--
-- Author: Your Name
-- Date: 2017-11-16 16:44:09
--
--BOSS有奖
local Active1052 = class("Active1052",import("game.base.Ref"))

function Active1052:ctor(param,parent)
    self.view = param
    self.parent = parent
    self:initView()
end

function Active1052:initView()
    self.timeTxt = self.view:GetChild("n6")
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    -- self.bossConf = conf.ActivityConf:getBossPriceData()
    local btnGuize = self.view:GetChild("n21")
    btnGuize.onClick:Add(self.onGuize,self)
    self.getTxt = self.view:GetChild("n22"):GetChild("n1")
    self.btnGet = self.view:GetChild("n22"):GetChild("n3")
    self.isGetImg = self.view:GetChild("n22"):GetChild("n4")
    self.listView = self.view:GetChild("n22"):GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.plies = 1--记录tarId
    self.timeTxtTab = {}--倒计时text
    self.timeTab = {}
    for i=1,3 do
        self.timeTxtTab[i] = self.view:GetChild("n"..(17+i)):GetChild("n2")
    end
end

function Active1052:onGuize()
    GOpenRuleView(1061)
end

function Active1052:onController1()
    -- if self.plies ~= 10000 + self.c1.selectedIndex + 1 then
    if self.c1.selectedIndex > #self.data.rewards then
        GComAlter(language.kaifu65)
        -- self.c1.selectedIndex = #self.data.rewards
        self.c1:SetSelectedIndex(#self.data.rewards)
        return
    end
        self.plies = 10000 + self.c1.selectedIndex + 1
        self:setBossInfo()
    -- end
end

function Active1052:onTimer()
    -- body
    if self.data then
        if self.leftTime > 0 then
            self.leftTime = self.leftTime - 1
            self.timeTxt.text = GGetTimeData2(self.leftTime)
        end
        for i=1,3 do
            if self.timeTab[i] then
                self.timeTab[i] = self.timeTab[i] - 1
                self.timeTxtTab[i].text = GTotimeString(self.timeTab[i])
            end
        end
    end
end

function Active1052:celldata( index,obj )
    local data = self.rewards[index+1]
    if data then
        local mId = data[1]
        local amount = data[2]
        local bind = data[3]
        local itemInfo = {mid = mId, amount = amount, bind = bind}
        GSetItemData(obj,itemInfo,true)
    end
end

-- 1   int8    变量名: bossStatu  说明: 精英boss1:已死亡;世界boss1:已死亡,2未刷新,3已刷新
-- 2   int32   变量名: lastRefreshTime    说明: 上一次刷新时间
-- 3   int32   变量名: nextRefreshTime    说明: 下次刷新时间
-- 4   int32   变量名: sceneId    说明: 场景id
-- 5   string  变量名: lastKillName   说明: 上一次击杀者的名字
-- 6   int32   变量名: monsterId  说明: 怪物id

--设置BOSS信息
function Active1052:setBossInfo()
    --奖励设置
    local bossConf = conf.ActivityConf:getBossPriceDataById(self.plies)
    self.rewards = bossConf.rewards
    self.listView.numItems = #self.rewards

    local bossInfos = self.data.bossPrizeInfo[self.plies]
    -- printt("BOSS信息",bossInfos)
    local severTime = mgr.NetMgr:getServerTime()
    local num = 0--当前完成数量
    for i=1,5 do
        self.view:GetChild("n1"..(2+i)).visible = false
    end
    local len = conf.ActivityConf:getPlies()
    for i=1,len do
        local cengIem = self.view:GetChild("n1"..(2+i))
        cengIem.visible = true
        local plies = 10000 + i
        local confData = conf.ActivityConf:getBossPriceDataById(plies)
        cengIem:GetChild("title").text = language.kaifu69[confData.type] .. language.kaifu70[i]
    end
    for i=1,#bossInfos.bossInfo do
        local data = bossInfos.bossInfo[i]
        local monsterId = data.monsterId
        local item = self.view:GetChild("n"..(17+i))
        local modelPanel = item:GetChild("n4")
        local lvTxt = item:GetChild("n3")
        local nameTxt = item:GetChild("n7")
        local stateImg = item:GetChild("n6")
        local leftTimeTxt = item:GetChild("n2")
        local monsterConf = conf.MonsterConf:getInfoById(monsterId)
        nameTxt.text = monsterConf.name
        
        lvTxt.text = "LV"..monsterConf.level
        -- print("当前是否刷新",data.nextRefreshTime)
        local time = data.nextRefreshTime - severTime
        if data.nextRefreshTime == -1 then
            num = num + 1
            stateImg.visible = true
            stateImg.url = UIPackage.GetItemURL("kaifu" , "bossyoujiang_003")
            leftTimeTxt.visible = false
        elseif time <= 0 then
            stateImg.visible = true
            stateImg.url = UIPackage.GetItemURL("kaifu" , "bossyoujiang_004")
            leftTimeTxt.visible = false
        else
            self.timeTab[i] = time
            leftTimeTxt.visible = true
            stateImg.visible = false
            leftTimeTxt.text = GTotimeString(data.nextRefreshTime - severTime)
            -- print("剩余刷新时间",self.timeTab[i],self.timeTxtTab[i].text)
        end
        -- print("怪物模型",monsterId,monsterConf.src)
        local modelObj = self.parent:addModel(monsterConf.src,modelPanel)--添加模型
        modelObj:setPosition(0, -150, 400)
        modelObj:setRotation(180)
        modelObj:setScale(50)
        item.data = monsterId
        item.onClick:Add(self.onClickGo,self)
    end

    
    --奖励领取
    self.btnGet.visible = true
    self.isGetImg.visible = false
    for k,v in pairs(self.data.rewards) do
        if v == self.plies then
            self.btnGet.visible = false
            self.isGetImg.visible = true
            break
        end
    end
    if num == 3 then
        self.btnGet.grayed = false
    else
        self.btnGet.grayed = true
    end
    self.getTxt.text = string.format(language.kaifu64,num)
    self.btnGet.data = num
    self.btnGet.onClick:Add(self.onClickGet,self)
end

function Active1052:onClickGo( context )
    local monsterId = context.sender.data
    -- print("跳转怪物id",monsterId)
    local bossConf = conf.ActivityConf:getBossPriceDataById(self.plies)
    if bossConf.type == 1 then
        GOpenView({id = 1049,childIndex = monsterId})
    elseif bossConf.type == 2 then
        GOpenView({id = 1128,childIndex = monsterId})
    elseif bossConf.type == 3 then
        GOpenView({id = 1135,childIndex = monsterId})
    end

end

function Active1052:onClickGet( context )
    local num = context.sender.data
    if num == 3 then
        proxy.ActivityProxy:sendMsg(1030210,{reqType = 1, tarId = self.plies})
    else
        GComAlter(language.kaifu66)
    end
end

-- 变量名：reqType 说明：0=信息，1=领取奖励
-- 变量名：rewards 说明：获取的奖励
-- 变量名：bossPrizeInfo   说明：boss信息
-- 变量名：items   说明：获得道具
-- 变量名：leftTime    说明：活动剩余时间

function Active1052:add5030210(data)
    self.data = data
    self.leftTime = data.leftTime
    -- print("剩余活动时间",data.leftTime,type(data.rewards))
    local len = conf.ActivityConf:getPlies()
    -- print("当前层数",#data.rewards,len)
    self.c1.selectedIndex = #data.rewards >= len and len-1 or #data.rewards
    self:onController1()
    self.timeTxt.text = GGetTimeData2(self.leftTime)

end 

return Active1052