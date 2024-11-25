local addonName, FastMountTooltip = ...;

-- Mount-Objekt definieren
FastMountTooltip.Mount = {
  name = "",
  spellID = "",
  icon = "",
  isActive = "",
  isUsable = "",
  sourceType = "",
  isFavorite = "",
  faction = "",
  shouldHideOnChar = "",
  isCollected = "",
  mountID = "",
  isForDragonriding = "",
};

-- Methode zum Erstellen eines neuen Mount-Objekts
function FastMountTooltip.Mount:new(object)
  object = object or {};
  setmetatable(object, self);
  self.__index = self;
  return object;
end

-- Methode zum Abrufen der Mount-Informationen
function FastMountTooltip.Mount:getMountInfo(checkMountID)
  local foundMountInfo = false;

  local name, spellID, icon, isActive, isUsable, sourceType, isFavorite,
    isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID,
    isForDragonriding;

  if (type(checkMountID) == "number") then
    name,
    spellID,
    icon,
    isActive,
    isUsable,
    sourceType,
    isFavorite,
    isFactionSpecific,
    faction,
    shouldHideOnChar,
    isCollected,
    mountID,
    isForDragonriding
    = C_MountJournal.GetMountInfoByID(checkMountID);
  end

  if (name) then
    foundMountInfo = true;

    self.name = name;
    self.spellID = spellID;
    self.icon = icon;
    self.isActive = isActive;
    self.isUsable = isUsable;
    self.sourceType = sourceType;
    self.isFavorite = isFavorite;
    self.isFactionSpecific = isFactionSpecific;
    self.faction = faction;
    self.shouldHideOnChar = shouldHideOnChar;
    self.isCollected = isCollected;
    self.mountID = mountID;
    self.isForDragonriding = isForDragonriding;
  end

  return foundMountInfo;
end

-- Funktion zum Überprüfen von Auren, ob sie mit einem Mount verknüpft sind
function FastMountTooltip.CheckAurasForMount(name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, attribute1, attribute2)
  local mountID;
  
  -- Überprüfen, ob das spellID mit einem Mount verknüpft ist
  mountID = C_MountJournal.GetMountFromSpell(spellID);

  if (mountID ~= nil) then
    local mount = FastMountTooltip.Mount:new();
    local foundMountInfo = mount:getMountInfo(mountID);
    if (not foundMountInfo) then
      return true;
    end

    -- Zeige Mount-Informationen im Tooltip an
    GameTooltip:AddLine(" ");  -- Leere Zeile als Trennung
    local iconString = "|T" .. mount.icon .. ":25|t ";  -- Icon des Mounts
    GameTooltip:AddLine(iconString .. mount.name, 1, 1, 1);  -- Weißer Text für den Mountnamen
    return true;
  end
end

-- Funktion zur Verarbeitung der Auren des Spielers
function FastMountTooltip.ProcessAuras(self)
  local name, unit = self:GetUnit();

  if (not unit or not UnitIsPlayer(unit)) then
    return;
  end

  -- Aura-Filter für hilfreiche Auren
  local filterString = AuraUtil.CreateFilterString("HELPFUL");

  -- Durchsuche die Auren des Spielers nach Mounts
  AuraUtil.ForEachAura(unit, filterString, 40, FastMountTooltip.CheckAurasForMount);
end

-- Füge die Funktion hinzu, um Mount-Informationen im Tooltip anzuzeigen
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, FastMountTooltip.ProcessAuras);
