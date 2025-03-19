getgenv().HookHandler = HookHandler or {
	['OriginalNameCall'] = nil,
	['OriginalFireServer'] = nil,
	['OriginalInvokeServer'] = nil,
	['OriginalUnreliableFireServer'] = nil,
	['NameCall'] = nil,
	['CurrentMethod'] = nil
}

function HookHandler.getnamecallmethod()
	return HookHandler.CurrentMethod
end

HookHandler.OriginalNameCall = HookHandler.OriginalNameCall or hookfunction(getrawmetatable(game).__namecall, clonefunction(newcclosure(function(...)
	local method = getnamecallmethod()
	HookHandler.CurrentMethod = method

	return HookHandler.NameCall(...)
end)))

HookHandler.OriginalFireServer = HookHandler.OriginalFireServer or hookfunction(Instance.new('RemoteEvent').FireServer, clonefunction(newcclosure(function(...)
	HookHandler.CurrentMethod = 'FireServer'

	return HookHandler.NameCall(...)
end)))

HookHandler.OriginalUnreliableFireServer = HookHandler.OriginalUnreliableFireServer or hookfunction(Instance.new('UnreliableRemoteEvent').FireServer, clonefunction(newcclosure(function(...)
	HookHandler.CurrentMethod = 'FireServer'

	return HookHandler.NameCall(...)
end)))

HookHandler.OriginalInvokeServer = HookHandler.OriginalInvokeServer or hookfunction(Instance.new('RemoteFunction').InvokeServer, clonefunction(newcclosure(function(...)
	HookHandler.CurrentMethod = 'InvokeServer'

	return HookHandler.NameCall(...)
end)))

HookHandler.NameCall = HookHandler.NameCall or clonefunction(newcclosure(function(...)
	local Obj = select(1, ...)
	local Method = HookHandler.getnamecallmethod()
	local Bridged = {namecall(...)}

	if (Method == 'FireServer') then
		if (Obj and Obj.ClassName == 'UnreliableRemoteEvent') then
			return HookHandler.OriginalUnreliableFireServer(unpack(Bridged))
		end

		return HookHandler.OriginalFireServer(unpack(Bridged))
	end
	
	if (Method == 'InvokeServer') then
		return HookHandler.OriginalInvokeServer(unpack(Bridged))
	end

	return HookHandler.OriginalNameCall(unpack(Bridged))
end))

getgenv().namecall = clonefunction(newcclosure(function(...)
	return ...
end))

return HookHandler;
