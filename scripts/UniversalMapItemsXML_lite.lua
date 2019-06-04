--[[

    @name Universal Map Items XML Lite
    @description Makes Placeables single- and multiplayer compatible, automatically.
    @release fs19-0.7a

    @author CREE7EN
    @copyright 2019 Thomas Creeten, CREEATION.de
    @see https://github.com/CREEATION/FS19_UniversalMapItemsXML

    Originally created for the map `Puur Nederland` by Mike-Modding.com
    @see https://mike-modding.com/files/file/58-fs19-puur-nederland-by-mike-moddingcom/
    @see https://github.com/PCS-Sprinter/FS19-Puur-Nederland

--]]

--[[############################################################################

    CAUTION: there shouldn't be a reason to edit anything below.

    if you found a bug, report it on the maps GitHub!
    @see https://github.com/PCS-Sprinter/FS19-Puur-Nederland/issues

############################################################################--]]

UniversalMapItemsXML_lite = {}
UniversalMapItemsXML_lite.scriptName = 'UniversalMapItemsXML_lite.lua'
UniversalMapItemsXML_lite.enableDebugMode = false

--- hook into the function which places items after all necessary checks and adjust the `ownerFarmId` as needed
-- @see https://gdn.giants-software.com/documentation_scripting_fs19.php?version=script&category=66&class=10359#finalizePlacement164130
Placeable.finalizePlacement = Utils.overwrittenFunction(
  Placeable.finalizePlacement,
  function ( self, superFunc )
    if UniversalMapItemsXML_lite.enableDebugMode then
      g_logManager:info( "placed '%s' into the world... | %s", self.i3dFilename, UniversalMapItemsXML_lite.scriptName )
    end

    --- only do stuff if we're in singleplayer on first map start, as given `*items.xml` should already be multiplayer-compatible
    if g_currentMission.missionInfo.isNewSPCareer then
      --- hold associated farmId of current placeable
      local ownerFarmId = self:getOwnerFarmId()

      if UniversalMapItemsXML_lite.enableDebugMode then
        g_logManager:info( "placeable ownerFarmId: '%s' | %s", tostring( ownerFarmId ), UniversalMapItemsXML_lite.scriptName )
      end

      --- set all farmIds to `1`, except those defined as `0` and `15`
      if ownerFarmId ~= FarmManager.SPECTATOR_FARM_ID and ownerFarmId ~= FarmManager.INVALID_FARM_ID then
        self:setOwnerFarmId( FarmManager.SINGLEPLAYER_FARM_ID, true )
      end

      if UniversalMapItemsXML_lite.enableDebugMode then
        g_logManager:info( "finished placeable (ownerFarmId: '%s') | %s", tostring( self:getOwnerFarmId() ), UniversalMapItemsXML_lite.scriptName )
        print( '' )
      end

      --- we're done here
      return superFunc( self )
    end
  end
)
