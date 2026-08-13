---@class LCS_Addon
local addon = select(2, ...)

---@class LCS_Data
local Data = {}
addon.Data = Data

---@type table<number, LCS_Slot>
Data.slots = {
  [1] = {id = 1, side = "LEFT", name = "Head", canEnchant = true},
  [2] = {id = 2, side = "LEFT", name = "Neck", canEnchant = false},
  [3] = {id = 3, side = "LEFT", name = "Shoulder", canEnchant = true},
  [5] = {id = 5, side = "LEFT", name = "Chest", canEnchant = true},
  [6] = {id = 6, side = "RIGHT", name = "Waist", canEnchant = false},
  [7] = {id = 7, side = "RIGHT", name = "Legs", canEnchant = true},
  [8] = {id = 8, side = "RIGHT", name = "Feet", canEnchant = true},
  [9] = {id = 9, side = "LEFT", name = "Wrist", canEnchant = false},
  [10] = {id = 10, side = "RIGHT", name = "Hands", canEnchant = false},
  [11] = {id = 11, side = "RIGHT", name = "Finger0", canEnchant = true},
  [12] = {id = 12, side = "RIGHT", name = "Finger1", canEnchant = true},
  [13] = {id = 13, side = "RIGHT", name = "Trinket0", canEnchant = false},
  [14] = {id = 14, side = "RIGHT", name = "Trinket1", canEnchant = false},
  [15] = {id = 15, side = "LEFT", name = "Back", canEnchant = false},
  [16] = {id = 16, side = "RIGHT", name = "MainHand", canEnchant = true},
  [17] = {id = 17, side = "LEFT", name = "SecondaryHand", canEnchant = true},
}

--- Credit: https://www.raidbots.com/static/data/live/bonuses.json
---@type LCS_Season[]
Data.seasons = {
  {
    seasonID = 17,
    seasonDisplayID = 1,
    maxUpgradeLevel = 289,
    tracks = {
      {maxLevel = 237, bonusIDs = {12769, 12770, 12771, 12772, 12773, 12774}}, -- Adventurer
      {maxLevel = 250, bonusIDs = {12777, 12778, 12779, 12780, 12781, 12782}}, -- Veteran
      {maxLevel = 263, bonusIDs = {12785, 12786, 12787, 12788, 12789, 12790}}, -- Champion
      {maxLevel = 276, bonusIDs = {12793, 12794, 12795, 12796, 12797, 12798}}, -- Hero
      {maxLevel = 289, bonusIDs = {12801, 12802, 12803, 12804, 12805, 12806}}, -- Myth
      {maxLevel = 285, bonusIDs = {9401, 9402, 9403, 9404, 9405, 9623, 9624, 9625, 9626, 9627}}, -- Crafted Qualities
      {maxLevel = 285, bonusIDs = {12493, 12494, 12495, 12496, 12497, 13622}}, -- Midnight Crafted
      {maxLevel = 298, bonusIDs = {12498, 12499, 12500, 12501, 12502}}, -- Midnight Crafted Weapons
      {maxLevel = 259, bonusIDs = {13789}}, -- Sporefused: Veteran
      {maxLevel = 272, bonusIDs = {13788}}, -- Sporefused: Champion
      {maxLevel = 285, bonusIDs = {13787, 13653}}, -- Sporefused: Hero / Ascendant Voidforged: Hero
      {maxLevel = 298, bonusIDs = {13786, 13654}}, -- Sporefused: Myth / Ascendant Voidforged: Myth
      {maxLevel = 295, bonusIDs = {13655}}, -- Ascendant Voidforged
    },
  },
  {
    seasonID = 18,
    seasonDisplayID = 2,
    maxUpgradeLevel = 334,
    tracks = {
      {maxLevel = 282, bonusIDs = {12817, 12818, 12819, 12820, 12821, 12822}}, -- Adventurer Mistcrest
      {maxLevel = 295, bonusIDs = {12825, 12826, 12827, 12828, 12829, 12830}}, -- Veteran Mistcrest
      {maxLevel = 308, bonusIDs = {12833, 12834, 12835, 12836, 12837, 12838}}, -- Champion Mistcrest
      {maxLevel = 321, bonusIDs = {12841, 12842, 12843, 12844, 12845, 12846}}, -- Hero Mistcrest
      {maxLevel = 334, bonusIDs = {12849, 12850, 12851, 12852, 12853, 12854}}, -- Myth Mistcrest
      {maxLevel = 331, bonusIDs = {9401, 9402, 9403, 9404, 9405, 9623, 9624, 9625, 9626, 9627}}, -- Crafted Qualities
    },
  },
}
