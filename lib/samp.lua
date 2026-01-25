-- SAMP.Lua v2.3.0 
-- Built: Fri 01/23/2026 14:53:13.19 
local bit = require 'bit' 
local ffi = require 'ffi' 
-- Combined module start 
-- File: events.lua 
-- This file is part of the SAMP.Lua project.
-- Licensed under the MIT License.
-- Copyright (c) 2016, FYP @ BlastHack Team <blast.hk>
-- https://github.com/THE-FYP/SAMP.Lua

local raknet                                  = require 'samp.raknet'
local events                                  = require 'samp.events.core'
local utils                                   = require 'samp.events.utils'
local handler                                 = require 'samp.events.handlers'
                                                require 'samp.events.extra_types'
local RPC                                     = raknet.RPC
local PACKET                                  = raknet.PACKET
local OUTCOMING_RPCS                          = events.INTERFACE.OUTCOMING_RPCS
local OUTCOMING_PACKETS                       = events.INTERFACE.OUTCOMING_PACKETS
local INCOMING_RPCS                           = events.INTERFACE.INCOMING_RPCS
local INCOMING_PACKETS                        = events.INTERFACE.INCOMING_PACKETS

-- Outgoing rpcs
OUTCOMING_RPCS[RPC.ENTERVEHICLE]              = {'onSendEnterVehicle', {vehicleId = 'uint16'}, {passenger = 'bool8'}}
OUTCOMING_RPCS[RPC.CLICKPLAYER]               = {'onSendClickPlayer', {playerId = 'uint16'}, {source = 'uint8'}}
OUTCOMING_RPCS[RPC.CLIENTJOIN]                = {'onSendClientJoin', {version = 'int32'}, {mod = 'uint8'}, {nickname = 'string8'}, {challengeResponse = 'int32'}, {joinAuthKey = 'string8'}, {clientVer = 'string8'}, {challengeResponse2 = 'int32'}}
--OUTCOMING_RPCS[RPC.SELECTOBJECT]              = {'onSendSelectObject', {type = 'int32'}, {objectId = 'uint16'}, {model = 'int32'}, {position = 'vector3d'}}
OUTCOMING_RPCS[RPC.SELECTOBJECT]              = {'onSendEnterEditObject', {type = 'int32'}, {objectId = 'uint16'}, {model = 'int32'}, {position = 'vector3d'}}
OUTCOMING_RPCS[RPC.SERVERCOMMAND]             = {'onSendCommand', {command = 'string32'}}
OUTCOMING_RPCS[RPC.SPAWN]                     = {'onSendSpawn'}
OUTCOMING_RPCS[RPC.DEATH]                     = {'onSendDeathNotification', {reason = 'uint8'}, {killerId = 'uint16'}}
OUTCOMING_RPCS[RPC.DIALOGRESPONSE]            = {'onSendDialogResponse', {dialogId = 'uint16'}, {button = 'uint8'}, {listboxId = 'uint16'}, {input = 'string8'}}
OUTCOMING_RPCS[RPC.CLICKTEXTDRAW]             = {'onSendClickTextDraw', {textdrawId = 'uint16'}}
OUTCOMING_RPCS[RPC.SCMEVENT]                  = {'onSendVehicleTuningNotification', {vehicleId = 'int32'}, {param1 = 'int32'}, {param2 = 'int32'}, {event = 'int32'}}
OUTCOMING_RPCS[RPC.CHAT]                      = {'onSendChat', {message = 'string8'}}
OUTCOMING_RPCS[RPC.CLIENTCHECK]               = {'onSendClientCheckResponse', {requestType = 'uint8'}, {result1 = 'int32'}, {result2 = 'uint8'}}
OUTCOMING_RPCS[RPC.DAMAGEVEHICLE]             = {'onSendVehicleDamaged', {vehicleId = 'uint16'}, {panelDmg = 'int32'}, {doorDmg = 'int32'}, {lights = 'uint8'}, {tires = 'uint8'}}
OUTCOMING_RPCS[RPC.EDITATTACHEDOBJECT]        = {'onSendEditAttachedObject', {response = 'int32'}, {index = 'int32'}, {model = 'int32'}, {bone = 'int32'}, {position = 'vector3d'}, {rotation = 'vector3d'}, {scale = 'vector3d'}, {color1 = 'int32'}, {color2 = 'int32'}}
OUTCOMING_RPCS[RPC.EDITOBJECT]                = {'onSendEditObject', {playerObject = 'bool'}, {objectId = 'uint16'}, {response = 'int32'}, {position = 'vector3d'}, {rotation = 'vector3d'}}
OUTCOMING_RPCS[RPC.SETINTERIORID]             = {'onSendInteriorChangeNotification', {interior = 'uint8'}}
OUTCOMING_RPCS[RPC.MAPMARKER]                 = {'onSendMapMarker', {position = 'vector3d'}}
OUTCOMING_RPCS[RPC.REQUESTCLASS]              = {'onSendRequestClass', {classId = 'int32'}}
OUTCOMING_RPCS[RPC.REQUESTSPAWN]              = {'onSendRequestSpawn'}
OUTCOMING_RPCS[RPC.PICKEDUPPICKUP]            = {'onSendPickedUpPickup', {pickupId = 'int32'}}
OUTCOMING_RPCS[RPC.MENUSELECT]                = {'onSendMenuSelect', {row = 'uint8'}}
OUTCOMING_RPCS[RPC.VEHICLEDESTROYED]          = {'onSendVehicleDestroyed', {vehicleId = 'uint16'}}
OUTCOMING_RPCS[RPC.MENUQUIT]                  = {'onSendQuitMenu'}
OUTCOMING_RPCS[RPC.EXITVEHICLE]               = {'onSendExitVehicle', {vehicleId = 'uint16'}}
OUTCOMING_RPCS[RPC.UPDATESCORESPINGSIPS]      = {'onSendUpdateScoresAndPings'}
-- playerId = 'uint16', damage = 'float', weapon = 'int32', bodypart ='int32'
OUTCOMING_RPCS[RPC.GIVETAKEDAMAGE]            = {{'onSendGiveDamage', 'onSendTakeDamage'}, handler.rpc_send_give_take_damage_reader, handler.rpc_send_give_take_damage_writer}
OUTCOMING_RPCS[RPC.SCRIPTCASH] = {'onSendMoneyIncreaseNotification', {amount = 'int32'}, {increaseType = 'int32'}}
OUTCOMING_RPCS[RPC.NPCJOIN] = {'onSendNPCJoin', {version = 'int32'}, {mod = 'uint8'}, {nickname = 'string8'}, {challengeResponse = 'int32'}}
OUTCOMING_RPCS[RPC.SRVNETSTATS] = {'onSendServerStatisticsRequest'}
OUTCOMING_RPCS[RPC.WEAPONPICKUPDESTROY] = {'onSendPickedUpWeapon', {id = 'uint16'}}
OUTCOMING_RPCS[RPC.CAMTARGETUPDATE] = {'onSendCameraTargetUpdate', {objectId = 'uint16'}, {vehicleId = 'uint16'}, {playerId = 'uint16'}, {actorId = 'uint16'}}
OUTCOMING_RPCS[RPC.GIVEACTORDAMAGE] = {'onSendGiveActorDamage', {_unused = 'bool'}, {actorId = 'uint16'}, {damage = 'float'}, {weapon = 'int32'}, {bodypart ='int32'}}

-- Incoming rpcs
-- int playerId, string hostName, table settings, table vehicleModels, bool vehicleFriendlyFire
INCOMING_RPCS[RPC.INITGAME]                   = {'onInitGame', handler.rpc_init_game_reader, handler.rpc_init_game_writer}
INCOMING_RPCS[RPC.SERVERJOIN]                 = {'onPlayerJoin', {playerId = 'uint16'}, {color = 'int32'}, {isNpc = 'bool8'}, {nickname = 'string8'}}
INCOMING_RPCS[RPC.SERVERQUIT]                 = {'onPlayerQuit', {playerId = 'uint16'}, {reason = 'uint8'}}
INCOMING_RPCS[RPC.REQUESTCLASS]               = {'onRequestClassResponse', {canSpawn = 'bool8'}, {team = 'uint8'}, {skin = 'int32'}, {_unused = 'uint8'}, {positon = 'vector3d'}, {rotation = 'float'}, {weapons = 'Int32Array3'}, {ammo = 'Int32Array3'}}
INCOMING_RPCS[RPC.REQUESTSPAWN]               = {'onRequestSpawnResponse', {response = 'bool8'}}
INCOMING_RPCS[RPC.SETPLAYERNAME]              = {'onSetPlayerName', {playerId = 'uint16'}, {name = 'string8'}, {success = 'bool8'}}
INCOMING_RPCS[RPC.SETPLAYERPOS]               = {'onSetPlayerPos', {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETPLAYERPOSFINDZ]          = {'onSetPlayerPosFindZ', {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETPLAYERHEALTH]            = {'onSetPlayerHealth', {health = 'float'}}
INCOMING_RPCS[RPC.TOGGLEPLAYERCONTROLLABLE]   = {'onTogglePlayerControllable', {controllable = 'bool8'}}
INCOMING_RPCS[RPC.PLAYSOUND]                  = {'onPlaySound', {soundId = 'int32'}, {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETPLAYERWORLDBOUNDS]       = {'onSetWorldBounds', {maxX = 'float'}, {minX = 'float'}, {maxY = 'float'}, {minY = 'float'}}
INCOMING_RPCS[RPC.GIVEPLAYERMONEY]            = {'onGivePlayerMoney', {money = 'int32'}}
INCOMING_RPCS[RPC.SETPLAYERFACINGANGLE]       = {'onSetPlayerFacingAngle', {angle = 'float'}}
INCOMING_RPCS[RPC.RESETPLAYERMONEY]           = {'onResetPlayerMoney'}
INCOMING_RPCS[RPC.RESETPLAYERWEAPONS]         = {'onResetPlayerWeapons'}
INCOMING_RPCS[RPC.GIVEPLAYERWEAPON]           = {'onGivePlayerWeapon', {weaponId = 'int32'}, {ammo = 'int32'}}
INCOMING_RPCS[RPC.CANCELEDIT]                 = {'onCancelEdit'}
INCOMING_RPCS[RPC.SETPLAYERTIME]              = {'onSetPlayerTime', {hour = 'uint8'}, {minute = 'uint8'}}
INCOMING_RPCS[RPC.TOGGLECLOCK]                = {'onSetToggleClock', {state = 'bool8'}}
INCOMING_RPCS[RPC.WORLDPLAYERADD]             = {'onPlayerStreamIn', {playerId = 'uint16'}, {team = 'uint8'}, {model = 'int32'}, {position = 'vector3d'}, {rotation = 'float'}, {color = 'int32'}, {fightingStyle = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERSHOPNAME]          = {'onSetShopName', {name = 'fixedString32'}}
INCOMING_RPCS[RPC.SETPLAYERSKILLLEVEL]        = {'onSetPlayerSkillLevel', {playerId = 'uint16'}, {skill = 'int32'}, {level = 'uint16'}}
INCOMING_RPCS[RPC.SETPLAYERDRUNKLEVEL]        = {'onSetPlayerDrunk', {drunkLevel = 'int32'}}
INCOMING_RPCS[RPC.CREATE3DTEXTLABEL]          = {'onCreate3DText', {id = 'uint16'}, {color = 'int32'}, {position = 'vector3d'}, {distance = 'float'}, {testLOS = 'bool8'}, {attachedPlayerId = 'uint16'}, {attachedVehicleId = 'uint16'}, {text = 'encodedString4096'}}
INCOMING_RPCS[RPC.DISABLECHECKPOINT]          = {'onDisableCheckpoint'}
INCOMING_RPCS[RPC.SETRACECHECKPOINT]          = {'onSetRaceCheckpoint', {type = 'uint8'}, {position = 'vector3d'}, {nextPosition = 'vector3d'}, {size = 'float'}}
INCOMING_RPCS[RPC.DISABLERACECHECKPOINT]      = {'onDisableRaceCheckpoint'}
INCOMING_RPCS[RPC.GAMEMODERESTART]            = {'onGamemodeRestart'}
INCOMING_RPCS[RPC.PLAYAUDIOSTREAM]            = {'onPlayAudioStream', {url = 'string8'}, {position = 'vector3d'}, {radius = 'float'}, {usePosition = 'bool8'}}
INCOMING_RPCS[RPC.STOPAUDIOSTREAM]            = {'onStopAudioStream'}
INCOMING_RPCS[RPC.REMOVEBUILDINGFORPLAYER]    = {'onRemoveBuilding', {modelId = 'int32'}, {position = 'vector3d'}, {radius = 'float'}}
INCOMING_RPCS[RPC.CREATEOBJECT]               = {'onCreateObject', handler.rpc_create_object_reader, handler.rpc_create_object_writer}
INCOMING_RPCS[RPC.SETOBJECTPOS]               = {'onSetObjectPosition', {objectId = 'uint16'}, {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETOBJECTROT]               = {'onSetObjectRotation', {objectId = 'uint16'}, {rotation = 'vector3d'}}
INCOMING_RPCS[RPC.DESTROYOBJECT]              = {'onDestroyObject', {objectId = 'uint16'}}
INCOMING_RPCS[RPC.DEATHMESSAGE]               = {'onPlayerDeathNotification', {killerId = 'uint16'}, {killedId = 'uint16'}, {reason = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERMAPICON]           = {'onSetMapIcon', {iconId = 'uint8'}, {position = 'vector3d'}, {type = 'uint8'}, {color = 'int32'}, {style = 'uint8'}}
INCOMING_RPCS[RPC.REMOVEVEHICLECOMPONENT]     = {'onRemoveVehicleComponent', {vehicleId = 'uint16'}, {componentId = 'uint16'}}
INCOMING_RPCS[RPC.DESTROY3DTEXTLABEL]         = {'onRemove3DTextLabel', {textLabelId = 'uint16'}}
INCOMING_RPCS[RPC.CHATBUBBLE]                 = {'onPlayerChatBubble', {playerId = 'uint16'}, {color = 'int32'}, {distance = 'float'}, {duration = 'int32'}, {message = 'string8'}}
INCOMING_RPCS[RPC.UPDATETIME]                 = {'onUpdateGlobalTimer', {time = 'int32'}}
INCOMING_RPCS[RPC.SHOWDIALOG]                 = {'onShowDialog', {dialogId = 'uint16'}, {style = 'uint8'}, {title = 'string8'}, {button1 = 'string8'}, {button2 = 'string8'}, {text = 'encodedString4096'}}
INCOMING_RPCS[RPC.DESTROYPICKUP]              = {'onDestroyPickup', {id = 'int32'}}
INCOMING_RPCS[RPC.LINKVEHICLETOINTERIOR]      = {'onLinkVehicleToInterior', {vehicleId = 'uint16'}, {interiorId = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERARMOUR]            = {'onSetPlayerArmour', {armour = 'float'}}
INCOMING_RPCS[RPC.SETPLAYERARMEDWEAPON]       = {'onSetPlayerArmedWeapon', {weaponId = 'int32'}}
INCOMING_RPCS[RPC.SETSPAWNINFO]               = {'onSetSpawnInfo', {team = 'uint8'}, {skin = 'int32'}, {_unused = 'uint8'}, {position = 'vector3d'}, {rotation = 'float'}, {weapons = 'Int32Array3'}, {ammo = 'Int32Array3'}}
INCOMING_RPCS[RPC.SETPLAYERTEAM]              = {'onSetPlayerTeam', {playerId = 'uint16'}, {teamId = 'uint8'}}
INCOMING_RPCS[RPC.PUTPLAYERINVEHICLE]         = {'onPutPlayerInVehicle', {vehicleId = 'uint16'}, {seatId = 'uint8'}}
INCOMING_RPCS[RPC.REMOVEPLAYERFROMVEHICLE]    = {'onRemovePlayerFromVehicle'}
INCOMING_RPCS[RPC.SETPLAYERCOLOR]             = {'onSetPlayerColor', {playerId = 'uint16'}, {color = 'int32'}}
INCOMING_RPCS[RPC.DISPLAYGAMETEXT]            = {'onDisplayGameText', {style = 'int32'}, {time = 'int32'}, {text = 'string32'}}
INCOMING_RPCS[RPC.FORCECLASSSELECTION]        = {'onForceClassSelection'}
INCOMING_RPCS[RPC.ATTACHOBJECTTOPLAYER]       = {'onAttachObjectToPlayer', {objectId = 'uint16'}, {playerId = 'uint16'}, {offsets = 'vector3d'}, {rotation = 'vector3d'}}
-- menuId = 'uint8', menuTitle = 'fixedString32', x = 'float', y = 'float', twoColumns = 'bool32', columns = 'table', rows = 'table', menu = 'bool32'
INCOMING_RPCS[RPC.INITMENU]                   = {'onInitMenu', handler.rpc_init_menu_reader, handler.rpc_init_menu_writer}
INCOMING_RPCS[RPC.SHOWMENU]                   = {'onShowMenu', {menuId = 'uint8'}}
INCOMING_RPCS[RPC.HIDEMENU]                   = {'onHideMenu', {menuId = 'uint8'}}
INCOMING_RPCS[RPC.CREATEEXPLOSION]            = {'onCreateExplosion', {position = 'vector3d'}, {style = 'int32'}, {radius = 'float'}}
INCOMING_RPCS[RPC.SHOWPLAYERNAMETAGFORPLAYER] = {'onShowPlayerNameTag', {playerId = 'uint16'}, {show = 'bool8'}}
INCOMING_RPCS[RPC.ATTACHCAMERATOOBJECT]       = {'onAttachCameraToObject', {objectId = 'uint16'}}
INCOMING_RPCS[RPC.INTERPOLATECAMERA]          = {'onInterpolateCamera', {setPos = 'bool'}, {fromPos = 'vector3d'}, {destPos = 'vector3d'}, {time = 'int32'}, {mode = 'uint8'}}
INCOMING_RPCS[RPC.GANGZONESTOPFLASH]          = {'onGangZoneStopFlash', {zoneId = 'uint16'}}
INCOMING_RPCS[RPC.APPLYANIMATION]             = {'onApplyPlayerAnimation', {playerId = 'uint16'}, {animLib = 'string8'}, {animName = 'string8'}, {frameDelta = 'float'}, {loop = 'bool'}, {lockX = 'bool'}, {lockY = 'bool'}, {freeze = 'bool'}, {time = 'int32'}}
INCOMING_RPCS[RPC.CLEARANIMATIONS]            = {'onClearPlayerAnimation', {playerId = 'uint16'}}
INCOMING_RPCS[RPC.SETPLAYERSPECIALACTION]     = {'onSetPlayerSpecialAction', {actionId = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERFIGHTINGSTYLE]     = {'onSetPlayerFightingStyle', {playerId = 'uint16'}, {styleId = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERVELOCITY]          = {'onSetPlayerVelocity', {velocity = 'vector3d'}}
INCOMING_RPCS[RPC.SETVEHICLEVELOCITY]         = {'onSetVehicleVelocity', {turn = 'bool8'}, {velocity = 'vector3d'}}
INCOMING_RPCS[RPC.CLIENTMESSAGE]              = {'onServerMessage', {color = 'int32'}, {text = 'string32'}}
INCOMING_RPCS[RPC.SETWORLDTIME]               = {'onSetWorldTime', {hour = 'uint8'}}
INCOMING_RPCS[RPC.CREATEPICKUP]               = {'onCreatePickup', {id = 'int32'}, {model = 'int32'}, {pickupType = 'int32'}, {position = 'vector3d'}}
INCOMING_RPCS[RPC.MOVEOBJECT]                 = {'onMoveObject', {objectId = 'uint16'}, {fromPos = 'vector3d'}, {destPos = 'vector3d'}, {speed = 'float'}, {rotation = 'vector3d'}}
INCOMING_RPCS[RPC.ENABLESTUNTBONUSFORPLAYER]  = {'onEnableStuntBonus', {state = 'bool'}}
INCOMING_RPCS[RPC.TEXTDRAWSETSTRING]          = {'onTextDrawSetString', {id = 'uint16'}, {text = 'string16'}}
INCOMING_RPCS[RPC.SETCHECKPOINT]              = {'onSetCheckpoint', {position = 'vector3d'}, {radius = 'float'}}
INCOMING_RPCS[RPC.GANGZONECREATE]             = {'onCreateGangZone', {zoneId = 'uint16'}, {squareStart = 'vector2d'}, {squareEnd = 'vector2d'}, {color = 'int32'}}
INCOMING_RPCS[RPC.PLAYCRIMEREPORT]            = {'onPlayCrimeReport', {suspectId = 'uint16'}, {inVehicle = 'bool32'}, {vehicleModel = 'int32'}, {vehicleColor = 'int32'}, {crime = 'int32'}, {coordinates = 'vector3d'}}
INCOMING_RPCS[RPC.GANGZONEDESTROY]            = {'onGangZoneDestroy', {zoneId = 'uint16'}}
INCOMING_RPCS[RPC.GANGZONEFLASH]              = {'onGangZoneFlash', {zoneId = 'uint16'}, {color = 'int32'}}
INCOMING_RPCS[RPC.STOPOBJECT]                 = {'onStopObject', {objectId = 'uint16'}}
INCOMING_RPCS[RPC.SETNUMBERPLATE]             = {'onSetVehicleNumberPlate', {vehicleId = 'uint16'}, {text = 'string8'}}
INCOMING_RPCS[RPC.TOGGLEPLAYERSPECTATING]     = {'onTogglePlayerSpectating', {state = 'bool32'}}
INCOMING_RPCS[RPC.PLAYERSPECTATEPLAYER]       = {'onSpectatePlayer', {playerId = 'uint16'}, {camType = 'uint8'}}
INCOMING_RPCS[RPC.PLAYERSPECTATEVEHICLE]      = {'onSpectateVehicle', {vehicleId = 'uint16'}, {camType = 'uint8'}}
INCOMING_RPCS[RPC.SHOWTEXTDRAW]               = {'onShowTextDraw',
  {textdrawId = 'uint16'},
  {textdraw = {
    {flags = 'uint8'},
    {letterWidth = 'float'},
    {letterHeight = 'float'},
    {letterColor = 'int32'},
    {lineWidth = 'float'},
    {lineHeight = 'float'},
    {boxColor = 'int32'},
    {shadow = 'uint8'},
    {outline = 'uint8'},
    {backgroundColor = 'int32'},
    {style = 'uint8'},
    {selectable = 'uint8'},
    {position = 'vector2d'},
    {modelId = 'uint16'},
    {rotation = 'vector3d'},
    {zoom = 'float'},
    {color = 'int32'},
    {text = 'string16'}
  }}
}
INCOMING_RPCS[RPC.SETPLAYERWANTEDLEVEL]       = {'onSetPlayerWantedLevel', {wantedLevel = 'uint8'}}
INCOMING_RPCS[RPC.TEXTDRAWHIDEFORPLAYER]      = {'onTextDrawHide', {textDrawId = 'uint16'}}
INCOMING_RPCS[RPC.REMOVEPLAYERMAPICON]        = {'onRemoveMapIcon', {iconId = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERAMMO]              = {'onSetWeaponAmmo', {weaponId = 'uint8'}, {ammo = 'uint16'}}
INCOMING_RPCS[RPC.SETGRAVITY]                 = {'onSetGravity', {gravity = 'float'}}
INCOMING_RPCS[RPC.SETVEHICLEHEALTH]           = {'onSetVehicleHealth', {vehicleId = 'uint16'}, {health = 'float'}}
INCOMING_RPCS[RPC.ATTACHTRAILERTOVEHICLE]     = {'onAttachTrailerToVehicle', {trailerId = 'uint16'}, {vehicleId = 'uint16'}}
INCOMING_RPCS[RPC.DETACHTRAILERFROMVEHICLE]   = {'onDetachTrailerFromVehicle', {vehicleId = 'uint16'}}
INCOMING_RPCS[RPC.SETWEATHER]                 = {'onSetWeather', {weatherId = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERSKIN]              = {'onSetPlayerSkin', {playerId = 'int32'}, {skinId = 'int32'}}
INCOMING_RPCS[RPC.SETPLAYERINTERIOR]          = {'onSetInterior', {interior = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERCAMERAPOS]         = {'onSetCameraPosition', {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETPLAYERCAMERALOOKAT]      = {'onSetCameraLookAt', {lookAtPosition = 'vector3d'}, {cutType = 'uint8'}}
INCOMING_RPCS[RPC.SETVEHICLEPOS]              = {'onSetVehiclePosition', {vehicleId = 'uint16'}, {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETVEHICLEZANGLE]           = {'onSetVehicleAngle', {vehicleId = 'uint16'}, {angle = 'float'}}
INCOMING_RPCS[RPC.SETVEHICLEPARAMSFORPLAYER]  = {'onSetVehicleParams', {vehicleId = 'uint16'}, {objective = 'bool8'}, {doorsLocked = 'bool8'}}
INCOMING_RPCS[RPC.SETCAMERABEHINDPLAYER]      = {'onSetCameraBehind'}
INCOMING_RPCS[RPC.CHAT]                       = {'onChatMessage', {playerId = 'uint16'}, {text = 'string8'}}
INCOMING_RPCS[RPC.CONNECTIONREJECTED]         = {'onConnectionRejected', {reason = 'uint8'}}
INCOMING_RPCS[RPC.WORLDPLAYERREMOVE]          = {'onPlayerStreamOut', {playerId = 'uint16'}}
INCOMING_RPCS[RPC.WORLDVEHICLEADD]            = {'onVehicleStreamIn', handler.rpc_vehicle_stream_in_reader, handler.rpc_vehicle_stream_in_writer}
INCOMING_RPCS[RPC.WORLDVEHICLEREMOVE]         = {'onVehicleStreamOut', {vehicleId = 'uint16'}}
INCOMING_RPCS[RPC.WORLDPLAYERDEATH]           = {'onPlayerDeath', {playerId = 'uint16'}}
INCOMING_RPCS[RPC.ENTERVEHICLE]               = {'onPlayerEnterVehicle', {playerId = 'uint16'}, {vehicleId = 'uint16'}, {passenger = 'bool8'}}
INCOMING_RPCS[RPC.UPDATESCORESPINGSIPS]       = {'onUpdateScoresAndPings', handler.rpc_update_scores_and_pings_reader, handler.rpc_update_scores_and_pings_writer}
INCOMING_RPCS[RPC.SETOBJECTMATERIAL]          = {{'onSetObjectMaterial', 'onSetObjectMaterialText'}, handler.rpc_set_object_material_reader, handler.rpc_set_object_material_writer}
INCOMING_RPCS[RPC.CREATEACTOR]                = {'onCreateActor', {actorId = 'uint16'}, {skinId = 'int32'}, {position = 'vector3d'}, {rotation = 'float'}, {health = 'float'}}
INCOMING_RPCS[RPC.CLICKTEXTDRAW]              = {'onToggleSelectTextDraw', {state = 'bool'}, {hovercolor = 'int32'}}
INCOMING_RPCS[RPC.SETVEHICLEPARAMSEX]         = {'onSetVehicleParamsEx',
  {vehicleId = 'uint16'},
  {params = {
    {engine = 'uint8'},
    {lights = 'uint8'},
    {alarm = 'uint8'},
    {doors = 'uint8'},
    {bonnet = 'uint8'},
    {boot = 'uint8'},
    {objective = 'uint8'},
    {unknown = 'uint8'}
  }},
  {doors = {
    {driver = 'uint8'},
    {passenger = 'uint8'},
    {backleft = 'uint8'},
    {backright = 'uint8'}
  }},
  {windows = {
    {driver = 'uint8'},
    {passenger = 'uint8'},
    {backleft = 'uint8'},
    {backright = 'uint8'}
  }}
}
INCOMING_RPCS[RPC.SETPLAYERATTACHEDOBJECT]    = {'onSetPlayerAttachedObject',
  {playerId = 'uint16'},
  {index = 'int32'},
  {create = 'bool'},
  {object = {
    {modelId = 'int32'},
    {bone = 'int32'},
    {offset = 'vector3d'},
    {rotation = 'vector3d'},
    {scale = 'vector3d'},
    {color1 = 'int32'},
    {color2 = 'int32'}}
  }
}
INCOMING_RPCS[RPC.CLIENTCHECK] = {'onClientCheck', {requestType = 'uint8'}, {subject = 'int32'}, {offset = 'uint16'}, {length = 'uint16'}}
INCOMING_RPCS[RPC.DESTROYACTOR] = {'onDestroyActor', {actorId = 'uint16'}}
INCOMING_RPCS[RPC.DESTROYWEAPONPICKUP] = {'onDestroyWeaponPickup', {id = 'uint8'}}
INCOMING_RPCS[RPC.EDITATTACHEDOBJECT] = {'onEditAttachedObject', {index = 'int32'}}
INCOMING_RPCS[RPC.TOGGLECAMERATARGET] = {'onToggleCameraTargetNotifying', {enable = 'bool'}}
INCOMING_RPCS[RPC.SELECTOBJECT] = {'onEnterSelectObject'}
INCOMING_RPCS[RPC.EXITVEHICLE] = {'onPlayerExitVehicle', {playerId = 'uint16'}, {vehicleId = 'uint16'}}
INCOMING_RPCS[RPC.SCMEVENT] = {'onVehicleTuningNotification', {playerId = 'uint16'}, {event = 'int32'}, {vehicleId = 'int32'}, {param1 = 'int32'}, {param2 = 'int32'}}
INCOMING_RPCS[RPC.SRVNETSTATS] = {'onServerStatisticsResponse'} --, {data = 'RakNetStatisticsStruct'}}
INCOMING_RPCS[RPC.EDITOBJECT] = {'onEnterEditObject', {playerObject = 'bool'}, {objectId = 'uint16'}}
INCOMING_RPCS[RPC.DAMAGEVEHICLE] = {'onVehicleDamageStatusUpdate', {vehicleId = 'uint16'}, {panelDmg = 'int32'}, {doorDmg = 'int32'}, {lights = 'uint8'}, {tires = 'uint8'}}
INCOMING_RPCS[RPC.DISABLEVEHICLECOLLISIONS] = {'onDisableVehicleCollisions', {disable = 'bool'}}
INCOMING_RPCS[RPC.TOGGLEWIDESCREEN] = {'onToggleWidescreen', {enable = 'bool8'}}
INCOMING_RPCS[RPC.SETVEHICLETIRES] = {'onSetVehicleTires', {vehicleId = 'uint16'}, {tires = 'uint8'}}
INCOMING_RPCS[RPC.SETPLAYERDRUNKVISUALS] = {'onSetPlayerDrunkVisuals', {level = 'int32'}}
INCOMING_RPCS[RPC.SETPLAYERDRUNKHANDLING] = {'onSetPlayerDrunkHandling', {level = 'int32'}}
INCOMING_RPCS[RPC.APPLYACTORANIMATION] = {'onApplyActorAnimation', {actorId = 'uint16'}, {animLib = 'string8'}, {animName = 'string8'}, {frameDelta = 'float'}, {loop = 'bool'}, {lockX = 'bool'}, {lockY = 'bool'}, {freeze = 'bool'}, {time = 'int32'}}
INCOMING_RPCS[RPC.CLEARACTORANIMATION] = {'onClearActorAnimation', {actorId = 'uint16'}}
INCOMING_RPCS[RPC.SETACTORROTATION] = {'onSetActorFacingAngle', {actorId = 'uint16'}, {angle = 'float'}}
INCOMING_RPCS[RPC.SETACTORPOSITION] = {'onSetActorPos', {actorId = 'uint16'}, {position = 'vector3d'}}
INCOMING_RPCS[RPC.SETACTORHEALTH] = {'onSetActorHealth', {actorId = 'uint16'}, {health = 'float'}}
INCOMING_RPCS[RPC.SETPLAYEROBJECTNOCAMCOL] = {'onSetPlayerObjectNoCameraCol', {objectId = 'uint16'}}
INCOMING_RPCS[125] = {'_dummy125'}
INCOMING_RPCS[64] = {'_dummy64', {'uint16'}}
INCOMING_RPCS[48] = {'_unused48', {'int32'}}


-- Outgoing packets
OUTCOMING_PACKETS[PACKET.RCON_COMMAND]        = {'onSendRconCommand', {command = 'string32'}}
OUTCOMING_PACKETS[PACKET.STATS_UPDATE]        = {'onSendStatsUpdate', {money = 'int32'}, {drunkLevel = 'int32'}}
local function empty_writer() end
OUTCOMING_PACKETS[PACKET.PLAYER_SYNC]         = {'onSendPlayerSync', function(bs) return utils.process_outcoming_sync_data(bs, 'PlayerSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.VEHICLE_SYNC]        = {'onSendVehicleSync', function(bs) return utils.process_outcoming_sync_data(bs, 'VehicleSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.PASSENGER_SYNC]      = {'onSendPassengerSync', function(bs) return utils.process_outcoming_sync_data(bs, 'PassengerSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.AIM_SYNC]            = {'onSendAimSync', function(bs) return utils.process_outcoming_sync_data(bs, 'AimSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.UNOCCUPIED_SYNC]     = {'onSendUnoccupiedSync', function(bs) return utils.process_outcoming_sync_data(bs, 'UnoccupiedSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.TRAILER_SYNC]        = {'onSendTrailerSync', function(bs) return utils.process_outcoming_sync_data(bs, 'TrailerSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.BULLET_SYNC]         = {'onSendBulletSync', function(bs) return utils.process_outcoming_sync_data(bs, 'BulletSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.SPECTATOR_SYNC]      = {'onSendSpectatorSync', function(bs) return utils.process_outcoming_sync_data(bs, 'SpectatorSyncData') end, empty_writer}
OUTCOMING_PACKETS[PACKET.WEAPONS_UPDATE] = {'onSendWeaponsUpdate', handler.packet_weapons_update_reader, handler.packet_weapons_update_writer}
OUTCOMING_PACKETS[PACKET.AUTHENTICATION] = {'onSendAuthenticationResponse', {response = 'string8'}}

-- Incoming packets
INCOMING_PACKETS[PACKET.PLAYER_SYNC]          = {'onPlayerSync', handler.packet_player_sync_reader, handler.packet_player_sync_writer}
INCOMING_PACKETS[PACKET.VEHICLE_SYNC]         = {'onVehicleSync', handler.packet_vehicle_sync_reader, handler.packet_vehicle_sync_writer}
INCOMING_PACKETS[PACKET.MARKERS_SYNC]         = {'onMarkersSync', handler.packet_markers_sync_reader, handler.packet_markers_sync_writer}
INCOMING_PACKETS[PACKET.AIM_SYNC]             = {'onAimSync', {playerId = 'uint16'}, {data = 'AimSyncData'}}
INCOMING_PACKETS[PACKET.BULLET_SYNC]          = {'onBulletSync', {playerId = 'uint16'}, {data = 'BulletSyncData'}}
INCOMING_PACKETS[PACKET.UNOCCUPIED_SYNC]      = {'onUnoccupiedSync', {playerId = 'uint16'}, {data = 'UnoccupiedSyncData'}}
INCOMING_PACKETS[PACKET.TRAILER_SYNC]         = {'onTrailerSync', {playerId = 'uint16'}, {data = 'TrailerSyncData'}}
INCOMING_PACKETS[PACKET.PASSENGER_SYNC]       = {'onPassengerSync', {playerId = 'uint16'}, {data = 'PassengerSyncData'}}
INCOMING_PACKETS[PACKET.AUTHENTICATION] = {'onAuthenticationRequest', {key = 'string8'}}
INCOMING_PACKETS[PACKET.CONNECTION_REQUEST_ACCEPTED] = {'onConnectionRequestAccepted', {ip = 'int32'}, {port = 'uint16'}, {playerId = 'uint16'}, {challenge = 'int32'}}
INCOMING_PACKETS[PACKET.CONNECTION_LOST] = {'onConnectionLost'}
INCOMING_PACKETS[PACKET.CONNECTION_BANNED] = {'onConnectionBanned'}
INCOMING_PACKETS[PACKET.CONNECTION_ATTEMPT_FAILED] = {'onConnectionAttemptFailed'}
INCOMING_PACKETS[PACKET.NO_FREE_INCOMING_CONNECTIONS] = {'onConnectionNoFreeSlot'}
INCOMING_PACKETS[PACKET.INVALID_PASSWORD] = {'onConnectionPasswordInvalid'}
INCOMING_PACKETS[PACKET.DISCONNECTION_NOTIFICATION] = {'onConnectionClosed'}

return events
 
-- File: raknet.lua 
-- This file is part of the SAMP.Lua project.
-- Licensed under the MIT License.
-- Copyright (c) 2016, FYP @ BlastHack Team <blast.hk>
-- https://github.com/THE-FYP/SAMP.Lua

local mod =
{
	MODULEINFO = {
		name = 'samp.raknet',
		version = 2
	}
}
require 'sampfuncs'

mod.RPC = {
	CLICKPLAYER                   = RPC_CLICKPLAYER,
	CLIENTJOIN                    = RPC_CLIENTJOIN,
	ENTERVEHICLE                  = RPC_ENTERVEHICLE,
	SCRIPTCASH                    = RPC_SCRIPTCASH,
	SERVERCOMMAND                 = RPC_SERVERCOMMAND,
	SPAWN                         = RPC_SPAWN,
	DEATH                         = RPC_DEATH,
	NPCJOIN                       = RPC_NPCJOIN,
	DIALOGRESPONSE                = RPC_DIALOGRESPONSE,
	CLICKTEXTDRAW                 = RPC_CLICKTEXTDRAW,
	SCMEVENT                      = RPC_SCMEVENT,
	WEAPONPICKUPDESTROY           = RPC_WEAPONPICKUPDESTROY,
	CHAT                          = RPC_CHAT,
	SRVNETSTATS                   = RPC_SRVNETSTATS,
	CLIENTCHECK                   = RPC_CLIENTCHECK,
	DAMAGEVEHICLE                 = RPC_DAMAGEVEHICLE,
	GIVETAKEDAMAGE                = RPC_GIVETAKEDAMAGE,
	EDITATTACHEDOBJECT            = RPC_EDITATTACHEDOBJECT,
	EDITOBJECT                    = RPC_EDITOBJECT,
	SETINTERIORID                 = RPC_SETINTERIORID,
	MAPMARKER                     = RPC_MAPMARKER,
	REQUESTCLASS                  = RPC_REQUESTCLASS,
	REQUESTSPAWN                  = RPC_REQUESTSPAWN,
	PICKEDUPPICKUP                = RPC_PICKEDUPPICKUP,
	MENUSELECT                    = RPC_MENUSELECT,
	VEHICLEDESTROYED              = RPC_VEHICLEDESTROYED,
	MENUQUIT                      = RPC_MENUQUIT,
	EXITVEHICLE                   = RPC_EXITVEHICLE,
	UPDATESCORESPINGSIPS          = RPC_UPDATESCORESPINGSIPS,
	CAMTARGETUPDATE = 168,
	GIVEACTORDAMAGE = 177,

	CONNECTIONREJECTED            = 130,
	SETPLAYERNAME                 = RPC_SCRSETPLAYERNAME,
	SETPLAYERPOS                  = RPC_SCRSETPLAYERPOS,
	SETPLAYERPOSFINDZ             = RPC_SCRSETPLAYERPOSFINDZ,
	SETPLAYERHEALTH               = RPC_SCRSETPLAYERHEALTH,
	TOGGLEPLAYERCONTROLLABLE      = RPC_SCRTOGGLEPLAYERCONTROLLABLE,
	PLAYSOUND                     = RPC_SCRPLAYSOUND,
	SETPLAYERWORLDBOUNDS          = RPC_SCRSETPLAYERWORLDBOUNDS,
	GIVEPLAYERMONEY               = RPC_SCRGIVEPLAYERMONEY,
	SETPLAYERFACINGANGLE          = RPC_SCRSETPLAYERFACINGANGLE,
	RESETPLAYERMONEY              = RPC_SCRRESETPLAYERMONEY,
	RESETPLAYERWEAPONS            = RPC_SCRRESETPLAYERWEAPONS,
	GIVEPLAYERWEAPON              = RPC_SCRGIVEPLAYERWEAPON,
	SETVEHICLEPARAMSEX            = RPC_SCRSETVEHICLEPARAMSEX,
	CANCELEDIT                    = RPC_SCRCANCELEDIT,
	SETPLAYERTIME                 = RPC_SCRSETPLAYERTIME,
	TOGGLECLOCK                   = RPC_SCRTOGGLECLOCK,
	WORLDPLAYERADD                = RPC_SCRWORLDPLAYERADD,
	SETPLAYERSHOPNAME             = RPC_SCRSETPLAYERSHOPNAME,
	SETPLAYERSKILLLEVEL           = RPC_SCRSETPLAYERSKILLLEVEL,
	SETPLAYERDRUNKLEVEL           = RPC_SCRSETPLAYERDRUNKLEVEL,
	CREATE3DTEXTLABEL             = RPC_SCRCREATE3DTEXTLABEL,
	DISABLECHECKPOINT             = RPC_SCRDISABLECHECKPOINT,
	SETRACECHECKPOINT             = RPC_SCRSETRACECHECKPOINT,
	DISABLERACECHECKPOINT         = RPC_SCRDISABLERACECHECKPOINT,
	GAMEMODERESTART               = RPC_SCRGAMEMODERESTART,
	PLAYAUDIOSTREAM               = RPC_SCRPLAYAUDIOSTREAM,
	STOPAUDIOSTREAM               = RPC_SCRSTOPAUDIOSTREAM,
	REMOVEBUILDINGFORPLAYER       = RPC_SCRREMOVEBUILDINGFORPLAYER,
	CREATEOBJECT                  = RPC_SCRCREATEOBJECT,
	SETOBJECTPOS                  = RPC_SCRSETOBJECTPOS,
	SETOBJECTROT                  = RPC_SCRSETOBJECTROT,
	DESTROYOBJECT                 = RPC_SCRDESTROYOBJECT,
	DEATHMESSAGE                  = RPC_SCRDEATHMESSAGE,
	SETPLAYERMAPICON              = RPC_SCRSETPLAYERMAPICON,
	REMOVEVEHICLECOMPONENT        = RPC_SCRREMOVEVEHICLECOMPONENT,
	CHATBUBBLE                    = RPC_SCRCHATBUBBLE,
	UPDATETIME                    = RPC_SCRSOMEUPDATE,
	SHOWDIALOG                    = RPC_SCRSHOWDIALOG,
	DESTROYPICKUP                 = RPC_SCRDESTROYPICKUP,
	LINKVEHICLETOINTERIOR         = RPC_SCRLINKVEHICLETOINTERIOR,
	SETPLAYERARMOUR               = RPC_SCRSETPLAYERARMOUR,
	SETPLAYERARMEDWEAPON          = RPC_SCRSETPLAYERARMEDWEAPON,
	SETSPAWNINFO                  = RPC_SCRSETSPAWNINFO,
	SETPLAYERTEAM                 = RPC_SCRSETPLAYERTEAM,
	PUTPLAYERINVEHICLE            = RPC_SCRPUTPLAYERINVEHICLE,
	REMOVEPLAYERFROMVEHICLE       = RPC_SCRREMOVEPLAYERFROMVEHICLE,
	SETPLAYERCOLOR                = RPC_SCRSETPLAYERCOLOR,
	DISPLAYGAMETEXT               = RPC_SCRDISPLAYGAMETEXT,
	FORCECLASSSELECTION           = RPC_SCRFORCECLASSSELECTION,
	ATTACHOBJECTTOPLAYER          = RPC_SCRATTACHOBJECTTOPLAYER,
	INITMENU                      = RPC_SCRINITMENU,
	SHOWMENU                      = RPC_SCRSHOWMENU,
	HIDEMENU                      = RPC_SCRHIDEMENU,
	CREATEEXPLOSION               = RPC_SCRCREATEEXPLOSION,
	SHOWPLAYERNAMETAGFORPLAYER    = RPC_SCRSHOWPLAYERNAMETAGFORPLAYER,
	ATTACHCAMERATOOBJECT          = RPC_SCRATTACHCAMERATOOBJECT,
	INTERPOLATECAMERA             = RPC_SCRINTERPOLATECAMERA,
	SETOBJECTMATERIAL             = RPC_SCRSETOBJECTMATERIAL,
	GANGZONESTOPFLASH             = RPC_SCRGANGZONESTOPFLASH,
	APPLYANIMATION                = RPC_SCRAPPLYANIMATION,
	CLEARANIMATIONS               = RPC_SCRCLEARANIMATIONS,
	SETPLAYERSPECIALACTION        = RPC_SCRSETPLAYERSPECIALACTION,
	SETPLAYERFIGHTINGSTYLE        = RPC_SCRSETPLAYERFIGHTINGSTYLE,
	SETPLAYERVELOCITY             = RPC_SCRSETPLAYERVELOCITY,
	SETVEHICLEVELOCITY            = RPC_SCRSETVEHICLEVELOCITY,
	CLIENTMESSAGE                 = RPC_SCRCLIENTMESSAGE,
	SETWORLDTIME                  = RPC_SCRSETWORLDTIME,
	CREATEPICKUP                  = RPC_SCRCREATEPICKUP,
	MOVEOBJECT                    = RPC_SCRMOVEOBJECT,
	ENABLESTUNTBONUSFORPLAYER     = RPC_SCRENABLESTUNTBONUSFORPLAYER,
	TEXTDRAWSETSTRING             = RPC_SCRTEXTDRAWSETSTRING,
	SETCHECKPOINT                 = RPC_SCRSETCHECKPOINT,
	GANGZONECREATE                = RPC_SCRGANGZONECREATE,
	PLAYCRIMEREPORT               = RPC_SCRPLAYCRIMEREPORT,
	SETPLAYERATTACHEDOBJECT       = RPC_SCRSETPLAYERATTACHEDOBJECT,
	GANGZONEDESTROY               = RPC_SCRGANGZONEDESTROY,
	GANGZONEFLASH                 = RPC_SCRGANGZONEFLASH,
	STOPOBJECT                    = RPC_SCRSTOPOBJECT,
	SETNUMBERPLATE                = RPC_SCRSETNUMBERPLATE,
	TOGGLEPLAYERSPECTATING        = RPC_SCRTOGGLEPLAYERSPECTATING,
	PLAYERSPECTATEPLAYER          = RPC_SCRPLAYERSPECTATEPLAYER,
	PLAYERSPECTATEVEHICLE         = RPC_SCRPLAYERSPECTATEVEHICLE,
	SETPLAYERWANTEDLEVEL          = RPC_SCRSETPLAYERWANTEDLEVEL,
	SHOWTEXTDRAW                  = RPC_SCRSHOWTEXTDRAW,
	TEXTDRAWHIDEFORPLAYER         = RPC_SCRTEXTDRAWHIDEFORPLAYER,
	SERVERJOIN                    = RPC_SCRSERVERJOIN,
	SERVERQUIT                    = RPC_SCRSERVERQUIT,
	INITGAME                      = RPC_SCRINITGAME,
	REMOVEPLAYERMAPICON           = RPC_SCRREMOVEPLAYERMAPICON,
	SETPLAYERAMMO                 = RPC_SCRSETPLAYERAMMO,
	SETGRAVITY                    = RPC_SCRSETGRAVITY,
	SETVEHICLEHEALTH              = RPC_SCRSETVEHICLEHEALTH,
	ATTACHTRAILERTOVEHICLE        = RPC_SCRATTACHTRAILERTOVEHICLE,
	DETACHTRAILERFROMVEHICLE      = RPC_SCRDETACHTRAILERFROMVEHICLE,
	SETWEATHER                    = RPC_SCRSETWEATHER,
	SETPLAYERSKIN                 = RPC_SCRSETPLAYERSKIN,
	SETPLAYERINTERIOR             = RPC_SCRSETPLAYERINTERIOR,
	SETPLAYERCAMERAPOS            = RPC_SCRSETPLAYERCAMERAPOS,
	SETPLAYERCAMERALOOKAT         = RPC_SCRSETPLAYERCAMERALOOKAT,
	SETVEHICLEPOS                 = RPC_SCRSETVEHICLEPOS,
	SETVEHICLEZANGLE              = RPC_SCRSETVEHICLEZANGLE,
	SETVEHICLEPARAMSFORPLAYER     = RPC_SCRSETVEHICLEPARAMSFORPLAYER,
	SETCAMERABEHINDPLAYER         = RPC_SCRSETCAMERABEHINDPLAYER,
	WORLDPLAYERREMOVE             = RPC_SCRWORLDPLAYERREMOVE,
	WORLDVEHICLEADD               = RPC_SCRWORLDVEHICLEADD,
	WORLDVEHICLEREMOVE            = RPC_SCRWORLDVEHICLEREMOVE,
	WORLDPLAYERDEATH              = RPC_SCRWORLDPLAYERDEATH,
	CREATEACTOR                   = 171,
	DESTROYACTOR = 172,
	DESTROY3DTEXTLABEL = 58,
	DESTROYWEAPONPICKUP = 151,
	TOGGLECAMERATARGET = 170,
	SELECTOBJECT = 27,
	DISABLEVEHICLECOLLISIONS = 167,
	TOGGLEWIDESCREEN = 111,
	SETVEHICLETIRES = 98,
	SETPLAYERDRUNKVISUALS = 92,
	SETPLAYERDRUNKHANDLING = 150,
	APPLYACTORANIMATION = 173,
	CLEARACTORANIMATION = 174,
	SETACTORROTATION = 175,
	SETACTORPOSITION = 176,
	SETACTORHEALTH = 178,
	SETPLAYEROBJECTNOCAMCOL = 169,

	-- Invalid. Retained only for backward compatibility.
	ENTEREDITOBJECT = RPC_ENTEREDITOBJECT,
	UPDATE3DTEXTLABEL = RPC_SCRUPDATE3DTEXTLABEL,
}

mod.PACKET = {
	VEHICLE_SYNC                      = PACKET_VEHICLE_SYNC,
	RCON_COMMAND                      = PACKET_RCON_COMMAND,
	RCON_RESPONCE                     = PACKET_RCON_RESPONCE,
	AIM_SYNC                          = PACKET_AIM_SYNC,
	WEAPONS_UPDATE                    = PACKET_WEAPONS_UPDATE,
	STATS_UPDATE                      = PACKET_STATS_UPDATE,
	BULLET_SYNC                       = PACKET_BULLET_SYNC,
	PLAYER_SYNC                       = PACKET_PLAYER_SYNC,
	MARKERS_SYNC                      = PACKET_MARKERS_SYNC,
	UNOCCUPIED_SYNC                   = PACKET_UNOCCUPIED_SYNC,
	TRAILER_SYNC                      = PACKET_TRAILER_SYNC,
	PASSENGER_SYNC                    = PACKET_PASSENGER_SYNC,
	SPECTATOR_SYNC                    = PACKET_SPECTATOR_SYNC,

	INTERNAL_PING                     = PACKET_INTERNAL_PING,
	PING                              = PACKET_PING,
	PING_OPEN_CONNECTIONS             = PACKET_PING_OPEN_CONNECTIONS,
	CONNECTED_PONG                    = PACKET_CONNECTED_PONG,
	REQUEST_STATIC_DATA               = PACKET_REQUEST_STATIC_DATA,
	CONNECTION_REQUEST                = PACKET_CONNECTION_REQUEST,
	AUTHENTICATION                    = PACKET_AUTH_KEY,
	BROADCAST_PINGS                   = PACKET_BROADCAST_PINGS,
	SECURED_CONNECTION_RESPONSE       = PACKET_SECURED_CONNECTION_RESPONSE,
	SECURED_CONNECTION_CONFIRMATION   = PACKET_SECURED_CONNECTION_CONFIRMATION,
	RPC_MAPPING                       = PACKET_RPC_MAPPING,
	SET_RANDOM_NUMBER_SEED            = PACKET_SET_RANDOM_NUMBER_SEED,
	RPC                               = PACKET_RPC,
	RPC_REPLY                         = PACKET_RPC_REPLY,
	DETECT_LOST_CONNECTIONS           = PACKET_DETECT_LOST_CONNECTIONS,
	OPEN_CONNECTION_REQUEST           = PACKET_OPEN_CONNECTION_REQUEST,
	OPEN_CONNECTION_REPLY             = PACKET_OPEN_CONNECTION_REPLY,
	CONNECTION_COOKIE                 = PACKET_CONNECTION_COOKIE,
	RSA_PUBLIC_KEY_MISMATCH           = PACKET_RSA_PUBLIC_KEY_MISMATCH,
	CONNECTION_ATTEMPT_FAILED         = PACKET_CONNECTION_ATTEMPT_FAILED,
	NEW_INCOMING_CONNECTION           = PACKET_NEW_INCOMING_CONNECTION,
	NO_FREE_INCOMING_CONNECTIONS      = PACKET_NO_FREE_INCOMING_CONNECTIONS,
	DISCONNECTION_NOTIFICATION        = PACKET_DISCONNECTION_NOTIFICATION,
	CONNECTION_LOST                   = PACKET_CONNECTION_LOST,
	CONNECTION_REQUEST_ACCEPTED       = PACKET_CONNECTION_REQUEST_ACCEPTED,
	INITIALIZE_ENCRYPTION             = PACKET_INITIALIZE_ENCRYPTION,
	CONNECTION_BANNED                 = PACKET_CONNECTION_BANNED,
	INVALID_PASSWORD                  = PACKET_INVALID_PASSWORD,
	MODIFIED_PACKET                   = PACKET_MODIFIED_PACKET,
	PONG                              = PACKET_PONG,
	TIMESTAMP                         = PACKET_TIMESTAMP,
	RECEIVED_STATIC_DATA              = PACKET_RECEIVED_STATIC_DATA,
	REMOTE_DISCONNECTION_NOTIFICATION = PACKET_REMOTE_DISCONNECTION_NOTIFICATION,
	REMOTE_CONNECTION_LOST            = PACKET_REMOTE_CONNECTION_LOST,
	REMOTE_NEW_INCOMING_CONNECTION    = PACKET_REMOTE_NEW_INCOMING_CONNECTION,
	REMOTE_EXISTING_CONNECTION        = PACKET_REMOTE_EXISTING_CONNECTION,
	REMOTE_STATIC_DATA                = PACKET_REMOTE_STATIC_DATA,
	ADVERTISE_SYSTEM                  = PACKET_ADVERTISE_SYSTEM,

	AUTH_KEY                          = PACKET_AUTH_KEY,
}

return mod
 
-- File: synchronization.lua 
-- This file is part of the SAMP.Lua project.
-- Licensed under the MIT License.
-- Copyright (c) 2016, FYP @ BlastHack Team <blast.hk>
-- https://github.com/THE-FYP/SAMP.Lua

local mod =
{
	MODULEINFO = {
		name = 'samp.synchronization',
		version = 2
	}
}
local ffi = require 'ffi'

ffi.cdef[[
#pragma pack(push, 1)

typedef struct VectorXYZ {
	float x, y, z;
} VectorXYZ;

typedef struct SampKeys {
	uint8_t primaryFire : 1;
	uint8_t horn_crouch : 1;
	uint8_t secondaryFire_shoot : 1;
	uint8_t accel_zoomOut : 1;
	uint8_t enterExitCar : 1;
	uint8_t decel_jump : 1;
	uint8_t circleRight : 1;
	uint8_t aim : 1;
	uint8_t circleLeft : 1;
	uint8_t landingGear_lookback : 1;
	uint8_t unknown_walkSlow : 1;
	uint8_t specialCtrlUp : 1;
	uint8_t specialCtrlDown : 1;
	uint8_t specialCtrlLeft : 1;
	uint8_t specialCtrlRight : 1;
	uint8_t _unknown : 1;
} SampKeys;

typedef struct PlayerSyncData {
	uint16_t leftRightKeys;
	uint16_t upDownKeys;
	union {
		uint16_t keysData;
		SampKeys keys;
	};
	VectorXYZ position;
	float     quaternion[4];
	uint8_t   health;
	uint8_t   armor;
	uint8_t   weapon : 6;
	uint8_t   specialKey : 2;
	uint8_t   specialAction;
	VectorXYZ moveSpeed;
	VectorXYZ surfingOffsets;
	uint16_t  surfingVehicleId;
	union {
		struct {
			uint16_t id;
			uint8_t  frameDelta;
			union {
				struct {
					bool    loop : 1;
					bool    lockX : 1;
					bool    lockY : 1;
					bool    freeze : 1;
					uint8_t time : 2;
					uint8_t _unused : 1;
					bool    regular : 1;
				};
				uint8_t value;
			} flags;
		} animation;
		struct {
			uint16_t  animationId;
			uint16_t  animationFlags;
		};
	};
} PlayerSyncData;

typedef struct VehicleSyncData {
	uint16_t vehicleId;
	uint16_t leftRightKeys;
	uint16_t upDownKeys;
	union {
		uint16_t keysData;
		SampKeys keys;
	};
	float     quaternion[4];
	VectorXYZ position;
	VectorXYZ moveSpeed;
	float     vehicleHealth;
	uint8_t   playerHealth;
	uint8_t   armor;
	uint8_t   currentWeapon : 6;
	uint8_t   specialKey : 2;
	uint8_t   siren;
	uint8_t   landingGearState;
	uint16_t  trailerId;
	union {
		float    bikeLean;
		float    trainSpeed;
		uint16_t hydraThrustAngle[2];
	};
} VehicleSyncData;

typedef struct PassengerSyncData {
	uint16_t vehicleId;
	uint8_t  seatId : 6;
	bool     driveBy : 1;
	bool     cuffed : 1;
	uint8_t  currentWeapon : 6;
	uint8_t  specialKey : 2;
	uint8_t  health;
	uint8_t  armor;
	uint16_t leftRightKeys;
	uint16_t upDownKeys;
	union {
		uint16_t keysData;
		SampKeys keys;
	};
	VectorXYZ position;
} PassengerSyncData;

typedef struct UnoccupiedSyncData {
	uint16_t  vehicleId;
	uint8_t   seatId;
	VectorXYZ roll;
	VectorXYZ direction;
	VectorXYZ position;
	VectorXYZ moveSpeed;
	VectorXYZ turnSpeed;
	float     vehicleHealth;
} UnoccupiedSyncData;

typedef struct TrailerSyncData {
	uint16_t  trailerId;
	VectorXYZ position;
	union {
		struct {
			float quaternion[4];
			VectorXYZ moveSpeed;
			VectorXYZ turnSpeed;
		};
		/* Invalid. Retained for backwards compatibility. */
		struct {
			VectorXYZ roll;
			VectorXYZ direction;
			VectorXYZ speed;
			uint32_t  unk;
		};
	};
} TrailerSyncData;

typedef struct SpectatorSyncData {
	uint16_t leftRightKeys;
	uint16_t upDownKeys;
	union {
		uint16_t keysData;
		SampKeys keys;
	};
	VectorXYZ position;
} SpectatorSyncData;

typedef struct BulletSyncData {
	uint8_t   targetType;
	uint16_t  targetId;
	VectorXYZ origin;
	VectorXYZ target;
	VectorXYZ center;
	uint8_t   weaponId;
} BulletSyncData;

typedef struct AimSyncData {
	uint8_t   camMode;
	VectorXYZ camFront;
	VectorXYZ camPos;
	float     aimZ;
	uint8_t   camExtZoom : 6;
	uint8_t   weaponState : 2;
	uint8_t   aspectRatio;
} AimSyncData;

#pragma pack(pop)
]]

assert(ffi.sizeof('VectorXYZ') == 12)
assert(ffi.sizeof('SampKeys') == 2)
assert(ffi.sizeof('PlayerSyncData') == 68)
assert(ffi.sizeof('VehicleSyncData') == 63)
assert(ffi.sizeof('PassengerSyncData') == 24)
assert(ffi.sizeof('UnoccupiedSyncData') == 67)
assert(ffi.sizeof('TrailerSyncData') == 54)
assert(ffi.sizeof('SpectatorSyncData') == 18)
assert(ffi.sizeof('BulletSyncData') == 40)
assert(ffi.sizeof('AimSyncData') == 31)

return mod
 
 
local M = {} 
 
M.events = require 'samp.events' 
M.raknet = require 'samp.raknet' 
M.synchronization = require 'samp.synchronization' 
 
function M.isSampAvailable() 
    return true 
end 
 
function M.addChatMessage(text, color) 
    print('[SA-MP] ' .. string.gsub(text, '{......}', '')) 
    return true 
end 
 
function M.registerChatCommand(cmd, func) 
    _G['cmd_' .. cmd] = func 
    return true 
end 
 
return M 
