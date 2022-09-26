/*
Pending Events:
===============

CGameManialinkScriptHandler const MwFastBuffer<CGameManialinkScriptEvent@> PendingEvents
done: CaptureMlScriptEvent

CGameServerPlugin const MwFastBuffer<CGameServerPluginEvent@> PendingEvents

CGamePlaygroundUIConfigMgrScript const MwFastBuffer<CGamePlaygroundUIConfigEvent@> PendingEvents

CGameEditorPluginMap const MwFastBuffer<CGameEditorPluginMapScriptEvent@> PendingEvents

CGameServerScriptXmlRpc const MwFastBuffer<CGameServerScriptXmlRpcEvent@> PendingEvents

CGameScriptChatManager const MwFastBuffer<CGameScriptChatEvent@> PendingEvents
done: class not used?

CGameManiaplanetPlugin const MwFastBuffer<CGameManiaAppScriptEvent@> PendingEvents
done: CaptureMAScriptEvent

CGameManiaplanetPluginInterface const MwFastBuffer<CGameManiaplanetPluginInterfaceEvent@> PendingEvents

CGameManiaAppPlaygroundCommon const MwFastBuffer<CGameManiaAppPlaygroundScriptEvent@> PendingEvents
done:CaptureMAPGScriptEvent

CGameManiaAppTitle const MwFastBuffer<CGameManiaAppScriptEvent@> PendingEvents
done: CaptureMAScriptEvent

CGameManiaAppBrowser const MwFastBuffer<CGameManiaAppScriptEvent@> PendingEvents
done: CaptureMAScriptEvent

CGameManiaAppMinimal const MwFastBuffer<CGameManiaAppScriptEvent@> PendingEvents
done: CaptureMAScriptEvent

CGameEditorModule const MwFastBuffer<CGameEditorPluginModuleScriptEvent@> PendingEvents

CGameEditorPlugin const MwFastBuffer<CGameManiaAppScriptEvent@> PendingEvents
CGameManiaAppScriptEvent

CGameEditorEditor const MwFastBuffer<CGameEditorEvent@> PendingEvents

CGameDialogsScript const MwFastBuffer<CGameDialogsScriptEvent@> PendingEvents

CGameEditorMesh const MwFastBuffer<CGameEditorEvent@> PendingEvents

CGameEditorSkinPluginAPI MwSArray<CGameEditorEvent@> PendingEvents

CGameEditorMediaTrackerPluginAPI const MwFastBuffer<CGameEditorEvent@> PendingEvents

CNetScriptHttpManager const MwNodPool<CNetScriptHttpEvent@> PendingEvents

CInputScriptManager const MwFastBuffer<CInputScriptEvent@> PendingEvents
done: CaptureInputScriptEvent

CSmActionInstance const MwFastBuffer<CSmActionInstanceEvent@> PendingEvents

CSmArenaRulesMode const MwFastBuffer<CSmArenaRulesEvent@> PendingEvents

* CGameManialinkNavigationScriptHandler MwFastBuffer<CEventMenuNavigation@> PendingEvents
done? seems not to be used

*/

namespace EventInspector {
    void CaptureEvent(wstring &in type, MwFastBuffer<wstring> &in data, EventSource &in source, const string &in annotation = "", CGameUILayer@ layer = null, CGameEditorPluginHandle@ handle = null) {
        if (!ShouldCapture) return;
        auto event = CustomEvent(type, data, source, annotation, layer, handle);
        _RecordCaptured(event);
    }

    void CaptureMlScriptEvent(CGameManialinkScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {tostring(event.KeyCode), event.KeyName, event.CharPressed, event.ControlId, tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f', event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.PluginCustomEventType, FastBufferWStringToString(event.PluginCustomEventData)};
        auto ce = CustomEvent("CGameManialinkScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::ML_SE);
        _RecordCaptured(ce);
    }

    // // todo: does this work?
    // void CaptureServerPluginEvent(CGameServerPluginEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }

    // void CapturePGUIConfigEvent(CGamePlaygroundUIConfigEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }

    // void Capture _ Event(CGameEditorPluginMapScriptEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CGameServerScriptXmlRpcEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CGameScriptChatEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CGameManiaplanetPluginInterfaceEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CGameEditorPluginModuleScriptEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CGameEditorEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CGameDialogsScriptEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CNetScriptHttpEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CSmActionInstanceEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }
    // void Capture _ Event(CSmArenaRulesEvent@ event) {
    //     if (!ShouldCapture) return;
    //     // todo
    // }

    // todo: should actually capture some stuff but doesn't
    void CaptureMAScriptEvent(CGameManiaAppScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {tostring(event.KeyCode), event.KeyName, event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.ExternalEventType, FastBufferWStringToString(event.ExternalEventData), "EMenuNavAction::" + tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f'};
        auto ce = CustomEvent("CGameManiaAppScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::MA_SE, "", event.CustomEventLayer);
        _RecordCaptured(ce);
    }

    // todo: doesn't seem to capture anything... maybe wrong point in maniascript execution flow
    void CaptureMAPGScriptEvent(CGameManiaAppPlaygroundScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {event.PlaygroundScriptEventType, FastBufferWStringToString(event.PlaygroundScriptEventData),
            (event.Ghost is null) ? "Ghost(null)" : ("Ghost(id=" + event.Ghost.Id.Value + ", Nickname=\"" + event.Ghost.Nickname + "\", ...(todo)...)"),
            "GameplaySpecialType::" + tostring(event.GameplaySpecialType),
            "GameplayTurboRoulette::" + tostring(event.GameplayTurboRoulette),
            "RaceWaypointTime=" + event.RaceWaypointTime,
            "DiffWithBestRace=" + event.DiffWithBestRace,
            "RaceWaypointCount=" + event.RaceWaypointCount,
            "RaceWaypointIndex=" + event.RaceWaypointIndex,
            tostring(event.KeyCode), event.KeyName, event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.ExternalEventType, FastBufferWStringToString(event.ExternalEventData), "EMenuNavAction::" + tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f'};
        auto ce = CustomEvent("PlaygroundType::" + tostring(event.PlaygroundType), ArrStringToFastBufferWString(data), EventSource::MAPG_SE, "", event.CustomEventLayer);
        _RecordCaptured(ce);
    }

    // todo: doesn't seem to capture much... maybe wrong point in maniascript execution flow
    void CaptureInputScriptEvent(CInputScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {"EButton::" + tostring(event.Button),
            tostring(event.KeyCode), event.KeyName, event.IsAutoRepeat ? 't' : 'f'};
        auto ce = CustomEvent("CInputScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::InputSE, "");
        _RecordCaptured(ce);
    }
}
