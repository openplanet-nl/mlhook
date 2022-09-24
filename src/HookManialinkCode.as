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

CGameManiaAppPlayground@ get_cmap() {
    return GetApp().Network.ClientManiaAppPlayground;
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
}

CustomEvent@[] SH_SCE_EventQueue = {};

uint lastGameTime = 0;
bool logWhenCalled(CMwStack &in stack, CMwNod@ nod) {
    if (noIntercept) return true;
    if (targetSH is null || targetSH.Page is null) return true;
    SendEvents_RunOnlyWhenSafe();
    return true;
}

void SendEvents_RunOnlyWhenSafe() {
    if (targetSH is null || targetSH.Page is null) return;
    uint gt = targetSH.GameTime;
    if (gt > lastGameTime) {
        lastGameTime = gt;
        if (targetSH.PendingEvents.Length > 0)
            dev_trace("SH.PendingEvents.Length: " + targetSH.PendingEvents.Length);
        // print("SendEvents_RunOnlyWhenSafe - " + gt);
        while (SH_SCE_EventQueue.Length > 0) {
            // cannot do more than one at a time
            auto ce = SH_SCE_EventQueue[SH_SCE_EventQueue.Length - 1];
            SH_SCE_EventQueue.RemoveLast();
            trace('Processing event: ' + ce.ToString());
            noIntercept = true;
            targetSH.SendCustomEvent(ce.type, ce.data);
            noIntercept = false;
        }
    }
}

bool _LayerCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    if (!EventInspector::g_capturing) return true;
    auto layer = cast<CGameUILayer>(stack.CurrentNod(2));
    wstring type = stack.CurrentWString(1);
    auto data = stack.CurrentBufferWString();
    EventInspector::CaptureEvent(type, data, "LayerCE", layer);
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
    EventInspector::CaptureEvent(type, data, "PG.SendCE");
    return true;
}

int countShNods = 0;

CSmArenaInterfaceManialinkScripHandler@ lastNod;
CGameManialinkPage@ thePage;

bool noIntercept = false;

bool _SendCustomEventSH(CMwStack &in stack, CMwNod@ nod) {
    wstring type = stack.CurrentWString(1);
    auto data = stack.CurrentBufferWString();
    EventInspector::CaptureEvent(type, data, (noIntercept ? "[AS] " : "") + "SH.SendCE");
    if (noIntercept) return true;
    if (string(type) != HookEventName) {return true;}
    if (targetSH !is null && targetSH.Page !is null)
        SendEvents_RunOnlyWhenSafe();
    return false;
    // if (false) {
    //     auto data = stack.CurrentBufferWString();
    //     if (nod.IdName.Length <= 0) {
    //         nod.IdName = "SH-" + (++countShNods);
    //     }
    //     print("ScriptHandler.SendCustomEvent on nod: " + nod.IdName + " of type: " + type);
    //     print("Same as last nod? " + (@nod == @lastNod ? "yes" : "no"));
    //     print("Same as target script handler? " + (@nod == @targetSH ? "yes" : "no"));
    //     if (true || string(type) == "TMxSM_Race_Record_ToggleGhost") {
    //         print("Is nod CSmArenaInterfaceManialinkScripHandler?");
    //         print(cast<CSmArenaInterfaceManialinkScripHandler>(nod) is null ? "no" : "yes");
    //         if (cast<CSmArenaInterfaceManialinkScripHandler>(nod) !is null) {
    //             // if (updateLastNod) {
    //                 @lastNod = cast<CSmArenaInterfaceManialinkScripHandler>(nod);
    //                 if (@nod == @targetSH && lastNod.Page !is null) {
    //                     @thePage = lastNod.Page;
    //                 }
    //             // }
    //             print(".Page is null? " + (lastNod.Page is null ? "yes" : "no"));
    //             print(".PageIsVisible? " + (lastNod.PageIsVisible ? "yes" : "no"));
    //             print(".PageAlwaysUpdateScript? " + (lastNod.PageAlwaysUpdateScript ? "yes" : "no"));
    //         }
    //         print("Is nod CGameScriptHandlerPlaygroundInterface?");
    //         print(cast<CGameScriptHandlerPlaygroundInterface>(nod) is null ? "no" : "yes");
    //         print("Is nod CGameManialinkScriptHandler?");
    //         print(cast<CGameManialinkScriptHandler>(nod) is null ? "no" : "yes");
    //     }
    //     for (uint i = 0; i < data.Length; i++) {
    //         auto item = data[i];
    //         print(item);
    //     }
    // }
    // return false;
}
