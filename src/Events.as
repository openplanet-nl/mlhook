enum EventSource
    { Any = 0
    , LayerCE // LayerCustomEvent
    , PG_SendCE // Playground.SendCustomEvent
    , SH_SendCE // ScriptHandler.SendCustomEvent
    , PluginCE // SendPluginEvent -> CGameManiaAppScriptEvent? (mb)
    , ML_SE // CGameManialinkScriptEvent
    , MA_SE // todo: CGameManiaAppScriptEvent
    , MAPG_SE // todo: verify CGameManiaAppPlaygroundScriptEvent works
    , InputSE // CInputScriptEvent
    }

EventSource[] AllEventSources =
    { EventSource::Any
    , EventSource::LayerCE
    , EventSource::PG_SendCE
    , EventSource::SH_SendCE
    , EventSource::PluginCE
    , EventSource::ML_SE
    , EventSource::MA_SE
    , EventSource::MAPG_SE
    , EventSource::InputSE
    };

string[] EventSourceLegend =
    { "Any or Unknown"
    , "via LayerCustomEvent() (working)"
    , "via Playground.SendCustomEvent() (working)"
    , "via ScriptHandler.SendCustomEvent() (working)"
    , "via CGameEditorMainPlugin.SendPluginEvent() (working? idk)"
    , "CGameManialinkScriptEvent via ScriptHandler.PendingEvents (note: possibly does not catch all events)"
    , "CGameManiaAppScriptEvent via ManiaApp.PendingEvents (not working?)"
    , "CGameManiaAppPlaygroundScriptEvent via ManiaAppPlayground.PendingEvents (not working)"
    , "CInputScriptEvent via Input.PendingEvents (not working)"
    };

const string EventSourceToString(EventSource es, bool colorize = true) {
    if (!colorize) return tostring(es);
    switch (es) {
        case EventSource::Any: return tostring(es);
        case EventSource::LayerCE: return "\\$db2" + tostring(es) + "\\$z";
        case EventSource::PG_SendCE: return "\\$2d2" + tostring(es) + "\\$z";
        case EventSource::SH_SendCE: return "\\$d2d" + tostring(es) + "\\$z";
        case EventSource::PluginCE: return "\\$b61" + tostring(es) + "\\$z";
        case EventSource::ML_SE: return "\\$6bf" + tostring(es) + "\\$z";
        case EventSource::MA_SE: return "\\$f22" + tostring(es) + "\\$z";
        case EventSource::MAPG_SE: return "\\$f19" + tostring(es) + "\\$z";
        case EventSource::InputSE: return "\\$19f" + tostring(es) + "\\$z";
    }
    return tostring(es);
}

class CustomEvent {
    wstring type;
    string s_type;
    MwFastBuffer<wstring> data;
    string[] s_data;
    // for capturing only
    EventSource source = EventSource::Any;
    string s_source;
    private uint _time = Time::Stamp;
    uint repeatCount = 0;  // for recording repeats during capturing
    CGameUILayer@ layer;
    CGameEditorPluginHandle@ handle;
    string annotation;

    // no source -- from angelscript code
    CustomEvent(const string &in type, string[] &in data = {}) {
        this.s_type = type;
        this.type = wstring(type);
        this.s_data = data;
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(wstring(item));
        }
    }

    // must have a source, from a capture source
    CustomEvent(wstring &in type, MwFastBuffer<wstring> &in data, EventSource &in source, const string &in annotation = "",
            CGameUILayer@ layer = null, CGameEditorPluginHandle@ handle = null) {
        this.type = wstring(type);
        this.s_type = string(type);
        this.source = source;
        this.s_data.Resize(data.Length);
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(item);
            this.s_data[i] = string(item);
        }
        this.annotation = annotation;
        @this.layer = layer;
        @this.handle = handle;
    }

    string s_data_csv;
    string s_final;
    const string ToString(bool justData = false) {
        if (s_data_csv.Length == 0) {
            s_data_csv = "{";
            for (uint i = 0; i < s_data.Length; i++) {
                s_data_csv += "\"" + string(s_data[i]).Replace('"', '\\"') + (i < s_data.Length - 1 ? "\", " : "\"");
            }
            s_data_csv += "}";
        }
        if (justData) return s_data_csv;
        if (s_final.Length == 0) {
            s_final = "CustomEvent(" + s_type + ", " + s_data_csv;
            if (source != EventSource::Any)
                s_final += ", Source=" + SourceStr;
            s_final += ")";
        }
        return s_final;
    }

    const string get_SourceStr() {
        if (s_source.Length == 0)
            s_source = AnnoPrefix + EventSourceToString(source, false);
        return s_source;
    }

    const string get_AnnoPrefix() {
        return (annotation.Length > 0 ? "[" + annotation + "] " : "");
    }

    // does not include _time! just for comparing if two events are basically identical
    bool opEquals(const CustomEvent@ &in other) const {
        if (string(type) != string(other.type)) return false;
        if (source != other.source) return false;
        if (data.Length != other.data.Length) return false;
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            if (string(item) != string(other.data[i])) return false;
        }
        return true;
    }

    uint get_time() {
        return _time;
    }
}
