# MLHook -- Manialink Hook Library & Custom Event Inspector

## Status: Public Beta and RFC

**Note: some of these features will be in-progress or planned. The insepctor is functional, and it is possible to send some custom events, currently.**

**For Users:** You may need to install this plugin as a dependency for another plugin that you want to use.
In that case, you can install and forget -- it'll operate silently the background.

MLHook is a dependency plugin (for use by other plugins) to enable running code at the same time as Manialink does.
It is also a developer tool used to inspect all Custom Events.

As a dependency, MLHook lets you interact with `Nod`s that would not otherwise be possible, and send Custom Events that would otherwise not be possible.

*(Planned)* Additionally, events can be intercepted and/or blocked.

*(Partial Implementaiton / In Progress)* This plugin provides exports to allow sending custom events (only via `ScriptHandler.SendCustomEvent` currently).
*Any Ghost* [was patched](https://github.com/XertroV/Any-Ghost/commit/7036885adb8213c87a1bf7719dd697ebb8dd67df) as a proof-of-concept.
```AngelScript
MLHook::Queue_SH_SendCustomEvent(const string &in type, string[] &in data = {})
```


### Acknowledgements

This plugin is only possible due to many prior efforts and a lot of trial and error.
This is a non-exhaustive list of those who are owed partial credit and appreciation:
* skybaxrider
* zer0detail
* Miss
* nbert
(contact @XertroV if someone is missing)

### About

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-ml-to-angelscript-hook](https://github.com/XertroV/tm-ml-to-angelscript-hook)

GL HF

## For Developers

This allows the use of `SendCustomEvent` on script handlers without crashing the game.
In general, sending custom events seems to be fine when `.Page` is not null -- which it always is during the typical times that AngelScript runs.
As far as I can tell, `.Page` is only not-null when Manialink code is executing, and even then, not all of the time.

### Usage:

Add this to your `info.toml`:
```
[script]
dependencies = [ 'MLHook' ]
```
