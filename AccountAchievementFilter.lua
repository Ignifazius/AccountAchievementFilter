local _, L = ...;

local frame = CreateFrame ("Button", "AccAvFFrame", UIParent)
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function (self,event,...)
	if event == "ADDON_LOADED" then
		addFourthOption()
	end
end)

function addFourthOption()
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE = 4;
	ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE = L["Account Incomplete"];
	local original_AchievementFrameFilters = AchievementFrameFilters;
	AchievementFrameFilters = { 
		{text=ACHIEVEMENTFRAME_FILTER_ALL, func= AchievementFrame_GetCategoryNumAchievements_All},
		{text=ACHIEVEMENTFRAME_FILTER_COMPLETED, func=AchievementFrame_GetCategoryNumAchievements_Complete},
		{text=ACHIEVEMENTFRAME_FILTER_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_Incomplete} ,
		{text=ACHIEVEMENTFRAME_FILTER_ACCOUNT_INCOMPLETE, func=AchievementFrame_GetCategoryNumAchievements_AccIncomplete}
		};
	
	ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION = L["Show all achievements not already completed by this ACCOUNT"];
	
	local orig_AchievementFrameFilterStrings = AchievementFrameFilterStrings;
	AchievementFrameFilterStrings = {ACHIEVEMENT_FILTER_ALL_EXPLANATION, 
ACHIEVEMENT_FILTER_COMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_INCOMPLETE_EXPLANATION, ACHIEVEMENT_FILTER_ACCOUNT_INCOMPLETE_EXPLANATION};
end
		
function AchievementFrame_GetCategoryNumAchievements_AccIncomplete(category)
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












