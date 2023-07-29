-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- =============================================================
local composer    = require "composer"
local scene       = composer.newScene()
local common      = require "scripts.common"
local utils        = require "scripts.utils"

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
local onPlay

----------------------------------------------------------------------
-- Locals
----------------------------------------------------------------------
local allowClickToAdvance = true
local minWaitTime = 3000
local maxWaitTime = 5000
local startTime
local lastTimer

if( ssk.misc.countLocals ) then ssk.misc.countLocals(1) end

----------------------------------------------------------------------
-- Scene Methods
----------------------------------------------------------------------
function scene:create( event )
   local sceneGroup = self.view

   -- Beginning of 'wait'
   startTime = system.getTimer()

   -- Draw background, title, etc.
   local back = newImageRect( sceneGroup, centerX, centerY, 
                              "images/" .. common.theme .."/background.png",
                              { w = 720, h = 1386, rotation = (fullw>fullh) and 90 or 0 } )

   local title  =  easyIFC:quickLabel( sceneGroup, common.gameTitle, centerX, centerY - 75, _G.fontB, 50, common.textFill1 )
   local by     =  easyIFC:quickLabel( sceneGroup, "by", centerX, centerY, _G.fontN, 32, common.textFill2 )
   local author =  easyIFC:quickLabel( sceneGroup, "The Roaming Gamer", centerX, centerY + 50, _G.fontN, 32, common.textFill2 )
   
   -- Start timer to automatically change to play scene after 'maxWaitTime'
   lastTimer = timer.performWithDelay( maxWaitTime, onPlay )

   -- Optionally allow user to click screen after 'minWaitTime' to advance to play scene.
   if( allowClickToAdvance ) then
      -- Allow the player to touch the screen to go directly to the play scene
      function back.touch( self, event )  
         local dt = system.getTimer() - startTime
         if( dt < minWaitTime ) then return true end
         if( event.phase == "began" ) then
            timer.cancel( lastTimer )
            lastTimer = nil
            onPlay()
         end
      end
      back:addEventListener( "touch" )
   end   
end

function scene:willShow( event )
   local sceneGroup = self.view
end

function scene:didShow( event )
   local sceneGroup = self.view
end

function scene:willHide( event )
   local sceneGroup = self.view
end

function scene:didHide( event )
   local sceneGroup = self.view
end

function scene:destroy( event )
   local sceneGroup = self.view
end

----------------------------------------------------------------------
--          Custom Scene Functions/Methods
----------------------------------------------------------------------
onPlay = function( event )
   -- If the GDPR dialog is showing, don't leave yet.
   -- Wait till the user closes the dialog
   if( common.gdpr_dialog_is_showing ) then 
      lastTimer = timer.performWithDelay( 500, onPlay )
      return true 
   end
   local params = { }
   composer.gotoScene( "scenes.play", { time = 500, effect = "crossFade", params = params } )
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
