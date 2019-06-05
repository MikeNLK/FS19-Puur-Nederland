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

function UniMIXML_lite.createSingleplayerDefaultItemsXMLFile( cfg=nil )
  if ( cfg == nil ) then
    return false
  end
    g_logManager:error(
      "Couldn't read config for creating '%s', aborting. | %s",
      cfg.singleplayerDefaultItemsXMLFilename, cfg.mapModName,
      cfg.mapModScriptPath
    )


  if ( not g_currentMission.missionInfo.isNewSPCareer ) then
    g_logManager:info(
      "Won't create '%s' for '%s', as 'items.xml' for existing savegame can't be overwritten. | %s",
      cfg.singleplayerDefaultItemsXMLFilename, cfg.mapModName,
      cfg.mapModScriptPath
    )

  end

  local multiplayerDefaultItemsXML = loadXMLFile( 'defaultItems', cfg.baseMapModDir .. cfg.multiplayerDefaultItemsXMLFilename )
  local singleplayerDefaultItemsXML = createXMLFile( 'singleplayerDefaultItems', cfg.singleplayerDefaultItemsXMLFilepath, 'items' )
  local successfullyWrittenXML = true
  local i = 0

  while ( true ) do
    local item = string.format( 'items.item(%d)', i )

    local filename = getXMLString( multiplayerDefaultItemsXML, item .. '#filename' )
    if ( filename == nil ) then
      successfullyWrittenXML = false
      break
    end

    local position = getXMLString( multiplayerDefaultItemsXML, item .. '#position' )
    local x, y, z = StringUtil.getVectorFromString( getXMLString( multiplayerDefaultItemsXML, item .. '#position' ) )
    if ( x == nil or y == nil or z == nil ) then
      successfullyWrittenXML = false
      break
    end

    local rotation = getXMLString( multiplayerDefaultItemsXML, item .. '#rotation' )
    local xRot ,yRot, zRot = StringUtil.getVectorFromString( getXMLString( multiplayerDefaultItemsXML, item .. '#rotation' ) )
    if ( xRot == nil or yRot == nil or zRot == nil ) then
      successfullyWrittenXML = false
      break
    end

    local className = getXMLString( multiplayerDefaultItemsXML, item .. '#className' )
    if ( className == nil ) then
      successfullyWrittenXML = false
      break
    end

    local farmId = Utils.getNoNil( getXMLInt( multiplayerDefaultItemsXML, item .. '#farmId' ), 0 )
    if ( farmId == FarmManager.INVALID_FARM_ID ) then
      farmId = FarmlandManager.NOT_BUYABLE_FARM_ID

    elseif ( farmId ~= FarmlandManager.NO_OWNER_FARM_ID ) then
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

  local singleplayerDefaultItemsXMLSaved = false

  if ( successfullyWrittenXML ) then
    setXMLString( singleplayerDefaultItemsXML, 'items#version', mapModVersion )
    createFolder( configFolderPath )
    singleplayerDefaultItemsXMLSaved = saveXMLFile( singleplayerDefaultItemsXML )
  end

  delete( singleplayerDefaultItemsXML )

  if ( successfullyWrittenXML and singleplayerDefaultItemsXMLSaved ) then
    g_logManager:info(
      "'%s' successfully created from '%s'! | %s",
      cfg.singleplayerDefaultItemsXMLFilename, cfg.multiplayerDefaultItemsXMLFilename,
      cfg.mapModScriptPath
    )

    g_currentMission.missionInfo.itemsXMLLoad = cfg.singleplayerDefaultItemsXMLFilepath

    return true

  else
    g_logManager:error(
      "Couldn't create '%s'! Map '%s' won't use singleplayer compatible farmIds, which could otherwise lead to unexpected behaviour. | %s",
      cfg.singleplayerDefaultItemsXMLFilename, cfg.mapModName,
      cfg.mapModScriptPath
    )

    return false

  end
end

function UniMIXML_lite:loadMap()
  if ( g_currentMission.missionDynamicInfo.isMultiplayer ) then
    return false

  end

  local baseMapModDir = g_currentMission.baseDirectory
  local pathSep = string.sub( baseMapModDir, -1 )
  local mapModName = Utils.getModNameAndBaseDirectory( baseMapModDir, true )
  local mapModScriptPath = self.scriptFilename
  local baseGameFolderPath = string.sub( string.gsub( baseMapModDir, mapModName, '' ), 1, -7 )
  local configFolderName = self.scriptName .. '_defaultItemsXMLs'
  local configFolderPath = baseGameFolderPath .. configFolderName
  local singleplayerDefaultItemsXMLFilename = mapModName .. '_defaultItems_SP.xml'
  local singleplayerDefaultItemsXMLFilepath = configFolderPath .. pathSep .. singleplayerDefaultItemsXMLFilename
  local mapModDesc = loadXMLFile( 'modDesc', baseMapModDir .. 'modDesc.xml' )
  local multiplayerDefaultItemsXMLFilename = getXMLString( mapModDesc, 'modDesc.maps.map#defaultItemsXMLFilename' )
  local mapModVersion = getXMLString( mapModDesc, 'modDesc.version' )

  delete( mapModDesc )

  local singleplayerDefaultItemsConfiguration = {}
  singleplayerDefaultItemsConfiguration.mapModName = mapModName
  singleplayerDefaultItemsConfiguration.baseMapModDir = baseMapModDir
  singleplayerDefaultItemsConfiguration.multiplayerDefaultItemsXMLFilename = multiplayerDefaultItemsXMLFilename
  singleplayerDefaultItemsConfiguration.singleplayerDefaultItemsXMLFilepath = singleplayerDefaultItemsXMLFilepath
  singleplayerDefaultItemsConfiguration.singleplayerDefaultItemsXMLFilename = singleplayerDefaultItemsXMLFilename
  singleplayerDefaultItemsConfiguration.mapModScriptPath = mapModScriptPath

  DebugUtil.printTableRecursively( singleplayerDefaultItemsConfiguration )

  if ( fileExists( singleplayerDefaultItemsXMLFilepath ) ) then
    g_logManager:info(
      "File '%s' already exists, checking map version... | %s",
      singleplayerDefaultItemsXMLFilename,
      mapModScriptPath
    )

    local tmpSingleplayerDefaultItemsXML = loadXMLFile( 'tmpSingleplayerDefaultItemsXML', singleplayerDefaultItemsXMLFilepath )
    local singleplayerDefaultItemsXMLMapVersion = getXMLString( tmpSingleplayerDefaultItemsXML, 'items#version' )
    delete( tmpSingleplayerDefaultItemsXML )

    if ( mapModVersion ~= singleplayerDefaultItemsXMLMapVersion ) then
      g_logManager:info(
        "Map versions don't match! ('%s' version: '%s', '%s' version: '%s') | %s",
        mapModName, mapModVersion, singleplayerDefaultItemsXMLFilename, singleplayerDefaultItemsXMLMapVersion,
        mapModScriptPath
      )

      g_logManager:info(
        "For your own safety, a fresh version of '%s' from '%s' will be created! | %s",
        singleplayerDefaultItemsXMLFilename, mapModName,
        mapModScriptPath
      )

      self.createSingleplayerDefaultItemsXMLFile( singleplayerDefaultItemsConfiguration )
    end

  else
    g_logManager:info(
      "Couldn't find '%s', creating a fresh one for '%s'... | %s",
      singleplayerDefaultItemsXMLFilename, mapModName,
      mapModScriptPath
    )

    self.createSingleplayerDefaultItemsXMLFile( singleplayerDefaultItemsConfiguration )

  end

  g_logManager:info(
    "Using '%s' to set singleplayer farmIds for placeables. | %s",
    g_currentMission.missionInfo.itemsXMLLoad,
    mapModScriptPath
  )

  return true

end

addModEventListener( UniMIXML_lite )
