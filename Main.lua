---@type string
local addonName = select(1, ...)
---@class LCS_Addon
local addon = select(2, ...)

local _G = _G
local defaultFont = "Fonts\\FRIZQT__.TTF"
local defaultFontsize = 13
local defaultFontOutline = "OUTLINE"
local fontOutlineOptions = {"", "OUTLINE", "THICKOUTLINE"}
local defaultColorEnchant = {r = 0, g = 1, b = 0, a = 1}
local defaultColorEnchantMissing = {r = 1, g = 0, b = 0, a = 1}
local defaultColorTexture = {r = 0, g = 0, b = 0, a = 0.33}
local defaultColorLevel = {r = 1, g = 1, b = 1, a = 1}
local defaultColorMaxLevel = {r = 1, g = 1, b = 1, a = 1}
local defaultColormaxLevelsUpgraded = {r = 0, g = 1, b = 0, a = 1}
local LCSFrameName = "LCSFrame"

--@debug@
_G[addonName] = addon
--@end-debug@

local config = {
  colors = {
    enchants = defaultColorEnchant,
    enchantsMissing = defaultColorEnchantMissing,
    texture = defaultColorTexture,
    levels = defaultColorLevel,
    maxLevels = defaultColorMaxLevel,
    maxLevelsUpgraded = defaultColormaxLevelsUpgraded,
  },
  fonts = {
    font = defaultFont,
    size = defaultFontsize,
    outline = defaultFontOutline,
  },
  show = {
    levels = true,
    maxLevels = true,
    enchants = true,
    enchantsMissing = true,
    gems = true,
  },
}

local Slots = {
  [1] = {id = 1, side = "LEFT", name = "Head", canEnchant = false},
  [2] = {id = 2, side = "LEFT", name = "Neck", canEnchant = false},
  [3] = {id = 3, side = "LEFT", name = "Shoulder", canEnchant = false},
  -- [4] = {id = 4, side = "LEFT", name = "Shirt", canEnchant = false},
  [5] = {id = 5, side = "LEFT", name = "Chest", canEnchant = true},
  [6] = {id = 6, side = "RIGHT", name = "Waist", canEnchant = false},
  [7] = {id = 7, side = "RIGHT", name = "Legs", canEnchant = true},
  [8] = {id = 8, side = "RIGHT", name = "Feet", canEnchant = true},
  [9] = {id = 9, side = "LEFT", name = "Wrist", canEnchant = true},
  [10] = {id = 10, side = "RIGHT", name = "Hands", canEnchant = false},
  [11] = {id = 11, side = "RIGHT", name = "Finger0", canEnchant = true},
  [12] = {id = 12, side = "RIGHT", name = "Finger1", canEnchant = true},
  [13] = {id = 13, side = "RIGHT", name = "Trinket0", canEnchant = false},
  [14] = {id = 14, side = "RIGHT", name = "Trinket1", canEnchant = false},
  [15] = {id = 15, side = "LEFT", name = "Back", canEnchant = true},
  [16] = {id = 16, side = "RIGHT", name = "MainHand", canEnchant = true},
  [17] = {id = 17, side = "LEFT", name = "SecondaryHand", canEnchant = true},
  --    [18] = {id = 18, side = "LEFT", name = "Ranged", canEnchant = false},
  --    [19] = {id = 19, side = "LEFT", name = "Tabard", canEnchant = false}
}

-- Credit: https://www.raidbots.com/static/data/live/bonuses.json
-- Season 15 / TWW S3 / Pre-Patch Squish
local maxUpgaradeLevel = 170
local maxUpgradeLevels = {
  [105] = {12265, 12266, 12267, 12268, 12269, 12270, 12271, 12272},     -- Explorer
  [118] = {12274, 12275, 12276, 12277, 12278, 12279, 12280, 12281},     -- Adventurer
  [131] = {12282, 12283, 12284, 12285, 12286, 12287, 12288, 12289},     -- Veteran
  [146] = {12290, 12291, 12292, 12293, 12294, 12295, 12296, 12297},     -- Champion
  [157] = {12350, 12351, 12352, 12353, 12354, 12355, 13443, 13444},     -- Hero
  [170] = {12356, 12357, 12358, 12359, 12360, 12361, 13445, 13446},     -- Myth
  [167] = {9401, 9402, 9403, 9404, 9405, 9623, 9624, 9625, 9626, 9627}, -- Crafted Qualities
}

local GetMaxUpgradeLevel = function(bonusId)
  for level, ids in pairs(maxUpgradeLevels) do
    for i, id in pairs(ids) do
      if id == bonusId then
        return level
      end
    end
  end
  return nil
end


-- local CreateSlotFrame = function(unitId, slot)
--   if slot == nil then
--     return nil
--   end

--   local slotPrefix = "Inspect"
--   if unitId == "player" then
--     slotPrefix = "Character"
--   end

--   local parent = _G[slotPrefix .. slot.name .. "Slot"]
--   if parent == nil then
--     return nil
--   end

--   local relativePoint = slot.side == "LEFT" and "RIGHT" or "LEFT"
--   local offsetX = slot.side == "LEFT" and 9 or -10
--   local offsetEnchantY = (slot.id == 16 or slot.id == 17) and -12 or 8

--   if parent[LCSFrameName] == nil then
--     parent[LCSFrameName] = CreateFrame("Frame", parent:GetName() .. LCSFrameName, parent)
--     parent[LCSFrameName]:SetPoint("CENTER")
--     parent[LCSFrameName]:SetAllPoints(parent)
--     -- parent[LCSFrameName]:Show()
--   else
--     return parent
--   end

--   -- Overlay tint
--   if parent[LCSFrameName].Tint == nil then
--     parent[LCSFrameName].Tint = parent[LCSFrameName]:CreateTexture(nil, "BACKGROUND")
--     parent[LCSFrameName].Tint:SetTexture("Interface\\TutorialFrame\\TutorialFrameBackground")
--     parent[LCSFrameName].Tint:SetAllPoints(parent[LCSFrameName])
--   end

--   if parent[LCSFrameName].Level == nil then
--     parent[LCSFrameName].Level = parent[LCSFrameName]:CreateFontString(parent[LCSFrameName]:GetName() .. "Level", "OVERLAY", "GameTooltipText")
--     parent[LCSFrameName].Level:SetPoint("CENTER", parent[LCSFrameName], "CENTER", 0, 0)
--     local font, fontSize = parent[LCSFrameName].Level:GetFont()
--     if font then
--       parent[LCSFrameName].Level:SetFont(font, fontSize + 1, "OUTLINE")
--     end
--   end

--   if parent[LCSFrameName].MaxLevel == nil then
--     parent[LCSFrameName].MaxLevel = parent[LCSFrameName]:CreateFontString(parent[LCSFrameName]:GetName() .. "MaxLevel", "OVERLAY", "GameTooltipText")
--     parent[LCSFrameName].MaxLevel:SetPoint("CENTER", parent[LCSFrameName], "CENTER", 0, -8)
--     local font, fontSize = parent[LCSFrameName].Level:GetFont()
--     if font then
--       parent[LCSFrameName].MaxLevel:SetFont(font, fontSize - 3, "OUTLINE")
--     end
--   end

--   if parent[LCSFrameName].Enchant == nil then
--     parent[LCSFrameName].Enchant = parent[LCSFrameName]:CreateFontString(parent[LCSFrameName]:GetName() .. "Enchant", "OVERLAY", "GameTooltipText")
--     parent[LCSFrameName].Enchant:SetPoint(slot.side, parent[LCSFrameName], relativePoint, offsetX, offsetEnchantY)
--     parent[LCSFrameName].Enchant:SetWidth(80)
--     parent[LCSFrameName].Enchant:SetWordWrap(false)
--     local font, fontSize = parent[LCSFrameName].Level:GetFont()
--     if font then
--       parent[LCSFrameName].Enchant:SetFont(font, fontSize - 3, "OUTLINE")
--     end
--   end

--   if parent[LCSFrameName].Sockets == nil then
--     parent[LCSFrameName].Sockets = {}
--     for i = 1, 3 do
--       if parent[LCSFrameName].Sockets[i] == nil then
--         parent[LCSFrameName].Sockets[i] = CreateFrame("Button", parent[LCSFrameName]:GetName() .. "Socket" .. i, parent[LCSFrameName], "UIPanelButtonTemplate")
--         parent[LCSFrameName].Sockets[i]:SetSize(14, 14)
--         local socketOffsetX = offsetX - 3 - (15 * (i - 1))
--         if slot.side == "LEFT" then
--           socketOffsetX = offsetX + 3 + (15 * (i - 1))
--         end
--         parent[LCSFrameName].Sockets[i]:SetPoint(slot.side, parent[LCSFrameName]:GetName(), relativePoint, socketOffsetX, 0)
--       end
--     end
--   end

--   return parent
-- end

local UpdateSlot = function(unitId, slotId)
  if unitId == nil or slotId == nil then return end

  local slot = Slots[slotId]
  if slot == nil then return end

  -- Blizzard inventory slot frame
  local CharacterSlotFrame = _G[(unitId == "player" and "Character" or "Inspect") .. slot.name .. "Slot"]
  if CharacterSlotFrame == nil then
    return nil
  end

  -- Get or create new frames
  local LCSFrame = CharacterSlotFrame[LCSFrameName]
  if LCSFrame == nil then
    local relativePoint = slot.side == "LEFT" and "RIGHT" or "LEFT"
    local offsetX = slot.side == "LEFT" and 9 or -10
    local offsetEnchantY = (slot.id == 16 or slot.id == 17) and -12 or 8

    CharacterSlotFrame[LCSFrameName] = CreateFrame("Frame", CharacterSlotFrame:GetName() .. LCSFrameName, CharacterSlotFrame)
    LCSFrame = CharacterSlotFrame[LCSFrameName]
    LCSFrame:SetPoint("CENTER")
    LCSFrame:SetAllPoints(CharacterSlotFrame)
    -- LCSFrame:Show()

    -- Overlay tint
    -- if LCSFrame.Tint == nil then
    LCSFrame.Tint = LCSFrame:CreateTexture(nil, "BACKGROUND")
    LCSFrame.Tint:SetTexture("Interface\\TutorialFrame\\TutorialFrameBackground")
    LCSFrame.Tint:SetAllPoints(LCSFrame)
    -- end

    -- if LCSFrame.Level == nil then
    LCSFrame.Level = LCSFrame:CreateFontString(LCSFrame:GetName() .. "Level", "OVERLAY", "GameTooltipText")
    LCSFrame.Level:SetPoint("CENTER", LCSFrame, "CENTER", 0, 0)
    local font, fontSize = LCSFrame.Level:GetFont()
    if font then
      LCSFrame.Level:SetFont(font, fontSize + 1, "OUTLINE")
    end
    -- end

    -- if LCSFrame.MaxLevel == nil then
    LCSFrame.MaxLevel = LCSFrame:CreateFontString(LCSFrame:GetName() .. "MaxLevel", "OVERLAY", "GameTooltipText")
    LCSFrame.MaxLevel:SetPoint("CENTER", LCSFrame, "CENTER", 0, -8)
    local font, fontSize = LCSFrame.Level:GetFont()
    if font then
      LCSFrame.MaxLevel:SetFont(font, fontSize - 3, "OUTLINE")
    end
    -- end

    -- if LCSFrame.Enchant == nil then
    LCSFrame.Enchant = LCSFrame:CreateFontString(LCSFrame:GetName() .. "Enchant", "OVERLAY", "GameTooltipText")
    LCSFrame.Enchant:SetPoint(slot.side, LCSFrame, relativePoint, offsetX, offsetEnchantY)
    LCSFrame.Enchant:SetWidth(80)
    LCSFrame.Enchant:SetWordWrap(false)
    local font, fontSize = LCSFrame.Level:GetFont()
    if font then
      LCSFrame.Enchant:SetFont(font, fontSize - 3, "OUTLINE")
    end
    -- end

    -- if LCSFrame.Sockets == nil then
    LCSFrame.Sockets = {}
    for i = 1, 3 do
      if LCSFrame.Sockets[i] == nil then
        LCSFrame.Sockets[i] = CreateFrame("Button", LCSFrame:GetName() .. "Socket" .. i, LCSFrame, "UIPanelButtonTemplate")
        LCSFrame.Sockets[i]:SetSize(14, 14)
        local socketOffsetX = offsetX - 3 - (15 * (i - 1))
        if slot.side == "LEFT" then
          socketOffsetX = offsetX + 3 + (15 * (i - 1))
        end
        LCSFrame.Sockets[i]:SetPoint(slot.side, LCSFrame:GetName(), relativePoint, socketOffsetX, 0)
      end
    end
    -- end
  end

  -- local parent = CreateSlotFrame(unitId, slot)
  -- if parent == nil then return end
  -- if parent[LCSFrameName] == nil then return end

  local itemId = GetInventoryItemID(unitId, slotId)
  if itemId == nil then
    LCSFrame:Hide()
    return
  end

  local itemLink = GetInventoryItemLink(unitId, slotId)
  if itemLink == nil or itemLink == "" then
    LCSFrame:Hide()
    return
  end

  local itemPayload = string.match(itemLink, "item:([%-?%d:]+)")
  if itemPayload == nil then
    LCSFrame:Hide()
    return
  end

  -- local itemRarityColor = string.sub(itemLink, 3, 10)
  local itemPayloadSplit = {strsplit(":", itemPayload)}
  local itemEnchant = nil
  local itemEnchantAtlas = ""
  local itemSocketCount = 0
  local itemSockets = {}
  local MaxLevel = nil
  local enchantPattern = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.*)")
  local enchantAtlasPattern = "(.*)|A:(.*):20:20|a"
  local enchantText = ""
  local colorEnchant = defaultColorEnchant
  local colorEnchantMissing = defaultColorEnchantMissing
  local colorTexture = defaultColorTexture
  local colorLevel = defaultColorLevel
  local colorMaxLevel = defaultColorMaxLevel
  local colorMaxLevelUpgraded = defaultColormaxLevelsUpgraded
  local font = defaultFont
  local fontSize = defaultFontsize
  local fontOutline = defaultFontOutline

  if config.fonts.font ~= nil then
    font = defaultFont
  end

  if config.fonts.outline ~= nil then
    local fontOutlineSelected = fontOutlineOptions[config.fonts.outline]
    if fontOutlineSelected ~= nil then
      fontOutline = fontOutlineSelected
    end
  end

  if config.colors.enchants ~= nil then
    colorEnchant = config.colors.enchants
  end
  if config.colors.enchantsMissing ~= nil then
    colorEnchantMissing = config.colors.enchantsMissing
  end
  if config.colors.levels ~= nil then
    colorLevel = config.colors.levels
  end
  if config.colors.maxLevels ~= nil then
    colorMaxLevel = config.colors.maxLevels
  end
  if config.colors.maxLevelsUpgraded ~= nil then
    colorMaxLevelUpgraded = config.colors.maxLevelsUpgraded
  end

  if config.colors.texture ~= nil then
    colorTexture = config.colors.texture
  end

  local itemLevel = nil
  local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
  if tooltipData ~= nil and tooltipData.lines ~= nil then
    for _, lineData in ipairs(tooltipData.lines) do
      if lineData.type == Enum.TooltipDataLineType.ItemLevel then
        itemLevel = lineData.itemLevel
      end
    end
  end

  -- local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
  local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
  if itemLevel == nil or config.show.levels == false or config.show.levels == nil then
    LCSFrame.Level:Hide()
    LCSFrame.MaxLevel:Hide()
    LCSFrame.Tint:Hide()
  else
    LCSFrame.Level:SetText(tostring(itemLevel))
    LCSFrame.Level:Show()
    LCSFrame.Tint:Show()
    if config.show.maxLevels == true then
      LCSFrame.MaxLevel:Show()
    else
      LCSFrame.MaxLevel:Hide()
    end
  end

  local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
  upgradePattern = upgradePattern:gsub("%%d", "%%s")
  upgradePattern = upgradePattern:format("(.+)", "(%d+)", "(%d+)")
  local tooltipData = C_TooltipInfo.GetInventoryItem(unitId, slotId)
  if tooltipData ~= nil then
    for i, line in pairs(tooltipData.lines) do
      local text = line.leftText
      local enchantString = string.match(text, enchantPattern)
      if enchantString ~= nil then
        if string.find(enchantString, "|A:") then
          itemEnchant, itemEnchantAtlas = string.match(enchantString, enchantAtlasPattern)
        else
          itemEnchant = enchantString
        end
      end

      if line.type == Enum.TooltipDataLineType.GemSocket then
        if line.gemIcon then
          itemSocketCount = itemSocketCount + 1
          itemSockets[itemSocketCount] = line.gemIcon
        elseif line.socketType then
          itemSocketCount = itemSocketCount + 1
          itemSockets[itemSocketCount] = string.format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", line.socketType)
        end
      end

      local match = line.leftText:find(upgradePattern)
      if match then
        if line.leftColor:GenerateHexColor() == DISABLED_FONT_COLOR:GenerateHexColor() then
          local r, g, b, a = DISABLED_FONT_COLOR:GetRGBA()
          colorLevel = {r = r, g = g, b = b, a = a}
        end
      end
    end
  end

  local numBonuses = tonumber(itemPayloadSplit[13])
  if numBonuses ~= nil and numBonuses > 0 then
    for i = 14, 13 + numBonuses do
      local bonusId = tonumber(itemPayloadSplit[i])
      if bonusId ~= nil then
        local maxLevelUpgrade = GetMaxUpgradeLevel(bonusId)
        if maxLevelUpgrade ~= nil then
          MaxLevel = maxLevelUpgrade
        end
      end
    end
  end

  ---TWW S3: Reshii Wraps
  if itemId == 235499 then
    MaxLevel = 170
  end

  ---TWW S2: D.I.S.C Belt
  if itemId == 245966 or itemId == 245964 or itemId == 245965 or itemId == 242664 then
    MaxLevel = 141
  end

  if MaxLevel == nil then
    if config.colors.levels ~= nil then
      local r, g, b, a = DISABLED_FONT_COLOR:GetRGBA()
      colorLevel = {r = r, g = g, b = b, a = a}
    end
    LCSFrame.Level:SetPoint("CENTER", LCSFrame, "CENTER", 0, 0)
    LCSFrame.MaxLevel:Hide()
  else
    LCSFrame.MaxLevel:SetText(tostring(MaxLevel))
    if config.show.levels == true and config.show.maxLevels == true then
      LCSFrame.Level:SetPoint("CENTER", LCSFrame, "CENTER", 0, 4)
      LCSFrame.MaxLevel:Show()
    else
      LCSFrame.Level:SetPoint("CENTER", LCSFrame, "CENTER", 0, 0)
      LCSFrame.MaxLevel:Hide()
    end
  end

  if itemEnchant == nil then
    if slot.canEnchant == true then
      enchantText = "No enchant"
      colorEnchant = colorEnchantMissing
      if config.show.enchantsMissing == true and (itemEquipLoc ~= "INVTYPE_HOLDABLE" and itemEquipLoc ~= "INVTYPE_SHIELD") then
        LCSFrame.Enchant:Show()
      else
        LCSFrame.Enchant:Hide()
      end
    else
      LCSFrame.Enchant:Hide()
    end
  else
    itemEnchant = itemEnchant:gsub("+", "")
    if itemEnchantAtlas ~= nil and itemEnchantAtlas ~= "" then
      enchantText = "|A:" .. itemEnchantAtlas .. ":12:12|a" .. itemEnchant
    else
      enchantText = itemEnchant
    end
    if config.show.enchants == true then
      LCSFrame.Enchant:Show()
    else
      LCSFrame.Enchant:Hide()
    end
  end

  LCSFrame.Enchant:SetText(enchantText)
  LCSFrame.Enchant:SetTextColor(colorEnchant.r, colorEnchant.g, colorEnchant.b, colorEnchant.a)
  LCSFrame.Enchant:SetJustifyH(slot.side == "RIGHT" and "RIGHT" or "LEFT")

  -- Weapon enchants
  if slot.id ~= 16 and slot.id ~= 17 then
    local point, relativeTo, relativePoint, offset_x = LCSFrame.Enchant:GetPoint()
    if itemSocketCount > 0 or (slot.id == 9 or slot.id == 14) then
      LCSFrame.Enchant:SetPoint(point, relativeTo, relativePoint, offset_x, 8)
    else
      LCSFrame.Enchant:SetPoint(point, relativeTo, relativePoint, offset_x, 0)
    end
  end

  -- Sockets
  for i = 1, 3 do
    local _, gemLink = C_Item.GetItemGem(itemLink, i)
    local socketFrame = LCSFrame.Sockets[i]
    local point, relativeTo, relativePoint, offset_x = socketFrame:GetPoint()

    if gemLink == nil then
      if i <= itemSocketCount then
        if itemSockets[i] ~= nil and config.show.gems == true then
          socketFrame:SetNormalTexture(itemSockets[i])
          socketFrame:Show()
        else
          socketFrame:Hide()
        end
      else
        socketFrame:Hide()
      end
    else
      socketFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(socketFrame, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(gemLink)
        GameTooltip:Show()
      end)
      socketFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      if itemSockets[i] ~= nil and config.show.gems == true then
        socketFrame:SetNormalTexture(itemSockets[i])
        socketFrame:Show()
      else
        socketFrame:Hide()
      end
    end

    if enchantText ~= "" or (slot.id == 9 or slot.id == 14) then
      socketFrame:SetPoint(point, relativeTo, relativePoint, offset_x, -8)
    else
      socketFrame:SetPoint(point, relativeTo, relativePoint, offset_x, 0)
    end
  end

  LCSFrame.Level:SetFont(font, fontSize, fontOutline)
  LCSFrame.Level:SetTextColor(colorLevel.r, colorLevel.g, colorLevel.b, colorLevel.a)
  LCSFrame.MaxLevel:SetFont(font, fontSize - 3, fontOutline)
  LCSFrame.MaxLevel:SetTextColor(colorMaxLevel.r, colorMaxLevel.g, colorMaxLevel.b, colorMaxLevel.a)
  LCSFrame.Enchant:SetFont(font, fontSize - 3, fontOutline)
  LCSFrame.Tint:SetColorTexture(colorTexture.r, colorTexture.g, colorTexture.b, colorTexture.a)

  if itemLevel ~= nil then
    if itemLevel == MaxLevel or itemLevel >= maxUpgaradeLevel then
      LCSFrame.Level:SetTextColor(colorMaxLevelUpgraded.r, colorMaxLevelUpgraded.g, colorMaxLevelUpgraded.b, colorMaxLevelUpgraded.a)
      LCSFrame.MaxLevel:SetTextColor(colorMaxLevelUpgraded.r, colorMaxLevelUpgraded.g, colorMaxLevelUpgraded.b, colorMaxLevelUpgraded.a)
    end
  end

  LCSFrame:Show()
end

local function UpdateAll(unitId)
  for slotId in pairs(Slots) do
    UpdateSlot(unitId, slotId)
  end
end

local function OnEvent(self, event, ...)
  if self[event] == nil then return end
  self[event](self, event, ...)
end

local f = CreateFrame("Frame")

function f:PLAYER_ENTERING_WORLD()
  UpdateAll("player")
end

function f:PLAYER_EQUIPMENT_CHANGED(_, slotId)
  if slotId == nil then return end
  UpdateSlot("player", slotId)
end

function f:UNIT_INVENTORY_CHANGED(_, unitId)
  if unitId == nil then return end
  UpdateAll(unitId)
end

function f:INSPECT_READY()
  UpdateAll("target")
end

function f:BAG_UPDATE_DELAYED()
  UpdateAll("player")
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("INSPECT_READY")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:SetScript("OnEvent", OnEvent)
