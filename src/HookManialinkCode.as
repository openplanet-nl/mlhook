/*

a note from menu scripts about custom events:

	> We use a json formatted string instead of the array directly because there is a limit
	> to the number of values the array can contains. The `SendCustomEvent()` function will fail
	> if there are too many entries.
	Store::SendEvent(C_StoreId, C_Event_MapRecordsUpdated, [CampaignIdList.tojson()]);
	Store::SendEvent(C_StoreId, C_Event_MapPlayerGlobalRankingsUpdated, [LeaderboardGroupUidList.tojson()]);

*/

void HookManialinkCode()
{
	Dev::InterceptProc("CGameManiaApp", "LayerCustomEvent", _LayerCustomEvent);
	Dev::InterceptProc("CGameManiaAppPlayground", "SendCustomEvent", _SendCustomEvent);
	Dev::InterceptProc("CGameManialinkScriptHandler", "SendCustomEvent", _SendCustomEventSH);
	Dev::InterceptProc("CGameEditorMainPlugin", "SendPluginEvent", _SendPluginEvent);
#if DEV
	// experimental hooks to see if we can get more events
	// Dev::InterceptProc("CGameMenuSceneScriptManager", "SceneCreate", _CheckForEvents);
	// Dev::InterceptProc("CGameManialinkPage", "GetFirstChild", _CheckForEvents);
	// Dev::InterceptProc("CGameManialinkPage", "GetClassChildren", _CheckForEvents);
	// Dev::InterceptProc("CGameManialinkFrame", "GetFirstChild", _CheckForEvents);
	// Dev::InterceptProc("CGameManialinkFrame", "HasClass", _CheckForEvents);
	// Dev::InterceptProc("CGameManialinkScriptHandler", "IsKeyPressed", _CheckForEvents);

	// these were good:
	// Dev::InterceptProc("CGameDataFileManagerScript", "Ghost_Release", _CheckForEvents);
	// Dev::InterceptProc("CGameDataFileManagerScript", "TaskResult_Release", _CheckForEvents);
	// Dev::InterceptProc("CGameDataFileManagerScript", "ReleaseTaskResult", _CheckForEvents);
	// Dev::InterceptProc("CGameDataFileManagerScript", "Map_NadeoServices_GetListFromUid", _CheckForEvents);
	// Dev::InterceptProc("CGameDataFileManagerScript", "Map_NadeoServices_Get", _CheckForEvents);
#endif
	startnew(WatchForSetup).WithRunContext(Meta::RunContext::AfterMainLoop);
	startnew(SetUpMenu).WithRunContext(Meta::RunContext::AfterMainLoop);
	startnew(WatchForEditor).WithRunContext(Meta::RunContext::AfterMainLoop);
}

void SetUpMenu()
{
	while (mcma is null) yield();
	while (mcma.UILayers.Length < 20) yield();
	sleep(50);
	while (!manialinkMenuHooksSetUp) {
		yield();
		TryManialinkMenuSetup();
	}
	if (targetMenuSH is null) {
		NotifyError("Failed to set up main menu ML hook.");
		return;
	}
	RunMenuInjectionOnSetup();
	// we can return here because the menu mania app isn't cleared
}

// Wait for cmap to be non-null and set up the hook.
// Repeat so that it is done each time
void WatchForSetup()
{
	while (true) {
		@targetSH = null;
		while (IsLoadingScreenActive) yield();
		// if (PanicMode::IsActive) WarnOnPanic;
		// yield();
		// wait for cmap to exist
		while (cmap is null) {
			yield();
		}
		dev_trace("cmap not null");
		// yield();
		dev_trace('checking first uiPopulated');
		while (!uiPopulated) {
			dev_trace('uiPopulated: false');
			yield();
		}
		dev_trace("ui populated");
		for (uint i = 0; i < 10; i++) yield();
		// wait for script hooks to be set up
		dev_trace("UI populated: about to do ML page injection");
		dev_trace("checking ml hooks set up");
		// yield();
		while (cmap !is null && !manialinkHooksSetUp) {
			yield();
			dev_trace("attempting ml setup");
			TryManialinkSetup();
		}
		if (targetSH is null) continue;  // restart if we didn't get targetSH properly
		dev_trace("ML hook set up");
		RerunInjectionsOnSetupCoro();
		dev_trace("Cached ML injections re-run");
		yield();
		// wait for cmap to not exist or for hooks to disappear
		while (cmap !is null && !IsLoadingScreenActive) {
			yield();
			// ML gets cleared on changing game mode. Sleep a bit to let things load, will then break because SH is null
			if (!manialinkHooksSetUp) {
				dev_trace('manialinkHooksSetUp is false');
				break;
			}
			if (targetSH is null) break;  // restart if we lose targetSH
		}
		dev_trace("cmap is null (or !manialinkHooksSetUp, or loading screen active)");
	}
}


void WatchForEditor()
{
	while (true) {
		yield();
		while (AppEditorIsNull) yield();
		while (editor is null) yield();
		while (PluginMapType is null) yield();
		while (!manialinkEditorHooksSetUp) {
			TryManialinkEditorSetup();
			yield();
		}
		if (targetEditorSH is null) continue;
		RunEditorInjectionOnSetup();
		// wait for editor to exit
		while (!AppEditorIsNull) yield();
		while (IsLoadingScreenActive) yield();
		@targetEditorSH = null;
	}
}


// A one-time version of the above
void EnsureHooksEstablished()
{
	while (cmap is null) yield();
	while (!uiPopulated) yield();
	while (!manialinkHooksSetUp) yield();
	while (targetSH is null) throw('targetSH == null; should never happen?');
}

void EnsureMenuHooksEstablished()
{
	while (mcma is null) yield();
	while (mcma.UILayers.Length < 20) yield();
	while (!manialinkMenuHooksSetUp) yield();
	while (targetMenuSH is null) throw('targetMenuSH == null; should never happen?');
}

void EnsureEditorHooksEstablished()
{
	while (editor is null) yield();
	while (!manialinkEditorHooksSetUp) yield();
	while (targetEditorSH is null) throw('targetEditorSH == null; should never happen?');
}

bool get_uiPopulated()
{
	dev_trace('uiPopulated: loading screen check');
	if (IsLoadingScreenActive) return false;
	dev_trace('uiPopulated: checking cmap and currPg');
	if (cmap is null) { dev_trace('false'); return false; }
	dev_trace('uiPopulated: checking currPg, app null? ' + (GetApp() is null));
	if (GetApp().CurrentPlayground is null) return false;
	// 2 by default, it seems; but if there are not more than 2 here, there will be some elsewhere (probably)
	dev_trace('uiPopulated: checking UILayers');
	if (cmap.UILayers.Length > 2) return true;
	dev_trace('uiPopulated: checking UIConfigs and UIConfigs[0].UILayers');
	if (GetApp().CurrentPlayground.UIConfigs.Length == 0) return false;
	if (GetApp().CurrentPlayground.UIConfigs[0].UILayers.Length > 0) return true;
	dev_trace('uiPopulated: checking UIConfigs and UIConfigs[0].UILayers');
	return false;
}

const string ML_Setup_AttachId = MLHook::GlobalPrefix + "AngelScript_CallBack";

bool get_manialinkHooksSetUp() {
	if (cmap is null) return false;
	bool foundCBLayer = false;
	for (uint i = cmap.UILayers.Length - 1; i < cmap.UILayers.Length; i--) {
		auto layer = cmap.UILayers[i];
		if (layer.AttachId == ML_Setup_AttachId) {
			if (targetSH is null) {
				@targetSH = cast<CSmArenaInterfaceManialinkScripHandler>(layer.LocalPage.ScriptHandler);
			}
			foundCBLayer = true;
			break;
		}
	}
	return foundCBLayer;
}

bool get_manialinkMenuHooksSetUp() {
	if (mcma is null) return false;
	bool foundCBLayer = false;
	for (uint i = 0; i < mcma.UILayers.Length; i++) {
		auto layer = mcma.UILayers[i];
		if (layer.AttachId == ML_Setup_AttachId) {
			if (targetMenuSH is null) {
				@targetMenuSH = cast<CGameManiaAppTitleLayerScriptHandler>(layer.LocalPage.ScriptHandler);
			}
			foundCBLayer = true;
			break;
		}
	}
	return foundCBLayer;
}

bool get_manialinkEditorHooksSetUp() {
	if (PluginMapType is null) return false;
	bool foundCBLayer = false;
	for (uint i = 0; i < PluginMapType.UILayers.Length; i++) {
		auto layer = PluginMapType.UILayers[i];
		if (layer.AttachId == ML_Setup_AttachId) {
			if (targetEditorSH is null) {
				@targetEditorSH = cast<CGameEditorPluginMapLayerScriptHandler>(layer.LocalPage.ScriptHandler);
			}
			foundCBLayer = true;
			break;
		}
	}
	return foundCBLayer;
}

void TryManialinkSetup() {
	if (cmap is null || manialinkHooksSetUp) return;
	auto layer = cmap.UILayerCreate();
	layer.AttachId = ML_Setup_AttachId;
	layer.ManialinkPage = """
<manialink name="MLHook_AngelScript_CallBack" version="3">
<script><!--
main() {
	while(True) {
		SendCustomEvent(""" + '"' + MLHook::PlaygroundHookEventName + '"' + """, []);
		yield;
	}
}
--></script>
</manialink>
""";
	@targetSH = cast<CSmArenaInterfaceManialinkScripHandler>(layer.LocalPage.ScriptHandler);
}

void TryManialinkMenuSetup() {
	if (mcma is null || manialinkMenuHooksSetUp) return;
	auto layer = mcma.UILayerCreate();
	layer.AttachId = ML_Setup_AttachId;
	layer.ManialinkPage = """
<manialink name="MLHook_AngelScript_CallBack" version="3">
<script><!--
main() {
	while(True) {
		SendCustomEvent(""" + '"' + MLHook::MenuHookEventName + '"' + """, []);
		yield;
	}
}
--></script>
</manialink>
""";
	@targetMenuSH = cast<CGameManiaAppTitleLayerScriptHandler>(layer.LocalPage.ScriptHandler);
}

void TryManialinkEditorSetup() {
	if (PluginMapType is null || manialinkEditorHooksSetUp) return;
	auto layer = PluginMapType.UILayerCreate();
	layer.AttachId = ML_Setup_AttachId;
	layer.ManialinkPage = """
<manialink name="MLHook_AngelScript_CallBack" version="3">
<script><!--
main() {
	while(True) {
		SendCustomEvent(""" + '"' + MLHook::EditorHookEventName + '"' + """, []);
		yield;
	}
}
--></script>
</manialink>
""";
	@targetEditorSH = cast<CGameEditorPluginMapLayerScriptHandler>(layer.LocalPage.ScriptHandler);
}

CSmArenaInterfaceManialinkScripHandler@ targetSH;
CGameManiaAppTitleLayerScriptHandler@ targetMenuSH;
CGameEditorPluginMapLayerScriptHandler@ targetEditorSH;

CustomEvent@[] SH_SCE_EventQueue = {};
CustomEvent@[] PG_SCE_EventQueue = {};
CustomEvent@[] Menu_SH_SCE_EventQueue = {};
CustomEvent@[] Editor_SH_SCE_EventQueue = {};

uint lastGameTime = 0;
uint lastMenuTime = 0;
uint lastEditorTime = 0;

funcdef void SendEventF(CustomEvent@ event);

void SendEvents_RunOnlyWhenSafe() {
	if (PanicMode::IsActive) return;
	try {
		if (cmap is null || targetSH is null || targetSH.Page is null) return;
		uint gt = targetSH.GameTime;
		if (gt != lastGameTime) {
			lastGameTime = gt;
			// print("SendEvents_RunOnlyWhenSafe - " + gt);
			_ProcessAllEventsFor(SH_SCE_EventQueue, function(CustomEvent@ event) {
				targetSH.SendCustomEvent(event.type, event.data);
			});
			_ProcessAllEventsFor(PG_SCE_EventQueue, function(CustomEvent@ event) {
				cmap.SendCustomEvent(event.type, event.data);
			});
		}
	} catch {
		PanicMode::Activate("Exception in SendEvents_RunOnlyWhenSafe: " + getExceptionInfo());
	}
}

void SendMenuEvents_RunOnlyWhenSafe() {
	if (PanicMode::IsActive) return;
	try {
		if (mcma is null || targetMenuSH is null || targetMenuSH.Page is null) return;
		uint gt = targetMenuSH.Now;
		if (gt != lastMenuTime) {
			lastMenuTime = gt;
			// print("SendEvents_RunOnlyWhenSafe - " + gt);
			_ProcessAllEventsFor(Menu_SH_SCE_EventQueue, function(CustomEvent@ event) {
				targetMenuSH.SendCustomEvent(event.type, event.data);
			});
		}
	} catch {
		PanicMode::Activate("Exception in SendMenuEvents_RunOnlyWhenSafe: " + getExceptionInfo());
	}
}

void SendEditorEvents_RunOnlyWhenSafe() {
	if (PanicMode::IsActive) return;
	try {
		if (PluginMapType is null || targetEditorSH is null || targetEditorSH.Page is null) return;
		uint gt = targetEditorSH.Now;
		if (gt != lastEditorTime) {
			lastEditorTime = gt;
			// print("SendEvents_RunOnlyWhenSafe - " + gt);
			_ProcessAllEventsFor(Editor_SH_SCE_EventQueue, function(CustomEvent@ event) {
				targetEditorSH.SendCustomEvent(event.type, event.data);
			});
		}
	} catch {
		PanicMode::Activate("Exception in SendEditorEvents_RunOnlyWhenSafe: " + getExceptionInfo());
	}
}

void _ProcessAllEventsFor(CustomEvent@[]@ eventQueue, SendEventF@ funcSendEvent) {
	noIntercept = true;
	for (uint i = 0; i < eventQueue.Length; i++) {
		// cannot do more than one at a time
		auto ce = eventQueue[i];
		dev_trace('Processing event: ' + ce.ToString());
		funcSendEvent(ce);
	}
	noIntercept = false;
	eventQueue.RemoveRange(0, eventQueue.Length);
}

// uint lastPendingCheck = 0;
uint lastShPendingLen = 0;
LastChecker targetSHChecker;
LastChecker targetMenuSHChecker;
LastChecker targetEditorSHChecker;
LastChecker cmapChecker;
LastChecker InputMgrChecker;
LastChecker mcmaChecker;
LastChecker PluginMapTypeChecker;

void CheckForPendingEvents() {
	// todo (maybe): we need to avoid checking EI::IsCapturing if we (ab)use it for routing
	// atm it's okay b/c we only care about MLHook custom events coming from ML
	if (noIntercept || !EventInspector::IsCapturing) return;
	// if (lastPendingCheck == Time::Now) {
	//     return;
	// }
	// lastPendingCheck = Time::Now;
	// CGameManialinkScriptEvent
	if (targetSH !is null && targetSH.PendingEvents.Length > 0) {
		uint peLen = targetSH.PendingEvents.Length;
		if (targetSHChecker.ShouldCheckAgain(peLen, tostring(targetSH.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < targetSH.PendingEvents.Length; i++) {
				CGameManialinkScriptEvent@ item = targetSH.PendingEvents[i];
				EventInspector::CaptureMLScriptEvent(item);
			}
		}
	} else { targetSHChecker.Reset(); }

	if (targetMenuSH !is null && targetMenuSH.PendingEvents.Length > 0) {
		uint peLen = targetMenuSH.PendingEvents.Length;
		if (targetMenuSHChecker.ShouldCheckAgain(peLen, tostring(targetMenuSH.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < targetMenuSH.PendingEvents.Length; i++) {
				CGameManialinkScriptEvent@ item = targetMenuSH.PendingEvents[i];
				EventInspector::CaptureMLScriptEvent(item);
			}
		}
	} else { targetMenuSHChecker.Reset(); }

	if (targetEditorSH !is null && targetEditorSH.PendingEvents.Length > 0) {
		uint peLen = targetEditorSH.PendingEvents.Length;
		if (targetEditorSHChecker.ShouldCheckAgain(peLen, tostring(targetEditorSH.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < targetEditorSH.PendingEvents.Length; i++) {
				CGameManialinkScriptEvent@ item = targetEditorSH.PendingEvents[i];
				EventInspector::CaptureMLScriptEvent(item);
			}
		}
	} else { targetEditorSHChecker.Reset(); }

	// todo: CGameManiaAppScriptEvent excluding CGameManiaAppPlaygroundScriptEvent
	// CGameManiaAppPlaygroundScriptEvent
	if (cmap !is null && cmap.PendingEvents.Length > 0) {
		uint peLen = cmap.PendingEvents.Length;
		if (cmapChecker.ShouldCheckAgain(peLen, tostring(cmap.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < cmap.PendingEvents.Length; i++) {
				CGameManiaAppPlaygroundScriptEvent@ item = cmap.PendingEvents[i];
				EventInspector::CaptureMAPGScriptEvent(item); // crashes on accessing null fields
			}
		}
	} else { cmapChecker.Reset(); }

	// CGameScriptChatEvent -- chat managers seem always null
	// CInputScriptEvent
	if (InputMgr !is null && InputMgr.PendingEvents.Length > 0) {
		uint peLen = InputMgr.PendingEvents.Length;
		if (InputMgrChecker.ShouldCheckAgain(peLen, tostring(InputMgr.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < InputMgr.PendingEvents.Length; i++) {
				CInputScriptEvent@ item = InputMgr.PendingEvents[i];
				EventInspector::CaptureInputScriptEvent(item);
			}
		}
	} else { InputMgrChecker.Reset(); }

	// CGameManiaAppTitle / CGameManiaAppScriptEvent -- works!
	if (mcma !is null && mcma.PendingEvents.Length > 0) {
		uint peLen = mcma.PendingEvents.Length;
		if (mcmaChecker.ShouldCheckAgain(peLen, tostring(mcma.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < mcma.PendingEvents.Length; i++) {
				CGameManiaAppScriptEvent@ item = mcma.PendingEvents[i];
				EventInspector::CaptureMAScriptEvent(item); // crashes on accessing null fields
			}
		}
	} else { mcmaChecker.Reset(); }

	if (PluginMapType !is null && PluginMapType.PendingEvents.Length > 0) {
		uint peLen = PluginMapType.PendingEvents.Length;
		if (PluginMapTypeChecker.ShouldCheckAgain(peLen, tostring(PluginMapType.PendingEvents[peLen - 1].Type))) {
			for (uint i = 0; i < PluginMapType.PendingEvents.Length; i++) {
				CGameEditorPluginMapScriptEvent@ item = PluginMapType.PendingEvents[i];
				EventInspector::CapturePMScriptEvent(item);
			}
		}
	} else { PluginMapTypeChecker.Reset(); }

	// warn("CheckForPendingEvents too: " + (Time::Now - lastPendingCheck));
}

// string lastLayerType = "";

bool _LayerCustomEvent(CMwStack &in stack, CMwNod@ nod) {
	if (PanicMode::IsActive) return true;
	try {
		// CheckForPendingEvents();
		if (EventInspector::g_capturing || HookRouter::shouldRouteLayerEvents) {
			wstring type = stack.CurrentWString(1);
			auto data = stack.CurrentBufferWString();
			if (EventInspector::g_capturing) {
				auto layer = cast<CGameUILayer>(stack.CurrentNod(2));
				EventInspector::CaptureEvent(type, data, EventSource::LayerCE, (noIntercept ? "AS" : ""), layer);
			}
			if (HookRouter::shouldRouteLayerEvents && !string(type).EndsWith("_PreloadImages")) {
				HookRouter::OnEvent(MLHook::PendingEvent(type, data));
			}
		}
		return true;
	} catch {
		PanicMode::Activate("Exception in _LayerCustomEvent: " + getExceptionInfo());
		return true;
	}
}

// playground custom events; note, entrypoint for AS hook is _SendCustomEventSH
bool _SendCustomEvent(CMwStack &in stack, CMwNod@ nod) {
	if (PanicMode::IsActive) return true;
	try {
		CheckForPendingEvents();
		if (EventInspector::g_capturing || HookRouter::shouldRoutePlaygroundEvents) {
			wstring type = stack.CurrentWString(1);
			auto data = stack.CurrentBufferWString();
			if (EventInspector::g_capturing) {
				EventInspector::CaptureEvent(type, data, EventSource::PG_SendCE, (noIntercept ? "AS" : ""));
			}
			if (HookRouter::shouldRoutePlaygroundEvents) {
				HookRouter::OnEvent(MLHook::PendingEvent(type, data));
			}
		}
		// if (!EventInspector::g_capturing) return true;
		// wstring type = stack.CurrentWString(1);
		// auto data = stack.CurrentBufferWString();
		// EventInspector::CaptureEvent(type, data, EventSource::PG_SendCE, (noIntercept ? "AS" : ""));
		return true;
	} catch {
		PanicMode::Activate("Exception in _SendCustomEvent: " + getExceptionInfo());
		return true;
	}
}

bool _SendPluginEvent(CMwStack &in stack, CMwNod@ nod) {
	if (PanicMode::IsActive) return true;
	try {
		CheckForPendingEvents();
		if (!EventInspector::g_capturing) return true;
		wstring type = stack.CurrentWString(1);
		auto data = stack.CurrentBufferWString();
		CGameEditorPluginHandle@ handle = cast<CGameEditorPluginHandle>(stack.CurrentNod(2));
		EventInspector::CaptureEvent(type, data, EventSource::PluginCE, (noIntercept ? "AS" : ""), null, handle);
		return true;
	} catch {
		PanicMode::Activate("Exception in _SendPluginEvent: " + getExceptionInfo());
		return true;
	}
}

int countShNods = 0;

CSmArenaInterfaceManialinkScripHandler@ lastNod;
CGameManialinkPage@ thePage;

bool noIntercept = false;

// right now, this is the only entrypoint for ML->AS events -- might need to be generalized later
// that entrypoint is via HookRouter::OnEvent
bool _SendCustomEventSH(CMwStack &in stack, CMwNod@ nod) {
	if (PanicMode::IsActive) return true;
	try {
		CheckForPendingEvents();
		string s_type = string(stack.CurrentWString(1));
		bool is_mlhook_event = s_type.StartsWith(MLHook::GlobalPrefix);

		/* putting the hook router call here will route all events */
		if (EventInspector::IsCapturing) {
			EventInspector::CaptureEvent(s_type, stack.CurrentBufferWString(), EventSource::SH_SendCE, (noIntercept ? "AS" : ""));
		}

		// custom events are from maniascript, so we always want to intercept them and let everything else through.
		// if noIntercept is set, then we don't want to bother checking it b/c it came via MLHook anyway.
		if (noIntercept) return true;
		// return here only if it's not an MLhook event AND we don't want to capture SH events
		if (!is_mlhook_event && !HookRouter::ShouldRouteExtraEvents()) return true;

		auto data = stack.CurrentBufferWString();
		HookRouter::OnEvent(MLHook::PendingEvent(s_type, data));

		// return early for non-mlhook events as optimization
		if (!is_mlhook_event) {
			return true; // game events -> true, mlhook events -> false
		}

		bool isPgTrigger = s_type == MLHook::PlaygroundHookEventName;
		bool isMenuTrigger = !isPgTrigger && s_type == MLHook::MenuHookEventName;
		bool isEditorTrigger = !isPgTrigger && !isMenuTrigger && s_type == MLHook::EditorHookEventName;

		if (isPgTrigger && targetSH !is null && targetSH.Page !is null) {
			SendEvents_RunOnlyWhenSafe();
		} else if (isMenuTrigger && targetMenuSH !is null && targetMenuSH.Page !is null) {
			SendMenuEvents_RunOnlyWhenSafe();
		} else if (isEditorTrigger && targetEditorSH !is null && targetEditorSH.Page !is null) {
			SendEditorEvents_RunOnlyWhenSafe();
		}
		if (s_type.StartsWith(MLHook::LogMePrefix)) {
			ml_log("[" + s_type.SubStr(MLHook::LogMePrefix.Length) + " via MLHook] " + FastBufferWStringToString(data));
		}

		if (isPgTrigger || isMenuTrigger || isEditorTrigger) {
			// triggers callbacks for running during ML execution
			MLHook::_ML_Hook_Feed.OnEvent(MLHook::PendingEvent(s_type, data));
		}

		// ! this doesn't work. probably need to wait for Miss's ML exec stuff
		// // we only route pending events during the trigger event, so is_mlhook_event is always true at this time.
		// if (isPgTrigger && HookRouter::shouldRoutePgPendingEvents) {
		// 	// also check for playground PendingEvents
		// 	CheckAndRoutePgPendingEvents();
		// }

		return false;
	} catch {
		PanicMode::Activate("Exception in _SendCustomEventSH: " + getExceptionInfo());
		return true;
	}
}

// void CheckAndRoutePgPendingEvents() {
// 	if (cmap is null) return;
// 	// CGameManiaAppPlaygroundScriptEvent
// 	// trace('cmap.PendingEvents: ' + cmap.PendingEvents.Length);
// 	for (uint i = 0; i < cmap.PendingEvents.Length; i++) {
// 		CGameManiaAppPlaygroundScriptEvent@ item = cmap.PendingEvents[i];
// 		HookRouter::RoutePlaygroundScriptEvent(item);
// 	}
// }
