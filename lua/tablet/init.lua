

tablet = tablet or {}
tablet.hasSignal = function(ply) return true end

tablet.ui = include("tablet/ui.lua")

tablet.Width = 1794
tablet.Height = 1385
tablet.Material = Material("ugc/tablet/tablet.png", "smooth")
tablet.Materials = {
	Power = Material("ugc/tablet/power_btn.png", "smooth"),
	Back = Material("ugc/tablet/back_btn.png", "smooth"),
	Menu = Material("ugc/tablet/menu_btn.png", "smooth"),
	Signal = Material("ugc/tablet/signal.png", "smooth"),
	Battery = Material("ugc/tablet/battery.png", "smooth"),
	AppIcon = Material("ugc/tablet/appicon_blank.png", "smooth")
}

tablet.apps = tablet.apps or {}
tablet.addApp = function(tbl)
	tablet.apps[tbl.ID] = tbl
end

tablet.scaleSize = function(w, h)
	w, h =  w or tablet.Width, h or tablet.Height

	local scrw, scrh = ScrW(), ScrH()
	local resizeW, resizeH = w >= scrw, h >= scrh
	local oldW, oldH = w, h

	if resizeW then
		w = scrw - 40
		h = math.Round(h * (w / oldW))

		if resizeH then
			return tablet.scaleSize(w, h)
		end
	elseif resizeH then
		h = scrh - 40
		w = math.Round(w * (h / oldH))
	end

	return w, h
end 