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
physics.setGravity( 0, 9.8)
--physics.setDrawMode("hybrid")--test colision

--////////////////////////////////////////////////////////////////////////////////
-- Configurar hoja de imagen
local sheetOptions =
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

local player--ship
local statePlayer = "move"
local posVerticalPlayer = display.contentHeight - 100
--local imagePlayer = 4

local cangrejoAmarillo
local cangrejoAzul
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

local audio2 = audio.loadSound("Sound/soundBack2.wav")
local audioPlay2

--TEST
local stateText
local positionText

------------




--//////////////////////////////////////////////////////////////////////////////////////////////////
--FUNCIONES-------------------
--[[
local function updateText()
	--livesText.text = "Lives: " .. lives
	--scoreText.text = "Score: " .. score
  
  stateText.text = "STATE: " .. statePlayer
  positionText.text = "POSITION: " .. player.y
end
]]

local function crearCaparazones()

	local nuevoCaparazon = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	table.insert( caparazonesTable, nuevoCaparazon )
	physics.addBody( nuevoCaparazon, "dynamic", { radius=30, bounce=0.8, isSensor = true} )
	nuevoCaparazon.myName ="caparazon"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
		nuevoCaparazon.x = -60
		nuevoCaparazon.y = math.random( 60,80 )
		--nuevoCaparazon:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    nuevoCaparazon:setLinearVelocity( math.random( 60,520 ), 0)
	elseif ( whereFrom == 2 ) then
		-- From the top
		nuevoCaparazon.x = display.contentWidth/2--math.random( display.contentWidth )
		nuevoCaparazon.y = -60
		--nuevoCaparazon:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    nuevoCaparazon:setLinearVelocity( math.random( -100,100 ), math.random( 130,140 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		nuevoCaparazon.x = display.contentWidth + 60
		nuevoCaparazon.y = math.random( 60,80 )
		--nuevoCaparazon:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    nuevoCaparazon:setLinearVelocity( math.random( -520,-60 ), 0 )
	end

	nuevoCaparazon:applyTorque( math.random( -6,6 ) )
end

local function crearCaparazonAmarillo()
	local nuevoCaparazonAmarillo = display.newImageRect( mainGroup, objectSheet2, 1, 102, 85 )
	table.insert( amarilloTable, nuevoCaparazonAmarillo )
	physics.addBody( nuevoCaparazonAmarillo, "dynamic", { radius=30, bounce=0.8 } )
	nuevoCaparazonAmarillo.myName ="nuevoCaparazonAmarillo"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
		nuevoCaparazonAmarillo.x = -60
		nuevoCaparazonAmarillo.y = math.random( 60,80 )
		--nuevoCaparazonAmarillo:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    nuevoCaparazonAmarillo:setLinearVelocity( math.random( 60,520 ), 0 )
	elseif ( whereFrom == 2 ) then
		-- From the top
		nuevoCaparazonAmarillo.x = display.contentWidth/2--math.random( display.contentWidth )
		nuevoCaparazonAmarillo.y = -60
		--nuevoCaparazonAmarillo:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    nuevoCaparazonAmarillo:setLinearVelocity( math.random( -100,100 ), math.random( 130,140 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		nuevoCaparazonAmarillo.x = display.contentWidth + 60
		nuevoCaparazonAmarillo.y = math.random( 60,80 )
		--nuevoCaparazonAmarillo:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    nuevoCaparazonAmarillo:setLinearVelocity( math.random( -520,-60 ), 0 )
	end

	nuevoCaparazonAmarillo:applyTorque( math.random( -6,6 ) )
end


local function crearCaparazonAzul()

	local nuevoCaparazonAzul = display.newImageRect( mainGroup, objectSheet3, 1, 102, 85 )
	table.insert( azulTable, nuevoCaparazonAzul )
	physics.addBody( nuevoCaparazonAzul, "dynamic", { radius=30, bounce=0.8 } )
	nuevoCaparazonAzul.myName ="nuevoCaparazonAzul"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
		nuevoCaparazonAzul.x = -60
		nuevoCaparazonAzul.y = math.random( 60,80 )
		--nuevoCaparazonAzul:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    nuevoCaparazonAzul:setLinearVelocity( math.random( 60,520 ), 0 )
	elseif ( whereFrom == 2 ) then
		-- From the top
		nuevoCaparazonAzul.x = display.contentWidth/2--math.random( display.contentWidth )
		nuevoCaparazonAzul.y = -60
		--nuevoCaparazonAzul:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    nuevoCaparazonAzul:setLinearVelocity( math.random( -100,100 ), math.random( 130,140 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		nuevoCaparazonAzul.x = display.contentWidth + 60
		nuevoCaparazonAzul.y = math.random( 60,80 )
		--nuevoCaparazonAzul:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    nuevoCaparazonAzul:setLinearVelocity( math.random( -520,-60 ), 0)
	end

	nuevoCaparazonAzul:applyTorque( math.random( -6,6 ) )
end




local function disparo()
  --if(statePlayer == "move")then
  --SE COMFIGURO LA GRAVEDAD AL INICIO DEL CODIGO
  player:applyLinearImpulse(0,-0.75, player.x, player.y)
  --end
  
  
  --[[
	local nuevoDisparo = display.newImageRect( mainGroup, objectSheet,0, 32, 32 )
	physics.addBody( nuevoDisparo, "dynamic", { isSensor=true } )
	nuevoDisparo.isBullet = true
	nuevoDisparo.myName = "nuevoDisparo"

	nuevoDisparo.x = player.x
	nuevoDisparo.y = player.y
	nuevoDisparo:toBack()

	transition.to( nuevoDisparo, { y=-40, time=500,
		onComplete = function() display.remove( nuevoDisparo ) end
	} )
  ]]
end

local function arrastrarPlayer( event )

	local player = event.target
	local phase = event.phase

	if ( "began" == phase ) then
		-- Establecer enfoque táctil en el jugador
		display.currentStage:setFocus( player )
		-- Almacenar la posición de compensación inicial
		player.touchOffsetX = event.x - player.x
   -- player.touchOffsetY = event.y - player.y

	elseif ( "moved" == phase ) then
		-- Mueva el jugador a la nueva posición táctil
		player.x = event.x - player.touchOffsetX
    --player.y = event.y - player.touchOffsetY

	elseif ( "ended" == phase or "cancelled" == phase ) then
		-- Suelta el enfoque táctil en el jugador
		display.currentStage:setFocus( nil )
	end

	return true  -- Evita la propagación del tacto a los objetos subyacentes.
end





local function gameLoop()

  --updateText()--Actualiza TxtTEST
  
  
	-- Create cangrejos
	crearCaparazones()
  
	-- Elimina los caparazones que se han salido de la pantalla
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
  
  --crearCaparazonAmarillo()
  
  --Eliminar si sale de los limites
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
  
  
  crearCaparazonAzul()
  
  --Eliminar si sale de los limites
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
	player.y = posVerticalPlayer--display.contentHeight - 80

	-- Fade in the ship
	transition.to( player, { alpha=1, time=4000,onComplete = function()
			player.isBodyActive = true
			died = false
		end
	} )
end

--------------END GAME----------------------------------------------------------
local function endGame()
	composer.gotoScene( "Escenas.menu", { time=800, effect="crossFade" } )
end

--//////////////////////////////////////////////////////////////////////////////////////




--------------------COLLISION-----------------------------------------------------
local function onCollision( event )

	if ( event.phase == "began" ) then--began ==> comenzo

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
		elseif ( ( obj1.myName == "player" and obj2.myName == "nuevoCaparazonAmarillo" )or
              ( obj1.myName == "nuevoCaparazonAmarillo" and obj2.myName == "player" ))
		then
      player:setLinearVelocity(0,80)
      --player:applyLinearImpulse(0,0.75, player.x, player.y)
      
      -- Remueve ambos objetos
			--display.remove( obj1 )
			--display.remove(obj2)
      
      
      for i = #amarilloTable, 1, -1 do
				if ( amarilloTable[i] == obj1 or amarilloTable[i] == obj2 ) then
					table.remove( amarilloTable, i )
					break
				end
			end
      
      
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1--resta una vida por cada colision
				livesText.text = "Lives: " .. lives --concatena con la variable lives

        --[[Si la vida llega a cero entonces fin del juego de lo
            contrario restaura a player en su posicion inicial]]
				if ( lives == 0 ) then
					display.remove( player )
					timer.performWithDelay( 2000, endGame )
				else
					player.alpha = 0
					timer.performWithDelay( 1000, restauraPlayer )
				end
			end
     
     --Colision con cangrejo azul---------------------------------------------
		elseif ( ( obj1.myName == "player" and obj2.myName == "nuevoCaparazonAzul" ))-- or
              --( obj1.myName == "nuevoCaparazonAzul" and obj2.myName == "player" ))
		then
      player:setLinearVelocity(0,80)
      --player:applyLinearImpulse(0,0.75, player.x, player.y)
      
      -- Remueve ambos objetos
			--display.remove( obj1 )
			display.remove( obj2 )
      
      for i = #azulTable, 1, -1 do
				if ( azulTable[i] == obj1 or azulTable[i] == obj2 ) then
					table.remove( azulTable, i )
					break
				end
			end
      
      
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
        
        
        
				-- Update score
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


--------------LIMITES CANGREJO
local function limitesCangrejo()
  --player.x < -50 or player.x > display.contentWidth + 50 or
       --player.y < -50 or player.y > display.contentHeight + 50
  if (player.x < -50 or player.x > display.contentWidth + 50 or
       player.y < -50 or player.y > display.contentHeight + 50 )
  then
    if ( died == false ) then
      died = true
          
          
          
      -- Update score
      --score = score + 10
      --scoreText.text = "Score: " .. score --concatena con la variable score
      
      -- Update lives
      lives = lives - 1
      livesText.text = "Lives: " .. lives --concatena con la variable lives
          
          

      if ( lives == 0 ) then
        display.remove( player )
        timer.performWithDelay( 1000, endGame )
      else
        player.alpha = 0
        timer.performWithDelay( 1000, restauraPlayer )
      end
    end 
  end
end
--////////////////////////////////////////////////////////////////////////////////////////


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
  
  
  --Plataforma
  local platform = display.newImageRect( "Assets/Tablero.png", 300, 50 )
  platform.x = display.contentCenterX
  platform.y = display.contentHeight-25
  physics.addBody( platform, "static" )
  platform.myName = "platform"
  
  --Plataforma izquierda
  local platformI = display.newImageRect( "Assets/Tablero.png", 40, 80 )
  platformI.x = display.contentCenterX - 160
  platformI.y = display.contentHeight-100
  physics.addBody( platformI, "static" )
  platformI.myName = "platformI"
  
  --Plataforma derecha
  local platformD = display.newImageRect( "Assets/Tablero.png", 40, 80 )
  platformD.x = display.contentCenterX + 160
  platformD.y = display.contentHeight-100
  physics.addBody( platformD, "static" )
  platformD.myName = "platformD"
  
  --Player se crea a partir de una hoja de imagenes llamada objectSheet
  local imagePlayer = 3
  player = display.newImageRect( mainGroup, objectSheet, imagePlayer , 96, 126 )
	player.x = display.contentCenterX
	player.y = posVerticalPlayer--display.contentHeight - 80
	physics.addBody( player, "dynamic",{ radius = 45, isSensor = false, bounce=0.3 } )
	player.myName = "player"
  
  --algunos parametros de fisica---------------
  --density
  --friccion
  --bounce
  --radius
  --isSensor
  ------------------------------------------
  
  --SE CONFIGURO LA GRAVEDAD AL INICIO DEL CODIGO
  --if (statePlayer == "move")then
  player:addEventListener( "tap", disparo)--Dispara llamando a la funcion disparo
  --end
  player:addEventListener("touch", arrastrarPlayer )--Ejecuta la funcion arrastrarPLayer
  
  
  --[[
  --cangrejo amarillo
  cangrejoAmarillo = display.newImageRect(mainGroup, objectSheet2, 3, 96,126)
  cangrejoAmarillo.x = display.contentCenterX - 60
  cangrejoAmarillo.y = display.contentHeight - 80
  physics.addBody( cangrejoAmarillo, { radius = 45, isSensor = false, bounce=0.3})
  cangrejoAmarillo.myName = "cangrejoAmarillo"
  
  --cangrejo azul
  cangrejoAzul = display.newImageRect(mainGroup, objectSheet3, 3, 96,126)
  cangrejoAzul.x = display.contentCenterX + 60
  cangrejoAzul.y = display.contentHeight - 80
  physics.addBody( cangrejoAzul, { radius = 45, isSensor = false, bounce=0.3})
  cangrejoAzul.myName = "cangrejoAzul"
  ]]
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
  
  
  -- Display TEST---------
  stateText = display.newText( uiGroup, "ESTADO: ".. statePlayer, 60,20, native.systemFont, 15)
  stateText:setFillColor(0,0,0)
  positionText = display.newText( uiGroup, "POSITION: ".. player.y, 260,20, native.systemFont, 15)
  positionText:setFillColor(0,0,0)
  
  -----------------------------------
  
  --SOUND
  audioPlay2 = audio.play(audio2,{loops=-1, channel=2})--Usar -1 para reproducir infinitamente

  --audio.pause(audioPlay2)--Pausar canal de sonido o variable donde se almacena
  --audio.resume(2)--Continuar reproduccion
  --audio.stop(audioPlay2)--Detener sonido
  
  
  -----------------------------------------
  
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
  local retraso = 2300
  local iteraciones = 0

	if ( phase == "will" ) then
		-- El código aquí se ejecuta cuando la escena aún está fuera de la 
    -- pantalla (pero está a punto de aparecer en la pantalla)

	elseif ( phase == "did" ) then
		-- El código aquí se ejecuta cuando la escena está completamente en pantalla
    physics.start()
		Runtime:addEventListener( "collision", onCollision )
    --Runtime:addEventListener( "touch", limitesCangrejo)
		gameLoopTimer = timer.performWithDelay( retraso, gameLoop, iteraciones )--controla  creacion de caparazones
    loopLimite = timer.performWithDelay( 1500, limitesCangrejo, 0)

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel( gameLoopTimer )
    timer.cancel( loopLimite )--cancelamos el timer para limiteCaparazon


	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		composer.removeScene( "Escenas.game" )
    audio.stop(audioPlay2)
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



