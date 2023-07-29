-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
--  easyIAP.lua
-- =============================================================
local common      = require "scripts.common"
local helpers     = require "scripts.iap.helpers"
local iap_badger  = require "scripts.iap.iap_badger"
-- =============================================================

-- =============================================================
-- Start with empty catalog
-- =============================================================
local catalog           = {}
catalog.products        = {}
catalog.inventoryItems  = {}
-- =============================================================
local easyIAP = {}

-- =============================================================
-- BEGIN EDITING HERE * BEGIN EDITING HERE * BEGIN EDITING HERE
-- =============================================================
local salt      = "TypeSomeRandomStringHere"

local ids = { android = {}, ios = {} }
--
ids.android.noads       = "com.yourcompany.appname.noads"
ids.android.unlockall   = "com.yourcompany.appname.unlockall"
ids.android.coins_1000  = "com.yourcompany.appname.coins_1000"
ids.android.coins_4000  = "com.yourcompany.appname.coins_4000"
ids.android.coins_8500  = "com.yourcompany.appname.coins_8500"
--
ids.ios.noads           = "com.yourcompany.appname.noads"
ids.ios.unlockall       = "com.yourcompany.appname.unlockall"
ids.ios.coins_1000      = "com.yourcompany.appname.coins_1000"
ids.ios.coins_4000      = "com.yourcompany.appname.coins_4000"
ids.ios.coins_8500      = "com.yourcompany.appname.coins_8500"
--
function easyIAP.prepare( )
   local os = helpers.os()
   if( os == "android" or os == "ios" ) then
      easyIAP.addItem( "noads",        ids[os].noads,       "non-consumable" )
      easyIAP.addItem( "unlockall",    ids[os].unlockall,   "non-consumable" )
      easyIAP.addItem( "coins_1000",   ids[os].coins_1000,  "consumable" )
      easyIAP.addItem( "coins_4000",   ids[os].coins_4000,  "consumable" )
      easyIAP.addItem( "coins_8500",   ids[os].coins_8500,  "consumable" )
   end
   --
   local doNotLoadInventory = common.iap_do_not_load_inventory
   if( common.extras.iap_test_mode == false ) then 
      doNotLoadInventory = false
   end
   --
   easyIAP.init( 
      {
         salt               = salt,
         testMode           = common.extras.iap_test_mode,
         doNotLoadInventory = doNotLoadInventory,         

      } )
end
-- =============================================================
-- STOP EDITING HERE * STOP EDITING HERE * STOP EDITING HERE
-- =============================================================


-- =============================================================
-- ONLY EXPERTS NEED MODIFY BELOW THIS LINE
-- =============================================================
function easyIAP.setBadger( badgerIn )
   iap_badger = badgerIn
end

-- =============================================================
--
--  name - Short name of IAP item
--    id - ID for IAP item (assumes same ID for all stores)
-- ptype - Product type "non-consumable" or "consumable"  (default is "non-nonsumable")
--
-- params - Optional fields to get extra features.
--
-- title     - Title for dialog.
-- msg       - Message body for dialog.
-- yesText   - (Optional) Text for 'Yes' button.  Defaults to 'Yes'
-- noText    - (Optional) Text for 'No' button.  Defaults to 'No'
-- purchaseListener - (Optional) listener for purchase attempts.
--
function easyIAP.addItem( name, id, ptype, params  )
   params = params or {}
   -- New Product Entry
   catalog.products[name] =
   {
      productNames = 
      { 
         apple    = id,
         google   = id,
      },

      productType = (ptype or "non-consumable"),

      onPurchase = 
         function() 
            iap_badger.setInventoryValue( name, true )
            iap_badger.saveInventory()
         end,

      onRefund = 
         function() 
            iap_badger.setInventoryValue( name, false )
            iap_badger.saveInventory()
         end,

      simulatorPrice          = params.simulatorPrice,
      simulatorDescription    = params.simulatorDescription, 
   }

   -- New Inventory item
   catalog.inventoryItems[name] = { productType = ptype or "non-consumable" }

   -- Attach a function to check for ownership of a product to easyIAP module
   easyIAP["owns_" .. name ] = function() 
      return iap_badger.getInventoryValue(name) or false
   end

   -- Attach a customized 'buy' function to the easyIAP module.
   local function onBuy( altPurchaseListener )
      
      if( altPurchaseListener ) then
         iap_badger.purchase( name, altPurchaseListener )
      elseif( params.purchaseListener ) then
         iap_badger.purchase( name, params.purchaseListener )
      else
         iap_badger.purchase( name )
      end
   end

   -- Show a 'prompt' dialog before starting purchase
   if( params.title ) then
      easyIAP["buy_" .. name] = function( altPurchaseListener ) 
         helpers.easyAlert( params.title,params.msg,    
                    {
                      { params.noText or "No",  nil },
                      { 
                        params.yesText or "Yes",  
                        function() timer.performWithDelay( 30, function() onBuy(altPurchaseListener) end) end 
                      }
                      
                    } )
      end
   else

      easyIAP["buy_" .. name] = onBuy
   end
end

-- =============================================================
-- This function doesn't serve much purpose, because of the way it 
-- is called, but it can be overriden if need be.
local function defaultOnFail( name, details ) 
   if( not details or type( details ) ~= "table" ) then
      return 
   end
   print("defaultOnFail()", name ) 
   for k,v in pairs( details ) do
      print( ">> " .. tostring(k) .. " = " .. tostring(v) )
   end
   
end

-- =============================================================
-- easyIAP.getProductsCatalog() - Returns the products catalog
--
function easyIAP.getProductsCatalog( )
   return iap_badger.getLoadProductsCatalogue()

end


-- =============================================================
-- easyIAP.init( params [, onCatalog ] ) - Prepares the generated features for use.
--
-- params - Table of options (all settings are optional).
-- >     salt - String used to 'encode' save file.
-- >   onFail - General listener for failed purchases.
-- > onCancel - General listener for cancelled purchases.
-- > testMode - Set to 'true' if you want to test IAP w/o the store.
-- > doNotLoadInventory - Set to 'true' if you want to start with all items unpurchased.
--
-- onCatalog - Supply this function if you want the easyIAP helper to load the store catalog
-- and to then call this function.  Please note: 
-- > This is not immediate.  It takes time to get the catalog info from the store.
-- > The purpose of doing this is to get region specific prices and other information.
--   Thus allowing you to customize graphics and prices you display in your game.
--   If you do not explicitly show the price of an item in the game interface, but instead
--   rely on the store dialog to show the price, you do not need to use this feature.
--
--
function easyIAP.init( params, onCatalog )
   params = params or {}
   local options = 
   {
      catalogue           = catalog,
      filename            = params.iapFilename or "iap.json",
      salt                = params.salt or "398lkdfjoasd7nmkasdfo",
      failedListener      = params.onFail or defaultOnFail,
      cancelledListener   = params.onCancel or defaultOnFail,
      doNotLoadInventory  = helpers.fnn( params.doNotLoadInventory, false ),
      debugMode           = helpers.fnn( params.testMode, true )
   }
   iap_badger.init(options)
   --
   if(onCatalog) then iap_badger.loadProducts( onCatalog ) end
   --
   easyIAP.init = function() print("Warning: You called easyIAP.init() twice!") end  -- Stub out init to prevent multiple calls.
end

-- =============================================================
-- This function restores all previously purchaed items
--
local lastRestoreTimer
function easyIAP.restore( onSuccess, onFail )
   doDialog = (doDialog ~= false) -- default to 'true'
   local function restoreListener( productName, event )
      if( event.firstRestoreCallback and onSuccess ) then

         if( lastRestoreTimer ) then 
            timer.cancel(lastRestoreTimer)
         end
         lastRestoreTimer = timer.performWithDelay( 1, 
            function()
               lastRestoreTimer = nil         
               onSuccess(event)
            end )
      end
      iap_badger.saveInventory()
   end
   iap_badger.restore( false, restoreListener, onFail or defaultOnFail )  
end

return easyIAP	