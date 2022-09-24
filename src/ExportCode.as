namespace MLHook {
    void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {}) {
        SH_SCE_EventQueue.InsertLast(CustomEvent(type, data));
    }
    void Queue_SendCustomEvent(const string &in type, string[] &in data = {}) {
        SCE_EventQueue.InsertLast(CustomEvent(type, data));
    }

    void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
        CMAP_InjectQueue.InsertLast(InjectionSpec(PageUID, ManialinkPage, replace));
    }

    void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg) {
        outboundMlMessages.InsertLast(OutboundMessage(PageUID, msg));
    }

    const string get_QueuePrefix() {return "MLHook_Inbound_";}
    const string get_DebugPrefix() {return "MLHook_Debug_";}
}
