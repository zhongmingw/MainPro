--
-- Author: EVE
-- Date: 2017-12-04 21:18:37
-- DESC: 天书活动
--

local HighGradePackageView = class("HighGradePackageView", base.BaseView)

function HighGradePackageView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale
    self.uiClear = UICacheType.cacheTime
    self.isBlack = true

    -- print("打开界面之前的红点值：", cache.PlayerCache:getRedPointById(30124))
    -- print("BUFFFFFFFFFFFF：", cache.PlayerCache:getRedPointById(30126))
end

function HighGradePackageView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onCloseView, self)

    --Tab页签控制
    self.tabC1 = self.view:GetController("c1")
    self.tabC1.onChanged:Add(self.onControlChange,self)

    --Buff收集状态
    self.buffC2 = self.view:GetController("c2")
    self.buffC2.selectedIndex = 1

    --领取列表
    self.getList = self.view:GetChild("n8")

    --BUFF
    self.buffGetDesc = self.view:GetChild("n18") --获取途径描述
    self.buffGetDesc.text = ""
    self.buffProgressDesc = self.view:GetChild("n12") --进度描述
    self.buffProgressDesc.text = ""
    local buffGetBtn = self.view:GetChild("n15") --按钮
    buffGetBtn.onClick:Add(self.getBuff, self)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

    --标志位
    self.flag = true
    
    --地级和天级根据上一层开启， 仙级和神级根据等级开启
    --层级遮罩（用于设定层级是否可以跳转）
    self.layerList = {}  
    for i=1,2 do
        local tempPanel = self.view:GetChild("n2"..i)
        table.insert(self.layerList, tempPanel)
        self.layerList[i].onClick:Add(self.onForbid, self)
    end
    --等级开启的层级
    self.openLvLayerList = {}
    for i=4,5 do
        local confData = conf.ActivityConf:getHighGradePackgeBuffConf(i)
        local tempPanel = self.view:GetChild("n2"..(i-1))
        tempPanel.data = confData.open_lv
        tempPanel.onClick:Add(self.checkOpen, self)
        table.insert(self.openLvLayerList, tempPanel)
    end
    --这个列表里不包含第一个按钮
    self.btnList = {}
    for i=4,7 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.btnList, btn)
    end
end

function HighGradePackageView:initData()
    -- body
    self:setGetList() --主列表
end

function HighGradePackageView:setGetList()
    -- body
 
    self.getList.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.getList:SetVirtual()

    self.getList.numItems = 0
end
function HighGradePackageView:addGuiide()
    -- body
    --检测是否有个引导
    if not cache.GuideCache:getGuide() then
        return
    end
    cache.GuideCache:setGuide(nil)

    
    if self.getList.numItems == 0 then
        return 
    end 
    if self.tabC1.selectedIndex ~= 0 then
        return
    end

    local cell = self.getList:GetChildAt(0)
    if not cell then
        return
    end
    local c1 = cell:GetController("c1") 
    if c1.selectedIndex == 0 then 
        local btn = cell:GetChild("n7")
        local param = {}
        param.richang = btn 
        param.nilthing = "tianshu"
        mgr.ViewMgr:openView2(ViewName.GuideLayer,param)
    end
end
function HighGradePackageView:itemData(index, obj)
    local data = self.awardConfData[index+1]

    local itemC1 = obj:GetController("c1")      --领取状态
    local itemC2 = obj:GetController("c2")      --是否BOSS
    local equipList = obj:GetChild("n8")        --推荐装备
    local equipListText = obj:GetChild("n14")   --推荐装备文字描述
    local explain = obj:GetChild("n4")          --领取条件显示
    local moneyIcon = obj:GetChild("n11")       --奖励的金钱LOGO
    local curProgress = obj:GetChild("n13")     --当前进度
    curProgress.text = ""

    --领取状态(1,2,4)
    if self.data then   
        if self.got[data.id] then   --已领取
            itemC1.selectedIndex = 2

        elseif self.data.otherInfo[data.id] 
        and self.data.otherInfo[data.id] < 0 
        and not self.got[data.id] then  --领取

            itemC1.selectedIndex = 0
            local btnGet = obj:GetChild("n7")
            btnGet.data = data.id 
            btnGet.onClick:Add(self.onClickGet,self)

        else  --未达成
            itemC1.selectedIndex = 1
        end

        -- print("当前领取状态",index+1,itemC1.selectedIndex)
    else
        print("服务端消息没返回~！")
    end

    if self.tabC1.selectedIndex ~= 2 then  --非BOSS
        itemC2.selectedIndex = 0
        if self.tabC1.selectedIndex ~= 4 then--非神级
            GSetAwards(equipList,data.reco_equip)       --推荐装备
            equipListText.text = data.reco_equip_text   --推荐装备文字描述
        end

        if self.tabC1.selectedIndex == 0 then  --第一页       
            explain.text = string.format(language.skybook01[1], 
                data.cond, 
                self:setMoneyAmount(data.condition[1]))
            moneyIcon.url = UIItemRes.moneyIcons[data.condition[2]]
            curProgress.text = string.format(language.skybook05, self.curPower, data.cond)
        elseif self.tabC1.selectedIndex == 1 then  --第二页
            --阶数
            local class = math.floor(data.cond/1000)
            --品质
            local quality = math.floor((data.cond-class*1000)/100)
            --部位
            local pos = data.cond-class*1000-quality*100

            explain.text = string.format(language.skybook01[2], 
                class, 
                language.skybook03[quality], 
                language.skybook02[pos],
                self:setMoneyAmount(data.condition[1]))
            moneyIcon.url = UIItemRes.moneyIcons[data.condition[2]]

        elseif self.tabC1.selectedIndex == 3 then  --第四页
            --类别 1诛仙/2诸神
            local category = math.floor(data.cond/1000)
            --部位
            local pos = data.cond - category*1000

            explain.text = string.format(language.skybook01[4], 
                language.skybook02[pos],
                language.skybook06[category], 
                data.condition[1])
            moneyIcon.url = UIItemRes.moneyIcons[data.condition[2]]   
        elseif self.tabC1.selectedIndex == 4 then  --神级天书
            itemC2.selectedIndex = 2
            explain.text = string.format(language.skybook14[data.cond],self:setMoneyAmount(data.condition[1]))
            moneyIcon.url = UIItemRes.moneyIcons[data.condition[2]]   
            local specialIconList = obj:GetChild("n16")--特殊icon
            specialIconList.itemRenderer = function (index, cell)
                self:cellGodIcon(index, cell)
            end
            self.godIcon = data.god_icon
            specialIconList.numItems = #data.god_icon
            local color = 7
            local progress = 0
            if itemC1.selectedIndex == 1 then--未达成
                progress = 0
                color = 14
            else
                progress = 1
                color = 7
            end
            local textData = {
                {text = progress,color = color},
                {text = "/",color = 7},
                {text = "1",color = 7},
            }
            curProgress.text = "("..mgr.TextMgr:getTextByTable(textData)..")"
        end
    end  
    if self.tabC1.selectedIndex == 2 then --BOSS
        itemC2.selectedIndex = 1      

        if self.tabC1.selectedIndex == 2 then  --第三页
            --BOSS类型
            local bossType = data.boss_type

            explain.text = string.format(language.skybook01[3], 
                mgr.TextMgr:getTextColorStr(language.skybook07[bossType], 15),
                self:setMoneyAmount(data.condition[1]))
            moneyIcon.url = UIItemRes.moneyIcons[data.condition[2]]
        end

        --Boss击杀进度
        local isFinish = false
        if self.data and self.data.bossInfo[data.id] then      
            -- local killSum = #self.data.bossInfo[data.id]["bossInfo"] --已击杀数
            local needKillSum = #data.monsters 

            -- print("击杀进度",killSum, needKillSum, data.id)          --需要击杀数
            -- if killSum >= needKillSum then 
            --     isFinish = true
            -- else 
            --     isFinish = false
            -- end

            -- 坑爹BOSS修改版 
            local tempVal = 0
            for k,v in pairs(data.monsters) do            
                for i,j in pairs(self.data.bossInfo[data.id]["bossInfo"]) do
                    if v == j.monsterId then 
                        tempVal = tempVal + 1
                    end 
                end
            end  

            if tempVal == needKillSum then 
                isFinish = true
            else
                isFinish = false
            end 
        end 

        --领取状态(3)
        if self.data then                
            if self.got[data.id] then   --已领取
                itemC1.selectedIndex = 2

            elseif isFinish and not self.got[data.id] then  --领取
            
                itemC1.selectedIndex = 0
                local btnGet = obj:GetChild("n7")
                btnGet.data = data.id 
                btnGet.onClick:Add(self.onClickGet,self)

            else  --未达成
                itemC1.selectedIndex = 1
            end
        else
            print("服务端消息没返回~！")
        end
       
        self.bossIconList = obj:GetChild("n15") --BOSS图标
        self.bossIconConf = data.boss_icon      --BOSS图标配表
        self.bossIsOver = itemC1.selectedIndex  --BOSS领取状态
        self.curItem = data.id                  --当前的Item
        self.bossData = {bossType = data.boss_type, bossId = data.monsters}
        self:setBossIconList()                  --设置boss图标列表
        self.bossIconList.onClickItem:Add(self.goToBossPanel,self) 
        self.bossIconList.numItems = #data.boss_icon
    end 
end

function HighGradePackageView:cellGodIcon(index,cell)
    local data = self.godIcon[index+1]
    local icon = cell:GetChild("n0")
    local iconUrl = ResPath.iconRes(tostring(data[1]))
    icon.url = iconUrl
    cell.data = data[2]
    cell.onClick:Add(self.onClickGodIcon,self)

end

function HighGradePackageView:onClickGodIcon(context)
    local modelId = context.sender.data
    GOpenView({id = modelId})
end

--领取
function HighGradePackageView:onClickGet(context)
    local id = context.sender.data

    proxy.ActivityProxy:sendMsg(1030212, {reqType = 1,id = id})

    -- print("领取~~~~~~~~~~~~~",id)
end

--领取BUFF
function HighGradePackageView:getBuff()
    -- body
    proxy.ActivityProxy:sendMsg(1030212, {reqType = 2,id = self.tabC1.selectedIndex+1})
end

--boss图标
function HighGradePackageView:setBossIconList()
    self.bossIconList.itemRenderer = function(index,obj)
        self:bossItemData(index, obj)
    end
    -- self.bossIconList:SetVirtual() --虚表里不可套虚表！！原因麻蛋的

    self.bossIconList.numItems = 0
end
--boss图标
function HighGradePackageView:bossItemData(index, obj)
    local data = self.bossIconConf[index+1]

    local icon = obj:GetChild("n0")
    icon.url = UIPackage.GetItemURL("_icons" , tostring(data)) --Icon

    local lv = obj:GetChild("n9") --BOSS等级
    local lvConf = conf.MonsterConf:getInfoById(self.bossData.bossId[index+1]).level
    lv.text = string.format(language.skybook08, lvConf)

    --用于跳转BOSS页面数据传递 
    --***注意，列表传递数据到Item，不可用self类型数据，必须用局部变量
    local i = index+1
    obj.data = {bossData = self.bossData, index = i}    

    local bossItemC1 = obj:GetController("c1") --是否击杀
    bossItemC1.selectedIndex = 0
    if self.data.bossInfo and self.data.bossInfo[self.curItem] then 
        if self.data.bossInfo[self.curItem]["bossInfo"] then      
            for k,v in pairs(self.data.bossInfo[self.curItem]["bossInfo"]) do
                for i,j in pairs(self.bossData.bossId) do
                    if v.monsterId == j then 
                        if i == index + 1 then 
                            bossItemC1.selectedIndex = 1 --已击杀
                        end 
                    end 
                end
            end         
        end
    end

    if self.bossIsOver == 2 then
        bossItemC1.selectedIndex = 1 --已击杀
    end
end



--跳转BOSS页面
function HighGradePackageView:goToBossPanel(context)
    local cell = context.data.data
    local bossType = cell.bossData.bossType
    local bossIds = cell.bossData.bossId
    local index = cell.index 
 
    -- printt(cell)
    -- print("跳转到BOSS页面~~~~~~~~~~~~~~~~~~~~~~~",bossType)

    local bossPanelIndex 
    if bossType == 1 then --世界BOSS
        bossPanelIndex = 1049

    elseif bossType == 2 then --BOSS之家
        bossPanelIndex = 1128

    elseif bossType == 3 then --咸鱼禁地
        bossPanelIndex = 1135
    end 
    

    local param = {id = bossPanelIndex, childIndex = bossIds[index]} 

    -- print("BOSS id", bossIds[index])

    GOpenView(param)
end

--Tab页签控制
function HighGradePackageView:onControlChange()
    -- body
    self:setBuffProgress()

    proxy.ActivityProxy:sendMsg(1030212, {reqType = 0}) --重新获取列表信息

    self.awardConfData = conf.ActivityConf:getHighGradePackgeAwardConf(self.tabC1.selectedIndex + 1)
    
    self.getList.numItems = #self.awardConfData

end

function HighGradePackageView:setBuffProgress()
    -- body
    self.curBuffProgress = 0
 
    local min = (self.tabC1.selectedIndex + 1) * 10000
    local max = (self.tabC1.selectedIndex + 2) * 10000

    if self.data.got then 
        local gotSize = #self.data.got
        if gotSize ~= 0 then 
            for k,v in pairs(self.data.got) do   --获取进度
                if min <= v and v < max then 
                    self.curBuffProgress = self.curBuffProgress + 1
                end
            end
        end 
    end 
    local floor = conf.ActivityConf:getHighGradePackgeFloor(self.tabC1.selectedIndex+1)
    self.buffGetDesc.text = language.skybook09[self.tabC1.selectedIndex+1]
    self.buffProgressDesc.text = string.format(language.skybook10, 
            language.skybook11[self.tabC1.selectedIndex+1],
            self.curBuffProgress,floor)

    --BUFF按钮状态
    local curBuffPanel = 99
    for k,v in pairs(self.data.buffs) do
        if v == self.tabC1.selectedIndex + 1 then  --判断是否已领取
             curBuffPanel = v   
        end
    end
 
    --BUFF可领取状态
    if curBuffPanel ~= 99 and self.curBuffProgress == floor then  --已领取
        self.buffC2.selectedIndex = 2
    elseif self.curBuffProgress == floor then  --可领取
        self.buffC2.selectedIndex = 0

        cache.PlayerCache:setRedpoint(30124, 1)
        if cache.PlayerCache:getRedPointById(30124) ~= 0 then 
            local mainview = mgr.ViewMgr:get(ViewName.MainView)
            if mainview then
                mainview:refreshRedTop()
            end 
        end 
    else    --未达成
        self.buffC2.selectedIndex = 1
    end 
end

--消息返回
function HighGradePackageView:setData(data) 
    -- printt("天书",data)
    -- for k,v in pairs(data.otherInfo) do
    --     print(k,v)
    -- end
    -- printt(data.bossInfo)

    self.data = data
    --已领取的列表
    if self.data.got then 
        self.got = {}
        for k,v in pairs(self.data.got) do
            self.got[v] = true
        end
    end 
    --奖励配置
    self.awardConfData = conf.ActivityConf:getHighGradePackgeAwardConf(self.tabC1.selectedIndex + 1)
    --列表排序
    self:setSort()
    --层级开启
    self:setJumpTab()
    --设置页签
    self:setTabBtnShow()
    --BUFF进度
    self:setBuffProgress()
    --设置红点
    -- self:setGetRedPoint(self.tabC1.selectedIndex)

    self:setTabBtnRedPoint()
    
    --当前攻击力
    self.curPower = data.atk 

    self.getList.numItems = #self.awardConfData
    
    mgr.TimerMgr:addTimer(0.2,1,function()
        -- body
        self:addGuiide()
    end) 
end

--设置跳转页面
function HighGradePackageView:setJumpTab()
    local buffsSize = #self.data.buffs
    if buffsSize ~= 0 then 
        for _,v in pairs(self.data.buffs) do
            if v < 3 then 
                -- print("设置不可见",v)
                if self.layerList[v].visible then
                 
                    self.view:GetChild("n"..(v+2)):GetChild("n4").visible = false --原层级红点熄灭
                    self.layerList[v].visible = false --下一层级开启
                    -- self:setGetRedPoint(v)            --设置下一层级红点
                    self.awardConfData = conf.ActivityConf:getHighGradePackgeAwardConf(v + 1) --法克鱿
                    self.tabC1.selectedIndex = v      --自动选中下一层级
                end
            end 
        end
    end 
    --根据等级开启
    local roleLv = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(self.openLvLayerList) do
        if roleLv >= v.data then
            v.visible = false
        else
            v.visible = true
        end
    end

    -- --测试用：解锁全部层级
    -- for k,v in pairs(self.layerList) do
    --     v.visible = false
    -- end
end

local TabBtnIcon = {
    [1] = "tianshuxunzhu_007",--地
    [2] = "tianshuxunzhu_008",--天
    [3] = "tianshuxunzhu_009",--仙
    [4] = "tianshuxunzhu_024",--神
}

--设置左侧页签按钮的显示
function HighGradePackageView:setTabBtnShow()
    local roleLv = cache.PlayerCache:getRoleLevel()
    --已领取的buff个数
    local gotBuffLen = #self.data.buffs
    local gotBuffList = {}
    for k,v in pairs(self.data.buffs) do
        gotBuffList[v] = 1 
    end
    --这个列表里不包含第一个按钮
    for k,v in pairs(self.btnList) do
        local confBuffData = conf.ActivityConf:getHighGradePackgeBuffConf(k+1)
        -- if roleLv < confBuffData.open_lv then
        --     -- v.icon = UIPackage.GetItemURL("highgradepackage","tianshuxunzhu_025")--“？？？？？”问号资源
        -- else
            if confBuffData.open_type == 1 then--根据上一册开启的
                if gotBuffList[k]  and gotBuffList[k] == 1 then
                    self.btnList[k].icon = UIPackage.GetItemURL("highgradepackage",TabBtnIcon[k])
                else
                    self.btnList[k].icon = UIPackage.GetItemURL("highgradepackage","tianshuxunzhu_025")--“？？？？？”问号资源
                end
            else
                self.btnList[k].icon = UIPackage.GetItemURL("highgradepackage",TabBtnIcon[k])
            end
        -- end
    end
end

-- --设置红点
-- function HighGradePackageView:setGetRedPoint(value) 
--     -- print(self.tabC1.selectedIndex+1,"OOOOOOOOOOOOOOOOOOOO")
--     local getRedPoint = self.view:GetChild("n"..(value+3)):GetChild("n4")

--     local isShowRedPoint = true
--     for k,v in pairs(self.data.buffs) do
--         if v == self.tabC1.selectedIndex + 1 then  --判断是否已领取,已领取的层级不显示红点
--              isShowRedPoint = false  
--         end
--     end

--     local curRedPointValue = cache.PlayerCache:getRedPointById(30124)
--     local curBuffRedPointValue = cache.PlayerCache:getRedPointById(30126)
--     if (curRedPointValue > 0 or curBuffRedPointValue > 0) and isShowRedPoint then
--         getRedPoint.visible = true
--     else
--         getRedPoint.visible = false
--     end 
-- end

function HighGradePackageView:setTabBtnRedPoint()
    --包含第一个按钮
    local allLeftBtnList = {}
    for i=1,5 do
        local btn = self.view:GetChild("n"..(2+i))
        table.insert(allLeftBtnList, btn)
    end
    self.myGot = {}
    for k,v in pairs(self.data.got) do
        self.myGot[v] = 1
    end

     --已领取的buff列表
    local gotBuff = {}
    for k,v in pairs(self.data.buffs) do
        gotBuff[v] = 1
    end
    local roleLv = cache.PlayerCache:getRoleLevel()

    for k,v in pairs(allLeftBtnList) do
        local redImg = v:GetChild("n4")
        redImg.visible = false
        local confBuffData = conf.ActivityConf:getHighGradePackgeBuffConf(k)
        if v.icon == UIPackage.GetItemURL("highgradepackage","tianshuxunzhu_025") or roleLv < confBuffData.open_lv  then
            redImg.visible = false
        else
            for i,j in pairs(self.data.otherInfo) do
                if not self.myGot[i]  then--i这个id，还没有领取过
                    local floor = math.floor(i/10000)
                    if floor == k then--第k层有没有领取的奖励
                        allLeftBtnList[floor]:GetChild("n4").visible = true
                    end
                end
            end
        end
        --本层最大进度
        local floorProgress = conf.ActivityConf:getHighGradePackgeFloor(k)
        --本层当前进度
        local curProgress = self:getCurFloorProgress(k)
        -- print(curProgress,floorProgress,gotBuff[k],k)
        if curProgress == floorProgress and not gotBuff[k] then
            allLeftBtnList[k]:GetChild("n4").visible = true
        end
    end

end

function HighGradePackageView:getCurFloorProgress(floor)
    local data = {}
    for k,v in pairs(self.data.otherInfo) do
        if floor == math.floor(k/10000) then
            table.insert(data,k)
        end
    end
    return #data
end


--排序
function HighGradePackageView:setSort()
    for k,v in pairs(self.awardConfData) do
        if self.tabC1.selectedIndex ~= 2 then --排序(1,2,4)                    
            if self.got[v.id] then   --已领取
                self.awardConfData[k].sign = 2

            elseif self.data.otherInfo[v.id] 
                and self.data.otherInfo[v.id] < 0 
                and not self.got[v.id] then  --领取

               self.awardConfData[k].sign = 0  

            else  --未达成
                self.awardConfData[k].sign = 1
            end

        else --排序(3)  
            --Boss击杀进度        
            local isFinish = false
            if self.data and self.data.bossInfo[v.id] then 

                -- local killSum = #self.data.bossInfo[v.id]["bossInfo"] --已击杀数
                local needKillSum = #v.monsters           --需要击杀数
                -- if killSum >= needKillSum then 
                --     isFinish = true
                -- else 
                --     isFinish = false
                -- end

                local tempVal = 0
                for h,w in pairs(v.monsters) do            
                    for i,j in pairs(self.data.bossInfo[v.id]["bossInfo"]) do
                        if w == j.monsterId then 
                            tempVal = tempVal + 1
                        end 
                    end
                end  

                if tempVal == needKillSum then 
                    isFinish = true
                else
                    isFinish = false
                end 
            end 

            if self.got[v.id] then   --已领取
                self.awardConfData[k].sign = 2   

            elseif isFinish and not self.got[v.id] then  --领取
                self.awardConfData[k].sign = 0
               
            else  --未达成
                self.awardConfData[k].sign = 1

            end
        end
    end
    
    table.sort(self.awardConfData,function(a,b)

            if a.hierarchy ~= b.hierarchy then 
                return a.hierarchy < b.hierarchy
            elseif a.sign ~= b.sign then
                return a.sign < b.sign
            elseif a.id ~= b.id then
                return a.id < b.id
            end
    end)
end

--铜钱数量用万显示
function HighGradePackageView:setMoneyAmount(Amount)
    if Amount > 9999 then 
        local temp = math.floor(Amount/10000) .. language.skybook04
        return temp
    end
    return Amount
end

--禁止跳转
function HighGradePackageView:onForbid()
    -- body
    GComAlter(language.skybook12)
end

function HighGradePackageView:checkOpen(context)
    local data = context.sender.data
    local roleLv = cache.PlayerCache:getRoleLevel()
    if roleLv < data then
        GComAlter(string.format(language.skybook13,data))
    end
end

function HighGradePackageView:onCloseView()
    -- body
    self:closeView()
end

return HighGradePackageView