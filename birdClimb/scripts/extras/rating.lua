-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local common  = require "scripts.common"
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

-- Android
local packageID = "com.mycompany.gamename"

-- iOS
local appleID  = "123456789" 

-- ==
-- rate() - This function executes the correct (per-platform) rating code based on your
--            settings in common.lua
--
-- Note:  iOS requires this FREE plugin: https://marketplace.coronalabs.com/corona-plugins/review-popup
-- ==
public.rate = function( onSuccess )
   onSuccess = onSuccess or function() end
   --
   local os = helpers.os()
   --
   if( helpers.onSim() ) then
      easyAlert("Testing Twitter Feature", 
               "You supplied these IDs:\n\n" ..
               "    iOS - '" .. appleID .. "'\n" ..
               "Android - '" .. packageID .. "'\n\n" ..
               "Simulate 'Success' or 'Failure'?",
               { { "Success", onSuccess }, { "Failure", nil } } )
   
   elseif( os == "ios" ) then
      local platformVersion = system.getInfo( "platformVersion" ) or 0
      local iOSVersion = tonumber(string.sub( platformVersion, 1, 4 ))       
      if( iOSVersion >= 10.3 and system.getInfo("platform") == "ios" ) then       
         local reviewPopUp = require "plugin.reviewPopUp"
         reviewPopUp.show()
         onSuccess()
      else
         local  url = "itms-apps://itunes.apple.com/app/id" .. appleID .. "?onlyLatestVersion=false"
         system.openURL( url )
         onSuccess()
      end

   elseif( os == "android" ) then
      local url = "https://play.google.com/store/apps/details?id=" .. packageID
      system.openURL( url )
      onSuccess()

   else
      -- No idea what system this is.  May as well call onSuccess to hide button.
      -- User is never going to be able to rate from this device anyways, so pretend it was successful.
      onSuccess()
   end
end

return public
