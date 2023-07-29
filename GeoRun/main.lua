-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load title screen
composer.gotoScene( "title", "fade" )

-- Semilla generardor de random de numeros
math.randomseed( os.time() )