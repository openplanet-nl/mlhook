class CustomEvent {
    wstring type;
    MwFastBuffer<wstring> data;
    // for capturing only
    string source;
    private uint _time = Time::Stamp;
    uint repeatCount = 0;  // for recording repeats during capturing

    // no source -- from angelscript code
    CustomEvent(const string &in type, string[] &in data = {}) {
        this.type = wstring(type);
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(wstring(item));
        }
    }

    // must have a source, from a capture source
    CustomEvent(wstring &in type, MwFastBuffer<wstring> &in data, const string &in source) {
        this.type = wstring(type);
        this.source = source;
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(item);
        }
    }

    const string ToString(bool justData = false) {
        string dataStr = "{";
        for (uint i = 0; i < data.Length; i++) {
            dataStr += "\"" + data[i] + (i < data.Length - 1 ? "\", " : "\"");
        }
        dataStr += "}";
        if (justData) return dataStr;
        if (source.Length > 0)
            dataStr += ", Source=" + source;
        return "CustomEvent(" + type + ", " + dataStr + ")";
    }

    // does not include _time! just for comparing if too events are basically identical
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
