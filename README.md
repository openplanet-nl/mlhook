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
It is also a developer tool used to inspect all Custom Events.

As a dependency, MLHook lets plugins interact with game elements that would not otherwise be possible, and send Custom Events that would otherwise not be possible.

### For Devs:

*(Note: additionally, see the section at the bottom)*

[Suggestions requested!](https://github.com/XertroV/tm-ml-to-angelscript-hook/issues)
* What would you use this for?
* What manialink elements would you interact with?
* Do you want to inject manialink code?
* Anything else?

#### Feature stuff:

##### *(Done)* Event Inspector

* All Custom Events
* Some other events (notably: `CGameManialinkScriptEvent`)
  * Note: I think other events, like `CGameManiaAppPlaygroundScriptEvent` **should** be possible, but we need to find the right point to check `PendingEvents`.

##### *(Planned)* Additionally, events can be intercepted and/or blocked.

##### *(Partial Implementation / In Progress)* Sending Custom Events

This plugin provides exports to allow sending custom events via `ScriptHandler.SendCustomEvent` only atm.
As a PoC, *Any Ghost* [was patched](https://github.com/XertroV/Any-Ghost/commit/7036885adb8213c87a1bf7719dd697ebb8dd67df) to use the new api (see bottom for details).

##### *(Planned)* Inject Manialink code

Example: could be used to refresh leaderboards without wiping ghosts. (@nbert)

##### *(Possible)* Std Two-way (async) communication between AngelScript and ManiaScript

##### *(Possible?)* Std Two-way (sync) communication between AngelScript and ManiaScript

##### Future Features?

* Export inspector log as .csv, etc
* Interface for sending ad-hoc custom events

<!-- todo: better inputs via ML_SE / InputSE? -->

### Acknowledgements

This plugin is only possible due to many prior efforts and a lot of trial and error.
This is a non-exhaustive list of those who are owed partial credit and appreciation:
* skybaxrider
* zer0detail
* Miss
* nbert
(contact @XertroV if someone is missing; I know people are, just that I don't know enough of the lore.)

### About

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-ml-to-angelscript-hook](https://github.com/XertroV/tm-ml-to-angelscript-hook)

GL HF

## For Developers

MLHook currently allows the use of `SendCustomEvent` on script handlers without crashing the game.
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
MLHook::Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {})
```
