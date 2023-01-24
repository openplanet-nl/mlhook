# NS: MLHook



## Functions

### DebugLogAllHook -- `DebugLogAllHook@ DebugLogAllHook(const string &in eventType)`

### HookMLEventsByType -- `HookMLEventsByType@ HookMLEventsByType(const string &in typeToHook)`

### InjectManialinkToMenu -- `void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false)`

### InjectManialinkToPlayground -- `void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false)`

### MLFeed -- `MLFeed@ MLFeed(const string &in typeToDistribute)`

### MLFeedFunction -- `MLFeedFunction@ MLFeedFunction(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```

### MLFeedFunction -- `MLFeedFunction@ MLFeedFunction(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```

### MLFeedFunction -- `MLFeedFunction@ MLFeedFunction(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```

### MLFeedFunctionRaw -- `MLFeedFunctionRaw@ MLFeedFunctionRaw(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```

### MLFeedFunctionRaw -- `MLFeedFunctionRaw@ MLFeedFunctionRaw(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```

### MLFeedFunctionRaw -- `MLFeedFunctionRaw@ MLFeedFunctionRaw(Function@ func)`

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```

### PendingEvent -- `PendingEvent@ PendingEvent(const string &in _t, MwFastBuffer<wstring> &in _d)`

### PlaygroundMLExecutionPointFeed -- `PlaygroundMLExecutionPointFeed@ PlaygroundMLExecutionPointFeed()`

### Queue_Menu_SendCustomEvent -- `void Queue_Menu_SendCustomEvent(const string &in type, string[] &in data = {})`

### Queue_MessageManialinkMenu -- `void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg)`

### Queue_MessageManialinkMenu -- `void Queue_MessageManialinkMenu(const string &in PageUID, string[] &in msgs)`

### Queue_MessageManialinkPlayground -- `void Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg)`

### Queue_MessageManialinkPlayground -- `void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs)`

### Queue_PG_SendCustomEvent -- `void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {})`

### Queue_SH_SendCustomEvent -- `void Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {})`

### Queue_SendCustomEvent -- `void Queue_SendCustomEvent(const string &in type, string[] &in data = {})`

### Queue_ToInjectedManialink -- `void Queue_ToInjectedManialink(const string &in PageUID, const string &in msg)`

### RegisterMLHook -- `void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false)`

### RegisterPlaygroundMLExecutionPointCallback -- `void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func)`

note: callback arg is always null

### RemoveAllInjectedML -- `void RemoveAllInjectedML()`

### RemoveInjectedMLFromMenu -- `void RemoveInjectedMLFromMenu(const string &in PageUID)`

### RemoveInjectedMLFromPlayground -- `void RemoveInjectedMLFromPlayground(const string &in PageUID)`

### RequireVersionApi -- `void RequireVersionApi(const string &in versionReq)`

### ToMLScript -- `string ToMLScript(const string &in src)`

### UnregisterMLHookFromAll -- `void UnregisterMLHookFromAll(HookMLEventsByType@ hookObj)`

### UnregisterMLHooksAndRemoveInjectedML -- `void UnregisterMLHooksAndRemoveInjectedML()`

## Properties

### DebugPrefix -- `const string DebugPrefix`

### EventPrefix -- `const string EventPrefix`

### GlobalPrefix -- `const string GlobalPrefix`

}

### LogMePrefix -- `const string LogMePrefix`

### MenuHookEventName -- `const string MenuHookEventName`

### PlaygroundHookEventName -- `const string PlaygroundHookEventName`

note: hardcoded in PlaygroundMLExecutionPointFeed

### QueuePrefix -- `const string QueuePrefix`

### Version -- `const string Version`

### _ML_Hook_Feed -- `PlaygroundMLExecutionPointFeed _ML_Hook_Feed`

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



## MLHook::InjectManialinkToMenu (class)

```angelscript_snippet
funcdef void InjectManialinkToMenu(const string &in PageUID, const string &in ManialinkPage, bool replace = false);
```







## MLHook::InjectManialinkToPlayground (class)

```angelscript_snippet
funcdef void InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false);
```







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







## MLHook::MLFeedFunction (class)

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```







## MLHook::MLFeedFunction (class)

```angelscript_snippet
funcdef void MLFeedFunction(ref@ processedData);
```







## MLHook::MLFeedFunctionRaw (class)

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```







## MLHook::MLFeedFunctionRaw (class)

```angelscript_snippet
funcdef void MLFeedFunctionRaw(MwFastBuffer<wstring> &in data);
```







## MLHook::MLFeedFunctionRaw (class)

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



## MLHook::Queue_Menu_SendCustomEvent (class)

```angelscript_snippet
funcdef void Queue_Menu_SendCustomEvent(const string &in type, string[] &in data = {});
```







## MLHook::Queue_MessageManialinkM (class)

```angelscript_snippet
funcdef void Queue_MessageManialinkM(const string &in PageUID, const string &in msg);
```







## MLHook::Queue_MessageManialinkMenu (class)

```angelscript_snippet
funcdef void Queue_MessageManialinkMenu(const string &in PageUID, const string &in msg);
```







## MLHook::Queue_MessageManialinkPlayground (class)

```angelscript_snippet
funcdef void Queue_MessageManialinkPlayground(const string &in PageUID, string[] &in msgs);
```







## MLHook::Queue_PG_SendCustomEvent (class)

```angelscript_snippet
funcdef void Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {});
```







## MLHook::Queue_SendCustomEvent (class)

```angelscript_snippet
funcdef void Queue_SendCustomEvent(const string &in type, string[] &in data = {});
```







## MLHook::RegisterMLHook (class)

```angelscript_snippet
funcdef void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false);
```







## MLHook::RegisterPlaygroundMLExecutionPointCallback (class)

```angelscript_snippet
funcdef void RegisterPlaygroundMLExecutionPointCallback(MLFeedFunction@ func);
```







## MLHook::RemoveInjectedMLFromPlayground (class)

```angelscript_snippet
funcdef void RemoveInjectedMLFromPlayground(const string &in PageUID);
```







## MLHook::ToMLScript (class)

```angelscript_snippet
funcdef string ToMLScript(const string &in ManialinkPage);
```
