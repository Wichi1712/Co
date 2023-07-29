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
local onRestart
local onResume
local onWatchVideoToResume
local onShop

----------------------------------------------------------------------
-- Locals
----------------------------------------------------------------------
local layers
local msg1
local msg2
local restartButton
local resumeButton
local watchVideoButton
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
   local overrides = { selImgFillColor = common.color2, 
                       unselImgFillColor = common.color1, 
                       labelColor = _W_, labelOffset = { -40, 0 }  }

   local coinIcon = newImageRect( layers.overlay, 
                                w - 80 - common.cornerOffsetX, 
                                top + common.cornerOffsetY + 50, 
                                "images/" .. common.theme .. "/coin.png",
                                { w = 50, h = 50, isGem = true, fill = common.gold } )
   --
   local coinBuyButton = easyIFC:presetPush( layers.overlay, "plus", coinIcon.x + 50, coinIcon.y, 50, 50, "", onShop )
   coinBuyButton:setSelColor( common.color2 )
   coinBuyButton:setUnselColor( common.color1 )
   coinBuyButton.alpha = 0
   transition.to( coinBuyButton, { alpha = 1, delay = 800, time = 0 } )
   --
   local coinCountLabel = easyIFC:quickLabel( layers.overlay, "0", coinIcon.x - 30, coinIcon.y - 8, _G.fontN, 40, common.color1, 1 )
   --
   function coinCountLabel.onUpdateCoins(self)
      coinCountLabel.text = ssk.persist.get( "settings.json", "coins" )
   end; listen( "onUpdateCoins", coinCountLabel )
   coinCountLabel:onUpdateCoins()
   --
   function coinCountLabel.finalize( self )
      ignoreList( { "onUpdateCoins" }, self )
   end; coinCountLabel:addEventListener("finalize")

   --
   msg1  =  easyIFC:quickLabel( layers.overlay, "Continue from here?", centerX, centerY - 355, _G.fontN, 60, common.color1 )
   msg2  =  easyIFC:quickLabel( layers.overlay, "Floor reached: " .. common.level-1, centerX, centerY - 255, _G.fontN, 50, common.color1 )
   --

   --
   restartButton = easyIFC:presetPush( layers.overlay, "basic", 
                                             centerX, centerY - 100,
                                             250, 60, 
                                             "Restart", onRestart, overrides )
   newImageRect( restartButton, 45, 0, "images/" .. common.theme .. "/restart.png", { size = 50 } )


   resumeButton = easyIFC:presetPush( layers.overlay, "basic", 
                                             centerX, centerY,
                                             300, 80, 
                                             "Use " .. tostring(common.resumeCoinCost), onResume, overrides )
   newImageRect( resumeButton, 45, 0, "images/" .. common.theme .. "/coin.png", { size = 54,fill = _W_ } )
   newImageRect( resumeButton, 45, 0, "images/" .. common.theme .. "/coin.png", { size = 50, fill = common.gold } )

   --
   function resumeButton.onUpdateCoins(self)
      if( ssk.persist.get( "settings.json", "coins" ) >= common.resumeCoinCost ) then
         self:enable()
      else
         self:disable(0.5)
      end
   end; listen( "onUpdateCoins", resumeButton )
   resumeButton:onUpdateCoins()
   --
   function resumeButton.finalize( self )
      ignoreList( { "onUpdateCoins" }, self )
   end; 

   watchVideoButton = easyIFC:presetPush( layers.overlay, "basic", 
                                             centerX, centerY + 100,
                                             300, 80, 
                                             "Watch", onWatchVideoToResume, overrides )
   newImageRect( watchVideoButton, 45, 0, "images/" .. common.theme .. "/movie.png", { size = 50 } )

   if( common.extras.iap_enabled ) then
      local easyIAP     = require "scripts.iap.easyIAP"
      if( easyIAP.owns_noads() or easyIAP.owns_unlockall() ) then
         watchVideoButton:disable( 0.5 )
      end
   end

   if( not common.extras.ads_enabled or not persist.get( "settings.json", "ads_enabled") ) then
      watchVideoButton:disable( 0.5 )
   end


   if( event.params and event.params.skipFlyIn == true )  then
      -- Skip fly in
   else
      ssk.easyIFC.easyFlyIn( msg1, { sox = 0, soy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyIn( msg2, { sox = 0, soy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyIn( restartButton, { sox = 0, soy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyIn( resumeButton, { sox = 0, soy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyIn( watchVideoButton, { sox = 0, soy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   end
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
   msg1 = nil
   msg2 = nil
   restartButton = nil
   resumeButton = nil
   watchVideoButton = nil
end

function scene:destroy( event )
   local sceneGroup = self.view
end

----------------------------------------------------------------------
--          Custom Scene Functions/Methods
----------------------------------------------------------------------

onRestart = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local function onComplete()
      composer.hideOverlay()
      game.recreate()
   end
   --
   ssk.easyIFC.easyFlyOut( msg1, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( msg2, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( restartButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( resumeButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( watchVideoButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad,
                           onComplete = onComplete })
end  

onResume = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   persist.set( "settings.json", "coins", persist.get( "settings.json", "coins" ) - common.resumeCoinCost )
   post( "onUpdateCoins" )
   --
   local function onComplete()
      composer.hideOverlay()
      game.continue(false)
   end
   --
   ssk.easyIFC.easyFlyOut( msg1, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( msg2, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( restartButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( resumeButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
   ssk.easyIFC.easyFlyOut( watchVideoButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad,
                           onComplete = onComplete })
end   

onWatchVideoToResume = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --local params = {}
   --composer.gotoScene( "scenes.home", { time = 500, effect = "crossFade", params = params } )
   
   local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )

   local function onSuccess()
      local function onComplete()
         composer.hideOverlay()
         game.continue(false)
      end
      --
      ssk.easyIFC.easyFlyOut( msg1, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyOut( msg2, { eox = 0, eoy = -fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyOut( restartButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyOut( resumeButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad })
      ssk.easyIFC.easyFlyOut( watchVideoButton, { eox = 0, eoy = fullh, delay = 100, time = 800, myEasing = easing.outQuad,
                              onComplete = onComplete })
   end

   adsHelper.showRewarded( onSuccess )
end

-- Shop Button Listener
onShop = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local options = {
      isModal     = true,
      effect      = "crossFade",
      time        = 500,
      params      = { from = "died" },
   }
   composer.showOverlay( "scenes.shop", options )
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
