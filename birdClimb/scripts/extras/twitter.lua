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

-- To use this feature, you must set up a Twitter App and get the API KEY & SECRET.
-- http://www.jasonschroeder.com/2015/07/15/twitter-plugin-for-corona-sdk/
local apiKey      = "API_KEY"
local apiSecret   = "API_SECRET"
local hashtag     = "#hashtag"
local androidURL  = "https://play.google.com/store/apps/details?id=<package ID goes here>"
local iosURL      = "https://itunes.apple.com/us/app/sudoku-for/id<Apple ID goes here>?mt=8"

-- ==
-- sendTweet() - Send a tweet about this game.
--
-- Note: Requires this PAID plugin: 
-- > https://marketplace.coronalabs.com/corona-plugins/twitter
-- > http://www.jasonschroeder.com/2015/07/15/twitter-plugin-for-corona-sdk/
-- ==
public.sendTweet = function( onSuccess )
   local twitter = require("plugin.twitter")

   -- Initialize twitter keys
   --print(apiKey, apiSecret)
   twitter.init(apiKey, apiSecret)
   twitter.init = function() end

   --
   -- Tweet Listener
   --
   local function tweetCallback(response)
      --table.print_r( response )      
      --print("TWEET TEXT: " .. response.text)
      --print("TWEET ID: " .. response.id)      
      if( onSuccess ) then
         onSuccess()
      end
   end

   --
   -- Let's create a message based on how well the user is doing, what OS they are on
   --
   local message = "Playing " .. tostring(hashtag) ..
      " my best score so far is " .. 
      tostring(ssk.persist.get( "settings.json", "bestScore" )) .. " " .. 
      ( (helpers.os() == "android") and androidURL or iosURL )

   --print(message)      

   -- Warning: Thoroughly test and be sure your twitter message meets the current
   -- maximum length requirements!
   --[[
   if( true ) then 
      print(string.len(message))
      print(message)
      return
   end
   --]] 

   -- See the twitter plugin docs for more options: 
   -- http://www.jasonschroeder.com/2015/07/15/twitter-plugin-for-corona-sdk/#tweet
   --local path = system.pathForFile( <image path>, <baseDir> )
   --twitter.tweet( message, path, tweetCallback )
   
   twitter.tweet( message, tweetCallback )
end

return public
