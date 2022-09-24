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
    startnew(WatchForSetup);
}

// Wait for cmap to be non-null and set up the hook.
// Repeat so that it is done each time
void WatchForSetup() {
    while (true) {
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
        yield();
        // wait for cmap to not exist
        while (cmap !is null) {
            yield();
            if (targetSH is null) continue;  // restart if we lose targetSH
        }
        dev_trace("cmap is null");
    }
}

bool get_uiPopulated() {
    if (cmap is null) return false;
    if (cmap.UILayers.Length < 10) return false;
    return true;
}

const string _attachId = "AngelScript_CallBack";

bool get_manialinkHooksSetUp() {
    bool foundCBLayer = false;
    auto layers = cmap.UILayers;
    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
        if (layer.AttachId == _attachId) {
            if (targetSH is null) {
                @targetSH = cast<CSmArenaInterfaceManialinkScripHandler>(layer.LocalPage.ScriptHandler);
            }
            foundCBLayer = true;
            break;
        }
    }
    return foundCBLayer;
}

const string HookEventName = "AngelScript_Hook";

void TryManialinkSetup() {
    if (manialinkHooksSetUp) return;
    auto layer = cmap.UILayerCreate();
    layer.AttachId = _attachId;
    layer.ManialinkPage = """
<script><!--
main() {
    while(True) {
        SendCustomEvent("AngelScript_Hook", []);
        yield;
    }
}
--></script>""";
    @targetSH = cast<CSmArenaInterfaceManialinkScripHandler>(layer.LocalPage.ScriptHandler);
}

CSmArenaInterfaceManialinkScripHandler@ targetSH;

void RunGhostTest() {
    if (targetSH is null) {
        UI::ShowNotification("toggle ghost", "targetSH is null == true");
        return;
    }
    // ExploreNod(lastNod);
    // ExploreNod(thePage);
    // @targetSH.Page = thePage; // no set-accessor :(
    // warn(thePage.ScriptHandler);
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"da4642f9-6acf-43fe-88b6-b120ff1308ba"}));
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"8d90f6c6-5a03-4fd3-8026-791c4d7404db"}));
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"41122fb7-f264-448e-9660-a418f438e58b"}));
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"1336b019-0d7d-43f7-b227-ff336f8b7140"}));
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"2a13aa7d-992d-4a7c-a3c5-d29b08b7f8cb"}));
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"7ccc9d81-bc43-4faa-b454-46bed6b6d4f5"}));
    SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"aca96daf-0fda-4496-9887-22e616d8a481"}));
}

CustomEvent@[] SH_SCE_EventQueue = {};
CustomEvent@[] SCE_EventQueue = {};

uint lastGameTime = 0;

funcdef void SendEventF(CustomEvent@ event);

void SendEvents_RunOnlyWhenSafe() {
    CheckForPendingEvents();
    if (targetSH is null || targetSH.Page is null) return;
    uint gt = targetSH.GameTime;
    if (gt > lastGameTime) {
        lastGameTime = gt;
        // CheckForPendingEvents();
        // print("SendEvents_RunOnlyWhenSafe - " + gt);
        _ProcessAllEventsFor(SH_SCE_EventQueue, function(CustomEvent@ event) {
            targetSH.SendCustomEvent(event.type, event.data);
        });
        _ProcessAllEventsFor(SCE_EventQueue, function(CustomEvent@ event) {
            cmap.SendCustomEvent(event.type, event.data);
        });
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

void CheckForPendingEvents() {
    // CGameManialinkScriptEvent
    if (targetSH.PendingEvents.Length > 0) {
        dev_trace("targetSH.PendingEvents.Length: " + targetSH.PendingEvents.Length);
        for (uint i = 0; i < targetSH.PendingEvents.Length; i++) {
            CGameManialinkScriptEvent@ item = targetSH.PendingEvents[i];
            EventInspector::CaptureMlScriptEvent(item);
        }
    }
    // todo: CGameManiaAppScriptEvent excluding CGameManiaAppPlaygroundScriptEvent
    // CGameManiaAppPlaygroundScriptEvent
    if (cmap.PendingEvents.Length > 0) {
        dev_trace("cmap.PendingEvents.Length: " + cmap.PendingEvents.Length);
        for (uint i = 0; i < cmap.PendingEvents.Length; i++) {
            CGameManiaAppPlaygroundScriptEvent@ item = cmap.PendingEvents[i];
            EventInspector::CaptureMAPGScriptEvent(item);
        }
    }
    // CGameScriptChatEvent -- chat managers seem always null
    // CInputScriptEvent
    if (InputMgr.PendingEvents.Length > 0) {
        dev_trace("InputMgr.PendingEvents.Length: " + InputMgr.PendingEvents.Length);
        for (uint i = 0; i < InputMgr.PendingEvents.Length; i++) {
            CInputScriptEvent@ item = InputMgr.PendingEvents[i];
            EventInspector::CaptureInputScriptEvent(item);
        }
    }
}

bool _LayerCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    if (!EventInspector::g_capturing) return true;
    auto layer = cast<CGameUILayer>(stack.CurrentNod(2));
    wstring type = stack.CurrentWString(1);
    auto data = stack.CurrentBufferWString();
    EventInspector::CaptureEvent(type, data, EventSource::LayerCE, (noIntercept ? "AS" : ""), layer);
    return true;
    // print("LayerCustomEvent on nod: " + nod.IdName + " of type: " + type);
    // for (uint i = 0; i < data.Length; i++) {
    //     auto item = data[i];
    //     print(item);
    // }
    // return true;
}

bool _SendCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    if (!EventInspector::g_capturing) return true;
    wstring type = stack.CurrentWString(1);
    auto data = stack.CurrentBufferWString();
    EventInspector::CaptureEvent(type, data, EventSource::PG_SendCE, (noIntercept ? "AS" : ""));
    return true;
}

int countShNods = 0;

CSmArenaInterfaceManialinkScripHandler@ lastNod;
CGameManialinkPage@ thePage;

bool noIntercept = false;

bool _SendCustomEventSH(CMwStack &in stack, CMwNod@ nod) {
    wstring type = stack.CurrentWString(1);
    string s_type = string(type);
    auto data = stack.CurrentBufferWString();
    EventInspector::CaptureEvent(type, data, EventSource::SH_SendCE, (noIntercept ? "AS" : ""));
    bool is_debug = s_type.StartsWith(MLHook::DebugPrefix);
    if (noIntercept && !is_debug) return true;
    if (targetSH !is null && targetSH.Page !is null)
        SendEvents_RunOnlyWhenSafe();
    if (is_debug) return false;
    if (s_type == HookEventName) {return false;}
    return true;
}


// bool logWhenCalled(CMwStack &in stack, CMwNod@ nod) {
//     if (noIntercept) return true;
//     if (targetSH is null || targetSH.Page is null) return true;
//     SendEvents_RunOnlyWhenSafe();
//     return true;
// }
