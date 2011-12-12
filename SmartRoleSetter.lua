-------------------------------------------------------------------------------
-- SmartRoleSetter
-- Created by Aeldra (EU-Proudmoore)
--
-- Sets automatically your role in the raid based on your skill tree.
-------------------------------------------------------------------------------

SLASH_SMARTROLESETTER1 = "/srs";
SLASH_SMARTROLESETTER2 = "/srole";

local sRoleDmg  = "DAMAGER";
local sRoleTank = "TANK";
local sRoleHeal = "HEALER";
local sRoleNone = "NONE";

local _O  = nil;
local frame = nil;
local role = "NONE";
local isRoleSet = false;
local doCheck = false;
local tTime = 0;
local isInit = false;


local function CheckRole(force)
  if (not force and role ~= sRoleNone) then return; end

  local cr = 0;
  local _, pc = UnitClass("player");
  local iPTT = GetPrimaryTalentTree();
  local roleOld = UnitGroupRolesAssigned("player");
  
  --print("Current role = "..roleOld);
  
  if (iPTT == nil) then
    --print("No primary talent tree found!");
    role = sRoleNone;
    return;
  end

  if (pc == "ROGUE" or pc == "HUNTER" or pc == "MAGE" or pc == "WARLOCK") then
    role = sRoleDmg;
  elseif (pc == "DRUID") then
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
  elseif (pc == "PALADIN") then
    if (iPTT == 1) then role = sRoleHeal; end
    if (iPTT == 2) then role = sRoleTank; end
    if (iPTT == 3) then role = sRoleDmg; end
  elseif (pc == "PRIEST") then
    if (iPTT == 1) then role = sRoleHeal; end
    if (iPTT == 2) then role = sRoleHeal; end
    if (iPTT == 3) then role = sRoleDmg; end
  elseif (pc == "SHAMAN") then
    if (iPTT == 1) then role = sRoleDmg; end
    if (iPTT == 2) then role = sRoleDmg; end
    if (iPTT == 3) then role = sRoleHeal; end
  elseif (pc == "WARRIOR") then
    if (iPTT == 1) then role = sRoleDmg; end
    if (iPTT == 2) then role = sRoleDmg; end
    if (iPTT == 3) then role = sRoleTank; end
  elseif (pc == "DEATHKNIGHT") then
    if (iPTT == 1) then role = sRoleTank; end
    if (iPTT == 2) then role = sRoleDmg; end
    if (iPTT == 3) then role = sRoleDmg; end
  end
  
  --local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player");  
  if (roleOld ~= role) then
    isRoleSet = false;
    --print("Detected role = "..role);
  end
end


local function SetRole(r, isPoll)
  if (r == nil or r == sRoleNone or isRoleSet or (not isPoll and GetNumRaidMembers() <= 0)) then return; end
  isRoleSet = true;
  UnitSetRole("player", r);
  --print("Role set to -> "..r);
end


function SmartRoleSetter_OnEvent(self, event, ...)
  --print("SmartRoleSetter"..event);
  if (not isInit) then return; end  
  if (not _O.isOn) then return; end  
  
  if (event == "PLAYER_TALENT_UPDATE") then
    CheckRole(true);
    SetRole(role, false);
  end
  
  if (event == "ROLE_POLL_BEGIN" and _O.isAuto) then
    role = sRoleNone;
    CheckRole(true);
    isRoleSet = false;
    SetRole(role, true);
    StaticPopupSpecial_Hide(RolePollPopup);
  end
    
  if (event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED") then
    doCheck = true;
  end  
end


function SmartRoleSetter_OnUpdate(self, elapsed)
  tTime = tTime + elapsed;
  if (tTime > 1.0) then
    tTime = 0.0;    
    if (isInit) then
      if (_O.isOn and doCheck) then
        doCheck = false;
        CheckRole(false);
        SetRole(role, false);
      end
    else    
      local sName = GetTalentInfo(1, 1);
      if (sName) then
        -- Settings --------------------
        if (SMARTROLESETTER_Options == nil) then SMARTROLESETTER_Options = { }; end
        _O = SMARTROLESETTER_Options;
        if (_O.isOn == nil) then _O.isOn = true; end
        if (_O.isAuto == nil) then _O.isAuto = true; end
        print("SmartRoleSetter loaded");
        --------------------------------
        isInit = true;
        doCheck = true;
      end
    end
  end
end


function SlashCmdList.SMARTROLESETTER(...)
  local msg = ...;    
  if (msg == "") then
    _O.isOn = not _O.isOn;
    print("SmartRoleSetter active = "..tostring(_O.isOn));
    if (_O.isOn) then
      CheckRole(true);
      SetRole(role, false);
    end
  elseif (msg == "auto") then
    _O.isAuto = not _O.isAuto;
    print("SmartRoleSetter auto accept role poll = "..tostring(_O.isAuto));
  elseif (msg == "t1") then
    RolePollPopup_Show(RolePollPopup);
  elseif (msg == "t2") then
    StaticPopupSpecial_Hide(RolePollPopup);
  else
    print("SmartRoleSetter:");
    print("Active = "..tostring(_O.isOn));
    print("Auto accept role poll = "..tostring(_O.isAuto));
  end
end

frame = CreateFrame("Frame", "SmartRoleSetterFrame", UIParent);
frame:SetScript("OnEvent", SmartRoleSetter_OnEvent);
frame:SetScript("OnUpdate", SmartRoleSetter_OnUpdate);
frame:RegisterEvent("PLAYER_TALENT_UPDATE");
frame:RegisterEvent("RAID_ROSTER_UPDATE");
frame:RegisterEvent("ROLE_POLL_BEGIN");
frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
