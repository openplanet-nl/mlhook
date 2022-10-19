namespace MLHook {
    // Push an event to ScriptHandler.SendCustomEvent
    import void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";
    // Push an event to CGameManiaAppPlayground.SendCustomEvent
    import void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";
    // deprecated:
    import void Queue_SendCustomEvent(const string &in type, string[] &in data = {}) from "MLHook";

    // Inject some manialink code to react to custom events or whatnot
    import void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false) from "MLHook";
    import void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false) from "MLHook";
    import void RemoveInjectedMLFromPlayground(const string &in PageUID) from "MLHook";
    import void RemoveInjectedMLFromMenu(const string &in PageUID) from "MLHook";

    // Send a message to some manialink code that you injected
    import void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg) from "MLHook";
    import void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs) from "MLHook";
    import void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) from "MLHook";
    // deprecated:
    import void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg) from "MLHook";

    import const string get_EventPrefix() from "MLHook";
    import const string get_QueuePrefix() from "MLHook";
    import const string get_DebugPrefix() from "MLHook";
    import const string get_LogMePrefix() from "MLHook";

    import const string get_PlaygroundHookEventName() from "MLHook";

    // register some code that runs when particular events are detected
    import void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false) from "MLHook";
    import void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj) from "MLHook";

    // preferred way to unregister injections and hooks -- auto-detects the calling plugin.
    import void UnregisterMLHooksAndRemoveInjectedML() from "MLHook";

    import const string get_Version() from "MLHook";
    import void RequireVersionApi(const string &in versionReq) from "MLHook";

    import string ToMLScript(const string &in ManialinkPage) from "MLHook";

    // experimental api stuff below

#if DEV
    // idea: allow for other plugins to execute when ML to AS hook occurs
    import void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func) from "MLHook";
#endif
}
