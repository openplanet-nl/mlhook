namespace HookRouter {
    dictionary hooksByType;

    void RegisterMLHook(MLHook::HookMLEventsByType@ hookObj) {
        auto type = MLHook::EventPrefix + hookObj.type;
        if (!hooksByType.Exists(type)) {
            @hooksByType[type] = array<MLHook::HookMLEventsByType@>();
        }
        cast<array<MLHook::HookMLEventsByType@>>(hooksByType[type]).InsertLast(hookObj);
        trace("registered MLHook event for type: " + type);
        // print("n hooks: " + cast<array<MLHook::HookMLEventsByType@>>(hooksByType[type]).Length);
    }

    void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) {
        if (hooksByType.Exists(type)) {
            // trace('got event for type: ' + type + ' with data of len: ' + data.Length);
            auto hs = cast<array<MLHook::HookMLEventsByType@>>(hooksByType[type]);
            if (hs is null) throw("unexpected hooksByType[type] is null");
            for (uint i = 0; i < hs.Length; i++) {
                auto hook = hs[i];
                hook.OnEvent(type, data);
            }
        }
    }
}
