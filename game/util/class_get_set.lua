local type = type
local rawset = rawset
local setmetatable = setmetatable

local traceCount = 0
local tracebacks = setmetatable({}, {__mode = "k"})

local function class_get_set(classname, super)
    local cls = {}

    cls.classname = classname
	cls.class = cls
    cls.Get = {}
    cls.Set = {}
	cls.__paramers = {}
    
    local Get = cls.Get
    local Set = cls.Set

    if super then
        -- copy super method 
        for key, value in pairs(super) do
            if type(value) == "function" and key ~= "ctor" then
                cls[key] = value
            end
        end

        -- copy super getter
        for key, value in pairs(super.Get) do
            Get[key] = value
        end
        
        -- copy super setter
        for key, value in pairs(super.Set) do
            Set[key] = value
        end
        
        cls.super = super
    end

    function cls.__index(self, key)
        local func = cls[key]
        if func then
           return func
        end

        local getter = Get[key]
        if getter then
            return getter(self)
        end

        return nil
    end

    function cls.__newindex(self, key, value)
        local setter = Set[key]
        if setter then
            setter(self, value)
            return
        end

        if Get[key] then
            assert(false, "readonly property")
        end
        
        rawset(self, key, value)
    end
	
	function cls.just_set(self,name,value)
		self["_"..name]=value
	end
	
	function cls.paramer_set(self,name,value,...)
		self.__paramers={...}
		self[name]=value
	end
	
	function cls.bind(self,name,func,...)
		local temp={...}
		self.Set[name]=function(self,value)
			local oldvalue=self["_"..name]
			self["_"..name]=value
			
			xpcall(function()
				local paramers=self.__paramers
				self.__paramers={}
				if(#paramers>0) then
					if(#temp>0) then
						func(value,oldvalue,unpack(temp),unpack(paramers))
					else
						func(value,oldvalue,unpack(paramers))
					end
				else
					func(value,oldvalue,unpack(temp))
				end
			end,function(e) return e end)
		end
		self.Get[name]=function()
			return self["_"..name]
		end
	end
	
	function cls.unbind(self,name)
		self.Set[name]=nil
		self.Get[name]=nil
	end

    function cls.new(...)
        local self = setmetatable({}, cls)
        local function create(cls, ...)
            if cls.super then
                create(cls.super, ...)
            end
            if cls.ctor then
                cls.ctor(self, ...)
            end
        end
        create(cls, ...)
        
        -- debug
        traceCount = traceCount + 1
        tracebacks[self] = traceCount

        return self
    end

    -- compat
    cls.dtor = nil
    function cls.delete(self)
        if tracebacks[self] < 0 then return end
        local destroy
        destroy = function(cls)
            if cls.dtor then
                cls.dtor(self)
            end
            if cls.super then
                destroy(cls.super)
            end
        end
        destroy(cls)
        tracebacks[self] = -tracebacks[self]
    end

    return cls
end

return class_get_set