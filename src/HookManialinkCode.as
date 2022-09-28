/*

a note from menu scripts about custom events:

	> We use a json formatted string instead of the array directly because there is a limit
	> to the number of values the array can contains. The `SendCustomEvent()` function will fail
	> if there are too many entries.
	Store::SendEvent(C_StoreId, C_Event_MapRecordsUpdated, [CampaignIdList.tojson()]);
	Store::SendEvent(C_StoreId, C_Event_MapPlayerGlobalRankingsUpdated, [LeaderboardGroupUidList.tojson()]);

*/

void HookManialinkCode() {
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
    startnew(WatchForSetup);
}

// Wait for cmap to be non-null and set up the hook.
// Repeat so that it is done each time
void WatchForSetup() {
    while (true) {
        // if (PanicMode::IsActive) WarnOnPanic;
        yield();
        // wait for cmap to exist
        while (cmap is null) {
            yield();
        }
        dev_trace("cmap not null");
        yield();
        while (!uiPopulated) {
            yield();
        }
        // wait for script hooks to be set up
        while (!manialinkHooksSetUp) {
            yield();
            TryManialinkSetup();
        }
        if (targetSH is null) continue;  // restart if we didn't get targetSH properly
        dev_trace("ML hook set up");
        RerunInjectionsOnSetupCoro();
        dev_trace("Cached ML injections re-run");
        yield();
        // wait for cmap to not exist
        while (cmap !is null) {
            yield();
            if (targetSH is null) continue;  // restart if we lose targetSH
        }
        dev_trace("cmap is null");
    }
}

// A one-time version of the above
void EnsureHooksEstablished() {
    while (cmap is null) yield();
    while (!uiPopulated) yield();
    while (!manialinkHooksSetUp) yield();
    while (targetSH is null) throw('should never happen?');
}

bool get_uiPopulated() {
    if (cmap is null) return false;
    if (cmap.UILayers.Length < 10) return false;
    return true;
}

const string ML_Setup_AttachId = MLHook::GlobalPrefix + "AngelScript_CallBack";

bool get_manialinkHooksSetUp() {
    if (cmap is null) return false;
    bool foundCBLayer = false;
    auto layers = cmap.UILayers;
    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
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

void TryManialinkSetup() {
    if (manialinkHooksSetUp) return;
    auto layer = cmap.UILayerCreate();
    layer.AttachId = ML_Setup_AttachId;
    layer.ManialinkPage = """

<script><!--
main() {
    while(True) {
        SendCustomEvent(""" + '"' + MLHook::PlaygroundHookEventName + '"' + """, []);
        yield;
    }
}
--></script>""";
    @targetSH = cast<CSmArenaInterfaceManialinkScripHandler>(layer.LocalPage.ScriptHandler);
}

CSmArenaInterfaceManialinkScripHandler@ targetSH;

CustomEvent@[] SH_SCE_EventQueue = {};
CustomEvent@[] PG_SCE_EventQueue = {};

uint lastGameTime = 0;

funcdef void SendEventF(CustomEvent@ event);

void SendEvents_RunOnlyWhenSafe() {
    if (PanicMode::IsActive) return;
    try {
        if (targetSH is null || targetSH.Page is null) return;
        uint gt = targetSH.GameTime;
        if (gt > lastGameTime) {
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

void _ProcessAllEventsFor(CustomEvent@[]@ &in eventQueue, SendEventF@ funcSendEvent) {
    while (eventQueue.Length > 0) {
        // cannot do more than one at a time
        auto ce = eventQueue[eventQueue.Length - 1];
        eventQueue.RemoveLast();
        dev_trace('Processing event: ' + ce.ToString());
        noIntercept = true;
        funcSendEvent(ce);
        noIntercept = false;
    }
}

// uint lastPendingCheck = 0;
uint lastShPendingLen = 0;
LastChecker targetSHChecker;
LastChecker cmapChecker;
LastChecker InputMgrChecker;
LastChecker mcmaChecker;

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
    // todo: CGameManiaAppScriptEvent excluding CGameManiaAppPlaygroundScriptEvent
    // CGameManiaAppPlaygroundScriptEvent
    if (cmap !is null && cmap.PendingEvents.Length > 0) {
        uint peLen = cmap.PendingEvents.Length;
        if (cmapChecker.ShouldCheckAgain(peLen, tostring(cmap.PendingEvents[peLen - 1].Type))) {
            for (uint i = 0; i < cmap.PendingEvents.Length; i++) {
                CGameManiaAppPlaygroundScriptEvent@ item = cmap.PendingEvents[i];
                EventInspector::CaptureMAPGScriptEvent(item);
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
                EventInspector::CaptureMAScriptEvent(item);
            }
        }
    } else { mcmaChecker.Reset(); }
    // warn("CheckForPendingEvents too: " + (Time::Now - lastPendingCheck));
}

// string lastLayerType = "";

bool _LayerCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    if (PanicMode::IsActive) return true;
    try {
        CheckForPendingEvents();
        if (!EventInspector::g_capturing) return true;
        auto layer = cast<CGameUILayer>(stack.CurrentNod(2));
        wstring type = stack.CurrentWString(1);
        auto data = stack.CurrentBufferWString();
        EventInspector::CaptureEvent(type, data, EventSource::LayerCE, (noIntercept ? "AS" : ""), layer);
        return true;
    } catch {
        PanicMode::Activate("Exception in _LayerCustomEvent: " + getExceptionInfo());
        return true;
    }
}

bool _SendCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    if (PanicMode::IsActive) return true;
    try {
        CheckForPendingEvents();
        if (!EventInspector::g_capturing) return true;
        wstring type = stack.CurrentWString(1);
        auto data = stack.CurrentBufferWString();
        EventInspector::CaptureEvent(type, data, EventSource::PG_SendCE, (noIntercept ? "AS" : ""));
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

bool _SendCustomEventSH(CMwStack &in stack, CMwNod@ nod) {
    if (PanicMode::IsActive) return true;
    try {
        CheckForPendingEvents();
        wstring type = stack.CurrentWString(1);
        string s_type = string(type);
        bool is_mlhook_event = s_type.StartsWith(MLHook::GlobalPrefix);
        auto data = stack.CurrentBufferWString();
        // right now, this is the only entrypoint for ML->AS events -- might need to be generalized later
        HookRouter::OnEvent(s_type, data);
        EventInspector::CaptureEvent(type, data, EventSource::SH_SendCE, (noIntercept ? "AS" : ""));
        // custom events are from maniascript, so we always want to intercept them and let everything else through.
        // if noIntercept is set, then we don't want to bother checking it b/c it came via MLHook anyway.
        if (noIntercept) return true;
        if (!is_mlhook_event) return true;
        if (s_type == MLHook::PlaygroundHookEventName && targetSH !is null && targetSH.Page !is null)
            SendEvents_RunOnlyWhenSafe();
        if (s_type.StartsWith(MLHook::LogMePrefix)) {
            print("[" + s_type.SubStr(MLHook::LogMePrefix.Length) + " via MLHook] " + FastBufferWStringToString(data));
        }
        return false;
    } catch {
        PanicMode::Activate("Exception in _SendCustomEventSH: " + getExceptionInfo());
        return true;
    }
}

// bool logWhenCalled(CMwStack &in stack, CMwNod@ nod) {
//     if (noIntercept) return true;
//     if (targetSH is null || targetSH.Page is null) return true;
//     SendEvents_RunOnlyWhenSafe();
//     return true;
// }
