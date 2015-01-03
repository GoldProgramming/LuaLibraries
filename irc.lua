import( "socket" )
import( "lfs" )
bots = {}
bot = setmetatable({},{__type="class"})
bot.hooks = {}
getmetatable( bot ).__call = function( t0, data )
	setmetatable( t0, {__index=bot,__type="bot"})
	for k, v in pairs( data ) do
		t0.data[k] = v
	end
	t0.hooks = {}
	setmetatable( t0.hooks, {__index = bot.hooks} )
	bots[t0.data.name or #bots+1] = t0
	return t0
end

function bot:connect()
	self.socket = require( "socket" ).connect( self.data.server, (self.data.port or 6667) )
	assert( self.socket, "Unable to connect for %s" % (self.data.name or self.data.server) )
	self.socket:settimeout( 0.01 )
	if self.data.pass then
		self.socket:send( "PASS %s\r\n" % self.data.pass )
	end
	self.socket:send( "NICK %s\r\nUSER %s * * :%s\r\n" % {self.data.nick, self.data.user, (self.data.realname or "...")} )
end
function bot:think( line )
	for k, v in pairs( table.append( bot.hooks, self.hooks ) ) do
		if tonumber( k ) then
			for k, _v in pairs( v ) do
				local ok, err = pcall( _v, self, line )
				if not ok then
					if err then
						log( "Hooks", "Error \"%s\" in \"%s\"" % {err,line} )
					else
						log( "Hooks", "Error in \"%s\"" % line )
					end
				end
			end
		else
			local ok, err = pcall( v, self, line )
			if not ok then
				if err then
					log( "Hooks", "Error \"%s\" in \"%s\"" % {err,line} )
				else
					log( "Hooks", "Error in \"%s\"" % line )
				end
			end
		end
	end
end
function bot:send( ... )
	self.socket:send( table.concat( {...}, " " ) .. "\r\n" )
end
function bot:privmsg( c, ... )
	self:send( "PRIVMSG", c, ":%s" % table.concat( {...}, " " ) )
end
function bot:notice( c, ... )
	self:send( "NOTICE", c, ":%s" % table.concat( {...}, " " ) )
end
function bot:ctcp( t, ctcp, ... )
	if ... then
		self:privmsg( t, "\1%s %s\1" % { ctcp:upper(), table.concat( {...}, " " ) } )
	else
		self:privmsg( t, "\1%s\1" % ctcp:upper() )
	end
end
function bot:rctcp( t, ctcp, ... )
	if ... then
		self:notice( t, "\1%s %s\1" % { ctcp:upper(), table.concat( {...}, " " ) } )
	else
		self:notice( t, "\1%s %s\1" % ctcp:upper() )
	end
end
function bot:act( c, ... )
	self:ctcp( c, "ACTION", table.concat( {...}, " " ) )
end
function bot:join( c )
	self:send( "JOIN", c )
end
function bot:part( chan, ... )
	if ... then
		self:send( "PART", chan, ":%s" % table.concat( {...}, " " ) )
	else
		self:send( "PART", chan )
	end
end
function bot:disconnect( m )
	if m then
		self:send( "QUIT", ":%s" % m )
	else
		self:send( "QUIT" )
	end
end
