local _, L = ...;
cryForHelp = false;
local frame = CreateFrame ("Button", "AccAvFFrame", UIParent) -- create a Frame (doesnt Matter which one) to start a function
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function (self,event,...)
	if event == "ADDON_LOADED" then
		AccountAchievementFilter_addFourthOption()		
	end
	if event == "PLAYER_LOGIN" then
		AccountAchievementFilter_createMenuFrame()
		AccountAchievementFilter_load()
		AccountAchievementFilter_init()
		AccountAchievementFilter_WelcomeMessage()
	end
	if event == "PLAYER_LOGOUT" then
		AccountAchievementFilter_save()
	end
end)


function AccountAchievementFilter_addFourthOption()
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE = 4; -- add option 4
	ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE = L["Account Incomplete"]; --set text for dropdownmenu of option 4
	local original_AchievementFrameFilters = AchievementFrameFilters;	--save original
	AchievementFrameFilters = AccountAchievementFilter_FixBlizzardBug(BlizzardFixBool);
	
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION = L["Show all achievements not already completed by this ACCOUNT"]; --set explanation text for option 4
	
	local orig_AchievementFrameFilterStrings = AchievementFrameFilterStrings; --save original
	AchievementFrameFilterStrings = {ACHIEVEMENT_FILTER_ALL_EXPLANATION, --replace original with extended version
ACHIEVEMENT_FILTER_COMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_INCOMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION};
end
		
function AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_AccIncomplete(category) --create function for option 4
	--print("debug: "..category)
	local total, completed, missing = GetCategoryNumAchievements (category);
	local TEMPmissing = total - completed;
	--print("before "..TEMPmissing)
	--[[if (not AchievementFrame_IsFeatOfStrength()) then --seems do to... nothing?
		--for i = total - missing + 1, total do
		for i = total - TEMPmissing + 1, total do
			local _, _, _, c1, _, _, _, _, _, _, _, _, c2, c3 = GetAchievementInfo(category, i);
			if (c1 or c2 or c3) then
				TEMPmissing = TEMPmissing - 1;
				print("counting down")
			end
		end
	end]]--
	--return missing, 0, total - missing;
	--print("after "..TEMPmissing)
	return TEMPmissing, 0, total - TEMPmissing;
end

local configFrame = CreateFrame('Frame');
local configTitle = nil;
local configWelcome = nil;
local configFix = nil;
local welcome = nil;
local blizzFix = nil;

function AccountAchievementFilter_createMenuFrame()
	AccountAchievementFilter_CreateConfigFrame()
	configFrame.name = "AccountAchievementFilter";
	configFrame.refresh = AccountAchievementFilter_refresh;
	configFrame.default = AccountAchievementFilter_reset;
	InterfaceOptions_AddCategory(configFrame)
end



function AccountAchievementFilter_CreateCheckbox(label, description, onClick)
	local check = CreateFrame("CheckButton", "IAConfigCheckbox" .. label, configFrame, "InterfaceOptionsCheckButtonTemplate")
	check:SetScript("OnClick", function(self)
		PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		onClick(self, self:GetChecked() and true or false)
	end)
	check.label = _G[check:GetName() .. "Text"]
	check.label:SetText(label)
	check.tooltipText = label
	check.tooltipRequirement = description
	return check
end

function AccountAchievementFilter_CreateConfigFrame()
	configTitle = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    configTitle:SetPoint("TOPLEFT", 16, -16)
    configTitle:SetText("Account Achievement Filter")

    configFix = AccountAchievementFilter_CreateCheckbox(
    	L["Use AV \"incomplete\" fix"],
    	L["Fixes a current bug in GetCategoryNumAchievements(). This MAY break stuff in future blizzard updates."],
    	function(self, value) AccountAchievementFilter_FixBlizzardBugMENUBUTTON(value) end)
    configFix:SetPoint("TOPLEFT", configTitle, "BOTTOMLEFT", 0, -8)
	
	configWelcome = AccountAchievementFilter_CreateCheckbox(
    	L["Display welcome message"],
    	L["Enables the display of the welcome message after login."],
    	function(self, value) AccountAchievementFilter_DisplayWelcome(value) end)
    configWelcome:SetPoint("TOPLEFT", configFix, "BOTTOMLEFT", 0, -8)
	
	configBottom = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    configBottom:SetPoint("BOTTOMLEFT", 16, 16)
    configBottom:SetText("If you want to help translating this addon, visit\n http://wow.curseforge.com/addons/account-achievement-filter/ \nor write me a PM on Curse. \nCurrently only German, English and Portuguese translations are available.")
end

function AccountAchievementFilter_FixBlizzardBug(bool)
	blizzFix = bool;
	if bool then
		fix = {  --replace original with FIXED extended version
			{text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All}, --original
			{text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete}, --original
			{text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_Incomplete} , -- fix
			{text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE, func=AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_AccIncomplete} --new
			}
	else
		fix = {  --replace original with UNFIXED extended version
			{text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All}, --original
			{text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete}, --original
			{text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_Incomplete} , --original / unfixed
			{text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE, func=AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_AccIncomplete} --new
			}
	end
	return fix
end


StaticPopupDialogs["AAF_RELOADUI"] = {
  text = L["This will become active after you reload. Reload UI now?"],
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
      ReloadUI()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

function AccountAchievementFilter_FixBlizzardBugMENUBUTTON(bool)
	blizzFix = bool;
	--[[if bool then
	--DEFAULT_CHAT_FRAME:AddMessage(wname.." pinged by: |cffFF0000" .. ping_name .. "|r")
		DEFAULT_CHAT_FRAME:AddMessage(L["|cff33FFFF AccountAchievementFilter|r: AV fix|cff33FF33 enabled|r. It will become active after you reload/relog."])
	else
		DEFAULT_CHAT_FRAME:AddMessage(L["|cff33FFFF AccountAchievementFilter|r: AV fix|cffFF0000 disabled|r. It will become active after you reload/relog."])
	end]]--
	StaticPopup_Show("AAF_RELOADUI")
end

function AccountAchievementFilter_getEnabled()
	if blizzFix then
		return "|cff33FF33 "..L["enabled"].."|r"
	else
		return "|cffFF0000 "..L["disabled"].."|r"
	end	
end


function AccountAchievementFilter_DisplayWelcome(bool)
	welcome = bool;
end

function AccountAchievementFilter_WelcomeMessage()
	if (WelcomeBool) then
		DEFAULT_CHAT_FRAME:AddMessage(L["Welcome to|cff33FFFF AccountAchievementFilter|r! There is a bug affecting the |cffFF9933incomplete|r option in your achievements. You can enable a fix from the option menu of this addon (currently"]..AccountAchievementFilter_getEnabled()..").")
	end
end

function AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_Incomplete(categoryID)
	local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID);	
	local TEMPnumIncomplete = 0;
	
	if (not AchievementFrame_IsFeatOfStrength()) then 
		for i = 1, numAchievements do
			local _, _, _, c1, _, _, _, _, _, _, _, _, c2, c3 = GetAchievementInfo(categoryID, i);
			if (not c1) or(c1 and not c2) then 
				TEMPnumIncomplete = TEMPnumIncomplete + 1;
			end
		end
	end
	return TEMPnumIncomplete, 0, numAchievements-TEMPnumIncomplete;
end

function AccountAchievementFilter_refresh()
	configWelcome:SetChecked(WelcomeBool)
	configFix:SetChecked(BlizzardFixBool)
end

function AccountAchievementFilter_load()
	welcome = WelcomeBool
	blizzFix = BlizzardFixBool;
end

function AccountAchievementFilter_save()
	WelcomeBool = welcome;
	BlizzardFixBool = blizzFix;
end

function AccountAchievementFilter_init()
	if (BlizzardFixBool == nil) then
		BlizzardFixBool = false;
		configFix:SetChecked(false)
	end
	if (WelcomeBool == nil) then
		WelcomeBool = true;
		configWelcome:SetChecked(true)
	end	
end

















