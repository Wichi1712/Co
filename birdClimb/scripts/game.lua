-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- game.lua - Game Module
-- =============================================================
local common 		= require "scripts.common"
local physics     = require "physics"
local roomM       = require "scripts.room"
local playerM     = require "scripts.player"
local composer    = require "composer"
local utils       = require "scripts.utils"

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
--if( ssk.misc.countLocals ) then ssk.misc.countLocals(1) end

-- =============================================================
-- Forward Declarations
-- =============================================================
local colorSet
local onSound
local onShare
local onFacebook
local onTwitter
local onRate
local onNoAds
local onPlay
local onAbout
local onAchievements
local onLeaderboard
local onShop

-- =============================================================
-- Locals
-- =============================================================
local origCreateParams
local origStartParams
local gemBag =  ssk.shuffleBag.new( 0, 0, 1, 1, 1, 1, 2, 2 )
gemBag:shuffle()
--
local diedCount = 0 
--
local pauseBlocker
local aboutButton
local pauseButton
local coinIcon
local coinCountLabel
local coinBuyButton
local playButton
local buttons = {}

-- =============================================================
-- Module Begins
-- =============================================================
local game = {}

-- ==
--    init() - One-time initialization of game module.
-- ==
function game.init()
   physics.start()
   physics.setGravity( common.gravityX, common.gravityY )
   --physics.setDrawMode("hybrid")
   common.gameInitialized = true
   common.gameCreated     = false
   common.gameIsRunning   = false
   common.gameIsPaused    = false
   --
   common.level = 0
   common.highestLevelToday = 0
end

-- ==
--    create()
-- ==
function game.create( group, params )
   if( common.gameInitialized == false ) then return end
   group = group or display.currentStage
	params = params or {}
   --
   game.destroy() 
   origCreateParams = params
   --
   local layers = ssk.display.quickLayers( group, 
      "underlay", 
      "world", 
         { "background", "particles", "content", "pickups", "monsters", "menu" },
      "overlay",
      "blocker" )
   common.layers = layers

   layers.world.xScale = 1.25
   layers.world.yScale = 1.25
   layers.world.x = -(fullw/8)
   layers.world.y = -(fullh/8)

   -- This is a less zoomed in version.
   -- I like the above zoom better though.
   --[[
   layers.world.xScale = 1.125
   layers.world.yScale = 1.125
   layers.world.x = -(fullw/18)
   layers.world.y = -(fullh/10)
   --]]

   -- ==
   -- Add a pause button
   -- ==
   local function onPause( event )
      local target = event.target
      post("onSound", { sound = "click" } )
      game.pause( true )
      -- 
      local options = {
         isModal =       true,
         effect      = "crossFade",
         time        = 0
      }
      composer.showOverlay( "scenes.pause", options )   
   end

   pauseButton = easyIFC:presetPush( layers.overlay, "pause", 
                                             0 + common.cornerOffsetX + 50, 
                                             top + common.cornerOffsetY + 50, 
                                             80, 80, "", onPause )
   pauseButton.isVisible = false

   -- ==
   -- Add coins icon
   -- == -- 
   coinIcon = newImageRect( layers.overlay, 
                                w - 80 - common.cornerOffsetX, 
                                top + common.cornerOffsetY + 50, 
                                "images/" .. common.theme .. "/coin.png",
                                { w = 50, h = 50, isGem = true, fill = common.gold },
                                { bodyType = "static", isSensor = true, radius = 22 } )
   --
   if( common.extras.shop_enabled ) then   
      coinBuyButton = easyIFC:presetPush( layers.overlay, "plus", coinIcon.x + 50, coinIcon.y, 50, 50, "", onShop )
   end
   --
   coinCountLabel = easyIFC:quickLabel( layers.overlay, "0", coinIcon.x - 30, coinIcon.y, _G.fontN, 40, _W_, 1 )
   --
   function coinCountLabel.onUpdateCoins(self)
      coinCountLabel.text = ssk.persist.get( "settings.json", "coins" )
   end; listen( "onUpdateCoins", coinCountLabel )
   coinCountLabel:onUpdateCoins()
   --
   function coinCountLabel.finalize( self )
      ignoreList( { "onUpdateCoins" }, self )
   end; coinCountLabel:addEventListener("finalize")

   -- ==
   -- Create easy input helper.
   -- ==
   ssk.easyInputs.oneTouch.create( layers.underlay, { debugEn = false, keyboardEn = false } )

   -- ==
   -- Create player.
   -- ==
   playerM.create()

   -- ==
   -- Create walls and first set of monsters.
   -- ==   
   roomM.setColorSet( colorSet ) -- Passes colorSet function to room module for use from there.
   roomM.drawWallsAndFloor()
   roomM.drawMonsters( 0 )

   -- ==
   -- Use 'enterFrame' listener to generate more monsters when needed.
   -- ==
   function layers.enterFrame( self )
      -- ==
      -- Request monsters generation if we need to.
      -- ==
      if( (common.player.highY - common.levelHeight) < common.player.genY ) then
         -- 1 in 2 chance of drawing a pickup
         roomM.drawMonsters( gemBag:get() )
      end
   end; listen( "enterFrame", layers )

   -- ==
   -- 'onDied' event listener use to handle bird 'death' event.
   -- ==
   function layers.onDied()
      game.stop()            
      -- 
      local options = {
         isModal =       true,
         effect      = "crossFade",
         time        = 0
      }
      composer.showOverlay( "scenes.died", options )   

   end; listen( "onDied", layers )


   -- ==
   -- Clean up when we destroy the layers super-group.
   -- ==
   function layers.finalize( self )
      ignoreList( { "enterFrame", "onDied" }, self )
   end; layers:addEventListener( "finalize" )

   --
   -- Create remainder of buttons here (some enabled in common.lua) 
   --  
   buttons = {} 

   local overrides = { selImgFillColor = common.color2, unselImgFillColor = common.color1 }

   aboutButton = easyIFC:presetPush( layers.overlay, "about", 
                                           0 + common.cornerOffsetX + 50, 
                                          top + common.cornerOffsetY + 50, 
                                           100, 100, "", onAbout, overrides )

   playButton = easyIFC:presetPush( layers.menu, "play", centerX, centerY + 100, 100, 100, "", onPlay, overrides )


   -- Bar to put buttons on
   local bar = newRect( layers.menu, centerX, bottom - fullh/5, { w = fullw, h = 60, fill = common.color1 })

   
   -- Draw buttons we need (may change over time)
   buttons = {}   

  
   local soundButton = easyIFC:presetToggle( layers.menu, "sound", centerX, bar.y, 50, 50, "", onSound )
   buttons[#buttons+1] = soundButton

   if( common.extras.rating_enabled and persist.get( "settings.json", "rated") == false ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "rate", centerX, bar.y, 50, 50, "", onRate )
   end

   if( targetiOS and common.extras.sharing_enabled ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "share", centerX, bar.y, 50, 50, "", onShare )
   end

   if( common.extras.facebook_enabled ) then   
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "facebook", centerX, bar.y, 50, 50, "", onFacebook )
   end

   if( common.extras.twitter_enabled ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "twitter", centerX, bar.y, 50, 50, "", onTwitter )
   end
   
   -- Show 'no ads' option if user did not buy it already.
   if( common.extras.iap_enabled and common.extras.ads_enabled and ssk.persist.get( "settings.json", "ads_enabled" ) ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "noads", centerX, bar.y, 50, 50, "", onNoAds )
   end

   -- NOT USED IN THIS GAME
   if( common.extras.achievements_enabled ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "achievements", centerX, bar.y, 50, 50, "", onAchievements )
   end

   if( common.extras.leaderboard_enabled ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "leaderboard", centerX, bar.y, 50, 50, "", onLeaderboard )   
   end

   if( common.extras.shop_enabled ) then
      buttons[#buttons+1] = easyIFC:presetPush( layers.menu, "shop", centerX, bar.y, 50, 50, "", onShop )
   end

   utils.positionButtons( buttons, { widthOffset = -math.floor(w/4) }  )


   if( persist.get( "settings.json", "sound_enabled" ) ) then
      soundButton:toggle(true)
   end

   -- Show scores and plays 
   easyIFC:quickLabel( layers.menu, "Today's High: " .. common.highestLevelToday, centerX, centerY - 250, _G.fontN, 30, common.color1 )
   easyIFC:quickLabel( layers.menu, "Games Played: " .. ssk.persist.get( "settings.json", "gamesPlayed" ), centerX, centerY - 210, _G.fontN, 30, common.color1 )
   easyIFC:quickLabel( layers.menu, "Highscore: " .. ssk.persist.get( "settings.json", "bestScore" ), centerX, centerY - 170, _G.fontN, 30, common.color1 )

   --
   -- Mark game as created 
   --
   common.gameCreated    = true  
end

-- ==
--    destroy() - Remove all game content and reset game state.
-- ==
function game.destroy()
   common.gameCreated      = false
   common.gameIsRunning    = false
   common.gameIsPaused     = false
   --
   display.remove( common.layers )
   common.layers = nil
   --
   origCreateParams = nil
   origStartParams = nil
   --
   common.allColoredObj = {}
   common.level = 0
   --
   pauseBlocker = nil
   aboutButton = nil
   pauseButton = nil
   coinIcon = nil
   coinBuyButton = nil
   coinCountLabel = nil
   playButton = nil
   buttons = {}
   -- 
   common.monsters = {}
end

-- ==
--    start()
-- ==
function game.start( params )
   if( common.gameCreated == false ) then return end
   params = params or { }
   origStartParams = params
   --
   physics.start()
   --
   common.gameIsRunning = true
   common.gameIsPaused  = false
   --
   common.player:startMoving()

   -- Increment 'games played' count
   ssk.persist.set( "settings.json", "gamesPlayed", ssk.persist.get( "settings.json", "gamesPlayed" ) + 1 )
end

-- ==
--    stop()
-- ==
function game.stop()
   if( common.gameIsRunning == false ) then return end
   game.pause(true)
   common.gameIsRunning = false
end


-- ==
--    restart()
-- ==
function game.restart( )
   if( common.gameCreated == false ) then return end
   local tmp = origStartParams
   game.create( common.layers.parent, origCreateParams )
   game.start( tmp )
end

-- ==
--    recreate()
-- ==
function game.recreate( )
   if( common.gameCreated == false ) then return end
   local tmp = origStartParams
   game.create( common.layers.parent, origCreateParams )

   --   
   if( ssk.persist.get( "settings.json", "ads_enabled" ) == true ) then
      local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )
      
      -- 
      -- If the 'high score' summary was requested, it means we just died,
      -- so update died count.
      diedCount = diedCount + 1
      -- Now, check to see if we should show a banner or an interstitial ad
      --   
      if( common.extras.ads_show_interstitials and ( diedCount % common.extras.ads_interstitial_frequency == 0 ) ) then
         adsHelper.hideBanner()
         adsHelper.showInterstitial( function() adsHelper.showBanner() end )
      else
         adsHelper.showBanner()
      end

   end
end


-- ==
--    continue() - Continue a stopped game.
-- ==
function game.continue()
   if( common.gameCreated == false ) then return end
   if( common.gameIsRunning == true ) then return end
   -- 
   roomM.destroyMonstersNearPlayer()
   --
   common.gameIsRunning = true
   -- Unpause game
   game.pause(false, true)
end


-- ==
--    pause( pause ) - Pause/resume game. 
-- ==
function game.pause( pause )
   if( common.gameIsRunning == false ) then return end
   if( common.gameIsPaused == pause ) then return end
   
   -- PAUSE
   if( pause ) then      
      physics.pause()
      --
      pauseBlocker = newRect( common.layers.blocker, centerX, centerY, 
         { size = 10000, alpha = 0.1, touch = function() return true end  })
      transition.to( pauseBlocker, { alpha = 0.95, time = 800 } )
      
   
   -- RESUME
   else 
      local function onComplete()
         local counterBack = newImageRect( common.layers.blocker, centerX, centerY,
                                           "images/" .. common.theme .. "/counterBack.png", 
                                           { w = 230/2, h = 200/2, fill = common.color1 } )
         local countLabel = easyIFC:quickLabel( common.layers.blocker, "3", counterBack.x, counterBack.y, _G.fontB, 80 )
         local count = 3
         timer.performWithDelay( 1000, 
            function()
               count = count - 1
               countLabel.text = count
               if( count <= 0 ) then
                  display.remove(counterBack)
                  display.remove(countLabel)
                  physics.start()
                  display.remove( pauseBlocker )
                  pauseBlocker = nil
                  common.player:startMoving()
               end
            end, 3)
      end
      transition.to( pauseBlocker, { alpha = 0.1, time = 750, onComplete = onComplete } )
      
   end

   common.gameIsPaused = pause
end


----------------------------------------------------------------------
--          Custom Scene Functions/Methods
----------------------------------------------------------------------

--
-- This function is used to update the color of various buttons in the scene
-- whenever the scene color changes.
--
-- While the user plays the game, the room module changes the level color 
-- every N levels.
--
colorSet = function()
   --
   -- Colorize our buttons based on the current color theme
   common.color1 = common.currentColor
   common.color2 = { common.color1[1], common.color1[2], common.color1[3], common.color2Alpha  }

   pauseButton:setSelColor( common.color2 )
   pauseButton:setUnselColor( common.color1 )   

   if( coinBuyButton ) then
      coinBuyButton:setSelColor( common.color2 )
      coinBuyButton:setUnselColor( common.color1 )
   end

   coinCountLabel:setFillColor( unpack(common.color1) )
end

-- Sound Button Listener
onSound = function( event )
   if( event.phase == "moved" ) then return false end
   local target = event.target 
   persist.set( "settings.json", "sound_enabled", target:pressed() )
   soundMgr.enableSFX( persist.get( "settings.json", "sound_enabled" ) )
   post("onSound", { sound = "click" } )
end

-- Share Button Listener
onShare = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   require( "scripts.extras.sharing").showActivityDialog()
end

-- Facebook Button Listener
onFacebook = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   require( "scripts.extras.facebook").post()
end

-- Twitter Button Listener
onTwitter = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   require( "scripts.extras.twitter").sendTweet()
end

-- Rate Button Listener
onRate = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local function onSuccess()
      persist.set( "settings.json", "rated", true )
      if( target ) then
         table.removeByRef( buttons, target )
         utils.positionButtons( buttons, { time = 500, transition = easing.outBack, 
                                           widthOffset = -math.floor(w/4) } )
         display.remove(target)
      end
   end
   --
   require( "scripts.extras.rating").rate( onSuccess )
end


-- No Ads Button Listener
onNoAds = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local function onSuccess( itemName, event )
      local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )
      --
      if( event.state == "purchased" and itemName == "noads" ) then
         if( target ) then
            table.removeByRef( buttons, target )
            utils.positionButtons( buttons, nil, { time = 500, transition = easing.outBack,
                                                   widthOffset = -math.floor(w/4) })
            display.remove(target)
            
            -- Set persistent ads_enabled flag to false
            ssk.persist.set( "settings.json", "ads_enabled", false )

            -- Try to hide banner (just in case it is showing now)
            adsHelper.hideBanner()
           
            -- Disable the ads module and force it to clean up any 
            -- oustanding listeners.
            adsHelper.disableModule(true)
         end
      end

      -- Try to hide banner (just in case it is showing now)
      adsHelper.hideBanner()
   end
   --
   local easyIAP = require "scripts.iap.easyIAP"
   easyIAP.buy_noads( onSuccess )
end

-- Play Button Listener
onPlay = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   aboutButton.isVisible = false
   playButton:disable(1)
   --
   if( coinBuyButton ) then
      coinBuyButton.isVisible = false
   end
   --
   for k,v in pairs( buttons ) do
      v:disable(1)
   end   
   --
   local function onComplete()
      game.start()      
      --
      pauseButton.isVisible = true
   end
   --
   transition.to( common.layers.world, { xScale = 1, yScale = 1, 
                                  x = 0,  y = 0, delay = 400,
                                  time = 600, onComplete = onComplete } )
end

-- About Button Listener
onAbout = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   local options = {
      isModal     = true,
      effect      = "crossFade",
      time        = 500
   }
   composer.showOverlay( "scenes.about", options )
end


-- Achievements Button Listener
onAchievements = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   --require( "scripts.extras.gaming")
   --
end

-- Leaderboard Button Listener
onLeaderboard = function( event )
   local target = event.target
   post("onSound", { sound = "click" } )
   --
   --require( "scripts.extras.achievementsLeaderboards")
   --
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
      params      = { from = "play" },
   }
   composer.showOverlay( "scenes.shop", options )
end


return game