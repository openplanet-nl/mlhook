[Setting category="Demo"]
bool Setting_DemoEnabled = false;

void RenderDemoUI() {
    if (!Setting_DemoEnabled) return;
    if (UI::Begin("ghost test button", Setting_DemoEnabled, UI::WindowFlags::AlwaysAutoResize)) {
        if (UI::Button("run ghost test")) {
            RunGhostTest();
        }
        if (UI::Button("run ghost test async")) {
            startnew(RunGhostTest);
        }
        if (UI::Button("change opponents")) {
            eventQueue.InsertLast(CustomEvent("RaceMenuEvent_ChangeOpponents"));
        }
        if (UI::Button("playmap-endracemenu-save-replay")) {
            eventQueue.InsertLast(CustomEvent("playmap-endracemenu-save-replay"));
        }
        if (UI::Button("Close window")) { Setting_DemoEnabled = false; }
    }
    UI::End();
}
