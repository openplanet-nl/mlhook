void dev_trace(const string &in msg) {
#if DEV
	trace(msg);
#endif
}

[Setting category="Logging" name="Pass logs from ML through to Openplanet logs"]
#if DEV
bool S_PassThroughMLLogs = true;
#else
bool S_PassThroughMLLogs = false;
#endif

string[] logMsgsFromML;

void ml_log(const string &in msg) {
	logMsgsFromML.InsertLast(formatMlLogMsg(msg));
	if (S_PassThroughMLLogs) {
		trace(msg);
	}
}

string formatMlLogMsg(const string &in msg) {
	return (Time::FormatString("\\$888(%H:%M:%S)\\$z ", Time::Stamp) + msg).Replace("\n", "\\n");
}

bool g_LogsWindowOpen = false;

void RenderLogsWindow() {
	if (!g_LogsWindowOpen) return;
	UI::SetNextWindowSize(500, 400, UI::Cond::FirstUseEver);
	if (UI::Begin("MLHook Logs", g_LogsWindowOpen)) {
		if (logMsgsFromML.Length == 0) {
			UI::Text("No logs");
		} else {
			UI::ListClipper clip(logMsgsFromML.Length);
			while (clip.Step()) {
				for (uint i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
					UI::Text(logMsgsFromML[i]);
				}
			}
		}
	}
	UI::End();
}

void RenderLogsMenuItem() {
	if (UI::MenuItem("Logs (from Injected ML)", "", g_LogsWindowOpen)) {
		g_LogsWindowOpen = !g_LogsWindowOpen;
	}
}
