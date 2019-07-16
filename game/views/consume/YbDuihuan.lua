--
-- Author: 
-- Date: 2018-09-04 17:41:16
--

local YbDuihuan = class("YbDuihuan", base.BaseView)

function YbDuihuan:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function YbDuihuan:initView()
    local btn = self.view:GetChild("n10")
    self:setCloseBtn(btn)

    self.lab1 = self.view:GetChild("n16")
    local dec1 = self.view:GetChild("n17")
    dec1.text = language.ybdh02 
    self.money = self.view:GetChild("n19")

    self.awardList = self.view:GetChild("n15")
    
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList:SetVirtual()

    self.condata = {}
end

function YbDuihuan:initData(data)
    self.mulActId = data.mulActId
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActId)
    if mulActConf then
        self.condata = conf.ActivityConf:getYbdh(mulActConf.award_pre)
        table.sort(self.condata,function(a,b)
            -- body
            return a.id <b.id
        end)
        self.awardList.numItems = #self.condata
    end
    if data then
        self:addMsgCallBack(data)
    end

    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"ActXunBaoRank")
end

function YbDuihuan:onTimer( ... )
    -- body
    if not self.data then return end 
    self.data.leftTime = math.max(self.data.leftTime - 1,0)
    if self.data.leftTime <= 0 then
        self:closeView()
        return
    end
    self.lab1.text = language.ybdh01 .. mgr.TextMgr:getTextColorStr(GGetTimeData4(self.data.leftTime), 10)  
end

function YbDuihuan:cellAwardData( index, obj )
    -- body
    local data = self.condata[index+1]

    local lab1 = obj:GetChild("n6")
    lab1.text = string.format(language.ybdh03,data.item[1][2])

    local itemObj = obj:GetChild("n5")
    local t = {}
    t.mid = data.item[1][1]
    t.amount = data.item[1][2]
    t.bind = data.item[1][3]
    GSetItemData(itemObj, t, true)

    local lab2 = obj:GetChild("n12") 
    lab2.text = data.need_num

    local lab2 = obj:GetChild("n8") 
    lab2.text = string.format(language.ybdh04,data.quota)

    local btn = obj:GetChild("n9")
    btn.data = data 
    btn.onClick:Add(self.onCellBtnCall,self)

    local c1 =obj:GetController("c1")
    if self.data and self.data.gotSigns[data.id] then
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
    end
end

function YbDuihuan:onCellBtnCall(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if not self.data then
        return
    end 
    if self.data.gotSigns[data.id] then
        return GComAlter(language.ybdh05)
    end
    if self.data.czYb >= data.quota then
        local param = {}
        param.reqType = 1
        param.cid = data.id 
        proxy.ActivityProxy:sendMsg(1030522,param)
    else
        GOpenView({id = 1042})
        --GComAlter(language.skill11)
    end
end

function YbDuihuan:addMsgCallBack( data )
    -- body
    self.data = data
    self.money.text = data.czYb

    self.awardList:RefreshVirtualList()

    local number = 0 
    for k ,v in pairs(self.condata) do
        if not self.data.gotSigns[v.id] and self.data.czYb >= v.quota then
            number = 1
            break
        end
    end
    mgr.GuiMgr:redpointByVar(30182,number,1)
end

return YbDuihuan