--
-- Author: EVE
-- Date: 2017-08-29 11:00:37
--

local ActiveTree = class("ActiveTree", base.BaseView)

--随机数种子
-- math.randomseed(tostring(os.time()):reverse():sub(1,6))

function ActiveTree:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
    self.isBlack = true
end

function ActiveTree:initData()
    self:initModel() --模型添加
    self.timeMark = false --时间显示标志位
end

function ActiveTree:initView()
    local btnClose = self.view:GetChild("n24"):GetChild("n13")
    btnClose.onClick:Add(self.onCloseView, self)

    self.time = self.view:GetChild("n27") --倒计时
    self.time.text = ""

    self.treeLv = self.view:GetChild("n29") --树等级
    self.treeLv.text = ""

    self.once = self.view:GetChild("n31") --浇水一次
    self.once.text = ""
    self.btnOnce = self.view:GetChild("n19")
    self.btnOnce.data = {status = 1}
    self.btnOnce.onClick:Add(self.onWatering, self)

    self.many = self.view:GetChild("n32") --浇水多次
    self.many.text = ""
    local btnMany = self.view:GetChild("n20")
    btnMany.data = {status = 2}
    btnMany.onClick:Add(self.onWatering, self)

    local btnLookReward = self.view:GetChild("n11")  --查看奖励
    btnLookReward.onClick:Add(self.onLookReward, self)

    self.progress = self.view:GetChild("n25") --进度条

    self.freeTimes = self.view:GetChild("n30") --免费次数显示
    self.freeTimes.text = ""

    self.animList = {} --果子动效列表
    for i=1,5 do 
        local temp = self.view:GetTransition("t"..i)
        table.insert(self.animList, temp)
    end

    self.treeLvRewardList = self.view:GetChild("n23") --树等级奖励列表
    self:initListRewardView()

    self.isGet = false --是否已经领取

    self.modelPos = self.view:GetChild("n33") --模型的父物体
    
    self.confData = conf.ActivityConf:getTreeConfData() --配置表
    self.fruitConfData = conf.ActivityConf:getFruitRewardList() --果子配置

    local mark = self.view:GetChild("n46") -- 规则弹窗
    mark.onClick:Add(self.onGuize, self)
end

function ActiveTree:onGuize()
    -- body
    GOpenRuleView(1045)
end

function ActiveTree:initModel()
    local confModel = conf.ActivityConf:getModel() --模型配置

    if not confModel then 
        return
    end 

    if confModel[1].model[2] == 1 then 
        local body = cache.PlayerCache:getSkins(Skins.clothes)--衣服载体 
        local weapon = cache.PlayerCache:getSkins(Skins.wuqi)--衣服载体 
        if weapon == 0 then weapon = 3020101 end  --设置一把默认武器

        self.model = self:addModel(body, self.modelPos)
        self.model:setSkins(nil, weapon, confModel[1].model[1]) --添加翅膀

        self.model:setPosition(confModel[1].pos[1],confModel[1].pos[2],confModel[1].pos[3])
        self.model:setRotationXYZ(confModel[1].rotate[1],confModel[1].rotate[2],confModel[1].rotate[3])
        self.model:setScale(confModel[1].scale[1])

        --神兵特效加到武器上
        self.model:addWeaponEct(confModel[2].model[1].."_ui")
    end 
end

function ActiveTree:initListRewardView()
    self.treeLvRewardList.numItems = 0
    self.treeLvRewardList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.treeLvRewardList:SetVirtual()
end

function ActiveTree:itemData(index,obj)
    local data = self.confData[index+1]

    local reward = obj:GetChild("n0")
    local mId = data.awards[1][1]
    local number = data.awards[1][2]
    local bind = data.awards[1][3]
    infoReward = {mid=mId,amount=number,bind=bind}
    
    local sign = obj:GetChild("n2")
    local num = 16+index
    sign.url = UIPackage.GetItemURL("activetree" , "qibaomiaoshu_0"..num)
    if index == 6 then obj:GetChild("n1").visible = false end 
    
    reward.onClick:Clear()
    if self.gotList[index+1] then --已经领取
        self.isGet = false 
        obj:GetChild("n3").visible = true
        obj:GetChild("n4").visible = true
        obj.touchable = false
        -- plog("已经领取：",index+1)
        obj:GetChild("n5").visible = false
    elseif index+1 > self.data.curLevel then   --只可查看
        obj:GetChild("n3").visible = false
        obj:GetChild("n4").visible = false
        self.isGet = true
        obj.touchable = true
        -- plog("只能查看：",index+1)
        obj:GetChild("n5").visible = false
    else 
        self.isGet = false    
        obj:GetChild("n3").visible = false
        obj:GetChild("n4").visible = false
      
        obj.data = {status = index, obj = obj} --领取按钮
        obj.onClick:Add(self.onClickItem,self)
        obj.touchable = true
        -- plog("可以领取：",index+1,self.isGet)
        obj:GetChild("n5").visible = true
    end  

    GSetItemData(reward,infoReward,self.isGet) 
end

function ActiveTree:onClickItem(context)
    local itemObj = context.sender.data
    -- plog("领取：", itemObj.status)
    -- printt(itemObj)
    if itemObj.status+1 <= self.data.curLevel then
        proxy.ActivityProxy:sendMsg(1030145,{reqType=5,cfgId=itemObj.status})
        itemObj.obj:GetChild("n3").visible = true
        itemObj.obj:GetChild("n4").visible = true
    end
end

function ActiveTree:setTime(data) --计时器【优化版】
    if not self.data then 
        self.time.text = ""
        return
    end 

    if timers then
        self:removeTimer(timers)
        timers = nil
    end 

    local timers = self:addTimer(1, -1, function()
        data = data - 1
        if data < 0 then
            self.time.text = language.tree01
            return
        end
        self.time.text = GGetTimeData2(data)
    end)
end

function ActiveTree:onWatering(context) --浇水
    if self.data.curLevel >= 7 then
        GComAlter(language.tree04)
        return
    end

    local status = context.sender.data.status
    if status == 1 then          
        proxy.ActivityProxy:sendMsg(1030145,{reqType=2})
    else
        proxy.ActivityProxy:sendMsg(1030145,{reqType=3})
    end 
     -- plog("浇水~~~~~~~~~~~~~~",status)
end 

--根据物品id返回得到的果子的类型
function ActiveTree:getFruitById(data1,data2)
    for _,v in pairs(self.fruitConfData) do
        for _,j in pairs(v.awards) do
            if j[1] == data1 and j[2] == data2 then
                -- plog("找到对应果子：",v.id,data1,data2,"果子编号：",v.id - 995)
                return v.id
            end 
         end 
    end
end
--播放对应果子的动效和特效
function ActiveTree:playEffect(data)
    -- local tempIndex = math.random(1,#self.animList) --播放果子动效
    local fruit = self.view:GetChild("n"..(data-995))
    -- local savePos = fruit.xy
    self.animList[data-1000]:Play()
    
    if effect then  --播放果子炸裂特效
        self:removeUIEffect(effect)
        self.temp = nil
    end
    -- plog(data-962,"特效编号")
    local curTemp = data-995 
    local effectNum = 0
    if curTemp == 10 then 
        effectNum = 39
    elseif curTemp == 9 then 
        effectNum = 40
    elseif curTemp == 8 then 
        effectNum = 41
    elseif curTemp == 7 then 
        effectNum = 42
    elseif curTemp == 6 then 
        effectNum = 43
    end 

    self.temp = self.view:GetChild("n"..effectNum)
    local effect = nil
    self:addTimer(0.5, 1, function()
        effect = self:addEffect(4020106,self.temp)
    end)

    -- self:addTimer(1.25, 1, function()  --播放完成后，果子位置还原，防止回不去的情况    
    --     fruit.xy = savePos
    -- end)
end

--保存特效位置，用于飘道具
function ActiveTree:savePos()
    if self.temp and self.data.reqType == 2 then 
        return self.temp.xy
    else
        return false
    end 
end

function ActiveTree:setProgressBar(data) --进度条
    if self.data.curLevel == 7 then
        self.progress.max = self.confData[self.data.curLevel].need_exp
        self.progress.value = self.confData[self.data.curLevel].need_exp
    else
        self.progress.max = self.confData[self.data.curLevel+1].need_exp
        self.progress.value = data
    end
end

function ActiveTree:setData(data)
    -- printt(data)
    -- -- printt(data.items)
    -- -- printt(data.items[1])
    -- plog("树苗了个树苗")

    self.data = data 
    self.gotList = {}
    for _,v in pairs(self.data.gotList) do
        if v then 
            self.gotList[v] = v
        end
    end

    if data.items[1] and data.reqType == 2 then 
        local temp = self:getFruitById(data.items[1].mid,data.items[1].amount)  --得到果子编号
        self:playEffect(temp) --播放果子动画
    end 

    if data.reqType ~= 4 and not self.timeMark then
        self:setTime(self.data.lastTime) --活动倒计时
        self.timeMark = true
    end 

    self.treeLvRewardList.numItems = #self.confData - 1

    self.freeTimesconfData = conf.ActivityConf:getFreeTimesData() --免费抽奖信息
    self.freeTimes.text = string.format(language.tree03, self.freeTimesconfData[1],self.freeTimesconfData[2])

    self.treeLv.text = self.data.curLevel --树等级

    if self.data.curLevel ~= 7 then   --浇水花费
        if self.data.leftTimes == 0 then
            self.view:GetChild("n21").visible = true
            self.once.text = self.confData[self.data.curLevel+1].cost 
            self.once.xy = Vector2.New(382, 532)
            self.many.text = self.confData[self.data.curLevel+1].cost*10

            self.btnOnce:GetChild("red").visible = false
        else
            self.view:GetChild("n21").visible = false            
            self.once.text = language.tree05
            self.once.xy = Vector2.New(352, 532)
            self.many.text = self.confData[self.data.curLevel+1].cost*(10-self.data.leftTimes)

            --免费时设置红点
            self.btnOnce:GetChild("red").visible = true
        end 
    else
        self.once.text = self.confData[self.data.curLevel].cost 
        self.many.text = self.confData[self.data.curLevel].cost*10
    end

    self:setProgressBar(self.data.exp) --成长进度条
end

function ActiveTree:onLookReward()  
    local view = mgr.ViewMgr:get(ViewName.ActiveTreePopupView)
    if not view then 
        proxy.ActivityProxy:sendMsg(1030145,{reqType=4})
    end 
end

function ActiveTree:onCloseView()
    cache.PlayerCache:setAttribute(30122,self.data.curLevel)
    GIsOpenWishPop(30122)
    self:closeView()
end

return ActiveTree