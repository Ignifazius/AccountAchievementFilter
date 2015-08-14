local _, L = ...;
cryForHelp = false;
local frame = CreateFrame ("Button", "AccAvFFrame", UIParent) -- create a Frame (doesnt Matter which one) to start a function
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function (self,event,...)
	if event == "ADDON_LOADED" then
		addFourthOption()
	end
end)

function addFourthOption()
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE = 4; -- add option 4
	ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE = L["Account Incomplete"]; --set text for dropdownmenu of option 4
	local original_AchievementFrameFilters = AchievementFrameFilters;	--save original
	AchievementFrameFilters = {  --replace original with extended version
		{text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All}, --original
		{text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete}, --original
		{text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_Incomplete} , --original
		{text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_AccIncomplete} --new
		};
	
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION = L["Show all achievements not already completed by this ACCOUNT"]; --set explanation text for option 4
	
	local orig_AchievementFrameFilterStrings = AchievementFrameFilterStrings; --save original
	AchievementFrameFilterStrings = {ACHIEVEMENT_FILTER_ALL_EXPLANATION, --replace original with extended version
ACHIEVEMENT_FILTER_COMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_INCOMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION};
end
		
function AchievementFrame_GetCategoryNumAchievements_AccIncomplete(category) --create function for option 4
	local total, _, missing = GetCategoryNumAchievements (category);
	if (not AchievementFrame_IsFeatOfStrength()) then
		for i = total - missing + 1, total do
			local _, _, _, c1, _, _, _, _, _, _, _, _, c2, c3 = GetAchievementInfo(category, i);
			if (c1 or c2 or c3) then
				missing = missing - 1;
			end
		end
	end
	return missing, 0, total - missing;
end












