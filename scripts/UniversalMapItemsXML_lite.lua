--[[

    @name Universal Map Items XML (Lite)
    @description Makes Placeables single- and multiplayer compatible, automatically.
    @release fs19-0.8a

    @author CREE7EN
    @copyright 2019 Thomas Creeten, CREEATION.de
    @see https://github.com/CREEATION/FS19_UniversalMapItemsXML (full version)

    Originally created for the map `Puur Nederland` by Mike-Modding.com
    @see https://mike-modding.com/files/file/58-fs19-puur-nederland-by-mike-moddingcom/
    @see https://github.com/PCS-Sprinter/FS19-Puur-Nederland

--]]

--[[############################################################################

    CAUTION: there shouldn't be a reason to edit anything below.

    if you found a bug, report it on the maps GitHub page!
    @see https://github.com/PCS-Sprinter/FS19-Puur-Nederland/issues

############################################################################--]]

UniMIXML_lite = {}
UniMIXML_lite.scriptName = 'UniMIXML'
UniMIXML_lite.scriptFilename = 'UniversalMapItemsXML_lite.lua'

function UniMIXML_lite:loadMap()
  if g_currentMission.missionDynamicInfo.isMultiplayer then
    return false

  end

  local baseMapModDir = g_currentMission.baseDirectory
  local pathSep = string.sub( baseMapModDir, -1 )
  local mapModName = Utils.getModNameAndBaseDirectory( baseMapModDir, true )
  local mapModScriptPath = mapModName .. pathSep .. 'scripts' .. pathSep .. self.scriptFilename
  local baseGameFolderPath = string.sub( string.gsub( baseMapModDir, mapModName, '' ), 1, -7 )
  local configFolderName = self.scriptName .. '_defaultItemsXMLs'
  local configFolderPath = baseGameFolderPath .. configFolderName
  local singleplayerDefaultItemsXMLFilename = mapModName .. '_defaultItems_SP.xml'
  local singleplayerDefaultItemsXMLFilepath = configFolderPath .. pathSep .. singleplayerDefaultItemsXMLFilename

  createFolder( configFolderPath )

  if ( fileExists( singleplayerDefaultItemsXMLFilepath ) ) then
    g_logManager:info(
      "File '%s' already exists, skipping creation... | %s",
      singleplayerDefaultItemsXMLFilename,
      mapModScriptPath
    )

    g_currentMission.missionInfo.itemsXMLLoad = singleplayerDefaultItemsXMLFilepath

  else
    g_logManager:info(
      "Couldn't find '%s', creating a fresh one for '%s'... | %s",
      singleplayerDefaultItemsXMLFilename, mapModName,
      mapModScriptPath
    )

    local mapModDesc = loadXMLFile( 'modDesc', baseMapModDir .. 'modDesc.xml' )
    local multiplayerDefaultItemsXMLFilename = getXMLString( mapModDesc, 'modDesc.maps.map#defaultItemsXMLFilename' )
    delete( mapModDesc )

    local multiplayerDefaultItemsXML = loadXMLFile( 'defaultItems', baseMapModDir .. multiplayerDefaultItemsXMLFilename )
    local singleplayerDefaultItemsXML = createXMLFile( 'singleplayerDefaultItems', singleplayerDefaultItemsXMLFilepath, 'items' )
    local i = 0

    while true do
      local item = string.format( 'items.item(%d)', i )

      local filename = getXMLString( multiplayerDefaultItemsXML, item .. '#filename' )
      if filename == nil then break end

      local position = getXMLString( multiplayerDefaultItemsXML, item .. '#position' )
      local x, y, z = StringUtil.getVectorFromString( getXMLString( multiplayerDefaultItemsXML, item .. '#position' ) )
      if x == nil or y == nil or z == nil then break end

      local rotation = getXMLString( multiplayerDefaultItemsXML, item .. '#rotation' )
      local xRot ,yRot, zRot = StringUtil.getVectorFromString( getXMLString( multiplayerDefaultItemsXML, item .. '#rotation' ) )
      if xRot == nil or yRot == nil or zRot == nil then break end

      local className = getXMLString( multiplayerDefaultItemsXML, item .. '#className' )
      if className == nil then break end

      local farmId = Utils.getNoNil( getXMLInt( multiplayerDefaultItemsXML, item .. '#farmId' ), 0 )
      if farmId == FarmManager.INVALID_FARM_ID then
        farmId = FarmlandManager.NOT_BUYABLE_FARM_ID

      elseif farmId ~= FarmlandManager.NO_OWNER_FARM_ID then
        farmId = FarmManager.SINGLEPLAYER_FARM_ID

      end

      setXMLString( singleplayerDefaultItemsXML, item .. '#filename', filename )
      setXMLString( singleplayerDefaultItemsXML, item .. '#className', className )
      setXMLString( singleplayerDefaultItemsXML, item .. '#position', position )
      setXMLString( singleplayerDefaultItemsXML, item .. '#rotation', rotation )
      setXMLInt( singleplayerDefaultItemsXML, item .. '#farmId', farmId )

      i = i + 1

    end

    delete( multiplayerDefaultItemsXML )

    local singleplayerDefaultItemsXMLSaved = saveXMLFile( singleplayerDefaultItemsXML )
    delete( singleplayerDefaultItemsXML )

    if singleplayerDefaultItemsXMLSaved then
      g_logManager:info(
        "'%s' successfully created from '%s'! | %s",
        singleplayerDefaultItemsXMLFilename, multiplayerDefaultItemsXMLFilename,
        mapModScriptPath
      )

      g_currentMission.missionInfo.itemsXMLLoad = singleplayerDefaultItemsXMLFilepath

    else
      g_logManager:error(
        "Couldn't create '%s'! Map '%s' won't use singleplayer compatible farmIds, which could lead to unexpected behaviour | %s",
        singleplayerDefaultItemsXMLFilename, mapModName,
        mapModScriptPath
      )

    end

  end

  g_logManager:info(
    "Using '%s' to set singleplayer farmIds for placeables | %s",
    g_currentMission.missionInfo.itemsXMLLoad,
    mapModScriptPath
  )

  return true

end

addModEventListener( UniMIXML_lite )
