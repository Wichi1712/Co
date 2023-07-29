-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- =============================================================
local composer    = require "composer"
local scene       = composer.newScene()
local common      = require "scripts.common"
local utils       = require "scripts.utils"
local game        = require "scripts.game"

-- =============================================================
-- Localizations
-- =============================================================
-- Commonly used Lua & Corona Functions
local getTimer = system.getTimer; local mRand = math.random
local mAbs = math.abs; local mFloor = math.floor; local mCeil = math.ceil
local strGSub = string.gsub; local strSub = string.sub
-- Common SSK Features
local newCircle = ssk.display.newCircle;local newRect = ssk.display.newRect
local newImageRect = ssk.display.newImageRect;local newSprite = ssk.display.newSprite
local quickLayers = ssk.display.quickLayers
local easyIFC = ssk.easyIFC;local persist = ssk.persist
local isValid = display.isValid;local isInBounds = ssk.easyIFC.isInBounds
local normRot = math.normRot;local easyAlert = ssk.misc.easyAlert
-- SSK 2D Math Library
local addVec = ssk.math2d.add;local subVec = ssk.math2d.sub;local diffVec = ssk.math2d.diff
local lenVec = ssk.math2d.length;local len2Vec = ssk.math2d.length2;
local normVec = ssk.math2d.normalize;local vector2Angle = ssk.math2d.vector2Angle
local angle2Vector = ssk.math2d.angle2Vector;local scaleVec = ssk.math2d.scale
local RGTiled = ssk.tiled; local files = ssk.files
local factoryMgr = ssk.factoryMgr; local soundMgr = ssk.soundMgr
-- =============================================================

----------------------------------------------------------------------
-- Forward Declarations
----------------------------------------------------------------------
local onResume
local onHome
local onSound

----------------------------------------------------------------------
-- Locals
----------------------------------------------------------------------
local layers
local title
local resumeButton
local menuButton
local soundButton
--if( ssk.misc.countLocals ) then ssk.misc.countLocals(1) end

----------------------------------------------------------------------
-- Scene Methods
----------------------------------------------------------------------
function scene:create( event )
   local sceneGroup = self.view
end

function scene:willShow( event )
   local sceneGroup = self.view
   --
   layers = ssk.display.quickLayers( sceneGroup, 
      "underlay", 
      "content",
      "overlay" )
   --
   local overrides = { selImgFillColor = common.color2, unselImgFillColor = common.color1, labelColor = _W_  }
   --
   title  =  easyIFC:quickLabel( layers.overlay, "pause", centerX, centerY - 105, _G.fontN, 50, common.color1 )
   --
   resumeButton = easyIFC:presetPush( layers.overlay, "basic", 
                                             centerX, centerY,
                                             300, 80, 
                                             "resume", onResume, overrides )

   menuButton = easyIFC:presetPush( layers.overlay, "basic", 
                                             centerX, centerY + 100,
                                             300, 80, 
                                             "menu", onHome, overrides )

   soundButton = easyIFC:presetToggle( layers.overlay, "sound", 
                                             centerX + 100, centerY + 200,
                                             80, 80, "", onSound  )
   soundButton:setUnselColor( common.color1 )
   soundButton:setSelColor( common.color1 )  


   if( persist.get( "settings.json", "sound_enabled" ) ) then
      soundButton:toggle(true)
   end

   ssk.easyIFC.easyFlyIn( title, { sox = 0, soy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyIn( resumeButton, { sox = 0, soy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyIn( menuButton, { sox = 0, soy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyIn( soundButton, { sox = 0, soy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
end

function scene:didShow( event )
   local sceneGroup = self.view
end

function scene:willHide( event )
   local sceneGroup = self.view
end

function scene:didHide( event )
   local sceneGroup = self.view
   --
   display.remove(layers)   
   layers = nil
   title = nil
   resumeButton = nil
   menuButton = nil
   soundButton = nil
end

function scene:destroy( event )
   local sceneGroup = self.view
end

----------------------------------------------------------------------
--          Custom Scene Functions/Methods
----------------------------------------------------------------------
onResume = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local function onComplete()
      composer.hideOverlay()
      game.pause(false)
   end
   --
   ssk.easyIFC.easyFlyOut( title, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( resumeButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( menuButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( soundButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad, 
                                         onComplete = onComplete })
end   

onHome = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --local params = {}
   --composer.gotoScene( "scenes.home", { time = 500, effect = "crossFade", params = params } )
   composer.hideOverlay( "crossFade", 500 )
   timer.performWithDelay( 500,
      function()
         game.recreate()
      end )

end
   
onSound = function( event )
   if( event.phase == "moved" ) then return false end
   local target = event.target
   persist.set( "settings.json", "sound_enabled", target:pressed() )
   soundMgr.enableSFX( persist.get( "settings.json", "sound_enabled" ) )
   post("onSound", { sound = "click" } )
end


---------------------------------------------------------------------------------
-- Custom Dispatch Parser -- DO NOT EDIT THIS
---------------------------------------------------------------------------------
function scene.commonHandler( event )
   local willDid  = event.phase
   local name     = willDid and willDid .. event.name:gsub("^%l", string.upper) or event.name
   if( scene[name] ) then scene[name](scene,event) end
end
scene:addEventListener( "create",   scene.commonHandler )
scene:addEventListener( "show",     scene.commonHandler )
scene:addEventListener( "hide",     scene.commonHandler )
scene:addEventListener( "destroy",  scene.commonHandler )
return scene
