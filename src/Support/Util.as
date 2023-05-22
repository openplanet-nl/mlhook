enum Cmp {Lt = -1, Eq = 0, Gt = 1}

MwFastBuffer<wstring> ArrStringToFastBufferWString(const string[] &in ss)
{
    MwFastBuffer<wstring> ret;
    for (uint i = 0; i < ss.Length; i++) {
        ret.Add(wstring(ss[i]));
    }
    return ret;
}

const string FastBufferWStringToString(MwFastBuffer<wstring> &in fbws)
{
    string[] items = array<string>(fbws.Length);
    for (uint i = 0; i < fbws.Length; i++) {
        auto item = fbws[i];
        items[i] = '"' + string(item).Replace('"', '\\"') + '"';
    }
    return "{" + string::Join(items, ', ') + "}";
}

const string ArrStringToString(const string[] &in ss)
{
    string[] items = array<string>(ss.Length);
    for (uint i = 0; i < ss.Length; i++) {
        auto item = ss[i];
        items[i] = '"' + string(item).Replace('"', '\\"') + '"';
    }
    return "{" + string::Join(items, ', ') + "}";
}

const string ArrUintToString(const uint[] &in ss)
{
    string[] items = array<string>(ss.Length);
    for (uint i = 0; i < ss.Length; i++) {
        auto item = ss[i];
        items[i] = '' + ss[i];
    }
    return "{" + string::Join(items, ', ') + "}";
}


class StringAccumulator
{
    string[] items = {};
    string name;
    string qFor;
    bool isNetwrite;
    StringAccumulator(const string &in name, const string &in qFor, bool isNetwrite)
    {
        this.name = name;
        this.qFor = qFor;
        this.isNetwrite = isNetwrite;
    }
    void Add(const string &in item)
    {
        items.InsertLast(item);
    }
}
