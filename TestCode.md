```AngelScript
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
```
