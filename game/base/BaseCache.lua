--[[--
缓存基类
]]

local BaseCache = class("BaseCache")

function BaseCache:ctor()
  self._msgs = {}
  self:init()
end

function BaseCache:init()


end



return BaseCache