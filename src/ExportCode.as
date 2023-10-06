namespace MLHook
{
	// Queue an event to send via a Playground ScriptHandler's SendCustomEvent
	void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {})
	{
		SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}
	// Queue an event to send via the Playground's SendCustomEvent
	void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {})
	{
		PG_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}
	// *Deprecated* Queue an event to send via the Playground's SendCustomEvent
	void Queue_SendCustomEvent(const string &in type, string[] &in data = {})
	{
		warn('deprecated, use Queue_PG_SendCustomEvent');
		Queue_PG_SendCustomEvent(type, data);
	}

	// Queue an event to send via a Menu ScriptHandler's SendCustomEvent
	void Queue_Menu_SendCustomEvent(const string &in type, string[] &in data = {})
	{
		Menu_SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}
	// Queue an event to send via Editor.PluginMapType's SendCustomEvent
	void Queue_Editor_SendCustomEvent(const string &in type, string[] &in data = {})
	{
		Editor_SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}

	// Inject a ML page to the playground. The page name will be MLHook_PageUID.
	void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false)
	{
		CheckProvidedManialinkPage(ManialinkPage);
		CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
	}
	// Inject a ML page to the menu. The page name will be MLHook_PageUID.
	void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false)
	{
		CheckProvidedManialinkPage(ManialinkPage);
		Menu_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
	}
	// Inject a ML page to editor.PluginMapType. The page name will be MLHook_PageUID.
	void InjectManialinkToEditor(const string &in PageUID, const string &in ManialinkPage, bool replace = false)
	{
		CheckProvidedManialinkPage(ManialinkPage);
		Editor_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
	}

	void CheckProvidedManialinkPage(const string &in src) {
		if (src.Contains("<manialink")) {
			throw("Refusing to inject ML script that already contains `<manialink>` tags. Please do not include these in your script (other ML tags are fine).");
		}
	}

	// Remove an injected ML page with the given PageUID from the playground
	void RemoveInjectedMLFromPlayground(const string &in PageUID)
	{
		RemoveInjected(cmap, CMAP_CurrentInjections, PageUID);
	}
	// Remove an injected ML page with the given PageUID from the menu
	void RemoveInjectedMLFromMenu(const string &in PageUID)
	{
		RemoveInjected(mcma, Menu_CurrentInjections, PageUID);
	}
	// Remove an injected ML page with the given PageUID from editor.PluginMapType
	void RemoveInjectedMLFromEditor(const string &in PageUID)
	{
		RemoveInjected(PluginMapType, Editor_CurrentInjections, PageUID);
	}


	// deprecated in favor of Queue_MessageManialinkPlayground
	void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg)
	{
		warn('deprecated; use Queue_MessageManialinkPlayground');
		Queue_MessageManialinkPlayground(PageUID, msg);
	}
	// queue a message to a page with the given PageUID
	void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg)
	{
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, {msg}));
	}
	// queue messages to a page with the given PageUID
	void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs)
	{
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, msgs));
	}
	// queue a message to an ML page on the game server (via netwrite) with the given PageUID
	void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, const string &in msg)
	{
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, {msg}, true));
	}
	// queue messages to an ML page on the game server (via netwrite) with the given PageUID
	void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, string[] &in msgs)
	{
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, msgs, true));
	}
	// queue a message to a page in the menu with the given PageUID
	void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg)
	{
		outboundMenuMLMessages.InsertLast(OutboundMessage(PageUID, {msg}));
	}
	// queue messages to a page in the menu with the given PageUID
	void Queue_MessageManialinkMenu(const string &in PageUID, string[] &in msgs)
	{
		outboundMenuMLMessages.InsertLast(OutboundMessage(PageUID, msgs));
	}
	// queue a message to a page in editor.PluginMapType with the given PageUID
	void Queue_MessageManialinkEditor(const string &in PageUID, const string &in msg)
	{
		outboundEditorMLMessages.InsertLast(OutboundMessage(PageUID, {msg}));
	}
	// queue messages to a page in editor.PluginMapType with the given PageUID
	void Queue_MessageManialinkEditor(const string &in PageUID, string[] &in msgs)
	{
		outboundEditorMLMessages.InsertLast(OutboundMessage(PageUID, msgs));
	}

	const string get_GlobalPrefix() {return "MLHook_";}
	const string get_EventPrefix() {return "MLHook_Event_";}
	const string get_QueuePrefix() {return "MLHook_Inbound_";}
	const string get_NetQueuePrefix() {return "MLHook_NetQueue_";}
	const string get_DebugPrefix() {return "MLHook_Debug_";}
	const string get_LogMePrefix() {return "MLHook_LogMe_";}

	const string _EventPrefix = "MLHook_Event_";
	const string _PlaygroundHookEventName	= "MLHook_Event_AngelScript_PG_Trigger";
	const string _MenuHookEventName			= "MLHook_Event_AngelScript_Menu_Trigger";
	const string _EditorHookEventName		= "MLHook_Event_AngelScript_Editor_Trigger";

	// note: hardcoded in PlaygroundMLExecutionPointFeed
	const string get_PlaygroundHookEventName() { return _PlaygroundHookEventName; }

	const string get_MenuHookEventName() { return _MenuHookEventName; }

	const string get_EditorHookEventName() { return _EditorHookEventName; }

	// Register a hook object to recieve events of the specified type (or the default for that page). The MLHook_Event_ prefix is automatically applied, except if isNadeoEvent is true
	void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false)
	{
		HookRouter::RegisterMLHook(hookObj, type, isNadeoEvent);
	}

	// Unregister a hook object
	void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj)
	{
		HookRouter::UnregisterMLHook(hookObj);
	}

	/**
	 	Unregister all of your plugins hooks and uninject ML pages (call in `OnDisabled` and `OnDestroyed`)

		This is the preferred way to unregister injections and hooks -- auto-detects the calling plugin.
	 */
	void UnregisterMLHooksAndRemoveInjectedML()
	{
		auto pluginName = Meta::ExecutingPlugin().Name;
		dev_trace('unloading for ' + pluginName + ': InjectedML');
		RemoveAllInjectedML();
		dev_trace('unloading for ' + pluginName + ': PluginsMLHooks');
		HookRouter::UnregisterExecutingPluginsMLHooks();
		dev_trace('unloading for ' + pluginName + ': Playground Callbacks');
		_ML_Hook_Feed.DeregisterCallbacksFrom(Meta::ExecutingPlugin());
		dev_trace('unloading for ' + pluginName + ': Done');
	}

	// uninject all your plugins ML pages
	void RemoveAllInjectedML()
	{
		RemovedExecutingPluginsManialinkFromPlayground();
		RemovedExecutingPluginsManialinkFromMenu();
		RemovedExecutingPluginsManialinkFromEditor();
	}


	const string get_Version()
	{
		return Meta::GetPluginFromID("MLHook").Version;
	}

	string[] versionsAlsoCompatible = {"0.3.0", "0.3.1", "0.3.2", "0.3.3", "0.3.4"
		, "0.4.0", "0.4.1", "0.4.2", "0.4.3", "0.4.4", "0.4.5", "0.4.6"
		, "0.5.0"
		, Meta::ExecutingPlugin().Version // add the current version in case of forgetfullness
	};

	// Deprecated. The intent was to ensure MLHook's api was compatible, but breaking changes are not expected any longer
	void RequireVersionApi(const string &in versionReq)
	{
		if (Version != versionReq && versionsAlsoCompatible.Find(versionReq) < 0) {
			auto caller = Meta::ExecutingPlugin();
			NotifyVersionIssue("caller: " + caller.Name + " requires MLHook version: " + versionReq + ", but MLHook is at version " + Version + " which is incompatible.");
			while (true) yield();
		}
	}

	// Convert Maniascript code to an ML page
	string ToMLScript(const string &in src)
	{
		if (src.Trim().StartsWith("<")) {
			// we already have XML, so assume the user has wrapped script code with script tags
			return src;
		}
		return "\n<script><!--\n\n" + src + "\n\n--></script>\n";
	}

	class PlaygroundMLExecutionPointFeed : MLFeed
	{
		PlaygroundMLExecutionPointFeed()
		{
			// does not match an event, will be called manually during interception
			super("");
		}

		ref@ Preprocess(MwFastBuffer<wstring> &in data) override
		{
			return null;
		}
	}

	PlaygroundMLExecutionPointFeed _ML_Hook_Feed;


	/**
		*Warning:* Experimental.

		Register a function to be called during ML execution each frame. Note that the argument to the callback will always be null.

		~~Note that no way to remove these functions exists yet.~~
	*/
	void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func)
	{
		_ML_Hook_Feed.RegisterCallback(func);
	}
}
