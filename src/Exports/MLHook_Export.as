namespace MLHook {
	// Queue an event to send via a Playground ScriptHandler's SendCustomEvent
	import void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";
	// Queue an event to send via the Playground's SendCustomEvent
	import void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";
	// *Deprecated* Queue an event to send via the Playground's SendCustomEvent
	import void Queue_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";
	// Queue an event to send via a Menu ScriptHandler's SendCustomEvent
	import void Queue_Menu_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";
	// Queue an event to send via Editor.PluginMapType's SendCustomEvent
	import void Queue_Editor_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";

	// Inject a ML page to the playground. The page name will be MLHook_PageUID.
	import void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false) from "MLHook";
	// Inject a ML page to the menu. The page name will be MLHook_PageUID.
	import void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false) from "MLHook";
	// Inject a ML page to editor.PluginMapType. The page name will be MLHook_PageUID.
	import void InjectManialinkToEditor(const string &in PageUID, const string &in ManialinkPage, bool replace = false) from "MLHook";
	// Remove an injected ML page with the given PageUID from the playground
	import void RemoveInjectedMLFromPlayground(const string &in PageUID) from "MLHook";
	// Remove an injected ML page with the given PageUID from the menu
	import void RemoveInjectedMLFromMenu(const string &in PageUID) from "MLHook";
	// Remove an injected ML page with the given PageUID from editor.PluginMapType
	import void RemoveInjectedMLFromEditor(const string &in PageUID) from "MLHook";

	// queue a message to a page with the given PageUID
	import void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg) from "MLHook";
	// queue messages to a page with the given PageUID
	import void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs) from "MLHook";
	// queue a message to an ML page on the game server (via netwrite) with the given PageUID
	import void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, const string &in msg) from "MLHook";
	// queue messages to an ML page on the game server (via netwrite) with the given PageUID
	import void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, string[] &in msgs) from "MLHook";
	// queue a message to a page in the menu with the given PageUID
	import void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) from "MLHook";
	// queue messages to a page in the menu with the given PageUID
	import void Queue_MessageManialinkMenu(const string &in PageUID, string[] &in msgs) from "MLHook";
	// queue a message to a page in editor.PluginMapType with the given PageUID
	import void Queue_MessageManialinkEditor(const string &in PageUID, const string &in msg) from "MLHook";
	// queue messages to a page in editor.PluginMapType with the given PageUID
	import void Queue_MessageManialinkEditor(const string &in PageUID, string[] &in msgs) from "MLHook";

	// deprecated:
	import void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg) from "MLHook";

	import const string get_GlobalPrefix() from "MLHook";
	import const string get_EventPrefix() from "MLHook";
	import const string get_QueuePrefix() from "MLHook";
	import const string get_NetQueuePrefix() from "MLHook";
	import const string get_DebugPrefix() from "MLHook";
	import const string get_LogMePrefix() from "MLHook";

	import const string get_PlaygroundHookEventName() from "MLHook";
	import const string get_MenuHookEventName() from "MLHook";
	import const string get_EditorHookEventName() from "MLHook";

	// Register a hook object to recieve events of the specified type (or the default for that page). The MLHook_Event_ prefix is automatically applied, unless isNadeoEvent is false
	import void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false) from "MLHook";
	// Unregister a hook object
	import void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj) from "MLHook";

	/**
	 	Unregister all of your plugins hooks and uninject ML pages (call in `OnDisabled` and `OnDestroyed`)

		This is the preferred way to unregister injections and hooks -- auto-detects the calling plugin.
	 */
	import void UnregisterMLHooksAndRemoveInjectedML() from "MLHook";
	// uninject all your plugins ML pages
	import void RemoveAllInjectedML() from "MLHook";

	import const string get_Version() from "MLHook";
	// Deprecated. The intent was to ensure MLHook's api was compatible, but breaking changes are not expected any longer
	import void RequireVersionApi(const string &in versionReq) from "MLHook";

	// Convert Maniascript code to an ML page
	import string ToMLScript(const string &in ManialinkPage) from "MLHook";

	/**
		*Warning:* Experimental.

		Register a function to be called during ML execution each frame. Note that the argument to the callback will always be null.

		Note that no way to remove these functions exists yet.
	*/
	import void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func) from "MLHook";
}
