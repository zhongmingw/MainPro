--
-- Author: 
-- Date: 2018-09-18 17:49:39
--

--
-- Author: wx
-- Date: 2018-09-10 16:28:35
--

local qmbz1154 = class("qmbz1154",import("game.base.Ref"))

function qmbz1154:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function qmbz1154:onTimer()
    -- body
    if not self.data then return end
    self.data.leftTime = math.max(0,self.data.leftTime - 1) 

    if self.moduleId == self.parent.param.showId then
        self.parent:setTimeLab(self.data.leftTime)
    end
end
function qmbz1154:addMsgCallBack(data)
    -- body
    if data.msgId == 5030614 then
        self.data = data 
        GOpenAlert3(data.items)
        if data.reqType == 1 then
            self.listView:RefreshVirtualList()
        else
            self.confdata = conf.ActivityConf:getQmGiftByDay(data.curDay)
            table.sort(self.confdata , function(a,b)
                -- body
                return a.id < b.id 
            end)
            self.listView.numItems = #self.confdata
        end
    end
end

function qmbz1154:initView()
    -- body
    
    self.listView = self.view:GetChild("n0")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function qmbz1154:cellData( index, obj )
    -- body
    local data = self.confdata[index+1]

    local itemobj = obj:GetChild("n8") 
    local t = {}
    t.mid = data.items[1][1]
    t.amount = data.items[1][2]
    t.bind = data.items[1][3]
    GSetItemData(itemobj, t, true)

    local dec1 = obj:GetChild("n9") 
    dec1.text = language.qmbz02

    local dec2 = obj:GetChild("n11") 
    dec2.text = data.cost

    local dec3 = obj:GetChild("n10")
    dec3.text = language.qmbz03

    local dec4 = obj:GetChild("n12")
    dec4.text = data.discount

    local dec5 = obj:GetChild("n18")
    local var = self.data.numSigns[data.id]
    dec5.text = language.qmbz04 ..  mgr.TextMgr:getTextColorStr(var, 7)

    local btn = obj:GetChild("n15")
    btn.data = data
    btn.title = ""
    btn.onClick:Add(self.onCellCall,self)

    obj:GetChild("n19").text = language.qmbz05

    local c1 = obj:GetController("c1")
    c1.selectedIndex = 0

    local c2 = obj:GetController("c2")
    if var <= 0 then
        c2.selectedIndex = 1
    else
        c2.selectedIndex = 0
    end
end

function qmbz1154:onCellCall(context)
    -- body
    if not self.data then return end
    local btn = context.sender
    local data = btn.data 
    local var = self.data.numSigns[data.id]
    if var <= 0 then
        return GComAlter(language.qmbz06)
    elseif data.discount > cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        return GComAlter(language.qmbz07)
    end
    local param = {}
    param.reqType = 1
    param.cid = data.id 
    proxy.ActivityProxy:sendMsg(1030614,param)
end



return qmbz1154



