if SERVER then

util.AddNetworkString("GiveTablettePlayer")
util.AddNetworkString("RetirerTablettePlayer")

net.Receive("GiveTablettePlayer", function(len, ply)

	ply:Give("maxou_tabletfq")
	ply:SelectWeapon("maxou_tabletfq")
end)

net.Receive("RetirerTablettePlayer", function(len, ply)

	ply:StripWeapon("maxou_tabletfq")


end)

end