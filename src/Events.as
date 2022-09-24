enum EventSource
    { Any = 0
    , LayerCE // LayerCustomEvent
    , PG_SendCE // Playground.SendCustomEvent
    , SH_SendCE // ScriptHandler.SendCustomEvent
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
    , EventSource::ML_SE
    , EventSource::MA_SE
    , EventSource::MAPG_SE
    , EventSource::InputSE
    };

const string EventSourceToString(EventSource es, bool colorize = true) {
    if (!colorize) return tostring(es);
    switch (es) {
        case EventSource::Any: return tostring(es);
        case EventSource::LayerCE: return "\\$db2" + tostring(es) + "\\$z";
        case EventSource::PG_SendCE: return "\\$2d2" + tostring(es) + "\\$z";
        case EventSource::SH_SendCE: return "\\$d2d" + tostring(es) + "\\$z";
        case EventSource::ML_SE: return "\\$6bf" + tostring(es) + "\\$z";
        case EventSource::MA_SE: return "\\$f22" + tostring(es) + "\\$z";
        case EventSource::MAPG_SE: return "\\$f19" + tostring(es) + "\\$z";
        case EventSource::InputSE: return "\\$19f" + tostring(es) + "\\$z";
    }
    return tostring(es);
}

class CustomEvent {
    wstring type;
    MwFastBuffer<wstring> data;
    // for capturing only
    EventSource source = EventSource::Any;
    private uint _time = Time::Stamp;
    uint repeatCount = 0;  // for recording repeats during capturing
    CGameUILayer@ layer;
    string annotation;

    // no source -- from angelscript code
    CustomEvent(const string &in type, string[] &in data = {}) {
        this.type = wstring(type);
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(wstring(item));
        }
    }

    // must have a source, from a capture source
    CustomEvent(wstring &in type, MwFastBuffer<wstring> &in data, EventSource &in source, const string &in annotation = "", CGameUILayer@ layer = null) {
        this.type = wstring(type);
        this.source = source;
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(item);
        }
        this.annotation = annotation;
        @this.layer = layer;
    }

    const string ToString(bool justData = false) {
        string dataStr = "{";
        for (uint i = 0; i < data.Length; i++) {
            dataStr += "\"" + string(data[i]).Replace('"', '\\"') + (i < data.Length - 1 ? "\", " : "\"");
        }
        dataStr += "}";
        if (justData) return dataStr;
        if (source != EventSource::Any)
            dataStr += ", Source=" + SourceStr;
        return "CustomEvent(" + type + ", " + dataStr + ")";
    }

    const string get_SourceStr() {
        return AnnoPrefix + EventSourceToString(source, false);
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
