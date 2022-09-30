namespace HookRouter {
    dictionary hooksByType;
    array<PendingEvent@> pendingEvents;
    dictionary hooksByPlugin;

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
        auto hooks = cast<array<MLHook::HookMLEventsByType@>>(hooksByType[type]);
        if (hooks.FindByRef(hookObj) < 0) {
            hooks.InsertLast(hookObj);
            trace("registered MLHook event for type: " + type);
            OnHookRegistered(hookObj);
        } else {
            warn("Attempted to add hook object for type " + type + " more than once. Refusing.");
        }
    }

    void OnHookRegistered(MLHook::HookMLEventsByType@ hookObj) {
        auto plugin = Meta::ExecutingPlugin();
        if (!hooksByPlugin.Exists(plugin.ID)) {
            @hooksByPlugin[plugin.ID] = array<MLHook::HookMLEventsByType@>();
        }
        auto hooks = cast<array<MLHook::HookMLEventsByType@>>(hooksByPlugin[plugin.ID]);
        if (hooks.FindByRef(hookObj) < 0) {
            hooks.InsertLast(hookObj);
        }
    }

    void UnregisterExecutingPluginsMLHooks() {
        auto plugin = Meta::ExecutingPlugin();
        if (hooksByPlugin.Exists(plugin.ID)) {
            auto hooks = cast<array<MLHook::HookMLEventsByType@>>(hooksByPlugin[plugin.ID]);
            for (uint i = 0; i < hooks.Length; i++) {
                UnregisterMLHook(hooks[i]);
            }
        }
    }

    void UnregisterMLHook(MLHook::HookMLEventsByType@ hookObj) {
        auto types = hooksByType.GetKeys();
        string[] remTypes = {};
        for (uint i = 0; i < types.Length; i++) {
            auto hookType = types[i];
            auto hooks = cast<array<MLHook::HookMLEventsByType@>>(hooksByType[hookType]);
            int hookIx = hooks.FindByRef(hookObj);
            if (hookIx >= 0) hooks.RemoveAt(hookIx);
            if (hooks.Length == 0) {
                hooksByType.Delete(hookType);
                remTypes.InsertLast(hookType);
            }
        }
        if (remTypes.Length > 0) {
            trace('UnregisteredMLHook object for types: ' + string::Join(remTypes, ", "));
        }
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
