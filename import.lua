function import( v )
	local k, api = pcall( require, v )
	if k and api then
		_G[v:match( ".+%.(.+)$" ) or v] = api
	end
end
