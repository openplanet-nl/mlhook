// none of these tests worked, but printing the events is useful
//  for getting info out of maniascript

void ToggleGhostTest() {
    Dev::InterceptProc("CGameManiaApp", "LayerCustomEvent", _LayerCustomEvent);
    Dev::InterceptProc("CGameManiaAppPlayground", "SendCustomEvent", _SendCustomEvent);
    Dev::InterceptProc("CGameManialinkScriptHandler", "SendCustomEvent", _SendCustomEventSH);
    // Dev::InterceptProc("CGameGhostMgrScript", "Ghost_SetDossard", _Ghost_Add);
    Dev::InterceptProc("CGameManialinkFrame", "GetFirstChild", logWhenCalled);
    Dev::InterceptProc("CGameManialinkPage", "GetFirstChild", logWhenCalled);
    Dev::InterceptProc("CGameManialinkFrame", "Scroll", logWhenCalled);
    Dev::InterceptProc("CGameManialinkFrame", "HasClass", logWhenCalled);
    Dev::InterceptProc("CGameManialinkFrame", "DataAttributeExists", logWhenCalled);
    Dev::InterceptProc("CGameManialinkFrame", "DataAttributeGet", logWhenCalled);
    Dev::InterceptProc("CGameManialinkFrame", "DataAttributeSet", logWhenCalled);
    Dev::InterceptProc("CGameManialinkPage", "GetClassChildren", logWhenCalled);
    Dev::InterceptProc("CGameManialinkPage", "ScrollToControl", logWhenCalled);
    Dev::InterceptProc("CGamePlaygroundUIConfig", "GetLayerManialinkAction", logWhenCalled);
    // Dev::InterceptProc("CControlFrame", "SetLocation", logWhenCalled);
    // virtual:
    // Dev::InterceptProc("CControlFrame", "SetLocation", logWhenCalled);
    startnew(SetUpGhostTest);
}

class CustomEvent {
    wstring type;
    MwFastBuffer<wstring> data;

    CustomEvent(const string &in type, string[] &in data = {}) {
        this.type = wstring(type);
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            this.data.Add(wstring(item));
        }
    }
}

void Render() {
    if (UI::Begin("ghost test button")) {
        if (UI::Button("run ghost test")) {
            RunGhostTest();
        }
        if (UI::Button("run ghost test async")) {
            startnew(RunGhostTest);
        }
        if (UI::Button("change opponents")) {
            eventQueue.InsertLast(CustomEvent("RaceMenuEvent_ChangeOpponents"));
        }
    }
    UI::End();
}

CSmArenaInterfaceManialinkScripHandler@ targetSH;

void SetUpGhostTest() {
    auto network = GetApp().Network;
    auto cmap = GetApp().Network.ClientManiaAppPlayground;
    if (cmap is null) return;
    auto layers = GetApp().Network.ClientManiaAppPlayground.UILayers;
    CGameUILayer@ rr;
    for (uint i = 0; i < layers.Length; i++) {
        auto layer = layers[i];
        if (layer.IsVisible && layer.ManialinkPageUtf8.StartsWith("\n<manialink name=\"UIModule_Race_Record\"")) {
            print('found race_record with index: ' + i);
            @rr = layer;
            break;
        }
    }
    MwFastBuffer<wstring> data;
    // data.Add(network.PlaygroundClientScriptAPI.LocalUser.WebServicesUserId);
    // data.Add(wstring("da4642f9-6acf-43fe-88b6-b120ff1308ba")); // scrappie
    // data.Add("9652fb43-3399-4f05-bdb5-57bcf8a4213b");
    // data.Add("cb137a6a-7112-4917-8e57-c457e082ea3d");
    // network.ClientManiaAppPlayground.LayerCustomEvent(rr, "TMxSM_Race_Record_ToggleGhost", data);
    // network.ClientManiaAppPlayground.SendCustomEvent("TMxSM_Race_Record_ToggleGhost", data);
    // network.ClientManiaAppPlayground.SendCustomEvent("TMxSM_Race_Record_SpectateGhost", data);

    @targetSH = cast<CSmArenaInterfaceManialinkScripHandler>(rr.LocalPage.ScriptHandler);

    // this crashes the game
    //cast<CSmArenaInterfaceManialinkScripHandler>(rr.LocalPage.ScriptHandler).SendCustomEvent(wstring("TMxSM_Race_Record_ToggleGhost"), data);

    // stuff to try
    // - cache page, then:
    // - PageAlwaysUpdateScript
    // - ?? page is visible, can we turn that on? (mb it's only true during rendering)

    // from anyghost
    // string CreateManialink() {
        // string ghostToggleEvent = "TMxSM_Race_Record_ToggleGhost";
        // return "<script><!--"
        //     + "main()"
        //     + "{"
        //     + "    SendCustomEvent(\"" + ghostToggleEvent + "\", [\"" + WsId + "\"]);"
        //     + "}"
        //     + "--></script>";

    if (targetSH !is null) {
        string _attachId = "AngelScript_CallBack";
        bool foundCBLayer = false;
        for (uint i = 0; i < layers.Length; i++) {
            auto layer = layers[i];
            if (layer.AttachId == _attachId) {
                foundCBLayer = true;
                break;
            }
        }
        if (!foundCBLayer) {
            auto layer = cmap.UILayerCreate();
            layer.AttachId = _attachId;
            layer.ManialinkPage = """
<script><!--
main()
{
    while(True) {
        SendCustomEvent("AngelScript_Hook", []);
        yield;
    }
}
--></script>""";
        }
    }

}


void RunGhostTest() {
    if (targetSH is null) {
        UI::ShowNotification("toggle ghost", "targetSH is null == true");
        return;
    }
    // ExploreNod(lastNod);
    // ExploreNod(thePage);
    // @targetSH.Page = thePage; // no set-accessor :(
    // warn(thePage.ScriptHandler);
    eventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"da4642f9-6acf-43fe-88b6-b120ff1308ba"}));
    // eventQueue.InsertLast("8d90f6c6-5a03-4fd3-8026-791c4d7404db");
    // eventQueue.InsertLast("41122fb7-f264-448e-9660-a418f438e58b");
    // eventQueue.InsertLast("1336b019-0d7d-43f7-b227-ff336f8b7140");
    // eventQueue.InsertLast("2a13aa7d-992d-4a7c-a3c5-d29b08b7f8cb");
}

// bool updateLastNod = true;

CustomEvent@[] eventQueue = {};

uint lastGameTime = 0;
bool logWhenCalled(CMwStack &in stack, CMwNod@ nod) {
    if (noIntercept) return true;
    UpdateGhosts_RunOnlyWhenSafe();
    return true;
}

void UpdateGhosts_RunOnlyWhenSafe() {
    if (targetSH is null) return;
    uint gt = targetSH.GameTime;
    if (targetSH !is null && gt > lastGameTime && targetSH.Page !is null) {
        lastGameTime = gt;
        // print("logWhenCalled - " + gt);
        while (eventQueue.Length > 0) {
            // cannot do more than one at a time
            auto ce = eventQueue[eventQueue.Length - 1];
            eventQueue.RemoveLast();
            noIntercept = true;
            // targetSH.SendCustomEvent(wstring("TMxSM_Race_Record_ToggleGhost"), data);
            targetSH.SendCustomEvent(ce.type, ce.data);
            noIntercept = false;
        }
    }
}

bool _LayerCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    auto data = stack.CurrentBufferWString();
    wstring type = stack.CurrentWString(1);
    print("LayerCustomEvent on nod: " + nod.IdName + " of type: " + type);
    for (uint i = 0; i < data.Length; i++) {
        auto item = data[i];
        print(item);
    }
    return true;
}

bool _SendCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    wstring type = stack.CurrentWString(1);
    // if (string(type) == "AngelScript_Hook") {return true;}
    auto data = stack.CurrentBufferWString();
    print("SendCustomEvent on nod: " + nod.IdName + " of type: " + type);
    for (uint i = 0; i < data.Length; i++) {
        auto item = data[i];
        print(item);
    }
    return true;
}

int countShNods = 0;

CSmArenaInterfaceManialinkScripHandler@ lastNod;
CGameManialinkPage@ thePage;

bool noIntercept = false;

bool _SendCustomEventSH(CMwStack &in stack, CMwNod@ nod) {
    if (noIntercept) return true;
    wstring type = stack.CurrentWString(1);
    if (string(type) != "AngelScript_Hook") {return true;}
    UpdateGhosts_RunOnlyWhenSafe();
    if (false) {
        auto data = stack.CurrentBufferWString();
        if (nod.IdName.Length <= 0) {
            nod.IdName = "SH-" + (++countShNods);
        }
        print("ScriptHandler.SendCustomEvent on nod: " + nod.IdName + " of type: " + type);
        print("Same as last nod? " + (@nod == @lastNod ? "yes" : "no"));
        print("Same as target script handler? " + (@nod == @targetSH ? "yes" : "no"));
        if (true || string(type) == "TMxSM_Race_Record_ToggleGhost") {
            print("Is nod CSmArenaInterfaceManialinkScripHandler?");
            print(cast<CSmArenaInterfaceManialinkScripHandler>(nod) is null ? "no" : "yes");
            if (cast<CSmArenaInterfaceManialinkScripHandler>(nod) !is null) {
                // if (updateLastNod) {
                    @lastNod = cast<CSmArenaInterfaceManialinkScripHandler>(nod);
                    if (@nod == @targetSH && lastNod.Page !is null) {
                        @thePage = lastNod.Page;
                    }
                // }
                print(".Page is null? " + (lastNod.Page is null ? "yes" : "no"));
                print(".PageIsVisible? " + (lastNod.PageIsVisible ? "yes" : "no"));
                print(".PageAlwaysUpdateScript? " + (lastNod.PageAlwaysUpdateScript ? "yes" : "no"));
            }
            print("Is nod CGameScriptHandlerPlaygroundInterface?");
            print(cast<CGameScriptHandlerPlaygroundInterface>(nod) is null ? "no" : "yes");
            print("Is nod CGameManialinkScriptHandler?");
            print(cast<CGameManialinkScriptHandler>(nod) is null ? "no" : "yes");
        }
        for (uint i = 0; i < data.Length; i++) {
            auto item = data[i];
            print(item);
        }
    }
    return false;
}


bool _Ghost_Add(CMwStack &in stack) {
    auto timeOffset = stack.CurrentInt();
    auto isGhostLayer = stack.CurrentBool(1);
    auto ghost = cast<CGameGhostScript>(stack.CurrentNod(2));
    // print("Ghost_Add on nod: " + nod.IdName + " isGhostLayer? " + (isGhostLayer ? 't' : 'f') + " timeOffset: " + timeOffset);
    // for (uint i = 0; i < data.Length; i++) {
    //     auto item = data[i];
    //     print(item);
    // }
    return true;
}
