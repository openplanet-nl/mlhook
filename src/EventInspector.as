namespace EventInspector {
    CustomEvent@[] events = {};
    dictionary eventTypes;
    dictionary eventSources;

    CustomEvent@[] f_events = {};
    string f_source;
    string f_type;

#if DEV
    bool g_windowVisible = true;
#else
    bool g_windowVisible = false;
#endif
    bool g_capturing = false;

    void CaptureEvent(wstring &in type, MwFastBuffer<wstring> &in data, const string &in source, CGameUILayer@ layer = null) {
        if (!g_capturing) return;
        auto event = CustomEvent(type, data, source, layer);
        if (events.Length > 0) {
            auto lastEvent = events[events.Length - 1];
            if (lastEvent == event) {
                lastEvent.repeatCount++;
                return;
            }
        }
        events.InsertLast(event);
        eventSources[event.source] = true;
        eventTypes[event.type] = true;
    }

    void ResetEventInspector() {
        events.RemoveRange(0, events.Length-1);
        eventTypes.DeleteAll();
        eventSources.DeleteAll();
        f_source = "";
        f_type = "";
        f_events.RemoveRange(0, f_events.Length-1);
    }

    array<CustomEvent@> get_filteredEvents() {
        if (f_events.Length == 0)
            return events;
        return f_events;
    }

    void UpdateFilterSource() {
        CustomEvent@[] tmp = {};
        for (uint i = 0; i < events.Length; i++) {
            auto item = events[i];
            if (item.source == f_source)
                tmp.InsertLast(item);
        }
        f_events = tmp;
    }

    void UpdateFilterType() {
        CustomEvent@[] tmp = {};
        for (uint i = 0; i < events.Length; i++) {
            auto item = events[i];
            if (string(item.type).Contains(f_type))
                tmp.InsertLast(item);
        }
        f_events = tmp;
    }



    void RenderEventInspectorMenuItem() {
        if (UI::MenuItem("\\$2f8" + Icons::ListAlt + "\\$z Event Inspector", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }


    // draw events and toggle capture
    void RenderEventInspectorWindow() {
        if (!g_windowVisible) return;
        UI::SetNextWindowSize(1200, 500, UI::Cond::FirstUseEver); // Appearing
        if (UI::Begin("Manialink Event Inspector", g_windowVisible)) {
            // capture/clear and legend

            g_capturing = UI::Checkbox("Capturing", g_capturing);
            UI::SameLine();
            if (UI::Button("Clear")) {
                ResetEventInspector();
            }
            UI::SameLine();
            UI::Dummy(vec2(20, 0));
            UI::SameLine();
            UI::Text("Source Legend:  CE = CustomEvent  |  SH = ScriptHandler  |  [AS] = from Anglescript code.");

            // filters

            vec2 cPos = UI::GetCursorPos();
            UI::AlignTextToFramePadding();
            UI::Text("Filter Type: ");
            UI::SetCursorPos(cPos + vec2(100, 0));
            UI::SetNextItemWidth(200);
            bool f_type_changed = false;
            f_type = UI::InputText("##f_type", f_type, f_type_changed);
            if (f_type_changed) UpdateFilterType();
            UI::SameLine();
            if (UI::Button(Icons::Times + "##f_type")) {
                f_type = "";
                UpdateFilterType();
            }

            // UI::SameLine();

            cPos = UI::GetCursorPos();
            UI::AlignTextToFramePadding();
            UI::Text("Filter Source: ");
            UI::SetCursorPos(cPos + vec2(100, 0));
            bool f_source_changed = false;
            UI::SetNextItemWidth(200);
            if (UI::BeginCombo("##f_source", f_source == "" ? "<None>" : f_source)) {
                if (UI::Selectable("<None>", "" == f_source)) {
                    f_source = "";
                    UpdateFilterSource();
                }
                auto eventSourceKeys = eventSources.GetKeys();
                for (uint i = 0; i < eventSourceKeys.Length; i++) {
                    auto item = eventSourceKeys[i];
                    if (UI::Selectable(item, item == f_source)) {
                        f_source = item;
                        UpdateFilterSource();
                    }
                }
                UI::EndCombo();
            }
            UI::SameLine();
            if (UI::Button(Icons::Times + "##f_source")) {
                f_source = "";
                UpdateFilterSource();
            }

            // table

            if (UI::BeginTable("Events", 6, UI::TableFlags::Resizable)) {
                UI::TableSetupColumn("Time", UI::TableColumnFlags::WidthFixed, 50);
                UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthFixed, 200);
                UI::TableSetupColumn("Data", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Source", UI::TableColumnFlags::WidthFixed, 120);
                UI::TableSetupColumn("Repeats", UI::TableColumnFlags::WidthFixed, 50);
                UI::TableSetupColumn("Actions", UI::TableColumnFlags::WidthFixed, 230);
                UI::TableHeadersRow();

                UI::ListClipper clipper(filteredEvents.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        auto event = filteredEvents[filteredEvents.Length - i - 1];
                        UI::PushID(event);  // neat; didn't know about this
                        UI::TableNextRow();

                        UI::TableNextColumn();
                        UI::Text(Time::Stamp - event.time + " s");

                        UI::TableNextColumn();
                        UI::Text(event.type);

                        UI::TableNextColumn();
                        UI::Text(event.ToString(true));

                        UI::TableNextColumn();
                        UI::Text(event.source);

                        UI::TableNextColumn();
                        if (event.repeatCount > 0)
                            UI::Text("\\$d92" + event.repeatCount);

                        UI::TableNextColumn();
                        if (UI::Button(Icons::Clipboard + " Type")) {
                            IO::SetClipboard(event.type);
                        }
                        UI::SameLine();
                        if (UI::Button(Icons::Clipboard + " Data")) {
                            IO::SetClipboard(event.ToString(true));
                        }
                        UI::SameLine();
                        if (UI::Button(Icons::Clipboard + " All")) {
                            IO::SetClipboard(event.ToString());
                        }
                        if (event.layer !is null) {
                            UI::SameLine();
                            if (UI::Button(Icons::Cube + " Layer Nod")) {
                                ExploreNod(event.layer);
                            }
                            AddSimpleTooltip("Opens the layer in the Nod Explorer");
                        }

                        UI::PopID();
                    }
                }
                UI::EndTable();
            }
        }
        UI::End();
    }
}
