

local APP = {}
APP.ID = "gunshop"
APP.Name = "Armurie"
APP.Icon = Material("ugc/tablet/gunstore.png", "smooth")
APP.SortOrder = 10
APP.canUse = function(p) return table.HasValue(LifeRP_gunshop, team.GetName(p:Team())) end

local ui = tablet.ui
local gradient = Material("gui/gradient_up")
local mHeader = Material("ugc/tablet/gunstoreowner.png", "smooth")
local mMinus, mPlus = Material("icon16/bullet_white.png"), Material("icon16/bullet_green.png")
 
local function canBuy(itm)
    local ply = LocalPlayer()
    local money = ply:getDarkRPVar("money")
    local price = itm.separate and itm.pricesep or itm.price
 
    if money < price then
        return false, "Pas assez d'argent"
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
 
surface.CreateFont("tablet_gunstoreheader", {font = "Roboto", size = 36, weight = 1000})
function APP:onOpen(layout, frame)
    layout.Paint = function(self, w, h) ui.DrawRect(0, 0, w, h, 61, 61, 61) end
 
    local items
    local header = vgui.Create("DPanel", layout)
    header:SetSize(layout:GetWide(), 69)
    header.Paint = function(self, w, h)
        ui.DrawRect(0, 0, w, 64, 245, 124, 0)
        ui.DrawTexturedRect(0, 0, w, 64, gradient, 255, 255, 255, 50)
        ui.DrawRect(0, 64, w, 5, 0, 0, 0, 255)
 
        ui.DrawTexturedRect(0, 0, 118, 64, mHeader)
        ui.DrawText("ARMURIE", "tablet_gunstoreheader", w / 2, 32, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
 
    local filter = vgui.Create("DPanel", layout)
    filter:SetPos(10, 74)
    filter:SetSize(180, layout:GetTall() - 79)
    filter.Paint = function(self, w, h)
        ui.DrawRect(0, 0, w, 35, 110, 110, 110, 110)
        ui.DrawOutlinedRect(0, 0, w, 35, 255, 255, 255, 25)
    end
    filter.filterBy = {}
 
    local function getCategories(f)
        local categories = {}
 
        for k, v in pairs(DarkRP.getCategories().weapons) do
            if categories[v.name] and not v.deepweb then
                for _, m in pairs(table.Copy(v.members)) do
                    table.insert(categories[v.name], m)
                end
            else
                categories[v.name] = table.Copy(v.members)
            end
        end
 
        for k, v in pairs(DarkRP.getCategories().shipments) do
            if categories[v.name] and not v.deepweb then
                for _, m in pairs(table.Copy(v.members)) do
                    table.insert(categories[v.name], m)
                end
            else
                categories[v.name] = table.Copy(v.members)
            end
        end
 
        for k, v in pairs(DarkRP.getCategories().ammo) do
            if categories.Ammo and not v.deepweb then
                for _, m in pairs(table.Copy(v.members)) do
                    m.isAmmo = true
                    table.insert(categories.Ammo, m)
                end
            else
                local temp = table.Copy(v.members)
                for k, v in pairs(temp) do v.isAmmo = true end
                categories.Ammo = temp
            end
        end
 
        if f then
            for catName, btn in pairs(filter.filterBy) do
                if !btn.include then
                    categories[catName] = nil
                end
            end
 
            if IsValid(filter.search) then
                local searchValue = filter.search:GetValue()
 
                if searchValue and #searchValue > 0 then
                    local function filterMembers(tbl) for k, v in pairs(tbl) do if !v.name:lower():find(searchValue:lower()) then tbl[k] = nil end end end
                    for k, v in pairs(categories) do
                        filterMembers(v)
                    end
                end
            end
 
            local temp = {}
            for _, v in pairs(categories) do
                for _, m in pairs(v) do
                    table.insert(temp, m)
                end
            end
 
            return temp
        end
 
        return categories
    end
 
    local categoriesList = getCategories()
 
    filter.search = vgui.Create("DTextEntry", filter)
    filter.search:SetSize(filter:GetWide() - 10, 25)
    filter.search:SetPos(5, 5)
    filter.search:SetText("")
    filter.search.OnEnter = function() items:Load() end
 
    filter.scroll = vgui.Create("DScrollPanel", filter)
    filter.scroll:SetPos(0, 40)
    filter.scroll:SetSize(filter:GetWide(), filter:GetTall() - 40)
    	    	local sbar = filter.scroll:GetVBar()
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
 
    filter.layout = vgui.Create("DIconLayout", filter.scroll)
    filter.layout:SetSpaceY(5)
    filter.layout:SetSize(filter.scroll:GetSize())
 
    for catName, _ in pairs(categoriesList) do
        local p = filter.layout:Add("mgButton")
        p:SetSize(filter.layout:GetWide(), 24)
        p:SetText("")
        p.include = cookie.GetNumber("tablet_gunstore_filter_" .. tostring(catName), 1) == 1 and true or false
        p.oldPaint = p.Paint
        p:SetColor(Color(255, 255, 255, 50))
        p.Paint = function(self, w, h)
            self:oldPaint(w, h)
 
            ui.DrawTexturedRect(4, 4, 16, 16, self.include and mPlus or mMinus)
 
            if filter.scroll.VBar.Enabled then
                self:SetWide(filter.layout:GetWide() - filter.scroll.VBar:GetWide() - 5)
            else
                self:SetWide(filter.layout:GetWide())
            end
 
            ui.DrawText(catName, "button_text", 26, h / 2, self:GetColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        p.DoClick = function(self)
            self.include = !self.include
            cookie.Set("tablet_gunstore_filter_" .. tostring(catName), self.include and 1 or 0)
            items:Load()
        end
        filter.filterBy[catName] = p
    end
 
    local itemsScroll = vgui.Create("DScrollPanel", layout)
    itemsScroll:SetPos(filter.x + filter:GetWide() + 5, header:GetTall() + 5)
    itemsScroll:SetSize(layout:GetWide() - itemsScroll.x - 5, layout:GetTall() - itemsScroll.y - 5)
    itemsScroll.VBar.btnGrip.PaintOver = function(self, w, h) ui.DrawOutlinedRect(0, 0, w, h, 150, 150, 150, 25) end
    	    	local sbar = itemsScroll:GetVBar()
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
 
    items = vgui.Create("DIconLayout", itemsScroll)
    items:SetSize(itemsScroll:GetSize())
    items:SetSpaceY(5)
    items.Load = function(self)
        self:Clear()
 
        local itms = getCategories(true)
        for k, v in pairs(itms) do v.sortOrder = v.sortOrder or ((v.separate and 0 or 5) + (v.isAmmo and 5 or 0)) if !canBuy(v) then v.sortOrder = v.sortOrder + 1000 end end
 
        for k, v in SortedPairsByMemberValue(itms, "sortOrder") do
            local ply = LocalPlayer()
            if v.allowed and not table.HasValue(v.allowed, ply:Team()) then continue end
            local isShipment = !v.separate and !v.isAmmo
            local price = !isShipment and v.pricesep or v.price
            local p = self:Add("mgPanel")
            p:SetSize(self:GetWide(), 64)
            p.PaintOver = function(self, w, h)
                local bcanBuy, reason = canBuy(v)
                local borderColor = bcanBuy and Color(255, 255, 255, 20) or Color(255, 30, 30, 50)
                local money = LocalPlayer():getDarkRPVar("money")
 
                ui.DrawOutlinedRect(0, 0, w, h, borderColor)
                ui.DrawRect(h, 1, 1, h - 2, borderColor)
                local _, th = ui.DrawText(v.name, "button_text", h + 10, 5, Color(255, 255, 255, 50))
                ui.DrawText(price .. "$ " .. (isShipment and " (" .. tostring(v.amount) .. " objets)" or ""), "button_text", h + 10, 5 + th + 5, money >= price and Color(255, 255, 255, 50) or tablet.config.colours["Red"])
 
                if itemsScroll.VBar.Enabled then
                    self:SetWide(items:GetWide() - itemsScroll.VBar:GetWide() - 5)
                else
                    self:SetWide(items:GetWide())
                end
 
                self.buy:SetPos(w - self.buy:GetWide() - 5, h - self.buy:GetTall() - 5)
                --self.buy:SetVisible(bcanBuy)
 
                if reason then
                    self.buy:SetColor(Color(244, 67, 54, 230))
                    ui.DrawText(reason, "DermaDefaultBold", w - 110, h - 20, tablet.config.colours["Red"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
 
            local buy = vgui.Create("mgButton", p)
            buy:SetSize(100, 25)
            buy:SetPos(p:GetWide() - 105, p:GetTall() - 30)
            buy:SetText("Acheter")
            p.buy = buy
            buy.DoClick = function()
                if isShipment then
                    RunConsoleCommand("DarkRP", "buyshipment", v.name)
                elseif v.isAmmo then
                    RunConsoleCommand("DarkRP", "buyammo", v.id)
                else
                    RunConsoleCommand("DarkRP", "buy", v.name)
                end
            end
 
            local item_mdl = vgui.Create("ModelImage", p)
            item_mdl:SetPos(1, 1)
            item_mdl:SetSize(p:GetTall() - 2, p:GetTall() - 2)
            item_mdl:SetModel(v.model)
 
            if isShipment and v.shipmodel then
                local ship_mdl = vgui.Create("ModelImage", p)
                ship_mdl:SetPos(p:GetTall() - 21, 5)
                ship_mdl:SetSize(16, 16)
                ship_mdl:SetModel(v.shipmodel)
                ship_mdl:SetAlpha(150)
                ship_mdl:SetZPos(item_mdl:GetZPos() + 1)
            end
        end
    end
    items:Load()
end
 
tablet.addApp(APP)