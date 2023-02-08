/**
 * Results: UI layers are never destroyed via this method.
 * (probably explains why it crashes it game and that hasn't been fixed)
 */


// Dev::InterceptProc("CGameManiaApp", "UILayerDestroy", _UILayerDestroy);
// Dev::InterceptProc("CGamePlaygroundUIConfigMgrScript", "UILayerDestroy", _UILayerDestroy);
// Dev::InterceptProc("CGameManiaApp", "UILayerCreate", _UILayerCreate_CGMA);
// Dev::InterceptProc("CGamePlaygroundUIConfigMgrScript", "UILayerCreate", _UILayerCreate_CGPGUICMgr);

// bool _UILayerDestroy(CMwStack &in stack, CMwNod@ nod) {
//     auto layer = cast<CGameUILayer>(stack.CurrentNod());
//     if (layer is null) {
//         warn("_UILayerDestroy got a null layer!?");
//     } else {
//         auto header = layer.ManialinkPageUtf8.SubStr(0, Math::Min(127, layer.ManialinkPageUtf8.Length)).Trim();
//         print("Destroyed Layer: " + header);
//     }
//     return true;
// }

// bool _UILayerCreate_CGMA(CMwStack &in stack, CMwNod@ nod) {
//     auto cgma = cast<CGameManiaApp>(nod);
//     if (cgma is null) {
//         error("CGMA was null but that's what we intercepted!?");
//     } else {
//         print("CGMA Intercepted layer create, already there are nb layers: " + cgma.UILayers.Length);
//     }
//     return true;
// }

// bool _UILayerCreate_CGPGUICMgr(CMwStack &in stack, CMwNod@ nod) {
//     auto cgma = cast<CGameManiaApp>(nod);
//     if (cgma is null) {
//         error("CGPGUICMgr was null but that's what we intercepted!?");
//     } else {
//         print("CGPGUICMgr Intercepted layer create, already there are nb layers: " + cgma.UILayers.Length);
//     }
//     return true;
// }
