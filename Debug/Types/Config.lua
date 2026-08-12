---@class LCS_ColorTable
---@field r number
---@field g number
---@field b number
---@field a number?

---@class LCS_ConfigColors
---@field enchants LCS_ColorTable
---@field enchantsMissing LCS_ColorTable
---@field texture LCS_ColorTable
---@field levels LCS_ColorTable
---@field maxLevels LCS_ColorTable
---@field maxLevelsUpgraded LCS_ColorTable

---@class LCS_ConfigFonts
---@field font string
---@field size number
---@field outline string

---@class LCS_ConfigShow
---@field levels boolean
---@field maxLevels boolean
---@field enchants boolean
---@field enchantsMissing boolean
---@field gems boolean

---@class LCS_Config
---@field colors LCS_ConfigColors
---@field fonts LCS_ConfigFonts
---@field show LCS_ConfigShow
