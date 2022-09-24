[Setting category="Demo"]
bool Setting_DemoEnabled = false;

void RenderDemoUI() {
    if (!Setting_DemoEnabled) return;
    if (UI::Begin("ML to AS Hook Demo", Setting_DemoEnabled, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)) {
        UI::Text("Manialink Hook Demo");
        UI::Separator();

        UI::Text("Add a selection of ghosts.");
        UI::Text("Note: this is done\\$5ad in AngelScript\\$z via .SendCustomEvent.");
        UI::Text("For best results, use TOTD for 23rd Sept 2022: \\$FC9Mi\\$FDBr\\$FEDro\\$FFFr\\$FC9W\\$FDBo\\$FEDrl\\$FFFd");
        if (!Permissions::PlayRecords()) {
            UI::Text("\\$f51Demo UI requires club access since it spawns ghosts.");
        } else {
            if (UI::Button("run ghost test")) {
                RunGhostTest();
            }
            if (UI::Button("run ghost test async")) {
                startnew(RunGhostTest);
            }
        }
        UI::Separator();
        UI::Text("In solo mode, e.g., campaign");
        if (UI::Button("change opponents")) {
            MLHook::Queue_SH_SendCustomEvent("RaceMenuEvent_ChangeOpponents");
        }
        if (UI::Button("save replay (only from menus where it's shown)")) {
            MLHook::Queue_SH_SendCustomEvent("playmap-endracemenu-save-replay");
        }
    }
    UI::End();
}
