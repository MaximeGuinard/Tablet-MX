
local function LoadCS(path)
	if SERVER then
		AddCSLuaFile("tablet/" .. path)
	else
		include("tablet/" .. path)
	end
end

local function LoadSV(path)
	if (SERVER) then
		include("tablet/" .. path)
	end
end

LoadCS("ui.lua")
LoadCS("init.lua")
LoadCS("config.lua")

LoadCS("client/apps.lua")
LoadCS("client/main.lua")

--LoadCS("client/command.lua")
LoadCS("client/estore.lua")
LoadCS("client/gunshop.lua")
LoadCS("client/webbrowser.lua")
LoadCS("client/advert.lua")
LoadCS("client/mayor.lua")
LoadCS("client/discorddevsource.lua")
LoadCS("client/jobs.lua")
LoadCS("client/discordliferp.lua")
LoadCS("client/workshop.lua")
LoadCS("client/foodstore.lua")


LoadSV("netstrings.lua")