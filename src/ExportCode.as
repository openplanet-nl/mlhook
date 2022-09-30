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


    void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
        CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
    }
    void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
        NotifyTodo("InjectManialinkToMenu not yet implemented");
        // CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ToMLScript(ManialinkPage), Meta::ExecutingPlugin().ID, replace));
    }
    void RemoveInjectedMLFromPlayground(const string &in PageUID) {
        RemoveInjected(PageUID);
    }
    void RemoveInjectedMLFromMenu(const string &in PageUID) {
        NotifyTodo("RemoveInjectedMLFromMenu not yet implemented");
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

    void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) {
        NotifyTodo("Queue_MessageManialinkMenu not yet implemented");
        // outboundMLMessages.InsertLast(OutboundMessage(PageUID, msg));
    }

    const string get_GlobalPrefix() {return "MLHook_";}
    const string get_EventPrefix() {return "MLHook_Event_";}
    const string get_QueuePrefix() {return "MLHook_Inbound_";}
    const string get_DebugPrefix() {return "MLHook_Debug_";}
    const string get_LogMePrefix() {return "MLHook_LogMe_";}

    // note: hardcoded in PlaygroundMLExecutionPointFeed
    const string get_PlaygroundHookEventName() { return EventPrefix + "AngelScript_PG_Trigger"; }

    void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "") {
        HookRouter::RegisterMLHook(hookObj, type);
    }

    void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj) {
        HookRouter::UnregisterMLHook(hookObj);
    }

    void UnregisterMLHooksAndRemoveInjectedML() {
        HookRouter::UnregisterExecutingPluginsMLHooks();
        RemovedExecutingPluginsManialinkFromPlayground();
    }


    const string get_Version() {
        return Meta::GetPluginFromID("MLHook").Version;
    }

    string[] versionsAlsoCompatible = {"0.2.0"};

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
            super("MLHook_Event_AngelScript_PG_Trigger");
        }

        ref@ Preprocess(string[] &in data) final {
            return null;
        }
    }

    PlaygroundMLExecutionPointFeed _ML_Hook_Feed;
    // PlaygroundMLExecutionPointFeed@ get_ML_Hook_Feed() { return _ML_Hook_Feed; }

    // note: callback arg is always null
#if DEV
    void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func) {
        _ML_Hook_Feed.RegisterCallback(func);
    }
#endif
}
