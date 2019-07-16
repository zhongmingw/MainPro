--
-- Author: bxp
-- Date: 2017-12-06 20:19:58
--

local ScoreStroeView = class("ScoreStroeView", base.BaseView)

function ScoreStroeView:ctor()
    ScoreStroeView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ScoreStroeView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n1")
    self.haveScoreTxt = self.view:GetChild("n6")
    self.haveScoreTxt.text = ""
    -- self:initListView()

end

function ScoreStroeView:initData(data)
    if self.data then   --这个清空是为了在切换不同的积分商城时，清空上个积分商城留下的信息
        self.data = nil
    end
    -- printt("积分商城data",data)
    self:initListView()
    if data then 
        self.haveScore = data.score
        self.haveScoreTxt.text = self.haveScore 
        self.moduleId = data.moduleId
        self:setItemData(self.moduleId)
    end
   
end

function ScoreStroeView:initListView()
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj,self.moduleId)
    end
end

function ScoreStroeView:cellData(index,obj,moduleId) 
    local key = index + 1 
    local needScore = obj:GetChild("n6")
    local itemName = obj:GetChild("n7")
    local exchangeBtn = obj:GetChild("n9")
    local itemObj = obj:GetChild("n4")
    local data = self.confData[index+1]
    if data then 
        needScore.text = data.need_score
        local itemInfo = data.item
        itemName.text = mgr.TextMgr:getColorNameByMid(itemInfo[1],itemInfo[2])
        local itemData = {mid = itemInfo[1],amount = itemInfo[2],bind = itemInfo[3]}
        if moduleId == 1362 then
            itemData.eStar = self:getStarNum(itemData.mid)
        end
        GSetItemData(itemObj, itemData, true)
        local data = {cid = data.id ,needScore = data.need_score,moduleId = moduleId }
        exchangeBtn.data = data
        exchangeBtn.onClick:Add(self.onClickget,self)
    end
end

function ScoreStroeView:getStarNum(mid)
    local colorBNum = 0
    local colorAttris = {}
    local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")

    local birthAtt = conf.ItemConf:getBaseBirthAtt(mid) or {}
    for k,v in pairs(birthAtt) do
        if k % 2 == 0 then
            local atti ={type = birthAtt[k - 1], value = birthAtt[k]}
            table.insert(colorAttris, atti)
        end
    end
    for k,v in pairs(colorAttris) do
        local confData = conf.ItemConf:getEquipColorAttri(v.type)
        local colorAtt = confData and confData.color or 0
        if colorAtt == maxColor then--最高属性品质
            colorBNum = colorBNum + 1
        end
    end
    return colorBNum
end



function ScoreStroeView:setItemData(moduleId)
    if moduleId == 1155 then 
        self.confData = conf.ActivityConf:getScoreStoreItem()
    elseif moduleId == 1163 then 
        self.confData = conf.ActivityConf:getJinJieScoreStoreItem()
    elseif moduleId == 1194 then
        self.confData = conf.ActivityConf:getPetScoreStoreItem()
    elseif moduleId == 1239 then
        self.confData = conf.ActivityConf:getShenQiScoreStoreItem()
    elseif moduleId == 1240 then
        self.confData = conf.ActivityConf:getHonghuangScoreStoreItem()
    elseif moduleId == 1267 then
        self.confData = conf.ActivityConf:getJianLingScoreStoreItem()
    elseif moduleId == 1343 then
        self.confData = conf.ActivityConf:getXianZhuangScoreStoreItem()
    elseif moduleId == 1358 then
        self.confData = conf.ActivityConf:getShengYinScoreStoreItem()
    elseif moduleId == 1362 then
        self.confData = conf.ActivityConf:getJianShenScoreStoreItem()
    elseif moduleId == 1437 then
        self.confData = conf.ActivityConf:getQiBingScoreStoreItem()   
    elseif moduleId == 1450 then
        self.confData = conf.ActivityConf:getHongMengScoreStoreItem()     
    end
    self.listView.numItems = #self.confData
end

function ScoreStroeView:onClickget(context)
    local data = context.sender.data
    local needScore = data.needScore
    local haveScore = 0
    if self.data and  self.data.score then  --这个是兑换完物品之后的分数
        haveScore = self.data.score
        -- print("这个是兑换完物品之后的分数",haveScore)
    else
        haveScore = self.haveScore   --从主界面跳转进来的分数
        -- print("从主界面跳转进来的分数",haveScore)
    end
    -- print("拥有积分",haveScore,"需要积分",needScore)
    if haveScore < needScore then --积分不足
        GComAlter(language.xunbao02)
    else
        local msg
        if data.moduleId == 1155 then 
            msg = 1030153  --装备兑换
        elseif data.moduleId == 1163 then 
            msg = 1030157  --进阶兑换
        elseif data.moduleId == 1194 then 
            msg = 1030171  --宠物兑换
        elseif data.moduleId == 1239 then 
            msg = 1030190  --神器兑换
        elseif data.moduleId == 1240 then
            msg = 1030193  --洪荒兑换
        elseif data.moduleId == 1267 then
            msg = 1030196  --剑灵兑换
        elseif data.moduleId == 1343 then
            msg = 1030247  --仙装兑换
        elseif data.moduleId == 1358 then
            msg = 1030623  --圣印兑换
        elseif data.moduleId == 1362 then
            msg = 1030631  --剑神兑换
        elseif data.moduleId == 1437 then
            msg = 1030684  --奇兵兑换
        elseif data.moduleId == 1450 then
            msg = 1030694  --鸿蒙兑换
        end
        proxy.ActivityProxy:sendMsg(msg,{cid = data.cid,amount = 1})
    end
end

function ScoreStroeView:setData(data_)  --请求兑换完物品返回的
    self.data = data_
    self.haveScoreTxt.text = self.data.score --拥有积分
end

return ScoreStroeView