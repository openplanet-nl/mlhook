namespace HookRouter {
	dictionary hooksByType = dictionary();
	array<MLHook::PendingEvent@> pendingEvents;
	dictionary hooksByPlugin = dictionary();
	bool shouldRouteLayerEvents = false;
	bool shouldRouteScriptHandlerEvents = false;
	bool shouldRoutePlaygroundEvents = false;

	void MainCoro() {
		pendingEvents.Reserve(100);
		while (true) {
			yield();
			for (uint i = 0; i < pendingEvents.Length; i++) {
				auto event = pendingEvents[i];
				// trace('got event for type: ' + type + ' with data of len: ' + data.Length);
				auto hs = GetHooksByType(event.type); // cast<array<MLHook::HookMLEventsByType@> >(hooksByType[event.type]);
				// hs can be null if a hook was unloaded before an event is processed
				if (hs !is null) {
					for (uint j = 0; j < hs.Length; j++) {
						auto hook = hs[j];
						// hook.OnEvent(event.type, event.data);
						uint startTime = Time::Now;
						hook.OnEvent(event);
						if (Time::Now - startTime > 1) {
							warn('Event processing for hook of type ' + hook.type + ' took ' + (Time::Now - startTime) + ' ms! Removing the hook for performance reasons.');
							UnregisterMLHook(hook);
							j--;
						}
					}
				}
			}
			pendingEvents.RemoveRange(0, pendingEvents.Length);
		}
	}

	void RegisterMLHook(MLHook::HookMLEventsByType@ hookObj, const string &in _type = "", bool isNadeoEvent = false) {
		if (hookObj is null) {
			warn("RegisterMLHook was passed a null hook object!");
			return;
		}
		string type = _type.Length == 0 ? hookObj.type : _type;
		if (!isNadeoEvent) {
			if (type.StartsWith(MLHook::EventPrefix)) {
				warn('RegisterMLHook given a type that starts with the event prefix (this is probably wrong)');
			}
			type = MLHook::EventPrefix + type;
		} else {
			// if we get any nadeo event capture requests, enable capturing SendCustomEvent events
			// shouldRouteLayerEvents = true; // don't enable layer events atm -- big performance hit in some places
			shouldRoutePlaygroundEvents = true;
			shouldRouteScriptHandlerEvents = true;
		}
		auto hooks = GetHooksByType(type);
		if (hooks.FindByRef(hookObj) < 0) {
			hooks.InsertLast(hookObj);
			trace("registered MLHook event for type: " + type);
			OnHookRegistered(hookObj);
		} else {
			warn("Attempted to add hook object for type " + type + " more than once. Refusing.");
		}
	}

	array<MLHook::HookMLEventsByType@>@ GetHooksByType(const string &in type, bool createIfAbsent = true) {
		auto hooks = cast<array<MLHook::HookMLEventsByType@>>(hooksByType[type]);
		if (hooks is null && createIfAbsent) {
			@hooks = array<MLHook::HookMLEventsByType@>();
			@hooksByType[type] = hooks;
		}
		return hooks;
	}

	array<MLHook::HookMLEventsByType@>@ GetHooksByPlugin(const string &in pluginID) {
		auto hooks = cast<array<MLHook::HookMLEventsByType@> >(hooksByPlugin[pluginID]);
		if (hooks is null) {
			@hooks = array<MLHook::HookMLEventsByType@>();
			@hooksByPlugin[pluginID] = hooks;
		}
		return hooks;
	}

	void OnHookRegistered(MLHook::HookMLEventsByType@ hookObj) {
		auto plugin = Meta::ExecutingPlugin();
		auto hooks = GetHooksByPlugin(plugin.ID);
		// if we already have a reference to this hook for this plugin don't add it again (e.g., b/c it watches multiple event types)
		auto ix = hooks.FindByRef(hookObj);
		if (ix < 0) {
			hooks.InsertLast(hookObj);
		}
	}

	// for a plugin's hooks, set all to null, set array length to 0, and delete the plugin's entry from the plugin->hooks map
	void UnregisterExecutingPluginsMLHooks() {
		auto plugin = Meta::ExecutingPlugin();
		if (hooksByPlugin.Exists(plugin.ID)) {
			auto hooks = GetHooksByPlugin(plugin.ID);
			for (uint i = 0; i < hooks.Length; i++) {
				UnregisterMLHook(hooks[i]);
				@hooks[i] = null;
			}
			hooks.RemoveRange(0, hooks.Length);
			hooksByPlugin.Delete(plugin.ID);
		}
	}

	// unregisters a hook object by checking all event types' list of hooks.
	void UnregisterMLHook(MLHook::HookMLEventsByType@ hookObj) {
		if (hookObj is null) return;
		auto types = hooksByType.GetKeys();
		string[] remTypes = {};
		for (uint i = 0; i < types.Length; i++) {
			auto hookType = types[i];
			auto hooks = GetHooksByType(hookType, false);
			int hookIx = hooks.FindByRef(hookObj);
			while (hookIx >= 0) {
				hooks.RemoveAt(hookIx);
				remTypes.InsertLast(hookType);
				hookIx = hooks.FindByRef(hookObj);
			}
			if (hooks.Length == 0) {
				hooksByType.Delete(hookType);
			}
		}
		if (remTypes.Length > 0) {
			trace('UnregisteredMLHook object for types: ' + string::Join(remTypes, ", "));
		}
	}

	void OnEvent(MLHook::PendingEvent@ event) {
		if (hooksByType.Exists(event.type))
			pendingEvents.InsertLast(event);
	}
}
