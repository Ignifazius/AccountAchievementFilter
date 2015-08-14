local addonName, L = ...; -- Let's use the private table passed to every .lua file to store our locale
local function defaultFunc(L, key)
 -- If this function was called, we have no localization for this key.
 -- We could complain loudly to allow localizers to see the error of their ways, 
 -- but, for now, just return the key as its own localization. This allows you to—avoid writing the default localization out explicitly.
	--print("AccountAchievementFilter: If you are reading this, your Language is currently not supported by AccountAchievementFilter. The used Language was set to English. You can help translate this Addon (currently only 2 sentences) at Curse.com")
 return key;
end
setmetatable(L, {__index=defaultFunc});