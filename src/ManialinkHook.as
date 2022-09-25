/*
Goal: abstract the pattern of hooking into manialink code in a given context.
E.g., we want to have one instance monitoring for playground changes
and injecting ML there.
We also want another instance for the menu, and the editor, etc.

Contextual elements:
- On setup: hook name and where to inject (cmap / mcma / etc)
  -- needs UILayers / UILayerCreate

*/

interface IManialinkHook {
    void InjectML(const string &in msg);
    void QueueMessageToML(const string &in msg);
    void Queue_SH_SendCustomEvent(const string &in msg);
    void Queue_PG_SendCustomEvent(const string &in msg);
}

// class ManialinkHookBase : IManialinkHook {

// }
