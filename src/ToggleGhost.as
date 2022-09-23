// none of these tests worked, but printing the events is useful
//  for getting info out of maniascript

void ToggleGhostTest() {
    Dev::InterceptProc("CGameManiaApp", "LayerCustomEvent", _LayerCustomEvent);
    Dev::InterceptProc("CGameManiaAppPlayground", "SendCustomEvent", _SendCustomEvent);
    // Dev::InterceptProc("CGameGhostMgrScript", "Ghost_SetDossard", _Ghost_Add);

    auto network = GetApp().Network;
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
    auto cmap = GetApp().Network.ClientManiaAppPlayground;
    MwFastBuffer<wstring> data;
    // data.Add(network.PlaygroundClientScriptAPI.LocalUser.WebServicesUserId);
    data.Add("9652fb43-3399-4f05-bdb5-57bcf8a4213b");
    // data.Add("cb137a6a-7112-4917-8e57-c457e082ea3d");
    // network.ClientManiaAppPlayground.LayerCustomEvent(rr, "TMxSM_Race_Record_ToggleGhost", data);
    // network.ClientManiaAppPlayground.SendCustomEvent("TMxSM_Race_Record_ToggleGhost", data);
    // network.ClientManiaAppPlayground.SendCustomEvent("TMxSM_Race_Record_SpectateGhost", data);
}


bool _LayerCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    auto data = stack.CurrentBufferWString();
    wstring type = stack.CurrentWString(1);
    print("LayerCustomEvent on nod: " + nod.Id.Value + " of type: " + type);
    for (uint i = 0; i < data.Length; i++) {
        auto item = data[i];
        print(item);
    }
    return true;
}

bool _SendCustomEvent(CMwStack &in stack, CMwNod@ nod) {
    auto data = stack.CurrentBufferWString();
    wstring type = stack.CurrentWString(1);
    print("SendCustomEvent on nod: " + nod.Id.Value + " of type: " + type);
    for (uint i = 0; i < data.Length; i++) {
        auto item = data[i];
        print(item);
    }
    return true;
}


bool _Ghost_Add(CMwStack &in stack) {
    auto timeOffset = stack.CurrentInt();
    auto isGhostLayer = stack.CurrentBool(1);
    auto ghost = cast<CGameGhostScript>(stack.CurrentNod(2));
    // print("Ghost_Add on nod: " + nod.Id.Value + " isGhostLayer? " + (isGhostLayer ? 't' : 'f') + " timeOffset: " + timeOffset);
    // for (uint i = 0; i < data.Length; i++) {
    //     auto item = data[i];
    //     print(item);
    // }
    return true;
}
