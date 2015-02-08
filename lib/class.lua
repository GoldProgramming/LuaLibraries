require( "lib.stdlib" )
class = {}
local reg = {}
local mt = {}
setmetatable( class, mt )
function mt:__call( name, base )
	check( name, 1, "string" )
	check( base, 2, "table", "nil" )
	local __class = {}
	local mt = {}
	setmetatable( __class, setmetatable( mt, {__index = class} ) )
	mt.__data = {
		name = name,
		type = "Class"
	}
	if base then
		local __mt = getmetatable( base )
		if __mt and __mt.__data and __mt.__data.name then
			mt.__data.classof = { name = __mt.__data.name, class = base }
			table.lock( mt.__data.classof )
		end
	end
	local x = tostring( __class )
	mt.__tostring = function( t )
		if mt.__data and mt.__data.name and mt.__data.type then
			return "<%s %s> %s" % { mt.__data.type, mt.__data.name, x }
		elseif mt.__data and mt.__data.name then
			return "<%s> %s" % { mt.__data.name, x }
		elseif mt.__data and mt.__data.type then
			return "<%s> %s" % { mt.__data.type, x }
		else
			return "<Object> %s" % x
		end
	end
	mt.__call = function( ... )
		local t = setmetatable( {}, {__index = self} )
		if self.__call then
			return self.__call( t, ... )
		end
		return t
	end
	table.lock( mt.__data )
	table.lock( mt, { __data = true } )
	return __class
end

function class:isclass()
	check( self, 1, "table" )
	local mt = getmetatable( self )
	if mt then
		return reg[tostring(mt):match( "table: (.+)" )]
	end
end
function class:isclassof( class_2 )
	check( self, 1, "table" )
	check( class_2, 2, "table" )
	local mt = getmetatable( self )
	if mt and mt.__data then
		if mt.__data['classof'] and mt.__data.classof['class'] and mt.__data.classof['class'] == class_2 then
			return true
		end
	end
	return false
end
