#if SIG_DEVELOPER
namespace LayersBrowser {
    [Setting hidden]
    bool g_windowVisible = false;

    void RenderMenu() {
        if (UI::MenuItem(Icons::Map + " UILayers Browser", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }

    void RenderInterface() {
        if (!g_windowVisible) return;
        if (UI::Begin("UILayers Browser", g_windowVisible)) {
            UI::BeginTabBar("ui browser tabs", UI::TabBarFlags::None);

            if (UI::BeginTabItem("Main Menu")) {
                RenderMainMenuUiLayersTab();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem("Playground")) {
                RenderPgUiLayersTab();
                UI::EndTabItem();
            }

            UI::EndTabBar();
            UI::End();
        }
    }

    string draftMLPage = MinimalManialinkPageCode;

    void RenderMainMenuUiLayersTab() {
        auto mm = cast<CGameManiaPlanet>(GetApp()).MenuManager;
        auto mccma = mm !is null ? mm.MenuCustom_CurrentManiaApp : null;
        if (mccma is null) {
            UI::Text("MenuCustom_CurrentManiaApp is null!\nThis is unexpected.");
            return;
        } else if (mccma.UILayers.Length == 0) {
            UI::Text("No menu UI layers.");
            return;
        }
        DrawManiaAppUILayers(mccma);
    }

    void RenderPgUiLayersTab() {
        if (cmap is null) {
            UI::Text("CurrentManiaAppPlayground is null!\nTry loading a map.");
            return;
        } else if (cmap.UILayers.Length == 0) {
            UI::Text("Waiting for UILayers...");
            return;
        }
        DrawManiaAppUILayers(cmap);
    }

    void DrawManiaAppUILayers(CGameManiaApp@ mApp) {
        UI::Text("Create UI Layer:");
        draftMLPage = UI::InputTextMultiline("ManialinkPage", draftMLPage);

        if (UI::Button("UILayerCreate")) {
            auto layer = mApp.UILayerCreate();
            layer.AttachId = "MLHook Temp " + Time::Now;
            if (draftMLPage.Length > 0) {
                layer.ManialinkPage = draftMLPage;
            }
            draftMLPage = MinimalManialinkPageCode;
        }
        UI::SameLine();
        UI::Dummy(vec2(25, 0));
        UI::SameLine();
        if (UI::Button("Reset draft page code")) {
            draftMLPage = MinimalManialinkPageCode;
        }

        UI::Separator();

        if (UI::BeginChild("ui layers")) {
            uint nCols = 6;
            if (UI::BeginTable("layers list table", nCols, UI::TableFlags::SizingStretchProp)) {
                UI::TableSetupColumn("Ix / MwId", UI::TableColumnFlags::WidthFixed, 75.0);
                UI::TableSetupColumn("Visible", UI::TableColumnFlags::WidthFixed);
                UI::TableSetupColumn("##NodBtn", UI::TableColumnFlags::WidthFixed);
                UI::TableSetupColumn("##Running", UI::TableColumnFlags::WidthFixed);
                UI::TableSetupColumn("ML Page Name", UI::TableColumnFlags::WidthFixed);
                UI::TableSetupColumn("##OptsBtnsExtra", UI::TableColumnFlags::WidthStretch);
                DrawLayersList(mApp);
                UI::EndTable();
            }
        }
        UI::EndChild();
    }

    void DrawLayersList(CGameManiaApp@ mApp) {
        int nbLayers = mApp.UILayers.Length;
        UI::ListClipper clip(nbLayers);
        while (clip.Step()) {
            for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
                if (i >= nbLayers) continue;
                auto @layer = mApp.UILayers[i];

                UI::TableNextRow();
                UI::TableNextColumn();
                UI::AlignTextToFramePadding();

                if (layer is null || layer.ManialinkPage.Length < 10) {
                    UI::Text("" + i + ". Skipped");
                    UI::TableNextColumn();
                    UI::TableNextColumn();
                    UI::TableNextColumn();
                    UI::TableNextColumn();
                    UI::Text("Empty page. Attach ID: " + layer.AttachId);
                    continue;
                }

                UI::PushID(layer);

                // index + MwId
                // vec2 cPos = UI::GetCursorPos();
                UI::Text("" + i + (layer.IdName.Length == 0 ? "" : " \\$fd7" + layer.IdName));
                // IsVisible checkbox
                // UI::SetCursorPos(cPos + vec2(75, 0));

                UI::TableNextColumn();
                layer.IsVisible = UI::Checkbox("", layer.IsVisible);
                AddSimpleTooltip("IsVisible");
                // nod explorer
                UI::TableNextColumn();
                if (UI::Button(Icons::Cube + " Nod")) {
                    ExploreNod(layer);
                }
                UI::TableNextColumn();
                string isRunning = "\\$2f2" + Icons::PlayCircleO;
                if (!layer.IsLocalPageScriptRunning) {
                    isRunning = "\\$f22" + Icons::StopCircleO;
                }
                UI::Text(isRunning);
                AddSimpleTooltip("layer.IsLocalPageScriptRunning");
                // IsRunning
                auto pageStart = layer.ManialinkPageUtf8.SubStr(0, Math::Min(layer.ManialinkPage.Length, 127));
                string mlPage = pageStart.Length > 10 ? pageStart.Trim() : pageStart;
                string pageName = "";
                if (mlPage.StartsWith("<manialink name=\"")) {
                    auto chunks = mlPage.Split("\"");
                    if (chunks.Length > 1) {
                        pageName = chunks[1];
                    }
                } else if (layer.AttachId != "Unassigned") {
                    pageName = layer.AttachId;
                }

                UI::TableNextColumn();
                if (pageName.Length > 0) {
                    UI::Text(pageName);
                }

                UI::TableNextColumn();
                if (UI::Button("Copy ML")) {
                    ref@[] ud;
                    ud.InsertLast(layer);
                    ud.InsertLast(array<string> = {pageName});
                    startnew(OnClickCopyML, ud);
                }

                UI::PopID();
            }
        }
    }

    bool CtrlButton(const string &in label, CoroutineFuncUserdata@ onClick, ref@ userData, bool sameLineAfter = true) {
        bool clicked = UI::Button(label);
        if (clicked) startnew(onClick, userData);
        if (sameLineAfter) UI::SameLine();
        return clicked;
    }

    void OnClickCopyML(ref@ incoming) {
        auto refs = cast<ref[]>(incoming);
        if (refs is null || refs.Length < 2) {
            warn('refs null'); return;
        } else if (refs.Length < 2) {
            warn(' or bad len: ' + refs.Length); return;
        }
        auto layer = cast<CGameUILayer>(refs[0]);
        auto pageName = cast<string[]>(refs[1])[0];

        IO::SetClipboard(layer.ManialinkPageUtf8);
        UI::ShowNotification(Meta::ExecutingPlugin().Name, "Copied Manialink for " + pageName);
    }
}
#endif
