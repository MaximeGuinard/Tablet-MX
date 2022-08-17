
if SERVER then return nil end

local ui = {}

ui.DrawText = draw.SimpleText
ui.SetDrawColor = surface.SetDrawColor

ui.DrawRect = function(x, y, w, h, ...)
	if (...) then
		surface.SetDrawColor(...)
	end
	surface.DrawRect(x, y, w, h)
end

local blur = Material( "pp/blurscreen" )
ui.DrawBlurRect = function (panel, amount, heavyness)
	local x, y = panel:LocalToScreen( 0, 0 )
	local wasEnabled = DisableClipping( true )

	-- Menu cannot do blur
	if ( !MENU_DLL ) then
		surface.SetMaterial( blur )
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i=0, 2 do
			blur:SetFloat( "$blur", (i / 3) * (amount or 4) )
			blur:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
	end

	surface.SetDrawColor( 10, 10, 10, 200 * 1 )
	surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )

	DisableClipping( wasEnabled )
   
end

ui.DrawTexturedRect = function(x, y, w, h, mat, ...)
   	if (...) then
        surface.SetDrawColor(...)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

ui.DrawLine = function(startx, starty, endx, endy, ...)
    if (...) then
        surface.SetDrawColor(...)
    end
    surface.DrawLine(startx, starty, endx, endy)
end

ui.DrawOutlinedRect = function(x, y, w, h, ...)
    if (...) then
        surface.SetDrawColor(...)
    end
    surface.DrawOutlinedRect(x, y, w, h)
end

ui.GetTextSize = function(font, text)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

ui.CreateCirclePoly = function(x, y, radius, seg)
	local tbl = {}

	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		local aSin, aCos = math.sin(a), math.cos(a)

		tbl[i + 1] = {x = x + aSin * radius, y = y + aCos * radius, u = aSin / 2 + 0.5, v = aCos / 2 + 0.5}
	end

	return tbl
end

ui.DrawPreMadeCircle = surface.DrawPoly

ui.DrawCircle = function(x, y, radius, seg)
	surface.DrawPoly(ui.CreateCirclePoly(x, y, radius, seg))
end

ui.LerpColor = function(fr, from, to)
    from.a = from.a or 255
    to.a = to.a or 255

    return Color(
        Lerp(fr, from.r, to.r),
        Lerp(fr, from.g, to.g),
        Lerp(fr, from.b, to.b),
        Lerp(fr, from.a, to.a))
end

ui.DrawTexturedRectRotated = function(x, y, w, h, material, rotation, ...)
    if (...) then
        surface.SetDrawColor(...)
    else
        surface.SetDrawColor(255, 255, 255, 255)
    end

    surface.SetMaterial(material)
    surface.DrawTexturedRectRotated(x, y, w, h, rotation)
end

local mError = Material("something.vtf")
ui.NullMaterial = mError
ui.DownloadMaterial = function(url, params, callback)
    local crc = util.CRC(url)
    if file.Exists("ugc/saved/" .. crc .. ".png", "DATA") then
        callback(Material("../data/ugc/saved/" .. crc .. ".png", params))
        return
    end
    http.Fetch(url, function(body)
        file.Write("ugc/saved/" .. crc .. ".png", body)
        callback(Material("../data/ugc/saved/" .. crc .. ".png", params))
    end,
    function(err)
        ugc.error("error downloading material (" .. url .. "): " .. (err or "unknown error"))
        callback(mError)
    end)
end

return ui 