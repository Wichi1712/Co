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

-- ==
-- post() - This is a placeholder for users who want to enable facebook sharing in their games.
--
-- Warning: Setting up facebook is not difficult, but it does require that you set up a 'Facebook App' for 
-- the game to act as a 'Single-Sign-On' (SSO) helper.
--
-- Please follow the directions on this page: https://docs.coronalabs.com/plugin/facebook-v4a
-- ==
public.post = function( onSuccess )
   onSuccess = onSuccess or function() end
   --
   if( helpers.onSim() ) then
      easyAlert("Testing Facebook Feature", 
               "This is an advanced feature and assumes you have created a facebook app for your game.\n\n" ..
               "Please read the official Corona Docs for more the facebook plugin and its usage.",
               { 
                  { "Docs", 
                  function() 
                     system.openURL("https://docs.coronalabs.com/plugin/facebook-v4a") 
                     onSuccess()
                     end }, 
                  { "Close", onSuccess } 
               } )
      return    

   else
      --https://docs.coronalabs.com/plugin/facebook-v4a/
      local facebook = require( "plugin.facebook.v4a" )

      --https://docs.coronalabs.com/plugin/facebook-v4a/init.html
      local function shareLink( url )
         local accessToken = facebook.getCurrentAccessToken()
         if accessToken == nil then
            facebook.login()
         elseif not valueInTable( accessToken.grantedPermissions, "publish_actions" ) then
            facebook.login( { "publish_actions" } )
         else
            facebook.showDialog( "link", { link=url } )
         end
      end

      local function facebookListener( event )
         if ( "fbinit" == event.name ) then
            print( "Facebook initialized" )
            -- Initialization complete; share a link
            shareLink( "https://www.coronalabs.com/" )
         elseif ( "fbconnect" == event.name ) then

            if ( "session" == event.type ) then
               -- Handle login event and try to share the link again if needed
            elseif ( "dialog" == event.type ) then
               -- Handle dialog event
            end
         end
      end

      -- Set the "fbinit" listener to be triggered when initialization is complete
      facebook.init( facebookListener )      
   end
end
return public
