--[[

    @author CREE7EN
    @copyright 2019 Thomas Creeten, CREEATION.de

    Originally created for the map `Puur Nederland` by Mike-Modding.com
    @see https://mike-modding.com/files/file/58-fs19-puur-nederland-by-mike-moddingcom/

--]]

--- prevents spectator farm from trying to get money every hour
-- this happens when a placeable has `incomePerHour` set, but nobody bought the farmland yet
Placeable.hourChanged = Utils.overwrittenFunction(
  Placeable.hourChanged,
  function ( self, superFunc )
    --- skip function execution if placeable belongs to spectator farm
    if ( self:getOwnerFarmId() ~= FarmManager.SPECTATOR_FARM_ID ) then
      superFunc( self )

    end

  end
)
