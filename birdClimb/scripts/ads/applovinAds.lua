-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local helpers 			= require "scripts.ads.helpers"
--
local listener
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

-- =============================================================
-- BEGIN EDITING HERE * BEGIN EDITING HERE * BEGIN EDITING HERE
-- =============================================================
-- Comment out next line do disable fake ads in simulator.
local fakeAds        = require "scripts.ads.fake" 

-- Be sure to set next variable to false you release your app.
local testMode       = true

-- To get more debug output, set this to 'true'
local verboseLogging = false

-- Provide IDs for Android and/or iOS depending on if you are using them or not.
-- TIP: Module is smart enought to use the right one.
local androidID      = "ANDROID_ID_HERE"
local iosID          = "IOS_ID_HERE"

-- The module has a slight initialization delay to make it play nicer
-- with composer.*
local initDelay      = 30

-- Set following to true to enable verbose output from the
-- event listener.
local verbose        = false
-- =============================================================
-- END EDITING HERE * END EDITING HERE * END EDITING HERE
-- =============================================================

-- Empty function
local stub = function() end


local public = {}

-- Used to stub out a function on the module, effectively 
-- disabling it.
local function disableFunction( name ) public[name] = stub end


-- Most functions start off stubbed out for that rare case where
-- the module is 'used' before prepare was called.
--
-- This should only ever happen while you are editting and then 
-- only if you start the 'home' scene immediately.
disableFunction( "listen" )
disableFunction( "ignore" )
disableFunction( "ignoreAll" )
disableFunction( "isLoaded" )
disableFunction( "load" )
disableFunction( "showBanner" )
disableFunction( "showInterstitial" )
disableFunction( "showRewarded" )
disableFunction( "hideBanner" )

function public.prepare( enabled )

   -- This function can only be called once, so stub it out.
   disableFunction( "prepare" )

   --
   -- This module utilizes the concept of 'temporary' listeners.
   -- These listeners can be added and removed by name.
   -- Any temporary listeners that are currently in our list are 
   -- called (randomly) if an ad event comes in.
   -- 
   local temporaryListeners = {}
   local function listener( event )
      if( verbose ) then
         helpers.dump( event, "applovin listener" )
      end
      --
      for key, aListener in pairs( temporaryListeners ) do
         aListener( event )
      end
   end   

   -- It is possible to disable the module now, or
   -- in the future, so make this a helper function.
   --
   -- This helper assigns an empty function to all module function
   -- to stub them out.
   public.disableModule = function( doCleaning )
      if( doCleaning ) then
         temporaryListeners = {}
      end
      disableFunction( "disableModule" )
      disableFunction( "listen" )
      disableFunction( "ignore" )
      disableFunction( "ignoreAll" )
      disableFunction( "isLoaded" )
      disableFunction( "load" )
      disableFunction( "showBanner" )
      disableFunction( "showInterstitial" )
      disableFunction( "showRewarded" )
      disableFunction( "hideBanner" )
   end
   
   -- If not enabled, disable the module immediately.
   if( not enabled ) then
      public.disableModule()

   -- The module IS enabled, so add REAL functions
   else
      -- Select current ID
      local os = helpers.os()
      local id = (os == "android") and androidID or iosID

      -- =============================================================
      -- Helper To Call init() - Not called till end of preparation.
      --
      -- Tip: You may want to modify this code to configure extra
      -- features.
      --
      -- =============================================================
      local function doInit()
         local lparams = {}         
         lparams.sdkKey           = id
         lparams.testMode         = testMode
         lparams.verboseLogging   = verboseLogging

         -- DO NOT EDIT THIS UNLESS YOU ARE AN EXPERT:
         if( ssk.persist.get( "settings.json", "has_gdpr_consent" ) ) then
            local function clear()
               public.ignore( "init" )
            end
            local function initListener( event )
               local isError  = event.isError
               local phase    = event.phase
               --
               if( isError and phase == "init" ) then
                  clear()
                  -- If the init failed we may as well just disable
                  -- the module.
                  public.disableModule(true)
                  return
               end
               --
               -- Set 'has user consent' on 'init' phase detected.
               if( phase == "init" ) then
                  clear()
                  local applovin = require( "plugin.applovin" )
                  applovin.setHasUserConsent( true )
               end
            end
            public.listen( "init", initListener )
         end         
         --
         local applovin = require( "plugin.applovin" )
         applovin.init( listener, lparams )
      end
      
      -- =============================================================
      -- Temporary listener helpers.
      -- =============================================================
      function public.listen( name, aListener )
         temporaryListeners[name] = aListener
      end
      function public.ignore( name )
         temporaryListeners[name] = nil
      end
      function public.ignoreAll()
         temporaryListeners = {}
      end

      -- =============================================================
      -- Expose isLoaded() and load()
      -- If you need more applovin features exposed, 
      -- add your own helpers to expose them.
      -- =============================================================
      function public.isLoaded( adType )      
         if( helpers.onSim() ) then return true end      
         --
         local applovin = require( "plugin.applovin" )
         return applovin.isLoaded( adType  )      
      end
      
      function public.load( adType )
         if( helpers.onSim() ) then return end
         --
         local applovin = require( "plugin.applovin" )
         applovin.load( adType  )      
      end

      -- =============================================================
      -- Custom Show Functions
      -- =============================================================
      function public.showBanner( position, placement )
         if( helpers.onSim() ) then 
            if( fakeAds ) then                         
               fakeAds.showBanner( "applovin", id, position, placement )
            end
            return 
         end
         --
         local lparams = {}
         lparams.yAlign = position or "bottom"         
         lparams.placement = placement
         --
         local applovin = require( "plugin.applovin" )
         applovin.show( "banner", lparams  )
      end

      function public.showInterstitial( onComplete, placement )
         onComplete = onComplete or stub
         --
         if( helpers.onSim() ) then 
            if( fakeAds ) then 
               fakeAds.showInterstitial( "applovin", id, onComplete, placement )
            else
               onComplete()
            end
            return 
         end
         --
         local function clear()
            public.ignore( "interstitial" )
         end
         local function interstitialListener( event )
            local isError  = event.isError
            local phase    = event.phase
            --
            if( isError and phase == "interstitial" ) then
               clear()
               return
            end
            --
            -- Catch all 'ended' equivalent phases and assume that 
            -- the first one means we have shown the interstitial.
            if( phase == "hidden" or phase == "playbackEnded" ) then
               clear()
               onComplete()
            end
         end
         public.listen( "interstitial", interstitialListener )
         --
         local applovin = require( "plugin.applovin" )
         --
         if( placement ) then
            local lparams = {}
            lparams.placement = placement
            applovin.show( "interstitial", lparams  )
         else
            applovin.show( "interstitial" )
         end
      end

      function public.showRewarded( onSuccess, onFailure, placement )
         onSuccess = onSuccess or stub
         onFailure = onFailure or stub
         --
         if( helpers.onSim() ) then 
            if( fakeAds ) then 
               fakeAds.showRewarded( "applovin", id, onSuccess, onFailure, placement )
            else
               onSuccess()
            end
            return 
         end
         --
         local function clear()
            public.ignore( "interstitial" )
         end
         local function rewardedListener( event )
            local isError  = event.isError
            local phase    = event.phase
            --
            if( isError  and phase == "rewardedVideo" ) then
               clear()
               onFailure()
               return
            end

            -- 'closed' may get extra data that will allow for a failed rewarded case?
            -- Is this universal or only for some?
            -- EFM

            --
            -- Catch all 'ended' equivalent phases and assume that 
            -- the first one means we have shown the rewardedVideo.
            if( phase == "hidden" or phase == "playbackEnded" ) then
               clear()
               onSuccess()
            end
         end
         public.listen( "rewarded", rewardedListener   )
         --
         local applovin = require( "plugin.applovin" )
         --
         if( placement ) then
            local lparams = {}
            lparams.placement = placement
            applovin.show( "rewardedVideo", lparams  )
         else
            applovin.show( "rewardedVideo" )
         end
      end

      -- =============================================================
      -- Hide Banner Helper
      -- =============================================================
      function public.hideBanner()
         if( helpers.onSim() ) then 
            if( fakeAds ) then 
               fakeAds.hideBanner()
            end
            return 
         end
         --
         local applovin = require( "plugin.applovin" )
         applovin.hide( "banner"  )
      end

      -- =============================================================
      -- Initialize ads as last step of 'preparing' the module
      -- =============================================================
      if( helpers.onSim() == false ) then
         timer.performWithDelay( initDelay, doInit )
      end
   end
end
return public