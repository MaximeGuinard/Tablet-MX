
local APP = {}
APP.ID = "foodstore"
APP.Name = "FoodStore"
APP.Icon = Material("ugc/tablet/cadi.png", "smooth")
APP.canUse = function(p) return p:isCook() end
APP.SortOrder = 110

local ui = tablet.ui
surface.CreateFont("tablet_estorebtn", {font = "Roboto", size = 16})
surface.CreateFont("tablet_estorename", {font = "Roboto", size = 16, weight = 1000})


local function canBuy(itm)
	local ply = LocalPlayer()
	local money = ply:getDarkRPVar("money")

	if !LocalPlayer():isCook() then
		return false, "Vous n'êtes pas cuisinier ! (Bypass impossible)"
	elseif money < itm.price then
		return false, "Vous n'avez pas assez d'argent."
	elseif itm.allowed and !table.HasValue(itm.allowed, ply:Team()) then
		return false, "Vous ne pouvez pas acheter cela. (Restricted)"
	elseif itm.customCheck and !itm.customCheck(ply, itm) then
		local reason = ""
		if itm.CustomCheckFailMsg then
			if type(itm.CustomCheckFailMsg) == "function" then
				reason = itm.CustomCheckFailMsg(ply, itm)
			else
				reason = tostring(itm.CustomCheckFailMsg)
			end
		end

		return false, reason
	end

	return true
end

function APP:onOpen(layout, frame)
	local ply = LocalPlayer()
	layout.Paint = function(self, w, h) ui.DrawRect(0, 0, w, h, 121, 121, 121) end

	local List
	local tabs = vgui.Create("DPanel", layout)
	tabs:SetSize(layout:GetWide(), 35)
	tabs.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h - 1, 0, 0, 0, 50)
		ui.DrawRect(0, h - 1, w, 1, 0, 0, 0, 120)
	end

	local filter = vgui.Create("DPanel", layout)
    filter:SetPos(1, 1)
    filter:SetSize(180, layout:GetTall() - 79)
    filter.Paint = function(self, w, h)
        ui.DrawRect(0, 0, w, 35, 110, 110, 110, 110)
        ui.DrawOutlinedRect(0, 0, w, 35, 255, 255, 255, 25)
    end
    filter.filterBy = {}

	local cookCategory = {}

	cookCategory.Food = cookCategory.Food or {sortOrder = 1000, name = "Food", members = {}}

	if FoodItems then
		for k, v in pairs(FoodItems) do
			local t = table.Copy(v)
			t.sortOrder = t.sortOrder or 800
			table.insert(cookCategory.Food.members, t)
		end
	end

	cats = cookCategory

	local num = table.Count(cats)
	local width = tabs:GetWide() / num
	local selected = 1
	local i = 1

	local firstB
	for k, v in SortedPairsByMemberValue(cats, "sortOrder") do
		local b = vgui.Create("DButton", tabs)
		b:SetSize(width, tabs:GetTall() - 1)
		b:SetPos((i - 1) * width, 0)
		b:SetText("")
		b.Paint = function(self, w, h)
			local sel = k == selected
			local tw, th = ui.DrawText(num == 1 and "Aliments disponibles", "tablet_estorebtn", w / 2, h / 2, (self.Hovered and !sel) and Color(255, 255, 255) or Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if self.Hovered and !sel then
				local xp, yp = (w - tw) / 2, (h - th) / 2
				ui.DrawRect(xp, yp + th - 1, tw, 1, 6, 84, 186)
			end

			if sel then
				ui.DrawRect(0, h - 2, w, 2, 85, 85, 85)
			end
		end
		b.DoClick = function() selected = k; List:Load(k) end
		if i == 1 then firstB = b end
		i = i + 1
	end

	filter.search = vgui.Create("DTextEntry", filter)
    filter.search:SetSize(filter:GetWide() - 10, 25)
    filter.search:SetPos(5, 5)
    filter.search:SetText("")
    filter.search.OnEnter = function() return true end

	local scroll = vgui.Create("DScrollPanel", layout)
	scroll:SetPos(5, 40)
	scroll:SetSize(layout:GetWide() - 10, layout:GetTall() - 45)

	local sbar = scroll:GetVBar()

	function sbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
	end

	function sbar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(44, 62, 80))
	end

	function sbar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(44, 62, 80))
	end

	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
	end

	List = vgui.Create("DIconLayout", scroll)
	List:SetSize(scroll:GetSize())
	List:SetSpaceY(5)
	List.Load = function(self, id)
		self:Clear()

		local itms = cats[id].members
		for k, v in pairs(itms) do v.sortOrder = v.sortOrder or 0 if !canBuy(v) then v.sortOrder = v.sortOrder + 1000 end end
		for k, v in SortedPairsByMemberValue(itms, "sortOrder") do			
			if v.allowed and not table.HasValue(v.allowed, ply:Team()) then continue end
			local ply = LocalPlayer()
			local p = self:Add("DPanel")
			p:SetSize(self:GetWide(), 64)
			p.Paint = function(self, w, h)
				local canAfford = ply:getDarkRPVar("money") >= v.price

				ui.DrawRect(0, 0, w, h, 0, 0, 0, 15)
				ui.DrawOutlinedRect(0, 0, w, h, 0, 0, 0, 50)

				ui.DrawRect(1, 1, h - 1, h - 2, 0, 0, 0, 15)
				ui.DrawRect(h, 1, 1, h - 2, 0, 0, 0, 50)

				local tw, th = ui.DrawText(v.name, "tablet_estorename", h + 5, 5, Color(61, 61, 61))
				ui.DrawText(v.price .. "$", "tablet_estorebtn", h + 5, 5 + th, canAfford and Color(61,61,61) or tablet.config.colours["Red"])

				if scroll.VBar.Enabled then
					p:SetWide(List:GetWide() - scroll.VBar:GetWide() - 5)
				else
					p:SetWide(List:GetWide())
				end
			end

			local img = vgui.Create("ModelImage", p)
			img:SetModel(v.model)
			img:SetPos(1, 1)
			img:SetSize(p:GetTall() - 2, p:GetTall() - 2)

			local buy = vgui.Create("DButton", p)
			buy:SetSize(100, 25)
			buy:SetPos(p:GetWide() - 105, p:GetTall() - 30)
			buy:SetText("")
			buy.Paint = function(self, w, h)

				local bCan, reason = canBuy(v)

				if !bCan then self.Hovered = false end

				ui.DrawRect(2, 2, w - 4, h - 4, 255, 136, 0, 150, (self.Hovered and !self.Depressed) and 50 or 80)
				ui.DrawOutlinedRect(0, 0, w, h, 255, 255, 255, 20)
				ui.DrawOutlinedRect(1, 1, w - 2, h - 2, 255, 136, 0, 255)

				ui.DrawText("Acheter", "DermaDefaultBold", w / 2, h / 2, bCan and Color(255, 255, 255) or Color(244, 67, 54, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				self.x = p:GetWide() - w - 5

				if reason then
					surface.DisableClipping(true)
						ui.DrawText(reason, "tablet_estorebtn", -5, h / 2 - 1, tablet.config.colours["Red"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					surface.DisableClipping(false)
				end

			end
			buy.DoClick = function() RunConsoleCommand("darkrp", "buyfood", v.name) return end
		end
	end
	
	if firstB then 
		firstB:DoClick()
	else 
		local b = vgui.Create("DButton", tabs)
		b:SetSize(tabs:GetWide(), tabs:GetTall() - 1)
		b:SetPos(0, 0)
		b:SetText("")
		b.Paint = function(self, w, h)
			ui.DrawText("Le magasin est vide.", "tablet_estorebtn", w / 2, h / 2, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

end

tablet.addApp(APP)