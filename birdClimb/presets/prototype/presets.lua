-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
--
-- labelsInit.lua - Create Label Presets
--
local mgr 			= require "ssk2.interfaces.buttons"
local imagePath	= "presets/prototype/images/"
local common 		= require "scripts.common"

-- ============================
-- ========= DEFAULT BUTTON
-- ============================
local default_params = 
{ 
	unselImgSrc  			= imagePath .. "fillW.png",
	selImgSrc    			= imagePath .. "fillW.png",
	labelColor				= common.textFill2,
	labelSize				= 32,
	labelFont				= "kbsticktotheplan.ttf",
	emboss             	= false,	
	touchOffset				= { 2, 2 },
}
mgr:addButtonPreset( "basic", default_params )

local default_params = 
{ 
	unselImgSrc  			= imagePath .. "fillT.png",
	selImgSrc    			= imagePath .. "fillT.png",
	labelColor				= common.textFill2,
	labelSize				= 32,
	labelFont				= "kbsticktotheplan.ttf",
	emboss             	= false,	
	touchOffset				= { 2, 2 },
}
mgr:addButtonPreset( "basic_transparent", default_params )


-- ============================
-- ======= Play Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "play_unsel.png",
	selImgSrc    = imagePath .. "play_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "play", params )

-- ============================
-- ======= About Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "about_unsel.png",
	selImgSrc    = imagePath .. "about_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "about", params )

-- ============================
-- ======= Pause Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "pause_unsel.png",
	selImgSrc    = imagePath .. "pause_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "pause", params )

-- ============================
-- ======= Back Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "left_unsel.png",
	selImgSrc    = imagePath .. "left_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "back", params )



-- ============================
-- ======= Audio Button
-- ============================
local params = 
{ 
	unselImgSrc    = imagePath .. "soundOff.png",
	selImgSrc  		= imagePath .. "soundOn.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "sound", params )



-- ============================
-- ======= Event Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "arrowUp.png",
	selImgSrc    = imagePath .. "arrowUp.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "event", params )

-- ============================
-- ======= Rate Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "rate_unsel.png",
	selImgSrc    = imagePath .. "rate_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "rate", params )

-- ============================
-- ======= Share Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "share_unsel.png",
	selImgSrc    = imagePath .. "share_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "share", params )

-- ============================
-- ======= URL Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "url_unsel.png",
	selImgSrc    = imagePath .. "url_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "url", params )


-- ============================
-- ======= Shop Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "shop_unsel.png",
	selImgSrc    = imagePath .. "shop_unsel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "shop", params )

-- ============================
-- ======= Twitter Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "twitter_unsel.png",
	selImgSrc    = imagePath .. "twitter_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "twitter", params )

-- ============================
-- ======= Facebook Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "facebook_unsel.png",
	selImgSrc    = imagePath .. "facebook_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "facebook", params )

-- ============================
-- ======= Home Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "home_unsel.png",
	selImgSrc    = imagePath .. "home_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "home", params )

-- ============================
-- ======= Achievements Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "achievements_unsel.png",
	selImgSrc    = imagePath .. "achievements_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "achievements", params )

-- ============================
-- ======= Leaderboard Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "leaderboard_unsel.png",
	selImgSrc    = imagePath .. "leaderboard_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "leaderboard", params )

-- ============================
-- ======= No Ads Button
-- ============================
local params = 
{ 
	unselImgSrc  = imagePath .. "noads_unsel.png",
	selImgSrc    = imagePath .. "noads_sel.png",
	touchOffset	 = { 2, 2 },
}
mgr:addButtonPreset( "noads", params )
