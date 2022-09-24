CGameDataFileManagerScript@ LastUsedDfm;

void Main() {
    HookManialinkCode();
}

void Render() {
    RenderDemoUI(); // only when setting enabled
}

void RenderInterface() {
    EventInspector::RenderEventInspectorWindow();
}

#if DEV
void RenderMenuMain() {
    RenderMenuMainExploreNods();
}
#endif

void RenderMenu() {
    EventInspector::RenderEventInspectorMenuItem();
}

// void NotifyRefresh(const string &in msg) {
//     UI::ShowNotification("Refresh Media", msg, vec4(.2, .6, .3, .3), 3000);
// }

// void NotifyError(const string &in msg) {
//     warn(msg);
//     UI::ShowNotification("Refresh Media", msg, vec4(.9, .6, .1, .5), 7500);
// }

// game api stuff

CGameManiaAppPlayground@ get_cmap() {
    return GetApp().Network.ClientManiaAppPlayground;
}

CInputScriptManager@ get_InputMgr() {
    return cmap.Input;
}
