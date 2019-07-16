--
-- Author: 
-- Date: 2018-08-20 20:58:28
--

local BuBuGaoSheng = class("BuBuGaoSheng", base.BaseView)

function BuBuGaoSheng:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BuBuGaoSheng:initView()
    self.closeBtn = self.view:GetChild("n0"):GetChild("n6")--关闭界面按钮
    self.goToRechargeBtn = self.view:GetChild("n139")--前往充值按钮
    self.goToRechargeBtn.onClick:Add(self.goToRecharge,self)
    self.closeBtn.onClick:Add(self.closeBtnClick,self) 
    self.rechargeOneBtn = self.view:GetChild("n11")--抽一次按钮
    self.rechargeOneBtn.data = 1
    self.rechargeOneBtn.onClick:Add(self.onBtnCallBack,self)
    self.rechargeTenBtn = self.view:GetChild("n12")--抽十次按钮
    self.rechargeTenBtn.data = 10
    self.rechargeTenBtn.onClick:Add(self.onBtnCallBack,self)

    self.activeResidueTime = self.view:GetChild("n82")--活动剩余时间文本
    self.allRecordList = self.view:GetChild("n78")--全服记录列表
    self:allRecordListInit()
    self.skipActToggle = self.view:GetChild("n13")--跳过动画

    self.act = self.view:GetTransition("t1")--抽奖动画
    self.leftRechargeNum = self.view:GetChild("n80")--剩余抽奖次数
    self.rechargeNumText = self.view:GetChild("n79")--每充值 元宝获得额外单抽次数
    self.oneRechargeText = self.view:GetChild("n132")--单抽消耗元宝
    self.tenRechargeText = self.view:GetChild("n134")--十连抽消耗元宝

    self.awardList = {}--奖励池
    for i = 85,124 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.awardList,item)
    end
    

    self.guangXiaoCom = self.view:GetChild("n140")--抽奖光效

    self.nei = {}
    self:setData()
end

function BuBuGaoSheng:timerClick()
    if not self.leftTime then
        return
    end
    if self.leftTime > 0 then
        self.leftTime = self.leftTime - 1
        self.activeResidueTime.text = GGetTimeData2(self.leftTime)
    else
        GComAlter(language.vip11)
        self:closeView()
    end
end

--[[
变量名：reqType 说明：0:显示 1:抽1次 2:抽10次
变量名：reqType 说明：0:显示 1:抽1次 2:抽10次
变量名：curGridId   说明：当前的格子id(配置id)
变量名：leftCount   说明：剩余次数
变量名：actLeftTime 说明：活动剩余时间
变量名：items   说明：获得的奖励
变量名：logs    说明：日志记录
]]
--设置奖励物品的信息
function BuBuGaoSheng:setData( )
    --从配置表里读取信息
    local awardData = conf.ActivityConf:getBBGSItem()
    self.nei = {}
    self.wai = {}
    for k,v in pairs(awardData) do
        self.awardList[k].data = v.id --记录格子id
        if v.grid_type == 1 then --起点
            self.wai[k] = k
            self.awardList[k]:GetChild("n1").text = "起点"
            self.awardList[k]:GetChild("n4").visible = false
            local itemData = {}
            itemData.isCase = true
            GSetItemData(self.awardList[k]:GetChild("n0"),itemData)
        elseif v.grid_type == 2 then --内圈点
            self.awardList[k]:GetChild("n1").text = "内圈"
            self.awardList[k]:GetChild("n4").visible = false
            local itemData1 = {}
            itemData1.isCase = true
            GSetItemData(self.awardList[k]:GetChild("n0"),itemData1)

            self.nei[k] = k 
        elseif v.grid_type == 4 then --双开点
            self.awardList[k]:GetChild("n1").text = "双开"
            self.awardList[k]:GetChild("n4").visible = false
            local itemData2 = {}
            itemData2.isCase = true
            GSetItemData(self.awardList[k]:GetChild("n0"),itemData2)
        elseif v.grid_type == 5 then --道具点
            if v.item then
                for i,j in pairs(v.item) do
                    local btn = self.awardList[k]
                    if not btn then
                        break
                    end
                    local awardItem = {}
                    awardItem.mid = j[1]
                    awardItem.amount = j[2]
                    awardItem.bind = j[3]
                    if v.effect ~= 1 then
                        awardItem.isquan = true                     
                    end
                    GSetItemData(btn:GetChild("n0"),awardItem,true)                
                end
            else
                print("@ 策划 item 没配置v.id = ",v.id )
            end
        elseif v.grid_type == 3 then --元宝点
            if v.yb_mul then 
                local btn1 = self.awardList[k]
                if not btn1 then 
                    break
                end
                btn1:GetChild("n4").text = (v.yb_mul/100).."倍"
                btn1:GetChild("n3").url = UIPackage.GetItemURL("_icons" , "gonggongsucai_112")
                local awardItem1 = {}
                awardItem1.isCase = true
                GSetItemData(btn1:GetChild("n0"),awardItem1)
            else
                print("@ 策划 yb_mul 没配置v.id = ",v.id )
            end
        else     
        end
    end
end

--初始化全服记录列表
function BuBuGaoSheng:allRecordListInit( )
    self.allRecordList.numItems = 0
    self.allRecordList.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.allRecordList:SetVirtual()
end

function BuBuGaoSheng:cellData(index,obj)
    local data  = self.data.logs[index+1]
    local textStr  = obj:GetChild("n0")
    local content = string.split(data,"|")
    local str = mgr.TextMgr:getTextColorStr(content[1],7)..mgr.TextMgr:getTextColorStr("抽中了",6)..mgr.TextMgr:getTextColorStr(conf.ItemConf:getName(content[2]),7)
    textStr.text = str
end

function BuBuGaoSheng:initData()
    -- body
    self.rechargeOneBtn.touchable = true
    if self.timer then 
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))
end

function BuBuGaoSheng:addMsg(data)
    
    if data.reqType == 0 then
        self.startPos = data.curGridId--下一次抽奖的起始位置
    else
        if not self.data then
            self.startPos = 1001
        else
            self.startPos = self.data.curGridId
        end
    end

    self.data = data
    self.allRecordList.numItems = #data.logs

    --GOpenAlert3(data.items)
    local rechargeNum = conf.ActivityConf:getValue("bbgs_yb_count")
    self.leftTime = self.data.actLeftTime
    local oneConstNum = conf.ActivityConf:getValue("bbgs_one_cost")
    if self.data.leftCount == 0 then
        self.oneRechargeText.text  = oneConstNum[2]..""
    else
        self.oneRechargeText.text = "免费"
    end
    local tenConstNum = conf.ActivityConf:getValue("bbgs_ten_cost")
    self.tenRechargeText.text = tenConstNum[2]..""
    self.activeResidueTime.text = GGetTimeData2(self.leftTime)
    self.rechargeNumText.text = mgr.TextMgr:getTextColorStr("每充值",6)..mgr.TextMgr:getTextColorStr(rechargeNum,7)..mgr.TextMgr:getTextColorStr("元宝获得额外单抽次数",6)
    self.leftRechargeNum.text = mgr.TextMgr:getTextColorStr("现有",6)..mgr.TextMgr:getTextColorStr(""..self.data.leftCount,7)..mgr.TextMgr:getTextColorStr("次机会",6)

    mgr.GuiMgr:redpointByVar(30172,data.leftCount,1)
    if data.leftCount >= 1 then
        self.rechargeOneBtn:GetChild("red").visible = true
    else
        self.rechargeOneBtn:GetChild("red").visible = false
    end

    if data.reqType == 1 then
        self:turn()
    else
        GOpenAlert3(data.items)
    end 
end

function BuBuGaoSheng:onBtnCallBack(context)
    if not self.data then
        return 
    end
    local btn  = context.sender

    if btn.name == "n11" then
        local param = {}
        param.reqType = 1
        param.leftCount = btn.data --剩余额外抽奖机会
        proxy.ActivityProxy:sendMsg(1030514,param)
    elseif btn.name == "n12" then
        local param1 = {}
        param1.reqType = 2
        param1.leftCount = btn.data
        proxy.ActivityProxy:sendMsg(1030514,param1)
    end
end

--关闭界面按钮点击
function BuBuGaoSheng:closeBtnClick( )
    self:closeView()
end

--前往充值按钮点击
function BuBuGaoSheng:goToRecharge( )
    -- body
    GOpenView({id = 1042})
end

--抽奖转圈
function BuBuGaoSheng:turn()
    if self.skipActToggle.selected then  
        GOpenAlert3(self.data.items)
        local pos = 0 
        self.guangXiaoCom.visible = true
        for k,v in pairs(self.awardList) do
            if v.data == self.data.curGridId then
                pos = k
                self.guangXiaoCom.xy = self.awardList[pos].xy
            end
        end
    else
        --print("开始动画")
        --计算停止的位置
        self.guangXiaoCom.visible = true

        local toIndex = 0
        local startPosition = 0
        for k , v in pairs(self.awardList) do
            if v.data == self.data.curGridId then
                toIndex = k
            end
            if v.data == self.startPos then
                startPosition = k
                --print("==上一次停止位置==",k,self.startPos)
                self.guangXiaoCom.xy = self.awardList[startPosition].xy
            end
        end 
        local number = #self.awardList
        local _wai = 26
        local delay = 0.1 --间隔时间

        local list = {}
        if self.data.curGridId > 2000 then
            --目标在内圈
            if self.startPos > 2000 then
                --当前内圈
                for i = startPosition , number do
                    table.insert(list,i)
                end
                
            else
                --当前外圈圈
                local flag = 0
                for i = startPosition , _wai do
                    table.insert(list,i)
                    if self.nei[i] then
                        flag = i--找到内圈点
                        break
                    end
                end
                if flag == 0 then
                    for i = 1 , _wai do
                        table.insert(list,i)
                        if self.nei[i] then
                            flag = i--找到内圈点
                            break
                        end
                    end
                end
                if flag == 0 then
                    print("居然找不到内圈点")
                end
            end
            for i = _wai + 1 , number do
                table.insert(list,i)
            end
            for i = _wai + 1 , toIndex do
                 table.insert(list,i)
            end
        else
            --目标在外圈
            if self.startPos > 2000 then
                --当前内圈
                local flag = 0
                for i = startPosition , number do
                    table.insert(list,i)
                    if self.wai[i] then
                        flag = i--找到外圈点
                        break
                    end
                end
                if flag == 0 then
                    for i = _wai + 1 , number do
                        table.insert(list,i)
                        if self.wai[i] then
                            flag = i--找到外圈点
                            break
                        end
                    end
                end
                if flag == 0 then
                    print("居然找不到内圈点")
                end
                
            else
                --当前外圈圈
                for i = startPosition , _wai do
                    table.insert(list,i)
                end
            end

            for i = 1 , _wai do
                table.insert(list,i)
            end
            for i = 1 , toIndex do
                table.insert(list,i)
            end
        end

        local max = #list
        for k ,v in pairs(list) do
            self:addTimer(delay*(k - 1), 1,function( )
                --print("v",v)
                self.guangXiaoCom.x = self.awardList[v].x - 3
                self.guangXiaoCom.y = self.awardList[v].y - 3
                self.rechargeOneBtn.touchable = false

                if k == max then
                    self:addTimer(0.5,1,function ( )
                    GOpenAlert3(self.data.items)   
                    self.rechargeOneBtn.touchable = true           
                    end)
                end
            end)
        end
    end
end

return BuBuGaoSheng