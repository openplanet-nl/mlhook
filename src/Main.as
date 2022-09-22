CGameDataFileManagerScript@ LastUsedDfm;

void Main() {
    @LastUsedDfm = GetAccessibleDataFileMgr();
#if DEV
    // we don't need intercepts, but this helped determine that the accessible DataFileMgr was okay to use and mb is useful for monitoring game usage of the API
    Dev::InterceptProc("CGameDataFileManagerScript", "Media_RefreshFromDisk", _Media_RefreshFromDisk);
    Dev::InterceptProc("CGameDataFileManagerScript", "Map_RefreshFromDisk", _Map_RefreshFromDisk);
    Dev::InterceptProc("CGameDataFileManagerScript", "Replay_RefreshFromDisk", _Replay_RefreshFromDisk);
    Dev::InterceptProc("CGameDataFileManagerScript", "UserSave_DeleteFile", _UserSave_DeleteFile);
    Dev::InterceptProc("CGameDataFileManagerScript", "Replay_Save", _Replay_Save);
    Dev::InterceptProc("CGameDataFileManagerScript", "Replay_Author_Save", _Replay_Author_Save);
    Dev::InterceptProc("CGameDataFileManagerScript", "Campaign_Get", _Campaign_Get);
    Dev::InterceptProc("CGameDataFileManagerScript", "Replay_Load", _Replay_Load);
#endif
}

// list media types
const CGameDataFileManagerScript::EMediaType[] mediaTypes =
    { CGameDataFileManagerScript::EMediaType::Image
    , CGameDataFileManagerScript::EMediaType::Sound
    , CGameDataFileManagerScript::EMediaType::Script
    , CGameDataFileManagerScript::EMediaType::MatchSettings
    , CGameDataFileManagerScript::EMediaType::Skins
    , CGameDataFileManagerScript::EMediaType::ItemCollection
    };

/* from: Titles/Trackmania/Scripts/Libs/Nadeo/TMNext/TrackMania/Menu/Constants.Script.txt
> #Const C_BrowserFilter_GameData 1
> #Const C_BrowserFilter_TitleData 2
> #Const C_BrowserFilter_GameAndTitleData 3
> #Const C_BrowserFilter_UserData 4
> #Const C_BrowserFilter_AllData 7
*/
enum EMediaScope
    { GameData = 1
    , TitleData = 2
    , GameAndTitleData = 3
    , UserData = 4
    , AllData = 7
    }

// list media scopes
const EMediaScope[] mediaScopes =
    { EMediaScope::GameData
    , EMediaScope::TitleData
    , EMediaScope::GameAndTitleData
    , EMediaScope::UserData
    , EMediaScope::AllData
    };

void RenderMenuMain() {
    bool enableMenu = LastUsedDfm !is null
        && GetApp().RootMap is null;
#if DEV
    auto l = Safety.Lock('DataFileMgr');
    if (l is null) {
        enableMenu = false;
        warn('Failed to get safety lock for DataFileMgr');
    }
#endif
    if (UI::BeginMenu("Refresh Data", enableMenu)) {
        RM_Singletons();
        UI::Separator();
        for (uint i = 0; i < mediaTypes.Length; i++) {
            auto item = mediaTypes[i];
            RM_MediaType(item);
        }
        UI::EndMenu();
    }
#if DEV
    l.Unlock();
#endif
}

void RM_Singletons() {
    if (UI::MenuItem("Maps")) {
        LastUsedDfm.Map_RefreshFromDisk();
        NotifyRefresh("Refreshed Maps");
    }
    if (UI::MenuItem("Replays")) {
        LastUsedDfm.Replay_RefreshFromDisk();
        NotifyRefresh("Refreshed Replays");
    }
    if (UI::MenuItem("All Media")) {
        for (uint i = 0; i < mediaTypes.Length; i++) {
            auto item = mediaTypes[i];
            LastUsedDfm.Media_RefreshFromDisk(item, uint(EMediaScope::AllData));
        }
        NotifyRefresh("Refreshed all media types with scope " + tostring(EMediaScope::AllData));
    }
}

void RM_MediaType(CGameDataFileManagerScript::EMediaType &in mt) {
    if (UI::BeginMenu(tostring(mt), true)) {
        for (uint i = 0; i < mediaScopes.Length; i++) {
            auto item = mediaScopes[i];
            RM_MediaScope(mt, item);
        }
        UI::EndMenu();
    }
}

void RM_MediaScope(CGameDataFileManagerScript::EMediaType &in mt, EMediaScope &in scope) {
    if (UI::MenuItem(tostring(scope) + "##" + tostring(mt))) {
        LastUsedDfm.Media_RefreshFromDisk(mt, uint(scope));
        NotifyRefresh("Refreshed " + tostring(mt) + " with scope " + tostring(scope));
        trace('Called: DataFileMgr.Media_RefreshFromDisk(' + tostring(mt) + ', ' + tostring(scope) + ')');
    }
}

CGameDataFileManagerScript@ GetAccessibleDataFileMgr() {
    try {
        auto app = cast<CTrackMania>(GetApp());
        auto dfm = app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr;
        if (dfm is null) throw('DataFileMgr is null');
        return dfm;
    } catch {
        NotifyError("Error accessing DataFileMgr: " + getExceptionInfo());
        return null;
    }
}

void NotifyRefresh(const string &in msg) {
    UI::ShowNotification("Refresh Media", msg, vec4(.2, .6, .3, .3), 3000);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification("Refresh Media", msg, vec4(.9, .6, .1, .5), 7500);
}

// [SettingsTab name="General"]
// void RenderMediaRefersherSettings() {
//     UI::Text("settings");
// }
