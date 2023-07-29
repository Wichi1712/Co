-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local common 		= require "scripts.common"
local physics     = require "physics"

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
local colorSet

-- Monster layout rules
--
-- 0 - No monster
-- 1 - Monster on left
-- 2 - Monster on right
-- 3 - Monster on both sides.
--
local monsterLayouts = { }

monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 1, 0, 0, 0, 2, 0, 0, 1, 0, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 1, 2, 0, 1, 0, 0, 1, 2, 0, 0, 1 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 1, 1, 0, 3, 2, 0, 0, 1, 0, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 3, 2, 1, 0, 0, 0, 1, 3, 0, 3, 2, 0, 0,0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 3, 2, 1, 0, 0, 0, 1, 3, 3, 2, 0, 0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 1, 1, 2, 2, 0, 0, 1, 1, 1, 2, 2, 2, 0, 0, 0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 1, 0, 0, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 1, 1, 0, 0, 2, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 1, 1, 1, 0, 0, 2, 2, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 3, 0, 0, 3, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 3, 3, 0, 0, 3, 3, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 100, layout = { 0, 0, 1, 3, 3, 3, 0, 0, 3, 3, 3, 2 } }

monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 1, 0, 0, 0, 2, 0, 0, 1, 0, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 1, 2, 0, 1, 0, 0, 1, 2, 0, 0, 1 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 1, 1, 0, 3, 2, 0, 0, 1, 0, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 3, 2, 1, 0, 0, 0, 1, 3, 0, 3, 2, 0, 0,0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 3, 2, 1, 0, 0, 0, 1, 3, 3, 2, 0, 0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 1, 1, 2, 2, 0, 0, 1, 1, 1, 2, 2, 2, 0, 0, 0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 1, 0, 0, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 1, 1, 0, 0, 2, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 1, 1, 1, 0, 0, 2, 2, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 3, 0, 0, 3, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 3, 3, 0, 0, 3, 3, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 90, layout = { 0, 0, 1, 3, 3, 3, 0, 0, 3, 3, 3, 2 } }

monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 1, 0, 0, 0, 2, 0, 0, 1, 0, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 1, 2, 0, 1, 0, 0, 1, 2, 0, 0, 1 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 1, 1, 0, 3, 2, 0, 0, 1, 0, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 3, 2, 1, 0, 0, 0, 1, 3, 0, 3, 2, 0, 0,0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 3, 2, 1, 0, 0, 0, 1, 3, 3, 2, 0, 0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 1, 1, 2, 2, 0, 0, 1, 1, 1, 2, 2, 2, 0, 0, 0 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 1, 0, 0, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 1, 1, 0, 0, 2, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 1, 1, 1, 0, 0, 2, 2, 2, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 3, 0, 0, 3, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 3, 3, 0, 0, 3, 3, 2 } }
monsterLayouts[#monsterLayouts+1] = { tween = 80, layout = { 0, 0, 1, 3, 3, 3, 0, 0, 3, 3, 3, 2 } }


-- =============================================================
-- Forward Declarations
-- =============================================================
local makeEyeMonster


-- =============================================================
-- Module Begins
-- =============================================================
local public = {}

function public.setColorSet( colorSetF )
	colorSet = colorSetF
end

-- ==
--
-- ==
function public.drawWallsAndFloor( width, height )
	width = width or w
	height = height or common.levelHeight

	local back = newRect( common.layers.underlay, centerX, centerY, { w = width, h = height } )
	back:toBack() -- Push under one-touch so if we turn on debug mode we can see it.

	-- left wall
	local lw = newRect( common.layers.content, common.worldLeft + 10, centerY, 
		     { w = 100, h = height * 2, fill = common.currentColor, isWall = true, anchorX = 1 }, 
		     { bodyType = "kinematic", isSleepingAllowed = false, friction = 0 } )

	-- right wall
	local rw = newRect( common.layers.content, common.worldRight - 10, centerY, 
		     { w = 100, h = height * 2, fill = common.currentColor, isWall = true, anchorX = 0 }, 
		     { bodyType = "kinematic", isSleepingAllowed = false, friction = 0 } )

	-- bottom wall
	local bw = newRect( common.layers.content, centerX, bottom + height/2 - 10, 
		     { w = width, h = height, fill = common.currentColor }, 
		     { bodyType = "static", bounce = 0, friction = 0 } )

	-- Instructions
	local art = newImageRect( common.layers.menu, common.worldRight - 10, bw.y - height/2, 
	                          "images/" .. common.theme .. "/instructionart.png",
	                          { w = 640, h = 300, anchorX = 1, anchorY = 0 } )
	local iTween = 36
	local tmp = easyIFC:quickLabel( common.layers.menu, "Tap faster to fly faster,", common.worldLeft + 10, art.y + iTween/2, _G.fontN, 35, _W_, 0, 0 )
	local tmp = easyIFC:quickLabel( common.layers.menu, "but i will always fly", common.worldLeft + 10, tmp.y + iTween, _G.fontN, 35, _W_, 0, 0 )
	local tmp = easyIFC:quickLabel( common.layers.menu, "from side to side.", common.worldLeft + 10, tmp.y + iTween, _G.fontN, 35, _W_, 0, 0 )
	local tmp = easyIFC:quickLabel( common.layers.menu, "Pick up coins.", common.worldLeft + 10, tmp.y + iTween, _G.fontN, 35, _W_, 0, 0 )
	local tmp = easyIFC:quickLabel( common.layers.menu, "Just don't let me hit the obstacles!", common.worldLeft + 10, tmp.y + iTween, _G.fontN, 35, _W_, 0, 0 )

	common.allColoredObj[rw] = rw
	common.allColoredObj[bw] = bw
	common.allColoredObj[lw] = lw

	-- listener to keep walls aligned with
	function bw.enterFrame( self )
		if( not common.gameIsRunning ) then return end
		if( not isValid( common.player ) ) then return end
		lw.y = common.player.y
		rw.y = common.player.y
	end; listen( "enterFrame", bw )

end

function public.drawMonsters( drawPickup )

	-- ==
	-- Capture highest level completed today
	-- ==
   if( common.level > common.highestLevelToday ) then
   	common.highestLevelToday = common.level 
   end


   -- ==
   -- Check if we hit a a new highScore
   -- ==
   local bestScore = ssk.persist.get( "settings.json", "bestScore" )
   if( common.level > bestScore ) then
   	ssk.persist.set( "settings.json", "bestScore", common.level )
   end
   
   -- ==
   -- Increment 'current level' number
   -- ==
   common.level = common.level + 1

	-- ==
	--  Time to change color?  If so, change all 'colored' objects.
	-- -- ==
   if( common.level % common.colorChangeFreq == 1) then
      local lastColor = common.currentColor
      common.currentColor = table.getRandom( common.colors )
      if( common.level == 1 ) then
         for k,v in pairs( common.allColoredObj ) do
            v:setFillColor(unpack( common.currentColor ))
         end         
      else
         for k,v in pairs( common.allColoredObj ) do
            transition.color( v, { fromColor = lastColor, toColor = common.currentColor } )
         end         
      end

      -- Update interface (button) colors too
      colorSet()
   end


	-- ==
	--    Calculate begin and end position for monsters drawing.
	-- ==
   local beginY = common.player.genY
   local endY = beginY - common.levelHeight

   -- ==
   -- Draw 'Level Label'
   -- ==
   local levelLabel = display.newText( common.layers.background, "LEVEL " .. common.level, 
                                       centerX, beginY, _G.fontB, 40 )
   levelLabel:setFillColor(unpack(_GREY_))

   -- ==
   --	Draw the monsters
   -- ==
	local freqData
	local num 

	if( common.level > 36 ) then
		num = mRand(1,#monsterLayouts)
	elseif( common.level > 24 ) then
		num = mRand(24,36)
	elseif( common.level > 12 ) then
		num = mRand(13,24)
	elseif( common.level == 1 ) then	
		num = mRand(1,4)
	else
		num = mRand(1,12)
	end

	freqData = monsterLayouts[num]

	local tween = freqData.tween
	local layout = freqData.layout
	local count = 1

	--print("drawMonsters: ", num, beginY, endY, getTimer() )

	for y = beginY, endY, -tween do
		local cur = layout[count]
		count = count + 1
		count = count > #layout and 1 or count
		if( cur == 0 ) then
		elseif( cur == 1 ) then
			makeEyeMonster( common.layers.monsters, y, true )
		elseif( cur == 2 ) then
			makeEyeMonster( common.layers.monsters, y, false )
		elseif( cur == 3 ) then
			makeEyeMonster( common.layers.monsters, y, true )
			makeEyeMonster( common.layers.monsters, y, false )
		end
	end  

	-- ==
	-- Draw pickup if requested
	-- == 	
	for i = 1, drawPickup do
		local minX = common.worldLeft + common.pickupSideInset
		local maxX = common.worldRight -  common.pickupSideInset

		local x = mRand( minX, maxX )
		local y = mRand( endY, beginY )

		local coin = newImageRect( common.layers.pickups, x, y, "images/" .. common.theme .. "/coin.png",
			                       { w = 50, h = 50, isCoin = true, fill = common.gold },
			                       { bodyType = "static", isSensor = true, radius = 22 } )
	end

	-- ==
	-- Update genY position
	-- ==
   common.player.genY = endY
end


function public.destroyMonstersNearPlayer()
	for k,v in pairs( common.monsters ) do
		local dx = mAbs(common.player.x - v.shapeX)
		local dy = mAbs(common.player.y - v.shapeY)		--
		if( dx < common.monsterDestroyDistance  and dy < common.monsterDestroyDistance ) then
			common.monsters[k] = nil
			display.remove(v)
		end
	end
end


-- ==
--    Helper to draw monsters/monsters with moving eyes.
-- ==
makeEyeMonster = function( group, y, isRight )
	group = group or display.currentStage
	local width 	= mRand( 50, 100 )
	local height 	= mRand(25,50)
	local hw 		= width/2
	local hh 		= height/2
	local offsetX 	= mRand(5,20)
	local offsetY  = { mRand(-5,5), mRand(-5,5), mRand(-5,5), mRand(-5,5) }

	local radius1 = math.floor(hh/2) + math.floor(hh/10)
	local radius2 = math.ceil(radius1/2)
	local eyeDist = radius1 - radius2 - 2

	local monster = display.newGroup()
	group:insert( monster )
	common.monsters[monster] = monster

	local shape 
	if( isRight ) then
		shape = { -hw, -hh + offsetY[1], 
		           hw, -hh + offsetY[2], 
		           hw,  hh + offsetY[3], 
		          -hw + offsetX, hh + offsetY[4] }
		x =  w - hw

	else
		shape = { -hw, -hh + offsetY[1], 
		           hw, -hh + offsetY[2], 
		           hw - offsetX, hh + offsetY[3], 
		           -hw, hh + offsetY[4] }
		x =  0 + hw
	end

	local tmp = display.newPolygon( monster, x, y, shape )
	physics.addBody( tmp, "static", { shape = shape } )
	tmp.isSensor = true
	tmp.kills = true
	tmp:setFillColor(unpack(common.currentColor))

	common.allColoredObj[tmp] = tmp

	monster.shapeX = x
	monster.shapeY = y


	local eye = newImageRect( monster, 0, 0, "images/" .. common.theme .. "/circle.png", {radius = radius1 })
	local pupil = newImageRect( monster, 0, 0, "images/" .. common.theme .. "/circle.png", { radius = radius2, fill = _K_ })

	if( isRight ) then
		eye.x = tmp.x - hw + radius1 + 2 + offsetX/2
		eye.y = tmp.y - hh + radius1 + 2 + offsetY[1]
		pupil.x = eye.x
		pupil.y = eye.y
	else
		eye.x = tmp.x + hw - radius1 - 2 - offsetX/2
		eye.y = tmp.y - hh + radius1 + 2 + offsetY[2] 
		pupil.x = eye.x
		pupil.y = eye.y
	end

	pupil.x0 = pupil.x
	pupil.y0 = pupil.y

	local igoreTime = -1000
	function pupil.enterFrame( self )
		if( not isValid( common.player ) ) then return end
		local curTime = getTimer()
		if( curTime < igoreTime ) then return end
		if( mAbs(common.player.y - self.y ) > fullh * 2 ) then 
			return 
		end

		local vec = diffVec( self, common.player )
		vec = normVec( vec )
		vec = scaleVec( vec, eyeDist)
		self.x = self.x0 + vec.x
		self.y = self.y0 + vec.y

	end; listen("enterFrame", pupil)

	
	function pupil.finalize( self )
		ignoreList( {"enterFrame"}, self)
	end; pupil:addEventListener( "finalize" )


	return monster
end

return public

