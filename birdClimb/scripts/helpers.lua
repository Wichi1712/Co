-- =============================================================
-- Copyright Roaming Gamer, LLC. 2008-2018 (All Rights Reserved)
-- =============================================================
local function round(val) return math.floor(val+0.5); end
local w = display.contentWidth; local h = display.contentHeight
local centerX = display.contentCenterX;local centerY = display.contentCenterY
local fullw = display.actualContentWidth;local fullh = display.actualContentHeight
local unusedWidth = fullw - w;local unusedHeight = fullh - h
local left = round(0 - unusedWidth/2);local top = round(0 - unusedHeight/2)
local right  round(w + unusedWidth/2);local bottom = round(h + unusedHeight/2)
local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
-- =============================================================
local platformName            = string.lower(system.getInfo("platformName"))
local platform                = string.lower(system.getInfo("platform"))
local platformEnvironment     = string.lower(system.getInfo("environment"))
-- =============================================================
local helpers = {}

-- =============================================================
-- Return first argument in list that is 'not nil'
-- =============================================================
function helpers.fnn( ... ) 
   for i = 1, #arg do
      local theArg = arg[i]
      if(theArg ~= nil) then return theArg end
   end
   return nil
end

-- =============================================================
-- Native alert helper.
-- =============================================================
function helpers.easyAlert( title, msg, buttons )
   buttons = buttons or { {"OK"} }
   local function onComplete( event )
      local action = event.action
      local index = event.index
      if( action == "clicked" ) then
         local func = buttons[index][2]
         if( func ) then func() end 
       end
   end
   local names = {}
   for i = 1, #buttons do
      names[i] = buttons[i][1]
   end
   return native.showAlert( title, msg, names, onComplete )
end

-- =============================================================
-- Make first letter in string 'upper-case'
-- =============================================================
function helpers.first_upper(str)
   return str:gsub("^%l", string.upper)
end

-- =============================================================
-- Returns 'true' if obj is still a valid display object.
-- =============================================================
function helpers.isValid( obj )
   return ( obj and obj.removeSelf and type(obj.removeSelf) == "function" )
end

-- =============================================================
-- Shorthand for Runtime:addEventListener( name, listener )
-- =============================================================
function helpers.listen( name, listener ) 
   Runtime:addEventListener( name, listener ) 
end

-- =============================================================
-- Shorthand for Runtime:removeEventListener( name, listener )
-- =============================================================
function helpers.ignore( name, listener ) 
   Runtime:removeEventListener( name, listener ) 
end

-- =============================================================
-- Safe Runtime listener remover similar to 'ignore' (above), but
-- takes list (table of strings) for each listener name to remove.
-- =============================================================
function helpers.ignoreList( list, obj )
   if( not obj ) then return end
   for i = 1, #list do
      local name = list[i]
      if(obj[name]) then 
         ignore( name, obj ) 
         obj[name] = nil
      end
  end
end

-- =============================================================
-- Checks if obj is still valid and if not, removes named listener
-- Returns 'true' if object was invalid and listener was removed.
-- =============================================================
function helpers.autoIgnore( name, obj ) 
   if( not helpers.isValid( obj ) ) then
      ignore( name, obj )
      obj[name] = nil
      return true
   end
   return false 
end

-- =============================================================
-- Shorthand helper that does job of Runtime:dispatchEvent( event )
-- =============================================================
function helpers.post( name, params )
   params = params or {}
   local event = {}
   for k,v in pairs( params ) do event[k] = v end
   event.name = name
   if( not event.time ) then event.time = system.getTimer() end
   Runtime:dispatchEvent( event )
end

-- =============================================================
-- helpers.save( theTable, fileName [, base ] ) - Saves table to file (Uses JSON library as intermediary)
-- =============================================================
function helpers.save( theTable, fileName, base  )
   local json = require "json"
   local base = base or  system.DocumentsDirectory
   local path = system.pathForFile( fileName, base )
   local fh = io.open( path, "w" )

   if(fh) then
      fh:write(json.encode( theTable ))
      io.close( fh )
      return true
   end   
   return false
end

-- =============================================================
-- helpers.load( fileName [, base ] ) - Loads table from file 
-- (Uses JSON library as intermediary)
-- =============================================================
function helpers.load( fileName, base )
   local json = require "json"
   local base = base or system.DocumentsDirectory
   local path = system.pathForFile( fileName, base )
   if(path == nil) then return nil end
   local fh, reason = io.open( path, "r" )
   if( fh) then
      local contents = fh:read( "*a" )
      io.close( fh )
      local newTable = json.decode( contents )
      return newTable
   else
      return nil
   end
end

-- =============================================================
-- helpers:rpad( str, len, char ) - Places padding on right side 
-- of a string, such that the new string is at least len characters long.
-- =============================================================
function helpers.rpad( str, len, char)
   local theStr = str
    if char == nil then char = ' ' end
    return theStr .. string.rep(char, len - #theStr)
end

-- =============================================================
-- Table dumper.
-- =============================================================
function helpers.dump( theTable, padding, marker ) -- Sorted
   if(marker == nil and type(padding) == "string" ) then
      marker = padding
      padding = 30
   else
      padding = padding or 30
   end
   local theTable = theTable or  {}
   local function compare(a,b)
      return tostring(a) < tostring(b)
   end
   local tmp = {}
   for n in pairs(theTable) do table.insert(tmp, n) end
   table.sort(tmp,compare)

   local padding = padding or 30
   print("\Table Dump:")
   print("-----")
   if(#tmp > 0) then
      for i,n in ipairs(tmp) do     

         local key = tmp[i]
         local value = theTable[key]
         local keyType = type(key)
         local valueType = type(value)
         value = tostring(value)
         local keyString = tostring(key) .. " (" .. keyType .. ")"
         local valueString = tostring(value) .. " (" .. valueType .. ")" 

         keyString = helpers.rpad(keyString,padding)
         valueString = helpers.rpad(valueString,padding)

         print( keyString .. " == " .. valueString ) 
      end
   else
      print("empty")
   end
   print( marker and ( "-----\n" ..marker .. "\n-----" ) or "-----" )   
end

-- =============================================================
-- helpers.print_r( theTable ) - Dumps indexes and values inside 
-- multi-level table (for debug)
-- =============================================================
helpers.print_r = function ( t ) 
   local print_r_cache={}
   local function sub_print_r(t,indent)
      if (print_r_cache[tostring(t)]) then
         print(indent.."*"..tostring(t))
      else
         print_r_cache[tostring(t)]=true
         if (type(t)=="table") then
            for pos,val in pairs(t) do
               if (type(val)=="table") then
                  print(indent.."["..pos.."] => "..tostring(t))
                  print(indent.."{")
                  sub_print_r(val,indent..string.rep(" ",3))
                  print(indent..string.rep(" ",0).."}")
               elseif (type(val)=="string") then
                  print(indent.."["..pos..'] => "'..val..'"')
               else
                  print(indent.."["..pos.."] => "..tostring(val))
               end
            end
         else
            print(indent..tostring(t))
         end         
      end
   end
   if (type(t)=="table") then
      print(tostring(t).." {")
      sub_print_r(t," ")
      print("}")
   else
      sub_print_r(t," ")
   end
   return table.concat(print_r_cache, "\n")
end

-- =============================================================
-- Rounds floating point-values to zero places.
-- =============================================================
function helpers.round(val) return math.floor(val+0.5); end

-- =============================================================
-- returns: onSim, os
-- - onSim - 'true' if on simulator
-- - os - nil if not on simulator, 'win' or 'osx' otherwise.
-- =============================================================
function helpers.onSim()
   if( platformEnvironment == "device" ) then return false,nil end
   if( platformName == "mac os x" ) then return true, 'osx' end
   if( platformName == "win" ) then return true, 'win' end
   return false, nil
end
-- =============================================================
-- Returns: 'ios', 'android', 'tvos', or nil if OS is unknown.
-- =============================================================
function helpers.os()
   if( (platformName == "iphone os") or (platform == "ios") ) then
      return "ios"
   elseif( (platformName == "android") or (platform == "android") ) then
      return "android"
   elseif( (platformName == "tvos") or (platform == "tvos") ) then      
      return "tvos"   
   end
   return nil
end
-- =============================================================
-- Splits a string on specified token and returns table of values.
-- =============================================================
function helpers.split(str,tok)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local ftok = "(.-)" .. tok
   local last_end = 1
   local s, e, cap = str:find(ftok, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(ftok, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

return helpers
