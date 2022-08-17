SWEP.PrintName			= "Tablette" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Author			= "" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 1
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Primary.Delay = 1
SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.ViewModel			= "models/weapons/c_tablet_v2.mdl"
SWEP.WorldModel			= "models/weapons/w_tablet_v2.mdl"
SWEP.UseHands = true

SWEP.ViewModelFOV = 54
local regen = 0


function SWEP:Initialize()
	regen = CurTime()
	self:SetHoldType( "slam" )

end

SWEP.Offset = {
	Pos = {
		Up = -4,
		Right = -3,
		Forward = 1,
	},
	Ang = {
		Up = 0,
		Right = 5,
		Forward = 0,
	}
}


function SWEP:DrawWorldModel( )
	local hand, offset, rotate

	if not IsValid( self.Owner ) then
		self:DrawModel( )
		return
	end

	if not self.Hand then
		self.Hand = self.Owner:LookupAttachment( "anim_attachment_rh" )
	end

	hand = self.Owner:GetAttachment( self.Hand )

	if not hand then
		self:DrawModel( )
		return
	end

	offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up

	hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
	hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
	hand.Ang:RotateAroundAxis( hand.Ang:Up( ), self.Offset.Ang.Up )

	self:SetRenderOrigin( hand.Pos + offset )
	self:SetRenderAngles( hand.Ang )

	self:DrawModel( )
end

function SWEP:Deploy()
	self:SetSkin(2)
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNextPrimaryFire( CurTime() + 1.5 )
	timer.Simple(self:SequenceDuration(),function()
		if(IsValid(self)) then
			self:SetSkin(1)
			self:SendWeaponAnim( ACT_VM_IDLE )
		end
	end)
	return true
end

function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:ConCommand( "tablet_toggle" )


end

function SWEP:SecondaryAttack()

	return

end

function SWEP:Holster(wep)
    return true
end
