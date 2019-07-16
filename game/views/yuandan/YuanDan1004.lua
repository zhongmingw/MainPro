--
-- Author: 
-- Date: 2018-12-18 14:19:48
--探索

local YuanDan1004 = class("YuanDan1004",import("game.base.Ref"))

local SceneImg = {
    [1] = "xiyingyuandan_065",
    [2] = "xiyingyuandan_066",
    [3] = "xiyingyuandan_067",
}

function YuanDan1004:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId
    self:initPanel()
end
function YuanDan1004:initPanel()
    local panelObj = self.mParent:getPanelObj(self.modelId)

    --任务列表
    self.listView = panelObj:GetChild("n21")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    --秘境列表
    self.miJingList = panelObj:GetChild("n14")
    self.miJingList.numItems = 0
    self.miJingList.itemRenderer = function (index,obj)
        self:cellMiJingData(index, obj)
    end
    self.miJingList.onClickItem:Add(self.onChangedMiJing,self)
    
    self.awardObj =  panelObj:GetChild("n12")
    self.awardGetBtn = panelObj:GetChild("n13")
    self.awardGetBtn:GetChild("red").visible = false
    self.awardGetBtn.onClick:Add(self.onGetBigAward,self)
    self.awardGetBtnC1 = self.awardGetBtn:GetController("c1")

    self.jinDuTxt = panelObj:GetChild("n11")

    self.logsList = panelObj:GetChild("n10")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

end
function YuanDan1004:onTimer()

end

function YuanDan1004:setData(data)
    -- printt("探索",data)
    self.data = data
    if data.reqType == 2 or data.reqType == 3 then
        GOpenAlert3(data.items)
    end
    self.miJingList.numItems = conf.YuanDanConf:getValue("ny_explore_scene_num")
    if not self.selectType  then
        self.selectType = 0
    end

   

    self.confData = conf.YuanDanConf:getYuanDanTanSuoDataByType(self.selectType +1)
    self.listView.numItems = #self.confData

    self.logsList.numItems = #data.record
    if data.reqType == 0  then
        --优先寻找开放的大类型探索
        local isFind = false
        for k = self.miJingList.numItems ,1,-1 do
            if self:isOpenByType(k-1) then
                isFind =true
                local cell = self.miJingList:GetChildAt(k-1)
                if cell then
                    cell.onClick:Call()
                end
                break
            end
        end
        if not isFind then
             if self.miJingList.numItems > 0 then
                local cell = self.miJingList:GetChildAt(0)
                if cell then
                    cell.onClick:Call()
                end
            end
        end
    end
    self:setSelectData()

end

function YuanDan1004:cellMiJingData(index,obj)
    local data = conf.YuanDanConf:getYuanDanTanSuoDataByType(index+1)
    if data then
        obj.title = data[1].name
        obj.data = index
    end
end

--切换秘境
function YuanDan1004:onChangedMiJing(context)
    local cell = context.data
    self.selectType = cell.data
    if self.selectType > 0 then
        if not self:isOpenByType(self.selectType) then
            GComAlter(language.yuandan14)
            --副本没有开启，将self.selectType类型复位
            self.selectType = self.oldElect or 0
            self.miJingList:AddSelection(self.oldElect or 0,false)
        else
            self:setSelectData()
            self:refreshListView()
        end
    else
        self:setSelectData()
        self:refreshListView()
    end
end

function YuanDan1004:isOpenByType(_type)
    local data = {}
    for k,v in pairs(self.data.exploreMap) do
        if math.floor(k/1000) == _type  then
            table.insert(data,v)
        end
    end
    if #data >= self.listView.numItems then
        return true
    end
    return false
end

function YuanDan1004:refreshListView()
    self.confData = conf.YuanDanConf:getYuanDanTanSuoDataByType(self.selectType +1)
    self.listView.numItems = #self.confData
    self.oldElect = self.selectType
end


function YuanDan1004:setSelectData()

    local id = "2001"..string.format("%03d",(self.selectType +1)) 
    id = tonumber(id)
    local awardConfData = conf.YuanDanConf:getTanSuoAwardData(id)
    --大奖
    local itemData = {mid = awardConfData.items[1][1],amount = awardConfData.items[1][2],bind = awardConfData.items[1][3]}
    GSetItemData(self.awardObj, itemData, true)
    --设置进度
    local data = {}
    for k,v in pairs(self.data.exploreMap) do
        if math.floor(k/1000) == self.selectType +1 then
            table.insert(data,v)
        end
    end

    self.jinDuTxt.text = string.format(language.yuandan09,#data,self.listView.numItems)
    local reqType = 1
    if self.data.bigAwardSigns[id] and self.data.bigAwardSigns[id] == 1 then
        self.awardGetBtn.title = "已领取"
        self.awardGetBtn:GetChild("red").visible = false
        self.awardGetBtnC1.selectedIndex = 2
        reqType = 3--已领取
    else

        self.awardGetBtn.title = "领 取"
        if #data >= self.listView.numItems then
            self.awardGetBtnC1.selectedIndex = 0
            self.awardGetBtn:GetChild("red").visible = true
            reqType = 2
        else
            self.awardGetBtnC1.selectedIndex = 1
            self.awardGetBtn:GetChild("red").visible = false
            reqType = 1--需要完成当前8个探索才能领取
        end
    end
    self.awardGetBtn.data = {reqType = reqType,cid = id}

end

function YuanDan1004:cellData(index,obj)
    local btn = obj:GetChild("n5")
    local bg = obj:GetChild("n1")
    bg.url = UIPackage.GetItemURL("yuandan" , SceneImg[self.selectType+1])
    local redImg = btn:GetChild("red")
    redImg.visible = false
    btn.onClick:Add(self.onClickTanSuoBtn,self)
    local icon = obj:GetChild("n3")
    local costTxt = obj:GetChild("n4")
    local data = self.confData[index+1]
    local btnC1 = btn:GetController("c1")
    if data then
        local mid = data.items[1]
        local src = conf.ItemConf:getSrc(mid)
        icon.url = ResPath.iconRes(tostring(src))
        local packData = cache.PackCache:getPackDataById(mid)
        local color = tonumber(packData.amount) >= tonumber(data.items[2]) and 10 or 14
        local str = packData.amount.."/"..data.items[2]
        costTxt.text = mgr.TextMgr:getTextColorStr(str,color)
        
        btn.title =  "探 索"
        local btnType = 1
        if self.data.exploreMap[data.id] and self.data.exploreMap[data.id] == 1 then--已探索
            if not self.data.gotSigns or (self.data.gotSigns[data.id] and self.data.gotSigns[data.id] == 0) then--未领取
                local _type = self.data.typeMap and self.data.typeMap[data.id] or 1
                if _type == 1 then
                    btn.title = "领 取"
                    btnType = 5--领取
                else
                    btn.title =  "进 入"
                    btnType = 6--进入
                end
            else
                if tonumber(packData.amount) >= tonumber(data.items[2]) then
                    btnType = 1--可探索
                else
                    btnType = 2--道具不足
                end
            end
        else--未探索
            --前一个已经探索过，或者是第一个
            if((self.data.exploreMap and self.data.exploreMap[data.id -1] and self.data.exploreMap[data.id -1] == 1) or index == 0) then
                if tonumber(packData.amount) >= tonumber(data.items[2]) then
                    btnType = 1--可探索
                else
                    btnType = 2--道具不足
                end
            else
                btnType = 3--前一个未探索
            end
        end

        if btnType == 1 or btnType == 5 or btnType == 6 then
            btnC1.selectedIndex = 0
            redImg.visible = true
        else
            btnC1.selectedIndex = 1
            redImg.visible = false
        end
        -- btn.title =  btn.title..btnType

        btn.data = {mData = data,btnType = btnType,haveAmount = packData.amount}
    end
end

function YuanDan1004:onClickTanSuoBtn(context)
    local btn = context.sender
    local data = btn.data
    -- printt("点击探索按钮",data)
    if data.btnType == 3 then--前一个未探索
        GComAlter(language.yuandan12)
    elseif data.btnType == 2 then--道具不足
        local needAllAmont = data.mData.items[2]
        local needAmont = needAllAmont -data.haveAmount
        local money = needAmont * tonumber(conf.YuanDanConf:getValue("ny_explore_cost")) 
        local param = {
            type = 14,
            richtext = string.format(language.yuandan15,needAllAmont,money,needAmont),
            sure = function()
                proxy.YuanDanProxy:sendMsg(1030682,{reqType = 1,cid = data.mData.id})
            end
        }
        GComAlter(param)
    -- elseif data.btnType == 4 then--已领取
    --     GComAlter(language.yuandan10)
    elseif data.btnType == 5 then--领取
        proxy.YuanDanProxy:sendMsg(1030682,{reqType = 2,cid = data.mData.id})
    elseif data.btnType == 6 then--进入副本
        local sId = self.data.sceneMap and self.data.sceneMap[data.mData.id]
        if sId and sId ~= 0 then
            proxy.YuanDanProxy:sendMsg(1030682,{reqType = 2,cid = data.mData.id})
            mgr.FubenMgr:gotoFubenWar(sId)
        end
    elseif data.btnType == 1 then--可探索
        proxy.YuanDanProxy:sendMsg(1030682,{reqType = 1,cid = data.mData.id})
    end
end

function YuanDan1004:cellLogData(index, obj)
    local data = self.data.record[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.yuandan06, mgr.TextMgr:getTextColorStr(rolename,10),awardsStr)
end

function YuanDan1004:onGetBigAward(context)
    local btn = context.sender
    local data = btn.data
    if data.reqType == 3 then
        GComAlter(language.yuandan10)
    elseif data.reqType == 1 then
        GComAlter(language.yuandan13)
    elseif data.reqType == 2 then
        proxy.YuanDanProxy:sendMsg(1030682,{reqType = 3,cid = data.cid})
    end
end



return YuanDan1004