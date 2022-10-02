CGameDataFileManagerScript@ LastUsedDfm;

void Main() {
    HookManialinkCode();
    startnew(MainCoro);
    startnew(HookRouter::MainCoro);
#if SIG_DEVELOPER
    startnew(EventInspector::MainCoro); // note: does nothing as of 2022-09-27
#endif
}

void OnDisabled() {
    RemoveAllInjections();
}
void OnEnabled() {}
void OnDestroyed() {
    RemoveAllInjections();
}

void MainCoro() {
    while (true) {
        yield();
        yield();
        RunPendingInjections();
        RunQueuedMLDataInjections();
    }
}

void Render() {
    RenderDemoUI(); // only when setting enabled
}

void RenderInterface() {
#if SIG_DEVELOPER
    EventInspector::RenderEventInspectorWindow();
    LayersBrowser::RenderInterface();
#endif
}

void RenderMenuMain() {
    EventInspector::RenderMenuMainCapturingNotice(); // since this is a notice that only shows up when capturing is active, better to have it show up than not if it is somehow enabled
#if SIG_DEVELOPER
    // RenderMenuMainExploreNods();
#endif
}

void RenderMenu() {
#if SIG_DEVELOPER
    EventInspector::RenderEventInspectorMenuItem();
    LayersBrowser::RenderMenu();
#endif
}

// void NotifyRefresh(const string &in msg) {
//     UI::ShowNotification("Refresh Media", msg, vec4(.2, .6, .3, .3), 3000);
// }

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification("MLHook Error", msg, vec4(.9, .6, .1, .5), 7500);
}

void NotifyTodo(const string &in msg) {
    warn('Todo: ' + msg);
    UI::ShowNotification("MLHook Todo", msg, vec4(.5, .6, .3, .5), 7500);
}

void NotifyVersionIssue(const string &in msg) {
    warn(msg);
    UI::ShowNotification("MLHook Version Issue", msg, vec4(.9, .6, .3, .5), 20000);
}

// game api stuff

CGameManiaPlanet@ get_app() {
    return cast<CGameManiaPlanet>(GetApp());
}

CGameManiaAppPlayground@ get_cmap() {
    return app.Network.ClientManiaAppPlayground;
}

CInputScriptManager@ get_InputMgr() {
    return cmap is null ? null : cmap.Input;
}

// don't need CTrackManiaMenus
CGameCtnMenusManiaPlanet@ get_MenuMgr() {
    return app.MenuManager;
}

// MenuCustom_CurrentManiaApp
CGameManiaAppTitle@ get_mcma() {
    return MenuMgr.MenuCustom_CurrentManiaApp;
}
