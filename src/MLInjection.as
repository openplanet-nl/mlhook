/*

8b    d8 88         88 88b 88  88888 888888  dP""b8 888888
88b  d88 88         88 88Yb88     88 88__   dP   `"   88
88YbdP88 88  .o     88 88 Y88 o.  88 88""   Yb        88
88 YY 88 88ood8     88 88  Y8 "bodP' 888888  YboodP   88

ML INJECTIONS

*/

class InjectionSpec {
    private string _PageUID;
    private string _ManialinkPage;
    private string _ExecPluginID;
    private bool _replace = false;
    private CGameUILayer@ layer;

    InjectionSpec(const string &in PageUID, const string &in ManialinkPage, const string &in ExecPluginID, bool replace = false) {
        this._PageUID = PageUID;
        this._ManialinkPage = ManialinkPage;
        this._ExecPluginID = ExecPluginID;
        this._replace = replace;
        @this.layer = null;
    }

    const string get_PageUID() const {
        return _PageUID;
    }
    const string get_ManialinkPage() const {
        return _ManialinkPage;
    }
    const string get_ExecPluginID() const {
        return _ExecPluginID;
    }
    const bool get_replace() const {
        return _replace;
    }

    CGameUILayer@ AwaitLayer() {
        while (this.layer is null) {
            yield();
        }
        return layer;
    }

    void set_Layer(CGameUILayer@ _layer) {
        @layer = _layer;
    }

    CGameUILayer@ get_Layer() {
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

const string GenAttachId(const string &in PageUID) {
    return MLHook::GlobalPrefix + PageUID;
}

void InjectIfNotPresent(InjectionSpec@ spec) {
    const string _attachId = GenAttachId(spec.PageUID);
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
            @spec.Layer = layer;
        }
        return;
    }
    @layer = cmap.UILayerCreate();
    layer.AttachId = _attachId;
    layer.ManialinkPage = spec.ManialinkPage;
    @spec.Layer = layer;
}

const string RemnantAttachId = "RemnantOfHook_RemoveMe";

void CleanUpLayer(CGameUILayer@ layer) {
    if (layer is null) return;
    layer.ManialinkPage = MinimalManialinkPageCode; // deleting layers sometimes crashes the game, this is easier
    layer.AttachId = RemnantAttachId;
    // todo: can we delete layers?
}

void CleanUpRemnants() {
    warn("CleanUpRemnants currently crashes the game, sometimes at least.");
    // can trigger it manually from NodExplorer but calling it here crashes the game :(
    return; // until a method is found
    /*
    if (cmap is null) return;
    for (uint i = 0; i < cmap.UILayers.Length; i++) {
        auto layer = cmap.UILayers[i];
        if (layer.AttachId == RemnantAttachId) {
            cmap.UILayerDestroy(layer);
            i--;
        }
    }
    */
}

void RemoveAllInjections() {
    // clear our cached injections
    CMAP_InjectQueue.RemoveRange(0, CMAP_InjectQueue.Length);
    CMAP_CurrentInjections.RemoveRange(0, CMAP_CurrentInjections.Length);
    // undo injected layers if they exist
    if (cmap is null) return;
    auto layers = cmap.UILayers;
    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
        if (layer.AttachId.StartsWith(MLHook::GlobalPrefix)) {
            CleanUpLayer(layer);
        }
    }
    // CleanUpRemnants();
}

void RemoveInjected(const string &in PageUID) {
    // don't reinject it
    for (uint i = 0; i < CMAP_CurrentInjections.Length; i++) {
        auto item = CMAP_CurrentInjections[i];
        if (item.PageUID == PageUID) {
            CMAP_CurrentInjections.RemoveAt(i);
            break;
        }
    }
    if (cmap is null) return; // can't remove layers if none exist
    // unload it if it's loaded
    auto _attachId = GenAttachId(PageUID);
    auto layers = cmap.UILayers;
    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
        if (layer.AttachId == _attachId) {
            CleanUpLayer(layer);
            break;
        }
    }
    // startnew(CleanUpRemnants);
}

void RemovedExecutingPluginsManialinkFromPlayground() {
    auto plugin = Meta::ExecutingPlugin();
    InjectionSpec@[] toRem = {};
    for (uint i = 0; i < CMAP_CurrentInjections.Length; i++) {
        auto spec = CMAP_CurrentInjections[i];
        if (spec.ExecPluginID == plugin.ID) {
            CleanUpLayer(spec.Layer);
            CMAP_CurrentInjections.RemoveAt(i);
            i--;
        }
    }
    for (uint i = 0; i < CMAP_InjectQueue.Length; i++) {
        auto spec = CMAP_InjectQueue[i];
        if (spec.ExecPluginID == plugin.ID) {
            CleanUpLayer(spec.Layer);
            CMAP_InjectQueue.RemoveAt(i);
            i--;
        }
    }
}


/*

   db    .dP"Y8              `Yb.       8b    d8 88
  dPYb   `Ybo."     ________   `Yb.     88b  d88 88
 dP__Yb  o.`Y8b     """"""""   .dP'     88YbdP88 88  .o
dP""""Yb 8bodP'              .dP'       88 YY 88 88ood8

MESSAGES FROM AS TO ML

*/


class OutboundMessage {
    private string _PageUID;
    private string[] _msgs;
    private string _queueName;
    private bool sent = false;
    OutboundMessage(const string &in PageUID, string[] &in msgs) {
        this._queueName = GenQueueName(PageUID);
        this._PageUID = PageUID;
        this._msgs = msgs;
    }
    const string get_PageUID() {
        return this._PageUID;
    }
    const string[] get_msgs() {
        return this._msgs;
    }
    const string get_queueName() {
        return this._queueName;
    }
    void MarkSent() {
        sent = true;
    }
}

OutboundMessage@[] outboundMLMessages = {};

void QueueOutboundMessage(OutboundMessage@ ob_msg) {
    outboundMLMessages.InsertLast(ob_msg);
}

const string GenQueueName(const string &in PageUID) {
    return MLHook::QueuePrefix + PageUID;
}

const string GenManialinkPageForOutbound() {
    if (outboundMLMessages.Length == 0) return "";
    dictionary msgsFor = dictionary();
    string _outboundMsgs = "";
    for (uint i = 0; i < outboundMLMessages.Length; i++) {
        auto item = outboundMLMessages[i];
        if (!msgsFor.Exists(item.queueName))
            msgsFor[item.queueName] = StringAccumulator();
        cast<StringAccumulator>(msgsFor[item.queueName]).Add("[\"" + string::Join(item.msgs, '","') + "\"]");
    }
    trace('MLHook preparing ' + outboundMLMessages.Length + ' outbound messages to ML');
    outboundMLMessages.RemoveRange(0, outboundMLMessages.Length);
    auto keys = msgsFor.GetKeys();
    for (uint i = 0; i < keys.Length; i++) {
        auto qName = keys[i];
        _outboundMsgs += "  declare Text[][] " + qName + " for ClientUI;\n";
        StringAccumulator@ sa = cast<StringAccumulator>(msgsFor[qName]);
        for (uint j = 0; j < sa.items.Length; j++) {
            auto item = sa.items[j];
            _outboundMsgs += "  " + qName + ".add(" + item + ");\n";
        }
    }
    return ("<script><!-- \n"
    + "main() {\n"
    + "declare Integer _Nonce = " + Time::Now + """;
yield;
""" + _outboundMsgs + """
SendCustomEvent("MLHook_Debug_RanMsgSend", [""^_Nonce]);
}
--></script>""");
}

const string MLHook_DataInjectionAttachId = "MLHook_DataInjection";

void RunQueuedMLDataInjections() {
    if (cmap is null || outboundMLMessages.Length == 0) return;
    EnsureHooksEstablished();
    RunPendingInjections();
    auto layer = UpdateLayerWAttachIdOrMake(MLHook_DataInjectionAttachId, GenManialinkPageForOutbound(), false);
}

CGameUILayer@ UpdateLayerWAttachIdOrMake(const string &in AttachId, wstring &in ManialinkPage, bool canBeRunning = true) {
    if (cmap is null) return null;
    auto layers = cmap.UILayers;
    CGameUILayer@ layer;
    bool foundLayer = false;
    for (uint i = 0; i < layers.Length; i++) {
        @layer = layers[i];
        foundLayer = layer.AttachId == AttachId;
        if (foundLayer && !canBeRunning && layer.IsLocalPageScriptRunning) continue;
        if (foundLayer) break;
    }
    if (!foundLayer) {
        @layer = cmap.UILayerCreate();
        layer.AttachId = AttachId;
    }
    layer.ManialinkPage = ManialinkPage;
    return layer;
}
