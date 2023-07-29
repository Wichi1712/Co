-- =============================================================
-- Copyright Roaming publicr, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
-- =============================================================
local common      = require "scripts.common"
local easyIAP     = require "scripts.iap.easyIAP"

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
-- Locals
-- =============================================================
local coinIcon
local coinCounter
local coinPath          = "images/" .. common.theme .. "/coin.png"
local coinFill          = common.gold
local moveIconPath      = "images/" .. common.theme .. "/movie.png"
local moveIconFill      = _W_

local birdIconPath         = "images/" .. common.theme .. "/"
local birdIconFill         = _W_
local unlockedIconPath     = "images/" .. common.theme .. "/unlocked.png"
local unlockedIconFill     = _W_
local lockedIconPath       = "images/" .. common.theme .. "/locked.png"
local lockedIconFill       = _W_

--
local movieGroup 

-- =============================================================
-- Forward Declarations
-- =============================================================
local makeItemButton 
local select
local onTouch

-- =============================================================
-- Module Begins
-- =============================================================
local public = {}

-- ==
--    init() - One-time initialization of public module.
-- ==
function public.init()
   persist.setDefault( "settings.json", "coins", 400 )
   persist.setDefault( "settings.json", "coins", 400 )
end

-- ==
--    create() - 
-- ==
function public.create( parent, params )
   parent = parent or display.currentStage
   params = params or {}
   --
   local group = display.newGroup()
   parent:insert( group )
   -- 

   -- Calculate height of store page components
   local itemButtonSize       = 110
   local itemButtonOffset     = 20
   local columns              = 3
   local commonWidth          = itemButtonSize * columns + itemButtonOffset * (columns + 1)
   local headerHeight         = 100
   local maxBannerHeight      = 100
   local extraYOffset         = 10 
   local videoButtonHeight    = 100
   local videoButtonY         = top + headerHeight + videoButtonHeight/2 + extraYOffset + common.titleOffsetY

   local scrollerHeight       = fullh - headerHeight - maxBannerHeight - videoButtonHeight - 3 * extraYOffset - common.titleOffsetY
   local scrollerY            = videoButtonY + videoButtonHeight/2 + extraYOffset + scrollerHeight/2

   --   
   -- Create 'Watch Video' Button
   --
   movieGroup = display.newGroup()
   group:insert(movieGroup)
   --
   function movieGroup.finalize()
      movieGroup = nil
   end; movieGroup:addEventListener("finalize")
   --
   if( easyIAP.owns_unlockall() or easyIAP.owns_noads() ) then
      -- Skip
   else
      local function onWatchRewarded( event )
         local function onSuccess()
            local coins = tonumber(persist.get( "settings.json", "coins" ))
            --
            coins = coins + common.rewardedAdEarnsCoins
            --
            persist.set( "settings.json", "coins", coins ) 
            --
            coinCounter.text = coins           
         end
         local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )
         adsHelper.showRewarded( onSuccess )
      end

      local button = easyIFC:presetPush( movieGroup, "basic_transparent", centerX, videoButtonY, 
                                         commonWidth-4-2*itemButtonOffset, videoButtonHeight-itemButtonOffset/2, "", onWatchRewarded,
                                         { strokeWidth = 5 } )
      local icon1  = newImageRect( button, -20, 0, moveIconPath,
                                   { size = videoButtonHeight, anchorX = 1, fill = moveIconFill } )

      local icon2  = newImageRect( button, 20, 0, coinPath,
                                   { size = videoButtonHeight - 40, anchorX = 0, fill = coinFill } )

      local label  = easyIFC:quickLabel( button, "+" .. tostring(common.rewardedAdEarnsCoins), icon2.x + icon2.contentWidth + 10 , 0, _G.fontN, 36, _W_, 0  )
   end

   --
   -- Create Coins Counter
   --
   coinIcon  = newImageRect( group, w - 80 - common.cornerOffsetX, top + common.cornerOffsetY + 50, coinPath,
                                { size = 50,  
                                  fill = coinFill } )
   coinCounter = easyIFC:quickLabel( group, persist.get( "settings.json", "coins"), 
                                     coinIcon.x - 30, coinIcon.y, _G.fontN, 40, _W_, 1 )

   --
   -- Create Shop Scroller
   --   
   --local tmp = newRect( group, centerX, scrollerY, { w = commonWidth, h = scrollerHeight, fill = _GREY_ })
   local scroller = ssk.vScroller.new( group, centerX, scrollerY, 
                                                      { w = commonWidth, h = scrollerHeight, 
                                                        backFill = {0,0,0,0.5}, 
                                                        dragDist = 25 }  )
   local tmp = display.newLine( group, centerX - commonWidth/2, scrollerY - scrollerHeight/2, 
                                centerX + commonWidth/2, scrollerY - scrollerHeight/2 )
   tmp.strokeWidth = 5
   tmp:setStrokeColor( unpack(coinFill) )
   local tmp = display.newLine( group, centerX - commonWidth/2, scrollerY + scrollerHeight/2, 
                                centerX + commonWidth/2, scrollerY + scrollerHeight/2 )
   tmp.strokeWidth = 5
   tmp:setStrokeColor( unpack(coinFill) )

   --
   -- Create Some (Fake) Items For Example
   -- 
   -- Normally this section would be a bit longer... :)
   --
   local items = {}

   local ownsAll = ( easyIAP.owns_unlockall and easyIAP.owns_unlockall() )

   -- 
   -- Generate some Birds that can be bought with in-game currency: Coins
   --
   for i = 1, 5 do
      items[#items+1] = { currency = "coins", cost = 500 + (i-1) * 500, id = "item" .. i, name = "Bird " .. i, 
                          itemType = "bird", birdFile = "iap_bird" .. i .. ".png", birdNum = i,
                          owned = (i == 1) or (persist.get( "settings.json", "item" .. i ) == true) or ownsAll   }
                          --owned = (persist.get( "settings.json", "item" .. i ) == true) }
   end
   --
   -- Add some IAP items
   --
   items[#items+1] = { currency = "iap", id = "coins_1000", iapID = "coins_1000", name = "1,000 Coins", amount = 1,
                       price = "$0.99", consumable = true }

   items[#items+1] = { currency = "iap", id = "coins_4000", iapID = "coins_4000", name = "4,000 Coins", amount = 1,
                       price = "$2.99", consumable = true }

   items[#items+1] = { currency = "iap", id = "coins_8500", iapID = "coins_8500", name = "8,500 Coins", amount = 1,
                       price = "$3.99", consumable = true }

   items[#items+1] = { currency = "iap", id = "noads", iapID = "noads", name = "No Ads", amount = 1,
                       price = "$0.99",
                       owned = ( easyIAP.owns_noads and easyIAP.owns_noads() ) or ownsAll }

   items[#items+1] = { currency = "iap", id = "unlockall", iapID = "unlockall", name = "Unlock All", amount = 1,
                       price = "$14.99", -- Tip: Provide empty string to hide the price
                       owned = ownsAll }

   --
   -- Add Items To Scroller 
   --
   local allItems = {}
   local row = 1
   local col = 1
   local x, y
   for i = 1, #items do
      local item = items[i]
      --
      x = col * itemButtonSize + (col * itemButtonOffset) - itemButtonSize/2
      y = row * itemButtonSize + ( row * itemButtonOffset) - itemButtonSize/2
      --
      if( item.currency == "coins" or item.owned == false or item.consumable == true ) then
         makeItemButton( scroller, x, y, itemButtonSize, items[i], allItems )
         --
         col = col + 1
         if( col > columns ) then
            col = 1
            row = row + 1
         end
      end
   end
   --
   -- Add buffer at scroller bottom (to provide bottom gap)
   --
   local buffer = newRect( nil, 10, y + itemButtonSize/2 + itemButtonOffset, 
                          { size = 10, fill = _T_, anchorY = 1 } )
   scroller:insert(buffer)


   --
   -- Add finalize listener to clean up
   --
   function group.finalize( self )
      -- Clear coinCounter variable
      coinIcon = nil
      coinCounter = nil
   end; group:addEventListener( "finalize" )
end

-- =============================================================
-- Local Function Definitions
-- =============================================================
makeItemButton = function( scroller, x, y, size, rec, allItems )
   
   local item = display.newGroup()
   item.x = x
   item.y = y
   scroller:insert(item)
   item.isSelected = false
   item.onSelect = onSelect
   scroller:addTouch( item, onTouch )
   item.rec = rec
   item.allItems = allItems
   allItems[#allItems+1] = item
   --   
   item.frame = ssk.display.newImageRect( item, 0, 0, "images/fillT.png", 
      { stroke = _W_, strokeWidth = 5, size = size })
   --
   item.nameLabel = easyIFC:quickLabel( item, rec.name, 0, -size/2 + 5, _G.fontN, 16, _W_, 0.5, 0 )


   -- 
   -- Function To Buy Game Item With Coins
   --
   local function selectBird( self )
      if( not self.rec.birdNum ) then return end
      --
      ssk.persist.set( "settings.json", "currentBird", self.rec.birdNum )
      --
      --print("Selected bird: ", self.rec.birdNum)
   end
   -- 
   -- Function To Buy Game Item With Coins
   --
   local function buyWithCoins( self )
      local coins = tonumber(persist.get( "settings.json", "coins" ))
      --
      if( coins < self.rec.cost ) then 
         ssk.misc.easyShake(coinIcon, 10 )
         ssk.misc.easyShake(coinCounter, 10 )
         return 
      end
      --
      coins = coins - self.rec.cost
      persist.set( "settings.json", "coins", coins )      
      --
      persist.set( "settings.json", self.rec.id, true )
      -- 
      coinCounter.text = coins
      --
      self.cost.isVisible = false
      self.icon.isVisible = false
      if( self.rec.itemType == "bird" ) then
         self.lock.fill = { type = "image", filename = birdIconPath .. self.rec.birdFile }
         self.lock:setFillColor( unpack(unlockedIconFill))
         --
         self.buy = selectBird
         selectBird(self)
      else
         self.lock.fill = { type = "image", filename = unlockedIconPath }
         self.lock:setFillColor( unpack(unlockedIconFill))
      end
   end

   -- 
   -- Function To Buy No Ads
   --
   local function buyNoAds( self )
      local function onSuccess()
         self.lock.fill = { type = "image", filename = unlockedIconPath }
         self.lock:setFillColor( unpack(unlockedIconFill))
         self.label.isVisible = false
         movieGroup.isVisible = false
         --
         -- Set persistent ads_enabled flag to false
         ssk.persist.set( "settings.json", "ads_enabled", false )

         local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )

         -- Try to hide banner (just in case it is showing now)
         adsHelper.hideBanner()
        
         -- Disable the ads module and force it to clean up any 
         -- oustanding listeners.
         adsHelper.disableModule(true)         
      end
      easyIAP.buy_noads(onSuccess)
   end

   -- 
   -- Function To Buy Unlock All
   --
   local function buyUnlockAll( self )
      local function onSuccess()
         self.lock.fill = { type = "image", filename = unlockedIconPath }
         self.lock:setFillColor( unpack(unlockedIconFill))
         self.label.isVisible = false
         --
         movieGroup.isVisible = false
         --
         local allItems = self.allItems
         for i = 1, #allItems do
            local item = allItems[i]
            if( item.rec.currency == "coins" ) then               
               if( item.rec.itemType == "bird" ) then
                  item.lock.fill = { type = "image", filename = birdIconPath .. item.rec.birdFile }
                  if( item.cost ) then
                     item.cost.isVisible = false
                     item.icon.isVisible = false
                  end
               end
               --
               item.buy = selectBird


            elseif( item.rec.id == "noads" ) then
               item.lock.fill = { type = "image", filename = unlockedIconPath }
               item.lock:setFillColor( unpack(unlockedIconFill))
               item.label.isVisible = false
            end
         end
         --
         -- Set persistent ads_enabled flag to false
         ssk.persist.set( "settings.json", "ads_enabled", false )
               
         local adsHelper = require( "scripts.ads." .. common.extras.ads_provider .. "Ads" )

         -- Try to hide banner (just in case it is showing now)
         adsHelper.hideBanner()
        
         -- Disable the ads module and force it to clean up any 
         -- oustanding listeners.
         adsHelper.disableModule(true)         
      end
      easyIAP.buy_unlockall( onSuccess )
   end



   -- 
   -- Function To Buy Coins
   --
   local function buyCoins( self )
      local itemID   = self.rec.id
      local iapID    = self.rec.iapID
      local buyFunc  = easyIAP["buy_" .. iapID]

      if( not buyFunc ) then
         print( "Warning! - Could not find buy function.  Did you set up IAP ids?")
         return
      end
      -- 
      local function onSuccess( boughtID )
         local coins = tonumber(persist.get( "settings.json", "coins" ))
         --
         if( itemID == "coins_1000" ) then
            coins = coins + 1000
         elseif( itemID == "coins_4000" ) then
            coins = coins + 4000
         elseif( itemID == "coins_8500" ) then
            coins = coins + 8500
         end
         --
         persist.set( "settings.json", "coins", coins )      
         --
         coinCounter.text = coins
      end
      --
      buyFunc( onSuccess )
   end
   --  
   -- Game Item Purchased With In-Game Currency: Coins
   --
   if( rec.currency == "coins" ) then
      if( rec.owned ) then
         if( rec.itemType == "bird" ) then
            
            item.lock = newImageRect( item, 0, 0, birdIconPath .. rec.birdFile, { size = size/2, fill = unlockedIconFill } )
         else
            item.lock = newImageRect( item, 0, 0, unlockedIconPath, { size = size/2, fill = unlockedIconFill } )
         end
         item.buy = selectBird         
      else
         item.lock = newImageRect( item, 0, -5, lockedIconPath, { size = size/2, fill = lockedIconFill } )
         item.cost = easyIFC:quickLabel( item, rec.cost, 0, size/2 - 10, _G.fontN, 16, _W_, 1, 1 )
         item.icon = newImageRect( item, 5, item.cost.y, coinPath,
                                { size = item.cost.contentHeight, anchorX = 0, anchorY = 1,
                                  fill = coinFill } )
         item.buy = buyWithCoins
      end
   
   --
   -- IAP Items
   --
   elseif( rec.currency == "iap" and rec.id == "noads" ) then
         item.lock = newImageRect( item, 0, -5, lockedIconPath, { size = size/2, fill = lockedIconFill } )
         local text = rec.price or "Buy"
         item.label = easyIFC:quickLabel( item, text, 0, size/2 - 10, _G.fontN, 16, _W_, 0.5, 1 )
         item.buy = buyNoAds

   elseif( rec.currency == "iap" and rec.id == "unlockall" ) then
         item.lock = newImageRect( item, 0, -5, lockedIconPath, { size = size/2, fill = lockedIconFill } )
         local text = rec.price or "Buy"
         item.label = easyIFC:quickLabel( item, text, 0, size/2 - 10, _G.fontN, 16, _W_, 0.5, 1 )
         item.buy = buyUnlockAll
   
   elseif( rec.currency == "iap" ) then
         item.icon = newImageRect( item, 0, 0, coinPath,
                                { size = size/3, fill = coinFill } )
         local text = rec.price or "Buy"
         item.label = easyIFC:quickLabel( item, text, 0, size/2 - 10, _G.fontN, 16, _W_, 0.5, 1 )
         item.buy = buyCoins
   end
  
end

--
onSelect = function( self, sel )
   if( self.isSelected == sel ) then return end
   self.isSelected = sel
   if( sel ) then
      transition.cancel( self )
      transition.to( self, { xScale = 0.85, yScale = 0.85, time = 500, transition = easing.outBounce } )
   else
      transition.cancel( self )
      transition.to( self, { xScale = 1, yScale = 1, time = 150, transition = easing.linear } )
   end
end

--
onTouch = function ( self, event )  
   local scroller = event.target
   local dragged = scroller.dragged
   local owned = self.rec.owned

   if( event.phase == "began" ) then
      if(self.onSelect) then self:onSelect(true) end
   
   elseif( event.phase == "ended" ) then  
      if(self.onSelect) then self:onSelect(false) end
      
      if( not dragged and self.rec.itemType == "bird" and self.buy ) then
         -- Play a sound
         post("onSound", { sound = "click" } )

         self:buy()

      elseif( not dragged and not owned and self.buy ) then
         -- Play a sound
         post("onSound", { sound = "click" } )

         self:buy()
      end
      dragged = false      
   end
   if( dragged ) then
      if(self.onSelect) then self:onSelect(false) end
   end
   --table.dump( event )
end


return public



