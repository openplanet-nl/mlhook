#if TMNEXT

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
#if DEV
		UI::Separator();
		if (UI::Button('test notification')) {
			// UI::ShowNotification("MLHook Panic Mode", "MLHook encountered a serious error and is terminating for your safety.", vec4(.3, .3, .1, .2));
			PanicMode::__PanicModeNotification("test notification");
		}
		if (UI::Button('test panic mode')) {
			PanicMode::TestPanicMode();
		}
		if (UI::Button('test todo')) {
			NotifyTodo("implement something");
		}
#endif
	}
	UI::End();
}


void RunGhostTest() {
	if (targetSH is null) {
		UI::ShowNotification("toggle ghost", "targetSH is null == true");
		return;
	}
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"da4642f9-6acf-43fe-88b6-b120ff1308ba"}));
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"8d90f6c6-5a03-4fd3-8026-791c4d7404db"}));
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"41122fb7-f264-448e-9660-a418f438e58b"}));
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"1336b019-0d7d-43f7-b227-ff336f8b7140"}));
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"2a13aa7d-992d-4a7c-a3c5-d29b08b7f8cb"}));
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"7ccc9d81-bc43-4faa-b454-46bed6b6d4f5"}));
	SH_SCE_EventQueue.InsertLast(CustomEvent("TMxSM_Race_Record_ToggleGhost", {"aca96daf-0fda-4496-9887-22e616d8a481"}));
}

#else

void RenderDemoUI() {}

#endif
