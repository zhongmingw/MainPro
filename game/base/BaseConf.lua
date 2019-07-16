local BaseConf = class("BaseConf")

function BaseConf:ctor()
    self:init()    
end

function BaseConf:init()
end

function BaseConf:addConf(conf)
    self[conf] = require("conf."..conf)
end

function BaseConf:error(message)
    plog(self.__cname.."(配置表)没有这个配置:"..message)
end



return BaseConf