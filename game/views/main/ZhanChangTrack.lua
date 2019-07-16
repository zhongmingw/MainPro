--
-- Author: ohf
-- Date: 2017-05-12 10:49:03
--
--战场追踪
local ZhanChangTrack = class("ZhanChangTrack", import("game.base.Ref"))

function ZhanChangTrack:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ZhanChangTrack:initPanel()
    local panelObj = self.mParent.view:GetChild("n666")
    self.panelObj = panelObj
    self.isPick = true
    self.timeText = self.panelObj:GetChild("n5")
    self.listView = self.panelObj:GetChild("n6")   

    --EVE 皇陵UI优化加的逻辑
    local btnDetail = self.panelObj:GetChild("n11")  
    btnDetail.onClick:Add(self.onClickBtn1,self)
    local btnQuit = self.panelObj:GetChild("n12")
    btnQuit.onClick:Add(self.onClickQuit,self)

    -- local confData = conf.HuanglingConf:getAdditionalAwards()
    -- self:setAwards(self.listView,confData)

    self.progress = self.panelObj:GetChild("n15")  --进度
    self.isOver = self.panelObj:GetChild("n13") --当完成时显示的图片
    self.isOver.visible = false
    --EVE END
end

function ZhanChangTrack:setAwards(listView,confData)
    -- body
    listView.numItems = 0
    for k,v in pairs(confData) do
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj = listView:AddItemFromPool(url)
        local mId = v[1]
        local amount = v[2]
        local bind = v[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end

--1.皇陵 2.仙盟
function ZhanChangTrack:setType(type)
    self.mType = type
    -- self.btnList = {}
    -- self.listView.numItems = 0
    -- local url1 = UIPackage.GetItemURL("_components" , "Btngonggongsucai_012")
    -- local url2 = UIPackage.GetItemURL("_components" , "Btngonggongsucai_013")
    -- if type == 1 then
        -- local btn1 = self.listView:AddItemFromPool(url1)
        -- btn1.title = language.zhangchang02[1]
        -- btn1.onClick:Add(self.onClickBtn1,self)
        -- local btn2 = self.listView:AddItemFromPool(url1)
        -- btn2.title = language.zhangchang02[2]
        -- btn2.onClick:Add(self.onClickBtn2,self)
        -- local btn3 = self.listView:AddItemFromPool(url2)
        -- btn3.title = language.zhangchang02[3]
        -- btn3.onClick:Add(self.onClickQuit,self)
    -- end
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function ZhanChangTrack:setVisible(visible)
    self.panelObj.visible = visible
    self.mParent.view:GetChild("n208").visible = not visible
end

function ZhanChangTrack:onClickQuit()
    mgr.FubenMgr:quitFuben()
end

function ZhanChangTrack:onClickBtn1()
    if self.mType == 1 then
        local view = mgr.ViewMgr:get(ViewName.HuanglingTask)
        if view then
            view:onClickClose()
        end
        mgr.ViewMgr:openView2(ViewName.HuanglingTask,{type=1})       
    end
end

-- function ZhanChangTrack:onClickBtn2()
--     if self.mType == 1 then
--         local view = mgr.ViewMgr:get(ViewName.HuanglingTask)
--         if view then
--             view:onClickClose()
--         end
--         mgr.ViewMgr:openView2(ViewName.HuanglingTask,{type=2})
--     end
-- end

function ZhanChangTrack:onClickBtn3()
    mgr.ViewMgr:openView2(ViewName.GangBossInfoView, {})
end

function ZhanChangTrack:onTimer()
    if self.mType == 1 then
        local time = cache.PlayerCache:getRedPointById(attConst.A20132)
        if self.timeText then
            local sec = time - mgr.NetMgr:getServerTime()
            if sec > 0 then
                self.timeText.text = GTotimeString(sec)
            else
                self.timeText.text = GTotimeString(0)
            end
        end

        --EVE
        local data = cache.HuanglingCache:getTaskCache()   
        -- local otherData = {} --未完成的任务
        local otherDataNum = 0
        for k,v in pairs(data) do
            if v.taskFlag ~= 1 then
                -- table.insert(otherData,v)
                otherDataNum = otherDataNum + 1
            end
        end
        -- local len = 0
        -- if otherData then
        --     len = #otherData
        -- end
        local temp01 = cache.HuanglingCache:getTaskNum()
        local temp02 = temp01 - otherDataNum
        if temp02 < 3 then 
            self.progress.text = mgr.TextMgr:getTextColorStr(tostring(temp02), 14).."/"..temp01
        else
            self.isOver.visible = true
            self.progress.text = temp02 .. "/" .. temp01
        end             
        --EVE END
    end
end

function ZhanChangTrack:endZhanchang()
    self:setVisible(false)
    cache.HuanglingCache:BossFightState(false)
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

return ZhanChangTrack