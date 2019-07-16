--
-- Author: 
-- Date: 2018-09-03 16:36:14
--神兽岛

local ShenShouPanel = class("ShenShouPanel")

function ShenShouPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function ShenShouPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n33")
    self.panelObj = panelObj
    self.mainController = panelObj:GetController("c1")--主控制器
    -- self.mainController.selectedIndex = 7
    self.listView = panelObj:GetChild("n3")--列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)
    -- self.listView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.sceneListView = panelObj:GetChild("n14")--场景层
    self.sceneListView:SetVirtual()
    self.sceneListView.itemRenderer = function(index,obj)
        self:cellSceneData(index, obj)
    end
    self.sceneListView.onClickItem:Add(self.onClickSceneItem,self)

    self.awardsListView = panelObj:GetChild("n4")--掉落奖励
    self.awardsListView:SetVirtual()
    self.awardsListView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    local warBtn = panelObj:GetChild("n5")
    warBtn.onClick:Add(self.onClickWar,self)
    self.bgImg = panelObj:GetChild("n2")

    self.modelPanel = panelObj:GetChild("n6")

    self.modelImg = panelObj:GetChild("n18")

    local followBtn = panelObj:GetChild("n12")--关注
    self.followBtn = followBtn
    followBtn.onChanged:Add(self.onClickFollow,self)
    -- self.warLvText = panelObj:GetChild("n10")--挑战等级
    self.playerKill = panelObj:GetChild("n9")--上轮击杀者
    self.countText = panelObj:GetChild("n10")
    self.tipDesc = panelObj:GetChild("n15")
    self.tipDesc.text = language.fuben180

    self.dropAwardBtn = panelObj:GetChild("n16")
    self.dropAwardBtn.onClick:Add(self.onClickXianshi,self)

    local addBtn = panelObj:GetChild("n13")--增加购买次数
    addBtn.onClick:Add(self.onClickAdd,self)

end

function ShenShouPanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end

function ShenShouPanel:setData(data)
    self.data = data
    print(debug.traceback())
    self.bgImg.url = UIItemRes.bossWorld
    self.modelImg.url = UIPackage.GetItemURL("boss","shenshou_001")
    --关注信息
    self.tipConfMap = data and data.tipConfMap or {}
    self.dayBuyCount = data and data.dayBuyCount or 0

    local bossInfos = data and data.bossInfos or {}

    local otherInfos = data and data.otherInfos or {}

    if not self.initSceneId then
        self.initSceneId = bossInfos[1].sceneId
    end
    self.leftTired = data and data.leftTired or 0

    self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben68, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)

    for k,v in pairs(bossInfos) do
        v.type = 2
    end

    local lhjpId = conf.FubenConf:getBossValue("ssd_lhjp")--龙魂精魄配置id
    
    local ljswId = conf.FubenConf:getBossValue("ssd_ljsw")--龙景守卫配置id

    self.otherInfos = {}
    for k,v in pairs(otherInfos) do
        local lhjpInfo = {
            mapNum = v.lhjpMapNum,--龙魂晶魄地图数量
            nextRefreshTime = v.lhjpNextRefTime,--龙魂晶魄下次刷新时间
            sceneId = v.sceneId,
            monsterId = lhjpId,
            type = 1,
        }
        local ljswInfo = {
            mapNum = v.ljswMapNum,--龙晶守卫地图数量
            nextRefreshTime = v.ljswNextRefTime,--龙晶守卫下次刷新时间
            sceneId = v.sceneId,
            monsterId = ljswId,
            type = 1,
        }
        table.insert(self.otherInfos,lhjpInfo)
        table.insert(self.otherInfos,ljswInfo)
    end
 
    for k,v in pairs(self.otherInfos) do
        table.insert(bossInfos,v)
    end
    self.bossInfos = {}
    local page = 0
    for k,v in pairs(bossInfos) do
        local sceneId = v.sceneId
        if not self.bossInfos[sceneId] then
            self.bossInfos[sceneId] = {}
            page = page + 1
        end
        table.insert(self.bossInfos[sceneId], v)
    end

    local pageIndex = 0--跳转的页签
    if self.gotoMonsterId then--外部跳转
        for sceneId,bossList in pairs(self.bossInfos) do
            for k,v in pairs(bossList) do
                if v.monsterId == self.gotoMonsterId then
                    cache.FubenCache:setShenShouBossIndex(k - 1)
                    pageIndex = (sceneId - self.initSceneId)==0 and 0 or 1
                    break
                end
            end
        end
    end
    self.sceneListView.numItems = page
    self.sceneListView:ScrollToView(pageIndex)
    self:initChooseScene()
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.gotoMonsterId = nil

end



function ShenShouPanel:initChooseScene()
    local max = self.sceneListView.numItems
    if max > 8 then max = 8 end
    for k = 1,max do
        local cell = self.sceneListView:GetChildAt(k - 1)
        if cell then
            local sceneData = cell.data
            local sceneId = sceneData.id
            if sceneId == self.initSceneId then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end

function ShenShouPanel:onClickSceneItem(context)
    local btn = context.data
    local sceneData = context.data.data
    
    local sceneId = sceneData.id or self.initSceneId
    self.initSceneId = sceneId
    local index = sceneId%1000
    local openConf = conf.FubenConf:getBossValue("ssd_open_lvs")
    local openLv = openConf[index] or 0
    if cache.PlayerCache:getRoleLevel() < openLv then
        GComAlter(string.format(language.gonggong07, openLv))
        btn.selected = false
        if self.chooseBtn then self.chooseBtn.selected = true end
        return
    end
    self.chooseBtn = btn
    self.bossList = self.bossInfos[sceneId]
    table.sort(self.bossList,function(a,b)
        if a.type ~= b.type then
            return a.type < b.type
        elseif a.sceneId == b.sceneId then
            local aConf = conf.MonsterConf:getInfoById(a.monsterId)
            local bConf = conf.MonsterConf:getInfoById(b.monsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            return alvl < blvl
        else
            return a.sceneId < b.sceneId
        end
    end)

    self.listView.numItems = #self.bossList
    if cache.FubenCache:getShenShouBossIndex() > #self.bossList - 1 then
        cache.FubenCache:setShenShouBossIndex(0)
    end
    self.listView:ScrollToView(cache.FubenCache:getShenShouBossIndex())
    for k = 1,#self.bossList do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            local indexCache = cache.FubenCache:getShenShouBossIndex()
            if index == indexCache then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end
end

--层数
function ShenShouPanel:cellSceneData(index,cell)
    local sceneId = self.initSceneId
    for k,v in pairs(self.bossInfos) do
        if v[1].sceneId%1000 == index+1 then
            sceneId = v[1].sceneId
            break
        end
    end
    local sceneData = conf.SceneConf:getSceneById(sceneId)
    if sceneData.cross and sceneData.cross == 2 then
        cell:GetChild("n5").visible = true
    else
        cell:GetChild("n5").visible = false
    end
    cell.title = sceneData and sceneData.name or "神兽岛"
    cell.data = sceneData
end
--boss列表
function ShenShouPanel:cellData(index, cell)
    local key = index + 1
    local data = self.bossList[key]
    local image1 = cell:GetChild("n1")
    local image2 = cell:GetChild("n2")
    local icon = cell:GetChild("icon")
    local timeText = cell:GetChild("n10")--刷新时间
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    local isKuafu = cell:GetChild("n9")  --EVE 设置世界boss标志
    local cross = sceneData and sceneData.cross or 0
    if cross > 0 then 
        isKuafu.visible = true
    else  
        isKuafu.visible = false
    end
    local viewIcon = sceneData and sceneData.view_icon or ""
    icon.url = UIPackage.GetItemURL("boss" , tostring(viewIcon))
    --名字
    local model = data.monsterId
    local mConf = conf.MonsterConf:getInfoById(model)
    local name = mConf and mConf.name
    local bossText = cell:GetChild("n8")
    if not name then
        name = conf.NpcConf:getNpcById(model).name or ""
    end
    bossText.text = name
    local timeText = cell:GetChild("n10")--刷新时间
    local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
    if time > 0 then
        timeText.text = GTotimeString(time)
    else
        timeText.text = ""
    end
    --等级
    local lvText = cell:GetChild("n7")
    local arleayImg = cell:GetChild("n4")--已刷新
    local unAppear = cell:GetChild("n5")--未出现
    arleayImg.visible = false
    unAppear.visible = false
    if data.type == 1 then--龙晶
        lvText.text = "[size=18]"..string.format(language.fuben231[key],data.mapNum).."[/size]" 
    elseif data.type == 2 then--boss
      
        local lvl = mConf and mConf.level or 1
        local str = "LV"..lvl
        if cache.PlayerCache:getRoleLevel() >= lvl then
            lvText.text = mgr.TextMgr:getTextColorStr(str, 5)
        else
            lvText.text = mgr.TextMgr:getTextColorStr(str, 14)
        end
        local bossStatu = data.bossStatu
        image1.grayed = false
        image2.grayed = false
        icon.grayed = false
        if bossStatu == 1 then--已死亡
            image1.grayed = true
            image2.grayed = true
            icon.grayed = true
        elseif bossStatu == 2 then--未出现
            unAppear.visible = true
        elseif bossStatu == 3 then--已经刷新
            arleayImg.visible = true
        end
    end
    cell.data = {data = data, index = index, model = model}
end

function ShenShouPanel:onTimer()
    if self.listView.numItems > 0 then
        for k = 1,4 do--boos列表是虚表，最多显示4条内容
            local cell = self.listView:GetChildAt(k - 1)
            if cell then
                local change = cell.data
                local data = change.data
                local timeText = cell:GetChild("n10")--刷新时间
                local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
                if data.type == 1 then
                    if time > 0 then
                        timeText.text = GTotimeString(time)
                    else
                        proxy.FubenProxy:send(1331201)--神兽岛
                    end
                    -- break
                else
                    if data.bossStatu == 1 then--boss已经死了
                        -- local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
                        if time > 0 then
                            timeText.text = GTotimeString(time)
                        else
                            timeText.text = ""
                            plog("boss刷新时间",data.nextRefreshTime,"当前服务器时间",mgr.NetMgr:getServerTime(),time,data.monsterId.."的时间已到,需要刷新")
                            data.nextRefreshTime = 0
                            data.bossStatu = 3
                            proxy.FubenProxy:send(1331201)--神兽岛
                            break
                        end
                    end
                end
            end
        end
    end
end

function ShenShouPanel:onClickItem(context)
    local cell = context.data
    local change = cell.data
    local data = change.data
    local index = change.index
    local dec = self.panelObj:GetChild("n7")
    local dec2 = self.panelObj:GetChild("n20")
    if index == 0 then
        dec.text =  language.fuben233
        dec2.text =  string.format(language.fuben234,self.data.dayLeftLhjpCount)
        self.modelImg.visible = true
        self.modelPanel.visible = false
    elseif index == 1 then
        dec.text = language.fuben235
        dec2.text = language.fuben236
        self.modelImg.visible = false
        self.modelPanel.visible = true
    else
        dec.text = "掉落奖励"
        self.modelImg.visible = false
        self.modelPanel.visible = true
    end
    self.sceneId = data.sceneId
    self:addBossModel(change.model,index,data.sceneId)
    if data.type == 1 then
        self.mainController.selectedIndex = 0
    else
        self.mainController.selectedIndex = 1
        -- print("boss对应场景ID",data.sceneId)
        local sceneData = conf.SceneConf:getSceneById(data.sceneId)
        self.playerKill.text = data.lastKillName
        local lvl = sceneData.lvl or 1
        -- self.warLvText.text = string.format(language.gonggong16, lvl)
        self.bossStatu = data.bossStatu
        
        local optionVal = self.tipConfMap[self.mosterId] or 0--是否关注过
        if optionVal == 0 then
            self.followBtn.selected = false
        else
            self.followBtn.selected = true
        end
        self.isSpecialEffect = false
    end
    -- cache.FubenCache:setWuXingIndex(cell.data.index)
    
end

function ShenShouPanel:addBossModel(model,index,sceneId)
    self.mosterId = model
    local awardData = {}
    awardData = conf.FubenConf:getShenShouAward(model)
    local awardLv = awardData and awardData.no_reward_lev or 1
    if cache.PlayerCache:getRoleLevel() >= awardLv then
        self.tipDesc.visible = true
    else
        self.tipDesc.visible = false
    end
    local mConf = conf.MonsterConf:getInfoById(model)
    if mConf then
        local name = mConf and mConf.name or ""
        self.awards = mConf and mConf.normal_drop or {}
        if next(self.awards) == nil then
            print("@策划,怪物配置里",model,"normal_drop没有配")
        end
        local src = mConf and mConf.src or 0
        -- print("设置模型",model,src)
        local modelObj = self.mParent:addModel(src,self.modelPanel)--添加模型
        modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
        modelObj:setRotation(180)
        modelObj:setScale(100)
    else
        if index == 0 then
            local awardConfData = conf.FubenConf:getShenShouAwardByScene(model,sceneId)
            self.awards = awardConfData.items--conf.FubenConf:getBossValue("ssd_lhjp_normal_drop")
        else
            print("@策划,怪物配置里没有>>>>>>",model)
        end
    end
    self.awardsListView.numItems = #self.awards
end

function ShenShouPanel:cellAwardsData(index, cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function ShenShouPanel:onClickWar()
    if self.sceneId then
        cache.FubenCache:setChooseBossId(self.mosterId)
        mgr.FubenMgr:gotoFubenWar(self.sceneId)
    end
end

function ShenShouPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        proxy.FubenProxy:send(1331202,{monsterId = self.mosterId,optionVal = optionVal})
    end
end

function ShenShouPanel:onClickXianshi()
    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = self.mosterId})
    end
end
function ShenShouPanel:onClickAdd()
    local vipConf = conf.VipChargeConf:getAllVIPAwards()
    local maxVIP = #vipConf - 1
    local curVipLv = cache.PlayerCache:getVipLv()
    --当前vip可购买次数
    local curCountConf = conf.VipChargeConf:getShenShouReset(curVipLv)
    --最大可购买次数
    local maxCanRest = conf.VipChargeConf:getShenShouReset(maxVIP)
    --当前剩余可购买次数
    local curCount = curCountConf - self.dayBuyCount
    local money = conf.FubenConf:getBossValue("ssd_boss_buy_cost")
    local t = clone(language.fuben225)
    t[1].text = string.format(t[1].text,money[2])
    t[3].text = string.format(t[3].text,curCount)
    --可以购买次数的VIp等级
    local nextVip
    for i= 0, maxVIP do
        local rest = conf.VipChargeConf:getShenShouReset(i)
        if rest > curCountConf then
            nextVip = i
            break
        end
    end
    local param = {
        type = 14,
        richtext = mgr.TextMgr:getTextByTable(t),
        okUrl = UIItemRes.imagefons04,
        sure = function()
            if curCount <= 0 then--剩余疲劳值不足
                local t1 = clone(language.fuben226)
                t1[3].text = string.format(t1[3].text,nextVip and nextVip or maxVIP)
                local t2 = clone(language.fuben227)
                t2[1].text = string.format(t2[1].text,maxCanRest)
                if curCountConf == maxCanRest then
                     curVipLv = maxVIP
                end
                local richStr = tonumber(curVipLv) == tonumber(maxVIP) and t2 or t1
                local temp = {
                    type = 5,
                    sureIcon = curVipLv == maxVIP and UIItemRes.imagefons01 or UIItemRes.imagefons06,
                    richtext = mgr.TextMgr:getTextByTable(richStr),
                    sure = function ()
                        if curVipLv == maxVIP then
                        
                        else
                            GGoVipTequan(1)
                            self.mParent:closeView()
                        end
                    end
                }
                GComAlter(temp)
                return
            else
                proxy.FubenProxy:send(1330305,{sceneKind = 49,count = 1})--9世界boss31宠物岛49神兽岛
            end
        end
    }
    GComAlter(param)
end


function ShenShouPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.isSpecialEffect = false
    self.mosterId = 0
    self.bgImg.url = ""
    self.listView.numItems = 0
    self.initSceneId = nil
    
end


return ShenShouPanel