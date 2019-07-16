--
-- Author: EVE
-- Date: 2017-07-26 11:53:16
-- Desc: 聚宝盆 
--
local IngotCopy = class("IngotCopy", base.BaseView)

--随机数种子
math.randomseed(tostring(os.time()):reverse():sub(1,6)) 

function IngotCopy:ctor()
    self.super.ctor(self)
    self.openTween = ViewOpenTween.scale
    -- self.uiClear = UICacheType.cacheTime
end

function IngotCopy:initParams()
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function IngotCopy:initData(data)
    self.guiddata = data
    --复制记录缓存
    self.copyRecords = {} 
    --剩余次数标志位
    self.isCopyNum = false
    --是否满足复制条件
    self.isCanCopy = false

    proxy.ActivityProxy:sendMsg(1030122,{reqType = 0})   --目的：为了从隐藏任务跳转过来时，活动倒计时显示能正常

    self.randMultiple = {1.1,1.2,1.3,1.5,1.6,1.8,2,3}  --假消息：倍数
    self.randQuata = {100,400,1000}                        --假消息：下注额度    
end

function IngotCopy:initView()
    --关闭按钮
    local btnCloseView = self.view:GetChild("n0"):GetChild("n2")
    btnCloseView.onClick:Add(self.onCloseView, self)
    --剩余次数
    self.SurplusNum = self.view:GetChild("n10")
    self.SurplusNum.text = 0
    --剩余时间
    self.SurplusTime = self.view:GetChild("n11")
    self.SurplusTime.text = ""
    --复制记录
    self.listCopyRecord = self.view:GetChild("n12")
    -- self.listCopyRecord.touchable = false
    self:initListCopy()
    --下注按钮
    self.btnBet = self.view:GetChild("n17")
    self.btnBet.title = ""
    self.btnBet.onClick:Add(self.onBet, self)
    --下注条件显示
    self.condition = self.view:GetChild("n20")
    self.condition.text = ""
    --指针动效
    self.pointer00 = self.view:GetTransition("t0")
    self.pointer01 = self.view:GetTransition("t1")
    self.pointer02 = self.view:GetTransition("t2")
    self.pointer03 = self.view:GetTransition("t3")
    self.pointer04 = self.view:GetTransition("t4")
    self.pointer05 = self.view:GetTransition("t5")
    self.pointer06 = self.view:GetTransition("t6")
    self.pointer07 = self.view:GetTransition("t7")
    self.pointer08 = self.view:GetTransition("t8")
    --指针
    self.pointer = self.view:GetChild("n2")
    --假消息生成标志位
    self.isSet = false 
    --假消息列表 
    self.disinformationList = {}   
end 
--下注
function IngotCopy:onBet()
    if self:onShowNum() then 
        self.SurplusNum.text = self.data.leftTimes-1
    else
        if self.curCopyType == 1 then
            GComAlter(language.ingotcopy15)
            GOpenView({id = 1042})
            return
        else
            local tyTime = cache.VipChargeCache:getXianzunTyTime()
            if (cache.PlayerCache:VipIsActivate(self.curCopyType-1) and tyTime ) or (not cache.PlayerCache:VipIsActivate(self.curCopyType-1) and self.curCopyType ~= 5) then  --仙尊卡未激活飘字
                -- GComAlter(language.ingotcopy01[self.curCopyType-1])
                self:onClickToXianZunView(self.curCopyType-1) --前往激活仙尊卡
            elseif self.curCopyType == 5 then 
                GComAlter(language.ingotcopy01[4])
                -- plog("??????????????????结束GG")
            end 
            return
        end
    end

    if self.temp < 0 then 
        GComAlter(language.gonggong18)
        -- --TODO 跳转到充值
        -- GOpenView({id = 1042})
    end
   
    if self.isCanCopy then 
        self.btnBet.touchable = false
        self:onPlayEffect()
        proxy.ActivityProxy:sendMsg(1030122,{reqType = 1, copyType =self.curCopyType})
    end 
end
--下注次数
function IngotCopy:onShowNum()
    if self.data.leftTimes <= 0 then      
        return false
    elseif self.data.leftTimes > 0 then 
        return true
    end 
end

--列表：初始化复制记录列表
function IngotCopy:initListCopy()
    self.listCopyRecord.numItems = 0
    self.listCopyRecord.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listCopyRecord:SetVirtual()
end

--列表：复制列表信息设置,item赋值
function IngotCopy:itemData(index, obj)
    local data = self.copyRecords[index+1]
    local textRecordItem = obj:GetChild("n0")
    textRecordItem.text = data
end

function IngotCopy:setTime()
    if timers then
        self:removeTimer(timers)
        self.timers = nil
    end

    local timers = self:addTimer(1, -1, function()
        self.data.lastTime = self.data.lastTime-1
        self.SurplusTime.text = GGetTimeData2(self.data.lastTime)
    end)
end
--下注条件显示
function IngotCopy:setCopyCondition(temp)
    if self.curCopyType == 1 then 
        if self.data.firstCz == 0 then  -- 老方法，已不能用作是否首充过得判断 cache.PlayerCache:getVipLv() < 2
            self.condition.text = language.ingotcopy15
            -- print("没有首充时")
            return
        end 
        if temp < 0 then --第一次复制时但元宝不足  
            self.condition.text = string.format(language.ingotcopy07, math.abs(temp))
            self.isCanCopy = false
            -- plog("元宝不足！差：", math.abs(temp))
            return
        end 
    end

    if self.curCopyType == 5 then --复制结束时
        self.condition.text = language.ingotcopy01[4]
        return
    end
-- 
    if self.curCopyType > 1 and self.curCopyType < 5 then 
        local tyTime = cache.VipChargeCache:getXianzunTyTime()
        if (cache.PlayerCache:VipIsActivate(self.curCopyType-1) and tyTime ) or not cache.PlayerCache:VipIsActivate(self.curCopyType-1) then     --仙尊卡未激活时
            self.condition.text = language.ingotcopy01[self.curCopyType-1]
            self.isCanCopy = false               
            return
        elseif cache.PlayerCache:VipIsActivate(self.curCopyType-1) and temp < 0 then  --仙尊卡激活但元宝不足时
            self.condition.text = string.format(language.ingotcopy07, math.abs(temp))
            self.isCanCopy = false
            return          
        end 
    end 
    -- plog("!!!!!!!!!!!!!!!!!!",temp)
    self.condition.text = language.ingotcopy08  --条件满足
    self.isCanCopy = true
end

function IngotCopy:onClickToXianZunView(data) --未激活仙尊卡时弹窗
    -- local view = mgr.ViewMgr:get(ViewName.ToXianZunView)
    -- if not view then 
    --     mgr.ViewMgr:openView2(ViewName.ToXianZunView, data)
    -- end 
    local param = {}
    param.type = 2
    local str = mgr.TextMgr:getTextColorStr(language.ingotcopy12[data], 7)
    param.richtext = string.format(language.ingotcopy11,str)
    param.sure = function()
        -- body
        if self.guiddata and self.guiddata.isGuide then
            GgoToMainTask()
        end
        GOpenView({id = 1050})
    end
    GComAlter(param) 
end

function IngotCopy:setData(data)
    -- printt(data)
    -- plog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",data.firstCz)
    self.data = data
    self.records = data.records
    self.curCopyType = data.curCopyType   --法克鱿
    self.curMultiply = data.curMultiply
    self.items = data.items
 
    local confData = self:readConfigTable()
    if confData then
        self.btnBet.title = confData.cost_item[2]   --下注花费
        local ingotCount = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        self.temp = ingotCount - confData.cost_item[2]     
    end
    self:setCopyCondition(self.temp) --下注条件显示

    self:setTime()--剩余时间

    if self.isCanCopy then
        self.SurplusNum.text = self.data.leftTimes--剩余次数
    end
    if self.isCopyNum then
        self.SurplusNum.text = self.data.leftTimes-1--剩余次数刷新，防止BUG
        self.data.leftTimes  = self.data.leftTimes-1--剩余次数更新
    end

    --当前复制记录列表信息 
    local tempNum = #self.records
    for i = 1,tempNum,1 do      
        local arrayRecords = string.split(self.records[i], "#")
        --颜色设置
        local t = clone(language.ingotcopy03)
        t[1].text = string.format(t[1].text, arrayRecords[1])
        t[3].text = string.format(t[3].text, arrayRecords[4])
        t[5].text = string.format(t[5].text, arrayRecords[2])
        t[7].text = string.format(t[7].text, arrayRecords[5])
        local str = mgr.TextMgr:getTextByTable(t)

        table.insert(self.copyRecords, i, str)
    end

    if not self.isSet then 
        self:setDisinformation()
        self.isSet = true
    end 

    for i=1,10 do  --设置假消息
        table.insert(self.copyRecords, tempNum+1, self.disinformationList[i])   
    end    

    if tempNum+10 >= 20 then  --只保留20条记录
        self.listCopyRecord.numItems = 20
    else
        self.listCopyRecord.numItems = tempNum+10
    end
end 

function IngotCopy:setDisinformation()
    local serverNumber = string.split(cache.PlayerCache:getRoleName(), ".")[1]
    for i=1,10 do  --假消息 
        local randName = conf.RoleConf:getRandName(2)      --名字
        local randQuata = self:readRandValueTable(self.randQuata)  --下注额度
        local randMultiple = self:readRandValueTable(self.randMultiple)  --倍数
        local randTotal = randQuata*randMultiple    --总额度
        local str = string.format(language.ingotcopy14,
            mgr.TextMgr:getTextColorStr(string.format(language.ingotcopy13[1][1],serverNumber,randName), 7),
            mgr.TextMgr:getTextColorStr(string.format(language.ingotcopy13[1][2],randQuata), 15),
            mgr.TextMgr:getTextColorStr(string.format(language.ingotcopy13[1][3],randMultiple), 14),
            mgr.TextMgr:getTextColorStr(string.format(language.ingotcopy13[1][4],randTotal), 15))
        table.insert(self.disinformationList, i, str)  
    end 
end

function IngotCopy:onPlayEffect()
    self.isCopyNum = true

    self.pointer00:Play()
    if not temp then 
        local temp = self:addTimer(2.25, 1, function()
            if self.curMultiply then 
                if self.curMultiply == 1100 then
                    self.pointer01:Play()
                elseif self.curMultiply == 1200 then 
                    self.pointer02:Play()
                elseif self.curMultiply == 1300 then 
                    self.pointer03:Play()
                elseif self.curMultiply == 1500 then 
                    self.pointer04:Play()
                elseif self.curMultiply == 1600 then 
                    self.pointer05:Play()
                elseif self.curMultiply == 1800 then 
                    self.pointer06:Play()
                elseif self.curMultiply == 2000 then 
                    self.pointer07:Play()
                elseif self.curMultiply == 3000 then 
                    self.pointer08:Play()
                end
            end
        end)
    end 
end
--获取表中的随机值(用于假消息)
function IngotCopy:readRandValueTable(data)
    return data[math.random(1,#data)]
end

function IngotCopy:resetPointer()
    self.pointer:TweenRotate(0,0)  --指针复位
end

function IngotCopy:setBtnTouchable()
    self.btnBet.touchable = true  --设置按钮为可用
end
--读取配置表
function IngotCopy:readConfigTable()
    local temp = conf.ActivityConf:getIngot(self.curCopyType)
    return temp
end

function IngotCopy:onCloseView()
    if self.guiddata and self.guiddata.isGuide then
        GgoToMainTask()
    end

    self:setBtnTouchable()
    self:resetPointer()

    self:closeView()
end

return IngotCopy 