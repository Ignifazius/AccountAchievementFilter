local addonName, L = ...;
local function defaultFunc(L, key)
 --just return the key as its own localization. This allows you to—avoid writing the default localization out explicitly.
	if (cryForHelp) then
		print("AccountAchievementFilter: If you are reading this, your Language is currently not supported by AccountAchievementFilter. The used Language was set to English. You can help translate this Addon (currently only 2 sentences) at Curse.com")
	end
 return key;
end
setmetatable(L, {__index=defaultFunc});