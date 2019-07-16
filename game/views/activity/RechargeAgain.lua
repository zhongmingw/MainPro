--
-- Author: EVE
-- Date: 2017-04-11 17:21:33
--

local RechargeAgain = class("RechargeAgain", base.BaseView)

function RechargeAgain:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale

    -- --按钮: 状态转换表
     self.btnState = {0, 0, 0}
    self.effectList = nil
    self.modelList = nil
end

function RechargeAgain:initData(data)
    -- body
    self.confData = {}
    self.icon1.url = nil 
    self.icon2.url = nil 
    self:initBtn()

    -- self:onController()
    -- if GIsCharged() then
        for i=1,6 do
            if i == 4 or i == 5 or i == 6 then 
                self.view:GetChild("btn"..i).scaleX = 0
                self.view:GetChild("btn"..i).scaleY = 0
            else
                self.view:GetChild("btn"..i).visible = true
            end 
        end
        self.index = data.index or 0
    -- else
    --     for i=4,6 do
    --         self.view:GetChild("btn"..i).visible = false
    --     end
    --     if data.index > 2 then
    --         self.index = 0
    --     else
    --         self.index = data.index or 0
    --     end
    -- end
    proxy.ActivityProxy:sendMsg(1030123,{reqType = 0, awardId = 1})
end

function RechargeAgain:initView()

    --按钮：关闭窗口
    local btnClose = self.view:GetChild("n39"):GetChild("n8")
    btnClose.onClick:Add(self.onClickClose,self)
    self.t0 = self.view:GetTransition("t1")
    --按钮：充值/领取/已领取
    self.btnOK = self.view:GetChild("n10")

    --文本：充值金额
    self.textIngot = self.view:GetChild("n35")
    local textData = {
                    {text = language.gonggong88,color = globalConst.RechargeAgain01},
                    {text = 0,color = globalConst.RechargeAgain02},
            }
    self.textIngot.text = mgr.TextMgr:getTextByTable(textData)

    --控制器：奖励等级
    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController,self)

    --控制器：按钮状态转换
    self.controllerC2 = self.view:GetController("c2")
    
    --列表：定义
    self.listView = self.view:GetChild("n33")
    self:initListView()

    

    self.btnlist = {}
    for i = 1 , 6 do
        table.insert(self.btnlist,self.view:GetChild("btn"..i))
    end

    self.icon1 = self.view:GetChild("n38")  
    self.icon2 = self.view:GetChild("n0")  

end

function RechargeAgain:initBtn()
    -- body
    for k ,v in pairs(self.btnlist) do
        v:GetController("c1").selectedIndex = 0
    end
end

--1.列表：初始化
function RechargeAgain:initListView()
    -- body
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end
--2.列表：填值
function RechargeAgain:celldata(index, obj)
    -- body
    local data = self.awardsData[index+1]
    local mId = data[1]
    local amount = data[2]
    local bind = data[3]
    -- local info = {mid = mId,amount = amount,bind = conf.ItemConf:getBind(mId) or 0}
    local info = {mid = mId,amount = amount,bind = bind}

    GSetItemData(obj,info,true)     --物品信息
end

function RechargeAgain:onController()
    --self.confData = conf.ActivityConf:getReward(self.controllerC1.selectedIndex+1) 
    if not self.data then
        return
    end
    if self.controllerC1.selectedIndex < 3 then 
        self:setData()
    end
    
    -- print("水牛下水，水淹水牛头",self.controllerC1.selectedIndex+1)
    -- if self.controllerC1.selectedIndex == 3 then --EVE 添加时间：2017/8/25 原因：删除后三档
    --     self:onClickClose()
    -- end


    -- if self.data then
    --     self:setData(self.data)
    -- end 
end

function RechargeAgain:setData()
    local confdata = conf.ActivityConf:getReward(self.controllerC1.selectedIndex+1) or 0 

    if confdata.tab_dec then
        if self.controllerC1.selectedIndex == 0 then
            self.icon1.url = UIPackage.GetItemURL("activity" , confdata.tab_dec[1])
        else
            self.icon1.url = UIPackage.GetItemURL("activity" , confdata.tab_dec[1])
        end
    else
        self.icon1.url = nil 
    end
    if confdata.title then
        if self.controllerC1.selectedIndex == 0 then
            self.icon2.url = UIPackage.GetItemURL("activity" , confdata.title)
        else
            self.icon2.url = UIPackage.GetItemURL("activity" , confdata.title)
        end
    else
        self.icon2.url = nil 
    end
    --按钮状态转换
    if confdata.quota > self.data.lcYb then --充值金额不够
        -- self.btnOK.touchable = true
        self.btnOK:GetChild("red").visible = false
        self.controllerC2.selectedIndex = 0     --按钮：充值状态
    else
        local flag = false
        for k , v in pairs(self.data.gotList) do
            if v == confdata.id then
                flag = true
                -- self.btnOK.touchable = false
                self.controllerC2.selectedIndex = 2
                self.btnOK:GetChild("red").visible = false
                break
            end
        end

        if not flag then
            -- self.btnOK.touchable = true
            self.controllerC2.selectedIndex = 1
            self.btnOK:GetChild("red").visible = true
        end
    end
    -- print("按钮是否可点击",self.btnOK.touchable)
    self.btnOK.data = self.controllerC2.selectedIndex
    self.btnOK.onClick:Add(self.onClickOK,self)

    --获取奖励配置
    self.awardsData = {}
    local sex = cache.PlayerCache:getSex()
    if confdata.active_skin then
        table.insert(self.awardsData,confdata.active_skin[sex])
    end
    for k,v in pairs(confdata.awards) do
        table.insert(self.awardsData,v)
    end
    self.listView.numItems = #self.awardsData

    --模型图片展示
    local downImg = false
    if confdata.active_skin then--特殊皮肤
        local mid = confdata.active_skin[sex][1]
        local skin_oldShow = conf.ItemConf:getSuitmodel(mid)
        local modelId = skin_oldShow[1][1]
        self.t0:Stop()
        if self.effectList then
            -- print("特效移除",1,self.effectList)
            self:removeUIEffect(self.effectList)
            self.effectList = nil
        end
        if self.modelList then
            -- print("模型移除",1,self.modelList)
            self:removeModel(self.modelList)
            self.modelList = nil
        end
        local node = self.view:GetChild("n40")
        node.visible = true
        local modelObj = nil
        if self.controllerC1.selectedIndex == 1 then
            modelObj = self:addModel(modelId,node)
            -- modelObj:setSkins(nil,modelId,nil)
            self.t0:Play()
        elseif self.controllerC1.selectedIndex == 2 then
            local confData = conf.ActivityConf:getReward(self.controllerC1.selectedIndex)
            local wuqiMid = confData.active_skin[sex][1]
            local wuqiModel = conf.ItemConf:getSuitmodel(wuqiMid)
            modelObj = self:addModel(modelId,node)
            modelObj:setSkins(nil,wuqiModel[1][1],nil)
        end
        self.modelList = modelObj
        local xyz = confdata.xyz
        local pos = confdata.pos
        modelObj:setRotationXYZ(xyz[1][1],xyz[1][2],xyz[1][3])
        modelObj:setScale(confdata.scale[1])
        modelObj:setPosition(pos[1][1], pos[1][2], pos[1][3])
        self.view:GetChild("n36").visible = false
        local efcPos = self.view:GetChild("n47")
        self.effectList = self:addEffect(4020146, efcPos) --EVE 添加模型背景特效
    else
        local modelId = confdata.model_id
        -- print("模型图片展示",modelId)
        if modelId then
            self.t0:Stop()
            local downImg = false
            if type(modelId[1]) == "number" or type(modelId[1]) == "table" then
                local node = self.view:GetChild("n40")
                node.visible = true
                self.view:GetChild("n41").visible = false
                if self.effectList then
                    -- print("特效移除",1,self.effectList)
                    self:removeUIEffect(self.effectList)
                    self.effectList = nil
                end
                local modelObj = nil
                if type(modelId[1]) == "table" then
                    modelObj,downImg = self:addModel(modelId[1][1],node)
                    downImg = modelObj:setSkins(nil,modelId[1][2],modelId[1][3])
                else
                    modelObj,downImg = self:addModel(modelId[1],node)
                    -- if self.controllerC1.selectedIndex == 2 or self.controllerC1.selectedIndex == 5 then
                    --     modelObj,downImg = self:addModel(modelId[1],node) 
                    --     downImg = modelObj:setSkins(GuDingmodel[1],nil,modelId[1])
                    -- end 
                end
                self.modelList = modelObj
                local xyz = confdata.xyz
                local pos = confdata.pos
                modelObj:setRotationXYZ(xyz[1][1],xyz[1][2],xyz[1][3])
                modelObj:setScale(confdata.scale[1])
                modelObj:setPosition(pos[1][1], pos[1][2], pos[1][3])
                self.view:GetChild("n36").visible = false
            elseif type(modelId[1]) == "string" then
                if self.modelList then
                    -- print("模型移除",1,self.modelList)
                    self:removeModel(self.modelList)
                    self.modelList = nil
                end
                if self.effectList then
                    -- print("特效移除",1,self.effectList)
                    self:removeUIEffect(self.effectList)
                    self.effectList = nil
                end
                local node = self.view:GetChild("n41")
                node.visible = true
                self.view:GetChild("n40").visible = false
                local sex = cache.PlayerCache:getSex()
                local effectId = tonumber(string.sub(modelId[1],1,7))
                -- print("当前页签",self.controllerC1.selectedIndex)
                local var = 1
                if self.controllerC1.selectedIndex == 5 and sex == 2 and modelId[2] then
                    effectId = tonumber(string.sub(modelId[2],1,7))
                    var = 2
                    -- print("特效id",modelId[2],effectId)
                end
                if effectId then
                    self.view:GetChild("n36").visible = false
                    -- print("当前页签",self.controllerC1.selectedIndex,sex)
                    self.effectList = self:addEffect(effectId,node)
                    local xyz = confdata.xyz
                    local pos = confdata.pos
                    local scale = confdata.scale[var]
                    self.effectList.LocalRotation = Vector3.New(xyz[var][1],xyz[var][2],xyz[var][3])
                    self.effectList.Scale = Vector3.New(scale,scale,scale)
                    self.effectList.LocalPosition = Vector3(pos[var][1], pos[var][2], pos[var][3])

                else
                    local icon = UIItemRes.activeIcons..modelId[1]
                    local check = PathTool.CheckResDown(icon..".unity3d")
                    if check or g_extend_res == false then
                        self.view:GetChild("n36").url = UIItemRes.activeIcons..modelId[1]
                    else
                        self.view:GetChild("n36").url = UIPackage.GetItemURL("activity" , "zaichongxianli_005")
                    end

                    local effect = self:addEffect(4020203,node)
                    self.effectList = effect
                    self.view:GetChild("n36").visible = true
                    self.t0:Play()
                end
                -- self.view:GetChild("n3"..(i+7)).visible = true
            end
            -- --模型对应标签描述
            -- local tabDec = confdata.tab_dec
            -- if tabDec then
            --     local tabDecImg = self.view:GetChild("n3"..(i+7))
            --     tabDecImg.url = UIPackage.GetItemURL("activity" , tabDec[i])
            -- end
            -- if i == 1 and downImg then
            --     self.view:GetChild("n44").visible = true
            -- elseif i == 2 and downImg then
            --     self.view:GetChild("n45").visible = true
            -- end
        end
        if downImg then
            self.view:GetChild("n44").visible = true
        else
            self.view:GetChild("n44").visible = false
        end
    end
    
    --标题显示
    -- local title = confdata.title
    -- if title then
    --     local titleImg = self.view:GetChild("n0")
    --     titleImg.url = UIPackage.GetItemURL("activity" , title)
    -- end
    --文本显示已充值金额
    local textData = {
                    {text = language.gonggong88,color = globalConst.RechargeAgain01},
                    {text = self.data.lcYb,color = globalConst.RechargeAgain02},
            }
    self.textIngot.text = mgr.TextMgr:getTextByTable(textData)
end

--领取后跳转页签
function RechargeAgain:skipToNextPage(data)
    if self.index ~= 0 then
        if self.index == self.controllerC1.selectedIndex then
            self.index = 0
            self:onController()
        else
            self.controllerC1.selectedIndex = self.index
        end
        return
    end
    local confData = conf.ActivityConf:getReChargeAwards()

    local oldIndex = self.controllerC1.selectedIndex
    local pairs = pairs
    for k,v in pairs(confData) do
        local flag = false
        for i , j in pairs(data.gotList) do
            if v.id == j then
                flag = true
                break
            end
        end
        if not flag then
            self.controllerC1.selectedIndex = k - 1
            break
        else
            -- local var = 3
            -- if GIsCharged() then--首充过显示6档
            --     var = 6
            -- end
            if k ~= 6 then
                self.controllerC1.selectedIndex = k
            else
                self.controllerC1.selectedIndex = k - 1
            end
        end
    end
    -- print("当前档次",self.controllerC1.selectedIndex+1)
    if oldIndex == self.controllerC1.selectedIndex then
        self:onController()
    end
end

--按钮：充值/领取/已领取
function RechargeAgain:onClickOK(context)

    local cell = context.sender
    local status = cell.data    --C2 控制器状态
    if status == 0 then    --控制器 0状态（充值）
        self:onClickClose()
        GOpenView({id = 1042})
    elseif status == 1 then    ----控制器 1状态（领奖）
        proxy.ActivityProxy:sendMsg(1030123,{reqType = 1,awardId = self.controllerC1.selectedIndex+1})
    elseif status == 2 then --已领取
        GComAlter(language.xiuxian03)
    end
end

--按钮：关闭窗口
function RechargeAgain:onClickClose()
    
    self:closeView()
end

function RechargeAgain:dispose(clear)
    if self.effectList then
        -- print("特效移除",1,self.effectList)
        self:removeUIEffect(self.effectList)
        self.effectList = nil
    end
    if self.modelList then
        -- print("模型移除",1,self.modelList)
        self:removeModel(self.modelList)
        self.modelList = nil
    end
    
    self.super.dispose(self,clear)
end

function RechargeAgain:add5030123( data )
    -- body
    self.data = data
    if self.data.reqType == 0 then 
        --按档次显示
        self.confData = conf.ActivityConf:getReChargeAwards()
        --设置6个按钮状态
        for k ,v in pairs(self.confData) do
            local btn = self.btnlist[k]
            if btn and v.title1 then
                local c1 = btn:GetController("c1")
                c1.selectedIndex = 1
                local icon1 = btn:GetChild("n7") 
                icon1.url = UIPackage.GetItemURL("activity" , tostring(v.title1))
            end
        end
    --     -- self:onController()
    -- else
    end
end

return RechargeAgain

