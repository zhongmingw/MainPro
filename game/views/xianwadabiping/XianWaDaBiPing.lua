--
-- Author: 
-- Date: 2018-07-24 14:36:54
--

local XianWaDaBiPing = class("XianWaDaBiPing", base.BaseView)

function XianWaDaBiPing:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianWaDaBiPing:initView()
    local btnclose = self.view:GetChild("n11")
    self:setCloseBtn(btnclose)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)

    self.btn1 = self.view:GetChild("n5") --仙娃排行按钮
    self.btn2 = self.view:GetChild("n9")  --仙娃洞房返还按钮


    --仙娃排行
    local panel1 = self.view:GetChild("n1")
    self.list1 = panel1:GetChild("n3")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0


    local btnLevel = panel1:GetChild("n25")
    btnLevel.onClick:Add(self.onLevel,self)
    
    local btnonRank = panel1:GetChild("n26") 
    btnonRank.onClick:Add(self.onRank,self)

    local btnGuize = panel1:GetChild("n27")
    btnGuize.data = 1125 
    btnGuize.onClick:Add(self.onGuize,self)

    local dec1 = panel1:GetChild("n14") --活动倒计时
    dec1.text = language.XianWaDaBiPing01 

    local dec2 = panel1:GetChild("n15")--当前第一名
    dec2.text = language.XianWaDaBiPing02 

    self.lab1 = panel1:GetChild("n17") --名次
    self.lab1.text = language.rank03

    self.time1 = panel1:GetChild("n16") --时间
    self.time1.text = ""

    self.modelpanel1 = panel1:GetChild("n28")
    self.modelpanel2 = panel1:GetChild("n31")
    
    ---洞房返回
    local panel2 = self.view:GetChild("n8")
    local btnGuize = panel2:GetChild("n5")
    btnGuize.data = 1126 
    btnGuize.onClick:Add(self.onGuize,self)

   -- local dec1 = panel2:GetChild("n3") -- 活动倒计时
   -- dec1.text = language.XianWaDaBiPing01 

    self.time2 = panel2:GetChild("n4") -- 时间
    self.time2.text = ""

    self.list2 = panel2:GetChild("n2")
    self.list2.itemRenderer = function(index,obj)
        self:cellbackdata(index, obj)
    end
    self.list2:SetVirtual()
    self.list2.numItems = 0

end

function XianWaDaBiPing:initData(index)
    -- body
    --检测活动开启
    self.model = nil 
    self:setRankMsg()
    self:checkSeeBtn() -- 检测只开一个活动的情况下
    local redImg = self.btn2:GetChild("red")
    local param = {panel = redImg,ids = {30169}}
     mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    if index == self.c1.selectedIndex then
        self:onController()
    else
        self.c1.selectedIndex = index
    end
    if self.timer then
        self:removeTimer(self.timer)
    end
    self.timer = self:addTimer(1,-1,handler(self, self.onTimer))
end

function XianWaDaBiPing:checkSeeBtn()
    local data = cache.ActivityCache:get5030111()
   if  data.acts[5006] and data.acts[5006] == 1 then -- 仙娃大比拼
       self.btn1.visible = true
       if not data.acts[3085] then
         self.btn1.selected = false
       -- self.btn1.enable = false
       end
   else
       self.btn1.visible = false
       self.isMoveUp = true
   end
   if  data.acts[3085] and data.acts[3085] == 1 then --洞房返还
       self.btn2.visible = true
       if self.isMoveUp then
        self.btn2.y =  self.btn1.y
       end
   else
       self.btn2.visible = false
   end
end

function XianWaDaBiPing:onTimer()
    -- body
    if self.c1.selectedIndex == 0 then
        if not self.data5030236 then
            self.time1.text = ""
            return 
        end
        self.data5030236.lastTime = math.max(self.data5030236.lastTime - 1,0) 
        if math.floor(self.data5030236.lastTime/86400) == 0 then
            self.time1.text = GGetTimeData4(self.data5030236.lastTime)
        else
            self.time1.text = GGetTimeData3(self.data5030236.lastTime)
        end
        if self.data5030236.lastTime <= 0 then
            self:closeView()
        end
    else
         if not self.data5030237 then
            self.time2.text = ""
            return 
        end
        self.data5030237.lastTime = math.max(self.data5030237.lastTime - 1,0) 
        
        if math.floor(self.data5030237.lastTime/86400) == 0 then
            self.time2.text = GGetTimeData4(self.data5030237.lastTime)
        else
            self.time2.text = GGetTimeData3(self.data5030237.lastTime)
        end
        if self.data5030237.lastTime <= 0 then
            self:closeView()
        end
    end
end

function XianWaDaBiPing:celldata( index, obj )
    -- body
    local data = self.condata[index+1]
    local c1 = obj:GetController("c1")
    c1.selectedIndex = index
    local rewardlist =  obj:GetChild("n6")
    rewardlist.itemRenderer = function(_index,itemObj)
        local info = data.awards[_index+1] 
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3]
        -- t.isquan = true
        GSetItemData(itemObj,t,true)
    end
    rewardlist.numItems = #data.awards
end

function XianWaDaBiPing:setRankMsg()
    -- body
    self.condata = conf.ActivityConf:getXiantongpowerrank()
    table.sort(self.condata,function(a,b)
        -- body
        return a.id < b.id
    end)
    self.list1.numItems = #self.condata  
    local modelId = conf.ActivityConf:getHolidayGlobal("xt_model")
    
    self.model1 = self:addModel(modelId[1],self.modelpanel1)
    self.model1:setPosition(82,-256,600)
    self.model1:setRotationXYZ(0,179.6,0)
    self.model1:setScale(167,167,167)
    self.model2 = self:addModel(modelId[2],self.modelpanel2)
    self.model2:setPosition(47.3,-332,801)
    self.model2:setRotationXYZ(0,178,0)
    self.model2:setScale(167,167,167)
end


function XianWaDaBiPing:cellbackdata( index, obj )
    -- body
        local data = self.condataback[index+1] 
        local lab = obj:GetChild("n7")  -- 当前次数达到
        local str = string.format(language.XianWaDaBiPing03,data.count)  
        lab.text = str
        local numLab = obj:GetChild("n13")  --次数的几分之几 
        -- numLab.text = string.format(language.XianWaDaBiPing06,
        --     mgr.TextMgr:getTextColorStr(self.data5030237.currTimes, 18),--red
        --     mgr.TextMgr:getTextColorStr(data.count,7))
        numLab.text = "("..mgr.TextMgr:getTextColorStr(self.data5030237.currTimes,18)..
                      "/"..mgr.TextMgr:getTextColorStr(data.count,7)..")"
        local rewardlist =  obj:GetChild("n8")
        rewardlist.itemRenderer = function(_index,itemObj)
            local info = data.awards[_index+1]
            local t = {}
            t.mid = info[1]
            t.amount = info[2]
            t.bind = info[3]
            GSetItemData(itemObj,t,true)
        end
        rewardlist.numItems = #data.awards 
        local isget = self.itemGotData[data.count] --处理领取按钮状态
        local c1 = obj:GetController("c1") 
        if isget then
            c1.selectedIndex = 2
             numLab.text = "("..mgr.TextMgr:getTextColorStr(data.count, 7)..
                      "/"..mgr.TextMgr:getTextColorStr(data.count, 7)..")"
        else
            if data.count > self.data5030237.currTimes then
                c1.selectedIndex = 1
            else
                numLab.text = "("..mgr.TextMgr:getTextColorStr(data.count, 7)..
                      "/"..mgr.TextMgr:getTextColorStr(data.count, 7)..")"
                c1.selectedIndex = 0
            end
        end
        local btn =  obj:GetChild("n11") 
        btn.data = data
        btn.onClick:Add(self.onGetCall,self)  
end

function XianWaDaBiPing:onGetCall( context )
    -- body
    local data = context.sender.data
    if self.itemGotData[data.count] then
        return
    end
   
    if data.count > self.data5030237.currTimes then
        return GComAlter(language.XianWaDaBiPing04)
    else
        local param = {}
        param.reqType = 1
        param.cid = data.id
        proxy.ActivityProxy:sendMsg(1030237,param)
    end
end

function XianWaDaBiPing:setBackMsg( ... )
    -- body
    self.condataback = conf.ActivityConf:getDongfangaward() 
    table.sort(self.condataback,function(a,b)
        -- body
        local a_isget = self.itemGotData[a.count] or 0
        local b_isget = self.itemGotData[b.count] or 0
        if a_isget == b_isget then
            return a.count < b.count 
        else
            return a_isget < b_isget
        end
    end)
    self.list2.numItems = #self.condataback 

end

function XianWaDaBiPing:onController()
    -- body
    if 0 == self.c1.selectedIndex then
        --仙娃排行
        proxy.ActivityProxy:sendMsg(1030236) 
    else
        --洞房返回
        proxy.ActivityProxy:sendMsg(1030237,{reqType=0,cid=0})
    end
end

function XianWaDaBiPing:onLevel( ... )
    -- body
    GOpenView({id = 1304})
end
function XianWaDaBiPing:onRank( )
    -- body
    if not self.data5030236  then 
        return
    end
    mgr.ViewMgr:openView2(ViewName.XianWaRankBang,self.data5030236.rankInfos) 
end

function XianWaDaBiPing:onGuize(context)
    -- body
    GOpenRuleView(context.sender.data)
end
function XianWaDaBiPing:addMsgCallBack(data) 
    if 0 == self.c1.selectedIndex then
        --仙娃排行
        if 5030236 == data.msgId then 
            self.data5030236 = data   
            for k ,v in pairs(data.rankInfos) do
                printt("v",v)
                if v.rank == 1 then
                    self.lab1.text = v.name
                    break
                end
            end
        end
    elseif 1 == self.c1.selectedIndex then
        --洞房返回
        if 5030237 == data.msgId then  
            GOpenAlert3(data.items)  

            self.data5030237 = data 
            self.itemGotData = {}
            for k ,v in pairs(data.itemGotData) do 
                self.itemGotData[v] = 1
            end
            self:setBackMsg()
        end
    end
end

return XianWaDaBiPing