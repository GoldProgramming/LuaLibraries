screen = {}
screen.xsize = 80
screen.presize = 15
function log( name, text )
	if ( not name or not text ) then
		log( "Error", "missing name or text: %s" % debug.traceback() )
	end
	local lines = {}
	local words = {}
	local firstline = true
	local scrSize = screen.xsize
	if #name > screen.presize then
		name = name:sub( 1, screen.presize - 1 ) + "+"
	end
	while text:find( "  " ) do
		text = text:gsub( "  ", " \226\128\139 ")
	end
	for word in text:gmatch( "%S+" ) do
		for i=1, #word, scrSize do
			table.insert( words, word:sub( (scrSize-21)*(i-1), (scrSize-21)*i ) )
		end
	end
	local line = ""
	for k, v in pairs( words ) do
		if #line + #v > scrSize - (screen.presize+6) then
			table.insert( lines, line:sub( 1, -2 ) )
			line = v .. " "
		else
			line = line .. v .. " "
		end
	end
	if #line ~= 0 then
		table.insert( lines, line:sub( 1, -2 ) )
	end
	for k, v in pairs( lines ) do
		if firstline then
			print( " "*(screen.presize-#name) + "[%s] | %s" % {name,v:gsub( "\226\128\139", "" )} )
			firstline = false
		else
			firstline = false
			print( " " * (screen.presize+3) + "| %s" % v:gsub( "\226\128\139", "" ) )
		end
	end
end
