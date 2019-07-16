--
-- Author: 
-- Date: 2017-07-21 20:46:05
--

local MarryFuben = class("MarryFuben",import("game.base.Ref"))

function MarryFuben:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n2")
    self:initView()
end

function MarryFuben:initView()
    self.oldTime = 0
    --副本排行
    self.listView = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    --我的排名信息
    local dec1 = self.view:GetChild("n20")
    dec1.text = language.kuafu47
    local dec1 = self.view:GetChild("n21")
    dec1.text = language.kuafu48
    local dec1 = self.view:GetChild("n22")
    dec1.text = language.kuafu49

    self.rank = self.view:GetChild("n23")
    self.rank.text = language.kuafu50

    self.labbo = self.view:GetChild("n24")
    self.labbo.text = ""

    self.labtime = self.view:GetChild("n25")
    self.labtime.text = ""
    --通关奖励
    self.listReward = self.view:GetChild("n10")
    self.listReward.itemRenderer = function(index,obj)
        self:cellRewarddata(index, obj)
    end
    local passId = Fuben.marry * 1000 + 1
    local confData = conf.FubenConf:getPassDatabyId(passId)
    self.awards = confData and confData.normal_drop or {}
    self.listReward.numItems = #self.awards

    local dec1 = self.view:GetChild("n14")
    dec1.text = language.kuafu52

    local dec1 = self.view:GetChild("n15")
    dec1.text = language.kuafu53

    local dec1 = self.view:GetChild("n16")
    dec1.text = language.kuafu54

    local dec1 = self.view:GetChild("n19")
    dec1.text = language.kuafu55

    local dec1 = self.view:GetChild("n17")
    dec1.text = language.kuafu56

    self.leftTime = self.view:GetChild("n18")
    self.leftTime.text = 0

    local btn = self.view:GetChild("n5") 
    btn.onClick:Add(self.onSure,self)

    local btnRank = self.view:GetChild("n4") 
    btnRank.onClick:Add(self.onRank,self)

    self.myModel = self.view:GetChild("n28")
    self.spouseModel = self.view:GetChild("n29")
end
--设置模型
function MarryFuben:setModel(model,sex,skins)
    local skins1 = skins and skins[1] or cache.PlayerCache:getSkins(Skins.clothes)--衣服
    local skins2 = skins and skins[2] or cache.PlayerCache:getSkins(Skins.wuqi)--武器
    local skins3 = skins and skins[3] or cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local skins5 = skins and skins[5] or cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    local modelObj
    modelObj,cansee = self.parent:addModel(skins1,model)
    modelObj:setSkins(nil,skins2,skins3)
    modelObj:setPosition(model.actualWidth/2,-model.actualHeight-70,100)
    modelObj:setRotation(RoleSexModel[sex].angle)
    modelObj:setScale(180)
    if skins5 > 0 and skins2>0 then
        modelObj:addWeaponEct(skins5.."_ui")
    end
end

function MarryFuben:celldata( index, obj )
    -- body
    local data = self.data.ranking[index+1]

    local rank = obj:GetChild("n1") 
    local name1 = obj:GetChild("n2")
    local name2 = obj:GetChild("n3")

    rank.text = data.rank
    local manName = data.manName
    if manName == "" then
        manName = language.rank03
    end
    name1.text = manName
    local ladyName = data.ladyName
    if ladyName == "" then
        ladyName = language.rank03
    end
    name2.text = ladyName
end

function MarryFuben:cellRewarddata(index,obj)
    -- body
    local award = self.awards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(obj, itemData, true)
end

function MarryFuben:onRank()
    -- body
    if not self.data then
        return
    end
    mgr.ViewMgr:openView2(ViewName.MarryFubenRank,self.data)
end

function MarryFuben:onSure()
    -- body
    if not self.data then
        return
    end
    if self.data.leftCount <= 0 then
        GComAlter(language.kuafu57)
        return
    end
    if self.oldTime == 0 or Time.getTime() - self.oldTime >= 1.2 then
        proxy.MarryProxy:sendMsg(1027102)
    end
    self.oldTime = Time.getTime()
end

function MarryFuben:addMsgCallBack(data)
    if data.msgId == 5027101 then
        self.data = data
        --排行
        table.sort(self.data.ranking,function(a, b)
            return a.rank < b.rank
        end)
        local len = #self.data.ranking
        if len <= 3 then
            for i=1,3 - len do
                local data = {
                rank = len + i
                ,manName = language.rank03
                ,ladyName = language.rank03}
                table.insert(self.data.ranking, data)
            end
        end
        self.listView.numItems = #self.data.ranking
        --我的排名信息
        if data.myRankInfo.rank == 0 then
            self.rank.text = language.kuafu50
        else
            self.rank.text = data.myRankInfo.rank
        end
        self.labbo.text = string.format(language.kuafu51,data.myRankInfo.maxBo)

        self.labtime.text = GTotimeString(data.myRankInfo.passSec)
        --
        if data.leftCount < 0 then
            self.leftTime.text = 0
        else
            self.leftTime.text = data.leftCount
        end
        local sex = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon()).sex or 0
        local spouse = 0--伴侣的性别
        if sex == 1 then
            spouse = 2
        else
            spouse = 1
        end
        self:setModel(self.myModel,sex)
        if cache.PlayerCache:getCoupleName()=="" then
        else
            self:setModel(self.spouseModel,spouse,data.tarSkins)
        end
    end
end

function MarryFuben:clear()
    self.oldTime = 0
end

return MarryFuben