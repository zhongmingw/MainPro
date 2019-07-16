--
-- Author: 
-- Date: 2018-09-18 17:53:27
--

local qmbz1155 = class("qmbz1155",import("game.base.Ref"))

function qmbz1155:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function qmbz1155:onTimer()
    -- body
    if not self.data then return end

    self.data.leftTime = math.max(0,self.data.leftTime - 1) 

    if self.moduleId == self.parent.param.showId then
        self.parent:setTimeLab(self.data.leftTime)
    end
end
function qmbz1155:addMsgCallBack(data)
    -- body

    if data.msgId == 5030615 then
        self.data = data 
        GOpenAlert3(data.items)
        table.sort(self.condata,function(a,b)
            -- body
            local a_isget = self.data.gotSigns[a.id] 
            local b_isget = self.data.gotSigns[b.id]

            if self.data.gotSigns[a.id] then
                a_isget = 2
            elseif a.quota > self.data.costSum then
                a_isget = 1
            else
                a_isget = 0
            end

            if self.data.gotSigns[b.id] then
                b_isget = 2
            elseif b.quota > self.data.costSum then
                b_isget = 1
            else
                b_isget = 0
            end

            if a_isget ~= b_isget then
                return a_isget < b_isget
            else
                return a.id < b.id
            end
        end)
        
        self.listView.numItems = #self.condata

        --红点计算
        local number = 0
        for k,v in pairs(self.condata) do
            if not self.data.gotSigns[v.id] and v.quota <=  self.data.costSum then
                number = 1
                break
            end
        end
        mgr.GuiMgr:redpointByVar(30211,number,1)

    end
end

function qmbz1155:initView()
    -- body
    self.condata = conf.ActivityConf:getCostRebate()

    self.listView = self.view:GetChild("n0")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function qmbz1155:cellData( index, obj )
    -- body
    local data = self.condata[index + 1]

    local c1 = obj:GetController("c1")
    if self.data.gotSigns[data.id] then
        c1.selectedIndex = 2
    elseif data.quota > self.data.costSum then
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
    end
    local str = string.format(language.qmbz08,data.quota)
    if data.quota > self.data.costSum then
        str = str .. mgr.TextMgr:getTextColorStr(self.data.costSum, 14)
    else
        str = str ..  mgr.TextMgr:getTextColorStr(self.data.costSum, 7)
    end
    str = str .. "/" .. data.quota
    local dec1 = obj:GetChild("n2")
    dec1.text = str

    local listview = obj:GetChild("n4")
    listview.itemRenderer = function(_index,_obj)
        local info = data.items[_index + 1]
         local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3]
        GSetItemData(_obj, t, true)
    end
    listview.numItems = #data.items

    local btn = obj:GetChild("n5")
    btn.data = data 
    btn.onClick:Add(self.onCellCall,self)

    btn:GetChild("red").visible = c1.selectedIndex == 0
end

function qmbz1155:onCellCall(context)
    -- body
    if not self.data then
        return 
    end
    local btn = context.sender
    local data = btn.data 

    if data.quota > self.data.costSum then
        return GComAlter(language.qmbz09)
    elseif self.data.gotSigns[data.id] then
        return 
    end

    local param = {}
    param.reqType = 1
    param.cid = data.id 
    proxy.ActivityProxy:sendMsg(1030615,param)

end

return qmbz1155