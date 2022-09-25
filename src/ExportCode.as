namespace MLHook {
    void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {}) {
        SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
    }
    void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {}) {
        PG_SCE_EventQueue.InsertLast(CustomEvent(type, data));
    }
    void Queue_SendCustomEvent(const string &in type, string[] &in data = {}) {
        throw('deprecated, use Queue_PG_SendCustomEvent');
    }


    void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
        CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ManialinkPage, replace));
    }
    void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
        NotifyTodo("InjectManialinkToMenu not yet implemented");
        // CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ManialinkPage, replace));
    }

    void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg) {
        throw('deprecated; use Queue_MessageManialinkPlayground');
    }

    void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg) {
        outboundMlMessages.InsertLast(OutboundMessage(PageUID, msg));
    }
    void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg) {
        NotifyTodo("Queue_MessageManialinkMenu not yet implemented");
        // outboundMlMessages.InsertLast(OutboundMessage(PageUID, msg));
    }

    const string get_GlobalPrefix() {return "MLHook";}
    const string get_EventPrefix() {return "MLHookE_";}
    const string get_QueuePrefix() {return "MLHook_Inbound_";}
    const string get_DebugPrefix() {return "MLHook_Debug_";}

    const string get_Version() {
        return Meta::GetPluginFromID("MLHook").Version;
    }

    void RequireVersionApi(const string &in versionReq) {
        if (Version != versionReq) {
            auto caller = Meta::ExecutingPlugin();
            NotifyVersionIssue("caller: " + caller.Name + " requires MLHook version: " + versionReq + ", but MLHook is at version " + Version);
            while (true) yield();
        }
    }
}
