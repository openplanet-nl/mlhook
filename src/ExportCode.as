namespace MLHook {
	void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {}) {
		SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}
	void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {}) {
		PG_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}
	void Queue_SendCustomEvent(const string &in type, string[] &in data = {}) {
		warn('deprecated, use Queue_PG_SendCustomEvent');
		Queue_PG_SendCustomEvent(type, data);
	}
	void Queue_Menu_SendCustomEvent(const string &in type, string[] &in data = {}) {
		Menu_SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
	}


	void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
		CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
	}
	void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
		Menu_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
	}
	void RemoveInjectedMLFromPlayground(const string &in PageUID) {
		RemoveInjected(cmap, CMAP_CurrentInjections, PageUID);
	}
	void RemoveInjectedMLFromMenu(const string &in PageUID) {
		RemoveInjected(mcma, Menu_CurrentInjections, PageUID);
	}



	void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg) {
		warn('deprecated; use Queue_MessageManialinkPlayground');
		Queue_MessageManialinkPlayground(PageUID, msg);
	}

	void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg) {
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, {msg}));
	}
	void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs) {
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, msgs));
	}
	void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, const string &in msg) {
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, {msg}, true));
	}
	void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, string[] &in msgs) {
		outboundMLMessages.InsertLast(OutboundMessage(PageUID, msgs, true));
	}
	void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) {
		outboundMenuMLMessages.InsertLast(OutboundMessage(PageUID, {msg}));
	}
	void Queue_MessageManialinkMenu(const string &in PageUID, string[] &in msgs) {
		outboundMenuMLMessages.InsertLast(OutboundMessage(PageUID, msgs));
	}

	// void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) {
	//     NotifyTodo("Queue_MessageManialinkMenu not yet implemented - msg @XertroV");
	//     // outboundMLMessages.InsertLast(OutboundMessage(PageUID, msg));
	// }

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
	const string get_PlaygroundHookEventName() { return EventPrefix + "AngelScript_PG_Trigger"; }

	const string get_MenuHookEventName() { return EventPrefix + "AngelScript_Menu_Trigger"; }

	void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false) {
		HookRouter::RegisterMLHook(hookObj, type, isNadeoEvent);
	}

	void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj) {
		HookRouter::UnregisterMLHook(hookObj);
	}

	void UnregisterMLHooksAndRemoveInjectedML() {
		RemovedExecutingPluginsManialinkFromPlayground();
		RemovedExecutingPluginsManialinkFromMenu();
		HookRouter::UnregisterExecutingPluginsMLHooks();
	}

	void RemoveAllInjectedML() {
		RemovedExecutingPluginsManialinkFromPlayground();
		RemovedExecutingPluginsManialinkFromMenu();
	}


	const string get_Version() {
		return Meta::GetPluginFromID("MLHook").Version;
	}

	string[] versionsAlsoCompatible = {"0.3.0", "0.3.1", "0.3.2", "0.3.3", "0.3.4"
		, "0.4.0", "0.4.1", "0.4.2", "0.4.3", "0.4.4", "0.4.5", "0.4.6"
		, Meta::ExecutingPlugin().Version // add the current version in case of forgetfullness
	};

	void RequireVersionApi(const string &in versionReq) {
		if (Version != versionReq && versionsAlsoCompatible.Find(versionReq) < 0) {
			auto caller = Meta::ExecutingPlugin();
			NotifyVersionIssue("caller: " + caller.Name + " requires MLHook version: " + versionReq + ", but MLHook is at version " + Version + " which is incompatible.");
			while (true) yield();
		}
	}

	string ToMLScript(const string &in src) {
		return "\n<script><!--\n\n" + src + "\n\n--></script>\n";
	}

	class PlaygroundMLExecutionPointFeed : MLFeed {
		PlaygroundMLExecutionPointFeed() {
			// does not match an event, will be called manually during interception
			super("");
		}

		ref@ Preprocess(MwFastBuffer<wstring> &in data) override {
			return null;
		}
	}

	PlaygroundMLExecutionPointFeed _ML_Hook_Feed;

	// note: callback arg is always null
	void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func) {
		_ML_Hook_Feed.RegisterCallback(func);
	}
}
