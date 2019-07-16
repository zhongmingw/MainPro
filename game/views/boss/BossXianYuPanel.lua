
local BossXianYuPanel = class("BossXianYuPanel",import("game.base.Ref"))
local kuafuxianyu_diaoluoBtn_pos = {pos1={840,148},pos2={840,324}} --跨服仙域禁地第三层隐藏BOSS掉落按钮位置记录 

function BossXianYuPanel:ctor(mParent,modelId)
    self.mParent = mParent
    self.modelId = modelId or 1135
    if modelId == 1135 then--仙域禁地
        -- self.initSceneId = BossScene.xianyuBoss
        self.panelObj = self.mParent.view:GetChild("n27")
    elseif modelId == 1221 then--跨服禁地
        -- self.initSceneId = BossScene.kuafuXianyu
        self.panelObj = self.mParent.view:GetChild("n29")
    elseif modelId == 1242 then--上古神迹
        -- self.initSceneId = BossScene.sgsj
        self.panelObj = self.mParent.view:GetChild("n30")
    elseif modelId == 1324 then--飞升神殿
        self.panelObj = self.mParent.view:GetChild("n32")
    end
    self:initPanel()
end

function BossXianYuPanel:initPanel()
    self.mosterId = 0--怪物id
    local panelObj = self.panelObj
    self.mainController = panelObj:GetController("c1")--主控制器

    self.countText = panelObj:GetChild("n12")
    self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben122, 6) 

    local addBtn = panelObj:GetChild("n16")--bxp 世界boss增加购买次数
    addBtn.onClick:Add(self.onClickAdd,self)
    if self.modelId == 1242 then
        self.mainController.selectedIndex = 5
        local textDec = panelObj:GetChild("n23")
        textDec.text = language.fuben224
    elseif self.modelId == 1324 then
        self.mainController.selectedIndex = 7

    else
        self.mainController.selectedIndex = 3
    end

    self.sceneListView = panelObj:GetChild("n17")--场景层
    self.sceneListView:SetVirtual()
    self.sceneListView.itemRenderer = function(index,obj)
        self:cellSceneData(index, obj)
    end
    self.sceneListView.onClickItem:Add(self.onClickSceneItem,self)

    self.listView = panelObj:GetChild("n4")--boss
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.listAwardsList = panelObj:GetChild("n5")--掉落奖励
    self.listAwardsList:SetVirtual()
    self.listAwardsList.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local desc = panelObj:GetChild("n7")
    desc.text = language.fuben58
    self.descText = panelObj:GetChild("n9")
    self.descText.text = ""
    self.countDec = panelObj:GetChild("n20")
    self.countDec.visible = true
    self.playerKill = panelObj:GetChild("n8")--上轮击杀者
    self.warLvText = panelObj:GetChild("n10")--挑战等级
    local warBtn = panelObj:GetChild("n11")
    warBtn.onClick:Add(self.onClickWar,self)
    
    self.modelPanel = panelObj:GetChild("n14")
    self.bgImg = panelObj:GetChild("n3")
    local followBtn = panelObj:GetChild("n15")
    self.followBtn = followBtn
    followBtn.onChanged:Add(self.onClickFollow,self)
    self.tipDesc = panelObj:GetChild("n21")
    self.tipDesc.text = language.fuben180

    local btn = panelObj:GetChild("n22")
    btn.onClick:Add(self.onClickXianshi,self)

    if self.modelId == 1324 then
        btn.visible = false
    else
        btn.visible = true
    end

end

function BossXianYuPanel:setGotoMonsterId(monsterId)
    self.gotoMonsterId = monsterId
end

function BossXianYuPanel:setData(data)
    printt("县域禁地",data)
    self.leftCount = data.leftCount
    self.bgImg.url = UIItemRes.bossWorld
    local bossInfos = data and data.bossInfos or {}
    self.leftTired = data and data.leftTired or 0
    self.tipConfMap = data and data.tipConfMap or {}
    self.dayBuyCount = data and data.dayBuyCount or 0
    -- print("当前模块id>>>>>>>>>>>>>",self.modelId,bossInfos)
    -- if self.modelId ~= 1135 and self.modelId ~= 1242 then--跨服仙域禁地特殊取场景类型
    --     local sceneId = bossInfos[1].sceneId
    --     local sceneData = conf.SceneConf:getSceneById(sceneId)
    --     local kind = sceneData and sceneData.kind or 0
    --     if kind == SceneKind.kuafuXianyu then
    --         self.initSceneId = BossScene.kuafuXianyu
    --     else
    --         self.initSceneId = BossScene.kuafuXianyu2
    --     end
    -- end

    if not self.initSceneId then
        self.initSceneId = bossInfos[1].sceneId
        if self.modelId == 1324 then
            local A541 = cache.PlayerCache:getAttribute(541)
            local max = conf.FubenConf:getFszdMaxId()
            local _index = 1
            for i = 1 , max do
                local condata = conf.FubenConf:getFszdlayer(i)
                for k  , j in pairs(condata.con) do
                    if j == A541 then
                        _index = i
                        break
                    end 
                end
                
            end
            for i , j in pairs(bossInfos) do
                if string.sub(j.sceneId,-1,-1) == tostring(_index) then
                    self.initSceneId = j.sceneId
                    break
                end
            end
        end
    end


    self.tipConfMap = data and data.tipConfMap or {}
    table.sort(bossInfos,function(a,b)
        if a.sceneId == b.sceneId then
            local aConf = conf.MonsterConf:getInfoById(a.monsterId)
            local bConf = conf.MonsterConf:getInfoById(b.monsterId)
            local alvl = aConf and aConf.level or 0
            local blvl = bConf and bConf.level or 0
            return alvl < blvl
        else
            return a.sceneId < b.sceneId
        end
    end)
    self.bossInfos = {}--二维表
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
                    if self.modelId == 1324 then
                        cache.FubenCache:setFSBossIndex(k - 1)
                    elseif self.modelId ~= 1242 then
                        cache.FubenCache:setXianYuBossIndex(k - 1)
                    else
                        cache.FubenCache:setShangGuBossIndex(k - 1)
                    end
                    pageIndex = (sceneId - self.initSceneId)==0 and 0 or 1
                    break
                end
            end
        end
    end
    --print("pageIndex",pageIndex,self.gotoMonsterId)
    self.sceneListView.numItems = page
    self.sceneListView:ScrollToView(pageIndex)
    self:initChooseScene()
    if self.modelId == 1324 then
        self.countText.text =  mgr.TextMgr:getTextColorStr(language.fuben68, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    end
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.gotoMonsterId = nil
end

function BossXianYuPanel:initChooseScene()
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
--层数
function BossXianYuPanel:cellSceneData(index,cell)
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
    cell.title = sceneData and sceneData.name or "Boss之家"
    cell.data = sceneData
end

function BossXianYuPanel:onClickSceneItem(context)

    local btn = context.data
    local sceneData = context.data.data
    local value = ""
    if self.modelId == 1135 then--仙域禁地
        value = "xyjd_lvs"
    elseif self.modelId == 1221 then--跨服禁地
        value = "cross_xyjd_lvs"
    elseif self.modelId == 1242 then--上古神迹
        value = "sgsj_lvs"
    elseif self.modelId == 1324 then--飞升
        value = "fs_in_pass"
    end
    local sceneId = sceneData.id or self.initSceneId
    
    local index = sceneId%1000 - 1
       
    if self.modelId  == 1324  then
        --1、每层进入条件：X转（配置，0转及1转只能进第一层，1转2转3转能进第二层，）
        --print("sceneId",sceneId,index)
        --local condata = conf.FubenConf:getFszdlayer(i)
        local confdata = conf.FubenConf:getFszdlayer(index+1)
        local A541 =  cache.PlayerCache:getAttribute(541)
        local can = false
        if not confdata  then
            can = true
            print("没有进入条件 世界boss配置 fszd_layer")
        else
            for k , v in pairs(confdata.con) do
            if v == A541 then
                    can = true
                end
            end
            --can = A541>= confdata[index + 1] 
        end
        if not can then
            GComAlter(language.fs37 )
            btn.selected = false
            if self.chooseBtn then self.chooseBtn.selected = true end
            return
        end
    else
        local openLv = conf.FubenConf:getBossValue(value)[index] or 0
        if self.modelId == 1135 or self.modelId == 1221 then
            openLv = conf.FubenConf:getBossValue(value)[index+ 1] or 0
        end
        if cache.PlayerCache:getRoleLevel() < openLv then

            GComAlter(string.format(language.gonggong07, openLv))
            btn.selected = false
            if self.chooseBtn then self.chooseBtn.selected = true end
            return
        end
        --飞升第三层加限制
        if self.modelId == 1242 and sceneId == 260002 and index == 2 then
            if cache.PlayerCache:getAttribute(541) ~= 2 then
                GComAlter(string.format(language.fs37))
                btn.selected = false
                if self.chooseBtn then self.chooseBtn.selected = true end
                return
            end
        end
    end
    self.initSceneId = sceneId
    self.chooseBtn = btn
    self.bossList = self.bossInfos[sceneId]

        --跨服仙域禁地隐藏BOSS处理
    self.ishashideBoss = false
    self.isxyjdhideBoss = false
    if self.modelId == 1135 and index == 2 then
        self.isxyjdhideBoss = true
        self:showXianyuCom( true )
       
    else
        self:showXianyuCom( false )
    end

    if (sceneId == 258003 and index == 2) or (sceneId == 235003 and index == 2) then
        local data1 = {}
        local tab = {}
        local conf = conf.FubenConf:getKfXyjdHideBoss()
        for k,v in pairs(conf) do
            tab[v.item[1]] = 1
        end
        for k,v in pairs(self.bossList) do
            if  (v.sceneId == 258003 or v.sceneId == 235003 )  and not  tab[v.monsterId] then
                    table.insert(data1,  v)
                   
            end
        end
        self.bossList = data1
        self.listView.numItems = #self.bossList + 1
      
    else
        self.listView.numItems = #self.bossList   
    end
    
    if self.modelId == 1324 then
        if cache.FubenCache:getFSBossIndex() > #self.bossList - 1 then
            cache.FubenCache:setFSBossIndex(0)
        end
        self.listView:ScrollToView(cache.FubenCache:getFSBossIndex())
    elseif self.modelId ~= 1242 then
        if cache.FubenCache:getXianYuBossIndex() > #self.bossList - 1 then
            cache.FubenCache:setXianYuBossIndex(0)
        end
        self.listView:ScrollToView(cache.FubenCache:getXianYuBossIndex())
    else
        if cache.FubenCache:getShangGuBossIndex() > #self.bossList - 1 then
            cache.FubenCache:setShangGuBossIndex(0)
        end
        self.listView:ScrollToView(cache.FubenCache:getShangGuBossIndex())
    end
    for k = 1,#self.bossList do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local change = cell.data
            local index = change.index
            local indexCache = cache.FubenCache:getXianYuBossIndex()
            -- if not self.ishashideBoss and indexCache == 0 and sceneId == 258003 then
            --     self.listView:GetChildAt(k).onClick:Call()
            --     break
            -- end
            if self.modelId == 1242 then
                indexCache = cache.FubenCache:getShangGuBossIndex()
            elseif self.modelId == 1324 then
                indexCache = cache.FubenCache:getFSBossIndex()
            end
            if index == indexCache then--选中boss
                cell.onClick:Call()
                break
            end
        end
    end

end

function  BossXianYuPanel:onClickToScene()
    mgr.FubenMgr:gotoFubenWar2(self.sceneId)
end



-- 跨服仙域禁地隐藏BOSS组件显隐
function  BossXianYuPanel:showXianyuCom( flag )
     self.panelObj:GetChild("n26").visible = flag
     self.panelObj:GetChild("n31").visible = flag
     self.panelObj:GetChild("n27").visible = flag
     if flag then
        local list = self.panelObj:GetChild("n31")
        local confdata = conf.FubenConf:getKfXyjdHideAward()
    
        list.itemRenderer = function ( index,obj )
            local mConf = conf.MonsterConf:getInfoById(confdata[index + 1][1])
            local mConf1 = conf.MonsterConf:getInfoById(confdata[index + 1][2]) 
            obj:GetChild("n28").text = mConf.name
            local lvText = obj:GetChild("n29")
            local lvl = mConf and mConf.level or 1
            local str = "LV:"..lvl
            if cache.PlayerCache:getRoleLevel() >= lvl then
                lvText.text = mgr.TextMgr:getTextColorStr(str, 5)
            else
                lvText.text = mgr.TextMgr:getTextColorStr(str, 14)
            end
        local num = 0 --
        for k,v in pairs(self.bossInfos[self.initSceneId]) do
      
            if (v.monsterId == mConf.id )  or (v.monsterId == mConf1.id )  then
                self.ishashideBoss = true
                num = num + 1
            end 
        end
        local numText = obj:GetChild("n30")
        numText.text  = num>0 and  mgr.TextMgr:getTextColorStr(num.."",10 ) or mgr.TextMgr:getTextColorStr("0", 14)
        end
        list.numItems = #confdata
        self.panelObj:GetChild("n22"):SetXY(kuafuxianyu_diaoluoBtn_pos.pos1[1],kuafuxianyu_diaoluoBtn_pos.pos1[2])
     else
          self.panelObj:GetChild("n22"):SetXY(kuafuxianyu_diaoluoBtn_pos.pos2[1],kuafuxianyu_diaoluoBtn_pos.pos2[2])
     end
end
--boss列表
function BossXianYuPanel:cellData(index,cell)
    --跨服仙域禁地隐藏BOSS处理
    if self.modelId == 1135 and index == 0 and self.isxyjdhideBoss then
       
        cell:GetChild("n10").visible = false 
        cell:GetChild("n5").visible = false 
        cell:GetChild("n4").visible = false 
        cell:GetChild("n8").text = language.xyjd02
        cell:GetChild("n7").text = language.xyjd01
        local Img = cell:GetChild("icon")
        if self.ishashideBoss then
            Img.grayed = false
        else
            Img.grayed = true
        end
        if self.initSceneId == 258003  then -- 跨服标志显示
            cell:GetChild("n9").visible = true
        else
            cell:GetChild("n9").visible = false
        end
        cell.data = {data = {sceneId=235003}, index = index,model = 3076213}
        return
    end
    
    local key 
    if self.isxyjdhideBoss then
         key = index 
    else
         key = index + 1
    end

    local data = self.bossList[key]
    local image1 = cell:GetChild("n1")
    local image2 = cell:GetChild("n2")
    local icon = cell:GetChild("icon")
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
    local timeText = cell:GetChild("n10")--刷新时间
    local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
    if time > 0 then
        timeText.text = GTotimeString(time)
    else
        timeText.text = ""
    end
    local model = data.monsterId
    local mConf = conf.MonsterConf:getInfoById(model)
    local name = mConf and mConf.name or ""
    local bossText = cell:GetChild("n8")
    bossText.text = name
    local lvl_section = sceneData and sceneData.lvl_section
    local lvText = cell:GetChild("n7")
    local lvl = mConf and mConf.level or 1
    local str = "LV"..lvl
    if cache.PlayerCache:getRoleLevel() >= lvl then
        lvText.text = mgr.TextMgr:getTextColorStr(str, 5)
    else
        lvText.text = mgr.TextMgr:getTextColorStr(str, 14)
    end
    local arleayImg = cell:GetChild("n4")--已刷新
    local unAppear = cell:GetChild("n5")--未出现
    local bossStatu = data.bossStatu
    arleayImg.visible = false
    unAppear.visible = false
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
    cell.data = {data = data, index = index, model = model}
  
end

function BossXianYuPanel:cellAwardsData(index, cell)
    local awardData = self.awards[index + 1]
    local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
    GSetItemData(cell, itemData, true)
end

function BossXianYuPanel:onTimer()
    if self.listView.numItems > 0 then
        for k = 1,self.listView.numItems do
            local cell = self.listView:GetChildAt(k - 1)
            if cell then
                local change = cell.data
                local data = change.data
                if data.bossStatu == 1 then--boss已经死了
                    local timeText = cell:GetChild("n10")--刷新时间
                    local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
                    if time > 0 then
                        timeText.text = GTotimeString(time)
                    else
                        timeText.text = ""
                        plog("boss刷新时间",data.nextRefreshTime,"当前服务器时间",mgr.NetMgr:getServerTime(),time,data.monsterId.."的时间已到,需要刷新")
                        data.nextRefreshTime = 0
                        data.bossStatu = 3
                        if self.modelId == 1135 then--仙域禁地
                            proxy.FubenProxy:send(1330401)
                        elseif self.modelId == 1221 then--跨服禁地(丛林遗迹)
                            proxy.FubenProxy:send(1330601)
                        elseif self.modelId == 1242 then--上古神迹
                            proxy.FubenProxy:send(1330801)
                        elseif self.modelId == 1324 then--飞升
                            proxy.FubenProxy:send(1331101)
                        end
                        break
                    end
                end
            end
        end
    end
end

function BossXianYuPanel:onClickItem(context)

    local cell = context.data
    local change = cell.data
    local data = change.data
    self.sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(data.sceneId)
    self.playerKill.text = data.lastKillName
    local lvl = sceneData.lvl or 1
    self.warLvText.text = string.format(language.gonggong16, lvl)
    self.bossStatu = data.bossStatu
    if self.modelId == 1324 then
        cache.FubenCache:setFSBossIndex(cell.data.index)
    elseif self.modelId ~= 1242 then
        cache.FubenCache:setXianYuBossIndex(cell.data.index)
    else
        cache.FubenCache:setShangGuBossIndex(cell.data.index)
    end
    self:addBossModel(change.model)
    local optionVal = self.tipConfMap[self.mosterId] or 0--是否关注过
    if optionVal == 0 then
        self.followBtn.selected = false
    else
        self.followBtn.selected = true
    end

    local vip = cache.PlayerCache:getVipLv()
    -- local confData = conf.VipChargeConf:getVipAwardById(vip)
    -- local count = confData and confData.vip_tequan[2][2] or 0
    if self.modelId == 1324 then
        --local confdata = conf.FubenConf:getBossValue("fs_in_vip")
        --print("cell.data.index",self.initSceneId)
        --local confdata1 = conf.FubenConf:getBossValue("fs_in_pass")

        local _index = self.initSceneId % 1000
        local confdata = conf.FubenConf:getFszdlayer(_index)
        if not confdata or not confdata.vip_con  then
            self.descText.text = ""
        else
            --print(language.fs38,confdata[_index])
            self.descText.text = string.format(language.fs38,confdata.vip_con)
        end
        -- if confdata1[_index] and confdata1[_index] > 0 then
        --     self.descText.text = self.descText.text .. string.format(language.fs43,confdata1[_index])
        -- end
        if confdata and confdata.con then
            local ss = ""
            for k , v in pairs(confdata.con) do
                ss = ss .. v .. language.fs21
                if k ~= #confdata.con then
                    ss = ss.."、"
                end
            end
            self.countDec.text =string.format(language.fs43,ss )  
        else
            self.countDec.text = ""
        end
        
    else
        local textData = {
                            {text = language.fuben03,color = 6},
                            {text = self.leftCount,color = 7},
                        }
        self.descText.text = mgr.TextMgr:getTextByTable(textData)
        self.countDec.text = language.fuben176
    end
    --仙域禁地第三层隐藏BOSS
  
    if self.sceneId%1000  == 3 and self.modelId == 1135  then
        if change.index == 0 then
            self.panelObj:GetChild("n15").visible = false
            self.panelObj:GetChild("n13").visible = false
            self.hidebossindex = true
            self:showXianyuCom( true )
        else
               self.hidebossindex = false
            self.panelObj:GetChild("n15").visible = true
            self.panelObj:GetChild("n13").visible = true
            self:showXianyuCom( false )

        end
    end
    
end

function BossXianYuPanel:addBossModel(model)
    local mConf = conf.MonsterConf:getInfoById(model)
    self.mosterId = model
    local awardData = {}
    if self.modelId == 1135 then--仙域禁地
        awardData = conf.FubenConf:getXyjdAward(model)
    elseif self.modelId == 1221 then--跨服仙域禁地
        awardData = conf.FubenConf:getKfXyjdAward(model)
    elseif self.modelId == 1242 then--上古神迹
        awardData = conf.FubenConf:getSgsjAward(model)
    elseif self.modelId == 1324 then
        awardData = conf.FubenConf:getfszdAward(model)
        
    end
    local awardLv = awardData and awardData.no_reward_lev or 1
    if cache.PlayerCache:getRoleLevel() >= awardLv then
        self.tipDesc.visible = true
    else
        self.tipDesc.visible = false
    end
    local name = mConf and mConf.name or ""
    self.awards = mConf and mConf.normal_drop or {}
    self.listAwardsList.numItems = #self.awards
    local src = mConf and mConf.src or 0

    local modelObj = self.mParent:addModel(src,self.modelPanel)--添加模型
    modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(100)
end
--关注
function BossXianYuPanel:onClickFollow()
    if self.mosterId > 0 then
        local optionVal = 0
        if self.followBtn.selected then
            optionVal = 1
        end
        self.tipConfMap[self.mosterId] = optionVal
        if self.modelId == 1135 then--仙域禁地
            proxy.FubenProxy:send(1330402,{monsterId = self.mosterId,optionVal = optionVal})
        elseif self.modelId == 1221 then--跨服仙域禁地
            proxy.FubenProxy:send(1330602,{monsterId = self.mosterId,optionVal = optionVal})
        elseif self.modelId == 1242 then--上古神迹
            proxy.FubenProxy:send(1330802,{monsterId = self.mosterId,optionVal = optionVal})
        elseif self.modelId == 1324 then--飞升
            proxy.FubenProxy:send(1331102,{monsterId = self.mosterId,optionVal = optionVal})
        end
    end
end

function BossXianYuPanel:onClickXianshi()
    local mosterId1 
     if self.modelId == 1135 and self.initSceneId%1000 == 3 and  self.hidebossindex then
            mosterId1 = 3076213
     else
            mosterId1 = self.mosterId
     end

    if self.mosterId > 0 then
        mgr.ViewMgr:openView2(ViewName.BossCCAwardsView, {mosterId = mosterId1})
    end
end

function BossXianYuPanel:onClickWar()
    --221041957
    local modelId = self.modelId or 1135
    local proId = 221041957
    if modelId == 1135 then--仙域禁地
        proId = 221041957
    elseif modelId == 1221 then--跨服禁地
        proId = 221042602
    elseif modelId == 1242 then--上古神迹
        proId = 221042699
    elseif modelId == 1324 then --飞升
        --检测疲劳
        
        if self.leftTired <= 0 then
            GComAlter(language.fuben84)
            return
        end

        --检测VIP等级
        -- local confdata = conf.FubenConf:getBossValue("fs_in_vip")
        local _index = self.initSceneId % 1000
        local confdata = conf.FubenConf:getFszdlayer(_index)
        -- print("confdata.vip_con",confdata.vip_con)
        if not confdata or not confdata.vip_con  then

        else
            if cache.PlayerCache:getVipLv() < confdata.vip_con then
                local param = {}
                param.type = 14
                param.richtext = string.format(language.fs46,confdata.vip_con,confdata.cost_gold[2])
                param.cancelUrl = UIItemRes.imagefons07
                param.cancel = function ()
                    GGoVipTequan(1)
                end
                param.sure = function ()
                    cache.FubenCache:setChooseBossId(self.mosterId)
                    mgr.FubenMgr:gotoFubenWar2(self.sceneId)
                end
                GComAlter(param)
                -- GComAlter(string.format(language.fs38,confdata.vip_con))
                return
            end
        end
        cache.FubenCache:setChooseBossId(self.mosterId)
        mgr.FubenMgr:gotoFubenWar2(self.sceneId)
        return
    end
    if self.leftCount <= 0 then
        GComAlter(language.fuben154)
    else
        local itemCount = cache.PackCache:getPackDataById(proId).amount --入场券数量
        local vip = cache.PlayerCache:getVipLv()
        local confData = conf.VipChargeConf:getVipAwardById(vip)
        local count = confData and confData.vip_tequan[2][2] or 0
        local keyConf = conf.FubenConf:getBossValue("xyjd_tikey_conf")
        local ybNum = conf.FubenConf:getBossValue("xyjd_tikey_price") --每张入场券对应的元宝
        if modelId == 1221 then--跨服禁地
            keyConf = conf.FubenConf:getBossValue("kf_xyjd_tikey_conf")
            ybNum = conf.FubenConf:getBossValue("kf_xyjd_tikey_price")
        elseif modelId == 1242 then--上古神迹
            keyConf = conf.FubenConf:getBossValue("sgsj_tikey_conf")
            ybNum = conf.FubenConf:getBossValue("sgsj_tikey_price")
        end
        local index = (count - self.leftCount + 1) > #keyConf and #keyConf or (count - self.leftCount + 1)
        local needCount = keyConf[index] --需要的入场券数量
        local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        local myByb = cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
        local data = {}
        data.itemInfo = {mid = proId,amount = itemCount,bind = 1}
        if modelId == 1135 then--仙域禁地
            data.text1 = language.fuben171
            data.text2 = string.format(language.fuben172,needCount)
        elseif modelId == 1221 then--跨服禁地
            data.text1 = language.fuben216
            data.text2 = string.format(language.fuben217,needCount)
        elseif modelId == 1242 then--上古神迹
            data.text1 = language.fuben216_1
            data.text2 = string.format(language.fuben217_1,needCount)
        end
        if itemCount >= needCount then
            data.text3 = language.fuben174
        else
            local needYb = ybNum*(needCount - itemCount)
            data.text3 = string.format(language.fuben173,needYb)
        end
        data.sure = function ()
            if itemCount >= needCount then
                if self.ishashideBoss then
                    cache.FubenCache:setChooseBossId(nil)
                else
                    cache.FubenCache:setChooseBossId(self.mosterId)
                end
                --上古3层需飞升2转
                printt(data)
                mgr.FubenMgr:gotoFubenWar2(self.sceneId)
            else
                local needYb = ybNum*(needCount - itemCount)
                local param = {}
                param.type = 2
                param.richtext = string.format(language.fuben175,needYb)
                param.sure = function()
                     if self.ishashideBoss then
                        cache.FubenCache:setChooseBossId(nil)
                    else
                        cache.FubenCache:setChooseBossId(self.mosterId)
                    end
                    local sgdata = conf.FubenConf:getBossValue("sgsj_join_zhuan_limit")
                    if self.sceneId == sgdata[1][1] and cache.PlayerCache:getAttribute(541) < sgdata[1][2] then --上古神迹第三层飞升等级至少要2转
                        GComAlter(language.fuben240)
                        return
                    end
                    mgr.FubenMgr:gotoFubenWar2(self.sceneId)
                end
                GComAlter(param)
            end
        end
        mgr.ViewMgr:openView(ViewName.XianYuJinDiTips,function(view)
            view:setData(data)
        end)
    end

end

function BossXianYuPanel:clear()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.mosterId = 0
    self.bgImg.url = ""
    self.sceneListView.numItems = 0
    self.listView.numItems = 0
    self.initSceneId = nil
end

function BossXianYuPanel:onClickAdd()
    local vipConf = conf.VipChargeConf:getAllVIPAwards()
    local maxVIP = #vipConf - 1
    local curVipLv = cache.PlayerCache:getVipLv()
    --当前vip可购买次数
    local curCountConf = conf.VipChargeConf:getFsBossRest(curVipLv)
    --最大可购买次数
    local maxCanRest = conf.VipChargeConf:getFsBossRest(maxVIP)
    --当前剩余可购买次数
    local curCount = curCountConf - self.dayBuyCount
    local money = conf.FubenConf:getBossValue("fszd_boss_buy_cost")
    local t = clone(language.fuben225)
    t[1].text = string.format(t[1].text,money[2])
    t[3].text = string.format(t[3].text,curCount)
    --可以购买次数的VIp等级
    local nextVip
    for i= 0, maxVIP do
        local rest = conf.VipChargeConf:getFsBossRest(i)
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
                proxy.FubenProxy:send(1330305,{sceneKind = 47,count = 1})--9:世界boss 31:宠物岛
            end
        end
    }
    GComAlter(param)
end


function BossXianYuPanel:setBossLeftTimes( data )
    -- body
    if data and data.sceneKind == 47 then
        --self.mData = data
        self.leftTired = data and data.leftTired or 0
        self.countText.text = mgr.TextMgr:getTextColorStr(language.fuben165, 6)..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
    end
end
return BossXianYuPanel