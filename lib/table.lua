require( "lib.stdlib" )
function table.append( t, t0 )
	check( t, 1, "table" )
	check( t0, 2, "table" )
	for k, v in pairs( t0 ) do
		t[k] = v
	end
	return t
end
function table.lock( t, locks )
	check( t, 1, "table" )
	local storage = {}
	local mt = getmetatable( t ) or getmetatable( setmetatable( t, {} ) )
	if mt.__locks then
		mt.__locks = table.append( mt.__locks, locks ) -- overwrite the old locks (Use with caution)
	elseif check( locks, 2, "table", "nil" ) and locks then
		mt.__locks = locks
	end
	mt.__storage = storage
	mt.__newindex = function( t, k, v )
		if not storage[k] or not storage[k] and not ( mt.__locks and mt.__locks[k] ) then
			print( t,k,v,locks[k] )
			rawset( storage, k, v )
		else
			error( string.format( "locked table (%s): can't set key %s to %s", tostring( t ), tostring( k ), tostring( v ) ), 2 )
		end
	end
	mt.__index = actTable
end
function table.serialize( t, clean )
	check( t, 1, "table" )
	local eol, ind, sep
	if clean then
		eol, ind, sep = "","",""
	else
		eol, ind, sep = "\r\n", "\t", " "
	end
	local seen = {}
	local ser; ser = function( tSer, sIn )
		local t = type( tSer )
		if t == "table" and not seen[tostring( tSer )] then -- You have NOT seen this yet, feel free to serialize
			local retStr = "{" .. eol
			seen[tostring( tSer )] = true
			if not next( tSer ) then
				return "{}"
			else
				local base = 0
				local noin = false
				for i, v in ipairs( tSer ) do
					if not noin and i == base + 1 then
						base = base + 1
						retStr = retStr .. (sIn or "") .. ind .. ser( v ) .. ',' .. eol
					elseif not noin then
						noin = true
					else
						retStr = retStr .. (sIn or "") .. ind .. '[' .. sep .. tostring( i ) .. sep .. ']' .. sep .. '=' .. sep .. ser( v ) .. ',' .. eol
					end
				end
				for k, v in pairs( tSer ) do
					if not tonumber( k ) and type( k ) == "string" then
						if k:match( "^[%u%l_]+$" ) then
							retStr = retStr .. (sIn or "") .. ind .. k .. sep .. '=' .. sep .. ser( v ) .. ',' .. eol
						else
							retStr = retStr .. (sIn or "") .. ind .. '[' .. sep .. ("%q"):format( k ) .. sep .. ']' .. sep .. '=' .. sep .. ser( v ) .. ',' .. eol
						end
					elseif not tonumber( k ) then
						return error( "Unable to serialize tables with weak keys", 3 )
					end
				end
				retStr = retStr .. "}"
			end
			return retStr
		elseif t == "table" then
			return error( "Unable to serialize tables with recursive entries", 3 ) -- 3 because this, then table.serialize, then caller
		elseif t == "string" then
			return ("%q"):format( tSer )
		elseif t == "number" or t == "boolean" then
			return tostring( tSer )
		else
			error( "Unable to serialize type <" .. t .. ">", 3 )
		end
	end
	return ser( t, "" )
end
