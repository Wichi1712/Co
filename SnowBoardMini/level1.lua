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

local blanco = 0.9;
local arbol, casa, poste
local gravedad = -2;
local ANCHO = display.contentWidth
local ALTO = display.contentHeight
--local nuevoObstaculo
local obstaculosTable = {}

--===========================================================================
local function creaObstaculos()

	local nuevoObstaculo = display.newImageRect("Assets/arbol.png", 64,64 )
	table.insert( obstaculosTable, nuevoObstaculo )
	physics.addBody( nuevoObstaculo, "dynamic", { radius=30, bounce=0.8, isSensor = true} )
	nuevoObstaculo.myName ="obstaculo"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
    --nuevoObstaculo = display.newImageRect("Assets/arbol.png", 64,64 )
    --table.insert( obstaculosTable, nuevoObstaculo )
		nuevoObstaculo.x = -60
		nuevoObstaculo.y = math.random( 60,80 )
		--nuevoCaparazon:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    nuevoObstaculo:setLinearVelocity( math.random( 60,520 ), 0)
	elseif ( whereFrom == 2 ) then
		-- From the top
    --nuevoObstaculo = display.newImageRect("Assets/arbol.png", 64,64 )
    --table.insert( obstaculosTable, nuevoObstaculo )
		nuevoObstaculo.x = display.contentWidth/2--math.random( display.contentWidth )
		nuevoObstaculo.y = -60
		--nuevoCaparazon:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    nuevoObstaculo:setLinearVelocity( math.random( -100,100 ), math.random( 130,140 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
    --nuevoObstaculo = display.newImageRect("Assets/arbol.png", 64,64 )
    --table.insert( obstaculosTable, nuevoObstaculo )
		nuevoObstaculo.x = display.contentWidth + 60
		nuevoObstaculo.y = math.random( 60,80 )
		--nuevoCaparazon:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    nuevoObstaculo:setLinearVelocity( math.random( -520,-60 ), 0 )
	end

  --table.insert( obstaculosTable, nuevoObstaculo )
	--nuevoObstaculo:applyTorque( math.random( -6,6 ) )--aplica rotacion
end
--==========================================================================

local function mueveObstaculos()
    --velocidad = velocidad - gravedad
    --print(velocidad)
    print(gravedad)
    
    arbol.y = arbol.y - gravedad
    casa.y = casa.y - gravedad
    poste.y = poste.y - gravedad
    
    --Vuelve a la parte superior de la pantalla si llega al borde inferior
    if (arbol.y > ALTO) then
      arbol.y = math.random(-200,-10)
      arbol.x = math.random(10,ANCHO - 10)
    elseif (casa.y > ALTO) then
      casa.y = math.random(-800,-10)
      casa.x = math.random(10,ANCHO -10)
    elseif (poste.y > ALTO) then
      poste.y = math.random(-100,-10)
      poste.x = math.random(10,ANCHO -10)
    end
end

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

local function actualiza()
  mueveObstaculos();
  creaObstaculos();
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	--physics.pause()


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( blanco )
	
	-- make a crate (off-screen), position it, and rotate slightly
  --Creando un arbol
	arbol = display.newImageRect( "Assets/arbol.png", 64, 64 )
	--arbol.x = math.random(10,ANCHO)
  arbol.y = 100
	--crate.rotation = 15
	
	-- Agregando fisicas al arbol
	--physics.addBody( arbol, { density=1.0, friction=0.3, bounce=0.0 } )
	
  --Creando la casa
  casa = display.newImageRect("Assets/casa.png",64,90);
  casa.x = 60;
  casa.y = 50;
  
  --physics.addBody(casa, { density=1.0, friction=0.3, bounce=0.0 });
  
  --Creando el poste
  poste = display.newImageRect("Assets/poste.png",16,32);
  poste.x = 260;
  poste.y = 50;
  
  --physics.addBody(poste, { density=1.0, friction=0.3, bounce=0.0 });
  
  
  --Creando al personaje
  local player = display.newImageRect("Assets/player_1.png",32,32);
  player.x = screenW/2
  player.y = 450;
  
  
  
  player:addEventListener( "touch", dragPlayer )
  
  --////////////////////////////////////////////////////////////////////////////////
  --[[
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
  
  ]]
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	--sceneGroup:insert( grass)
	sceneGroup:insert( arbol )
  sceneGroup:insert(casa)
  sceneGroup:insert(player)
  sceneGroup:insert(poste)
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
		--physics.start()
    
    Runtime:addEventListener("enterFrame", actualiza);
    
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