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
