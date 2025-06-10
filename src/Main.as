CGameDataFileManagerScript@ LastUsedDfm;

void Main()
{
	HookManialinkCode();
	startnew(MainCoro);
	startnew(HookRouter::MainCoro);
#if SIG_DEVELOPER
	startnew(EventInspector::MainCoro); // note: does nothing as of 2022-09-27
#endif
#if DEV
	Test_RegisterEditorCallbacks();
#endif
}

void _Unload()
{
	RemoveAllInjections();
}
void OnDisabled()
{
	_Unload();
}
void OnEnabled() {}
void OnDestroyed()
{
	_Unload();
}

void MainCoro()
{
	while (true) {
		yield();
		yield();
		// Currently supported mania apps:
		//   Playground, Menu, Editor.PluginMapType (different from editor itself)
		// data injections for supported mania apps
		RunPendingInjections();
		RunPendingMenuInjections();
		RunPendingEditorInjections();
		// data injections for supported mania apps
		RunQueuedMLDataInjections();
		RunQueuedMenuMLDataInjections();
		RunQueuedEditorMLDataInjections();
	}
}

void Render()
{
	RenderDemoUI(); // only when setting enabled
}

void RenderInterface()
{
	RenderLogsWindow();
#if SIG_DEVELOPER
	EventInspector::RenderEventInspectorWindow();
	LayersBrowser::RenderInterface();
#endif
}

void RenderMenuMain()
{
	EventInspector::RenderMenuMainCapturingNotice(); // since this is a notice that only shows up when capturing is active, better to have it show up than not if it is somehow enabled
}

void RenderMenu()
{
	if (UI::BeginMenu(Icons::PhoneSquare + " MLHook")) {
		RenderLogsMenuItem();
#if SIG_DEVELOPER
		EventInspector::RenderEventInspectorMenuItem();
		LayersBrowser::RenderMenu();
#endif
		UI::EndMenu();
	}
}

void NotifyError(const string &in msg)
{
	warn(msg);
	UI::ShowNotification("MLHook Error", msg, vec4(.9, .6, .1, .5), 7500);
}

void NotifyTodo(const string &in msg)
{
	warn('Todo: ' + msg);
	UI::ShowNotification("MLHook Todo", msg, vec4(.5, .6, .3, .5), 7500);
}

void NotifyVersionIssue(const string &in msg)
{
	warn(msg);
	UI::ShowNotification("MLHook Version Issue", msg, vec4(.9, .6, .3, .5), 20000);
}

/**
	game api stuff

	NOTE!! This method (global getters) for game objects is **NOT** recommended.
	It makes plugin review much harder.
	Rather, you should call `GetApp()` within the function in which you're using it.
	If you want helper functions, have the functions take a CGameManiaPlanet@ and return the Nod@ that you want to access.

*/

// The app
CGameManiaPlanet@ get_app()
{
	return cast<CGameManiaPlanet>(GetApp());
}

//
bool get_IsLoadingScreenActive()
{
	return app.LoadProgress.State == NGameLoadProgress::EState::Displayed;
}

// app.Network.ClientManiaAppPlayground
CGameManiaAppPlayground@ get_cmap()
{
	return app.Network.ClientManiaAppPlayground;
}

// app.Network.ClientManiaAppPlayground.Input
CInputScriptManager@ get_InputMgr()
{
	return cmap is null ? null : cmap.Input;
}

// app.MenuManager; no need to cast to CTrackManiaMenus
CGameCtnMenusManiaPlanet@ get_MenuMgr()
{
	return app.MenuManager;
}

// MenuCustom_CurrentManiaApp
CGameManiaAppTitle@ get_mcma()
{
	return MenuMgr.MenuCustom_CurrentManiaApp;
}

CGameCtnEditorFree@ get_editor()
{
	return cast<CGameCtnEditorFree>(app.Editor);
}

// Editor.PluginMapType
CSmEditorPluginMapType@ get_PluginMapType()
{
	if (editor is null) return null;
	return cast<CSmEditorPluginMapType>(editor.PluginMapType);
}

// true when app.Editor is null (so any editor will mean this returns false)
bool get_AppEditorIsNull()
{
	return app.Editor is null;
}
