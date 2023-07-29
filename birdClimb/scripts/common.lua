-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local common = {}

-- =============================================================
-- Game Title
-- =============================================================
common.gameTitle = "Bird Climber"

-- =============================================================
-- Select an art theme for the game.
-- =============================================================
common.theme = "clone" -- casual clone flat medieval prototype kenney

-- ==
-- Color Codes
-- ==
--common.yellow					= hexcolor("#ffcc00")
common.green					= hexcolor("#4bcc5a")
common.pink						= hexcolor("#d272b4")
common.red						= hexcolor("#ff452d")
common.blue 					= hexcolor("#009eea")
common.colors 					= { common.green, common.pink, common.red, common.blue }

common.blue2 					= hexcolor("#009eea80")
common.gold 					= hexcolor("#FFDF00")

common.color2Alpha			= 204/255

if( common.theme == "clone" ) then
	common.textFill1 = hexcolor("#009eea")
	common.textFill2 = hexcolor("#009eea")
else
	common.textFill1 = hexcolor("#000000")
	common.textFill2 = hexcolor("#000000")
end

-- On an iPhoneX or another device with a notch at the top? Adjust for that.
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
common.titleOffsetY 	= topInset or 0
common.cornerOffsetX = leftInset --_G.oniPhoneX and 20 or 0
common.cornerOffsetY = topInset -- _G.oniPhoneX and 20 or 0

-- ==
-- Game Settings
-- ==
common.gravityX					= 0
common.gravityY					= 35
common.birdKickMag 				= 25
common.birdSpeed 					= 300
common.allColoredObj 			= {}
common.colorChangeFreq 			= 5

common.worldLeft 					= 0
common.worldRight 				= display.contentWidth
common.pickupSideInset			= 125
common.resumeCoinCost			= 30
common.rewardedAdEarnsCoins	= 20

common.levelHeight			= fullh * 1.5

-- When the game is resumed after a monster collision,
-- we delete nearby monsters.  This controls the delete distance.
common.monsterDestroyDistance = 200


-- =============================================================
-- Extras Settings 
-- =============================================================
local extras = {}
common.extras = extras

--
-- Achievements & Leaderboards
--
common.extras.achievements_enabled 					= false 
common.extras.leaderboard_enabled 					= false

--
-- Ads
--
common.extras.ads_enabled 								= false
common.extras.ads_show_interstitials				= false
-- 
common.extras.ads_provider 							= "applovin" -- applovin or appodeal
common.extras.ads_interstitial_frequency			= 5
common.extras.ads_request_gdpr_permission			= false

--
-- Facebook
--
common.extras.facebook_enabled 						= false 

--
-- IAP
--
common.extras.iap_enabled 								= false
-- 
common.extras.iap_test_mode							= true

-- This will not affect the shop.  Please delete the contents
-- of the sandbox to clear your purchases.
-- You should always leave this as 'false'
common.extras.iap_do_not_load_inventory			= false

--
-- Rating
--
common.extras.rating_enabled 							= false 

--
-- Sharing
--
common.extras.sharing_enabled 						= false 

--
-- Shop ('iap_enabled' must be 'true' to use this feature.)
--
common.extras.shop_enabled 							= false 

--
-- Twitter 
--
common.extras.twitter_enabled 						= false 

return common
