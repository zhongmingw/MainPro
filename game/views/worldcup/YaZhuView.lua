--
-- Author: 
-- Date: 2018-07-01 13:10:04
--

local YaZhuView = class("YaZhuView", base.BaseView)

function YaZhuView:ctor()
    YaZhuView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function YaZhuView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onBtnClose,self)
    
end
function YaZhuView:initData(data)
    if data then 
        -- printt("打开",data)
        -- local nowTime = mgr.NetMgr:getServerTime()

        -- print("结束时间",data.endTime,"nowTime",nowTime)
        self.data = data
        self.endTime = data.endTime
        local tempStakeInfo ={}
        for k,v in pairs(data.stakeInfo) do
            if data.teamId == v.teamId then
                table.insert(tempStakeInfo,v.stakeInfo)--获取所选队伍的押注信息
            end
        end
        self.stakeInfo = {}
        if next(tempStakeInfo) ~= nil then 
            for k,v in pairs(tempStakeInfo) do
                for i,j in pairs(v) do
                    if j then
                        self.stakeInfo[j] = 1
                    end
                end
            end
        end
        local hitTitle = self.view:GetChild("n4")
        local name = conf.WorldCupConf:getTeamName(data.teamId).name
        hitTitle.text = string.format(language.worldcup04,name)
        self.confData = conf.WorldCupConf:getAwardsData(data.field)
        -- printt("self.confData",self.confData)
    end

    self.modelPanel = self.view:GetChild("n5")

    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self:initModel()
    self.listView.numItems = #self.confData

end

function YaZhuView:initModel()
    self.sex = cache.PlayerCache:getSex()
    local modelId
    if self.sex == 1 then
        modelId = conf.ActivityConf:getValue("football_suit_id")
    else
        modelId = conf.ActivityConf:getValue("cheerleader_suit_id")
    end
    local modelObj1 = self:addModel(modelId[1],self.modelPanel)
    modelObj1:setSkins(modelId[1], modelId[2])
    modelObj1:setScale(220)
    modelObj1:setRotationXYZ(0,166,0)
    modelObj1:setPosition(0,-260,100)
end
function YaZhuView:cellData(index,obj)
    local data = self.confData[index+1]
    local list1 = obj:GetChild("n7")
    local list2 = obj:GetChild("n8")
    local c1 = obj:GetController("c1")
    if data then 
        local winAwards
        if data.awards_win_g then
            if self.sex == 2 then 
                winAwards = data.awards_win_g
            else
                winAwards = data.awards_win
            end
        else
            winAwards = data.awards_win
        end
        GSetAwards(list1, winAwards)
        GSetAwards(list2, data.awards_fail)
        local money = obj:GetChild("n13")
        money.text = data.stake_quota
        local sureBtn = obj:GetChild("n9")
        sureBtn.data = data
        sureBtn.onClick:Add(self.onYaZhu,self)
        if self.stakeInfo[data.id] then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end

        local nowTime = mgr.NetMgr:getServerTime()
        if nowTime > self.endTime then --已经开始比赛
            sureBtn.touchable = false
            sureBtn.grayed = true
            obj:GetChild("n10").grayed = true
            obj:GetChild("icon1").grayed = true
            obj:GetChild("n13").grayed = true
        else
            sureBtn.touchable = true
            sureBtn.grayed = false
            obj:GetChild("n10").grayed = false
            obj:GetChild("icon1").grayed = false
            obj:GetChild("n13").grayed = false

        end

    end
end
function YaZhuView:onYaZhu( context )
    local data = context.sender.data
    local field = self.data.field
    local teamId = self.data.teamId
    local needYb = data.stake_quota
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    local haveYb = ybData.amount
    if needYb > haveYb then
        GGoVipTequan(0)
        GComAlter(language.gonggong18)
        self:closeView()
        return
    end
    local nowTime = mgr.NetMgr:getServerTime()
    if nowTime > self.endTime then --已经开始比赛
        GComAlter(language.worldcup11) 
        return
    end
    proxy.ActivityProxy:sendMsg(1030501,{reqType = 1,field = field,teamId = teamId,confId = data.id})
    local str = string.format(language.worldcup13, tonumber(needYb))
    GComAlter(str) 
end


function YaZhuView:setData(data)
    self.mdata = data
    local tempStakeInfo = {}
    -- printt("压住返回",self.mdata.stakeInfos)
    for k,v in pairs(self.mdata.stakeInfos) do
        -- if self.data.field == v.field then 
        --     for _,j in pairs(v.stakeInfo) do
        --         if j then
        --             self.stakeInfo[j] = 1
        --         end
        --     end
        -- end
        if v.field == self.data.field and self.data.teamId == v.teamId then --获取所选场次的压住信息
            for i,j in pairs(v.stakeInfo) do
                table.insert(tempStakeInfo,j)
            end
        end
    end
    if next(tempStakeInfo) ~= nil then 
        for k,v in pairs(tempStakeInfo) do
            if v then
                self.stakeInfo[v] = 1
            end
        end
    end


    self.listView.numItems = #self.confData
end
function YaZhuView:onBtnClose()
    proxy.ActivityProxy:sendMsg(1030501,{reqType = 0,field = 0,teamId = 0,confId = 0})
    self:closeView()
end

return YaZhuView