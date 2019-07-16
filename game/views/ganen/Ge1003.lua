--
-- Author: Your Name
-- Date: 2018-09-18 14:32:34
--登录有礼
local Ge1003 = class("Ge1003",import("game.base.Ref"))

function Ge1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Ge1003:onTimer()
    -- body
    if not self.data then return end

end   
-- int8
-- 变量名：reqType 说明：0:显示 1:领取  
-- int32
-- 变量名：cid 说明：领取id  
-- map<int32,int32>
-- 变量名：taskInfo    说明：任务完成情况   
-- map<int32,int32>
-- 变量名：gotSigns    说明：领取标识  
-- array<SimpleItemInfo>   变量名：items   说明：奖励  
-- int32
-- 变量名：actStartTime    说明：活动开始时间  
-- int32
-- 变量名：actEndTime  说明：活动结束时间
function Ge1003:addMsgCallBack(data)
    -- body
    printt("感恩节互动",data)
    if data.items then
        GOpenAlert3(data.items,true)
    end
    self.taskInfo = {}
        for k,v in pairs(data.taskInfo) do
        self.taskInfo[k] = v
    end

    self.gotSigns = {}
        for k,v in pairs(data.gotSigns) do
        self.gotSigns[k] = v
    end
    self.listView1.numItems = #self.data1
    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)


end

function Ge1003:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
        -- GComAlter(language.gq01)
        return
    elseif state == 2 then
        GComAlter(language.czccl07)
    end

    proxy.GanEnProxy:sendMsg(1030654,{reqType = reqType,cid = data.id})
end

function Ge1003:initView()
    -- body
    self.timeTxt = self.view:GetChild("n8")
    print(self.timeTxt.name)
    
    self.data1 = conf.GanEnConf:getmyGift()
    self.data2 = conf.GanEnConf:getbanlvGift()
    
   
    self.listView1 = self.view:GetChild("n9")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()


end

function Ge1003:cell1data( index,obj )

    local data1 = self.data1[index +1]
    local data2 = self.data2[index +1]
    obj:GetChild("n17").text = data1.name or ""
    local c1 = obj:GetChild("n26"):GetController("c1")
    local c2 = obj:GetChild("n27"):GetController("c1")
    local itemInfo1 = {mid = data1.items[1][1],amount =  data1.items[1][2],bind =  data1.items[1][3]}
    local itemInfo2 = {mid = data2.items[1][1],amount =  data2.items[1][2],bind =  data2.items[1][3]}
    -- itemInfo1.isquan = false
    -- itemInfo2.isquan = false

    local btn1 = obj:GetChild("n26")
    local btn2 = obj:GetChild("n27")
    local myitem =  btn1:GetChild("n4")
    local blitem =  btn2:GetChild("n4")
    myitem.grayed = false
    blitem.grayed = false
    if self.gotSigns[data1.id] then -- 已领取
        c1.selectedIndex = 1
        myitem.grayed = true
        -- itemInfo1.isquan = true
        GSetItemData(myitem,itemInfo1,true)
        myitem:GetController("c1").selectedIndex = 0
    else
        c1.selectedIndex = 0
        if self.taskInfo[data1.id]  then
            myitem.touchable = true
            if self.taskInfo[data1.id] >= data1.count then
                --可领取
                myitem.touchable = false
                btn1.data = {id = data1.id}
                btn1.onClick:Add(self.lingQu,self)
                -- itemInfo1.isquan = false
                GSetItemData(myitem,itemInfo1,true)
                myitem:GetController("c1").selectedIndex = 1
            else
                 --只能查看
                 -- itemInfo1.isquan = true
                GSetItemData(myitem,itemInfo1,true)
                myitem:GetController("c1").selectedIndex = 0
            end
        else
            --只能查看
            -- itemInfo1.isquan = true
            GSetItemData(myitem,itemInfo1,true)
            myitem:GetController("c1").selectedIndex = 0
        end
    end 
    if self.gotSigns[data2.id] then -- 已领取
        c2.selectedIndex = 1
        blitem.grayed = true
        -- itemInfo2.isquan = true
        GSetItemData(blitem,itemInfo2,true)
        blitem:GetController("c1").selectedIndex = 0
    else
        c2.selectedIndex = 0
        if self.taskInfo[data2.id]  then  -- 任务完成情况
            blitem.touchable = true
            if self.taskInfo[data2.id] >= data2.count then --是否达到次数
                if (self.gotSigns[data1.id]) or 
                (self.taskInfo[data1.id] and tonumber(self.taskInfo[data1.id]) >= tonumber(data1.count)) then-- 判断同伴是否达成条件
                    blitem.touchable = false --可领取
                    btn2.data =  {id = data2.id}
                    btn2.onClick:Add(self.lingQu,self)
                    -- itemInfo2.isquan = false
                    GSetItemData(blitem,itemInfo2,true)
                    blitem:GetController("c1").selectedIndex = 1

                else
                    --只能查看
                    -- itemInfo2.isquan = true
                    GSetItemData(blitem,itemInfo2,true)
                    blitem:GetController("c1").selectedIndex = 0
                end 
            else
                 --只能查看
                  -- itemInfo2.isquan = true
                GSetItemData(blitem,itemInfo2,true)
                blitem:GetController("c1").selectedIndex = 0

            end
        else
            --只能查看
             -- itemInfo2.isquan = true
            GSetItemData(blitem,itemInfo2,true)
            blitem:GetController("c1").selectedIndex = 0
        end
    end 

    local mytimetex = obj:GetChild("n22")
    local banlvtex = obj:GetChild("n23")
    if self.taskInfo[data1.id] then
        local fenzi  = self.taskInfo[data1.id] >= data1.count and  data1.count or self.taskInfo[data1.id]
        if fenzi ==  data1.count then
            mytimetex.text = mgr.TextMgr:getTextColorStr(fenzi.."/"..data1.count,7)
        else
            mytimetex.text = mgr.TextMgr:getTextColorStr(fenzi.."/"..data1.count,14)
        end
    else
        mytimetex.text = mgr.TextMgr:getTextColorStr("0/"..data1.count,14)
    end
    if self.taskInfo[data2.id] then
        local fenzi  = self.taskInfo[data2.id] >= data2.count and  data2.count or self.taskInfo[data2.id]
         if fenzi ==  data2.count then
            banlvtex.text = mgr.TextMgr:getTextColorStr(fenzi.."/"..data2.count,7)
        else
            banlvtex.text = mgr.TextMgr:getTextColorStr(fenzi.."/"..data2.count,14)
        end
    else
        banlvtex.text = mgr.TextMgr:getTextColorStr("0/"..data2.count,14)
    end
end

function Ge1003:lingQu( context )
    local data = context.sender.data
    proxy.GanEnProxy:send(1030654,{reqType =1,cid = data.id})
end


return Ge1003