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
            RenderPgUiLayersTab();
            UI::End();
        }
    }

    string draftMLPage = MinimalManialinkPageCode;

    void RenderPgUiLayersTab() {
        if (cmap is null) {
            UI::Text("CurrentManiaAppPlayground is null!\nTry loading a map.");
            return;
        } else if (cmap.UILayers.Length == 0) {
            UI::Text("Waiting for UILayers...");
            return;
        }

        UI::Text("Create UI Layer:");
        draftMLPage = UI::InputTextMultiline("ManialinkPage", draftMLPage);

        if (UI::Button("UILayerCreate")) {
            auto layer = cmap.UILayerCreate();
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
            DrawLayersList(cmap.UILayers);
        }
        UI::EndChild();
    }

    void DrawLayersList(MwFastBuffer<CGameUILayer@> &in layers) {
        for (uint i = 0; i < layers.Length; i++) {
            auto layer = layers[i];
            UI::PushID(layer);

            // index + MwId
            vec2 cPos = UI::GetCursorPos();
            UI::AlignTextToFramePadding();
            UI::Text("" + i + (layer.IdName.Length == 0 ? "" : " \\$fd7" + layer.IdName));
            // IsVisible checkbox
            UI::SetCursorPos(cPos + vec2(75, 0));
            layer.IsVisible = UI::Checkbox("", layer.IsVisible);
            AddSimpleTooltip("IsVisible");
            // nod explorer
            UI::SameLine();
            if (UI::Button(Icons::Cube + " Nod")) {
                ExploreNod(layer);
            }
            UI::SameLine();
            string isRunning = "\\$2f2" + Icons::PlayCircleO;
            if (!layer.IsLocalPageScriptRunning) {
                isRunning = "\\$f22" + Icons::StopCircleO;
            }
            UI::Text(isRunning);
            AddSimpleTooltip("layer.IsLocalPageScriptRunning");
            // IsRunning

            string mlPage = layer.ManialinkPageUtf8.SubStr(0, 127);
            string pageName = "";
            if (mlPage.StartsWith("\n<manialink name=\"")) {
                auto chunks = mlPage.Split("\"");
                if (chunks.Length > 1) {
                    pageName = chunks[1];
                }
            } else if (layer.AttachId != "Unassigned") {
                pageName = layer.AttachId;
            }

            if (pageName.Length > 0) {
                UI::SameLine();
                UI::Text(pageName);
            }

            UI::PopID();
        }
    }
}
