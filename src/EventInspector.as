namespace EventInspector {
    CustomEvent@[] events = {};
    dictionary eventTypes;
    dictionary eventSources;

    CustomEvent@[] f_events = {};
    EventSource f_source;
    string f_type;

#if DEV
    bool g_windowVisible = true;
#else
    bool g_windowVisible = false;
#endif
    bool g_capturing = false;

    bool get_ShouldCapture() {
        // should we only capture when the window is visible?
        return g_capturing && g_windowVisible;
    }

    void _RecordCaptured(CustomEvent@ event) {
        if (events.Length > 0) {
            auto lastEvent = events[events.Length - 1];
            if (lastEvent == event) {
                lastEvent.repeatCount++;
                return;
            }
        }
        events.InsertLast(event);
        eventSources[tostring(event.source)] = true;
        eventTypes[event.type] = true;
        _FilterAddEvent(event);
    }

    void _FilterAddEvent(CustomEvent@ event) {
        if (_EventMeetsFilterConditions(event)) {
            f_events.InsertLast(event);
        }
    }

    void CaptureEvent(wstring &in type, MwFastBuffer<wstring> &in data, EventSource &in source, const string &in annotation = "", CGameUILayer@ layer = null, CGameEditorPluginHandle@ handle = null) {
        if (!ShouldCapture) return;
        auto event = CustomEvent(type, data, source, annotation, layer, handle);
        _RecordCaptured(event);
    }

    void CaptureMlScriptEvent(CGameManialinkScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {tostring(event.KeyCode), event.KeyName, event.CharPressed, event.ControlId, tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f', event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.PluginCustomEventType, FastBufferWStringToString(event.PluginCustomEventData)};
        auto ce = CustomEvent("CGameManialinkScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::ML_SE);
        _RecordCaptured(ce);
    }

    // todo: actually capture some stuff
    void CaptureMAScriptEvent(CGameManiaAppScriptEvent@ event) {
        if (!ShouldCapture) return;
        // event.ControlId, tostring(event.MenuNavAction),
        string[] data = {tostring(event.KeyCode), event.KeyName, event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.ExternalEventType, FastBufferWStringToString(event.ExternalEventData), "EMenuNavAction::" + tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f'};
        auto ce = CustomEvent("CGameManiaAppScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::MA_SE, "", event.CustomEventLayer);
        _RecordCaptured(ce);
    }

    // todo: doesn't seem to capture anything... maybe wrong point in maniascript execution flow
    void CaptureMAPGScriptEvent(CGameManiaAppPlaygroundScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {event.PlaygroundScriptEventType, FastBufferWStringToString(event.PlaygroundScriptEventData),
            (event.Ghost is null) ? "Ghost(null)" : ("Ghost(id=" + event.Ghost.Id.Value + ", Nickname=\"" + event.Ghost.Nickname + "\", ...(todo)...)"),
            "GameplaySpecialType::" + tostring(event.GameplaySpecialType),
            "GameplayTurboRoulette::" + tostring(event.GameplayTurboRoulette),
            "RaceWaypointTime=" + event.RaceWaypointTime,
            "DiffWithBestRace=" + event.DiffWithBestRace,
            "RaceWaypointCount=" + event.RaceWaypointCount,
            "RaceWaypointIndex=" + event.RaceWaypointIndex,
            tostring(event.KeyCode), event.KeyName, event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.ExternalEventType, FastBufferWStringToString(event.ExternalEventData), "EMenuNavAction::" + tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f'};
        auto ce = CustomEvent("PlaygroundType::" + tostring(event.PlaygroundType), ArrStringToFastBufferWString(data), EventSource::MAPG_SE, "", event.CustomEventLayer);
        _RecordCaptured(ce);
    }

    // todo: doesn't seem to capture anything... maybe wrong point in maniascript execution flow
    void CaptureInputScriptEvent(CInputScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {"EButton::" + tostring(event.Button),
            tostring(event.KeyCode), event.KeyName, event.IsAutoRepeat ? 't' : 'f'};
        auto ce = CustomEvent("CInputScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::InputSE, "");
        _RecordCaptured(ce);
    }

    void ResetEventInspector() {
        events.RemoveRange(0, events.Length);
        eventTypes.DeleteAll();
        eventSources.DeleteAll();
        f_source = EventSource::Any;
        f_type = "";
        f_events.RemoveRange(0, f_events.Length);
    }

    bool get_IsFilterActive() {
        return false
            || f_source != EventSource::Any
            || f_type.Length > 0
            ;
    }

    array<CustomEvent@> get_filteredEvents() {
        if (!IsFilterActive)
            return events;
        return f_events;
    }

    bool _EventMeetsFilterConditions(CustomEvent@ event) {
        // bool ret = true;
        if (f_type != "" && !string(event.type).Contains(f_type)) return false;
        if (f_source != EventSource::Any && event.source != f_source) return false;
        return true;
    }

    void UpdateFilter() {
        CustomEvent@[] tmp = {};
        for (uint i = 0; i < events.Length; i++) {
            auto item = events[i];
            if (_EventMeetsFilterConditions(item))
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
            if (f_type_changed) UpdateFilter();
            UI::SameLine();
            if (UI::Button(Icons::Times + "##f_type")) {
                f_type = "";
                UpdateFilter();
            }

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
                    UpdateFilter();
                }
                // start at 1 to skip any/all option
                for (uint i = 1; i < AllEventSources.Length; i++) {
                    auto item = AllEventSources[i];
                    if (UI::Selectable(EventSourceToString(item), item == f_source)) {
                        f_source = item;
                        UpdateFilter();
                    }
                }
                UI::EndCombo();
            }
            UI::SameLine();
            if (UI::Button(Icons::Times + "##f_source")) {
                f_source = EventSource::Any;
                UpdateFilter();
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
                        UI::Text(event.AnnoPrefix + EventSourceToString(event.source));

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

    void MaybeDrawNodExplorerBtnFor(const string &in label, CMwNod@ &in nod, bool sameLine = true) {
        if (sameLine) UI::SameLine();
        if (nod !is null && UI::Button(Icons::Cube + " " + label + " Nod")) {
            ExploreNod(nod);
        }
    }
}
