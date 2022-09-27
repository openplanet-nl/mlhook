namespace HookRouter {
    dictionary hooksByType;
    array<PendingEvent@> pendingEvents;

    void MainCoro() {
        while (true) {
            yield();
            while (pendingEvents.Length > 0) {
                auto event = pendingEvents[pendingEvents.Length - 1];
                pendingEvents.RemoveLast();
                // trace('got event for type: ' + type + ' with data of len: ' + data.Length);
                auto hs = cast<array<MLHook::HookMLEventsByType@>>(hooksByType[event.type]);
                if (hs is null) {
                    warn("unexpected hooksByType[" + event.type + "] is null");
                }
                for (uint i = 0; i < hs.Length; i++) {
                    auto hook = hs[i];
                    hook.OnEvent(event.type, event.data);
                }
            }
        }
    }

    void RegisterMLHook(MLHook::HookMLEventsByType@ hookObj, const string &in _type = "") {
        string type = _type.Length == 0 ? hookObj.type : _type;
        if (type.StartsWith(MLHook::EventPrefix)) {
            warn('RegisterMLHook given a type that starts with the event prefix (this is probably wrong)');
        }
        type = MLHook::EventPrefix + type;
        if (!hooksByType.Exists(type)) {
            @hooksByType[type] = array<MLHook::HookMLEventsByType@>();
        }
        cast<array<MLHook::HookMLEventsByType@>>(hooksByType[type]).InsertLast(hookObj);
        trace("registered MLHook event for type: " + type);
    }

    void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) {
        if (hooksByType.Exists(type)) {
            pendingEvents.InsertLast(PendingEvent(type, data));
        }
    }

    class PendingEvent {
        string type;
        MwFastBuffer<wstring> data;
        PendingEvent(const string &in _t, MwFastBuffer<wstring> _d) {
            type = _t; data = _d;
        }
    }
}
