# MLHook -- Manialink Hook Library & Event Inspector

## Status: Public Beta and RFC

**Warning: not all features are currently 100% reliable. Some work intermittently.**

**Note: some of these features will be in-progress or planned. The inspector is functional, and it is possible to send some custom events, currently.**

### For Users:

You may need to install this plugin as a dependency for another plugin that you want to use.
In that case, you can install and forget -- it'll operate silently the background.
That's all you need to know, but read on if you're curious.

### For Everyone:

MLHook is a dependency plugin (for use by other plugins) to enable running code at the same time as Manialink does.
It is also a developer tool used to inspect all Custom Events. (You must have the developer signature mode enabled.)

As a dependency, MLHook lets plugins interact with game elements that would not otherwise be possible, and send Custom Events that would otherwise not be possible.

### For Devs:

Current Features:
* Send events to Nadeo ML via `CGameManialinkScriptHandler.SendCustomEvent` (e.g., to display a ghost)
* Inject manialink and send messages to it, change ML state, etc (e.g., to refresh records)

*(Note: additionally, see the section at the bottom)*

[Suggestions/feedback requested!](https://github.com/XertroV/tm-ml-to-angelscript-hook/issues)
* Is the API bad or missing something?
* Any features that would let you do things you can't atm?
* What manialink elements would you interact with that you can't?
* Do you want to inject manialink code?
* Anything else?

#### Feature stuff:

* Done: event inspector
  * In-prog: more events
  * Planned: editor, menus, etc
  * Planned: export captured events as CSV/JSON
  * Done: filters
* Done: send script handler events
* Done: inject ML
* Done: message injected ML
* Planned: block some events
* Planned: better API / patterns for 2-way comms

##### *(Done)* Event Inspector

* All Custom Events
* Some other events (notably: `CGameManialinkScriptEvent`)
  * Note: I think other events, like `CGameManiaAppPlaygroundScriptEvent` **should** be possible, but we need to find the right point to check `PendingEvents`.

##### *(Planned)* Additionally, events can be intercepted and/or blocked.

##### *(Partial Implementation / In Progress)* Sending Custom Events

This plugin provides exports to allow sending custom events via `ScriptHandler.SendCustomEvent` only atm.
As a PoC, *Any Ghost* [was patched](https://github.com/XertroV/Any-Ghost/commit/7036885adb8213c87a1bf7719dd697ebb8dd67df) to use the new api (see bottom for details).

##### *(Possible)* Std Two-way (async) communication between AngelScript and ManiaScript

##### *(Possible?)* Std Two-way (sync) communication between AngelScript and ManiaScript

### Acknowledgements

This plugin is only possible due to many prior efforts and a lot of trial and error.
This is a non-exhaustive list of those who are owed partial credit and appreciation:
* skybaxrider
* zer0detail
* Miss
* nbert
* zer0detail

(contact @XertroV if someone is missing; I know people are, just that I don't know enough of the lore.)

### About

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-ml-to-angelscript-hook](https://github.com/XertroV/tm-ml-to-angelscript-hook)

GL HF

## For Developers

MLHook currently allows partial 2-way comms between AS and ML.
Full 2-way comms is planned, but requires more API work.

Also, the use of `SendCustomEvent` on script handlers without crashing the game.
In general, sending custom events seems to be fine when `.Page` is not null -- which it always is during the typical times that AngelScript runs.
As far as I can tell, `.Page` is only not-null when Manialink code is executing, and even then, not all of the time.

### Usage:

Add this to your `info.toml`:

```toml
[script]
dependencies = [ 'MLHook' ]
```

Send `CGameManialinkScriptHandler` Custom Events via:

```AngelScript
MLHook::Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {});
MLHook::Queue_PG_SendCustomEvent(const string &in type, string[] &in data = {});
```

Inject Manialink code to react to msgs from MLHook (which are independent of TM's script events).

```AngelScript
MLHook::InjectManialinkToPlayground(const string &in PageUID, const string &in ManialinkPage, bool replace = false);
MLHook::Queue_MessageManialinkPlayground(const string &in PageUID, const string &in msg);
```

Example using injected ML to refresh records: https://github.com/XertroV/tm-somewhat-better-records/blob/master/src/Main.as


#### Tips re ML Injection

You'll probably to recover from compile/syntax error:
- on script error page, press ctrl+g to get rid of overlay
- wait for "recovery restart" to come up (press okay when it does)
- after a second the UI should have reloaded, then you can reload the plugin to try your new changes.


--------------
<!-- below not in OP description-->

<!-- todo: better inputs via ML_SE / InputSE? -->

#### ML Script Hierarchy

(Note: input from someone more familiar with Maniascript would be appreciated)
Events seem to propagate up, like a PlaygroundScriptHandler event gets sent to the ManiaAppPlayground handler too.

(todo)


## Changelog

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
