# NS: MLHook



## Functions

### DebugLogAllHook -- `DebugLogAllHook@ DebugLogAllHook(const string &in eventType)`

### HookMLEventsByType -- `HookMLEventsByType@ HookMLEventsByType(const string &in typeToHook)`

### InjectManialinkToEditor -- `void InjectManialinkToEditor(const string &in PageUID, const string &in ManialinkPage, bool replace = false)`

Inject a ML page to editor.PluginMapType. The page name will be MLHook_PageUID.

### InjectManialinkToMenu -- `void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false)`

Inject a ML page to the menu. The page name will be MLHook_PageUID.

### InjectManialinkToPlayground -- `void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false)`

Inject a ML page to the playground. The page name will be MLHook_PageUID.

### MLFeed -- `MLFeed@ MLFeed(const string &in typeToDistribute)`

### MLFeedFunction -- `MLFeedFunction@ MLFeedFunction(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```

### MLFeedFunctionRaw -- `MLFeedFunctionRaw@ MLFeedFunctionRaw(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```


### PendingEvent -- `PendingEvent@ PendingEvent(const string &in _t, MwFastBuffer<wstring> &in _d)`

### PlaygroundMLExecutionPointFeed -- `PlaygroundMLExecutionPointFeed@ PlaygroundMLExecutionPointFeed()`

### Queue_Editor_SendCustomEvent -- `void Queue_Editor_SendCustomEvent(const string &in type, string[] &in data = {})`

Queue an event to send via the Menu's SendCustomEvent

### Queue_Editor_SendCustomEvent -- `void Queue_Editor_SendCustomEvent(const string &in type, string[] &in data = {})`

Queue an event to send via Editor.PluginMapType's SendCustomEvent

### Queue_Menu_SendCustomEvent -- `void Queue_Menu_SendCustomEvent(const string &in type, string[] &in data = {})`

Queue an event to send via a Menu ScriptHandler's SendCustomEvent

### Queue_MessageManialinkEditor -- `void Queue_MessageManialinkEditor(const string &in PageUID, const string &in msg)`

queue a message to a page in editor.PluginMapType with the given PageUID

### Queue_MessageManialinkEditor -- `void Queue_MessageManialinkEditor(const string &in PageUID, string[] &in msgs)`

queue messages to a page in editor.PluginMapType with the given PageUID

### Queue_MessageManialinkMenu -- `void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg)`

queue a message to a page in the menu with the given PageUID

### Queue_MessageManialinkMenu -- `void Queue_MessageManialinkMenu(const string &in PageUID, string[] &in msgs)`

queue messages to a page in the menu with the given PageUID

### Queue_MessageManialinkPlayground -- `void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg)`

queue a message to a page with the given PageUID

### Queue_MessageManialinkPlayground -- `void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs)`

queue messages to a page with the given PageUID

### Queue_MessageManialinkPlaygroundServer -- `void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, const string &in msg)`

queue a message to an ML page on the game server (via netwrite) with the given PageUID

### Queue_MessageManialinkPlaygroundServer -- `void Queue_MessageManialinkPlaygroundServer(const string &in PageUID, string[] &in msgs)`

queue messages to an ML page on the game server (via netwrite) with the given PageUID

### Queue_PG_SendCustomEvent -- `void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {})`

Queue an event to send via the Playground's SendCustomEvent

### Queue_SH_SendCustomEvent -- `void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {})`

Queue an event to send via a Playground ScriptHandler's SendCustomEvent

### Queue_SendCustomEvent -- `void Queue_SendCustomEvent(const string &in type, string[] &in data = {})`

*Deprecated* Queue an event to send via the Playground's SendCustomEvent

### Queue_ToInjectedManialink -- `void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg)`

deprecated in favor of Queue_MessageManialinkPlayground

### RegisterMLHook -- `void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false)`

Register a hook object to recieve events of the specified type (or the default for that page). The MLHook_Event_ prefix is automatically applied, except if isNadeoEvent is true

### RegisterPlaygroundMLExecutionPointCallback -- `void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func)`

Warning:* Experimental.

Register a function to be called during ML execution each frame. Note that the argument to the callback will always be null.

Note that no way to remove these functions exists yet.

### RemoveAllInjectedML -- `void RemoveAllInjectedML()`

uninject all your plugins ML pages

### RemoveInjectedMLFromEditor -- `void RemoveInjectedMLFromEditor(const string &in PageUID)`

Remove an injected ML page with the given PageUID from editor.PluginMapType

### RemoveInjectedMLFromMenu -- `void RemoveInjectedMLFromMenu(const string &in PageUID)`

Remove an injected ML page with the given PageUID from the menu

### RemoveInjectedMLFromPlayground -- `void RemoveInjectedMLFromPlayground(const string &in PageUID)`

Remove an injected ML page with the given PageUID from the playground

### RequireVersionApi -- `void RequireVersionApi(const string &in versionReq)`

Deprecated. The intent was to ensure MLHook's api was compatible, but breaking changes are not expected any longer

### ToMLScript -- `string ToMLScript(const string &in src)`

Convert Maniascript code to an ML page

### UnregisterMLHookFromAll -- `void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj)`

Unregister a hook object

### UnregisterMLHooksAndRemoveInjectedML -- `void UnregisterMLHooksAndRemoveInjectedML()`

Unregister all of your plugins hooks and uninject ML pages (call in `OnDisabled` and `OnDestroyed`)

This is the preferred way to unregister injections and hooks -- auto-detects the calling plugin.

## Properties

### DebugPrefix -- `const string DebugPrefix`

### EditorHookEventName -- `const string EditorHookEventName`

### EventPrefix -- `const string EventPrefix`

### GlobalPrefix -- `const string GlobalPrefix`

### LogMePrefix -- `const string LogMePrefix`

### MenuHookEventName -- `const string MenuHookEventName`

### NetQueuePrefix -- `const string NetQueuePrefix`

### PlaygroundHookEventName -- `const string PlaygroundHookEventName`

note: hardcoded in PlaygroundMLExecutionPointFeed

### QueuePrefix -- `const string QueuePrefix`

### Version -- `const string Version`

### _EditorHookEventName -- `const string _EditorHookEventName`

### _EventPrefix -- `const string _EventPrefix`

### _ML_Hook_Feed -- `PlaygroundMLExecutionPointFeed _ML_Hook_Feed`

### _MenuHookEventName -- `const string _MenuHookEventName`

### _PlaygroundHookEventName -- `const string _PlaygroundHookEventName`

### versionsAlsoCompatible -- `array<string> versionsAlsoCompatible`

# Types/Classes

## MLHook::DebugLogAllHook (class)

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### type -- `const string type`



## MLHook::HookMLEventsByType (class)

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### type -- `const string type`



## MLHook::MLFeed (class)

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### Preprocess -- `ref@ Preprocess(MwFastBuffer<wstring> &in data)`

#### RegisterCallback -- `void RegisterCallback(MLFeedFunction@ cb)`

### Properties

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### callbackPlugins -- `array<Meta::Plugin> callbackPlugins`

#### callbackRawPlugins -- `array<Meta::Plugin> callbackRawPlugins`

#### callbacks -- `array<MLFeedFunction> callbacks`

#### callbacksRaw -- `array<MLFeedFunctionRaw> callbacksRaw`

#### type -- `const string type`



## MLHook::MLFeedFunction (class)

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```




## MLHook::MLFeedFunctionRawx (class)

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```







## MLHook::PendingEvent (class)



### Properties

#### data -- `MwFastBuffer<wstring> data`

#### type -- `string type`



## MLHook::PlaygroundMLExecutionPointFeed (class)

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### Preprocess -- `ref@ Preprocess(MwFastBuffer<wstring> &in data)`

#### Preprocess -- `ref@ Preprocess(MwFastBuffer<wstring> &in data)`

#### RegisterCallback -- `void RegisterCallback(MLFeedFunction@ cb)`

### Properties

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### callbackPlugins -- `array<Meta::Plugin> callbackPlugins`

#### callbackRawPlugins -- `array<Meta::Plugin> callbackRawPlugins`

#### callbacks -- `array<MLFeedFunction> callbacks`

#### callbacksRaw -- `array<MLFeedFunctionRaw> callbacksRaw`

#### type -- `const string type`



## MLHook::Queue_MessageManialinkPlayground (class)

```angelscript_snippet
funcdef void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs);
```







## MLHook::Queue_PG_SendCustomEvent (class)

```angelscript_snippet
funcdef void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {});
```







## MLHook::RegisterPlaygroundMLExecutionPointCallback (class)

```angelscript_snippet
funcdef void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func);
```







## MLHook::RemoveAllInjectedML (class)

```angelscript_snippet
funcdef void RemoveAllInjectedML();
```







## MLHook::ToMLScript (class)

```angelscript_snippet
funcdef string ToMLScript(const string &in ManialinkPage);
```
