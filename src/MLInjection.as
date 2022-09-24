class InjectionSpec {
    private string _PageUID;
    private string _ManialinkPage;
    private bool _replace = false;
    private CGameUILayer@ layer;

    InjectionSpec(const string &in PageUID, const string &in ManialinkPage, bool replace = false) {
        this._PageUID = PageUID;
        this._ManialinkPage = ManialinkPage;
        this._replace = replace;
    }

    const string get_PageUID() const {
        return _PageUID;
    }
    const string get_ManialinkPage() const {
        return _ManialinkPage;
    }
    const bool get_replace() const {
        return _replace;
    }

    CGameUILayer@ AwaitLayer() {
        while (layer is null) {
            yield();
        }
        return layer;
    }
}

array<InjectionSpec@> CMAP_InjectQueue = {};
array<InjectionSpec@> CMAP_CurrentInjections = {};

void RunPendingInjections() {
    if (cmap is null || cmap.UILayers.Length < 10) return;
    while (CMAP_InjectQueue.Length > 0) {
        auto spec = CMAP_InjectQueue[CMAP_InjectQueue.Length - 1];
        InjectIfNotPresent(spec);
        CMAP_CurrentInjections.InsertLast(spec);
        CMAP_InjectQueue.RemoveLast();
    }
}

void RerunInjectionsOnSetupCoro() {
    while (!uiPopulated) yield();
    for (uint i = 0; i < CMAP_CurrentInjections.Length; i++) {
        auto item = CMAP_CurrentInjections[i];
        InjectIfNotPresent(item);
    }
}

void InjectIfNotPresent(InjectionSpec@ spec) {
    const string _attachId = spec.PageUID;
    bool alreadyExists = false;
    auto layers = cmap.UILayers;
    CGameUILayer@ layer;
    for (uint i = 0; i < layers.Length; i++) {
        @layer = layers[i];
        if (layer.AttachId == _attachId) {
            alreadyExists = true;
            break;
        }
    }
    if (alreadyExists) {
        if (spec.replace) {
            // layer will be set to the last layer with the attach id
            if (layer.AttachId != _attachId) throw("Unexpected AttachId mismatch");
            layer.ManialinkPage = spec.ManialinkPage;
        }
        return;
    }
    @layer = cmap.UILayerCreate();
    layer.AttachId = _attachId;
    layer.ManialinkPage = spec.ManialinkPage;
}

class OutboundMessage {
    private string _PageUID;
    private string _msg;
    private string _queueName;
    private bool sent = false;
    OutboundMessage(const string &in PageUID, const string &in msg) {
        this._queueName = GenQueueName(PageUID);
        this._PageUID = PageUID;
        this._msg = msg;
    }
    const string get_PageUID() {
        return this._PageUID;
    }
    const string get_msg() {
        return this._msg;
    }
    const string get_queueName() {
        return this._queueName;
    }
    void MarkSent() {
        sent = true;
    }
}

OutboundMessage@[] outboundMlMessages = {};

void QueueOutboundMessage(OutboundMessage@ ob_msg) {
    outboundMlMessages.InsertLast(ob_msg);
}

const string GenQueueName(const string &in PageUID) {
    return MLHook::QueuePrefix + PageUID;
}

const string GenManialinkPageForOutbound() {
    if (outboundMlMessages.Length == 0) return "";
    dictionary msgsFor = dictionary();
    string _outboundMsgs = "";
    for (uint i = 0; i < outboundMlMessages.Length; i++) {
        auto item = outboundMlMessages[i];
        if (!msgsFor.Exists(item.queueName))
            msgsFor[item.queueName] = StringAccumulator();
        cast<StringAccumulator>(msgsFor[item.queueName]).Add(item.msg);
    }
    outboundMlMessages.RemoveRange(0, outboundMlMessages.Length);
    auto keys = msgsFor.GetKeys();
    for (uint i = 0; i < keys.Length; i++) {
        auto qName = keys[i];
        _outboundMsgs += "  declare Text[] " + qName + " for ClientUI;\n";
        StringAccumulator@ sa = cast<StringAccumulator>(msgsFor[qName]);
        for (uint i = 0; i < sa.items.Length; i++) {
            auto item = sa.items[i];
            _outboundMsgs += "  " + qName + ".add(\"" + item + "\");\n";
        }
    }
    return ("<script><!-- \n"
    + "main() {\n"
    + "declare Integer _Nonce = " + Time::Now + """;
yield;
""" + _outboundMsgs + """
SendCustomEvent("RanInjection", [""^_Nonce]);
}
--></script>""");
}

const string MLHook_DataInjectionAttachId = "MLHook_DataInjection";

void RunQueuedMlDataInjections() {
    if (cmap is null || outboundMlMessages.Length == 0) return;
    EnsureHooksEstablished();
    RunPendingInjections();
    auto layer = UpdateLayerWAttachIdOrMake(MLHook_DataInjectionAttachId, GenManialinkPageForOutbound());
    // layer.ManialinkPage = GenManialinkPageForOutbound();
}

CGameUILayer@ UpdateLayerWAttachIdOrMake(const string &in AttachId, wstring &in ManialinkPage) {
    if (cmap is null) return null;
    auto layers = cmap.UILayers;
    CGameUILayer@ layer;
    bool foundLayer = false;
    for (uint i = 0; i < layers.Length; i++) {
        @layer = layers[i];
        foundLayer = layer.AttachId == AttachId;
        if (foundLayer) break;
    }
    if (!foundLayer) {
        @layer = cmap.UILayerCreate();
        layer.AttachId = AttachId;
    }
    layer.ManialinkPage = ManialinkPage;
    return layer;
}
