-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- =============================================================
local composer       = require "composer"
local scene          = composer.newScene()
local common         = require "scripts.common"
local utils          = require "scripts.utils"
local shop           = require "scripts.extras.shop"

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
local onBack

----------------------------------------------------------------------
-- Locals
----------------------------------------------------------------------
local content
local lastFrom 

----------------------------------------------------------------------
-- Scene Methods
----------------------------------------------------------------------
function scene:create( event )
   local sceneGroup = self.view
end

function scene:willShow( event )
   local sceneGroup = self.view
   --
   lastFrom = event.params.from
   --
   content = display.newGroup()
   sceneGroup:insert(content)
  
   -- Draw background, title, etc.
   local back = newImageRect( content, centerX, centerY, 
                              "images/" .. common.theme .."/background.png",
                              { w = 720, h = 1386, rotation = (fullw>fullh) and 90 or 0,
                                fill = common.color1 } )

   local title  =  easyIFC:quickLabel( content, "Store", 
                                       centerX, top + 50 + common.titleOffsetY, 
                                       _G.fontB, 50 )

   local backButton = easyIFC:presetPush( content, "back", 
                                             left + common.cornerOffsetX + 50, 
                                             top + common.cornerOffsetY + 50, 
                                             80, 80, "", onBack )

   shop.create(content)

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
   display.remove(content)
   content = nil
end

function scene:destroy( event )
   local sceneGroup = self.view
end

----------------------------------------------------------------------
--          Custom Scene Functions/Methods
----------------------------------------------------------------------

-- Back button listener
onBack = function( event )
   local target = event.target   
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   if( lastFrom == "died" ) then
      local options = {
         isModal     = true,
         effect      = "crossFade",
         time        = 500,
         params      = { skipFlyIn = true },
      }
      composer.showOverlay( "scenes.died", options )   

   elseif( lastFrom == "play" ) then
      local game = require "scripts.game"
      game.recreate()
      composer.hideOverlay( "crossFade", 500 )   
   end
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
