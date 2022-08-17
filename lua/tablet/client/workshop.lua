

local APP = {}
APP.ID = "workshop"
APP.Name = "Workshop"
APP.Icon = Material("ugc/tablet/workshop.png", "smooth")
APP.SortOrder = 110

local ui = tablet.ui
surface.CreateFont("tabletspeedy_loading", {font = "Roboto", size = 36})
function APP:onOpen(layout, frame)
	layout.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 245, 245, 245)
		ui.DrawText("Chargement...", "tabletspeedy_loading", w / 2, h / 2, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local header = vgui.Create("DHTMLControls", layout)
	header:SetWide(layout:GetWide())

	local html_pnl = vgui.Create("DHTML", layout)
	html_pnl:SetPos(0, header:GetTall())
	html_pnl:SetSize(layout:GetWide(), layout:GetTall() - header:GetTall())
	html_pnl:OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?edit=true&id=2582459612")
	html_pnl.OnChangeTargetURL = function(self, url) self.hoveredURL = url end
	html_pnl.PaintOver = function(self, w, h)
		if !self.hoveredURL or #self.hoveredURL < 1 then return end 

		local tw, th = ui.GetTextSize("DermaDefault", self.hoveredURL)
		ui.DrawRect(0, h - th - 6, tw + 10, th + 6, 0, 0, 0, 150)
		ui.DrawText(self.hoveredURL, "DermaDefault", 5, h - (th) / 2 - 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	header:SetHTML(html_pnl)
	header.AddressBar:SetText("https://steamcommunity.com/sharedfiles/filedetails/?edit=true&id=2582459612")
end

tablet.addApp(APP)