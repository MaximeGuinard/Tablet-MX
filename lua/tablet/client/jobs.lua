local APP = {}
APP.ID = "jobs"
APP.Name = "Travail.LIFE"
APP.SortOrder = 1
APP.Icon = Material("ugc/tablet/workgm.png", "smooth")

function APP:getCityName()
	local map = game.GetMap()
	local mapParts = {}
	for str in map:gmatch("%a+") do table.insert(mapParts, str) end
	return mapParts[2] and mapParts[2]:gsub("^%l", function(l) return l:upper() end) or map
end

local working = {}
local function canBecome(job)
	if job.admin and job.admin > 0 and !LocalPlayer():IsAdmin() then
		return false, "Admin Only"
	elseif job.level and (LocalPlayer():getDarkRPVar("level") or 1) < job.level then
		return false, "Niveau faible"
	elseif job.customCheck and !job.customCheck(LocalPlayer(), job) then
		if job.CustomCheckFailMsg then
			if type(job.CustomCheckFailMsg) == "function" then
				return false, job.CustomCheckFailMsg(LocalPlayer(), job)
			else
				return false, tostring(job.CustomCheckFailMsg)
			end
		end
		return false
	end

	return true
end

local ui = tablet.ui
surface.CreateFont("workgm_category", {font = "Roboto", size = 24, weight = 1000})
surface.CreateFont("workgm_jobname", {font = "Roboto", size = 18})
function APP:onOpen(layout, frame)
	layout.Paint = function(self, w, h) ui.DrawRect(0, 0, w, h, 244, 245, 246) end

	local lw, lh = layout:GetWide(), layout:GetTall()
	local headerSize = frame:scale(120)
	local header = vgui.Create("DPanel", layout)
	local searchbox = vgui.Create("DPanel", layout)
	local jobscroll = vgui.Create("mgScrollPanel", layout)
	local joblayout = vgui.Create("DIconLayout", jobscroll)

	surface.CreateFont("workgm_title", {font = "Roboto", size = headerSize * 0.8})

	header:SetSize(lw, headerSize)
	header.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 0, 176, 243)
		ui.DrawText("Travail.LIFE", "workgm_title", h * 0.15, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	searchbox:SetSize(lw - 20, 30)
	searchbox:SetPos(10, headerSize + 10)
	searchbox.Paint = function() end
	searchbox.xn = 0

	searchbox.entry = vgui.Create("mgTextEntry", searchbox)
	searchbox.entry:SetSize(lw * 0.6, 30)
	searchbox.entry:SetGhostText("Recherche par nom...")
	searchbox.xn = searchbox.entry:GetWide() + 10

	searchbox.city = vgui.Create("mgTextEntry", searchbox)
	searchbox.city.x = searchbox.xn
	searchbox.city:SetSize(lw * 0.1, 30)
	searchbox.city:SetText("")
	searchbox.city.name = self:getCityName()
	searchbox.city.PaintOver = function(self, w, h) ui.DrawText(self.name, "Default", w / 2, h / 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
	searchbox.city.DrawTextEntryText = function() end
	searchbox.city.AllowInput = function() return true end
	searchbox.xn = searchbox.xn + searchbox.city:GetWide() + 10

	searchbox.btn = vgui.Create("DButton", searchbox)
	searchbox.btn.x = searchbox.xn
	searchbox.btn:SetSize(searchbox:GetWide() - searchbox.xn, 30)
	searchbox.btn:SetText("Recherche")
	searchbox.btn:SetTextColor(color_white)
	searchbox.btn:SetFont("Default")
	searchbox.btn.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, Color(228, 36, 105)) end
	searchbox.btn.DoClick = function() joblayout:fill(searchbox.entry:GetValue()) end
	searchbox.entry.OnEnter = function(self) searchbox.btn:DoClick(); self:RequestFocus() end

	jobscroll:SetSize(lw - 20, lh - headerSize - 60)
	jobscroll:SetPos(10, headerSize + 50)

	joblayout:SetSize(jobscroll:GetSize())
	joblayout.Think = function(self, ...)
		if jobscroll.VBar.Enabled then
			joblayout:SetWide(jobscroll:GetWide() - jobscroll.VBar:GetWide() - 5)
		else
			joblayout:SetWide(jobscroll:GetWide())
		end
	end

	joblayout.fill = function(self, filter)
		local categories = DarkRP.getCategories().jobs
		self:Clear()
		if filter and #filter > 0 then
			local temp = {}
			for catid, cat in pairs(categories) do
				for jobid, job in pairs(cat.members or {}) do
					if job.name:lower():find(filter:lower()) then
						if !temp[catid] then
							temp[catid] = table.Copy(cat)
							temp[catid].members = {}
						end
						temp[catid].members[jobid] = job
					end
				end
			end
			categories = temp
		end

		local ypos = 0
		for _, cat in SortedPairsByMemberValue(categories, "sortOrder") do
			if table.Count(cat.members) < 1 then continue end
			local cpnl = vgui.Create("DPanel", joblayout)
			cpnl:SetPos(0, ypos)
			cpnl.minSize = 40
			cpnl.maxSize = cpnl.minSize + 10
			cpnl:SetSize(joblayout:GetWide(), cpnl.minSize)
			cpnl.Toggle = function(self) 
				self:SizeTo(self:GetWide(), self.toggled and self.minSize or self.maxSize, 0.5)
				self.toggled = !self.toggled
				cookie.Set("tablet_jobtab" .. cat.name, self.toggled and 1 or 0)
			end
			cpnl.Paint = function(self, w, h)
				self:SetWide(joblayout:GetWide())
				ui.DrawRect(0, 0, w, h, color_white)
				ui.DrawOutlinedRect(0, 0, w, h, 233, 235, 237)
			end

			cpnl.toggle = vgui.Create("DButton", cpnl)
			cpnl.toggle:SetSize(cpnl:GetWide(), cpnl.minSize)
			cpnl.toggle:SetText("")
			cpnl.toggle.Paint = function(self, w, h)
				self:SetWide(cpnl:GetWide())
				ui.DrawRect(0, 0, w, h, cat.color.r, cat.color.g, cat.color.b, 200)
				ui.DrawText(cat.name, "workgm_category", (h - 12) / 2 + 1, h / 2 + 1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				ui.DrawText(cat.name, "workgm_category", (h - 12) / 2, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				joblayout:Layout()
			end
			cpnl.toggle.DoClick = function() cpnl:Toggle() end

			local jp_y = cpnl.minSize + 5
			for _, job in SortedPairsByMemberValue(cat.members or {}, "sortOrder") do
				if job.tablet_hide then continue end
				if tablet.config.hideNonBuyable and !canBecome(job) then continue end
				if !job.team then continue end
				local jp = vgui.Create("DPanel", cpnl)
				jp:SetPos(5, jp_y)
				jp:SetSize(cpnl:GetWide() - 10, 64)
				jp.Paint = function(self, w, h) 
					self:SetWide(cpnl:GetWide() -10) ui.DrawRect(0, 0, w, h, 245, 245, 245) ui.DrawOutlinedRect(0, 0, w, h, 233, 235, 237) ui.DrawRect(h, 1, 1, h - 2) 																																																																																	--[[Nope =3]]
					if IsValid(self.become) then self.become:SetVisible(job.team != LocalPlayer():Team()) end
				end
				jp.canBecome = function() return canBecome(job) end

				local preferredModel = DarkRP.getPreferredJobModel(job.team)
				jp.mdl = vgui.Create("ModelImage", jp)
				jp.mdl:SetPos(1, 1)
				jp.mdl:SetSize(jp:GetTall() - 2, jp:GetTall() - 2)
				jp.mdl.models = type(job.model) == "table" and job.model or {job.model}
				jp.mdl:SetModel(jp.mdl.models[1] or "")
				jp.mdl.curID = 1
				for k, v in ipairs(jp.mdl.models) do if v == preferredModel then jp.mdl.curID = k; jp.mdl:SetModel(v); break end end
				jp.mdl.next = function(self)
					local id = (jp.mdl.curID + 1) % #self.models
					if id == 0 then id = #self.models end
					self.curID = id
					self:SetModel(self.models[id])
					DarkRP.setPreferredJobModel(job.team, self.models[id])
				end
				if #jp.mdl.models > 1 then
					jp.mdl:SetCursor("hand")
					jp.mdl.OnMousePressed = function(self) self:next() end
				end

				jp.name = vgui.Create("DLabel", jp)
				jp.name:SetPos(jp:GetTall() + 10, 5)
				jp.name:SetText(job.name .. " (" .. job.salary .. "€)")
				jp.name:SetFont("workgm_jobname")
				jp.name:SizeToContents()
				jp.name:SetColor(job.color or color_black)

				if job.max and job.max > 0 then
					jp.name.Think = function(self, w, h)
						working[job.team] = #team.GetPlayers(job.team)
						jp.name:SetText(job.name .. " (" .. working[job.team] .. "/" .. job.max .. ")" .. " (" .. job.salary .. "$)")
						jp.name:SizeToContents()
					end
				end

				local desc = job.description and job.description:gsub("[ ]+", " ") or "Aucune description donnée."
				jp:SetTooltip(" " .. desc)

				jp.description = vgui.Create("DLabel", jp)
				jp.description:SetPos(jp:GetTall() + 10, jp:GetTall() - 21)
				jp.description:SetText(string.Explode("\n", desc)[1] or "")
				jp.description:SetFont("workgm_jobname")
				jp.description:SetColor(Color(120, 120, 120))
				jp.description.Think = function(self) self:SetWide(jp:GetWide() - jp:GetTall() - 50) end

				jp.become = vgui.Create("DButton", jp)
				jp.become:SetSize(100, 25)
				jp.become:SetPos(jp:GetWide() - 105, 5)
				jp.become.Paint = function(self, w, h) 
					self.x = jp:GetWide() - w - 5
					local canBecome, reason = jp:canBecome()
					local clr = (!canBecome and Color(150, 150, 150)) or (self.Hovered and Color(228, 36, 105, 230)) or Color(228, 36, 105, 200)
					draw.RoundedBox(6, 0, 0, w, h, clr)
					self:SetDisabled(!canBecome)

					if reason then
						surface.DisableClipping(true)
							ui.DrawText(reason, "DermaDefaultBold", w / 2, h + 5, Color(228, 36, 105, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
						surface.DisableClipping(false)
					end
				end
				jp.become:SetFont("DermaDefaultBold")
				jp.become:SetText(job.vote and "Send a Resume" or "Become")
				jp.become:SetTextColor(color_white)
				jp.become.DoClick = function()
					RunConsoleCommand("darkrp", (job.vote and "vote" or "") .. job.command)
				end

				--jp.become:Remove()

				jp_y = jp_y + jp:GetTall() + 5
			end

			cpnl.maxSize = jp_y

			if cookie.GetNumber("tablet_jobtab" .. cat.name, cat.startExpanded and 1 or 0) == 1 then cpnl.toggled = true; cpnl:SetTall(cpnl.maxSize) end

			ypos = ypos + cpnl:GetTall() + 10
		end
	end
	joblayout:fill()
end

tablet.addApp(APP)