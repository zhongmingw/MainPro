--
-- Author: ohf
-- Date: 2017-04-15 10:40:29
--
--boss血条
local BossHpView = class("BossHpView", base.BaseView)

local sumCount = 120--总血条
local curCount = 121--当前血条
local curHpIndex = 104--当前血
local maxHpIndex = 105--最大血
-- local lvIndex = 502--boss等级
local idIndex = 601--bossId

local barMax = 100--血条最大值

function BossHpView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function BossHpView:initData(data)
    self.curAllHp = 0
    self.maxAllHp = 100
    self.bar.value = 0
    self.bar.max = 0
    self.barEff.value = 0
    self.barEff.max = 0
    self.barTitle.text = ""
    self.hateName = ""
    self:setHideHate()
    self.maxHp = nil
    self.hateName = nil
    self.buffListView.numItems = 0
    self.init = true
    self:setData(data)

    self.roleId = nil 
    self.btn1.visible = false
end

function BossHpView:initView()
    self.icon = self.view:GetChild("n2")
    self.bossName = self.view:GetChild("n6")
    self.bossName.text = ""
    self.bar = self.view:GetChild("bar")--第一条血
    self.barImg = self.bar:GetChild("bar")
    self.barFrame = self.view:GetChild("bar3"):GetChild("bar")--第二条血
    self.hateNameText = self.view:GetChild("n4")--仇恨归属
    self.hateNameText.text = ""
    self.bossLvText = self.view:GetChild("n5")
    self.symbol = self.view:GetChild("n3")
    self.hpCountText = self.view:GetChild("n7")
    self.barTitle = self.view:GetChild("title")
    self.buffListView = self.view:GetChild("bufflist")
    self.buffListView.itemRenderer = function(index,obj)
        self:cellBuffData(index, obj)
    end
    self.buffListView.onClick:Add(self.onBuffItemClick,self)
    self.barEff = self.view:GetChild("bar2")--打底的动态血


    ---新加的9-21 神兽圣域 加一个查看仙盟伤害排行查看

    self.btn1 = self.view:GetChild("n20")
    self.btn1.onClick:Add(self.onBtnCallBack,self)
    self.btn1.visible = false
     --print("我才",self.btn1)
end

function BossHpView:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    local sId = cache.PlayerCache:getSId()
    if "n20" == btn.name then
        print("self.roleId",self.roleId,mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu))
        if mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu) and self.roleId  then
            mgr.ViewMgr:openView2(ViewName.ShouShenHurtRank,self.roleId)
        end
    end
end

function BossHpView:setData(data)


    self.bossId = 0

    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isEliteBoss(sId) then
        self.bossLvText.visible = true
    elseif mgr.FubenMgr:isKuaFuBoss(sId) then
        self.bossLvText.visible = true
    elseif mgr.FubenMgr:isKuaFuTeamFuben(sId) then
        self.bossLvText.visible = false
    elseif mgr.FubenMgr:isKuaFuWar(sId) then
        self.bossLvText.visible = false
    elseif mgr.FubenMgr:isMainTaskFuben(sId) then
        self.bossLvText.visible = false
    else
        self.bossLvText.visible = true
    end
    if data then
        if data.mId then
            self.bossId = data.mId
        elseif data.attris then
            self.bossId = data.attris[601] or 0
        end
    end
    if mgr.FubenMgr:isShangGuShenJi(sId) or mgr.FubenMgr:isXianyuJinDi(sId) then
        self.view:GetChild("n18").visible = true
        self.view:GetChild("n19").visible = true
        local confData = conf.FubenConf:getSgsjAward(self.bossId)
        if confData then
            self.view:GetChild("n19").text = confData.anger
        else
            self.view:GetChild("n18").visible = false
            self.view:GetChild("n19").visible = false
        end
    else
        self.view:GetChild("n18").visible = false
        self.view:GetChild("n19").visible = false
    end
    if self.bossId == 0 then
        if mgr.FubenMgr:isBossFuben(sId) or mgr.FubenMgr:isXianzunBoss(sId) then
            self:setHideHate()
            local passId = sId * 1000 + 1
            local confData = conf.FubenConf:getPassDatabyId(passId)
            local bossData = confData and confData.ref_monsters
            self.bossId = bossData[1][1]
        elseif mgr.FubenMgr:isHome(sId) then
            --家园
            local monster = mgr.ThingMgr:getObj(ThingType.monster, data.roleId)
        else
            local confData = conf.SceneConf:getSceneById(sId)
            local bossData = confData and confData.order_monsters
            if bossData then
                self.bossId = bossData[1][2] or 0
            end
        end
    end

    local mConf = conf.MonsterConf:getInfoById(self.bossId)
    self.bossName.text = mConf and mConf.name or ""  

    local lv = mConf and mConf.level or 0
    self.bossLvText.text = "Lv"..lv
    self:setBossData()
end
--boss数据
function BossHpView:setBossData(hpCount)
    local bossObj = nil
    local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
    for k,v in pairs(allMonster) do
        if v.kind ~= WidgetKind.mb and v:getMId() == self.bossId then
            bossObj = v
            break
        end
    end
    if bossObj then
        local data = bossObj:getAttris()
        self:setAttisData(data,hpCount)
        self.init = false
    end
end

--仇恨归属
function BossHpView:setHateRoleName(name)
    local hateStr = ""
    if name then
        self.hateName = name
    end

    if self.hateName then
        hateStr = string.format(language.fuben62, self.hateName)
    end
    if self.bossId and self.bossId ~= 0 and self.hateName then
        --print("self.bossId",self.bossId)
        local mConf = conf.MonsterConf:getInfoById(self.bossId)
        if mConf.kind == 7 then
            hateStr = string.format(language.chunjie10, self.hateName)
        end
    end
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isBossFuben(sId) 
        or mgr.FubenMgr:isDujieFuben(sId)
        or mgr.FubenMgr:isKuaFuTeamFuben(sId) 
        or mgr.FubenMgr:isXianzunBoss(sId)
        or mgr.FubenMgr:isJuqingFuben(sId) 
        or mgr.FubenMgr:isMainTaskFuben(sId) 
        or mgr.FubenMgr:isFuben(sId) then
        self:setHideHate()
    else
        if self.hateNameText then
            self.hateNameText.text = hateStr
        end
    end
end

function BossHpView:setHideHate()
    if self.hateNameText then
        self.hateNameText.text = ""
    end
end

--boss属性数据（个人，精英，世界）
function BossHpView:setAttisData(data,hpCount)
    local curHp = data[curHpIndex] or 0
    local maxHp = data[maxHpIndex] or self.maxHp
    self.maxHp = maxHp
    local cur = hpCount or (data[curCount] or 0)

    local sum = data[sumCount] or 0
    local curAllHp = 0
    if curHp > 0 then
        curAllHp = curHp + (cur - 1) * maxHp
    else
        curAllHp = cur * maxHp
    end
    if cur == 0 then
        curAllHp = curHp
    end
    local maxAllHp = maxHp * sum
    if sum <= 0 then
        maxAllHp = maxHp
    end
    local attiData = {
        bossId = data[idIndex],
        curAllHp = curAllHp,
        maxAllHp = maxAllHp,
        cur = cur, 
        sum = sum, 
        curHp = curHp, 
        maxHp = maxHp
    }
    -- printt("广播boss血条>>>>>>>>>>>",attiData)
    self:setBossHp(attiData)
end
function BossHpView:setHomeBoss(data)
    -- body
end

--boss属性数据（野外，副本）
function BossHpView:setAttisData2(data,monsterId)
    local curAllHp = data[curHpIndex] or 0
    local maxAllHp = data[maxHpIndex] or 0
    local mConf = conf.MonsterConf:getInfoById(monsterId)
    local sum = mConf and mConf.att_123 or 1
    local maxHp = maxAllHp / sum--最大血（平均血）
    local cur = math.floor(curAllHp / maxHp)--当前血条
    local curHp = curAllHp % maxHp
    if curHp > 0 then
        cur = cur + 1
    else
        curHp = maxHp
    end
    if curAllHp <= 0 then
        curHp = 0
        cur = 0
    end
    local attiData = {
        bossId = monsterId,
        curAllHp = curAllHp,
        maxAllHp = maxAllHp,
        cur = cur, 
        sum = sum, 
        curHp = curHp, 
        maxHp = maxHp
    }
    -- printt("boss出现>>>>>>>>>",attiData)
    self:setBossHp(attiData)
end

function BossHpView:setBossHp(data)
    local mConf = conf.MonsterConf:getInfoById(data.bossId)
    -- self.icon.url = ResPath.iconRes(mConf.icon)  --UIPackage.GetItemURL("_icons" , ""..mConf.icon)
    self.bossName.text = mConf and mConf.name or ""  
    local lv = mConf and mConf.level or 0
    self.bossLvText.text = "Lv"..lv
    self.curAllHp = data.curAllHp
    self.maxAllHp = data.maxAllHp
    self.barTitle.text = GTransFormNum(data.curAllHp).."/"..GTransFormNum(data.maxAllHp)--血条值
    local cur = data and data.cur or 0
    local sum = data and data.sum or 0
    local index = sum - cur
    local curIndex = index + 1
    local nextIndex = curIndex + 1
    local curHpData = conf.HpConf:getHpData(curIndex)
    local color = curHpData and curHpData.color
    self.barImg.url = UIItemRes.boss01[color]
    self.oldValue = clone(self.bar.value)
    self.barEff.value = self.oldValue
    local curHp = data and data.curHp or 0
    local maxHp = data and data.maxHp or 0
    local hpValue = math.ceil(curHp / maxHp * barMax)
    -- plog("当前血",curHp,"最大血",maxHp,"当前血条",cur,"总血条",sum)
    self.barValue = hpValue
    self.bar.value = hpValue
    self.bar.max = barMax
    self.barEff.max = barMax
    if cur <= 1 then--只剩最后一条血了
        self.barFrame.visible = false
        self.barFrame.url = ""
    else--下一条血的情况
        self.barFrame.visible = true
        local nextHpData = conf.HpConf:getHpData(nextIndex)
        local color = nextHpData and nextHpData.color
        self.barFrame.url = UIItemRes.boss01[color]
    end
    if cur <= 0 then
        self.symbol.visible = false
        self.hpCountText.visible = false
    else
        self.symbol.visible = true
        self.hpCountText.visible = true
    end
    self.hpCountText.text = cur--当前血条数
    if data.bossId and data.bossId > 0 then
        self.bossId = data.bossId
        local mConf = conf.MonsterConf:getInfoById(data.bossId)
        self.bossName.text = mConf and mConf.name or ""
        
        --EVE 仅用于仙盟boss
        if cache.PlayerCache:getSId() == 230001 then 
            local confData = conf.MonsterConf:getInfoById(data.bossId)
            if confData and confData.level then 
                -- print("当前BOSS等级：",confData.level)
                self.bossLvText.text = "Lv"..confData.level
                self:setHideHate()
            end 
        end 
        --EVE END
    end
    self.hpValue = hpValue
    self.time = HpAdvTime
    self.timeBegan = Time.getTime()
    if not self.hpTimer then
        self.hpTimer = self:addTimer(BossDeleyTime2,-1,handler(self, self.onHpTimer))
    end
    if curHp <= 0 and cur <= 0 and not self.init then
        self:close()
    end
end

function BossHpView:getBossPercent()
    return self.curAllHp / self.maxAllHp
end

function BossHpView:releaseTimer()
    if self.hpTimer then
        self:removeTimer(self.hpTimer)
        self.hpTimer = nil
    end
end

function BossHpView:onHpTimer()
    if Time.getTime() - self.timeBegan >= BossDeleyTime1 then
        local value = self.oldValue - self.hpValue
        if self.time <= 0 then
            self.barEff.value = self.barValue
            self:releaseTimer()
            return
        end
        local var = value * (1 - self.time / HpAdvTime)
        self.barEff.value = self.oldValue - var
        self.time = self.time - BossDeleyTime2
    end
end

function BossHpView:setBossRoleId(roleId)
    self.roleId = roleId
    local sId = cache.PlayerCache:getSId()
    self.btn1.visible = mgr.FubenMgr:getJudeWarScene(sId,SceneKind.shenshoushengyu)
    --降妖除魔没有仇恨归属
    self.hateNameText.visible = not mgr.FubenMgr:isWSJChuMo(cache.PlayerCache:getSId())
end

function BossHpView:getBossRoleId()
    return self.roleId
end

function BossHpView:setBuffsData(buffs)
    -- printt("setBuffsData",buffs)
    self.buffs = buffs
    local len = #buffs
    if self.buffListView.numItems ~= len then
        self.buffListView.numItems = len
    end
end

function BossHpView:cellBuffData(index,obj)
    local modelId = self.buffs[index + 1].modelId
    local config = conf.BuffConf:getBuffConf(modelId)
    -- printt("cellBuffData",config)
    if config and config.icon then
        -- plog(config.icon,ResPath.buffRes(config.icon))
        obj:GetChild("icon").url = ResPath.buffRes(config.icon)
    end
end

function BossHpView:onBuffItemClick()
    if self.buffs then
        local data =  mgr.BuffMgr:getBuffByid(self.roleId)
        if table.nums(data) ~= 0 then 
            mgr.ViewMgr:openView(ViewName.BuffView,function(view)
                view:setData()
            end,{roleId = self.roleId})
        end
    end
end

function BossHpView:close()
    --printt(debug.traceback())
    self.startTime = Time.getTime()
    self:releaseTimer()
    self.roleId = 0
    self:closeView()
end

return BossHpView