/* tooltips */

void AddSimpleTooltip(const string &in msg)
{
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}

// /* padding */

void VPad()
{
    UI::Dummy(vec2(0, 2));
}
