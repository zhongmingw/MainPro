--
-- Author: 
-- Date: 2018-07-24 14:36:54
--

local PetHelpActive = class("PetHelpActive", base.BaseView)

function PetHelpActive:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function PetHelpActive:initView()
    local btnclose = self.view:GetChild("n22")
    self:setCloseBtn(btnclose)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)

    self.btn1 = self.view:GetChild("n7")
    self.btn2 = self.view:GetChild("n8")


    --宠物排行
    local panel1 = self.view:GetChild("n18")
    self.list1 = panel1:GetChild("n7")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0


    local btnXunbao = panel1:GetChild("n9")
    btnXunbao.onClick:Add(self.onXunBao,self)
    
    local btnonRank = panel1:GetChild("n10")
    btnonRank.onClick:Add(self.onRank,self)

    local btnGuize = panel1:GetChild("n14")
    btnGuize.data = 1107
    btnGuize.onClick:Add(self.onGuize,self)

    local dec1 = panel1:GetChild("n13")
    dec1.text = language.pethelpactive01 

    local dec2 = panel1:GetChild("n16")
    dec2.text = language.pethelpactive02

    self.lab1 = panel1:GetChild("n17")
    self.lab1.text = ""

    self.time1 = panel1:GetChild("n15")
    self.time1.text = ""

    self.modelpanel = panel1:GetChild("n8")

    
    ---寻宝返回
    local panel2 = self.view:GetChild("n19")
    local btnGuize = panel2:GetChild("n2")
    btnGuize.data = 1108
    btnGuize.onClick:Add(self.onGuize,self)

    local dec1 = panel2:GetChild("n3")
    dec1.text = language.pethelpactive01 

    self.time2 = panel2:GetChild("n4")
    self.time2.text = ""

    self.list2 = panel2:GetChild("n5")
    self.list2.itemRenderer = function(index,obj)
        self:cellbackdata(index, obj)
    end
    self.list2:SetVirtual()
    self.list2.numItems = 0

end

function PetHelpActive:initData(index)
    -- body
    --检测活动开启
    self.model = nil 
    self:setRankMsg()


    local redImg = self.btn2:GetChild("n5")
    local param = {panel = redImg,ids = {20191}}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    -- local data = cache.ActivityCache:get5030111()
    -- self.btn1.visible = mgr.ModuleMgr:CheckView(1282) and data.acts[5002] and data.acts[5002] == 1
    -- self.btn2.visible = mgr.ModuleMgr:CheckView(1283) and data.acts[3072] and data.acts[3072] == 1
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

function PetHelpActive:onTimer()
    -- body
    if self.c1.selectedIndex == 0 then
        if not self.data5030220 then
            self.time1.text = ""
            return 
        end
        self.data5030220.lastTime = math.max(self.data5030220.lastTime - 1,0) 
        self.time1.text = GGetTimeData3(self.data5030220.lastTime)
        if self.data5030220.lastTime <= 0 then
            self:closeView()
        end
    else
         if not self.data5030221 then
            self.time2.text = ""
            return 
        end
        self.data5030221.lastTime = math.max(self.data5030221.lastTime - 1,0) 
        self.time2.text = GGetTimeData3(self.data5030221.lastTime)
        if self.data5030221.lastTime <= 0 then
            self:closeView()
        end
    end
end

function PetHelpActive:celldata( index, obj )
    -- body
    local data = self.condata[index+1]
    local c1 = obj:GetController("c1")
    c1.selectedIndex = index
    local rewardlist =  obj:GetChild("n4")
    rewardlist.itemRenderer = function(_index,itemObj)
        local info = data.awards[_index+1]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.isquan = true
        GSetItemData(itemObj,t,true)
    end
    rewardlist.numItems = #data.awards
end

function PetHelpActive:setRankMsg()
    -- body
    self.condata = conf.ActivityConf:getPetrankaward()
    table.sort(self.condata,function(a,b)
        -- body
        return a.id < b.id
    end)
    self.list1.numItems = #self.condata 

    --100137001
    local cansee
    self.model,cansee = self:addModel(3050436,self.modelpanel)
    self.model:setPosition(39.2,-264.6,500)
    self.model:setRotationXYZ(0,144.62,0)
end

function PetHelpActive:cellbackdata( index, obj )
    -- body
    local data = self.condataback[index+1]
    local lab = obj:GetChild("n1") 
    local str = string.format(language.pethelpactive03,data.times)  
    str = str .. "\n("..mgr.TextMgr:getTextColorStr(self.data5030221.findTimes, 7)
    str = str .. "/"..mgr.TextMgr:getTextColorStr(data.times, 14)..")"
    lab.text = str

    local rewardlist =  obj:GetChild("n2")
    rewardlist.itemRenderer = function(_index,itemObj)
        local info = data.awards[_index+1]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.isquan = true
        GSetItemData(itemObj,t,true)
    end
    rewardlist.numItems = #data.awards 

    local isget = self.itemGotData[data.id]

    local c1 = obj:GetController("c1") 
    if isget then
        c1.selectedIndex = 2
    else
        if data.times > self.data5030221.findTimes then
            c1.selectedIndex = 1
        else
            c1.selectedIndex = 0
        end
    end

    local btn =  obj:GetChild("n3") 
    btn.data = data
    btn.onClick:Add(self.onGetCall,self)
end

function PetHelpActive:onGetCall( context )
    -- body
    local data = context.sender.data
    if self.itemGotData[data.id] then
        return
    end
    if data.times > self.data5030221.findTimes then
        return GComAlter(language.pethelpactive04)
    else
        local param = {}
        param.reqType = 1
        param.cid = data.id
        proxy.ActivityProxy:sendMsg(1030221,param)
    end
    
end

function PetHelpActive:setBackMsg( ... )
    -- body
    self.condataback = conf.ActivityConf:getPetrebackaward()
    table.sort(self.condataback,function(a,b)
        -- body
        local a_isget = self.itemGotData[a.id] or 0
        local b_isget = self.itemGotData[b.id] or 0
        if a_isget == b_isget then
            return a.times < b.times 
        else
            return a_isget < b_isget
        end
    end)
    self.list2.numItems = #self.condataback 

    --刷一下红点问题
    for k ,v in pairs(self.condataback) do
        if not self.itemGotData[v.id] then
            if v.times<=self.data5030221.findTimes then
                mgr.GuiMgr:redpointByVar(20191,1,1)
                return
            end
        end
    end
    mgr.GuiMgr:redpointByVar(20191,0,1)
end

function PetHelpActive:onController()
    -- body
    if 0 == self.c1.selectedIndex then
        --寻宝排行
        proxy.ActivityProxy:sendMsg(1030220)
    else
        --寻宝返回
        proxy.ActivityProxy:sendMsg(1030221,{reqType=0,cid=0})
    end
end

function PetHelpActive:onXunBao( ... )
    -- body
    GOpenView({id = 1194})
end
function PetHelpActive:onRank( )
    -- body
    if not self.data5030220  then
        return
    end
    mgr.ViewMgr:openView2(ViewName.PetHelpRank,self.data5030220.rankInfos)
end

function PetHelpActive:onGuize(context)
    -- body
    GOpenRuleView(context.sender.data)
end
function PetHelpActive:addMsgCallBack(data)
    if 0 == self.c1.selectedIndex then
        --寻宝排行
        if 5030220 == data.msgId then
            self.data5030220 = data
            for k ,v in pairs(data.rankInfos) do
                printt("v",v)
                if v.rank == 1 then
                    self.lab1.text = v.roleName
                    break
                end
            end
        end
    elseif 1 == self.c1.selectedIndex then
        --寻宝返回
        if 5030221 == data.msgId then 
            GOpenAlert3(data.items)

            self.data5030221 = data 
            self.itemGotData = {}
            for k ,v in pairs(data.itemGotData) do
                self.itemGotData[v] = 1
            end
            self:setBackMsg()
        end
    end
end

return PetHelpActive