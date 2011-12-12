local sRoleDmg	= 'DAMAGER';
local sRoleTank = 'TANK';
local sRoleHeal = 'HEALER';
local sRoleNone = 'NONE';

local frame = nil;
local role = 'NONE';
local isRoleSet = false;
local doCheck = false;
local tTime = 0;
local isInit = false;


local function CheckRole(force)
	if (not force and role ~= sRoleNone) then return; end

	local cr = 0;
	local _, pc = UnitClass('player');
	local iPTT = GetPrimaryTalentTree();
	local roleOld = UnitGroupRolesAssigned('player');

	if (iPTT == nil) then
		role = sRoleNone;
		return;
	end

	if (pc == 'ROGUE' or pc == 'HUNTER' or pc == 'MAGE' or pc == 'WARLOCK') then
		role = sRoleDmg;
	elseif (pc == 'DRUID') then
		if (iPTT == 1) then role = sRoleDmg; end
		if (iPTT == 2) then
			_, _, _, _, cr = GetTalentInfo(iPTT, 19);
			if (cr == 2) then
				role = sRoleDmg;
			else
				role = sRoleTank;
			end
		end
		if (iPTT == 3) then role = sRoleHeal; end
	elseif (pc == 'PALADIN') then
		if (iPTT == 1) then role = sRoleHeal; end
		if (iPTT == 2) then role = sRoleTank; end
		if (iPTT == 3) then role = sRoleDmg; end
	elseif (pc == 'PRIEST') then
		if (iPTT == 1) then role = sRoleHeal; end
		if (iPTT == 2) then role = sRoleHeal; end
		if (iPTT == 3) then role = sRoleDmg; end
	elseif (pc == 'SHAMAN') then
		if (iPTT == 1) then role = sRoleDmg; end
		if (iPTT == 2) then role = sRoleDmg; end
		if (iPTT == 3) then role = sRoleHeal; end
	elseif (pc == 'WARRIOR') then
		if (iPTT == 1) then role = sRoleDmg; end
		if (iPTT == 2) then role = sRoleDmg; end
		if (iPTT == 3) then role = sRoleTank; end
	elseif (pc == 'DEATHKNIGHT') then
		if (iPTT == 1) then role = sRoleTank; end
		if (iPTT == 2) then role = sRoleDmg; end
		if (iPTT == 3) then role = sRoleDmg; end
	end

	--local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles('player');	
	if (roleOld ~= role) then
		isRoleSet = false;
	end
end


local function SetRole(r, isPoll)
	if (r == nil or r == sRoleNone or isRoleSet or (not isPoll and GetNumRaidMembers() <= 0)) then return; end
	isRoleSet = true;
	UnitSetRole('player', r);
end


function SmartRoleSetter_OnEvent(self, event, ...)
	if (not isInit) then return; end

	if (event == 'PLAYER_TALENT_UPDATE') then
		CheckRole(true);
		SetRole(role, false);
	end

	if (event == 'ROLE_POLL_BEGIN') then
		role = sRoleNone;
		CheckRole(true);
		isRoleSet = false;
		SetRole(role, true);
		StaticPopupSpecial_Hide(RolePollPopup);
	end

	if (event == 'RAID_ROSTER_UPDATE' or event == 'PARTY_MEMBERS_CHANGED') then
		doCheck = true;
	end
end


frame = CreateFrame('Frame', 'SmartRoleSetterFrame', UIParent);
frame:SetScript('OnEvent', SmartRoleSetter_OnEvent);
frame:RegisterEvent('PLAYER_TALENT_UPDATE');
frame:RegisterEvent('RAID_ROSTER_UPDATE');
frame:RegisterEvent('ROLE_POLL_BEGIN');
frame:RegisterEvent('PARTY_MEMBERS_CHANGED');
