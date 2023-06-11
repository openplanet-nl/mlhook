/* used to check if the last time we checked pending events
whether it was probably the same as it is now.
*/
class LastChecker
{
	uint lastLen = 0;
	string lastFinalEntryType;
	bool ShouldCheckAgain(uint length, const string &in finalEntryType)
	{
		return !(length == lastLen && lastFinalEntryType == finalEntryType);
	}
	void Reset()
	{
		lastLen = 0; lastFinalEntryType = "";
	}
}
