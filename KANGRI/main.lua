-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")

--Oculta la barra de estado
display.setStatusBar( display.HiddenStatusBar )

-- Semilla generardor de random de numeros
math.randomseed( os.time() )


--Lleva a la pantalla menu
composer.gotoScene("Escenas.menu")
--local tapText = display.newText( "00000", display.contentCenterX, 20, native.systemFont, 40 )
--tapText:setFillColor( 100, 100, 100 )--le damos color al texto