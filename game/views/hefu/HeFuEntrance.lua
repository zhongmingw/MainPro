--
-- Author: Your Name
-- Date: 2018-07-11 14:56:26
--
--合服活动入口
local HeFuEntrance = class("HeFuEntrance", base.BaseView)

function HeFuEntrance:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function HeFuEntrance:initView()
    local closeBtn = self.view:GetChild("n4")
    self:setCloseBtn(closeBtn)
    
    --活动列表
    self.actList = {}
    self.bgIcon = self.view:GetChild("n0")
    self.listView = self.view:GetChild("n6"):GetChild("n1")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function HeFuEntrance:initData(_data)
    self.actList = {}
    self.id = _data.id
    local data = cache.ActivityCache:get5030111()
    local confData = conf.ActivityConf:getHefuActData()--合服活动入口
    self.bgIcon.url = UIPackage.GetItemURL("hefu" ,"hefuhuodong_005")
    if self.id == 1263 then--合服活动
    elseif self.id == 1271 then--开服活动入口
        confData = conf.ActivityConf:getKaifuActData()
        self.bgIcon.url = UIPackage.GetItemURL("hefu" ,"kaifuhuodong_024")
    elseif self.id == 1284 then--精彩活动入口
        confData = conf.ActivityConf:getJingCaiActData()
        self.bgIcon.url = UIPackage.GetItemURL("hefu" ,"jingcaihuodong_010")
    elseif self.id == 1426 then--圣诞庆典（2018）
        confData = conf.ShengDanConf:getShengDanItem()
        self.bgIcon.url = UIPackage.GetItemURL("hefu" ,"huodong_001")
    elseif self.id == 1427 then--冬至(2018)
        confData = conf.DongZhiConf:getDongZhiItem()
        self.bgIcon.url = UIPackage.GetItemURL("hefu" ,"huodong_002")
    elseif self.id == 1428 then--活动中心入口
        confData = conf.ActivityConf:gethdzxItem()
        self.bgIcon.url = UIPackage.GetItemURL("hefu" ,"huodong_003")   
    end
    if cache.PlayerCache:getActFakeRed(self.id) then--假红点置零
        cache.PlayerCache:setActFakeRed(self.id,0)
        local view = mgr.ViewMgr:get(ViewName.MainView)
        if view then
            view:refreshRedTop()
        end
    end
    for k,v in pairs(confData) do
        local var = cache.PlayerCache:getRedPointById(v.redid)
        if self.id == 1263 then--合服活动
            -- print("合服活动>>>>>>",v.act_id,data.acts[v.act_id])
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or v.id == 1252 or (var and var > 0) then
                if v.id == 1252 then
                    local endTime  = cache.PlayerCache:getRedPointById(30154)
                    local nowTime =mgr.NetMgr:getServerTime()
                    local leftTime = endTime-nowTime
                    -- print("leftTime>>>>>>>>>",endTime,nowTime,leftTime)
                    if leftTime > 0 and mgr.ModuleMgr:CheckView({id = 1252}) then
                        table.insert(self.actList,v)
                    end
                else
                    if mgr.ModuleMgr:CheckView({id = v.id}) then
                        table.insert(self.actList,v)
                    end
                end
            end
        elseif self.id == 1271 then--开服活动
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) or (var and var > 0) or v.id == 1028 then
                if v.id == 1028 then
                    local kaifuData = conf.ActivityConf:getActiveByTimetype(1)
                    local flag = false
                    for k ,v in pairs(kaifuData) do
                        if v.activity_pos and v.activity_pos == 1 and data.acts[v.id] == 1 then --这个活动开启了
                            flag = true
                            break
                        end
                    end
                    if flag and mgr.ModuleMgr:CheckView({id = v.id}) then
                        table.insert(self.actList,v)
                    end
                else
                    if mgr.ModuleMgr:CheckView({id = v.id}) then
                        table.insert(self.actList,v)
                    end
                end
            end
        elseif self.id == 1284 then--精彩活动
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) and mgr.ModuleMgr:CheckView({id = v.id}) then
                table.insert(self.actList,v)
            end
        elseif self.id == 1426 then--圣诞庆典（2018）
            if (data.acts[v.act_id] and data.acts[v.act_id] == 1) and mgr.ModuleMgr:CheckView({id = v.id}) then
                table.insert(self.actList,v)
            end
        elseif self.id == 1427 then--冬至
            if v.id == 1425 then
                local var =  cache.PlayerCache:getRedPointById(20214)---
                 if (data.acts[v.act_id] and data.acts[v.act_id] == 1) and var > 0 then
                    table.insert(self.actList,v)
                 end
            else
                if (data.acts[v.act_id] and data.acts[v.act_id] == 1) and mgr.ModuleMgr:CheckView({id = v.id}) then
                    table.insert(self.actList,v)
                end
            end
        elseif self.id == 1428 then--活动中心
            if v.id == 1436 then--记忆花灯
                local var =  cache.PlayerCache:getRedPointById(20214)---
                if (data.acts[v.act_id] and data.acts[v.act_id] == 1) and var > 0 then
                    table.insert(self.actList,v)
                end
            else
                if (data.acts[v.act_id] and data.acts[v.act_id] == 1) and mgr.ModuleMgr:CheckView({id = v.id}) then
                    table.insert(self.actList,v)
                end
            end
        end
    end

    self.listView.numItems = #self.actList
end

function HeFuEntrance:celldata( index,obj )
    local data = self.actList[index+1]
    if data then
        local iconImg = obj:GetChild("icon")
        local redImg = obj:GetChild("red")

        local actData = cache.ActivityCache:get5030111()
        local mulActList = actData.mulActList--多开活动列表
        local icon = nil
        for k,v in pairs(mulActList) do
            local mulAct = conf.ActivityConf:getMulActById(v)
            if mulAct and mulAct.module_id and  mulAct.module_id == data.id then
                icon = mulAct.main_icon
                break
            end
        end
        if icon then
            iconImg.url = UIPackage.GetItemURL("main" , icon)
        else
            iconImg.url = UIPackage.GetItemURL("main" , data.icon)
        end
        obj.data = data
        obj.onClick:Add(self.onClickOpen,self)
        --红点设置
        local redNum = 0
        if data.getRedid then
            for k,v in pairs(data.getRedid) do
                local var = cache.PlayerCache:getRedPointById(v)
                redNum = redNum + var
            end
            if data.id == 1290 then--挖矿活动红点特殊计算
                if cache.PlayerCache:getRedPointById(30160) ~= 0 then 
                    redNum = redNum + cache.PlayerCache:getRedPointById(30160)
                end
                local confData = conf.ActivityConf:getConversionList()
                local flag = false
                for k,v in pairs(confData) do
                    local mid = v.cost_item[1]
                    local num = v.cost_item[2]
                    local amount = cache.PackCache:getPackDataById(mid).amount
                    if amount >= num then
                        flag = true
                    end
                end
                if flag then
                    redNum = redNum + 1
                end
            end
        end
        if redNum > 0 then
            redImg.visible = true
        else
            redImg.visible = false
        end
    end
end

function HeFuEntrance:onClickOpen(context)
    local data = context.sender.data
    local modelId = data.id
    GOpenView({id = modelId})
end

function HeFuEntrance:onTimer()
    
end

return HeFuEntrance