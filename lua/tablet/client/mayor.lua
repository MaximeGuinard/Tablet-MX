

local APP = {}
APP.ID = "maire"
APP.Name = "Maire"
APP.Icon = Material("ugc/tablet/crimenet.png", "smooth")
APP.SortOrder = 10
APP.canUse = function(p) return p:isMayor() end
 
local ui = tablet.ui
local gradient = Material("gui/gradient_up")
 
local menu_action = {}
--[[menu_action[1] = {
    on = "Éteindre les ATMs de la ville",
    off = "Allumer les ATMs de la ville"
}
menu_action[2] = {
    on = "Désactiver les coffres personnels",
    off = "Activer les coffres personnels"
}]]
menu_action[1] = {
    on = "Lancer le couvre-feu",
    off = "Arrêter le couvre-feu",
    action = "lockdown",
    action2 = "unlockdown",
    func = function() return not GetGlobalBool("DarkRP_LockDown") end,
}
--menu_action[4] = {
   -- on = "Gérer le salaire des citoyens"
--}
menu_action[2] = {
    on = "Placer un tableau des lois",
    action = "placelaws"
}
menu_action[3] = {
    on = "Ajouter une loi",
    action = "addlaw"
}
menu_action[4] = {
    on = "Supprimer une loi",
    action = "removelaw"
}
 
local actMaire, salaireTBL = {
    [1] = false,
    [2] = false,
    [3] = false,
    --["imp"] = 0,
   -- ["ess"] = 0,
   -- ["pro"] = 0,
}, {}
 
local impSlider, essSlider, proSlider
net.Receive("mayorMenuGTA", function()
    local data, sal = net.ReadTable(), net.ReadTable()
    actMaire, salaireTBL = data, sal
    if IsValid(impSlider) then impSlider:SetValue(actMaire["imp"] or 0) end
    if IsValid(essSlider) then essSlider:SetValue(actMaire["ess"] or 0) end
    if IsValid(proSlider) then proSlider:SetValue(actMaire["pro"] or 0) end
end)
 
local buttonMat = Material("icon16/arrow_rotate_clockwise.png")
--[[local function mayorSalaire()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:isMayor() then return end
 
    local mayorFrame = vgui.Create( "DFrame" )
    mayorFrame:SetSize( 400, 570 )
    mayorFrame:Center()
    mayorFrame:SetTitle("")
    mayorFrame:ShowCloseButton(false)
    mayorFrame:SetDraggable(false)
    mayorFrame:MakePopup()
    mayorFrame.Paint = function(self,w,h)
        --Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
        draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37))
        draw.RoundedBox(2, 0, 0, w, 25, Color(65, 140, 200))
        draw.SimpleTextOutlined("Gestion des différents salaires:", "Roboto_15", 5, 12, color_white, 0, 1, 0.5, color_black)
        draw.SimpleText("Liste des métiers, baisse/augmentation des salaires en %:", "Roboto_15", 5, 40, color_white, 0, 1)
        draw.RoundedBox(2, 6, 47, 305, 2, color_white)
    end
 
    local exitB = vgui.Create( "DButton", mayorFrame )
    exitB:SetSize(30, 15)
    exitB:SetPos(mayorFrame:GetWide()-35, 5)
    exitB:SetText("")
    exitB.Paint = function(self,w,h)
        draw.RoundedBox(4, 0, 0, w, h, color_white)
        if self.cursor_on then
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60, 100))
        end
        draw.SimpleText("X", "DermaDefault", w/2, h/2, color_black, 1, 1)
    end
    exitB.OnCursorEntered = function(self)
        self.cursor_on = true
    end
    exitB.OnCursorExited = function(self)
        self.cursor_on = false
    end
    exitB.DoClick = function(self)
        if IsValid(self:GetParent()) then self:GetParent():Remove() end
    end
 
    local panelBase = vgui.Create("DPanelList", mayorFrame )
    panelBase:SetSize(390, 500)
    panelBase:SetPos(10, 60)
    panelBase:EnableVerticalScrollbar(true)
    panelBase.VBar.btnUp.Paint = function(self,w,h)
        draw.RoundedBox(0, 1, 0, w/3.5, h, Color(100, 100, 100))
    end
    panelBase.VBar.btnDown.Paint = function(self,w,h)
        draw.RoundedBox(0, 1, 0, w/3.5, h, Color(100, 100, 100))
    end
    panelBase.VBar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox(0, 1, 0, w/3.5, h, Color(120, 120, 120))
    end
    panelBase.VBar.Paint = function(self,w,h)
        draw.RoundedBox(0, 1, 16, w/3.5, h-32, Color(180, 180, 180))
    end
 
    for k,v in pairs(RPExtraTeams) do
        --if k > 2 then return end
        local panelInfo = vgui.Create("DPanel", mayorFrame )
        panelInfo:SetSize(375, 30)
        panelInfo:SetPos(10, 60)
        panelInfo.Paint = function(self,w,h)
            --draw.RoundedBox(2, 0, 0, w, h-1, Color(37, 255, 37))
            --draw.RoundedBox(2, 3, 14, 93, 2, color_white)
        end
 
        local labelName = vgui.Create("DLabel", panelInfo )
        labelName:SetPos(3, -6)
        labelName:SetSize(130, 30)
        labelName:SetText(v.name)
 
        local salaireSlider = vgui.Create( "DNumSlider", panelInfo )
        salaireSlider:SetPos( -30, -8)
        salaireSlider:SetSize( 400, 30 )
        salaireSlider:SetText("")
        salaireSlider:SetMin( -100 )
        salaireSlider:SetMax( 25 )
        salaireSlider:SetValue(salaireTBL[k] and (salaireTBL[k]-1) * 100 or 0)
        salaireSlider:SetDecimals(0)
        salaireSlider.TextArea:SetTextColor(color_white)
 
        local sendB = vgui.Create( "DButton", panelInfo )
        sendB:SetSize(20, 20)
        sendB:SetPos(panelInfo:GetWide() - 20, 0)
        sendB:SetText("")
        sendB.Paint = function(self,w,h)
            if self.cursor_on then
                draw.RoundedBox(4, 0, 0, w, h, Color(65, 140, 200))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(60,60,60))
            end
            surface.SetDrawColor(color_white)
            surface.SetMaterial(buttonMat)
            surface.DrawTexturedRect( 2, 2, 16, 16 )
        end
        sendB.OnCursorEntered = function(self)
            self.cursor_on = true
        end
        sendB.OnCursorExited = function(self)
            self.cursor_on = false
        end
        sendB.DoClick = function(self)
            local new_salaire = salaireSlider:GetValue()
            if new_salaire ~= 0 then
                net.Start("DoMayorAction")
                net.WriteInt(4, 4)
                net.WriteTable({k, new_salaire})
                net.SendToServer()
            end
        end
 
        panelBase:AddItem(panelInfo)
    end
end
 ]]
function APP:onOpen(layout, frame)
    local ply = LocalPlayer()
    layout.Paint = function(self, w, h) ui.DrawRect(0, 0, w, h, 245, 245, 245) end
    ply:ConCommand("maireDATA")
 
    local header = vgui.Create("DPanel", layout)
    header:SetSize(layout:GetWide(), 69)
    header.Paint = function(self, w, h)
        ui.DrawRect(0, 0, w, 64, 180, 0, 0)
        ui.DrawTexturedRect(0, 0, w, 64, gradient, 255, 255, 255, 50)
        ui.DrawRect(0, 64, w, 5, 0, 0, 0, 255)
 
        --ui.DrawTexturedRect(0, 0, 118, 64, mHeader)
        ui.DrawText("GESTION DE LA VILLE", "tablet_gunstoreheader", w / 2, 32, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
 
    local scroll = vgui.Create("DScrollPanel", layout)
    scroll:SetPos(5, 75)
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
 
    local panek = vgui.Create("DPanel", scroll)
    panek:SetSize(500, 600)
    panek.Paint = function(self, w, h)
        --ui.DrawText("Gestion des impôts (en $)", "workgm_category", 25, 350, color_black, 0, TEXT_ALIGN_CENTER)
       -- ui.DrawText("Gestion de la taxe essence (en %)", "workgm_category", 25, 405, color_black, 0, TEXT_ALIGN_CENTER)
       -- ui.DrawText("Gestion de la taxe de propriété (en $)", "workgm_category", 25, 460, color_black, 0, TEXT_ALIGN_CENTER)
    end
 
    for k,v in pairs(menu_action) do
        actMaire[k] = v.func and v.func() or actMaire[k]
        local actionB = vgui.Create( "DButton", scroll)
        actionB:SetSize(scroll:GetWide() *1 - 35, 35)
        actionB:SetPos(10, 39 * k - 17.5)
        actionB:SetText("")
        actionB.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
            if self.cursor_on then
                if v.off and actMaire[k] then
                    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(0, 100, 0))
                    draw.SimpleText(v.off, "tablet_estorebtn", w/2, h/2, color_white, 1, 1)
                else
                    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(140, 0, 0))
                    draw.SimpleText(v.on, "tablet_estorebtn", w/2, h/2, color_white, 1, 1)
                end
            else
                if v.off and actMaire[k] then
                    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(0, 120, 0))
                    draw.SimpleText(v.off, "tablet_estorebtn", w/2, h/2, color_white, 1, 1)
                else
                    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(180, 0, 0))
                    draw.SimpleText(v.on, "tablet_estorebtn", w/2, h/2, color_white, 1, 1)
                end
            end
        end
        actionB.OnCursorEntered = function(self)
            self.cursor_on = true
        end
        actionB.OnCursorExited = function(self)
            self.cursor_on = false
        end
        actionB.DoClick = function()
            frame.Close(frame)
            if v.action and v.action ~= "" and type(v.action) == "string" then
                if v.action == "addlaw" then
                    Derma_StringRequest("Ajouter une nouvelle loi", "Entrez la loi que vous souhaitez ajouter", "Ma loi", function(text) ply:ConCommand("say /addlaw " .. text) end, nil, "Valider", "Retour")
                elseif v.action == "removelaw" then
                    Derma_StringRequest("Supprimer une loi", "Entrez le numéro de la loi que vous souhaitez supprimer", "0", function(text) ply:ConCommand("say /removelaw " .. text) end, nil, "Valider", "Retour")
                elseif v.action2 and actMaire[k] then
                    ply:ConCommand("say /" .. v.action2)
                else
                    ply:ConCommand("say /" .. v.action)
                end
                return
            end
            if k == -1 then
                panelButton:SetVisible(false)
                panelButton:SetMouseInputEnabled(false)
                panelHelp:SetVisible(true)
                return
            elseif k == 2 then
                if job_tbl then mayorSalaire(job_tbl) return end
            elseif k == 1 or k == 3 then
                net.Start("DoMayorAction")
                net.WriteInt(k, 4)
                net.SendToServer()
            end
        end
    end
 --[[
    impSlider = vgui.Create( "DNumSlider", scroll)
    impSlider:SetPos(0, 325)
    impSlider:SetSize(scroll:GetWide(), 100)
    impSlider:SetText("")
    impSlider:SetMin(0)
   -- impSlider:SetMax(Pichot.maxImpot)
    impSlider:SetValue(actMaire["imp"] or 0)
    impSlider:SetDecimals(0)
 
    essSlider = vgui.Create( "DNumSlider", scroll)
    essSlider:SetPos(0, 380)
    essSlider:SetSize(scroll:GetWide(), 100)
    essSlider:SetText("")
    essSlider:SetMin(0)
    essSlider:SetMax(100)
    essSlider:SetValue(actMaire["ess"] or 0)
    essSlider:SetDecimals(0)
 
    proSlider = vgui.Create( "DNumSlider", scroll)
    proSlider:SetPos(0, 435)
    proSlider:SetSize(scroll:GetWide(), 100)
    proSlider:SetText("")
    proSlider:SetMin(0)
    proSlider:SetMax(Pichot.maxTaxePropriete)
    proSlider:SetValue(actMaire["pro"] or 0)
    proSlider:SetDecimals(0)
 
    local actionBf = vgui.Create( "DButton", scroll)
    actionBf:SetSize(scroll:GetWide() * 1 - 40, 35)
    actionBf:Dock(BOTTOM)
    actionBf:DockMargin(0, 0, 0, 40)
    -- actionBf:SetPos(25, 500)
    actionBf:SetText("")
    actionBf.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, self.cursor_on and Color(0, 140, 240) or Color(0, 120, 240))
        draw.SimpleText("Valider les modifications sur les taxes/impôts", "tablet_estorebtn", w / 2, h / 2, color_white, 1, 1)
    end
    actionBf.DoClick = function()
        local ess, pro, imp = math.Round(tonumber(essSlider:GetValue())), math.Round(tonumber(proSlider:GetValue())), math.Round(tonumber(impSlider:GetValue()))
        local tbl = { ess, pro, imp }
        if not tbl or #tbl ~= 3 then return end
        for k,v in pairs(tbl) do if not v or type(v) ~= "number" or v < 0 then return end end
        frame.Close(frame)
        net.Start("DoMayorAction")
        net.WriteInt(5, 4)
        net.WriteTable(tbl)
        net.SendToServer()
    end
 
    local actionBe = vgui.Create( "DButton", scroll)
    actionBe:SetSize(scroll:GetWide()*1 - 35, 35)
    actionBe:SetPos(10, 295)
    actionBe:SetText("")
    actionBe.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, self.cursor_on and Color(0, 140, 240) or Color(0, 120, 240))
        draw.SimpleText("Gérer les salaires des citoyens", "tablet_estorebtn", w / 2, h / 2, color_white, 1, 1)
    end
    actionBe.DoClick = function() mayorSalaire() end
 ]]
    for k,v in pairs(scroll:GetChildren()) do
        if v:GetName() == "DButton" then
            v.OnCursorEntered = function(self)
                self.cursor_on = true
            end
            v.OnCursorExited = function(self)
                self.cursor_on = false
            end
        end
    end
end
tablet.addApp(APP)