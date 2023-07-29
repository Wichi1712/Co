-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- Semilla generardor de random de numeros
math.randomseed( os.time() )

-- load menu screen
composer.gotoScene( "menu" )