CGameDataFileManagerScript@ LastUsedDfm;

void Main() {
    HookManialinkCode();
    startnew(MainCoro);
    startnew(EventInspector::MainCoro);
#if DEV
    startnew(DevRoutines);
#endif
}

void MainCoro() {
    while (true) {
        yield();
        RunPendingInjections();
        RunQueuedMlDataInjections();
    }
}

void Render() {
    RenderDemoUI(); // only when setting enabled
}

void RenderInterface() {
    EventInspector::RenderEventInspectorWindow();
    LayersBrowser::RenderInterface();
}

void RenderMenuMain() {
    EventInspector::RenderMenuMainCapturingNotice();
#if DEV
    RenderMenuMainExploreNods();
#endif
}

void RenderMenu() {
    EventInspector::RenderEventInspectorMenuItem();
    LayersBrowser::RenderMenu();
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
    UI::ShowNotification("MLHook Version Issue", msg, vec4(.9, .6, .3, .5), 7500);
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

#if DEV
void DevRoutines() {
    // startnew(PanicMode::TestPanicMode);
    // startnew(RedBlackTreeChecks);
    // TestListConstructors();
}

void TestListConstructors() {
    print("array<string>(5): " + ArrStringToString(array<string>(5)));
    print("array<uint>(5, 10): " + ArrUintToString(array<uint>(5, 10)));
    print('array<string>(5, "x"): ' + ArrStringToString(array<string>(5, "x")));
}

#endif
