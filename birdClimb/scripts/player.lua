-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local common 		= require "scripts.common"
local physics     = require "physics"
local roomM       = require "scripts.room"

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


-- =============================================================
-- Bird Image Sheets
-- =============================================================
local birdSheets = {}
local shapeSizes = {}
for i = 1, 5 do
	birdSheets[i] = graphics.newImageSheet( "images/" .. common.theme .. "/bird" .. i .. ".png", { width = 64, height = 64, numFrames = 4 } )
	shapeSizes[i] = 17	
end


local public = {}
function public.create()
	--
	-- Create bird object
	-- 
	local shapeSize = shapeSizes[persist.get( "settings.json", "currentBird" )]
	local shape = {-shapeSize, -shapeSize, shapeSize, -shapeSize, shapeSize, shapeSize, -shapeSize, shapeSize }	

	local player = newRect( common.layers.content, centerX, centerY, 
		                         --"images/rg256.png",
		                         { size = 64, moving = false, xScale = -1,
		                           highY = centerY, fpp = 7, frameCount = 0,
		                           wingFrame = 1, isPlayer = true }, 
		                         { gravityScale = 0, isFixedRotation = true, 
		                           shape = shape } )

	player.fill 	= { type = "image", sheet = birdSheets[persist.get( "settings.json", "currentBird" )], frame = 1 }
	player.highY 	= player.y
	player.genY 	= player.y - fullh/2 - 120
	common.player 	= player

	-- ==
	-- Start player moving
	-- ==
	function player.startMoving( self  )
		-- Play a sound
		post("onSound", { sound = "flap" } )

		-- Generate 'kick' vector and apply it
		self.moving = true 
		self.gravityScale = 1
		self:setLinearVelocity( -self.xScale * common.birdSpeed, 0 )
	end

	-- ==
	-- Attach an 'enterFrame' listener to player to 'higest' Y position of bird, and to flap wings.
	-- ==
	function player.enterFrame( self )
		-- ==
		-- Do nothing if game not running or in paused state
		-- ==
		if( not common.gameIsRunning or common.gameIsPaused ) then return end
		-- ==
		--   Track 'highest' position bird has reached.
		-- ==
		self.highY = self.y < self.highY and self.y or self.highY 

		-- ==
		-- Flap wings by changing image.  This technique is used to allow us to easily swap images when the
		-- user buys new bird types.
		-- ==
		if( self.moving ) then
			self.frameCount = self.frameCount + 1
			if( self.frameCount % self.fpp == 0 ) then
				local tmp = newRect( common.layers.particles, self.x + mRand( -3, 3), self.y + mRand( -3, 3), 
						             { size = self.contentWidth } )
				tmp.fill = { type = "image", sheet = birdSheets[persist.get( "settings.json", "currentBird" )], frame = 4 }
				transition.to( tmp, { xScale = 0.005, yScale = 0.005, alpha = 0,  rotation = mRand(-135,135),
					                 time = 2000, transition = easing.outQuad, onComplete = display.remove } )

				self.wingFrame = self.wingFrame + 1
				self.wingFrame = self.wingFrame > 3 and 1 or self.wingFrame
				self.fill = { type = "image", sheet = birdSheets[persist.get( "settings.json", "currentBird" )], frame = self.wingFrame }
			end
		end

	end; listen( "enterFrame", player )

	-- ==
	-- Collision listener
	-- ==
	function player.collision( self, event )
		local other = event.other
		local phase = event.phase
		if( event.phase == "began" ) then
			if( other.kills ) then
					
				-- Stop doing 'moving' work
				self.moving = false

				-- Dispatch 'onDied' event so game module can do work associated with this event
				post( "onDied" )

				-- Play a sound
				post("onSound", { sound = "gameOver" } )
				

			elseif( self.moving and other.isWall ) then 
				local vx,vy = self:getLinearVelocity()
				if( vx > 0 ) then
					self:setLinearVelocity( -common.birdSpeed, vy )
					self.xScale = 1
				else
					self:setLinearVelocity( common.birdSpeed, vy )
					self.xScale = -1
				end
			elseif( other.isCoin ) then

				-- Play a sound
				post("onSound", { sound = "coin" } )

				-- Add coin to coin count
				ssk.persist.set( "settings.json", "coins", ssk.persist.get( "settings.json", "coins") + 1 )

				-- Tell coin hud to update
				post( "onUpdateCoins" )
				
				-- Remove the coin
				display.remove(other)
			end
		end
		return true
	end; player:addEventListener( "collision" )

	-- ==
	-- Attach Camera
	-- ==
	ssk.camera.tracking( player, common.layers.world, { lockX = true }  )

	-- ==
	-- One-touch input listener
	-- ==
	function player.onOneTouch( self, event )
		-- ==
		-- Do nothing if game not running or in paused state
		-- ==
		if( not common.gameIsRunning or common.gameIsPaused ) then return end

		-- ==
		-- Only do someting on 'began'
		-- ==
		if( event.phase ~= "began" ) then return end	

		-- ==
		-- Player is moving, give it a 'kick'
		-- ==
		if( self.moving ) then 
			-- Play a sound
			post("onSound", { sound = "flap" } )

			-- Generate 'kick' vector and apply it
			local vx,vy = self:getLinearVelocity()
			self:setLinearVelocity( vx, 0 )
			self:applyLinearImpulse( 0, -common.birdKickMag * self.mass )
		end
	end
	listen( "onOneTouch", player )

	-- ==
	-- Clean up when player is destroyed
	-- ==
   function player.finalize( self )
   	player:stopCamera()
      ignoreList( { "enterFrame", "onOneTouch" }, self )
   end; player:addEventListener( "finalize" )

end

return public