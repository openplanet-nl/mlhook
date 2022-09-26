namespace LayersBrowser {
    [Setting hidden]
    bool g_windowVisible = false;

    void RenderMenu() {
        if (UI::MenuItem(Icons::Map + " UILayers Browser")) {
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

    string draftMLPage = "";

    void RenderPgUiLayersTab() {
        if (cmap is null) {
            UI::Text("CurrentManiaAppPlayground is null!\nTry loading a map.");
            return;
        } else if (cmap.UILayers.Length == 0) {
            UI::Text("Waiting for UILayers...");
            return;
        }

        if (UI::Button("UILayerCreate")) {
            auto layer = cmap.UILayerCreate();
            layer.AttachId = "MLHook Temp " + Time::Now;
            if (draftMLPage.Length > 0) {
                layer.ManialinkPage = draftMLPage;
            }
            draftMLPage = "";
        }
        UI::SameLine();
        draftMLPage = UI::InputTextMultiline("ManialinkPage", draftMLPage);
        if (UI::Button("Reset draft page code")) {
            draftMLPage = "";
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

            vec2 cPos = UI::GetCursorPos();
            UI::AlignTextToFramePadding();
            UI::Text("" + i + (layer.IdName.Length == 0 ? "" : " \\$fd7" + layer.IdName));
            UI::SetCursorPos(cPos + vec2(75, 0));
            layer.IsVisible = UI::Checkbox("", layer.IsVisible);
            AddSimpleTooltip("IsVisible");
            UI::SameLine();
            if (UI::Button(Icons::Cube + " Nod")) {
                ExploreNod(layer);
            }
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
