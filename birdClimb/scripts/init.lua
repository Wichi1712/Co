-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local common  = require "scripts.common"
local utils   = require "scripts.utils"
-- =============================================================

--
-- Load Button Presets
--
require ("presets." .. common.theme ..".presets")
 
 --
 -- Create a special presets needed just for this game template
 --
local params = 
{ 
  unselImgSrc  = "images/" .. common.theme .. "/plus.png",
  selImgSrc    = "images/" .. common.theme .. "/plus.png",
  touchOffset  = { 2, 2 },
}
ssk.easyIFC:addButtonPreset( "plus", params )

local params = 
{ 
  unselImgSrc  = "images/fillT.png",
  selImgSrc    = "images/fillT.png",
  touchOffset  = { 2, 2 },
}
ssk.easyIFC:addButtonPreset( "basic_transparent", params )


--
-- Set Persistent Settings' Defaults
--
ssk.persist.setDefault( "settings.json", "sound_enabled", true )
ssk.persist.setDefault( "settings.json", "bestScore", 0 )
ssk.persist.setDefault( "settings.json", "gamesPlayed", 0 )
ssk.persist.setDefault( "settings.json", "coins", 0 )
ssk.persist.setDefault( "settings.json", "currentBird", 1 )
--
ssk.persist.setDefault( "settings.json", "ads_enabled", common.extras.ads_enabled )
ssk.persist.setDefault( "settings.json", "request_gdpr_consent", common.extras.ads_request_gdpr_permission  )
ssk.persist.setDefault( "settings.json", "has_gdpr_consent", false )
ssk.persist.setDefault( "settings.json", "rated", false )


--
-- Configure Sound
--
ssk.soundMgr.setDebugLevel( 0 )
ssk.soundMgr.setVolume( 0.25, "effect" )
ssk.soundMgr.addEffect( "click", "sounds/sfx/click.wav")
ssk.soundMgr.addEffect( "flap", "sounds/sfx/flap.wav")
ssk.soundMgr.addEffect( "coin", "sounds/sfx/coin.wav")
ssk.soundMgr.addEffect( "gameOver", "sounds/sfx/gameOver.wav")
ssk.soundMgr.enableSFX( ssk.persist.get( "settings.json", "sound_enabled" ) )


--
-- Configure Ads
--
local function configureAds( enabled ) 
   local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )
   adsHelper.prepare( common.extras.ads_enabled and ssk.persist.get( "settings.json", "ads_enabled" ) )
end


--
-- GDPR - Handle various GDPR cases...
--

-- Ads have been disabled, so just initialize the helper as it won't matter anyways
if( ssk.persist.get( "settings.json", "ads_enabled" ) == false ) then
   configureAds()

-- Alread has consent, so initialize.
elseif( ssk.persist.get( "settings.json", "has_gdpr_consent" ) == true ) then
   configureAds()

-- Doesn't have permission yet, but you want to ask
elseif( ssk.persist.get( "settings.json", "request_gdpr_consent" ) == true ) then
   local helpers = require "scripts.helpers"

   -- Make the splash screen wait if while the user reads the dialog.
   common.gdpr_dialog_is_showing = true

   --
   local providerName = (common.extras.ads_provider == "applovin") and "AppLovin" or "Appodeal"
   --
   local function onYes()
      ssk.persist.set( "settings.json", "has_gdpr_consent", true ) 
      configureAds()
      common.gdpr_dialog_is_showing = false
   end
   local function onNo()
      ssk.persist.set( "settings.json", "has_gdpr_consent", false ) 
      configureAds()
      common.gdpr_dialog_is_showing = false
   end
   local function onDoNotAskAgain()
      ssk.persist.set( "settings.json", "has_gdpr_consent", false ) 
      ssk.persist.set( "settings.json", "request_gdpr_consent", false ) 
      configureAds()
      common.gdpr_dialog_is_showing = false
   end
   
   --   
   -- Tip: You should carefully review this statement and if you have a lawyer available to you,
   -- I strongly suggest you get a second opinion on the verbiage below.
   --
   helpers.easyAlert( "Personalized Ad Experience",
                      providerName .. " personalizes your advertising experience.\n\n" .. 
                      providerName .. " and its partners may collect and process personal data such as " ..
                      "device identifiers, location data, and other demographic and interest data to provide an advertising " ..
                      "experience tailored to you.\n\n" ..
                      "By agreeing to this, you are confirming you are over the age of 16 and that you would like a personalized experience.", 
                      {
                        {"Don't Ask Again", onDoNotAskAgain },
                        {"I Do Not Consent", onNo },
                        {"I Consent", onYes },
                     } )

-- You don't have permission and you don't want to ask, or the user
-- said do not ask me again...
else
   configureAds()
end


--
-- Configure In-App-Purchases
-- 
--
if( common.extras.iap_enabled ) then
   local easyIAP = require "scripts.iap.easyIAP"
   easyIAP.prepare()
end

