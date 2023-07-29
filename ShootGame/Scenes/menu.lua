--Variables
local composer = require("composer")
local scene = composer.newScene()

-------------------FUNCTIONS--------------------
local function jugar()
    composer.gotoScene("Scenes.juego")
end

local function acerca()
    
end


------------------------------------------------

--create()
function scene:create(event)
  local sceneGroup = self.view
  
  local title = display.newText(sceneGroup, "Shoot Game",display.contentCenterX,100,native.systemFont, 54)
  
  local botonJugar = display.newText( sceneGroup, "Play", display.contentCenterX, 300, native.systemFont, 44 )
  botonJugar:setFillColor( 0, 0.5, 0 )
 
  local botonAcerca = display.newText( sceneGroup, "About", display.contentCenterX, 350, native.systemFont, 44 )
  botonAcerca:setFillColor( 0, 100, 0 )
  
  botonJugar:addEventListener( "tap", jugar ) --llama a la funcion gotoGame
  botonAcerca:addEventListener( "tap", acerca )
  
end





-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

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