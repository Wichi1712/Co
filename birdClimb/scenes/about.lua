-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- =============================================================
local composer    = require "composer"
local scene       = composer.newScene()
local common      = require "scripts.common"
local utils       = require "scripts.utils"
local widget      = require "widget" 

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
local onRestore
local drawAboutContent

----------------------------------------------------------------------
-- Locals
----------------------------------------------------------------------
local content
local about = {
   { text = "This is a mechanics clone of the wonderful game 'Bird Climb' by BoomBit.\n" },
   { text = "Its purpose is to provide you with a starting point to improve and tweak." },
   { text = "Make this game your own, and take it to new heights (pun intended).\n" },
   { text = "Seriously though, make something new and exciting from this template.\n" },
   { image = "images/rg256.png", width = 128, height = 128 },
}
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
   display.remove(content)
   content = display.newGroup()
   sceneGroup:insert(content)
   --

   local overrides = { selImgFillColor = common.color2, unselImgFillColor = common.color1 }
   
   -- Draw background, title, etc.
   local back = newImageRect( content, centerX, centerY, 
                              "images/" .. common.theme .."/background.png",
                              { w = 720, h = 1386, rotation = (fullw>fullh) and 90 or 0 } )

   local title  =  easyIFC:quickLabel( content, "About", 
                                       centerX, top + 50 + common.titleOffsetY, 
                                       _G.fontB, 50, common.color1 )

   local backButton = easyIFC:presetPush( content, "back", 
                                             left + common.cornerOffsetX + 50, 
                                             top + common.cornerOffsetY + 50, 
                                             80, 80, "", onBack, overrides )

   -- Show restore button?
   local restoreB
   if( common.extras.iap_enabled and common.extras.ads_enabled and ssk.persist.get( "settings.json", "ads_enabled" ) ) then
      restoreB = easyIFC:presetPush( content, "basic_transparent", 
                                                centerX, bottom - 110, 100, 40, 
                                                "RESTORE", onRestore )
   end

   -- Draw about scroller contents
   --
   if( restoreB ) then
      drawAboutContent( content, title.y + 50, restoreB.y - 40 )   
   elseif( common.extras.iap_enabled and common.extras.ads_enabled  and ssk.persist.get( "settings.json", "ads_enabled" ) ) then
      drawAboutContent( content, title.y + 50, bottom - 80 )   
   else
      drawAboutContent( content, title.y + 50, bottom )   
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
   composer.hideOverlay( "crossFade", 500  )
end


-- Restore button listener
onRestore = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local function onSuccess(  )
      if( target ) then
         display.remove(target)
      end

      local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )

      -- Set persistent ads_enabled flag to false
      ssk.persist.set( "settings.json", "ads_enabled", false )

      -- Try to hide banner (just in case it is showing now)
      adsHelper.hideBanner()
     
      -- Disable the ads module and force it to clean up any 
      -- oustanding listeners.
      adsHelper.disableModule(true)
   end
   --
   local easyIAP = require "scripts.iap.easyIAP"
   easyIAP.restore( onSuccess )
end

-- Helper to draw contents of about table in a scroller.
--
-- Tip: Right now, it is not that sophisticated, but you can easily adjust the 
-- data format and make it more complex and enable more interesting layout rules.
drawAboutContent = function( group, yStart, yEnd )

   local scroller = widget.newScrollView(
      {
         x                 = left,
         y                 = yStart,
         width             = fullw,
         height            = yEnd - yStart,
         hideBackground    = true
      } )
   scroller.anchorX = 0
   scroller.anchorY = 0
   group:insert(scroller)

   local tmp = display.newLine( group, left, yStart, right, yStart )
   tmp.strokeWidth = 3
   tmp:setStrokeColor(unpack(common.textFill2))

   local tmp = display.newLine( group, left, yEnd, right, yEnd )
   tmp.strokeWidth = 3
   tmp:setStrokeColor(unpack(common.textFill2))

   local curY = 20
   local buffer = 30

   for i = 1, #about do
      local tmp = about[i]
      if( tmp.text ) then
         local options = 
         {
            text = tmp.text,
            x = 20,
            y = curY,
            width = fullw - 40,
            font = _G.fontN,
            fontSize = 32,
         } 
         local myText = display.newText( options )
         myText.anchorX = 0
         myText.anchorY = 0
         myText:setFillColor( unpack(common.color1) )
         scroller:insert( myText )

         curY = curY + myText.contentHeight + buffer

      elseif( tmp.image ) then
         local image
         if( tmp.width ) then
            image = display.newImageRect( tmp.image, tmp.width, tmp.height )
         else
            image = display.newImage( tmp.image,0,0 )
         end
         --
         image.xScale = 2
         image.yScale = 2
         --
         if( image.contentWidth > (fullw-40) ) then
            local scale = (fullw-40)/image.contentWidth
            image:scale( scale, scale )
         end
         --
         image.anchorY = 0
         --
         scroller:insert(image)
         --
         image.y = curY
         image.x = fullw/2
         --
         curY = curY + image.contentHeight + buffer
      end
   end

   -- buffer block
   local block = display.newRect( 0, 0, 40, 40 )
   scroller:insert( block )
   block.x = 100
   block.y = curY + 100
   block.isVisible = false

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
