namespace PanicMode {
    bool _NO_SET_DIRECT_active = false;

    bool get_IsActive() {
        return _NO_SET_DIRECT_active;
    }

    void Activate(const string &in msg) {
        _NO_SET_DIRECT_active = true;
        warn("[PANIC MODE] Activation reason: " + msg);
        // UI::ShowNotification("MLHook Panic Mode", "MLHook encountered a serious error and is terminating for your safety.\n> " + msg vec4(.9, .3, .1, .2));
        __PanicModeNotification(msg);
    }

    void __PanicModeNotification(const string &in msg) {
        UI::ShowNotification("\\$sMLHook Panic Mode",
            "\\$sMLHook encountered a serious error and is terminating for your safety.\n> " + msg,
            vec4(.7, .3, .2, .85),
            10000);
    }

#if DEV
    void TestPanicMode() {
        if (IsActive) throw('cannot test panic mode when panic is being had');
        Activate("testing panic mode");
        _NO_SET_DIRECT_active = false;
    }
#endif
}
