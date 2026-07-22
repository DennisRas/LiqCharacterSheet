---@class LCS_Addon
local addon = select(2, ...)

local name, title, notes = C_AddOns.GetAddOnInfo(select(1, ...))
addon.name = name
addon.title = title
addon.notes = notes
addon.version = C_AddOns.GetAddOnMetadata(name, "Version") or ""

--@debug@
_G[addon.name] = addon
--@end-debug@
