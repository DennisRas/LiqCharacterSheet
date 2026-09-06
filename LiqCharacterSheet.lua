---@class LCS_Addon
local addon = select(2, ...)

local LiqUI = addon.libs.LiqUI
local TableForEach = LiqUI.Utils.TableForEach
local inventorySlotSides = LiqUI.Constants.inventorySlotSides

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
local defaultColorMaxLevelsUpgraded = {r = 0, g = 1, b = 0, a = 1}
local slotOverlayFrameName = "LCSFrame"

---@type LCS_Config
local config = {
  colors = {
    enchants = defaultColorEnchant,
    enchantsMissing = defaultColorEnchantMissing,
    texture = defaultColorTexture,
    levels = defaultColorLevel,
    maxLevels = defaultColorMaxLevel,
    maxLevelsUpgraded = defaultColorMaxLevelsUpgraded,
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

---@param unitId string
---@param slotId number
local function UpdateSlot(unitId, slotId)
  if unitId == nil or slotId == nil then
    return
  end

  local slot = LiqUI.Data:GetInventorySlotByID(slotId)
  if slot == nil then
    return
  end

  ---@type Button|nil
  local characterSlotFrame = _G[(unitId == "player" and "Character" or "Inspect") .. slot.paperdoll .. "Slot"]
  if characterSlotFrame == nil then
    return
  end

  ---@type LCS_SlotOverlay|nil
  local slotOverlay = characterSlotFrame[slotOverlayFrameName]
  if slotOverlay == nil then
    local relativePoint = slot.side == inventorySlotSides.LEFT and inventorySlotSides.RIGHT or inventorySlotSides.LEFT
    local offsetX = slot.side == inventorySlotSides.LEFT and 9 or -10
    local offsetEnchantY = (slot.id == INVSLOT_MAINHAND or slot.id == INVSLOT_OFFHAND) and -12 or 8

    characterSlotFrame[slotOverlayFrameName] = CreateFrame("Frame", characterSlotFrame:GetName() .. slotOverlayFrameName, characterSlotFrame)
    slotOverlay = characterSlotFrame[slotOverlayFrameName]

    slotOverlay:SetPoint("CENTER")
    slotOverlay:SetAllPoints(characterSlotFrame)

    slotOverlay.Tint = slotOverlay:CreateTexture(nil, "BACKGROUND")
    slotOverlay.Tint:SetTexture("Interface\\TutorialFrame\\TutorialFrameBackground")
    slotOverlay.Tint:SetAllPoints(slotOverlay)

    slotOverlay.Level = slotOverlay:CreateFontString(slotOverlay:GetName() .. "Level", "OVERLAY", "GameTooltipText")
    slotOverlay.Level:SetPoint("CENTER", slotOverlay, "CENTER", 0, 0)
    local font, fontSize = slotOverlay.Level:GetFont()
    if font then
      slotOverlay.Level:SetFont(font, fontSize + 1, "OUTLINE")
    end

    slotOverlay.MaxLevel = slotOverlay:CreateFontString(slotOverlay:GetName() .. "MaxLevel", "OVERLAY", "GameTooltipText")
    slotOverlay.MaxLevel:SetPoint("CENTER", slotOverlay, "CENTER", 0, -8)
    if font then
      slotOverlay.MaxLevel:SetFont(font, fontSize - 3, "OUTLINE")
    end

    slotOverlay.Enchant = slotOverlay:CreateFontString(slotOverlay:GetName() .. "Enchant", "OVERLAY", "GameTooltipText")
    slotOverlay.Enchant:SetPoint(slot.side, slotOverlay, relativePoint, offsetX, offsetEnchantY)
    slotOverlay.Enchant:SetWidth(80)
    slotOverlay.Enchant:SetWordWrap(false)
    if font then
      slotOverlay.Enchant:SetFont(font, fontSize - 3, "OUTLINE")
    end

    slotOverlay.Sockets = {}
    for socketIndex = 1, 3 do
      if slotOverlay.Sockets[socketIndex] == nil then
        slotOverlay.Sockets[socketIndex] = CreateFrame("Button", slotOverlay:GetName() .. "Socket" .. socketIndex, slotOverlay, "UIPanelButtonTemplate")
        slotOverlay.Sockets[socketIndex]:SetSize(14, 14)
        local socketOffsetX = offsetX - 3 - (15 * (socketIndex - 1))
        if slot.side == inventorySlotSides.LEFT then
          socketOffsetX = offsetX + 3 + (15 * (socketIndex - 1))
        end
        slotOverlay.Sockets[socketIndex]:SetPoint(slot.side, slotOverlay:GetName(), relativePoint, socketOffsetX, 0)
      end
    end
  end

  local itemId = GetInventoryItemID(unitId, slotId)
  if itemId == nil then
    slotOverlay:Hide()
    return
  end

  local itemLink = GetInventoryItemLink(unitId, slotId)
  if itemLink == nil or itemLink == "" then
    slotOverlay:Hide()
    return
  end

  local itemPayload = string.match(itemLink, "item:([%-?%d:]+)")
  if itemPayload == nil then
    slotOverlay:Hide()
    return
  end

  local itemPayloadSplit = {strsplit(":", itemPayload)}
  local itemEnchant = nil
  local itemEnchantAtlas = ""
  local itemSocketCount = 0
  local itemSockets = {}
  local maxLevel = nil
  local enchantPattern = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.*)")
  local enchantAtlasPattern = "(.*)|A:(.*):20:20|a"
  local enchantText = ""
  local colorEnchant = defaultColorEnchant
  local colorEnchantMissing = defaultColorEnchantMissing
  local colorTexture = defaultColorTexture
  local colorLevel = defaultColorLevel
  local colorMaxLevel = defaultColorMaxLevel
  local colorMaxLevelUpgraded = defaultColorMaxLevelsUpgraded
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
  local hyperlinkTooltipData = C_TooltipInfo.GetHyperlink(itemLink)
  if hyperlinkTooltipData ~= nil and hyperlinkTooltipData.lines ~= nil then
    for lineIndex = 1, #hyperlinkTooltipData.lines do
      local lineData = hyperlinkTooltipData.lines[lineIndex]
      if lineData.type == Enum.TooltipDataLineType.ItemLevel then
        itemLevel = lineData.itemLevel
      end
    end
  end

  local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
  if itemLevel == nil or config.show.levels == false or config.show.levels == nil then
    slotOverlay.Level:Hide()
    slotOverlay.MaxLevel:Hide()
    slotOverlay.Tint:Hide()
  else
    slotOverlay.Level:SetText(tostring(itemLevel))
    slotOverlay.Level:Show()
    slotOverlay.Tint:Show()
    if config.show.maxLevels == true then
      slotOverlay.MaxLevel:Show()
    else
      slotOverlay.MaxLevel:Hide()
    end
  end

  local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
  upgradePattern = upgradePattern:gsub("%%d", "%%s")
  upgradePattern = upgradePattern:format("(.+)", "(%d+)", "(%d+)")
  local inventoryTooltipData = C_TooltipInfo.GetInventoryItem(unitId, slotId)
  if inventoryTooltipData ~= nil then
    for lineIndex = 1, #inventoryTooltipData.lines do
      local line = inventoryTooltipData.lines[lineIndex]
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
          local red, green, blue, alpha = DISABLED_FONT_COLOR:GetRGBA()
          colorLevel = {r = red, g = green, b = blue, a = alpha}
        end
      end
    end
  end

  local numBonuses = tonumber(itemPayloadSplit[13])
  if numBonuses ~= nil and numBonuses > 0 then
    for bonusIndex = 14, 13 + numBonuses do
      local bonusId = tonumber(itemPayloadSplit[bonusIndex])
      if bonusId ~= nil then
        local maxLevelUpgrade = LiqUI.Data:GetUpgradeMaxLevel(bonusId)
        if maxLevelUpgrade ~= nil and (maxLevel == nil or maxLevelUpgrade > maxLevel) then
          maxLevel = maxLevelUpgrade
        end
      end
    end
  end

  if maxLevel == nil then
    if config.colors.levels ~= nil then
      local red, green, blue, alpha = DISABLED_FONT_COLOR:GetRGBA()
      colorLevel = {r = red, g = green, b = blue, a = alpha}
    end
    slotOverlay.Level:SetPoint("CENTER", slotOverlay, "CENTER", 0, 0)
    slotOverlay.MaxLevel:Hide()
  else
    slotOverlay.MaxLevel:SetText(tostring(maxLevel))
    if config.show.levels == true and config.show.maxLevels == true then
      slotOverlay.Level:SetPoint("CENTER", slotOverlay, "CENTER", 0, 4)
      slotOverlay.MaxLevel:Show()
    else
      slotOverlay.Level:SetPoint("CENTER", slotOverlay, "CENTER", 0, 0)
      slotOverlay.MaxLevel:Hide()
    end
  end

  if itemEnchant == nil then
    if slot.canEnchant then
      enchantText = "No enchant"
      colorEnchant = colorEnchantMissing
      if config.show.enchantsMissing == true and (itemEquipLoc ~= "INVTYPE_HOLDABLE" and itemEquipLoc ~= "INVTYPE_SHIELD") then
        slotOverlay.Enchant:Show()
      else
        slotOverlay.Enchant:Hide()
      end
    else
      slotOverlay.Enchant:Hide()
    end
  else
    itemEnchant = itemEnchant:gsub("+", "")
    if itemEnchantAtlas ~= nil and itemEnchantAtlas ~= "" then
      enchantText = "|A:" .. itemEnchantAtlas .. ":12:12|a" .. itemEnchant
    else
      enchantText = itemEnchant
    end
    if config.show.enchants == true then
      slotOverlay.Enchant:Show()
    else
      slotOverlay.Enchant:Hide()
    end
  end

  slotOverlay.Enchant:SetText(enchantText)
  slotOverlay.Enchant:SetTextColor(colorEnchant.r, colorEnchant.g, colorEnchant.b, colorEnchant.a)
  slotOverlay.Enchant:SetJustifyH(slot.side == inventorySlotSides.RIGHT and inventorySlotSides.RIGHT or inventorySlotSides.LEFT)

  if slot.id ~= INVSLOT_MAINHAND and slot.id ~= INVSLOT_OFFHAND then
    local point, relativeTo, relativePoint, offsetX = slotOverlay.Enchant:GetPoint()
    if itemSocketCount > 0 then
      slotOverlay.Enchant:SetPoint(point, relativeTo, relativePoint, offsetX, 8)
    else
      slotOverlay.Enchant:SetPoint(point, relativeTo, relativePoint, offsetX, 0)
    end
  end

  for socketIndex = 1, 3 do
    local _, gemLink = C_Item.GetItemGem(itemLink, socketIndex)
    local socketFrame = slotOverlay.Sockets[socketIndex]
    local point, relativeTo, relativePoint, offsetX = socketFrame:GetPoint()

    if gemLink == nil then
      if socketIndex <= itemSocketCount then
        if itemSockets[socketIndex] ~= nil and config.show.gems == true then
          socketFrame:SetNormalTexture(itemSockets[socketIndex])
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
      if itemSockets[socketIndex] ~= nil and config.show.gems == true then
        socketFrame:SetNormalTexture(itemSockets[socketIndex])
        socketFrame:Show()
      else
        socketFrame:Hide()
      end
    end

    if enchantText ~= "" or itemSocketCount > 0 then
      socketFrame:SetPoint(point, relativeTo, relativePoint, offsetX, -8)
    else
      socketFrame:SetPoint(point, relativeTo, relativePoint, offsetX, 0)
    end
  end

  slotOverlay.Level:SetFont(font, fontSize, fontOutline)
  slotOverlay.Level:SetTextColor(colorLevel.r, colorLevel.g, colorLevel.b, colorLevel.a)
  slotOverlay.MaxLevel:SetFont(font, fontSize - 3, fontOutline)
  slotOverlay.MaxLevel:SetTextColor(colorMaxLevel.r, colorMaxLevel.g, colorMaxLevel.b, colorMaxLevel.a)
  slotOverlay.Enchant:SetFont(font, fontSize - 3, fontOutline)
  slotOverlay.Tint:SetColorTexture(colorTexture.r, colorTexture.g, colorTexture.b, colorTexture.a)

  if itemLevel ~= nil then
    local currentMaxUpgradeLevel = LiqUI.Data:GetCurrentMaxUpgradeLevel()
    if itemLevel == maxLevel or itemLevel >= currentMaxUpgradeLevel then
      slotOverlay.Level:SetTextColor(colorMaxLevelUpgraded.r, colorMaxLevelUpgraded.g, colorMaxLevelUpgraded.b, colorMaxLevelUpgraded.a)
      slotOverlay.MaxLevel:SetTextColor(colorMaxLevelUpgraded.r, colorMaxLevelUpgraded.g, colorMaxLevelUpgraded.b, colorMaxLevelUpgraded.a)
    end
  end

  slotOverlay:Show()
end

---@param unitId string
local function UpdateAll(unitId)
  TableForEach(LiqUI.Data:GetInventorySlots(), function(slot)
    UpdateSlot(unitId, slot.id)
  end)
end

---@param self LCS_Events
---@param event string
local function OnEvent(self, event, ...)
  if self[event] == nil then
    return
  end
  self[event](self, event, ...)
end

---@class LCS_Events : Frame
local Events = CreateFrame("Frame")
addon.Events = Events

---@param self LCS_Events
function Events:PLAYER_ENTERING_WORLD()
  UpdateAll("player")
end

---@param self LCS_Events
---@param slotId number|nil
function Events:PLAYER_EQUIPMENT_CHANGED(_, slotId)
  if slotId == nil then
    return
  end
  UpdateSlot("player", slotId)
end

---@param self LCS_Events
---@param unitId string|nil
function Events:UNIT_INVENTORY_CHANGED(_, unitId)
  if unitId == nil then
    return
  end
  UpdateAll(unitId)
end

---@param self LCS_Events
function Events:INSPECT_READY()
  UpdateAll("target")
end

---@param self LCS_Events
function Events:BAG_UPDATE_DELAYED()
  UpdateAll("player")
end

Events:RegisterEvent("PLAYER_ENTERING_WORLD")
Events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
Events:RegisterEvent("UNIT_INVENTORY_CHANGED")
Events:RegisterEvent("INSPECT_READY")
Events:RegisterEvent("BAG_UPDATE_DELAYED")
Events:SetScript("OnEvent", OnEvent)
