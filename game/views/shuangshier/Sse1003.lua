--
-- Author: Your Name
-- Date: 2018-09-18 14:32:34
--登录有礼
local Sse1003 = class("Sse1003",import("game.base.Ref"))

function Sse1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Sse1003:onTimer()
    -- body
    if not self.data then return end

end

    
-- int8
-- 变量名：reqType 说明：0:显示 1:领取   
-- int32
-- 变量名：cid 说明：领取id  
-- array<SimpleItemInfo>   变量名：items   说明：领取的道具 
-- int32
-- 变量名：actEndTime  说明：活动结束时间  
-- int32
-- 变量名：actStartTime    说明：活动开始时间
function Sse1003:addMsgCallBack(data)
    -- body
    printt("单笔狂欢",data)
    if data.items then
        GOpenAlert3(data.items,true)
    end
     self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)
     self.data= data
     self.quotaMap ={}
     if not data.quotaMap then
        for i = 1,#self.refreshnum  do 
           self.quotaMap[self.refreshnum[i]] = 0
        end
     else
         for k,v in pairs(data.quotaMap) do
             self.quotaMap[k] = v
         end
     end
     print(#self.refreshnum)
    self.listView1.numItems = #self.refreshnum
end

function Sse1003:onClickGet(context)
    local data = context.sender.data
  
end

function Sse1003:initView()
    -- body
  

    self.timeTxt = self.view:GetChild("n14")
    self.decTxt = self.view:GetChild("n15")
    self.decTxt.text = language.sse04

    self.listView1 = self.view:GetChild("n9")
    
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
  
    self.refreshnum = conf.ShuangShiErConf:getGlobal("dt_recharge")
    self.chooseKuang = false
end

function Sse1003:cell1data( index,obj )
    local list = obj:GetChild("n3")
    local confData = conf.ShuangShiErConf:getDanbiAwardById(index+ 1)
    list.itemRenderer = function (index,cell)
        local item = cell:GetChild("n4")
        local  c1 = cell:GetController("c1")
        local itemData = {mid = confData[index + 1].items[1],amount = confData[index + 1].items[2],bind = confData[index + 1].items[3],eStar =confData[index + 1].startnum or nil}
        GSetItemData(item, itemData, false)
        item:GetController("c1").selectedIndex = 0
        cell.data = {cell = obj,mid =  confData[index + 1].items[1] ,quota = confData[index + 1].quota,id =  confData[index + 1].id,eStar =confData[index + 1].startnum or nil}
        cell.onClick:Add(self.showxuanKuan,self)
    end
    list.numItems = #confData

    local  text1 = obj:GetChild("n4")
    local  text2 = obj:GetChild("n6")
    local  text3 = obj:GetChild("n7")

    text1.text = confData[1].quota
    text2.text = string.format(language.sse02,confData[1].quota)
    local canget 
    if self.quotaMap[confData[1].quota] then
        canget = self.quotaMap[confData[1].quota]
    else
        canget = 0
    end
    text3.text = string.format(language.sse03,canget or 0)
    local btn = obj:GetChild("n8") -- 领取button
    local c1 = btn:GetController("c1")
    if canget>0 then
        c1.selectedIndex = 0

    else
        c1.selectedIndex = 1
    end
    btn.data = {selected = c1.selectedIndex,quota = confData[1].quota}
    btn.onClick:Add(self.onClickItem1,self)

    -- obj.data = {id= confData[index + 1].id,quota = confData[1].quota}
    -- obj.onClick:Add(self.onClickItem,self)

end



function Sse1003:showxuanKuan(context)
    local data = context.sender.data
    local itemData = cache.PackCache:getPackDataById(data.mid)
    itemData.index = 0
    itemData.amount = 1
    itemData.eStar = data.eStar
    GSeeLocalItem(itemData)
    self.chooseID = data.id
    self.choosequota = data.quota
end

function Sse1003:onClickItem(context)
    local data = context.sender.data
    
end

function Sse1003:onClickItem1(context)
    local data = context.sender.data
    if data.selected == 0 then
        -- print(self.choosequota,data.quota,self.chooseID)
        if self.choosequota == data.quota then
            proxy.ShuangShiErProxy:sendMsg(1030662,{reqType = 1,cid = self.chooseID})
        else
            GComAlter(language.sse05)
        end
        -- if self.choosequota == quota then
        --     GComAlter(language.sse05)
        -- else
        --     print(self.chooseID,"#########")
        -- end
       
    else
        GComAlter(string.format(language.sse16,data.quota) )
    end
end


return Sse1003