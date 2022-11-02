# MLHook -- Manialink Hook Library & Event Inspector

### For Users:

You may need to install this plugin as a dependency for another plugin that you want to use.
In that case, you can install and forget -- it'll operate silently the background.
That's all you need to know, but read on if you're curious.

### For Everyone:

MLHook is a dependency plugin (for use by other plugins) to enable running code at the same time as Manialink does.
It is also a developer tool used to inspect all Custom Events. (You must have the developer signature mode enabled.)

As a dependency, MLHook lets plugins interact with game elements that would not otherwise be possible, and send Custom Events that would otherwise not be possible.

**Please report performance issues!** See "About" for who/where.

### For Devs:

#### Status: Public Beta and RFC, mostly stable API

Current Features:

* Send events to Nadeo ML via `CGameManialinkScriptHandler.SendCustomEvent` (e.g., to display a ghost) or the playground's `SendCustomEvent` function.
* Inject manialink code to read state from game objects or modify state (e.g., to trigger refreshing records)
  * Two-way messaging possible.
  * Scrape ML data of the form `declare (netread) [Type] [Name] for [GameObject]` and pass back to AngelScript
	* Receive messages from ML code via events using the `MLHook::HookMLEventsByType` base class. (see `src/Exports/ExportShared.as`)
	* Sent to ML code via `MLHook::Queue_MessageManialinkPlayground(PageUID, {"Command_Blah", "Arg_Foo"})` (see `src/ExportCode.as` via `src/Exports/Export.as`)
    * We don't use custom events while sending to maniascript to avoid scope / clobbering issues, and avoid duplicating all messages to all ML scripts.

*(Note: additionally, see the section at the bottom)*

[Suggestions/feedback requested!](https://github.com/XertroV/tm-ml-to-angelscript-hook/issues)
* Is the API bad or missing something?
* Any features that would let you do things you can't atm?
* What manialink elements would you interact with that you can't?
* Do you want to inject manialink code?
* Anything else?


### Acknowledgements

This plugin is only possible due to many prior efforts and a lot of trial and error.
This is a non-exhaustive list of those who are owed partial credit and appreciation:
* skybaxrider
* thommie
* zer0detail
* Miss
* nbert

### About

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-ml-to-angelscript-hook](https://github.com/XertroV/tm-ml-to-angelscript-hook)

GL HF

## For Developers

MLHook currently allows 2-way comms between AS and ML.

Also, the use of `SendCustomEvent` on script handlers without crashing the game.
In general, sending custom events seems to be fine when `.Page` is not null -- which it always is during the typical times that AngelScript runs.
As far as I can tell, `.Page` is only not-null when Manialink code is executing, and even then, not all of the time.

For an example of how to use MLHook, see [MLFeed: Race Data](https://github.com/XertroV/tm-mlfeed-race-data).

Examples of usage:
* [Race Stats](https://github.com/XertroV/tm-race-stats/blob/master/src/Main.as)
* [Autosave Ghosts](https://github.com/XertroV/tm-autosave-ghosts/blob/cd3c21f7b51e27a25755ed6f992a62100962b4a4/src/Main.as)

### Usage:

Add this to your `info.toml`:

```toml
[script]
dependencies = [ 'MLHook' ]
```

Send `CGameManialinkScriptHandler` Custom Events via:

```AngelScript
void MLHook::Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {})
void MLHook::Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {})
```

Inject Manialink code to react to msgs from MLHook (which are independent of TM's script events).

```AngelScript
void MLHook::InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false)
void MLHook::Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg)
void MLHook::RemoveInjectedMLFromPlayground(const string &in PageUID)
```

To run code whenever an event with a particular type is detected:

```AngelScript
void MLHook::RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "")
void MLHook::UnregisterMLHookFromAll(HookMLEventsByType@ hookObj)
```

To safely unload injected ML and hooks when your plugin is unloaded, add this to `Main.as` (or wherever):

```AngelScript
void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload() {
    trace('_Unload, unloading all hooks and removing all injected ML');
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}
```

Example using injected ML to refresh records: https://github.com/XertroV/tm-somewhat-better-records/blob/master/src/Main.as


#### Tips re ML Injection

You'll probably to recover from compile/syntax error:
- on script error page, press ctrl+g to get rid of overlay
- wait for "recovery restart" to come up (press okay when it does)
- after a second the UI should have reloaded, then you can reload the plugin to try your new changes.

While developing, the manialink linter is very very useful to avoid wasting time waiting for recovery restart b/c you left out a `;` or something.


--------------
<!-- below not in OP description-->

<!-- todo: better inputs via ML_SE / InputSE? -->

#### ML Script Hierarchy

(Note: input from someone more familiar with Maniascript would be appreciated)
Events seem to propagate up, like a PlaygroundScriptHandler event gets sent to the ManiaAppPlayground handler too.

(todo)


## Changelog

- v0.3.3
  -
- v0.3.2
  - fix null pointer exception in hook router (rare edge case)
  - enable routing all custom events from script handler/playground (e.g., `CustomEvent(TMxSM_Race_Record_NewRecord, {"48260"}, Source=PG_SendCE)`). To hook these game events:
    - specify the full event name when creating the hook
    - specify `isNadeoEvent` as `true` when calling `void RegisterMLHook(HookMLEventsByType@ hookObj, const string &in type = "", bool isNadeoEvent = false)`
    - layer custom events not supported due to performance impact (there are potentially 100s of these on some frames b/c they're propagated through many ML elements)
- v0.3.1
  - fix export issue
- v0.3.0
  - breaking change WRT hooks (`OnEvent`) to improve overhead of distributing data -- `OnEvent` now takes an `MLHook::PendingEvent@ event` with attrs: `.type` and `.data`.
  - performance improvements WRT HookRouter

- v0.2.0
  - breaking change re ML receiving msgs from MLHook `Text[][]` now instead of `Text[]` so more than one string can be sent.
  - breaking change re injected ML: should not be wrapped in `<script><!--`, `--></script>` anymore.
  - added exported `DebugLogAllHook` utility class
  - fix crash due to mismatching preprocessor conditions and changes to the way some events can be accessed

- v0.1.5-0.1.8
  - Add cleanup of injected ML on plugin unload
  - Improve UILayer browser
  - API for getting a feed of data
  - avoid exposing dangerous developer tools to typical users

- v0.1.4
  - API braking change in prep for supporting multiple injection/communication contexts: playground, menu, editor, etc. Each requires its own monitoring loop, etc.
  - More events gathered now (when they come from PendingEvents there are lots of duplicates, tho)
  - Inspector improvements: menu item, filters
  - Added some safety features, but won't help with all cases b/c some crashes aren't due to stuff we can `try{}catch{}`
  - Added a `RequireVersionApi` that will send a notification & block indefinitely if MLHook is of the wrong version (ideally this can be used to avoid issues when MLHook updates)

- v0.1.3
  - fix injection of ML code so that it is repeated on new playground loads

- v0.1.1-2
  - mostly regarding consistency of injection and communication
