--
-- Author: 
-- Date: 2018-08-07 22:04:22
--跨服充值榜

local KuaFuChargeMain = class("KuaFuChargeMain", base.BaseView)

function KuaFuChargeMain:ctor()
    KuaFuChargeMain.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function KuaFuChargeMain:initView()
    local btnclose = self.view:GetChild("n12")
    self:setCloseBtn(btnclose)

    local ruleBtn = self.view:GetChild("n99")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    local chargeBtn = self.view:GetChild("n9")
    chargeBtn.onClick:Add(self.goCharge,self)

    local dec1 = self.view:GetChild("n31")
    dec1.text = language.kuafuCharge01

    local dec2 = self.view:GetChild("n13")
    dec2.text = language.kuafuCharge02

    local dec3 = self.view:GetChild("n15")
    dec3.text = language.kuafuCharge03

    local dec3 = self.view:GetChild("n17")
    dec3.text = language.kuafuCharge04


    local rankBtn = self.view:GetChild("n8")
    rankBtn.onClick:Add(self.onRank,self)

    self.lastTime = self.view:GetChild("n14")

    self.firstRoleName = self.view:GetChild("n16")

    self.listView = self.view:GetChild("n30")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.hasCharge = self.view:GetChild("n19")

    self.myRank = self.view:GetChild("n21")

    self.needCz = self.view:GetChild("n22")
    
    self.modlePanel = self.view:GetChild("n26")

    self.titleIcon = self.view:GetChild("n33")

end

function KuaFuChargeMain:initData()
    
end

function KuaFuChargeMain:initModel()
    --坐骑奖励
    -- model_id
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    if mulActConf then
        local modelData = mulActConf.model_id
        local modelId = modelData[1][1]
        local scale = mulActConf.model_scale_pos_rot[1][1]
        local pos = mulActConf.model_scale_pos_rot[1][2]
        local rot = mulActConf.model_scale_pos_rot[1][3]
        if modelData[2] then
            local sex = cache.PlayerCache:getSex()
            local suitId
            if sex == 1 then
                suitId = modelData[1][1]
            else
                suitId = modelData[2][1]
            end
            local weapon = mulActConf.model_weapon
            local modelObj1 = self:addModel(suitId,self.modlePanel)
            modelObj1:setSkins(suitId, weapon[1][1])
            modelObj1:setScale(scale[1])
            modelObj1:setRotationXYZ(rot[1],rot[2],rot[3])
            modelObj1:setPosition(pos[1],pos[2],pos[3])
        else
            local modelObj1 = self:addModel(modelId,self.modlePanel)
            modelObj1:setScale(scale[1])
            modelObj1:setRotationXYZ(rot[1],rot[2],rot[3])
            modelObj1:setPosition(pos[1],pos[2],pos[3])
        end
    end
    -- 时装奖励
    -- local sex = cache.PlayerCache:getSex()
    -- local suitId
    -- if sex == 1 then
    --     suitId = conf.ActivityConf:getHolidayGlobal("kf_cz_suit_man_id")
    -- else
    --     suitId = conf.ActivityConf:getHolidayGlobal("kf_cz_suit_woman_id")
    -- end
    -- local modelObj1 = self:addModel(suitId[1],self.modlePanel)
    -- modelObj1:setSkins(suitId[1], suitId[2])
    -- modelObj1:setScale(180)
    -- modelObj1:setRotationXYZ(0,166,0)
    -- modelObj1:setPosition(50,-230,320)
    -- --仙器奖励
    -- local effectId = conf.ActivityConf:getHolidayGlobal("kf_cz_zuoqi_id")
    -- local effect = self:addEffect(effectId[1], self.modlePanel)
    -- effect.LocalPosition = Vector3.New(55, -250, 800)

end

function KuaFuChargeMain:cellData(index,obj)
    local data = self.confData[index+1]
    local rank = obj:GetChild("n28")
    local awardList = obj:GetChild("n29")
    if data then
        local str = ""
        if type(data.show_rank) == "string" then
            str = data.show_rank
        else
            if data.show_rank[1] == data.show_rank[2] then
                str = string.format(language.kaifu12,data.show_rank[1])
            else
                str = string.format(language.kaifu11,data.show_rank[1],data.show_rank[2])
            end
        end
        rank.text = str
        GSetAwards(awardList,data.awards)
    end
end

function KuaFuChargeMain:setData(data)
    printt("跨服充值榜",data)
    self.data = data
    self.mulActId = data.mulActId
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    if mulActConf then
        self.confData = conf.ActivityConf:getKuafuChargeAward(mulActConf.award_pre)
        self.listView.numItems = #self.confData
        self:initModel()
        self.titleIcon.url = UIPackage.GetItemURL("kuafu" , mulActConf.title_icon)
    end

    self.hasCharge.text = data.myCzYb
    self.myRank.text = data.myRank == 0 and language.rank04 or string.format(language.kaifu12,data.myRank)

    table.sort(data.rankInfo,function(a,b)
        return a.rank < b.rank
    end)
    local needCzMin = conf.ActivityConf:getHolidayGlobal("kf_cz_min_yb")
    if data.myRank == 0 then
        local need = needCzMin-data.myCzYb
        if need == 0 then
            need = 1
        end
        if data.myCzYb >= needCzMin then
            local temp = data.rankInfo[10].quota - data.myCzYb 
            temp = temp == 0 and 1 or temp
            self.needCz.text = string.format(language.kuafuCharge07,temp)
        else
            self.needCz.text = string.format(language.kuafuCharge06,need)
        end
    elseif data.myRank == 1 then
        self.needCz.text = ""
    elseif data.myRank <= 10 then
        if data.rankInfo[data.myRank - 1] then
            local needYb = data.rankInfo[data.myRank - 1].quota - data.myCzYb
            if needYb == 0 then
                needYb = 1
            end
            self.needCz.text = string.format(language.kuafuCharge08,needYb)
        end
    elseif data.myRank > 10 then
        if #data.rankInfo >= 10 then
            local needYb = data.rankInfo[10].quota - data.myCzYb
            if needYb == 0 then
                needYb = 1
            end
            self.needCz.text = string.format(language.kuafuCharge07,needYb)
        end
    end
    local firstName = data.rankInfo[1] and data.rankInfo[1].name or language.rank03
    self.firstRoleName.text = firstName
    self.time = data.lastTime
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end


function KuaFuChargeMain:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end


function KuaFuChargeMain:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function KuaFuChargeMain:onRank()
    -- body
    if not self.data  then
        return
    end
    mgr.ViewMgr:openView2(ViewName.KuaFuChargeRank,self.data.rankInfo)
end


function KuaFuChargeMain:goCharge()
    GGoVipTequan(0)
    self:closeView()
end

function KuaFuChargeMain:onClickRule()
    GOpenRuleView(1124)
end


return KuaFuChargeMain