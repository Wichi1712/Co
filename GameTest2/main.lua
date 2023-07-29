-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Oculta la barra de estado
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "menu" )