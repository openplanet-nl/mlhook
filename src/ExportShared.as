namespace MLHook {

    shared class HookMLEventsByType {
        private string _type;
        private Meta::Plugin@ _sourcePlugin;

        HookMLEventsByType(const string &in typeToHook) {
            @_sourcePlugin = Meta::ExecutingPlugin();
            this._type = typeToHook;
        }

        const string get_type() {
            return this._type;
        }

        Meta::Plugin@ get_SourcePlugin() final {
            if (_sourcePlugin is null) throw("SourcePlugin cannot be null! Make sure you call `super()` during your constructor.");
            return _sourcePlugin;
        }

        // todo: considering if OnEvent should be string[] or MwFastBuffer<wstring>
        void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) {
            // todo, declare `void OnEvent(const string &in type, string[] &in data) override {}` in your class
            // to react to events.
            throw("OnEvent unimplemented");
        }

        void NotifyMLHookError(const string &in msg) final {
            warn(msg);
            UI::ShowNotification("MLHook Error", msg, vec4(.9, .6, .1, .5), 7500);
        }
    }

    shared funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
    shared funcdef void MLFeedFunction(ref@ processedData);

    shared class MLFeed : HookMLEventsByType {
        MLFeedFunctionRaw@[] callbacksRaw;
        Meta::Plugin@[] callbackRawPlugins;
        MLFeedFunction@[] callbacks;
        Meta::Plugin@[] callbackPlugins;

        MLFeed(const string &in typeToDistribute) {
            super(typeToDistribute);
        }

        void RegisterCallback(MLFeedFunction@ cb) {
            if (cb is null)
                throw('cannot register a null callback');
            callbacks.InsertLast(cb);
            callbackPlugins.InsertLast(Meta::ExecutingPlugin());
        }

        void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) override final {
            auto obj = Preprocess(data);
            // i needs to be int in case of an issue with index 0
            for (int i = 0; i < int(callbacksRaw.Length); i++) {
                try {
                    callbacksRaw[i](data);
                } catch {
                    // todo: test
                    NotifyMLHookError("Exception in callback for " + callbackRawPlugins[i].Name + " -- it will be disabled.\n\nException details:\n" + getExceptionInfo());
                    callbacksRaw.RemoveAt(i);
                    callbackRawPlugins.RemoveAt(i);
                    i--;
                }
            }
            for (int i = 0; i < int(callbacks.Length); i++) {
                try {
                    callbacks[i](obj);
                } catch {
                    // todo: test
                    NotifyMLHookError("Exception in callback for " + callbackRawPlugins[i].Name + " -- it will be disabled.\n\nException details:\n" + getExceptionInfo());
                    callbacks.RemoveAt(i);
                    callbackPlugins.RemoveAt(i);
                    i--;
                }
            }
        }

        ref@ Preprocess(MwFastBuffer<wstring> &in data) {
            throw('override Preprocess(data).');
            return null;
        }
    }

    shared class DebugLogAllHook : HookMLEventsByType {
        DebugLogAllHook(const string &in eventType) {
            super(eventType);
        }

        void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) override final {
            string dataStr = (data.Length == 0) ? "{" : "{ ";
            for (uint i = 0; i < data.Length; i++) {
                if (i > 0) dataStr += ", ";
                dataStr += data[i];
            }
            dataStr += (data.Length == 0) ? "}" : " }";
            trace('[DebugLogAllHook] Type: ' + type + ', Data: ' + dataStr);
        }
    }
}
