local composer = require("composer")
local scene = composer.newScene()

local fisica = require("physics")
fisica.start()
fisica.setGravity(0,0)

--Variables
local CENTRO_X = display.contentCenterX
local CENTRO_Y = display.contentCenterY
local tamanoText = 20

local dron--player
local enemy--enemigo

local grupoPrincipal


--FUNCIONES-------------------------------------------------------------
local function arrastrarPlayer( event )

	local player = event.target
	local phase = event.phase

	if ( "began" == phase ) then
		-- Establecer enfoque táctil en el jugador
		display.currentStage:setFocus( player )
		-- Almacenar la posición de compensación inicial
		player.touchOffsetX = event.x - player.x
    player.touchOffsetY = event.y - player.y

	elseif ( "moved" == phase ) then
		-- Mueva el jugador a la nueva posición táctil
		player.x = event.x - player.touchOffsetX
    player.y = event.y - player.touchOffsetY

	elseif ( "ended" == phase or "cancelled" == phase ) then
		-- Suelta el enfoque táctil en el jugador
		display.currentStage:setFocus( nil )
	end

	return true  -- Evita la propagación del tacto a los objetos subyacentes.
end



local function disparo()

	local nuevoDisparo = display.newImageRect( grupoPrincipal, "Assets/neo.png", 32, 32 )
	fisica.addBody( nuevoDisparo, "dynamic", { isSensor=true } )
	nuevoDisparo.isBullet = true
	nuevoDisparo.myName = "nuevoDisparo"

	nuevoDisparo.x = dron.x
	nuevoDisparo.y = dron.y
  --nuevoDisparo:rotate(30)
	nuevoDisparo:toBack()

	transition.to( nuevoDisparo, { y=-30, time=800,
		onComplete = function() display.remove( nuevoDisparo ) end
	} )
end
------------------------------------------------------------------------


--create()
function scene:create(event)
  local sceneGroup = self.view
  
  --GRUPOS
  grupoPrincipal = display.newGroup()
  sceneGroup:insert(grupoPrincipal)
  
  --OBJETOS
  --text
  local txt = display.newText(grupoPrincipal,"Texto de prueba", CENTRO_X, CENTRO_Y,native.systemFont,tamanoText)
  
  --player
  dron = display.newImageRect(sceneGroup,"Assets/dron.png",32,32)
  dron.x = CENTRO_X
  dron.y = CENTRO_Y + 250
  --dron:setFillColor(0,0.5,1)
  
  dron:addEventListener("touch", arrastrarPlayer)
  dron:addEventListener("tap", disparo)
  
  --enemy
  enemy = display.newImageRect(grupoPrincipal,"Assets/canion.png",32,32)
  enemy.x = CENTRO_X
  enemy.y = CENTRO_Y
  
end



-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
    --El código aquí se ejecuta cuando la escena aún está fuera de la pantalla (pero está a punto de aparecer en la pantalla)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)



return scene