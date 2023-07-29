-- Comentario
--[[Comentario multiples
    lineas
]]



local composer = require("composer")

--Oculta la barra de estado
display.setStatusBar( display.HiddenStatusBar )

-- Semilla generador de random de numeros
math.randomseed( os.time() )


--Lleva a la pantalla menu
composer.gotoScene("escenas.menu")


--//-----------------------------------------------
