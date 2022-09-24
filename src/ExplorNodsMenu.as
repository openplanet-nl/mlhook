void RenderMenuMainExploreNods() {
    if (UI::BeginMenu(Icons::Map + " Explore Nods")) {
        RM_Nods();
        UI::EndMenu();
    }
}

void RM_Nods() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = app.Network;
    auto cmap = network.ClientManiaAppPlayground;
    if (UI::MenuItem("app.Network")) {
        ExploreNod(network);
    }
    if (UI::MenuItem("network.ClientManiaAppPlayground", "", false, cmap !is null)) {
        ExploreNod(cmap);
    }
}
