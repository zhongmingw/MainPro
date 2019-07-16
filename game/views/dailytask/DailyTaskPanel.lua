--
-- Author: Your Name
-- Date: 2017-12-07 21:18:55
--日常任务
local DailyTaskPanel = class("DailyTaskPanel", import("game.base.Ref"))

function DailyTaskPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n2")
    self:initPanel()
end

function DailyTaskPanel:initPanel()
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
    --活跃奖励
    self.activeAwards = {}
    for i=13,16 do
        local awardItem = self.view:GetChild("n"..i)
        table.insert(self.activeAwards,awardItem)
    end
    --活跃进度条
    self.activeBar = self.view:GetChild("n17")
    --活跃奖励领取按钮
    self.actGetBtn = self.view:GetChild("n18")
    self.actGetBtn.grayed = true
    self.actGetBtn.touchable = false
    self.actGetBtn.onClick:Add(self.onClickGetAwards,self)
    --离线挂机时间
    self.outLineTimeTxt = self.view:GetChild("n8")
    local outLineBtn = self.view:GetChild("n9")
    outLineBtn.onClick:Add(self.onClickAddOutLine,self)

    -- self.xianzunDec = self.view:GetChild("n34")
    -- self.xianzunBtn = self.view:GetChild("n33")
    -- self.xianzunBtn.onClick:Add(self.onXianzunBtn,self)

    -- local isvip3 = cache.PlayerCache:VipIsActivate(3)
    -- if isvip3  then
    --     self.xianzunBtn.visible = false
    --     self.xianzunDec.text = language.xiuxian24 .. language.zuoqi62
    -- else
    --     self.xianzunBtn.visible = true 
    --     self.xianzunDec.text = language.xiuxian24
    -- end

end

-- function DailyTaskPanel:onXianzunBtn()
--     GGoVipTequan(2,2)
-- end

function DailyTaskPanel:onClickAddOutLine()
    local param = {}
    param.mId = 221051011
    GGoBuyItem(param)
end

function DailyTaskPanel:setData(data)
    self.data = data
    -- printt("每日任务信息",data)
    --离线挂机时间
    self.outLineTimeTxt.text = GTotimeString2(data.outLineTime)
    self.awardFlagList = {0,0,0,0} --四个奖励的领取状态
    for k,v in pairs(self.data.awardGotFlag) do
        self.awardFlagList[v] = 1
    end
    for k,v in pairs(self.awardFlagList) do
        if v == 1 then
            self.view:GetChild("n"..(28+k)).visible = true
        else
            self.view:GetChild("n"..(28+k)).visible = false
        end
    end
    self.index = 0 --奖励索引
    --任务列表数据
    local roleLv = cache.PlayerCache:getRoleLevel()
    self.expWayData = conf.ImmortalityConf:getWayData(roleLv)
    for k,v in pairs(self.expWayData) do
        local num = self.data.expWayMap[v.id] or 0
        if v.max_count - num > 0 then
            self.expWayData[k].isfinish = 0 --未完成
        else
            self.expWayData[k].isfinish = 1 --进度已完成
        end
        --是否开启模块
        local moduleConf = conf.SysConf:getModuleById(v.skipId)
        if moduleConf then
            if moduleConf.open_lev then
                local roleLv = cache.PlayerCache:getRoleLevel()
                if roleLv < moduleConf.open_lev then
                    self.expWayData[k].isOpen = 0 --未开启
                else
                    self.expWayData[k].isOpen = 1 --已开启
                end
            elseif moduleConf.openTask and not GCheckView(moduleConf.openTask) then
                self.expWayData[k].isOpen = 0 --未开启
            else
                self.expWayData[k].isOpen = 1 --已开启
            end
        else
            self.expWayData[k].isOpen = 1 --已开启
        end
    end
    table.sort(self.expWayData,function(a,b)
        if a.isOpen ~= b.isOpen then
            return a.isOpen > b.isOpen
        elseif a.isfinish ~= b.isfinish then
            return b.isfinish > a.isfinish
        elseif a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    self.listView.numItems = #self.expWayData
    self:setActiveData()
end

function DailyTaskPanel:itemData( index,obj )
    local data = self.expWayData[index+1]
    if data then
        local timesNum = self.data.expWayMap[data.id] or 0
        local max_count = data.max_count or 0
        local icon = obj:GetChild("n1"):GetChild("n0")
        local name = obj:GetChild("n2")
        local times = obj:GetChild("n5")
        local singleExp = obj:GetChild("n6")
        local c1 = obj:GetController("c1")
        local openTxt = obj:GetChild("n10")
        if data.img then
            local iconUrl = UIPackage.GetItemURL("_icons" , data.img)
            if not iconUrl then
                iconUrl = UIPackage.GetItemURL("_icons2" , data.img)
            end
            icon.url = iconUrl
        end
        name.text = data.name
        times.text = timesNum .. "/" .. max_count
        local oneceExp = data.single_exp
        local isvip3 = cache.PlayerCache:VipIsActivate(3)
        if isvip3  then
            local add = conf.ImmortalityConf:getValue("xiuxian_add_plus")
            oneceExp = math.ceil(data.single_exp + data.single_exp * (add/100))
        end
        singleExp.text = oneceExp*timesNum .. "/" .. max_count*oneceExp
        local gotoBtn = obj:GetChild("n7")
        gotoBtn.data = data.skipId
        gotoBtn.onClick:Add(self.onClickGoTo,self)
        -- if data.isfinish == 1 then --已完成
        --     c1.selectedIndex = 2
        -- elseif data.isfinish == 0 then --未完成
        --     c1.selectedIndex = 0          
        -- end
        local moduleConf = conf.SysConf:getModuleById(data.skipId)
        -- print("999999999",data.skipId)
        if moduleConf then
            if moduleConf.open_lev then
                local roleLv = cache.PlayerCache:getRoleLevel()
                if roleLv < moduleConf.open_lev then
                    c1.selectedIndex = 1
                    openTxt.text = string.format(language.guide07,moduleConf.open_lev)
                else
                    if data.red_open then --BXP 
                        local var = cache.PlayerCache:getRedPointById(data.red_open)
                        if var > 0 then 
                            c1.selectedIndex = 0
                        else
                            c1.selectedIndex = 3 --本日未开放
                        end
                    else
                        c1.selectedIndex = 0
                    end
                end
            elseif moduleConf.openTask and not GCheckView(moduleConf.openTask) then
                c1.selectedIndex = 1
                local confdata = conf.TaskConf:getTaskById(moduleConf.openTask)
                if confdata.trigger_lev then
                    openTxt.text = string.format(language.dailytask02,confdata.trigger_lev)
                else
                    openTxt.text = language.dailytask03
                end
            else
                if data.red_open then 
                    local var = cache.PlayerCache:getRedPointById(data.red_open)
                    if var > 0 then 
                        c1.selectedIndex = 0
                    else
                        c1.selectedIndex = 3 --本日未开放
                    end
                else
                    c1.selectedIndex = 0
                end
            end
        else
            c1.selectedIndex = 0
        end
        obj:GetChild("n1").data = {
                            name = data.name,
                            counts = timesNum .. "/" .. max_count,
                            actTime = data.act_time,
                            skipId = data.skipId,
                            decTxt = data.dec,
                            actNum = data.single_exp,
                            awards = data.awards,
                            iconImg = data.img,
                        }
        obj:GetChild("n1").onClick:Add(self.onClickCheckTask,self)
    end
end

function DailyTaskPanel:onClickCheckTask(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.TaskTipsView, data)
end

function DailyTaskPanel:onClickGoTo(context)
    local skipId = context.sender.data
    if skipId then
        GOpenView({id = skipId})
    end
end

--活跃奖励设置
function DailyTaskPanel:setActiveData()
    local data = cache.ActivityCache:get5030111()
    local var = data.openDay%9
    if var == 0 then var = 9 end
    local activeData = conf.ImmortalityConf:getActiveAwardsData(var)
    if activeData then
        for k,v in pairs(activeData) do
            local mid = v.awards[1][1]
            local num = v.awards[1][2]
            local bind = v.awards[1][3]
            local awardItem = self.activeAwards[k]
            local info = { mid=mid, amount = num, bind = bind}
            GSetItemData(awardItem,info,true)
        end
        self.view:GetChild("n28").text = self.data.dayProcess .. "/" ..activeData[4].active_exp
        self.activeBar.visible = true
        self.activeBar.value = self.data.dayProcess
        -- print("当前活跃",self.data.dayProcess)
        self.activeBar.max = activeData[4].active_exp + activeData[1].active_exp
        --活跃按钮状态设置
        local awardGotFlag = self.data.awardGotFlag
        local index = 0--math.floor(4/(activeData[4].active_exp / self.data.dayProcess))
        for i=1,4 do
            if self.data.dayProcess>=activeData[i].active_exp then
                index = index + 1
            end
        end
        --进度条分割线位置设置
        -- for i=1,3 do
        --     local img = self.view:GetChild("n"..(18+i))
        --     local hyTxt = self.view:GetChild("n"..(22+i))
        --     local awardIcon = self.view:GetChild("n"..(12+i))
        --     hyTxt.text = activeData[i].active_exp
        --     img.x = self.activeBar.x + self.activeBar.width*(activeData[i].active_exp/activeData[4].active_exp)
        --     hyTxt.x = img.x - 10
        --     awardIcon.x = img.x - 0.8*(awardIcon.width/2)
        -- end
        for i=1,4 do
            local hyTxt = self.view:GetChild("n"..(22+i))
            hyTxt.text = activeData[i].active_exp
        end
        -- self.view:GetChild("n26").text = activeData[4].active_exp
        if index == 0 then --活跃度不够领取奖励
            self.actGetBtn.grayed = true
            self.actGetBtn.touchable = false
            self.actGetBtn:GetChild("red").visible = false
        else
            self.actGetBtn.grayed = true
            self.actGetBtn.touchable = false
            self.actGetBtn:GetChild("red").visible = false
            local count = 1
            while count <= index do
                if self.awardFlagList[count] == 0 then
                    self.actGetBtn.grayed = false
                    self.actGetBtn.touchable = true
                    self.actGetBtn:GetChild("red").visible = true
                    self.index = count
                    break
                end
                count = count + 1
            end
        end
    end
end

--领取奖励按钮
function DailyTaskPanel:onClickGetAwards( context )
    if self.index == 0 then
        GComAlter(language.xiuxian04)
    else
        proxy.ImmortalityProxy:sendMsg(1290103,{awardId = self.index})
    end
end

--领取奖励刷新
function DailyTaskPanel:getAwardsRefresh( data )
    self.data.awardGotFlag = data.awardGotFlag
    self.outLineTimeTxt.text = GTotimeString2(data.outLineTime)
    self.awardFlagList = {0,0,0,0} --四个奖励的领取状态
    for k,v in pairs(self.data.awardGotFlag) do
        self.awardFlagList[v] = 1
    end
    for k,v in pairs(self.awardFlagList) do
        if v == 1 then
            self.view:GetChild("n"..(28+k)).visible = true
        else
            self.view:GetChild("n"..(28+k)).visible = false
        end
    end
    self.index = 0
    self:setActiveData()
    -- GOpenAlert3(data.items)
end

return DailyTaskPanel