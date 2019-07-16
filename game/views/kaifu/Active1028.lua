--每日首充
local Active1028 = class("Active1028",import("game.base.Ref"))

function Active1028:ctor(param)
    self.view = param
    self:initView()
end

function Active1028:initView()
    -- body
    self.c1 = self.view:GetController("c1")

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
function Active1028:initDec()
    -- body
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.kaifu15

    local dec2 = self.view:GetChild("n8")
    dec2.text = language.kaifu44

    self.time = self.view:GetChild("n7")
    self.time.text = ""
    self.time.x = dec1.x+dec1.width
    self.money = self.view:GetChild("n9") 
    self.money.text = ""
    local icon = self.view:GetChild("n5")
    local maohao = self.view:GetChild("n10")
    icon.x = dec2.x+dec2.width
    maohao.x = icon.x + icon.width
    self.money.x = maohao.x + maohao.width
end


function Active1028:onTimer()
    if not self.data then
        return
    end
    if self.data.lastTime<=0 then
        mgr.ViewMgr:closeAllView2()
        return
    end
    self.data.lastTime = self.data.lastTime - 1
    self.time.text = GGetTimeData2(self.data.lastTime)
    self.money.text = self.data.czYB
end

function Active1028:celldata( index, obj )
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
    local text = obj:GetChild("n8")
    text.text = string.format(language.kaifu45,data.yb_num)
    local c1 =  obj:GetController("c1")
    c1.selectedIndex = self.data.itemStatus[data.id]
    local getBtn = obj:GetChild("n3")
    getBtn.data = data
    getBtn.onClick:Add(self.onClickGet,self)
end

function Active1028:setCurId(id)
    -- body
    self.id = id
    
end

function Active1028:setOpenDay( day )
    -- body
    self.c1.selectedIndex = day - 1 
end

function Active1028:onChongzhi()
    -- body
    mgr.ViewMgr:closeAllView2()
    GGoVipTequan(0)
end
function Active1028:onClickGet(context)
    local data = context.sender.data
    if self.data.itemStatus[data.id]  == 2 then
        return
    elseif self.data.itemStatus[data.id] == 0 then
        GComAlter(language.kaifu46)
        return
    end
    proxy.ActivityProxy:sendMsg(1030120, {reqType = 1,awardId = data.id,activityId = 1028})
end

-- 1   
-- int32
-- 变量名：czYB    说明：今日累充元宝
-- 2   
-- int32
-- 变量名：lastTime    说明：活动剩余时间
-- 3   
-- map<int32,int32>
-- 变量名：itemStatus  说明：道具列表状态
-- 4   
-- array<SimpleItemInfo>
-- 变量名：items   说明：奖励道具
-- 5   
-- int32
-- 变量名：reqType 说明：0:请求奖励信息 1:领取奖励

function Active1028:add5030120( data )
    -- body
    self.data = data
    local data = cache.ActivityCache:get5030111()
    self.confdata = conf.ActivityConf:getAwardsData(data.openDay)
    self.listView.numItems = #self.confdata
end



return Active1028