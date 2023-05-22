namespace EventInspector
{
    CustomEvent@[] events = {};
    uint totalEvents = 0;
    dictionary recentEventHashLookup;
    dictionary eventTypes; // type -> count
    dictionary eventSources; // type -> count

    CustomEvent@[] f_events = {};
    EventSource f_source;
    bool f_invSource;
    string f_type;
    bool f_invType;

#if DEV
    bool g_windowVisible = false;
#else
    bool g_windowVisible = false;
#endif
    bool g_capturing = false;

    bool get_ShouldCapture()
    {
        return g_capturing;
    }

    void StopCapture()
    {
        g_capturing = false;
    }

    bool get_IsCapturing()
    {
        return g_capturing;
    }

    void MainCoro()
    {
        // does nothing atm
    }

    // main ingestion functions in CaptureTypes.as
    void _RecordCaptured(CustomEvent@ event)
    {
        // dev_trace("_RecCaptured: " + event.ToString());
        totalEvents++;
        eventSources[tostring(event.source)] = uint(eventSources[tostring(event.source)]) + 1;
        eventTypes[event.type] = uint(eventTypes[event.type]) + 1;
        if (recentEventHashLookup.Exists(event.ToString())) {
            auto priorEvent = cast<CustomEvent>(recentEventHashLookup[event.ToString()]);
            if (priorEvent.time == uint(Time::Stamp)) {
                priorEvent.repeatCount++;
                return;
            }
        }
        @recentEventHashLookup[event.ToString()] = event;
        events.InsertLast(event);
        _FilterAddEvent(event);
    }

    void _FilterAddEvent(CustomEvent@ event)
    {
        if (_EventMeetsFilterConditions(event)) {
            f_events.InsertLast(event);
        }
    }

    void ResetEventInspector()
    {
        events.RemoveRange(0, events.Length);
        recentEventHashLookup = dictionary();
        eventTypes.DeleteAll();
        eventSources.DeleteAll();
        totalEvents = 0;
        f_source = EventSource::Any;
        f_type = "";
        f_events.RemoveRange(0, f_events.Length);
        f_invSource = false;
        f_invType = false;
    }

    bool get_IsFilterActive()
    {
        return false
            || f_source != EventSource::Any
            || f_type.Length > 0
            ;
    }

    array<CustomEvent@> get_filteredEvents()
    {
        if (!IsFilterActive)
            return events;
        return f_events;
    }

    bool _EventMeetsFilterConditions(CustomEvent@ event)
    {
        if ((f_type != "" && (!f_invType == !event.s_type.Contains(f_type)))) return false;
        if ((f_source != EventSource::Any && (!f_invSource == (event.source != f_source)))) return false;
        return true;
    }

    void UpdateFilter()
    {
        CustomEvent@[] tmp = {};
        for (uint i = 0; i < events.Length; i++) {
            auto item = events[i];
            if (_EventMeetsFilterConditions(item))
                tmp.InsertLast(item);
        }
        f_events = tmp;
    }

    void UpdateFilterSoon()
    {
        yield();
        yield();
        UpdateFilter();
    }

    uint lastEventCount = 0;
    void RenderMenuMainCapturingNotice()
    {
        if (g_capturing) {
            if (UI::BeginMenu("\\$f00" + Icons::Circle + "\\$z Event Capture: (" + lastEventCount + ")")) {
                // can't add tooltip here?
                // AddSimpleTooltip("This will slow down game-code.\nPlease don't forget to turn it off.");
                RenderEventInspectorMenuItem();
                UI::Separator();
                for (uint i = 0; i < AllEventSources.Length; i++) {
                    auto item = AllEventSources[i];
                    uint count = (item == EventSource::Any) ? totalEvents : uint(EventInspector::eventSources[tostring(item)]);
                    UI::MenuItem(EventSourceToString(item), '\\$ddd' + count, false, false);
                }
                UI::Separator();
                if (UI::MenuItem("Stop Capture", "", false)) {
                    EventInspector::StopCapture();
                }
                UI::EndMenu();
            } else {
                bool wasClicked = UI::IsItemClicked();
                AddSimpleTooltip("This will slow down game-code.\nPlease don't forget to turn it off.");
                // we don't want to update this when the menu is open b/c the ID changes
                if (!wasClicked)
                    lastEventCount = totalEvents;
            }
        }
    }

    void RenderEventInspectorMenuItem()
    {
        if (UI::MenuItem("\\$2f8" + Icons::ListAlt + "\\$z ML Event Inspector", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }


    // draw events and toggle capture
    void RenderEventInspectorWindow()
    {
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
            vec2 cPos = UI::GetCursorPos();
            UI::TextWrapped("Source Legend:  CE = CustomEvent  |  MA = ManiaApp |  ML = Manialink  | SE = ScriptEvent  |  SH = ScriptHandler  |  [AS] = from Anglescript code.");
            // go to the line below but line up with the above legend
            UI::AlignTextToFramePadding();
            UI::SetCursorPos(UI::GetCursorPos() * vec2(0, 1) + cPos * vec2(1, 0));
            UI::Text("Types & Description: ");
            UI::SameLine();
            for (uint i = 0; i < AllEventSources.Length; i++) {
                if (i > 0) UI::SameLine();
                auto es = AllEventSources[i];
                auto tt = EventSourceLegend[i];
                UI::Text(EventSourceToString(es));
                AddSimpleTooltip(tt);
            }
            VPad();
            // filters

            cPos = UI::GetCursorPos();
            UI::AlignTextToFramePadding();
            UI::Text("Filter Type: ");
            UI::SetCursorPos(cPos + vec2(100, 0));
            UI::SetNextItemWidth(200);
            bool f_type_changed = false;
            f_type = UI::InputText("##f_type", f_type, f_type_changed);
            if (f_type_changed) startnew(UpdateFilter);
            UI::SameLine();
            if (UI::Button(Icons::Times + "##f_type")) {
                f_type = "";
                startnew(UpdateFilter);
            }
            UI::SameLine();
            UI::Checkbox(Icons::Exclamation + "##inv-type", f_invType);
            if (UI::IsItemClicked()) {f_invType = !f_invType; startnew(UpdateFilter);}
            AddSimpleTooltip("Exclude matches");

            // UI::SameLine();

            cPos = UI::GetCursorPos();
            UI::AlignTextToFramePadding();
            UI::Text("Filter Source: ");
            UI::SetCursorPos(cPos + vec2(100, 0));
            bool f_source_changed = false;
            UI::SetNextItemWidth(200);
            if (UI::BeginCombo("##f_source", f_source == EventSource::Any ? "<Any/All>" : EventSourceToString(f_source))) {
                if (UI::Selectable("<Any/All>", EventSource::Any == f_source)) {
                    f_source = EventSource::Any;
                    startnew(UpdateFilter);
                }
                // start at 1 to skip any/all option
                for (uint i = 1; i < AllEventSources.Length; i++) {
                    auto item = AllEventSources[i];
                    if (UI::Selectable(EventSourceToString(item), item == f_source)) {
                        f_source = item;
                        startnew(UpdateFilter);
                    }
                }
                UI::EndCombo();
            }
            UI::SameLine();
            if (UI::Button(Icons::Times + "##f_source")) {
                f_source = EventSource::Any;
                startnew(UpdateFilter);
            }
            UI::SameLine();
            UI::Checkbox(Icons::Exclamation + "##inv-source", f_invSource);
            if (UI::IsItemClicked()) {f_invSource = !f_invSource; startnew(UpdateFilter);}
            AddSimpleTooltip("Exclude matches");

            // table

            if (UI::BeginTable("Events", 6, UI::TableFlags::Resizable | UI::TableFlags::ScrollY)) {
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
                        UI::Text(event.SourceStrClr);

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
                        MaybeDrawNodExplorerBtnFor("Layer", event.layer);
                        MaybeDrawNodExplorerBtnFor("Handle", event.handle);
                        if (event.layer !is null) {
                            UI::SameLine();
                            if (UI::Button(Icons::Cube + " Layer Nod")) {
                                ExploreNod(event.layer);
                            }
                            AddSimpleTooltip("Opens the layer in the Nod Explorer\n\\$f91## Warning. Can crash the game if\nyou don't close the layer tab! ##\\$z");
                        }

                        UI::PopID();
                    }
                }
                UI::EndTable();
            }
        }
        UI::End();
    }

    void MaybeDrawNodExplorerBtnFor(const string &in label, CMwNod@ nod, bool sameLine = true)
    {
        if (sameLine) UI::SameLine();
        if (nod !is null && UI::Button(Icons::Cube + " " + label + " Nod")) {
            ExploreNod(nod);
        }
    }
}
