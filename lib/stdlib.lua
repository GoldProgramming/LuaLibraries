function check( main, lev, ... )
	if not ... and main then return true elseif not ... then return end
	if not main and not lev then
		return error( "bad argument #1 (nil value)", 2 )
	elseif main and not lev then
		return true
	end
	if type( lev ) ~= "number" then
		return error( "bad argument #2 (number expected, got " .. type( lev ) .. ")", 2 )
	end
	local vert = { ... }
	for k, v in pairs( vert ) do
		check( vert )
	end
	local t = type( main )
	for k, v in pairs( vert ) do
		if t == v then
			return true
		end
	end
	if #vert == 1 then
		return error( ("bad argument #%d (%s expected, got %s)"):format( lev, (...), t ), 3 )
	else
		return error( ("bad argument #%d ([%s] expected, got %s)"):format( lev, table.concat( vert, " | " ), t ), 3 )
	end
end
