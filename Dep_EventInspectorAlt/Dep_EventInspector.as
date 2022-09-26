/*
There are too many events to capture for very long without increasing frametimes.
This gets worse when events happen simultaneously b/c we don't end up counting duplicates.
So we need a way to aggregate all events within a 'tick' (1s?) into a combined row.
*/
class EventsPerTick {
    // data heirarchy: s_type > s_data
    private RedBlackTree@ eventTree;
    private uint _time;
    uint get_time() { return _time; }
    uint get_Length() { return eventTree.Length; }

    EventsPerTick(uint time) {
        _time = time;
        @eventTree = RedBlackTree();
    }

    void AddEvent(CustomEvent@ ce) {
        // string[] key = {ce.s_type};
        // for (uint i = 0; i < ce.s_data.Length; i++) {
        //     key.InsertLast(ce.s_data[i]);
        // }
        eventTree.Put(ce);
    }

    IterCE@ EventIter() {
        return eventTree.GetIter();
    }

    private array<EventRow@>@ cachedRows;

    array<EventRow@>@ PrepareTickRows() {
        if (cachedRows !is null && cachedRows.Length > 0) return cachedRows;
        // string[][] =
        array<EventRow@> rows = {};
        CustomEvent@ tn;
        auto iter = eventTree.GetIter();
        for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
            rows.InsertLast(EventRow(
                {tn.s_type, tn.s_data_csv, tn.SourceStr,
                tn.repeatCount > 0 ? "\\$d92" + tn.repeatCount : ""},
                tn, this));
        }
        if (time < Time::Stamp) { // we're stale so can cache the rows
            @cachedRows = rows;
        }
        return rows;
    }
}

class EventRow {
    string[]@ row;
    CustomEvent@ ce;
    EventsPerTick@ ept;
    EventRow(string[] &in _row, CustomEvent@ &in _ce, EventsPerTick@ &in _ept) {
        @row = _row;
        @ce = _ce;
        @ept = _ept;
    }
}

namespace EventInspector {
    EventsPerTick@[] ticks = {};
    EventRow@[] allPastRows = {};
    CustomEvent@[] events = {};
    dictionary eventTypes;
    dictionary eventSources;

    CustomEvent@[] f_events = {};
    EventSource f_source;
    string f_type;

    // uint eventLimit = 1000;

#if DEV
    bool g_windowVisible = true;
#else
    bool g_windowVisible = false;
#endif
    bool g_capturing = false;

    void MainCoro() {
        while (true) {
            yield();
            if (ticks.Length > 1) {
                for (uint i = 0; i < ticks.Length - 1; i++) {
                    _ArchivePriorTick(ticks[i]);
                }
                ticks.RemoveRange(0, ticks.Length - 1);
            }
            if (capturedQueue.Length > 0) {
                uint count = 0;
                // print(capturedQueue.Length);
                while (0 < capturedQueue.Length) {
                    auto event = capturedQueue[capturedQueue.Length - 1];
                    capturedQueue.RemoveLast();
                    auto tick = GetCurrentEvents();
                    print('tick is null ? ' + (tick is null ? 'y' : 'n'));
                    tick.AddEvent(event);
                    count++;
                }
                // print('after: ' + capturedQueue.Length + ' with count ' + count);
            }
            // print("skipping: " + capturedQueue[capturedQueue.Length - 1].ToString());
            // capturedQueue.RemoveRange(0, capturedQueue.Length);
        }
    }

    bool get_ShouldCapture() {
        // todo: should we only capture when the window is visible?
        return g_capturing && g_windowVisible;
    }

    uint get_CurrentTick() {
        return Time::Stamp; // ticks every second
    }

    EventsPerTick@ GetCurrentEvents() {
        if (ticks.Length == 0) {
            ticks.InsertLast(EventsPerTick(CurrentTick));
        }
        return ticks[0];
        // if (ticks.Length == 0 || ticks[ticks.Length - 1].time < CurrentTick) {
        //     auto curr = EventsPerTick(CurrentTick);
        //     ticks.InsertLast(curr);
        //     startnew(_CleanUpPriorTick);
        //     return curr;
        // }
        // return ticks[ticks.Length - 1];
    }

    void _ArchivePriorTick(EventsPerTick@ ept) {
        auto ltRows = ept.PrepareTickRows();
        for (uint i = 0; i < ltRows.Length; i++) {
            auto row = ltRows[ltRows.Length - i - 1];
            allPastRows.InsertLast(row);
        }
    }

    CustomEvent@[] capturedQueue = {};

    void _RecordCaptured(CustomEvent@ event) {
        capturedQueue.InsertLast(event);
        // events.InsertLast(event);
        // eventSources[tostring(event.source)] = true;
        // eventTypes[event.type] = true;
        // _FilterAddEvent(event);
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

    void CaptureMLScriptEvent(CGameManialinkScriptEvent@ event) {
        if (!ShouldCapture) return;
        string[] data = {tostring(event.KeyCode), event.KeyName, event.CharPressed, event.ControlId, tostring(event.MenuNavAction), event.IsActionAutoRepeat ? 't' : 'f', event.CustomEventType, FastBufferWStringToString(event.CustomEventData), event.PluginCustomEventType, FastBufferWStringToString(event.PluginCustomEventData)};
        auto ce = CustomEvent("CGameManialinkScriptEvent::EType::" + tostring(event.Type), ArrStringToFastBufferWString(data), EventSource::ML_SE);
        _RecordCaptured(ce);
    }

    // todo: should actually capture some stuff but doesn't
    void CaptureMAScriptEvent(CGameManiaAppScriptEvent@ event) {
        if (!ShouldCapture) return;
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
        ticks.RemoveRange(0, ticks.Length);
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
            UI::SameLine();
            // UI::Dummy(vec2(20));
            // UI::SameLine();
            // f_excludeMLHookEvents = UI::Checkbox("Exclude MLHook Events?", f_excludeMLHookEvents);
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
            // TODO: What is it counting?
            UI::Text("Records: " + (allPastRows.Length + GetCurrentEvents().Length));
            UI::Text("Records: " + (allPastRows.Length));
            UI::Text("Records: " + (GetCurrentEvents().Length));

            if (UI::BeginTable("Events", 6, UI::TableFlags::Resizable)) {
                UI::TableSetupColumn("Time", UI::TableColumnFlags::WidthFixed, 50);
                UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthFixed, 200);
                UI::TableSetupColumn("Data", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Source", UI::TableColumnFlags::WidthFixed, 120);
                UI::TableSetupColumn("Repeats", UI::TableColumnFlags::WidthFixed, 50);
                UI::TableSetupColumn("Actions", UI::TableColumnFlags::WidthFixed, 230);
                UI::TableHeadersRow();

                auto activeTick = ticks.Length == 0 ? null : ticks[ticks.Length - 1];
                uint priorRows = allPastRows.Length;
                array<EventRow@> @activePrepped = activeTick is null ? array<EventRow@>() : activeTick.PrepareTickRows();
                uint activeRows = activePrepped.Length;
                // uint activeRows = 0;
                uint tableRows = activeRows + priorRows;
                if (activeRows > 0 || activePrepped.Length > 0)
                    print("activeRows: " + activeRows + " and prepped len: " + activePrepped.Length + ' activeTick is null? ' + (activeTick is null ? 'y' : 'n'));
                uint lastTime = 0;

                UI::ListClipper clipper(tableRows);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        EventRow@ row;
                        auto ix = i;
                        if (i >= int(activeRows)) {
                            @row = allPastRows[allPastRows.Length - 1 - i + activeRows];
                        } else {
                            if (i >= int(activePrepped.Length)) {
                                continue;
                            }
                            @row = activePrepped[activeRows - 1 - i];
                        }

                        UI::PushID(row.ce);  // neat; didn't know about this
                        UI::TableNextRow();

                        UI::TableNextColumn();
                        if (lastTime != row.ept.time) {
                            UI::Text(Time::Stamp - row.ept.time + " s");
                            lastTime = row.ept.time;
                        }

                        auto event = row.ce;

                        UI::TableNextColumn();
                        UI::Text(row.row[0]);

                        UI::TableNextColumn();
                        UI::Text(row.row[1]);

                        UI::TableNextColumn();
                        UI::Text(row.row[2]);

                        UI::TableNextColumn();
                        UI::Text(row.row[3]);

                        // tick.DrawButtons
                        UI::TableNextColumn();
                        if (UI::Button(Icons::Clipboard + " Type")) {
                            IO::SetClipboard(event.s_type);
                        }
                        UI::SameLine();
                        if (UI::Button(Icons::Clipboard + " Data")) {
                            IO::SetClipboard(event.ToString(true));
                        }
                        UI::SameLine();
                        if (UI::Button(Icons::Clipboard + " All")) {
                            IO::SetClipboard(event.ToString());
                        }
                        UI::SameLine();
                        if (event.layer !is null && UI::Button(Icons::Cube + " Layer Nod")) {
                            ExploreNod(event.layer);
                        }
                        UI::SameLine();
                        if (event.handle !is null && UI::Button(Icons::Cube + " Handle Nod")) {
                            ExploreNod(event.handle);
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
