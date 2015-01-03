function class( t )
    local t0 = {}
    local _type = type( t )
    setmetatable( t0, {} )
    if _type == "table" then
        setmetatable( t0, {__type="class"} )
        local _table = getmetatable( t0 )
        for k, v in pairs( t ) do
            _table[k] = v
        end
    elseif _type == "string" then
        local const = function( t, ... )
            local t1 = {}
            setmetatable( t1, {__index=t,__type=getmetatable(t).__ctype} )
            if getmetatable( t ).__init then
                getmetatable( t ).__init( t1, ... )
            end
            return t1
        end
        setmetatable( t0, {__type="class",__ctype=t,__call=const} )
    elseif _type == "function" then
        setmetatable( t0, {__type="class",__call=t} )
    end
    t0.__mt = getmetatable( t0 )
    return t0
end
do
    local rawtype = type
    function type( t, raw )
        local _type = rawtype( t )
        if raw then
            return _type
        elseif _type ~= "table" then
            return _type
        elseif _type == "table" then
            local mt = getmetatable( t )
            if mt and mt.__type then
                return mt.__type
            else
                return _type
            end
        end
    end
end
