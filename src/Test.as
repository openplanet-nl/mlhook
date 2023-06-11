#if DEV

void Test_RegisterEditorCallbacks() {
	// MLHook::RegisterPlaygroundMLExecutionPointCallback(Test_CheckPMTItems);
}

void Test_CheckPMTItems(ref@ processedData) {
	if (PluginMapType is null) return;
	auto pmt = PluginMapType;
	trace("PMT.Items count: " + pmt.Items.Length);
	if (pmt.Items.Length > 0) {
		auto i = pmt.Items[0];
		trace("first item position: " + i.Position.ToString());
	}
}




#endif