-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local function dragPlayer( event )

    local player = event.target
    local phase = event.phase

    if ( "began" == phase ) then
      -- Set touch focus on the ship
      display.currentStage:setFocus( player )
      -- Store initial offset position
      player.touchOffsetX = event.x - player.x

    elseif ( "moved" == phase ) then
      -- Move the ship to the new touch position
      player.x = event.x - player.touchOffsetX

    elseif ( "ended" == phase or "cancelled" == phase ) then
      -- Release touch focus on the ship
      display.currentStage:setFocus( nil )
    end

    return true  -- Prevents touch propagation to underlying objects
  end
  
  
  local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2
    
    if ( ( obj1.myName == "rect" and obj2.myName == "receptor" ) or
			 ( obj1.myName == "receptor" and obj2.myName == "rect" ) )
		then
      display.remove(obj1)
    end
    
    --[[

		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			-- Remove both the laser and asteroid
			display.remove( obj1 )
			display.remove( obj2 )

			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score

		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
		then
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives --concatena con la variable lives

				if ( lives == 0 ) then
					display.remove( ship )
					timer.performWithDelay( 2000, endGame )
				else
					ship.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
		end
    ]]
	end
end
  ------------------------------------------------------------------------------------

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	local crate = display.newImageRect( "crate.png", 90, 90 )
	crate.x, crate.y = 160, -100
	crate.rotation = 15
  
  -- add physics to the crate
	physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
  
  -----------------------------------------------------------------------------------
  --crea un cuadrado
  local rect = display.newImageRect( "assets/RectRed.png", 90, 90)
  rect.x, rect.y = 200, 50
  rect.myName = "rect"
  
  --Agrega evento arrastrar
  rect:addEventListener( "touch", dragPlayer)
  
  --Agrega fisica
  physics.addBody( rect, { density=1.0, friction=0.3})
  
  
  
  --crea receptor
  local receptor = display.newImageRect( "Assets/rect0.png", 90, 90)
  receptor.x, receptor.y = screenW/2, 400
  receptor.myName = "receptor"
  
  physics.addBody( receptor, "static")
  
  --------------------------------------------------------------------------------------
	

	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( grass)
	sceneGroup:insert( crate )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
    Runtime:addEventListener("collision", onCollision)
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene