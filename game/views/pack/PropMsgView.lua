local PropMsgView = class("PropMsgView", base.BaseView)

local notNumItems = {221051011,221051008,221051009,221071001,221071002,221071003,2210710014,221071005,221071006,221071007,221071008,221071009,221071010,221071011,221071012,221071013,221071014,221071015,221071016,221071017,221071018,221061001,221061002,221011031,221011032}--不显示拥有的道具
--道具弹窗
function PropMsgView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3           --窗口层级
    self.isBlack = true
end

function PropMsgView:initData()
    -- body
    self.model = nil 
    self.awardPanel.visible = false
    self.showAwardBtn.visible = false

end

function PropMsgView:initView()
    self.useBtn = self.view:GetChild("n2")
    self.useBtn.onClick:Add(self.onClickUse,self)
    self.useText = self.useBtn:GetChild("title")
    self.useText.visible = true
    self.discardBtn = self.view:GetChild("n3")
    self.discardBtn.onClick:Add(self.onClickDiscard,self)
    self.discardText = self.discardBtn:GetChild("title")
    self.discardText.visible = true
    self.useAllBtn = self.view:GetChild("n24")
    self.useAllBtn.visible = true
    self.useAllBtn.onClick:Add(self.onClickUseAll,self)
    self.blackView.onClick:Add(self.onClickClose,self)
    self.listView = self.view:GetChild("n22")
    if g_ios_test then   --EVE 屏蔽物品获得途径
        self.listView.visible = false
    end 
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.controller1 = self.view:GetController("c1")
    self.timeText = self.view:GetChild("n23")
    self.frame1 = self.view:GetChild("n18")
    self.frame2 = self.view:GetChild("n17")
    self.selectAttiBtn = self.view:GetChild("n26")
    self.selectAttiBtn.onClick:Add(self.onClickGoAtti,self)
    self.selectSuitBtn = self.view:GetChild("n27")
    self.selectSuitBtn.onClick:Add(self.onClickGoSuit,self)

    self.normal = self.view:GetChild("n25") 
    self.btnlist = self.view:GetChild("n17")  
    --策划要求加的模型显示界面 yb
    self._modelpanel = self.view:GetChild("n28")

    self._btnLeft = self._modelpanel:GetChild("n6")
    self._btnLeft.data = -1 
    self._btnLeft.visible = false
    self._btnLeft.onClick:Add(self.onChange,self)
    self._btnRight = self._modelpanel:GetChild("n5")
    self._btnRight.data = 1
    self._btnRight.visible = false
    self._btnRight.onClick:Add(self.onChange,self)
    --源计划宝箱特殊显示bxp
    self.showAwardBtn = self.view:GetChild("n29")
    self.showAwardBtn.onClick:Add(self.showAward,self)
    self.showAwardBtn.visible = false
    self.awardPanel = self.view:GetChild("n33")--奖励组件
    self.awardPanel.visible = false
    self.awardList = self.view:GetChild("n32")
    self.awardList:SetVirtual()
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.awardList.numItems = 0

end

function PropMsgView:setBtnVisible(visible)
    self.frame1.visible = visible
    self.frame2.visible = visible
    self.useBtn.visible = visible
    self.discardBtn.visible = visible
end
--设置右面版的大小（只有使用和丢弃）
function PropMsgView:initPointSize()
    self.useBtn.y = self.frame1.y + 6
    self.discardBtn.y = self.frame1.y + 46
    self.frame1.height = 92
    self.frame2.height = 111
end
--三个按钮都有的时候
function PropMsgView:initPointSize2()
    self.useAllBtn.title = language.pack39
    self.useAllBtn.visible = true
    self.useAllBtn.y = self.frame1.y + 6
    self.useBtn.y = self.frame1.y + 46
    self.discardBtn.y = self.frame1.y + 86
    self.frame1.height = 133
    self.frame2.height = 154
end
--没有丢弃的情况（只有批量使用和使用的时候）
function PropMsgView:initPointSize3()
    self.useAllBtn.title = language.pack39
    self.useAllBtn.visible = true
    self.useAllBtn.y = self.frame1.y + 6
    self.useBtn.y = self.frame1.y + 46
    self.frame1.height = 92
    self.frame2.height = 111
end
--只有使用的时候
function PropMsgView:initPointSize4()
    self.discardBtn.visible = false
    self.frame1.height = 52
    self.frame2.height = 72
end

--圣装碎片处理(只有一个上架)
function PropMsgView:initPointSize5()
    -- self.useAllBtn:RemoveEventListeners()
    -- self.useBtn:RemoveEventListeners()
    self.useAllBtn.y = self.frame1.y + 6
    self.useBtn.y = self.frame1.y + 46
    -- self.useAllBtn.onClick:Add(self.onShangJia,self)
    -- self.useBtn.onClick:Add(self.onHeChen,self)

    self.useAllBtn.title = language.shengzhuang02[2]
    self.useAllBtn.visible = true
    self.useBtn.visible = true
    self.useBtn.title = language.shengzhuang02[6]

    self.frame1.visible = true
    self.frame2.visible = true
    self.frame1.height = 92
    self.frame2.height = 111
end

function PropMsgView:initRight(id)
    -- body
    --宠物模型
    if not id then
        return
    end
    self.petId = id
    local condata = conf.PetConf:getPetItem(self.petId)
    if not condata or not condata.model then
        return
    end
    local _panel = self._modelpanel:GetChild("n4")
    if not self.model then
        self.model = self:addModel(condata.model,_panel)
    else
        self.model:setSkins(condata.model)
    end
    self.model:setScale(SkinsScale[Skins.newpet])
    self.model:setRotationXYZ(0,151.5,0)
    self.model:setPosition(0,-238.3,200)

    if mgr.PetMgr:getPetByCondition(1,self.petId) then
        self._btnRight.visible = true
    else
        self._btnRight.visible = false
    end

    if  mgr.PetMgr:getPetByCondition(-1,self.petId) then
        self._btnLeft.visible = true
    else
        self._btnLeft.visible = false
    end

    local name =  self._modelpanel:GetChild("n7") 
    name.text = mgr.TextMgr:getQualityStr1(condata.name, condata.color)
end

function PropMsgView:onChange(context)
    -- body
    if not self.mData then
        return
    end
    context:StopPropagation()
    local index = context.sender.data
    local condata = mgr.PetMgr:getPetByCondition(index,self.petId) 
    if condata then
        self:initRight(condata.id)
    end
end

function PropMsgView:setData(data,isSclect)
    self.mData = data
    local mId = self.mData.mid
    --如果有开箱奖励(源计划宝箱)
    if next(conf.ItemConf:getOpenAward(mId))~= nil then 
        self.showAwardBtn.visible = true
        self.showAwardBtn.data = {mId = mId}
        self.awardPanel.visible = true
        self.awardData = conf.ItemConf:getOpenAward(mId)
        self.awardList.numItems = #self.awardData
    end
    --如果是宠物蛋要做其他处理
    self.normal:Center()
    local condata = conf.ItemConf:getItem(data.mid)
    if condata and condata.petindex then
        self._modelpanel.visible = true
        self.normal.x = self.normal.x - self._modelpanel.width / 2
        self.btnlist.x = self._modelpanel.x +  self._modelpanel.width
        self.petId = condata.petindex
        self:initRight(condata.petindex)
    else
        self._modelpanel.visible = false

        local pp = self.view:GetChild('n15')
        self.btnlist.x = pp.x +  pp.width
    end

    local proObj = self.view:GetChild('n14')
    local _t = clone(data)
    _t.isdone = cache.PlayerCache:getIsNeed(_t.mid)
    GSetItemData(proObj,_t,false)
    local proName = self.view:GetChild("n9")
    local color = conf.ItemConf:getQuality(mId)
    local name = conf.ItemConf:getName(mId)--道具名称
    proName.text = mgr.TextMgr:getQualityStr1(name,color)
    local typeDec = self.view:GetChild("n10")
    typeDec.text = conf.ItemConf:getTypedec(mId)--类型描述
    local describe = self.view:GetChild("n6"):GetChild("n6")

    --EVE 经验丹增加经验显示
    local isShowEXP = conf.ItemConf:getItemEXPDisplay(mId) --用于判断是否经验丹
    if not isShowEXP then
        --原来的道具说明
        describe.text = conf.ItemConf:getDescribe(mId)--道具说明

    else
        --新增需要显示经验的道具说明
        local itemValue = conf.ItemConf:getItemValueOfEXP(mId) --用于计算当前道具应加经验
        local curLv = cache.PlayerCache:getRoleLevel()         --当前等级，用于计算经验
        local strDesc = conf.ItemConf:getDescribe(mId)

        local curEXPValue = itemValue.arg1*curLv + itemValue.arg2
        -- print(curEXPValue)
        describe.text = strDesc .. mgr.TextMgr:getTextColorStr(GTransFormNumEXP(curEXPValue),7)
    end

    local countDesc = self.view:GetChild("n11")
    local countNum = self.view:GetChild("n12")
    local index = self.mData.index or 0
    local divisor = 100000
    local cameo = self.mData.cameo
    --查看属性按钮
    local attiModule = conf.ItemConf:getAttiModule(mId)
    if attiModule then
        self.selectAttiBtn.data = attiModule
        self.selectAttiBtn.visible = true
    else
        self.selectAttiBtn.visible = false
    end
    --套装属性按钮
    local suitMod = conf.ItemConf:getSuitModule(mId)
    if suitMod then
        self.selectSuitBtn.data = suitMod
        self.selectSuitBtn.visible = true
    else
        self.selectSuitBtn.visible = false
    end
    self.controller1.selectedIndex = 0
    for k,v in pairs(notNumItems) do
        if mId == v then
            self.controller1.selectedIndex = 1
            break
        end
    end
    self:initPointSize()
    local amount = 0
    if mgr.ItemMgr:isPackItem(index) then--如果index是背包点击的
        amount = data.amount or 0
    else
        amount = cache.PackCache:getLinkCost(mId)
    end
    countNum.text = GTransFormNum(amount)--道具数量
    if mId == 221051008 then
        countDesc.text = ""
        countNum.text = ""
    end
    if cameo then--宝石
        self:setGemData()
        self:setFormview()
        return
    end
    self.useAllBtn.visible = false
    local iType = conf.ItemConf:getType(mId)
    --如果是家园种种子
    local subType = conf.ItemConf:getSubType(mId)
    -- if iType == Pack.prosType and subType and subType == 13 then
    --     if mgr.ViewMgr:get(ViewName.HomePlantingChoose) then
    --         self.useBtn.visible = true
    --         self.useBtn.title = language.home127
    --         self:initPointSize4()
    --     else
    --         self.discardBtn.visible = false
    --         self.useBtn.visible = false
    --     end
    --     return
    -- end
    
    if mgr.ItemMgr:isLimitItem(index) then--临时背包
        self.useText.text = language.pack25
        self:initPointSize4()
    else
        local isNotDiscard = conf.ItemConf:getIsNotDiscard(mId)
        if mgr.ItemMgr:getPackIndex() == Pack.wareIndex then --仓库
            if mgr.ItemMgr:isPackItem(index) then
                self.useText.text = language.pack06
            else
                self.useText.text = language.pack07
            end
            self:judeBtn(index)
            if mgr.ItemMgr:isPackItem(index) then
                if isNotDiscard == 1 then--如果是配了不能丢弃
                    self.discardBtn.visible = false
                    self:initPointSize4()
                else
                    self.discardBtn.visible = true
                end
            else
                self.discardBtn.visible = false
                self:initPointSize4()
            end
            self:judeTimeProp(iType)
            self.useBtn.enabled = true
        else
            self:judeBtn(index)
            if (iType == Pack.prosType or iType == Pack.gemType) and mgr.ItemMgr:isPackItem(index) then--道具
                if subType and subType == 13 then
                    if mgr.ViewMgr:get(ViewName.HomePlantingChoose) then
                        self.useBtn.visible = true
                        self.useBtn.title = language.home127
                        self.useText.text = language.home127
                    else
                        self:setBtnVisible(false)
                    end
                else
                    self.useText.text = language.pack03
                end

                
                self.discardText.text = language.pack04
                local useAll = conf.ItemConf:getIsUseAll(mId)
                if useAll and useAll >= 1 then
                    if isNotDiscard == 1 then
                        self:initPointSize3()
                    else
                        self:initPointSize2()
                    end
                else
                    if isNotDiscard == 1 then
                        self:initPointSize4()
                    else
                        self:initPointSize()
                    end
                end
                if isNotDiscard == 1 then
                    self.discardBtn.visible = false
                else
                    self.discardBtn.visible = true
                end
            end
            self:judeTimeProp(iType)
        end
    end
     --圣装碎片
    if conf.ItemConf:getType(mId) == Pack.equipawkenType and conf.ItemConf:getSubType(mId) == 2 then--2:碎片
        if mgr.ViewMgr:get(ViewName.AwakenView) then
            self:initPointSize5()
        else
            self:setBtnVisible(false)
        end
    end
    self:setFormview()
    if isSclect or g_ios_test then
        self.useAllBtn.visible = false
        self:setBtnVisible(false)
    end
end

function PropMsgView:showAward(context)
    local btn = context.sender 
    local mId = btn.data.mId
    local flag = self.awardPanel.visible == false and true or false
    self.awardPanel.visible = flag
    self.awardData = conf.ItemConf:getOpenAward(mId)
    self.awardList.numItems = #self.awardData
end
function PropMsgView:cellAwardData(index,obj)
    local data = self.awardData[index+1]
    if data then 
        local mId = data[1]
        local amount = data[2]
        local bind = data[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end

function PropMsgView:setFormview()
    self.formview = conf.ItemConf:getFormview(self.mData.mid)--跳转路径
    self.listView.numItems = 0
    if self.formview then
        local len = #self.formview
        self.listView.numItems = len
        if len > 0 then
            self.listView:ScrollToView(0)
        end
    end
end

function PropMsgView:setGemData()
    self.timeText.visible = false
    self:setBtnVisible(true)
    self.useText.text = language.pack08
    self.discardText.text = language.pack09
    self.useBtn.visible = false
    self.discardBtn.visible = false
    self.useAllBtn.visible = false
    local iType = self.mData.holeUpType
    if iType == 1 then--只可卸下
        self.useBtn.visible = true
        self.useBtn.title = language.pack38
        self.discardBtn.visible = true
        self.discardBtn.title = language.pack09
    elseif iType == 2 then--升级+卸下
        self.useBtn.visible = true
        self.useBtn.title = language.pack38
        self.discardBtn.visible = true
        self.discardBtn.title = language.pack09
    elseif iType == 3 then--替换+卸下
        self.useBtn.visible = true
        self.useBtn.title = language.pack37
        self.discardBtn.visible = true
        self.discardBtn.title = language.pack09
    elseif iType == 4 then--替换+升级+卸下 
        self.useAllBtn.visible = true
        self.useAllBtn.title = language.pack37
        self.useBtn.visible = true
        self.useBtn.title = language.pack38
        self.discardBtn.visible = true
        self.discardBtn.title = language.pack09
    end
end

function PropMsgView:judeBtn(index)
    if index <= 0 or not index or mgr.ItemMgr:getPackIndex() <= 0 then
        self:setBtnVisible(false)
    else
        self:setBtnVisible(true)
    end
end
--判断是否是时效道具
function PropMsgView:judeTimeProp(iType)
    self.timeText.visible = false
    self.useBtn.enabled = true
    if iType == Pack.prosType then
        self.propTime = self.mData.propMap and self.mData.propMap[attConst.packAging]
        local limitTime = conf.ItemConf:getlimitTime(self.mData.mid) or 0
        if self.propTime and limitTime > 0 then
            if mgr.NetMgr:getServerTime() < limitTime + self.propTime then
                if not self.propTimer then
                    self.timeText.visible = true
                    self:onTimer()
                    self.propTimer = self:addTimer(1, -1, handler(self, self.onTimer))
                end
            else
                self.useBtn.enabled = false
            end
        end
    end
end

function PropMsgView:releaseTimer()
    if self.propTimer then
        self:removeTimer(self.propTimer)
        self.propTimer = nil
    end
end

function PropMsgView:onTimer()
    local time = mgr.NetMgr:getServerTime() - self.propTime
    local limitTime = conf.ItemConf:getlimitTime(self.mData.mid) or 0
    if time >= limitTime then
        self.useBtn.enabled = false
        self:releaseTimer()
        return
    end
    local dec1 = mgr.TextMgr:getTextColorStr(language.pack24, 9)
    local dec2 = mgr.TextMgr:getTextColorStr(GTotimeString(limitTime - time), 14)
    self.timeText.text = dec1..dec2
end

function PropMsgView:cellData(index, obj)
    local moduleData = self.formview[index + 1]
    local id = moduleData and moduleData[1]
    local childIndex = moduleData and moduleData[2]
    local goBtnVisible = moduleData and moduleData[3]
    local data = conf.SysConf:getModuleById(id)
    local lab = obj:GetChild("n1")
    lab.text = data.desc or ""
    local btn = obj:GetChild("n0")
    if g_ios_test then
        btn.visible = false
    else
        btn.visible = true
    end
    if not goBtnVisible or (goBtnVisible and goBtnVisible == 0) then
        btn.visible = true
    else
        btn.visible = false
    end
    btn.data = {id = id,childIndex = childIndex}
    btn.onClick:Add(self.onBtnGo,self)
end

function PropMsgView:onClickUse()
    local mId = self.mData.mid
    local index = self.mData.index or 0
    local cameo = self.mData.cameo
    if cameo then--宝石
        local iType = self.mData.holeUpType
        if iType then
            if iType == 1 then--只可卸下
                self:upCameo()
            elseif iType == 2 then--升级+卸下
                self:upCameo()
            elseif iType == 3 then--替换+卸下
                self:replaceCameo()
            elseif iType == 4 then--替换+升级+卸下 
                self:replaceCameo()
            end
        else
            GOpenView({id = 1033})
        end
        return
    end
    local iType = conf.ItemConf:getType(mId)
    if mgr.ItemMgr:isLimitItem(index) then--临时背包
        proxy.PackProxy:send(1040501,{indexs = {self.mData.index}})
    else
        if mgr.ItemMgr:getPackIndex() == Pack.wareIndex then --仓库
            proxy.PackProxy:sendWareTake(self.mData)
        else
            -- print("iType",iType)
            if iType == Pack.equipType then--装备
            
            elseif iType == Pack.equipawkenType then--剑神
                self:onHeChen()
            elseif iType == Pack.prosType or iType == Pack.gemType then--道具
                --检测使用的道具是否是花
                local t = conf.MarryConf:getValue("flower_list")
                for k ,v in pairs(t) do
                    if v[1] == mId then
                        local param = {}
                        param.id = 1097
                        param.data = mId
                        GOpenView(param)
                        return
                    end
                end

                local tabType = conf.ItemConf:getTabType(mId)
                local argsType = conf.ItemConf:getArgsType(mId)
                local subType = conf.ItemConf:getSubType(mId)

                if tabType == 1 then
                    if argsType and argsType == Pros.chest then
                        mgr.ViewMgr:openView2(ViewName.PackChooseView, self.mData)
                        self:closeView()
                        return
                    elseif subType == Pros.neidanPros then--内丹
                        mgr.ViewMgr:openView2(ViewName.Alert18,self.mData)
                        self:closeView()
                        return
                    elseif argsType and argsType == Pros.promote then--升阶丹
                        local modelId = conf.ItemConf:getArgsType2(mId)
                        local arg3 = conf.ItemConf:getItemArg3(mId)
                        local jie = cache.PlayerCache:getDataJie(modelId)
                        if jie >= arg3 then
                            local params = {
                                index = index,--背包的位置
                                amount = 1,--使用数量
                                ext_arg = 0,
                            }
                            proxy.PackProxy:sendUsePro(params)
                        else
                            GComAlter(string.format(language.gonggong125,arg3))
                        end
                    else
                        local params = {
                            index = index,--背包的位置
                            amount = 1,--使用数量
                            ext_arg = 0,
                        }
                        proxy.PackProxy:sendUsePro(params)
                    end
                elseif tabType == 2 then--不能使用并且没有模块界面获得的道具
                    if subType == 13 then --家园种子
                        local view = mgr.ViewMgr:get(ViewName.HomePlantingChoose)
                        if view then
                            view:onPlant()
                        end
                        self:closeView()
                        return
                    end
                    GComAlter(string.format(language.pack20, conf.ItemConf:getName(mId)))
                else

                    if subType == Pros.bossRefreshCard then --BOSS刷新令
                        -- print("这是一张BOSS刷新令！",curSceneId,"当前刷新令道具ID:",mId)
                        local isOkScene = self:isCorrespondingScene(mId)                                     
                        if isOkScene then            --对应副本场景                      
                            mgr.ViewMgr:openView(ViewName.BossRefreshCard,function()
                                proxy.FubenProxy:send(1330701, {reqType=0, packIndex=index, monsterId=0})
                            end, {packIndex=index, targetRoleId=mId})

                        else                --非对应的副本场景，需要跳转到对应的BOSS入口 
                            GComAlter(language.fuben215)
                        end

                        self:closeView()
                        return
                    else
                        if cache.PackCache:checkisGao7(mId) then
                            local flag,module_id = cache.PackCache:checkIs7(mId)
                            if not flag and module_id then
                                return GComAlter( string.format(language.gonggong95,language.gonggong94[module_id]) )
                            end
                        end
                        if cache.PackCache:checkisGao10(mId) then
                            local flag,module_id = cache.PackCache:checkIs10(mId)
                            if not flag and module_id then
                                return GComAlter( string.format(language.gonggong95_1,language.gonggong94[module_id]) )
                            end
                        end
                        if tabType then
                            GOpenView({id = tabType[1],childIndex = tabType[2]})
                        end
                        return
                    end 
                end
            elseif conf.ItemConf:getType(mId) == Pack.gemType then--宝石

            end
        end
    end
    self:onClickClose()
end
--BOSS刷新卡，判断当前是否在对应场景中
function PropMsgView:isCorrespondingScene(cardId)
    -- body
    local curSceneId = cache.PlayerCache:getSId()           --当前场景
    local needSceneConf = conf.ItemConf:getArgsItem(cardId)        --道具配表配置的可用场景
    
    -- printt(needSceneConf[1])
    for k,v in pairs(needSceneConf[1]) do
        local allSceneId = conf.SceneConf:getAllScenesIdByKind(v)   --所有场景id
        for k,v in pairs(allSceneId) do
            -- print("配置场景：",v,"当前：",curSceneId)
            if v == curSceneId then     --在对应场景中时 
                return true 
            end 
        end
    end
    return false     --找不到对应场景
end
--批量使用
function PropMsgView:onClickUseAll()
    local cameo = self.mData.cameo
    local mId = self.mData.mid
    local iType = conf.ItemConf:getType(mId)

    if cameo then--宝石
        self:replaceCameo()
        return
    end
    if iType == Pack.equipawkenType then--剑神上架
        self:onShangJia()
        return
    end
    local params = {
        index = self.mData.index,--背包的位置
        amount = self.mData.amount,--使用数量
        ext_arg = 0,
    }
    proxy.PackProxy:sendUsePro(params)
    self:onClickClose()
end

function PropMsgView:onClickDiscard()
    local cameo = self.mData.cameo
    if cameo then--宝石
        local iType = self.mData.holeUpType
        if iType then
            if iType == 1 then
                self:unloadCameo()
            elseif iType == 2 then--升级+卸下
                self:unloadCameo()
            elseif iType == 3 then--替换+卸下
                self:unloadCameo()
            elseif iType == 4 then--替换+升级+卸下 
                self:upCameo()
            end
        end
        -- proxy.ForgingProxy:send(1100104,{reqType = 2,part = self.mData.part,hole = self.mData.hole,itemId = 0})
        -- self:onClickClose()
    else
        local function func()
            self:onClickClose()
        end
        mgr.ItemMgr:delete(self.mData.index,func)
    end
end

function PropMsgView:onBtnGo(context)
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end

function PropMsgView:onClickGoAtti(context)
    local data = context.sender.data
    if data[2] and data[2] == 999 then
        --一些不需要childIndex
        data[2] = nil 
    end
    local param = {id = data[1],childIndex = data[2],grandson = data[3]}
    GOpenView(param)
end

function PropMsgView:onClickGoSuit(context)
    local data = context.sender.data
    local param = {id = data[1],childIndex = data[2],grandson = data[3]}
    GOpenView(param)
end

--替换宝石
function PropMsgView:replaceCameo()
    local camoList = {}
    for k,v in pairs(self.mData.camoList) do
        if v.mid > self.mData.itemId then
            table.insert(camoList, v)
        end
    end
    table.sort(camoList,function(a,b)
        return a.mid > b.mid
    end)
    local cameoData = {pos = self.mData.pos, part = self.mData.part,camoList = camoList,hole = self.mData.hole}
    self:onClickClose()
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setData(4,cameoData)
    end)
end
--升级宝石
function PropMsgView:upCameo()
    local itemId = self.mData.itemId
    local itemLv = conf.ItemConf:getLvl(itemId)
    if itemLv >= GemMaxLv then
        GComAlter(language.forging47)
        self:onClickClose()
        return
    end
    local sendMsg = function()
        proxy.ForgingProxy:send(1100104,{reqType = 3,part = self.mData.part,hole = self.mData.hole,itemId = itemId})
        self:onClickClose()
    end
    if self.mData.holeUpType == 1 then
        local buyPrice = conf.ItemConf:getBuyPrice(itemId)
        local lvl = conf.ItemConf:getLvl(itemId)
        local strTab = clone(language.forging45)
        strTab[2].text = string.format(strTab[2].text, buyPrice)
        strTab[3].text = string.format(strTab[3].text, lvl, lvl + 1)
        local param = {type = 2,richtext = mgr.TextMgr:getTextByTable(strTab),sure = function()
            sendMsg()
        end}
        GComAlter(param)
    else
        sendMsg()
    end
end
--卸下宝石
function PropMsgView:unloadCameo()
    proxy.ForgingProxy:send(1100104,{reqType = 2,part = self.mData.part,hole = self.mData.hole,itemId = 0})
    self:onClickClose()
end

function PropMsgView:onClickClose()
    self.mData = nil
    self:releaseTimer()
    self:setBtnVisible(true)
    self:closeView()
end

function PropMsgView:onShangJia(context)
    mgr.ViewMgr:openView(ViewName.MarketMainView,function(view)      
    end,{index = 1})
    self:closeView()
end

function PropMsgView:onHeChen(context)
    local data = {}
    data.index = 1033
    mgr.ViewMgr:openView2(ViewName.ForgingView,data)
    local view = mgr.ViewMgr:get(ViewName.AwakenView)
    if view then
        view:closeView()
    end
    self:closeView()
end

return PropMsgView