getgenv().MetaMethods = MetaMethods or {
	['OriginalNameCall'] = nil,
	['OriginalFireServer'] = nil,
	['OriginalInvokeServer'] = nil,
	['OriginalUnreliableFireServer'] = nil,
	['NameCall'] = nil,
}

MetaMethods.OriginalNameCall = MetaMethods.OriginalNameCall or hookfunction(getrawmetatable(game).__namecall, clonefunction(newcclosure(function(...)
	return MetaMethods.NameCall(getnamecallmethod(), ...)
end)))

MetaMethods.OriginalFireServer = MetaMethods.OriginalFireServer or hookfunction(Instance.new('RemoteEvent').FireServer, clonefunction(newcclosure(function(...)
	return MetaMethods.NameCall('FireServer', ...)
end)))

MetaMethods.OriginalUnreliableFireServer = MetaMethods.OriginalUnreliableFireServer or hookfunction(Instance.new('UnreliableRemoteEvent').FireServer, clonefunction(newcclosure(function(...)
	return MetaMethods.NameCall('FireServer', ...)
end)))

MetaMethods.OriginalInvokeServer = MetaMethods.OriginalInvokeServer or hookfunction(Instance.new('RemoteFunction').InvokeServer, clonefunction(newcclosure(function(...)
	return MetaMethods.NameCall('InvokeServer', ...)
end)))

MetaMethods.NameCall = MetaMethods.NameCall or clonefunction(newcclosure(function(Method, ...)
	local Bridged = {namecall(Method, ...)}

	if (Method == 'FireServer') then
		return MetaMethods.OriginalFireServer(unpack(Bridged))
	end
	
	if (Method == 'InvokeServer') then
		return MetaMethods.OriginalInvokeServer(unpack(Bridged))
	end

	return MetaMethods.OriginalNameCall(unpack(Bridged))
end))

getgenv().namecall = clonefunction(newcclosure(function(Method, ...)
	return ...
end))
