--
-- Author: 
-- Date: 2018-09-10 16:21:12
--
local ZhongQiuConf = class("ZhongQiuConf",base.BaseConf)

function ZhongQiuConf:init()
    self:addConf("zq_show_list")
    self:addConf("zq_czhl")
    self:addConf("zq_login_award")
    self:addConf("zq_global")
    self:addConf("zq_hl_lottery")
    self:addConf("zq_visit_moon")
    self:addConf("zq_eliminate_devil_rank")
    self:addConf("zq_eliminate_devil_show")
end

function ZhongQiuConf:getShowList()
    -- body
    return table.values(self.zq_show_list)
end

function ZhongQiuConf:getChongZhiHaoLi()
    -- body
    return table.values(self.zq_czhl)
end

function ZhongQiuConf:getLoginAward()
    -- body
    return table.values(self.zq_login_award)
end

function ZhongQiuConf:getGlobal(id)
    -- body
    return self.zq_global[tostring(id)]
end

function ZhongQiuConf:getLeiChong()
    -- body
    return table.values(self.zq_hl_lottery)
end

function ZhongQiuConf:getBaiYue()
    -- body
    return table.values(self.zq_visit_moon)
end

function ZhongQiuConf:getDevilRank()
    -- body
    return table.values(self.zq_eliminate_devil_rank)
end

function ZhongQiuConf:getDevilShow()
    -- body
    return table.values(self.zq_eliminate_devil_show)
end

return ZhongQiuConf