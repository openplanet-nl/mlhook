namespace MLHook {
    shared class HookMLEventsByType {
        string type;
        private Meta::Plugin@ _sourcePlugin;

        HookMLEventsByType() {
            @_sourcePlugin = Meta::ExecutingPlugin();
        }

        Meta::Plugin@ get_SourcePlugin() final {
            if (_sourcePlugin is null) throw("SourcePlugin cannot be null! Make sure you call `super()` during your constructor.");
            return _sourcePlugin;
        }

        void OnEvent(const string &in type, string[] &in data) {
            // todo, declare `void OnEvent(const string &in type, string[] &in data) override {}` in your class
            // to react to events.
            throw("OnEvent unimplemented");
        }
    }
}
