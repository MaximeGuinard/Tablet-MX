

tablet.openApp = function(id)
	local f = tablet.get()
	if !IsValid(f) then f = tablet.open() end
	f:openApp(id)
end