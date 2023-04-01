## About MLHook

MLHook is a dependency to manage the injection of ML pages, communication between AngelScript and ManiaLink / ManiaScript code, and provide callbacks in response to ML events. Not all ML/ManiaScript code/apps are accessible, and only shared ML state is accessible.

Internally, much of MLHook's functionality comes from intercepting `SendCustomEvent` and running angelscript code during the manialink execution period.
This allows access to `PendingEvents` and thus the ML Event Inspector, as an example.
MLHook injects a simple ML script to the menu and playground so that we can reliably intercept this call at least once per frame.

MLHook provides communication functionality to other plugins by queuing incoming and outgoing events. A slightly asynchronous model was chosen to minimize the amount of plugin code running during ML execution time, and to provide a buffer between MLHook's internal operation and dependent plugin crashes. In general, the lag is always less than 2 frames.

In almost all cases, namespacing via prefix is used to avoid collisions and unknowingly unwise decisions by devs of dependent plugins.
Events, `declare for` variables, etc, are usually named in the following form: `MLHook_<Kind>_<Scope>_<Name>`.
For example: `MLHook_Event_RaceStats_Player`.
Often `Scope` is called `PageUID` in code and dependent plugins like MLFeed.
Pages created by MLHook have a name and `AttachId` in the form `MLHook_<PageUID>`.

Currently, ML with UI elements is not supported by MLHook.
This has been left out for the sake of convenience thus far (the only exposed method is a convenient one where maniascript code does not need to be wrapped in `<script>` or `<manialink>` tags).

### Primary Functions

- AngelScript -> ManiaLink / ManiaScript
  - Messages serialized as code and sent via dedicated ML page which 0writes that data to a known `declare X for ClientUI` (in the playground, the location is different when in the menu). This is done once every 2 frames to provide some buffer as the objects are completely overwritten each time.
  - `MLInjection.as`

- ManiaLink -> AngelScript
  - SendCustomEvent intercepted and processed for registered events.
  - `HookManialinkCode.as`
  - `HookRouter.as`

- ML Events -> AngelScript
  - Hook objects are registered with an event and receive callbacks.
  - `HookRouter.as`
  - `HookManialinkCode.as`

- Injecting ML
  - standardized form with some safety precautions.
  - `MLInjection.as`

### Design comments

Outside of SIG_DEVELOPER functionality, performance and memory management are given high priority.

Some consideration was paid to an object/interface model encapsulating the queuing, but there are so few maniaapps to interact with that it doesn't seem that valuable. See `ManialinkHook.as`.

### Aux/Dev Functions

- ML Event Inspector
- UI Layers Browser

### Use Case Examples

Some things that MLHook makes easy that are either slow/hard or not currently (known to be) possible:

- read ghost checkpoint times

- read opponents checkpoint times & nb respawns (I think, would need to check)

- easily tell the active menu page (possible in pure angelscript, but not performant)

- read standard `define X for Y` data associated with game modes like matchmaking, COTD / KO, etc. (note: potentially possible via the debug dump function, but I'm not sure it's equivalent)

- direct angelscript interaction with certain manialink related game objects / instances (which might be null or cause a crash, otherwise)
