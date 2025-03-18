# HookHandler

A simple library to intercept and detour Roblox remote calls without breaking other methods. It hooks:

- `__namecall` (for any method called with the `:` operator, like `object:ClientLog(...)`)
- `RemoteEvent:FireServer`
- `UnreliableRemoteEvent:FireServer` (if your environment supports them)
- `RemoteFunction:InvokeServer`

The library also catches direct calls such as  
```lua
Instance.new('RemoteFunction').InvokeServer(remote, ...)
```  
instead of the usual  
```lua
remoteFunction:InvokeServer(...)
```
In other words, **any** usage of `RemoteFunction:InvokeServer` can be intercepted, even when invoked in a less typical manner.

---

## Installation

1. Place [`HookHandler.lua`](./HookHandler.lua) in your Lua code:  
   **`lua/#Libraries/HookHandler/HookHandler.lua`**  

2. Load it in your script or exploit environment. For example:
   ```lua
   -- In your script:
   local HookHandler = loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/%23Libraries/HookHandler/HookHandler.lua'))()
   ```
That’s it! Once loaded, all the hooked functions are automatically replaced.

---

## How It Works

- **`MetaMethods.OriginalNameCall`**: Hooks the raw `__namecall` behind every Roblox Instance.  
- **`MetaMethods.OriginalFireServer`**: Hooks remote event calls.  
- **`MetaMethods.OriginalInvokeServer`**: Hooks remote function calls, including unusual calls such as `Instance.new('RemoteFunction').InvokeServer(remote, ...)`.  
- **`MetaMethods.OriginalUnreliableFireServer`**: Hooks “unreliable” remote events.  

A custom function `MetaMethods.NameCall` decides how to handle each method. The variable `getgenv().namecall` is exposed so you can override how the varargs are processed before going back to the original calls.

### Getting the NameCall Method

Inside the NameCall hook, we store the current name call method in `HookHandler.CurrentMethod`. To retrieve it outside of the hook, you can call:

```lua
local Method = HookHandler.getnamecallmethod()
```

This lets you check which method (e.g. `"FireServer"` or `"InvokeServer"`) was most recently intercepted.

---

## Usage

You can override the public `namecall` function to see or modify arguments. For instance:

```lua
-- Load the handler
local hooks = loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/%23Libraries/HookHandler/HookHandler.lua'))()

namecall = function(...)
    local method = HookHandler.getnamecallmethod()

    if method == "FireServer" then
        print("FireServer called on:", select(1, ...):GetFullName())
        print("Additional args:", unpack({select(2, ...)}))
    elseif method == "InvokeServer" then
        print("InvokeServer called on:", select(1, ...), "with arguments:", unpack({select(2, ...)}))
    end

    -- Always return the original arguments so the call doesn't break
    return ...
end
```

When a script calls `SomeRemoteEvent:FireServer("Hello", 123)` or `someRemoteFunction:InvokeServer("ABC")`, you’ll see a debug print with the remote name and arguments, and the original call will still run normally.

This library also captures less common calls like:
```lua
Instance.new('RemoteFunction').InvokeServer(someRemoteFunction, "xyz", 789)
```
so you can reliably intercept *any* usage pattern of `RemoteFunction`.

---

## Example

Below is a minimal usage example you might drop into your script after loading `HookHandler`:

```lua
-- Load the handler
local hooks = loadstring(game:HttpGet('https://raw.githubusercontent.com/afyzone/lua/refs/heads/main/%23Libraries/HookHandler/HookHandler.lua'))()

-- Example: track all 'FireServer' events
namecall = function (...)
    -- Example: Retrieve the last method used via HookHandler
    local method = HookHandler.getnamecallmethod()

    if (method == 'FireServer') then
        local remote = select(1, ...)
        local args = { select(2, ...) }

        print("Intercepted FireServer call!")
        print("Remote name:", remote and remote.Name)
        print("Arguments:", unpack(args))
    end

    -- Return all arguments so the original function can proceed
    return ...
end

```

---

## Disclaimer

- Overriding NameCall can be risky if you accidentally break argument ordering. Make sure to always return the correct arguments in the correct order.
- This script is intended for *educational and debugging* purposes. Use responsibly.  

Enjoy exploring Roblox’s remote calls!
