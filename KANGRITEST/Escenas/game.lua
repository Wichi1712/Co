local composer = require( "composer" )
local scene = composer.newScene()

-- ---------------------------------------------------------------------------------
-- El código fuera de las funciones de eventos de escena a continuación solo se 
-- ejecutará UNA VEZ a menos que la escena se elimina por completo (no se recicla) a 
-- través de "composer.removeScene ()"
-- ---------------------------------------------------------------------------------

--Fisicas
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

--////////////////////////////////////////////////////////////////////////////////
-- Configurar hoja de imagen
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 2) asteroid 2
            x = 32,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 3) asteroid 3
            x = 64,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 4) ship
            x = 96,
            y = 0,
            width = 32,
            height = 42
        },
    },
}
local objectSheet = graphics.newImageSheet( "Assets/cangrejo.png", sheetOptions )

local sheetOptions2 =
{
    frames =
    {
        {   -- 1) caparazon
            x = 0,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 2) cangrejo 1
            x = 32,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 3) cangrejo 2
            x = 64,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 4) cangrejo 3
            x = 96,
            y = 0,
            width = 32,
            height = 42
        },
    },
}
local objectSheet2 = graphics.newImageSheet( "Assets/cangriYellow.png", sheetOptions2 )


local sheetOptions3 =
{
    frames =
    {
        {   -- 1) caparazon
            x = 0,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 2) cangrejo 1
            x = 32,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 3) cangrejo 2
            x = 64,
            y = 0,
            width = 32,
            height = 42
        },
        {   -- 4) cangrejo 3
            x = 96,
            y = 0,
            width = 32,
            height = 42
        },
    },
}
local objectSheet3 = graphics.newImageSheet( "Assets/cangriBlue.png", sheetOptions3 )

--////////////////////////////////////////////////////////////////////////////////////////////////


-- Inicializa variables
local lives = 3
local score = 0
--local tapCount = 0
local died = false

local caparazonesTable = {}
local amarilloTable = {}
local azulTable = {}

local player
local cangrejoAmarillo
local cangrejoAzul
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup




--//////////////////////////////////////////////////////////////////////////////////////////////////
--FUNCIONES-------------------

local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end


--INICIO DE FUNCIONES PARA CREAR CAPARAZONES---------------------------
local function crearCaparazones()

	local nuevoCaparazon = display.newImageRect( mainGroup, objectSheet3, 1, 102, 85 )
	table.insert( caparazonesTable, nuevoCaparazon )
	physics.addBody( nuevoCaparazon, "dynamic", { radius=40, bounce=0.8 } )
	nuevoCaparazon.myName ="caparazon"

	local whereFrom = math.random( 3 )
  --Crea caparazones en posiciones aleatorias sea arriba derecha o izquierda
	if ( whereFrom == 1 ) then
		-- From the left
		nuevoCaparazon.x = -60
		nuevoCaparazon.y = math.random( 500 )
		nuevoCaparazon:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		nuevoCaparazon.x = math.random( display.contentWidth )
		nuevoCaparazon.y = -60
		nuevoCaparazon:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		nuevoCaparazon.x = display.contentWidth + 60
		nuevoCaparazon.y = math.random( 500 )
		nuevoCaparazon:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	nuevoCaparazon:applyTorque( math.random( -6,6 ) )
end

local function crearCangrejosAmarillos()
	local nuevoCangrejoAmarillo = display.newImageRect( mainGroup, objectSheet2, 1, 102, 85 )
	table.insert( amarilloTable, nuevoCangrejoAmarillo )
	physics.addBody( nuevoCangrejoAmarillo, "dynamic", { radius=40, bounce=0.8 } )
	nuevoCangrejoAmarillo.myName ="nuevoCangrejoAmarillo"

	local whereFrom = math.random( 3 )
  --Crea caparazones en posiciones aleatorias sea arriba derecha o izquierda
	if ( whereFrom == 1 ) then
		-- From the left
		nuevoCangrejoAmarillo.x = -60
		nuevoCangrejoAmarillo.y = math.random( 500 )
		nuevoCangrejoAmarillo:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		nuevoCangrejoAmarillo.x = math.random( display.contentWidth )
		nuevoCangrejoAmarillo.y = -60
		nuevoCangrejoAmarillo:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		nuevoCangrejoAmarillo.x = display.contentWidth + 60
		nuevoCangrejoAmarillo.y = math.random( 500 )
		nuevoCangrejoAmarillo:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	nuevoCangrejoAmarillo:applyTorque( math.random( -6,6 ) )
end


local function crearCangrejosAzules()
	local nuevoCangrejoAzul = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	table.insert( azulTable, nuevoCangrejoAzul )
	physics.addBody( nuevoCangrejoAzul, "dynamic", { radius=40, bounce=0.8 } )
	nuevoCangrejoAzul.myName ="nuevoCangrejoAzul"

	local whereFrom = math.random( 3 )
  --Crea caparazones en posiciones aleatorias sea arriba derecha o izquierda
	if ( whereFrom == 1 ) then
		-- From the left
		nuevoCangrejoAzul.x = -60
		nuevoCangrejoAzul.y = math.random( 500 )
		nuevoCangrejoAzul:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		nuevoCangrejoAzul.x = math.random( display.contentWidth )
		nuevoCangrejoAzul.y = -60
		nuevoCangrejoAzul:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		nuevoCangrejoAzul.x = display.contentWidth + 60
		nuevoCangrejoAzul.y = math.random( 500 )
		nuevoCangrejoAzul:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	nuevoCangrejoAzul:applyTorque( math.random( -6,6 ) )
end

--FIN DE CREAR CAPARAZONES------------------------------------------------


local function disparo()

	local nuevoDisparo = display.newImageRect( mainGroup, objectSheet,0, 32, 32 )
	physics.addBody( nuevoDisparo, "dynamic", { isSensor=true } )
	nuevoDisparo.isBullet = true
	nuevoDisparo.myName = "nuevoDisparo"

	nuevoDisparo.x = player.x
	nuevoDisparo.y = player.y
	nuevoDisparo:toBack()--mueve los objetos de destino a la parte posterior visual de su grupo principal (object.parent).

  --[[transition.to(target,params)
    Elimina el disparo despues de un cierto tiempo
  ]]
	transition.to( nuevoDisparo, { y=-40, time=500,
		onComplete = function() display.remove( nuevoDisparo ) end
	} )
end

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


local function gameLoop()

	-- Crear cangrejos
	crearCaparazones()
  
	-- Elimina los caparazones que se han salido de la pantalla.
	for i = #caparazonesTable, 1, -1 do
		local thisAsteroid = caparazonesTable[i]

		if ( thisAsteroid.x < -100 or
			 thisAsteroid.x > display.contentWidth + 100 or
			 thisAsteroid.y < -100 or
			 thisAsteroid.y > display.contentHeight + 100 )
		then
			display.remove( thisAsteroid )
			table.remove( caparazonesTable, i )
		end
	end
  
  crearCangrejosAmarillos()
  for i = #amarilloTable, 1, -1 do
		local thisAmarillo = amarilloTable[i]

		if ( thisAmarillo.x < -100 or
			 thisAmarillo.x > display.contentWidth + 100 or
			 thisAmarillo.y < -100 or
			 thisAmarillo.y > display.contentHeight + 100 )
		then
			display.remove( thisAmarillo )
			table.remove( amarilloTable, i )
		end
	end
  
  
  crearCangrejosAzules()
  for i = #azulTable, 1, -1 do
		local thisAzul = azulTable[i]

		if ( thisAzul.x < -100 or
			 thisAzul.x > display.contentWidth + 100 or
			 thisAzul.y < -100 or
			 thisAzul.y > display.contentHeight + 100 )
		then
			display.remove( thisAzul )
			table.remove( azulTable, i )
		end
	end
  
  
end


local function restauraPlayer()

	player.isBodyActive = false
	player.x = display.contentCenterX
	player.y = display.contentHeight - 100

	-- Desvanecimiento de player
	transition.to( player, { alpha=1, time=4000,
		onComplete = function()
			player.isBodyActive = true
			died = false
		end
	} )
end


local function endGame()
	composer.gotoScene( "Escenas.menu", { time=800, effect="crossFade" } )
end

--Inicio de colisiones-----------------
local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2
    --Colision con disparo----------------------------------------------------------
    
		if ( ( obj1.myName == "nuevoDisparo" and obj2.myName == "cangrejoAzul" ) or
			   ( obj1.myName == "cangrejoAzul" and obj2.myName == "nuevoDisparo" ))
		then
			-- Remove both the laser and asteroid
			--display.remove( obj1 )
			--display.remove( obj2 )

			--for i = #caparazonesTable, 1, -1 do
				--if ( caparazonesTable[i] == obj1 or caparazonesTable[i] == obj2 ) then
					--table.remove( caparazonesTable, i )
					--break
				--end
			--end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score
    --Colision con cangrejo amarillo---------------------------------------------
		elseif ( ( obj1.myName == "player" and obj2.myName == "cangrejoAmarillo" ) or
              ( obj1.myName == "cangrejoAmarillo" and obj2.myName == "player" )) or
           (( obj1.myName == "player" and obj2.myName == "cangrejoAzul" ) or
              ( obj1.myName == "cangrejoAzul" and obj2.myName == "player"))
		then
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives --concatena con la variable lives

				if ( lives == 0 ) then
					display.remove( player )
					timer.performWithDelay( 2000, endGame )
				else
					player.alpha = 0
					timer.performWithDelay( 1000, restauraPlayer )
				end
			end
      ---------------------------
    elseif (( obj1.myName == "player" and obj2.myName == "caparazon" ) or
            ( obj1.myName == "caparazon" and obj2.myName == "player" ))
    then
			--if ( died == false ) then
				--died = true

				-- Update lives
				score = score + 10
				scoreText.text = "Score: " .. score --concatena con la variable score
        
        display.remove(obj2)
        
        for i = #caparazonesTable, 1, -1 do
          if ( caparazonesTable[i] == obj1 or caparazonesTable[i] == obj2 ) then
            table.remove( caparazonesTable, i )
            break
          end
        end
        
        

				--[[if ( lives == 0 ) then
					display.remove( player )
					timer.performWithDelay( 2000, endGame )
				else
					player.alpha = 0
					timer.performWithDelay( 1000, restoreCangrejo )
				end]]
			--end 
      ---------------------------
		end
	end
end


--Fin de colisiones----------------------


--/////////////////////////////////////////////////////////////////////////////////////////////////
--create()
function scene:create(event)
  local sceneGroup = self.view
  
  physics.pause()  -- Pausar temporalmente el motor de física
  
  -- Configurar grupos de visualización
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
  
  -- Carga imagen de fondo
  local fondo = display.newImage(backGroup,"Assets/playa.png")
  fondo.x = display.contentCenterX
  fondo.y = display.contentCenterY
  
  
  --Player
  player = display.newImageRect( mainGroup, objectSheet, 2, 96, 126 )
	player.x = display.contentCenterX
	player.y = display.contentHeight - 100
	physics.addBody( player, { radius = 30, isSensor = true } )
	player.myName = "player"
  
  player:addEventListener( "tap", disparo)--Dispara llamando a la funcion disparo
  player:addEventListener("touch", arrastrarPlayer )--Ejecuta la funcion arrastrarPLayer
  
  
  --cangrejo amarillo
  cangrejoAmarillo = display.newImageRect(mainGroup, objectSheet2, 3, 98,79)
  cangrejoAmarillo.x = display.contentCenterX
  cangrejoAmarillo.y = display.contentCenterY
  physics.addBody( cangrejoAmarillo, { radius = 30, isSensor = true})
  cangrejoAmarillo.myName = "cangrejoAmarillo"
  
  --cangrejo azul
  cangrejoAzul = display.newImageRect(mainGroup, objectSheet3, 3, 96,126)
  cangrejoAzul.x = display.contentCenterX
  cangrejoAzul.y = display.contentCenterY - 200
  physics.addBody( cangrejoAzul, { radius = 30, isSensor = true})
  cangrejoAzul.myName = "cangrejoAzul"
  --cangrejoAzul:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )--Movimiento
  --cangrejoAzul:applyTorque( math.random( -2,2 ) )--rotacion
  --[[
  if ( cangrejoAzul.x > display.contentWidth or cangrejoAzul.x < 0) then
    cangrejoAzul.x = cangrejoAzul.x
  elseif(cangrejoAzul.y > display.contentHeight or cangrejoAzul.y < 0)then
    cangrejoAzul.y = cangrejoAzul.y
  end]]
  
  
  -- Display lives and score
	livesText = display.newText( uiGroup, "Lives: " .. lives, 60, 2, native.systemFont, 25 )
  livesText:setFillColor( 0, 0, 0 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 260, 2, native.systemFont, 25 )
  scoreText:setFillColor( 0, 0, 0)
  
  --ship:addEventListener( "tap", fireLaser )
	--ship:addEventListener( "touch", dragShip )
  
--  --audio.play(sonido)
  
--  local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 300, native.systemFont, 44 )
--  playButton:setFillColor( 0, 0, 0 )
 
--  local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 350, native.systemFont, 44 )
--  highScoresButton:setFillColor( 0, 0, 0 )
  
--  playButton:addEventListener( "tap", gotoGame )
--  highScoresButton:addEventListener( "tap", gotoHighScores )
  
end





-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
  local retraso = 1500
  local iteraciones = 0

	if ( phase == "will" ) then
		-- El código aquí se ejecuta cuando la escena aún está fuera de la 
    -- pantalla (pero está a punto de aparecer en la pantalla)

	elseif ( phase == "did" ) then
		-- El código aquí se ejecuta cuando la escena está completamente en pantalla
    physics.start()
		Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( retraso, gameLoop, iteraciones )--controla  creacion de caparazones

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		composer.removeScene( "Escenas.game" )

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- Oyentes de funciones de eventos de escena
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

--turtleBall:addEventListener( "tap", pushBall )


return scene



