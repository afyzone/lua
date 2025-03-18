getgenv().HookHandler = HookHandler or {
	['OriginalNameCall'] = nil,
	['OriginalFireServer'] = nil,
	['OriginalInvokeServer'] = nil,
	['OriginalUnreliableFireServer'] = nil,
	['NameCall'] = nil,
}

HookHandler.OriginalNameCall = HookHandler.OriginalNameCall or hookfunction(getrawmetatable(game).__namecall, clonefunction(newcclosure(function(...)
	return HookHandler.NameCall(getnamecallmethod(), ...)
end)))

HookHandler.OriginalFireServer = HookHandler.OriginalFireServer or hookfunction(Instance.new('RemoteEvent').FireServer, clonefunction(newcclosure(function(...)
	return HookHandler.NameCall('FireServer', ...)
end)))

HookHandler.OriginalUnreliableFireServer = HookHandler.OriginalUnreliableFireServer or hookfunction(Instance.new('UnreliableRemoteEvent').FireServer, clonefunction(newcclosure(function(...)
	return HookHandler.NameCall('FireServer', ...)
end)))

HookHandler.OriginalInvokeServer = HookHandler.OriginalInvokeServer or hookfunction(Instance.new('RemoteFunction').InvokeServer, clonefunction(newcclosure(function(...)
	return HookHandler.NameCall('InvokeServer', ...)
end)))

HookHandler.NameCall = HookHandler.NameCall or clonefunction(newcclosure(function(Method, ...)
	local Bridged = {namecall(Method, ...)}

	if (Method == 'FireServer') then
		return HookHandler.OriginalFireServer(unpack(Bridged))
	end
	
	if (Method == 'InvokeServer') then
		return HookHandler.OriginalInvokeServer(unpack(Bridged))
	end

	return HookHandler.OriginalNameCall(unpack(Bridged))
end))

getgenv().namecall = clonefunction(newcclosure(function(Method, ...)
	return ...
end))
