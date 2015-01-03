do
	function string:concat( endStr )
		return self .. endStr
	end
	function string:split( match )
		local res = {}
		for mat in self:gmatch( match ) do
			table.insert( res, mat )
		end
		return res
	end
	local mt = getmetatable( '' )
	-- example: "Ha" .. "i" * 5
	mt.__mul = function( str, rep )
		local k, err = pall( string.rep, str, rep )
		if k then
			return err
		else
			return error( err, 2 )
		end
	end
	-- example: "I am %s" % "IRON MAN"
	-- exmaple: "The number is %d" % 42
	-- example: "%s is %s because he was in %d movies" % { "Iron Man", "awesome", 9001 }
	mt.__mod = function( patstr, mod )
		if type( mod ) == "table" then
			local k, err = pcall( string.format, patstr, unpack( mod ) )
			if k then
				return err
			else
				return error( err, 2 )
			end
		else
			local k, err = pcall( string.format, patstr, mod )
			if k then
				return err
			else
				return error( err, 2 )
			end
		end
	end
	-- example: "he" .. "llo"
	-- un-working example: "4" + 2
	-- example: "The number is " + 42
	mt.__add = function( str, cat )
		local k, err = pcall( string.concat, str, cat )
		if k then
			return err
		else
			return error( err, 2 )
		end
	end
	-- example: "Herp Derp Trains" - " "
	-- example: "HerpDerpTrains" - { "%u+", function(t) return t:lower() end }
	mt.__sub = function( str, pat )
		if type( pat ) == "table" then
			local k, err = pcall( string.gsub, str, unpack( pat ) )
			if k then
				return err
			else
				return error( err, 2 )
			end
		else
			local k, err = pcall( string.gsub, str, pat, "" )
			if k then
				return err
			else
				return error( err, 2 )
			end
		end
	end
	-- example: "Herp Derp Trains" / "%S+"
	-- example: "This\nIs\nA\nMulti-line\nString" / "[^\n]+"
	mt.__div = function( str, div )
		local k, err = pcall( string.split, str, div )
		if k then
			return err
		else
			return error( err, 2 )
		end
	end
	-- example: ("Herp")[1] + ("Derp"):sub( 2 )
	mt.__index = function( str, index )
		if tonumber( index ) then
			return str:sub( index, index )
		else
			return string[index]
		end
	end
end

-- print( ("h%sp"%"er")+("d%s%sp"%{("herp")[2],"r"})+("herp derp trains"/"%S+")[3] - "er" )
