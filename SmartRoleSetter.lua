local sRoleDmg	= 'DAMAGER'
local sRoleTank = 'TANK'
local sRoleHeal = 'HEALER'
local sRoleNone = 'NONE'

local frame = CreateFrame('Frame', 'SmartRoleSetterFrame', UIParent)
frame:SetScript('OnEvent', SmartRoleSetter_OnEvent)
frame:RegisterEvent('PLAYER_TALENT_UPDATE')
frame:RegisterEvent('RAID_ROSTER_UPDATE')
frame:RegisterEvent('ROLE_POLL_BEGIN')
frame:RegisterEvent('PARTY_MEMBERS_CHANGED')

local _, pc = UnitClass('player')

local function CheckRole()
	local iPTT = GetPrimaryTalentTree()
	local role = sRoleNone

	if (iPTT) then
		if (pc == 'ROGUE' or pc == 'HUNTER' or pc == 'MAGE' or pc == 'WARLOCK') then
			role = sRoleDmg
		elseif (pc == 'DRUID') then
			if (iPTT == 1) then
				role = sRoleDmg
			elseif (iPTT == 2) then
				-- Assume kitty if specced for "Blood in the Water"
				local _, _, _, _, cr = GetTalentInfo(iPTT, 19)
				if (cr == 2) then
					role = sRoleDmg
				else
					role = sRoleTank
				end
			elseif (iPTT == 3) then
				role = sRoleHeal
			end
		elseif (pc == 'PALADIN') then
			if (iPTT == 1) then
				role = sRoleHeal
			elseif (iPTT == 2) then
				role = sRoleTank
			elseif (iPTT == 3) then
				role = sRoleDmg
			end
		elseif (pc == 'PRIEST') then
			if (iPTT == 1 or iPTT == 2) then
				role = sRoleHeal
			elseif (iPTT == 3) then
				role = sRoleDmg
			end
		elseif (pc == 'SHAMAN') then
			if (iPTT == 1 or iPTT == 2) then
				role = sRoleDmg
			elseif (iPTT == 3) then
				role = sRoleHeal
			end
		elseif (pc == 'WARRIOR') then
			if (iPTT == 1 or iPTT == 2) then
				role = sRoleDmg
			elseif (iPTT == 3) then
				role = sRoleTank
			end
		elseif (pc == 'DEATHKNIGHT') then
			if (iPTT == 1) then
				role = sRoleTank
			elseif (iPTT == 2 or iPTT == 3) then
				role = sRoleDmg
			end
		end
	end

	return role
end


function SmartRoleSetter_OnEvent(self, event, ...)
	if (event == 'ROLE_POLL_BEGIN') then
		local role = CheckRole()
		UnitSetRole('player', role)
		StaticPopupSpecial_Hide(RolePollPopup)
	else
		local roleOld = UnitGroupRolesAssigned('player')
		local role = CheckRole()
		if((role ~= roleOld) and (GetNumRaidMembers() > 0)) then
			UnitSetRole('player', role)
		end
	end
end
