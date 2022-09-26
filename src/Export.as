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

    // Send a message to some manialink code that you injected
    import void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg) from "MLHook";
    import void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) from "MLHook";
    // deprecated:
    import void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg) from "MLHook";

    import const string get_EventPrefix() from "MLHook";
    import const string get_QueuePrefix() from "MLHook";
    import const string get_DebugPrefix() from "MLHook";
    import const string get_LogMePrefix() from "MLHook";

    import const string get_PlaygroundHookEventName() from "MLHook";

    import const string get_Version() from "MLHook";
    import void RequireVersionApi(const string &in versionReq) from "MLHook";

    import MLExecutionPointFeed@ get_ML_Hook_Feed() from "MLHook";
}
