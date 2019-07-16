--开服累充
local Active1076 = class("Active1076",import("game.base.Ref"))

function Active1076:ctor(param)
    self.view = param
    self:initView()
end

function Active1076:initView()
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
function Active1076:initDec()
    -- body
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.kaifu15

    local dec2 = self.view:GetChild("n8")
    -- dec2.text = language.kaifu44

    self.time = self.view:GetChild("n7")
    self.time.text = ""
    self.time.x = dec1.x+dec1.width
    self.money = self.view:GetChild("n9") 
    self.money.text = ""
    local icon = self.view:GetChild("n5")
    -- local maohao = self.view:GetChild("n10")
    -- icon.x = dec2.x+dec2.width
    -- maohao.x = icon.x + icon.width
    -- self.money.x = maohao.x + maohao.width
end


function Active1076:onTimer()
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

function Active1076:celldata( index, obj )
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
    text.text = string.format(language.kaifu45_1,data.yb_num)
    local needYbTxt = obj:GetChild("n13")
    needYbTxt.text = data.yb_num - self.data.czYB
    local c1 =  obj:GetController("c1")
    local unfinishImg = obj:GetChild("n15")
    
    unfinishImg.visible = false
    c1.selectedIndex = self.data.itemStatus[data.id]
    if c1.selectedIndex == 0 then
        for i=11,13 do
            obj:GetChild("n"..i).visible = true
        end
        local lastIndex = index
        -- print("lastIndex",lastIndex)
        if lastIndex >= 1 then
            local lastData = self.confdata[lastIndex]
            if lastData then
                local flag = self.data.itemStatus[lastData.id]
                if flag == 0 then
                    unfinishImg.visible = true
                    for i=11,13 do
                        obj:GetChild("n"..i).visible = false
                    end
                end
            end
        end
    end
    local getBtn = obj:GetChild("n3")
    getBtn.data = data
    getBtn.onClick:Add(self.onClickGet,self)

end

function Active1076:setCurId(id)
    -- body
    self.id = id
    
end

function Active1076:setOpenDay( day )
    -- body
    
end

function Active1076:onChongzhi()
    -- body
    mgr.ViewMgr:closeAllView2()
    GGoVipTequan(0)
end
function Active1076:onClickGet(context)
    local data = context.sender.data
    if self.data.itemStatus[data.id]  == 2 then
        return
    elseif self.data.itemStatus[data.id] == 0 then
        GComAlter(language.kaifu46)
        return
    end
    proxy.ActivityProxy:sendMsg(1030184, {reqType = 1,awardId = data.id,actId = self.id})
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

function Active1076:add5030184( data )
    -- body
    self.data = data
    local data = cache.ActivityCache:get5030111()
    self.confdata = conf.ActivityConf:getKaifuTotalRecharge(self.id)
    for k,v in pairs(self.confdata) do
        if self:isGet(v.id) then
            self.confdata[k].sort = 1
        else
            self.confdata[k].sort = 0
        end
    end

    table.sort(self.confdata,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.yb_num ~= b.yb_num then
            return a.yb_num < b.yb_num
        end
    end)
    -- printt("奖励列表",self.confdata,self.id)
    self.listView.numItems = #self.confdata
end

function Active1076:isGet(id)
    if self.data.itemStatus[id] == 2 then
        return true
    end
    return false
end


return Active1076