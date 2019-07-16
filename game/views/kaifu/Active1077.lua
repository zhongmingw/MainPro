--开服累充
local Active1077 = class("Active1077",import("game.base.Ref"))

function Active1077:ctor(param)
    self.view = param
    self:initView()
end

function Active1077:initView()
    -- body
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local btnCZ = self.view:GetChild("n4")
    btnCZ.onClick:Add(self.onChongzhi,self)
    btnCZ:GetChild("title").text = language.kaifu14

    self:initDec()
end
function Active1077:initDec()
    -- body
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.kaifu15

    self.time = self.view:GetChild("n7")
    self.time.text = ""
    self.time.x = dec1.x+dec1.width
end


function Active1077:onTimer()
    if not self.data then
        return
    end
    if self.data.lastTime<=0 then
        mgr.ViewMgr:closeAllView2()
        return
    end
    self.data.lastTime = self.data.lastTime - 1
    self.time.text = GGetTimeData2(self.data.lastTime)
    -- self.money.text = self.data.czYB
end

function Active1077:celldata( index, obj )
    -- body
    local data = self.confdata[index+1]
    local itemList = obj:GetChild("n9")
    itemList.numItems = 0
    for i=1,#data.awards do
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj = itemList:AddItemFromPool(url)
        local info = {mid=data.awards[i][1],amount=data.awards[i][2],
        bind=data.awards[i][3]}
        GSetItemData(obj,info,true)
    end
    local text = obj:GetChild("n14")
    local text2 = obj:GetChild("n15")
    text2.text = language.kaifu45_3
    local t = clone(language.kaifu45_2)
    t[1].text = string.format(t[1].text,data.yb_num)
    text.text = mgr.TextMgr:getTextByTable(t)

    local c1 =  obj:GetController("c1")

    c1.selectedIndex = self.data.itemStatus[data.id]

    local getBtn = obj:GetChild("n3")
    getBtn.data = data
    getBtn.onClick:Add(self.onClickGet,self)

end

function Active1077:setCurId(id)
    -- body
    self.id = id
    
end

function Active1077:setOpenDay( day )
    -- body
    
end

function Active1077:onChongzhi()
    -- body
    mgr.ViewMgr:closeAllView2()
    GGoVipTequan(0)
end
function Active1077:onClickGet(context)
    local data = context.sender.data
    if self.data.itemStatus[data.id]  == 2 then
        return
    elseif self.data.itemStatus[data.id] == 0 then
        GComAlter(language.kaifu46)
        return
    end
    proxy.ActivityProxy:sendMsg(1030185, {reqType = 1,awardId = data.id,actId = self.id})
end

-- 1   
-- int32
-- 变量名：actId   说明：活动id
-- 2   
-- map<int32,int32>
-- 变量名：itemStatus  说明：道具列表状态
-- 3   
-- array<SimpleItemInfo>   变量名：items   说明：奖励道具
-- 4   
-- int32
-- 变量名：reqType 说明：0:请求奖励信息 1:领取奖励
-- 5   
-- int32
-- 变量名：lastTime    说明：活动剩余时间

function Active1077:add5030185( data )
    -- body
    self.data = data
    local data = cache.ActivityCache:get5030111()
    self.confdata = conf.ActivityConf:getKaifuOnceRecharge(self.id)
    for k,v in pairs(self.confdata) do
        if self:isGet(v.id) then--已领取
            self.confdata[k].sort = 2
        elseif self:canGet(v.id) then--可领取
            self.confdata[k].sort = 0
        else
            self.confdata[k].sort = 1
        end
    end

    table.sort(self.confdata,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.yb_num < b.yb_num
        end
    end)
    -- printt("奖励列表",self.confdata,self.id)
    self.listView.numItems = #self.confdata
end

function Active1077:isGet(id)
    if self.data.itemStatus[id] == 2 then
        return true
    end
    return false
end

function Active1077:canGet(id)
    if self.data.itemStatus[id] == 1 then
        return true
    end
    return false
end


return Active1077