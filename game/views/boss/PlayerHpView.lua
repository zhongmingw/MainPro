--
-- Author: 
-- Date: 2017-06-16 20:23:53
--
--PK玩家血条
local PlayerHpView = class("PlayerHpView", base.BaseView)

function PlayerHpView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function PlayerHpView:initData(data)
    self.time = PlayerHpTipTime
    self:releaseTimer()
    self:releaseHpTimer()
    self:setData(data)
end

function PlayerHpView:initView()
    self.icon = self.view:GetChild("n5"):GetChild("n3")
    self.buffListView = self.view:GetChild("bufflist")
    self.buffListView.itemRenderer = function(index,obj)
        self:cellBuffData(index, obj)
    end
    self.buffListView.onClick:Add(self.onBuffItemClick,self)
    self.roleName = self.view:GetChild("n2")
    self.hpBar = self.view:GetChild("bar")
    self.hpBar:GetChild("bar").url = UIItemRes.boss01[2]
    self.hpText = self.view:GetChild("title")
    self.barEff = self.view:GetChild("bar2")--打底的动态血
end

function PlayerHpView:setData(data)
    self.mData = data
    -- if mgr.FubenMgr:isWenDing(cache.PlayerCache:getSId()) then
    --     if data.roleId ~= cache.WenDingCache:getflagHoldRoleId() then
    --         self.roleName.text = language.wending06[1]
    --     else
    --         self.roleName.text = language.wending06[2]
    --     end
    -- else
        if self.roleName.text ~= data.roleName then
            self.roleName.text = data.roleName
        end
    -- end
    local playerData = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
        if self.icon then
            self.icon.url = t.headUrl
        end
    end)
    local sex = playerData.sex
    -- if self.icon.url ~= UIItemRes.playerIcon[sex] then
    --     self.icon.url = UIItemRes.playerIcon[sex]
    -- end
    self.icon.url = playerData.headUrl
    self.buffs = {}
    for k,v in pairs(self.mData.buffs) do
        local config = conf.BuffConf:getBuffConf(v.modelId)
        if config and config.icon then
            table.insert(self.buffs, v)
        end
    end
    self:setBuffsData(self.buffs)
    self:setHp(data,true)
    if not self.hpTimer then
        self:onTimer()
        self.hpTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function PlayerHpView:releaseTimer()
    if self.hpTimer then
        self:removeTimer(self.hpTimer)
        self.hpTimer = nil
    end
end

function PlayerHpView:onTimer()
    if not self.time then return end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
        return 
    end
    self.time = self.time - 1
end

function PlayerHpView:setHp(data,isAppear)
    self.time = PlayerHpTipTime
    local curHp = data.attris and data.attris[104] or 0
    local maxHp = data.attris and data.attris[105] or 0
    -- plog("血条",data.roleName,curHp,maxHp)
    self.oldValue = clone(self.hpBar.value)
    self.barEff.value = self.oldValue
    self.barValue = curHp
    if curHp <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    self.hpBar.value = curHp
    self.hpBar.max = maxHp
    self.barEff.max = maxHp
    self.hpText.text = GTransFormNum(curHp).."/"..GTransFormNum(maxHp)--血条值

    if isAppear then
        self.barEff.value = curHp
    else
        self.hpValue = curHp
        self.time2 = HpAdvTime
        self.timeBegan = Time.getTime()
        if not self.hpTimer2 then
            self.hpTimer2 = self:addTimer(BossDeleyTime2,-1,handler(self, self.onHpTimer))
        end
    end
end

function PlayerHpView:releaseHpTimer()
    if self.hpTimer2 then
        self:removeTimer(self.hpTimer2)
        self.hpTimer2 = nil
    end
end

function PlayerHpView:onHpTimer()
    if Time.getTime() - self.timeBegan >= BossDeleyTime1 then
        local value = self.oldValue - self.hpValue
        if self.time2 <= 0 then
            self.barEff.value = self.barValue
            self:releaseHpTimer()
            return
        end
        local var = value * (1 - self.time2 / HpAdvTime)
        self.barEff.value = self.oldValue - var
        self.time2 = self.time2 - BossDeleyTime2
    end
end

function PlayerHpView:setBuffsData(buffs)
    if self.mData then
        self.buffs = buffs
        self.buffListView.numItems = #self.buffs
    end
end

function PlayerHpView:cellBuffData(index,obj)
    local modelId = self.buffs[index + 1].modelId
    local config = conf.BuffConf:getBuffConf(modelId)
    if config and config.icon then
        obj:GetChild("icon").url = ResPath.buffRes(config.icon)
    end
end

function PlayerHpView:onBuffItemClick()
    if self.mData then
        local data =  mgr.BuffMgr:getBuffByid(self.mData.roleId)
        if table.nums(data) ~= 0 then 
            mgr.ViewMgr:openView(ViewName.BuffView,function(view)
                view:setData()
            end,self.mData)
        end
    end
end

function PlayerHpView:getData()
    return self.mData
end

return PlayerHpView