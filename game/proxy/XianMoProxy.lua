--
-- Author: 
-- Date: 2017-08-30 14:59:48
--

local XianMoProxy = class("XianMoProxy",base.BaseProxy)

function XianMoProxy:init()
    self:add(5420101,self.add5420101)--请求仙魔战场景信息
    self:add(5420102,self.add5420102)--请求仙魔战日志
    self:add(5420103,self.add5420103)--请求仙魔战详情
    self:add(5420104,self.add5420104)--请求仙魔战玩家位置信息
    self:add(5420105,self.add5420105)--请求仙魔战界面

    self:add(8180401,self.add8180401)--仙魔战阵营信息广播
    self:add(8180402,self.add8180402)--仙魔战我的信息广播
    self:add(8180403,self.add8180403)--仙魔战战报广播
    self:add(8180404,self.add8180404)--仙魔战结束广播

end
--请求仙魔战场景信息
function XianMoProxy:add5420101(data)
    if data.status == 0 then
        cache.FubenCache:setFubenModular(1117)
        cache.XianMoCache:setTop20AvgLev(data.top20AvgLev)--本服排名前20的平均等级
        cache.XianMoCache:setFubenETime(data.createTime + 1800)
        cache.XianMoCache:setWarData(data)
        mgr.ViewMgr:openView2(ViewName.TrackView, {index = 8})
        mgr.ViewMgr:openView2(ViewName.XianMoFightView, {})
        mgr.HookMgr:enterHook()
        mgr.TimerMgr:addTimer(1, 1, function( ... )
            if gRole then gRole:setXianMo() end
            local players = mgr.ThingMgr:objsByType(ThingType.player)
            for k, v in pairs(players) do
                if v then
                    v:setXianMo()
                end
            end
        end)
    else
        GComErrorMsg(data.status)
    end
end

--请求仙魔战日志
function XianMoProxy:add5420102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ZhanChangLog)
        if view then
            view:setData(data)
        else
            mgr.ViewMgr:openView(ViewName.ZhanChangLog,function(view)
                view:setData(data)
            end)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求仙魔战详情
function XianMoProxy:add5420103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.XianMoTipView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
--请求仙魔战玩家位置信息
function XianMoProxy:add5420104(data)
    if data.status == 0 then
        local code = data.reqType
        mgr.HookMgr:setHookData({code = code, info = data})
    else
        GComErrorMsg(data.status)
    end
end
--请求仙魔战界面
function XianMoProxy:add5420105(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

--仙魔战阵营信息广播
function XianMoProxy:add8180401(data)
    if data.status == 0 then
        cache.XianMoCache:setCampInfo(data)
        local view = mgr.ViewMgr:get(ViewName.XianMoFightView)
        if view then
            view:setData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--仙魔战我的信息广播
function XianMoProxy:add8180402(data)
    if data.status == 0 then
        cache.XianMoCache:setMyWarInfo(data)
        local view = mgr.ViewMgr:get(ViewName.TrackView)
        if view then
            view:setXianMoData()
        end
    else
        GComErrorMsg(data.status)
    end
end
--仙魔战战报广播
function XianMoProxy:add8180403(data)
    if data.status == 0 then
        local strTab = {}
        if data.reqType == 1 then--阵营第一名被击杀
            strTab = clone(language.xianmoWar12)
            local str = language.xianmoWar05[tonumber(data.roleCampId)]..data.roleName
            strTab[1].text = string.format(strTab[1].text, str)
            strTab[2].text = string.format(strTab[2].text, data.killerName)
        elseif data.reqType == 2 then--捷报己方连杀
            strTab = clone(language.xianmoWar13)
            local warData = cache.XianMoCache:getWarData()
            local myCampId = warData.campId or 0
            strTab[1].text = string.format(strTab[1].text, language.xianmoWar05[myCampId])
            strTab[2].text = string.format(strTab[2].text, data.roleName)
            strTab[3].text = string.format(strTab[3].text, tonumber(data.value))
        elseif data.reqType == 3 then--警报敌方连杀
            strTab = clone(language.xianmoWar14)
            strTab[2].text = string.format(strTab[2].text, data.roleName)
            strTab[3].text = string.format(strTab[3].text, tonumber(data.value))
        end
        mgr.TipsMgr:addCenterTip({text = mgr.TextMgr:getTextByTable(strTab)})
    else
        GComErrorMsg(data.status)
    end
end

function XianMoProxy:add8180404(data)
    printt("仙魔战结束广播",data)
    if data.status == 0 then
        data["titleUrl"] = UIItemRes.xianmoWar01
        data["type"] = 4
        local expData = {mid = PackMid.exp,amount = data.gotExp,bind = 1}--获得的经验
        local scoreAwards = {}
        scoreAwards[1] = expData
        local awards = data.items or {}
        for k,v in pairs(awards) do
            table.insert(scoreAwards, v)
        end
        data.items = scoreAwards
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView,data)
    else
        GComErrorMsg(data.status)
    end
end

return XianMoProxy