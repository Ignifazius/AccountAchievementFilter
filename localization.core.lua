local addonName, L = ...;
local function defaultFunc(L, key)
 --just return the key as its own localization. This allows you to—avoid writing the default localization out explicitly.
 return key;
end
setmetatable(L, {__index=defaultFunc});