--EVE BOSS刷新卡
local BossRefreshCard = class("BossRefreshCard", base.BaseView)

function BossRefreshCard:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BossRefreshCard:initView()
    --关闭
    self.view:GetChild("n0"):GetChild("n7").onClick:Add(self.onClickClose,self)
    --list
    self.list = self.view:GetChild("n1")
end 

function BossRefreshCard:initData(data)
    --使用道具时传过来的index和道具id
    self.curPropCard = data
    -- print("当前道具卡：",data.packIndex, data.targetRoleId)
    --计时器
    self:createTimer()
    --初始化表
    self:initList()
    --list中所用的到得参数（倒计时）
    self.timeObj = {}      --时间对象组件
    self.timeNext = {}     --下次刷新时间
    self.flag = false      --倒计时是否结束
    self.refreshBossLv = 0 --刷新的boss等级
end

function BossRefreshCard:createTimer()
    -- body
    if self.timer then 
        self:removeTimer(self.timer)
        self.timer = nil
    end

    self.timer = self:addTimer(1,-1,handler(self,self.onTimer))
end

function BossRefreshCard:initList()
    self.list.numItems = 0
    self.list.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.list:SetVirtual()
end

function BossRefreshCard:itemData(index, obj)
    -- body
    local data = self.data.bossList[index+1]
    local bossConfData = conf.MonsterConf:getInfoById(data.monsterId)
    --BOSS名称
    local bossName = obj:GetChild("n0")
    bossName.text = bossConfData and bossConfData.name or 0
    --BOSS等级
    local bossLv = obj:GetChild("n1")
    bossLv.text = string.format(language.gonggong51, bossConfData and bossConfData.level or 0) 
    --BOSS刷新倒计时
    local bossTiemr = obj:GetChild("n2")
    table.insert( self.timeObj, bossTiemr )
    table.insert( self.timeNext, data.nextRefreshTime) 
    self:onTimer()
    --刷新按钮
    local btnGet = obj:GetChild("n3")
    local data = {id = data.monsterId, lv = bossConfData.level}
    btnGet.data = data
    btnGet.onClick:Add(self.onClickRefresh,self)
end

--倒计时
function BossRefreshCard:onTimer()
    -- body
    for k,v in ipairs(self.timeNext) do
        local overTime = self:getOverTime(v)  
        if overTime and overTime > 0 then
            self.timeObj[k].text = GTotimeString(overTime)
        elseif overTime and not self.flag then --倒数计时结束
            -- print("倒计时结束")
            self.timeObj[k] = nil
            self.timeNext[k] = nil
            proxy.FubenProxy:send(1330701, {reqType=0, packIndex=self.curPropCard.packIndex, monsterId=0})
            self.flag = true
            return
        end
    end
end
--获取刷新的剩余时间
function BossRefreshCard:getOverTime(nextTime)
    local serverTime = mgr.NetMgr:getServerTime()       --os.time()  --服务器时间

    if nextTime then 
        local result = nextTime - serverTime              --剩余时间
        return result
    else
        -- print("self.data.start 返回结果为nil", id)
        return nil
    end 
end

--刷新
function BossRefreshCard:onClickRefresh(context)
    local cell = context.sender
    local data = cell.data

    -- print("请求刷新的BOSS ID：",data.id)

    self.refreshBossLv = data.lv

    proxy.FubenProxy:send(1330701, {reqType=1, packIndex=self.curPropCard.packIndex, monsterId=data.id})
end

function BossRefreshCard:setData(data)
    -- print("BOSS刷新卡广播返回")

    self.data = data

    if data.reqType == 1 then
        --刷新成功提示
        GComAlter(string.format(language.fuben214,self.refreshBossLv))
        --刷新背包
        local packView = mgr.ViewMgr:get(ViewName.PackView)
        if packView then
            packView:setData()
        end
    else  
        --初始化倒数计时标志位
        self.flag = false
    end

    self.list.numItems = #self.data.bossList or 0;
end

function BossRefreshCard:onClickClose()
    -- body
    self:closeView()
end

return BossRefreshCard