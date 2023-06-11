/*

8b    d8 88         88 88b 88  88888 888888  dP""b8 888888
88b  d88 88         88 88Yb88     88 88__   dP   `"   88
88YbdP88 88  .o     88 88 Y88 o.  88 88""   Yb        88
88 YY 88 88ood8     88 88  Y8 "bodP' 888888  YboodP   88

ML INJECTIONS

*/

class InjectionSpec
{
	private string _PageUID;
	private string _ManialinkPage;
	private string _ExecPluginID;
	private bool _replace = false;
	private CGameUILayer@ layer;

	InjectionSpec(const string &in PageUID, const string &in ManialinkPage, const string &in ExecPluginID, bool replace = false)
	{
		this._PageUID = PageUID;
		this._ManialinkPage = '\n<manialink name="' + GenAttachId(PageUID) + '" version="3">\n' + ManialinkPage + '\n</manialink>';
		this._ExecPluginID = ExecPluginID;
		this._replace = replace;
		@this.layer = null;
	}

	const string get_PageUID() const
	{
		return _PageUID;
	}
	const string get_ManialinkPage() const
	{
		return _ManialinkPage;
	}
	const string get_ExecPluginID() const
	{
		return _ExecPluginID;
	}
	const bool get_replace() const
	{
		return _replace;
	}

	CGameUILayer@ AwaitLayer()
	{
		while (this.layer is null) {
			yield();
		}
		return layer;
	}

	void set_Layer(CGameUILayer@ _layer)
	{
		@layer = _layer;
	}

	CGameUILayer@ get_Layer()
	{
		return layer;
	}
}

array<InjectionSpec@> CMAP_InjectQueue;
array<InjectionSpec@> CMAP_CurrentInjections;
array<InjectionSpec@> Menu_InjectQueue;
array<InjectionSpec@> Menu_CurrentInjections;
array<InjectionSpec@> Editor_InjectQueue;
array<InjectionSpec@> Editor_CurrentInjections;

void RunPendingInjections()
{
	if (cmap is null || cmap.UILayers.Length < 10) return;
	for (uint i = 0; i < CMAP_InjectQueue.Length; i++) {
		auto spec = CMAP_InjectQueue[i];
		InjectIfNotPresent(cmap, spec);
		CMAP_CurrentInjections.InsertLast(spec);
	}
	CMAP_InjectQueue.RemoveRange(0, CMAP_InjectQueue.Length);
}

void RunPendingMenuInjections()
{
	if (mcma is null || mcma.UILayers.Length < 20) return;
	for (uint i = 0; i < Menu_InjectQueue.Length; i++) {
		auto spec = Menu_InjectQueue[i];
		InjectIfNotPresent(mcma, spec);
		Menu_CurrentInjections.InsertLast(spec);
	}
	Menu_InjectQueue.RemoveRange(0, Menu_InjectQueue.Length);
}

void RunPendingEditorInjections()
{
	if (PluginMapType is null) return;
	for (uint i = 0; i < Editor_InjectQueue.Length; i++) {
		auto spec = Editor_InjectQueue[i];
		InjectIfNotPresent(PluginMapType, spec);
		Editor_CurrentInjections.InsertLast(spec);
	}
	Editor_InjectQueue.RemoveRange(0, Editor_InjectQueue.Length);
}

void RerunInjectionsOnSetupCoro()
{
	while (!uiPopulated) yield();
	// print("Injecting nb: " + CMAP_CurrentInjections.Length);
	for (uint i = 0; i < CMAP_CurrentInjections.Length; i++) {
		InjectIfNotPresent(cmap, CMAP_CurrentInjections[i]);
	}
}

void RunMenuInjectionOnSetup()
{
	while (mcma is null || mcma.UILayers.Length < 20) yield();
	for (uint i = 0; i < Menu_CurrentInjections.Length; i++) {
		InjectIfNotPresent(mcma, Menu_CurrentInjections[i]);
	}
}

void RunEditorInjectionOnSetup()
{
	while (PluginMapType is null) yield();
	for (uint i = 0; i < Editor_CurrentInjections.Length; i++) {
		InjectIfNotPresent(PluginMapType, Editor_CurrentInjections[i]);
	}
}

const string GenAttachId(const string &in PageUID)
{
	return MLHook::GlobalPrefix + PageUID;
}

void InjectIfNotPresent(CGameManiaApp@ mApp, InjectionSpec@ spec)
{
	const string _attachId = GenAttachId(spec.PageUID);
	bool alreadyExists = false;
	auto layers = mApp.UILayers;
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
	@layer = mApp.UILayerCreate();
	layer.AttachId = _attachId;
	layer.ManialinkPage = spec.ManialinkPage;
	@spec.Layer = layer;
}

const string RemnantAttachId = "RemnantOfHook_RemoveMe";

void CleanUpLayer(CGameUILayer@ layer)
{
	if (layer is null) return;
	// ~~testing: this might crash things; better to leave the ML there and just not reload
	// doesn't seem to be the source of the crash -- occurs on 2nd reload of mlhook while in a server
	layer.ManialinkPage = MinimalManialinkPageCode; // deleting layers sometimes crashes the game, this is easier
	layer.AttachId = RemnantAttachId;
	// todo: can we delete layers?

}

void CleanUpRemnants()
{
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

void RemoveAllInjections()
{
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

void RemoveInjected(CGameManiaApp@ mApp, InjectionSpec@[]@ currentInjections, const string &in PageUID)
{
	// dev_trace("Removing injection: " + PageUID);
	// don't reinject it
	for (uint i = 0; i < currentInjections.Length; i++) {
		auto item = currentInjections[i];
		if (item.PageUID == PageUID) {
			currentInjections.RemoveAt(i);
			break;
		}
	}
	if (mApp is null) return; // can't remove layers if none exist
	// unload it if it's loaded
	auto _attachId = GenAttachId(PageUID);
	for (uint i = 0; i < mApp.UILayers.Length; i++) {
		auto layer = mApp.UILayers[i];
		if (layer.AttachId == _attachId) {
			CleanUpLayer(layer);
			break;
		}
	}
	// startnew(CleanUpRemnants);
}

void RemovedExecutingPluginsManialinkFromPlayground()
{
	auto plugin = Meta::ExecutingPlugin();
	string[] toRem = {};
	for (uint i = 0; i < CMAP_CurrentInjections.Length; i++) {
		auto spec = CMAP_CurrentInjections[i];
		if (spec.ExecPluginID == plugin.ID) {
			toRem.InsertLast(spec.PageUID);
		}
	}
	for (uint i = 0; i < CMAP_InjectQueue.Length; i++) {
		auto spec = CMAP_InjectQueue[i];
		if (spec.ExecPluginID == plugin.ID) {
			CMAP_InjectQueue.RemoveAt(i);
			i--;
		}
	}
	for (uint i = 0; i < toRem.Length; i++) {
		RemoveInjected(cmap, CMAP_CurrentInjections, toRem[i]);
	}
}

void RemovedExecutingPluginsManialinkFromMenu()
{
	auto plugin = Meta::ExecutingPlugin();
	string[] toRem = {};
	for (uint i = 0; i < Menu_CurrentInjections.Length; i++) {
		auto spec = Menu_CurrentInjections[i];
		if (spec.ExecPluginID == plugin.ID) {
			toRem.InsertLast(spec.PageUID);
		}
	}
	for (uint i = 0; i < Menu_InjectQueue.Length; i++) {
		auto spec = Menu_InjectQueue[i];
		if (spec.ExecPluginID == plugin.ID) {
			Menu_InjectQueue.RemoveAt(i);
			i--;
		}
	}
	for (uint i = 0; i < toRem.Length; i++) {
		RemoveInjected(mcma, Menu_CurrentInjections, toRem[i]);
	}
}

void RemovedExecutingPluginsManialinkFromEditor()
{
	auto plugin = Meta::ExecutingPlugin();
	string[] toRem = {};
	for (uint i = 0; i < Editor_CurrentInjections.Length; i++) {
		auto spec = Editor_CurrentInjections[i];
		if (spec.ExecPluginID == plugin.ID) {
			toRem.InsertLast(spec.PageUID);
		}
	}
	for (uint i = 0; i < Editor_InjectQueue.Length; i++) {
		auto spec = Editor_InjectQueue[i];
		if (spec.ExecPluginID == plugin.ID) {
			Editor_InjectQueue.RemoveAt(i);
			i--;
		}
	}
	for (uint i = 0; i < toRem.Length; i++) {
		RemoveInjected(PluginMapType, Editor_CurrentInjections, toRem[i]);
	}
}


/*

   db    .dP"Y8              `Yb.       8b    d8 88
  dPYb   `Ybo."     ________   `Yb.     88b  d88 88
 dP__Yb  o.`Y8b     """"""""   .dP'     88YbdP88 88  .o
dP""""Yb 8bodP'              .dP'       88 YY 88 88ood8

MESSAGES FROM AS TO ML

*/


class OutboundMessage
{
	private string _PageUID;
	private string[]@ _msgs;
	private string _queueName;
	private bool sent = false;
	private bool _isNetwrite = false;
	OutboundMessage(const string &in PageUID, string[] &in msgs, bool isNetwrite = false) {
		this._queueName = GenQueueName(PageUID, isNetwrite);
		this._PageUID = PageUID;
		@this._msgs = msgs;
		this._isNetwrite = isNetwrite;
		for (uint i = 0; i < _msgs.Length; i++) {
			// Quick and dirty way to escape strings -- these now include surrounding quotes
			_msgs[i] = Json::Write(_msgs[i]);
		}
	}
	const string get_PageUID()
	{
		return this._PageUID;
	}
	const string[] get_msgs()
	{
		return this._msgs;
	}
	const string get_queueName()
	{
		return this._queueName;
	}
	const string QueueTypeAndName { get { return (_isNetwrite ? "netwrite Text[][] " : "Text[][] ") + _queueName; }}
	bool IsNetwrite { get { return _isNetwrite; }}

	void MarkSent()
	{
		sent = true;
	}
}

OutboundMessage@[] outboundMLMessages = {};
OutboundMessage@[] outboundMenuMLMessages = {};
OutboundMessage@[] outboundEditorMLMessages = {};

const string GenQueueName(const string &in PageUID, bool isNetwrite = false)
{
	return (isNetwrite ? MLHook::NetQueuePrefix : MLHook::QueuePrefix) + PageUID;
}

const string GenManialinkPageForOutbound(OutboundMessage@[]@ outboundMsgs, const string &in declareQFor, const string &in declareNWQFor = "UI")
{
	if (outboundMsgs.Length == 0) return "";
	dictionary msgsFor = dictionary();
	string _outboundMsgs = "";
	for (uint i = 0; i < outboundMsgs.Length; i++) {
		auto item = outboundMsgs[i];
		if (!msgsFor.Exists(item.QueueTypeAndName))
			@msgsFor[item.QueueTypeAndName] = StringAccumulator(item.queueName, item.IsNetwrite ? declareNWQFor : declareQFor, item.IsNetwrite);
		// item.msgs is a json encoded string, so already includes the quotes.
		cast<StringAccumulator>(msgsFor[item.QueueTypeAndName]).Add("[" + string::Join(item.msgs, ',') + "]");
	}

	trace('MLHook preparing ' + outboundMsgs.Length + ' outbound messages to ML');
	outboundMsgs.RemoveRange(0, outboundMsgs.Length);

	auto keys = msgsFor.GetKeys();
	for (uint i = 0; i < keys.Length; i++) {
		auto qTypeAndName = keys[i];
		StringAccumulator@ sa = cast<StringAccumulator>(msgsFor[qTypeAndName]);
		_outboundMsgs += "  declare " + qTypeAndName + " for " + sa.qFor + ";\n";
		if (sa.isNetwrite) _outboundMsgs += "  declare netwrite Integer " + sa.name + "_Last for " + sa.qFor + "; " + sa.name + "_Last += 1;\n";
		for (uint j = 0; j < sa.items.Length; j++) {
			_outboundMsgs += "  " + sa.name + ".add(" + sa.items[j] + ");\n";
		}
	}
	return ("\n<manialink name=\"MLHook_DataInjection\" version=\"3\"><script><!-- \n"
	+ "main() {\n"
	+ "declare Integer _Nonce = " + Time::Now + """;
yield;
""" + _outboundMsgs + """
SendCustomEvent("MLHook_Debug_RanMsgSend", [""^_Nonce]);
}
--></script>
</manialink>""");
}

const string MLHook_DataInjectionAttachId = "MLHook_DataInjection";

void RunQueuedMLDataInjections()
{
	if (cmap is null || outboundMLMessages.Length == 0) return;
	EnsureHooksEstablished();
	RunPendingInjections();
	auto layer = UpdateLayerWAttachIdOrMake(cmap, MLHook_DataInjectionAttachId, GenManialinkPageForOutbound(outboundMLMessages, "ClientUI"), false);
}

void RunQueuedMenuMLDataInjections()
{
	if (mcma is null || outboundMenuMLMessages.Length == 0) return;
	EnsureMenuHooksEstablished();
	RunPendingMenuInjections();
	auto layer = UpdateLayerWAttachIdOrMake(mcma, MLHook_DataInjectionAttachId, GenManialinkPageForOutbound(outboundMenuMLMessages, "LocalUser"), false);
}

void RunQueuedEditorMLDataInjections()
{
	if (PluginMapType is null || outboundEditorMLMessages.Length == 0) return;
	EnsureEditorHooksEstablished();
	RunPendingEditorInjections();
	auto layer = UpdateLayerWAttachIdOrMake(PluginMapType, MLHook_DataInjectionAttachId, GenManialinkPageForOutbound(outboundEditorMLMessages, "LocalUser"), false);
}

CGameUILayer@ UpdateLayerWAttachIdOrMake(CGameManiaApp@ mApp, const string &in AttachId, wstring &in ManialinkPage, bool canBeRunning = true)
{
	if (mApp is null || mApp.UILayers.Length == 0) return null;
	CGameUILayer@ layer;
	bool foundLayer = false;
	// `i < mApp.UILayers.Length` works because i is a uint
	for (uint i = mApp.UILayers.Length - 1; i < mApp.UILayers.Length; i--) {
		@layer = mApp.UILayers[i];
		foundLayer = layer.AttachId == AttachId;
		if (foundLayer && !canBeRunning && layer.IsLocalPageScriptRunning) continue;
		if (foundLayer) break;
	}
	if (!foundLayer) {
		@layer = mApp.UILayerCreate();
		layer.AttachId = AttachId;
	}
	layer.ManialinkPage = ManialinkPage;
	return layer;
}
