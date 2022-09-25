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
    // RedBlackTreeChecks();
    // TestListConstructors();
}

void TestListConstructors() {
    print("array<string>(5): " + ArrStringToString(array<string>(5)));
    print("array<uint>(5, 10): " + ArrUintToString(array<uint>(5, 10)));
    print('array<string>(5, "x"): ' + ArrStringToString(array<string>(5, "x")));
}

void RedBlackTreeChecks() {
    // print('"a".opCmp("b") = ' + "a".opCmp("b"));
    // print('"B".opCmp("b") = ' + "B".opCmp("b"));
    // print('"b".opCmp("b") = ' + "b".opCmp("b"));
    // print('"x".opCmp("b") = ' + "x".opCmp("b"));
    // print('"".opCmp("b") = ' + "".opCmp("b"));

    auto rb = RedBlackTree();
    rb.Put(CustomEvent("", {"2", "1", "3"}));
    if (true) {
        print(rb.size);
        RBTreeNode@ tn;
        auto iter = rb.GetIter();
        uint count = 0;
        for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
            // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
            print(tn.ce.ToString() + " " + tn.ce.repeatCount);
            count++;
        }
        print("total looped: " + count);
    }
    rb.Put(CustomEvent("", {"2", "1", "7"}));
    if (true) {
        print(rb.size);
        RBTreeNode@ tn;
        auto iter = rb.GetIter();
        uint count = 0;
        for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
            // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
            print(tn.ce.ToString() + " " + tn.ce.repeatCount);
            count++;
        }
        print("total looped: " + count);
    }
    rb.Put(CustomEvent("", {"2", "1", "5"}));
    if (true) {
        print(rb.size);
        RBTreeNode@ tn;
        auto iter = rb.GetIter();
        uint count = 0;
        for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
            // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
            print(tn.ce.ToString() + " " + tn.ce.repeatCount);
            count++;
        }
        print("total looped: " + count);
    }
    rb.Put(CustomEvent("", {"2", "1", "4"}));
    rb.Put(CustomEvent("", {"2", "1", "9"}));
    rb.Put(CustomEvent("", {"2", "1", "9"}));
    rb.Put(CustomEvent("", {"2", "1", "1"}));
    rb.Put(CustomEvent("", {"2", "1"}));
    rb.Put(CustomEvent("", {"2", "1", "a"}));
    rb.Put(CustomEvent("", {"a", "j", "r"}));
    rb.Put(CustomEvent("", {"a", "i", "r"}));
    rb.Put(CustomEvent("", {"a", "j", "m"}));
    rb.Put(CustomEvent("", {"a", "j", "z"}));
    rb.Put(CustomEvent("", {"a", "j", "z"}));
    rb.Put(CustomEvent("", {"a", "h", "r"}));
    rb.Put(CustomEvent("", {"z", "r", "r"}));
    rb.Put(CustomEvent("", {"z", "1", "d"}));
    rb.Put(CustomEvent("", {"z", "r", "z"}));
    rb.Put(CustomEvent("", {"z", "6", "r"}));
    rb.Put(CustomEvent("", {"z", "3", "z"}));
    rb.Put(CustomEvent("", {"z", "r", "8"}));
    rb.Put(CustomEvent("", {"m", "r", "r"}));
    rb.Put(CustomEvent("", {"m", "rr", "r"}));
    rb.Put(CustomEvent("", {"m", "rl", "r"}));
    rb.Put(CustomEvent("", {"m", "rl", "2r"}));
    rb.Put(CustomEvent("", {"l", "rl", "2r"}));
    rb.Put(CustomEvent("", {"r", "l", "2r"}));
    rb.Put(CustomEvent("", {"m", "l", "zz"}));
    print(rb.size);
    RBTreeNode@ tn;
    auto iter = rb.GetIter();
    uint count = 0;
    for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
        // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
        print(tn.ce.ToString() + " " + tn.ce.repeatCount);
        count++;
    }
    print("total looped: " + count);
}
#endif
