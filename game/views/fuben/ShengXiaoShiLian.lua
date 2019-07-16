--
-- Author: Your Name
-- Date: 2019-01-02 14:40:47
--生肖试炼
local ShengXiaoShiLian = class("ShengXiaoShiLian",import("game.base.Ref"))
local ATTRDATA = {--相冲属性对应
    [550] = 556,
    [551] = 557,
    [552] = 558,
    [553] = 559,
    [554] = 560,
    [555] = 561,
    [556] = 550,
    [557] = 551,
    [558] = 552,
    [559] = 553,
    [560] = 554,
    [561] = 555,
}

function ShengXiaoShiLian:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ShengXiaoShiLian:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(1448)
    --规则按钮
    local guizeBtn = panelObj:GetChild("n8")
    guizeBtn.onClick:Add(self.onClickGuiZe,self)
    --奖励预览按钮
    self.previewBtn = panelObj:GetChild("n22")
    self.previewBtn.onClick:Add(self.onClickPreview,self)
    --奖励列表
    self.awardsList = panelObj:GetChild("n14")
    self.awardsList:SetVirtual()
    self.awardsList.itemRenderer = function(index,obj)
        self:awardData(index, obj)
    end
    self.awardsList.numItems = 0
    --boss模型panel
    self.modelPanel = panelObj:GetChild("n33")
    --生肖名字
    self.sxNameTxt = panelObj:GetChild("n29")
    --当前生肖BOSS等级
    self.sxLvTxt = panelObj:GetChild("n30")
    --下一BOSS等级
    self.nextBossDec = panelObj:GetChild("n23")
    self.nextBossLv = panelObj:GetChild("n26")
    --升级所需
    self.needDec = panelObj:GetChild("n24")
    self.needTxt = panelObj:GetChild("n27")
    --当前生肖之力
    self.myPowerDec = panelObj:GetChild("n25")
    self.myPowerTxt = panelObj:GetChild("n28")
    --生肖相冲
    self.decTxt = panelObj:GetChild("n32")
    --购买次数按钮
    local buyBtn = panelObj:GetChild("n9")
    buyBtn.onClick:Add(self.onClickBuyCount,self)
    --前往挑战
    local gowarBtn = panelObj:GetChild("n11")
    gowarBtn.onClick:Add(self.onClickGoWar,self)
    --生肖背包
    local packBtn = panelObj:GetChild("n10")
    packBtn.onClick:Add(self.onClickPack,self)

    --左侧列表
    self.listView = panelObj:GetChild("n13")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onClickInfo,self)
    self.leftCountTxt = panelObj:GetChild("n19")
end

--设置左侧list
function ShengXiaoShiLian:initList()
    --自己的生肖之力
    local allAttrs = conf.ShengXiaoConf:getAllSpecialAttrs()
    self.myAttris = {}
    for k,v in pairs(GConfDataSort(allAttrs)) do
        self.myAttris[v[1]] = v[2]
    end
    printt("myAttris>>>>>>>>>>>>>>>",self.myAttris)
    self.confData = conf.FubenConf:getSxslFuBenData()
    self.listView.numItems = #self.confData
    if self.confData and #self.confData > 0 then
        local cell = self.listView:GetChildAt(0)
        cell.onClick:Call()
    end
end

function ShengXiaoShiLian:setData( data )
    self.leftPlayTimes = data.leftPlayTimes--剩余挑战次数
    self.leftCountTxt.text = self.leftPlayTimes
    self.buyTimes = data.buyTimes--已购买次数
    print("已购买次数>>>>>>>>",self.buyTimes)
    self:initList()
end

function ShengXiaoShiLian:cellData(index, cell)
    local data = self.confData[index+1]
    if data then
        local tabIcon = cell:GetChild("n0")
        local nameTxt = cell:GetChild("n2")
        local lvTxt = cell:GetChild("n3")
        local dayTxt = cell:GetChild("n4")
        local lastTimeTxt = cell:GetChild("n5")
        lastTimeTxt.text = ""
        tabIcon.url = UIPackage.GetItemURL("fuben", data.tab_icon)
        local open_weekday = data.open_weekday
        local netTime = mgr.NetMgr:getServerTime()
        local day = GGetWeekDayByTimestamp(netTime)--当前是周几
        if day == 0 then
            day = 7
        end
        local str = ""
        local flag = false--当前天是否开启
        for k,v in pairs(open_weekday) do
            if v == day then
                flag = true
            end
            if k == #open_weekday then
                str = str .. language.gonggong134[v]
            else
                str = str .. language.gonggong134[v] .. "、"
            end
        end
        if flag then
            dayTxt.visible = false
            lastTimeTxt.visible = true
        else
            dayTxt.visible = true
            lastTimeTxt.visible = false
            dayTxt.text = language.fuben245 .. str .. language.fuben246
        end
        nameTxt.text = data.name
        --当前关卡信息
        local fbId = self:getPassInfo(data.id)
        local fubenData = conf.FubenConf:getPassDatabyId(fbId)
        local monsterId = fubenData.pass_con[1][1]
        local monsterData = conf.MonsterConf:getInfoById(monsterId)
        if monsterData then
            local textData = {
                {text = "Lv.",color = 5},
                {text = monsterData.level,color = 4},
            }
            lvTxt.text = mgr.TextMgr:getTextByTable(textData)
        end
        data.flag = flag
        cell.data = data
    end
end

function ShengXiaoShiLian:onTimer()
    local num = self.listView.numItems
    if self.confData and num > 0 then
        for i=1,#self.confData do
            local cell = self.listView:GetChildAt(i-1)
            if cell then
                local data = cell.data
                local timeTxt = cell:GetChild("n5")
                local flag = false
                local netTime = mgr.NetMgr:getServerTime()
                local day = GGetWeekDayByTimestamp(netTime)--当前是周几
                if day == 0 then
                    day = 7
                end
                for k,v in pairs(data.open_weekday) do
                    if day == v then
                        flag = true
                    end
                end
                local timeData = os.date("*t", netTime)
                local endTime = GToTimestampByDayTime(timeData.day+1,timeData.month,timeData.year,0,0)
                if flag then
                    timeTxt.text = language.fuben247 .. GTotimeString(endTime - netTime)
                end
            end
        end
    end
end

--当前属性对应关卡信息
function ShengXiaoShiLian:getPassInfo(id)
    -- body
    --关卡信息
    local confData = conf.FubenConf:getSxslPassById(id)
    local fbId,nextFbId,nextId = nil
    
    for _,v in pairs(confData) do
        if v.xx_power then
            --自己是否达到生肖之力要求--[[550,300],[551,300],[552,300],[556,300],[557,300],[558,300]]
            local flag = true
            for k,attris in pairs(v.xx_power) do
                local myAttr = self.myAttris[ATTRDATA[attris[1]]] or 0
                if myAttr >= attris[2] then
                    flag = true
                else
                    flag = false
                    break
                end
            end
            if flag then
                fbId = v.pass_id
            else
                nextId = v.id
                nextFbId = v.pass_id
                break
            end
        else
            fbId = v.pass_id
        end
    end
    return fbId,nextFbId,nextId
end

function ShengXiaoShiLian:setInfo(data)
    self.sxNameTxt.text = data.name
    self.decTxt.text = language.fuben241 .. data.enemy_name
    --关卡信息
    local fbId,nextFbId,nextId = self:getPassInfo(data.id)

    
    -- print("当前副本id>>>>>>>>",fbId,id,nextFbId,nextId)
    --当前副本关卡
    local fubenData = conf.FubenConf:getPassDatabyId(fbId)
    local monsterId = fubenData.pass_con[1][1]
    local monsterData = conf.MonsterConf:getInfoById(monsterId)
    if monsterData then
        local textData = {
                {text = "Lv.",color = 5},
                {text = monsterData.level,color = 4},
            }
        self.sxLvTxt.text = mgr.TextMgr:getTextByTable(textData)
        self.awardsData = monsterData.normal_drop or {}
        self.awardsList.numItems = #self.awardsData
        --boss模型
        -- print("怪物id>>>>>>>>>>",monsterId)
        local modelObj = self.mParent:addModel(monsterData.src,self.modelPanel)--添加模型
        modelObj:setPosition(0,-147,430)
        if 3070984 == monsterData.src then
            modelObj:setRotation(185)
        else
            modelObj:setRotation(145)
        end
        modelObj:setScale(100)
    end

    self.myPowerDec.text = string.format(language.fuben243,data.enemy_name)

    --下一等级副本关卡
    if nextFbId then
        local nextFubenData = conf.FubenConf:getPassDatabyId(nextFbId)
        local nextMonsterData = conf.MonsterConf:getInfoById(nextFubenData.pass_con[1][1])
        if nextMonsterData then
            self.nextBossDec.text = language.fuben248
            self.nextBossLv.text = nextMonsterData.level .. language.gonggong43
        end
        local nextPassData = conf.FubenConf:getSxslPassDataById(nextId)
        local passPower = nextPassData.xx_power

        self.needDec.text = string.format(language.fuben242,data.enemy_name)
        if nextPassData.xx_power then
            self.needTxt.text = nextPassData.xx_power[1][2]
        else
            self.needTxt.text = 0
        end
        local myAttr = 9999999
        for k,v in pairs(nextPassData.xx_power) do
            local temp = self.myAttris[ATTRDATA[v[1]]] or 0
            if myAttr > temp then
                myAttr = temp
            end
        end
        self.myPowerTxt.text = myAttr
    else
        self.needDec.text = ""
        self.needTxt.text = ""
        local fbPassData = conf.FubenConf:getSxslPassDataById(fbId)
        local myAttr = 9999999
        for k,v in pairs(fbPassData.xx_power) do
            local temp = self.myAttris[ATTRDATA[v[1]]] or 0
            if myAttr > temp then
                myAttr = temp
            end
        end
        self.myPowerTxt.text = myAttr
        self.nextBossDec.text = language.fuben249
        self.nextBossLv.text = monsterData.level .. language.gonggong43
    end

end

function ShengXiaoShiLian:awardData( index, obj )
    local data = self.awardsData[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2]}
        GSetItemData(obj,itemInfo,true)
    end
end

function ShengXiaoShiLian:onClickPreview( context )
    local data = context.sender.data
    if not data then
        return
    end
    mgr.ViewMgr:openView2(ViewName.ShengXiaoAwards, data)
end

function ShengXiaoShiLian:onClickInfo( context )
    local data = context.data.data
    if not data then
        return
    end
    self.sceneId = data.id
    self.isOpen = data.flag
    self.previewBtn.data = {id = data.id}
    self:setInfo(data)
end

--购买次数
function ShengXiaoShiLian:onClickBuyCount()
    print("购买次数")
    local costNum = conf.FubenConf:getValue("sxsl_buy_cost")
    local vipLv = cache.PlayerCache:getVipLv()
    local canBuyTimes = conf.VipChargeConf:getShengXiaoBuyCount(vipLv)
    --sxsl_buy_cost
    local costType = costNum[1]
    local myMoney = 0
    for k,v in pairs(BuyMoneyType[costType]) do
        local money = cache.PlayerCache:getTypeMoney(v)
        myMoney = myMoney + money
    end
    if canBuyTimes <= self.buyTimes then
        GComAlter(language.yjts19)
    elseif myMoney < costNum[2] then
        GComAlter(language.gonggong18)
    else
        local param = {}
        local textData = clone(language.fuben244)
        textData[2].text = string.format(textData[2].text,costNum[2])
        textData[7].text = string.format(textData[7].text,canBuyTimes - self.buyTimes)
        local str = mgr.TextMgr:getTextByTable(textData)
        param.richText = str
        param.func = function()
            proxy.FubenProxy:send(1028302)
        end
        mgr.ViewMgr:openView2(ViewName.YiJiTanSuoTips, param)
    end
end

--刷新购买次数
function ShengXiaoShiLian:refreshBuyTimes(data)
    self.buyTimes = data.buyTimes
    self.leftPlayTimes = data.leftPlayTimes
    self.leftCountTxt.text = self.leftPlayTimes
end

--前往挑战
function ShengXiaoShiLian:onClickGoWar()
    if not self.sceneId then
        return
    end
    if self.isOpen then
        if self.leftPlayTimes > 0 then
            mgr.FubenMgr:gotoFubenWar(self.sceneId)
        else
            GComAlter(language.fuben155)
        end
    else
        GComAlter(language.fuben251)
    end
end

--跳转生肖背包
function ShengXiaoShiLian:onClickPack()
    GOpenView({id = 1442})
end

function ShengXiaoShiLian:addMsgCallBack( data )
    if data.msgId == 5028301 then--
        self:setData(data)
    elseif data.msgId == 5028302 then
        
    end
end

function ShengXiaoShiLian:onClickGuiZe()
    GOpenRuleView(1173)
end

return ShengXiaoShiLian