-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local common = require "scripts.common"
local helpers = require "scripts.helpers"

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
-- Module Begins
-- =============================================================
local public = {}

-- iOS
local appleID  = "123456789" 

-- ==
-- showActivityDialog() - Share a message and/or image and/or url about this game.
--
-- Note: For iOS requires this FREE plugin: https://docs.coronalabs.com/plugin/Coronahelper_native_popup_activity/index.html
-- ==
public.showActivityDialog = function( onSuccess )
   onSuccess = onSuccess or function() end
   --
   local os = helpers.os()
   --
   if( helpers.onSim() ) then
      easyAlert("Testing Sharing Feature", 
               "Placeholder test of the 'sharing' via iOS Activity Popup feature.\n\n" ..
               "Test on iOS device(s) to validate real functionality.",
               { { "Success", onSuccess }, { "Failure", nil } } )

      return    
   end

   --
   -- See Corona docs for more details and options: 
   -- https://docs.coronalabs.com/plugin/CoronaProvider_native_popup_activity/index.html
   --
   local function listener( event )
      --print( "(name, type, activity, action):",  event.name, event.type, tostring(event.activity), tostring(event.action) )
      onSuccess()
   end

   local itemsToShare = {}   

   --
   -- Add a message
   --
   local bestScore = ssk.persist.get( "settings.json", "bestScore" )
   local message = "Playing " .. 
      " my best score so far is " .. tostring(bestScore) .. " " .. 
      ( (targetAndroid) and tostring(common.extras.twitter_android_url) or
                            tostring(common.extras.twitter_ios_url) )
   itemsToShare[#itemsToShare+1] ={ type = "string", value = message }

   --
   -- Add a link/URL
   --
   itemsToShare[#itemsToShare+1] = { type = "url", value = "itms-apps://itunes.apple.com/app/id" .. appleID .. "?onlyLatestVersion=false" }

   --
   -- Add an image
   --
   --itemsToShare[#itemsToShare+1] =  { type = "image", value = { filename = <path>, baseDir = system.DocumentsDirectory } }
   --itemsToShare[#itemsToShare+1] =  { type = "image", value = { filename = <path>, baseDir = system.ResourceDirectory } }

   -- https://docs.coronalabs.com/plugin/Coronahelper_native_popup_activity/showPopup.html
   local options = { items = itemsToShare, listener = listener }
   native.showPopup( "activity", options )
end

return public
