bool _CheckForEvents(CMwStack &in stack)
{
    if (PanicMode::IsActive) return true;
    try {
        CheckForPendingEvents();
        return true;
    } catch {
        PanicMode::Activate("Exception in _CheckForEvents: " + getExceptionInfo());
        return true;
    }
}
