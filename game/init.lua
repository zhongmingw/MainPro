--[[--
游戏lua初始化
]]


require("game.common.init")
--const
require("game.const.init")
--工具类
require("game.util.init")

require("game.hook.init")
--基类
base = require("game.base.init")
--配置
conf = require("game.conf.init")

--消息
message = require("game.message.init")
--管理器
mgr = require("game.manager.init")
--proxy
proxy = require("game.proxy.init")
--事物
thing = require("game.thing.init")
--战斗相关
fight = require("game.fight.init")
--緩存
cache = require("game.cache.init")


