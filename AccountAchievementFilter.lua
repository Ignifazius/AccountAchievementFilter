local _, L = ...;
cryForHelp = false;
local frame = CreateFrame ("Button", "AccAvFFrame", UIParent) -- create a Frame (doesnt Matter which one) to start a function
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function (self,event,arg1,...)
	if (event == "ADDON_LOADED" and arg1 =="Blizzard_AchievementUI") then
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
	--ACHIEVEMENT_FILTER_ACCOUNT_TEST = 5;

	ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE = L["Account Incomplete"]; --set text for dropdownmenu of option 4
	--ACHIEVEMENTFRAME_FILTER_ACCOUNT_TEST = L["TEST"];
	local original_AchievementFrameFilters = AchievementFrameFilters;	--save original
	AchievementFrameFilters = {  --replace original with extended version
		{text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All}, --original
		{text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete}, --original
		{text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_CharIncomplete}, --new
        {text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_Incomplete} --original
		--{text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE, func=AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_AccIncomplete}--, --new
		--{text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_TEST, func=AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_CharIncomplete}
		}
	
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION = L["Show all achievements not already completed by this ACCOUNT"]; --set explanation text for option 4
	--ACHIEVEMENT_FILTER_ACCOUNT_TEST_EXPLANATION = L["Test Explanation"]; --set explanation text for option 4

	local orig_AchievementFrameFilterStrings = AchievementFrameFilterStrings; --save original
	AchievementFrameFilterStrings = {ACHIEVEMENT_FILTER_ALL_EXPLANATION, --replace original with extended version
ACHIEVEMENT_FILTER_COMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_INCOMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION} --ACHIEVEMENT_FILTER_ACCOUNT_TEST_EXPLANATION};
end
		
function AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_AccIncomplete(category)
	--print("debug: "..category)
	local total, completed, missing = GetCategoryNumAchievements (category);
	local TEMPmissing = total - completed;
	return TEMPmissing, 0, total - TEMPmissing;
end

function AccountAchievementFilter_AchievementFrame_GetCategoryNumAchievements_CharIncomplete(category)
	--print("debug: "..category)
	local total, completed, missing = GetCategoryNumAchievements (category);
	local TEMPmissing = 0
	--print("before "..TEMPmissing)
	--if (not AchievementFrame_IsFeatOfStrength()) then --seems do to... nothing?
		--for i = total - missing + 1, total do
		for i = 1, total do
			--local id, name, points, completedB, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(category, i)
			local _, _, _, completedB, _, _, _, _, _, _, _, _, wasEarnedByMe, _ = GetAchievementInfo(category, i)
            --print(completedB, wasEarnedByMe, earnedBy)
			if ((completedB and not wasEarnedByMe) or not completedB) then
				TEMPmissing = TEMPmissing + 1;
				--print("counting up")
			end
		end
	--end
	--return missing, 0, total - missing;
	--print("after "..TEMPmissing)
	return TEMPmissing, 0, total - TEMPmissing;
end

local configFrame = CreateFrame('Frame');
local configTitle = nil;
local configWelcome = nil;
local welcome = nil;

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
		PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
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
	
	configWelcome = AccountAchievementFilter_CreateCheckbox(
    	L["Display welcome message"],
    	L["Enables the display of the welcome message after login."],
    	function(self, value) AccountAchievementFilter_DisplayWelcome(value) end)
    configWelcome:SetPoint("TOPLEFT", configTitle, "BOTTOMLEFT", 0, -8)
	
	configBottom = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    configBottom:SetPoint("BOTTOMLEFT", 16, 16)
    configBottom:SetText("If you want to help translating this addon, visit\n http://wow.curseforge.com/addons/account-achievement-filter/ \nor write me a PM on Curse. \nCurrently only German, English and Portuguese translations are available.")
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


function AccountAchievementFilter_DisplayWelcome(bool)
	welcome = bool;
end

function AccountAchievementFilter_WelcomeMessage()
	if (WelcomeBool) then
		DEFAULT_CHAT_FRAME:AddMessage(L["Welcome to|cff33FFFF AccountAchievementFilter|r!"])
		--DEFAULT_CHAT_FRAME:AddMessage(L["Welcome to|cff33FFFF AccountAchievementFilter|r 3.0! Blizzard changed the default incomplete to account-incomplete, so this addon will now add the option they removed (everything should work as before)."])
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
end

function AccountAchievementFilter_load()
	welcome = WelcomeBool
end

function AccountAchievementFilter_save()
	WelcomeBool = welcome;
end

function AccountAchievementFilter_init()
	if (WelcomeBool == nil) then
		WelcomeBool = true;
		configWelcome:SetChecked(true)
	end	
end