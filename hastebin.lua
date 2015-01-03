hastebin = {
	put = function( txt, service )
		local dat, err = require( "socket.http" ).request( "http://" .. (service or "hastebin.com") .. "/documents", txt )
		if dat and dat:match( '{"key":"(.-)"' ) then
			return "http://" .. (service or "hastebin.com") .. "/raw/" .. dat:match( '{"key":"(.-)"}' )
		end
		return "Error: " .. err
	end,
	get = function( url, service )
		local txt, err = require( "socket.http" ).request( "http://" .. (service or "hastebin.com") .. "/raw/" .. url )
		if err == 404 then
			return "Error: " .. txt:match( '{"data":"(.-)"}' )
		else
			return txt
		end
	end
}
_G['hastebin'] = hastebin
package.loaded['hastebin'] = hastebin
return hastebin
