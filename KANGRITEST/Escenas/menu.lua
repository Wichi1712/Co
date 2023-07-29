local composer = require("composer")
local scene = composer.newScene()


--[[------------SONIDOS----------------------------------------


Canales de reproducción
Los canales de reproducción sirven para mantener diferentes hilos de reproducción, por ejemplo:

Un canal puede ser la música de fondo
Un canal puede ser el efecto al tomar un objeto
Un canal puede ser el sonido de un enemigo
Un canal el efecto de caminar
Los canales sirven principalmente para mantener diferentes sonidos en reproducción y poderlos manejar de forma fácil.

]]
local audio1 = audio.loadSound("Sound/soundBack.wav")
local audioPlay = audio.play(audio1,{loops=1, channel=2})

--audioPlay = audio.play(audio1,{loops=1, channel=2})--Usar -1 para reproducir infinitamente

audio.pause(audioPlay)--Pausar canal de sonido o variable donde se almacena
audio.resume(2)--Continuar reproduccion
audio.stop(audioPlay)--Detener sonido
--/--------------------------------------------------------------------

local function gotoGame()
  composer.gotoScene("Escenas.game")
end

local function gotoOtherSCene()
    composer.gotoScene("Escenas.other")
end



--/////////////////////////////////////////////

--Create()
function scene:create(event)
    local sceneGroup = self.view
    
    --Dibuja imagen de fondo
    local imageFondo = display.newImage(sceneGroup, "Assets/playa.png")
    imageFondo.x = display.contentCenterX
    imageFondo.y = display.contentCenterY
    
    --Dibuja imagen de titulo
    local title = display.newImageRect( sceneGroup,"Assets/titulo.png", 300,100)
    title.x = display.contentCenterX
    title.y = 150
    
    local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 300, native.systemFont, 44 )
    playButton:setFillColor( 0, 0, 0 )
  
  
    local otherButton = display.newText( sceneGroup, "High Scores", display.contentCenterX,350, native.systemFont,44)
  otherButton:setFillColor( 0, 0, 0 )
  
  playButton:addEventListener( "tap", gotoGame ) --llama a la funcion gotoGame
  otherButton:addEventListener( "tap", gotoOtherSCene )
  
end


--show()
function scene:show(event)
    local sceneGroup = self.view
    local phase  = event.phase
    
    if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

    end
  
  
end



-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase  = event.phase

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