-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
--  main.lua
-- =============================================================
-- Uncomment the next line of code to make your logs QUIET, but be aware that this means
-- no print statements in your code will do anything.
--_G.print = function() end
-- =============================================================
io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)
-- =============================================================
_G.fontN 	= "fonts/Lato-Light.ttf" --native.systemFont
_G.fontB 	= "fonts/Lato-Black.ttf" --native.systemFontBold
-- =============================================================
require "ssk2.loadSSK"
_G.ssk.init( { measure = false } )
-- =============================================================
--ssk.meters.create_fps(true)
--ssk.meters.create_mem(true)
--ssk.misc.enableScreenshotHelper("s") 
-- =============================================================
-- =============================================================
--
-- Run Initialization Code
--
require "scripts.init"

--
-- Load First Scene (or go directly to a scene while debugging/modifying/editing the game)
--
local composer = require "composer"
composer.gotoScene( "scenes.splash" )
--composer.gotoScene( "scenes.play" )
--composer.gotoScene( "scenes.about" )
