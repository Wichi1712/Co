-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- Minimalistic 'starter' config.lua
-- =============================================================
-- https://docs.coronalabs.com/guide/basics/configSettings/index.html
-- =============================================================
application = {
   content = {
      width              = 640,
      height             = 960,
      scale              = "letterbox",
      fps                = 60,
   },

   -- Dynamic Image Selection
   --[[
   imageSuffix = {
      ["@2x"] = 2.0,
   },
   --]]

   -- Google Play In-App-Purchase
   -- https://docs.coronalabs.com/plugin/google-iap-v3/index.html
   --[[
   license = {
      google = {
         key = "YOUR_KEY",         
      },
   },
   --]]    
}

