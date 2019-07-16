
--
-- Author: 
-- Date: 2017-03-29 21:02:07
--

local Active1043 = class("Active1043",import("game.base.Ref"))

function Active1043:ctor(param)
    self.view = param
    self:initView()
end

function Active1043:initView()
    -- body
    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end
function Active1043:onTimer()
    -- body
end

function Active1043:celldata(index,obj)
    -- body
    local data = self.confData[index+1]
    local listView = obj:GetChild("n7")
    local decTxt = obj:GetChild("n4")
    local getBtn = obj:GetChild("n3")
    local c1 = obj:GetController("c1")
    listView.numItems = 0
    
    if data then
        local textData = {
                        {text = language.kaifu58[1],color = 6},
                        {text = string.format(language.kaifu58[2],data.level),color = 7},
                        {text = language.kaifu58[3],color = 6},
                    }
        decTxt.text = mgr.TextMgr:getTextByTable(textData)
        for k,v in pairs(data.rewards) do
            local itemUrl = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = listView:AddItemFromPool(itemUrl)
            local itemData = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(item,itemData,true)--设置道具信息
        end
        getBtn.data = data.id
        getBtn.onClick:Add(self.onget,self)
        
        if not self:checkGetid(data.id) then
            local roleLv = cache.PlayerCache:getRoleLevel()
            if roleLv >= data.level then
                c1.selectedIndex = 1
            else
                c1.selectedIndex = 0
            end
        else
            c1.selectedIndex = 2
        end
    end

end

function Active1043:onget(context)
    local itemId = context.sender.data
    local param = { actId = self.id , reqType = 2 , itemId = itemId }
    proxy.ActivityProxy:sendMsg(1030208,param)
end

function Active1043:setCurId(id)
    -- body
    self.id = id 
end

function Active1043:setOpenDay( day )
    -- body
    self.openday = day
end

function Active1043:checkGetid( id )
    for k,v in pairs(self.data.gotItems) do
        if id == v then
            return true
        end
    end
    return false
end

function Active1043:add5030208(data)
    -- body
    self.data = data
    self.confData = conf.ActivityConf:getLevelChargeById(self.openday)
    for k,v in pairs(self.confData) do
        if self:checkGetid(v.id) then
            self.confData[k].sortindex = 2
        else
            self.confData[k].sortindex = 1
        end
    end
    table.sort(self.confData,function(a,b)
        if a.sortindex ~= b.sortindex then
            return a.sortindex < b.sortindex
        elseif a.level ~= b.level then
            return a.level < b.level
        end
    end)

    self.listView.numItems = #self.confData
end


return Active1043