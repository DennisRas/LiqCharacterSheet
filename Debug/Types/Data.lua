---@class LCS_UpgradeTrack
---@field maxLevel number
---@field bonusIDs number[]

---@class LCS_Season
---@field seasonID number
---@field seasonDisplayID number
---@field maxUpgradeLevel number
---@field tracks LCS_UpgradeTrack[]

---@class LCS_Data
---@field slots table<number, LCS_Slot>
---@field seasons LCS_Season[]
