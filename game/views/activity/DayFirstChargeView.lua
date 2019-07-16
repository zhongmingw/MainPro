--每日首充
local DayFirstChargeView = class("DayFirstChargeView",base.BaseView)
local dangci = 9
function DayFirstChargeView:ctor(  )
    -- body
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function DayFirstChargeView:initData(data)
    -- body
    self.confData = {}
    self.icon1.url = nil 
    self.icon2.url = nil 
    self:initBtn()


    -- if GIsCharged() then
        for i=1,dangci do
            self.view:GetChild("btn"..i).visible = true
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
    proxy.ActivityProxy:sendMsg(1030121,{reqType = 0})
end

function DayFirstChargeView:initView()
    -- body
    local btnClose = self.view:GetChild("n31"):GetChild("n8")
    btnClose.onClick:Add(self.onClickClose,self)

    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")

    self.controllerC = self.view:GetController("c1")
    self.controllerC.onChanged:Add(self.onController,self)

    self.listView = self.view:GetChild("n15")

    self.chargeBtn = self.view:GetChild("n14")
    self.chargeBtn.onClick:Add(self.onClickCharge,self)

    self:initListView()

    self.btnlist = {}
    for i = 1 , dangci do
        table.insert(self.btnlist,self.view:GetChild("btn"..i))
    end

    self.icon1 = self.view:GetChild("n6")
    self.icon2 = self.view:GetChild("n2") 
end

function DayFirstChargeView:initBtn()
    -- body
    for k ,v in pairs(self.btnlist) do
        v:GetController("c1").selectedIndex = 0
    end
end

function DayFirstChargeView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function DayFirstChargeView:onController()
    -- body
    if not self.data or #self.confData == 0 then
        return
    end
    --档次信息
    -- print("档次信息",#self.confData,self.controllerC.selectedIndex)
    self.nowConfData = self.confData[self.controllerC.selectedIndex+1]
    if self.nowConfData.tab_dec then
        self.icon1.url = UIPackage.GetItemURL("activity" , self.nowConfData.tab_dec)
    else
        self.icon1.url = nil 
    end
    if self.nowConfData.title then
        self.icon2.url = UIPackage.GetItemURL("activity" , self.nowConfData.title)
    else
        self.icon2.url = nil 
    end

    self:setData()

end

function DayFirstChargeView:setData(data)
    -- body
    --充值领取按钮设置
    local status = self.data.ItemStatus[self.nowConfData.id]
    if status == 0 then
        self.chargeBtn.touchable = true
        self.chargeBtn.grayed = false
        self.chargeBtn:GetChild("red").visible = false
        self.chargeBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "chongdianxiaoqian")
    elseif status == 1 then
        self.chargeBtn.touchable = true
        self.chargeBtn.grayed = false
        self.chargeBtn:GetChild("red").visible = true
        self.chargeBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "sanshitiandenglu_034")
    elseif status == 2 then
        self.chargeBtn.grayed = true
        self.chargeBtn.touchable = false
        self.chargeBtn:GetChild("red").visible = false
        self.chargeBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "sanshitiandenglu_035")
    end
    self.chargeBtn.data = status
    

    --模型图片展示
    local modelId = self.nowConfData.model_id
    local downImg = self.view:GetChild("n30")
    downImg.visible = false
    local cansee = false
    if modelId then
        self.t0:Stop()
        self.t1:Stop()
        -- print("图片或模型",modelId)
        if type(modelId) == "number" then
            local node = self.view:GetChild("n22")
            -- print("特效>>>>>>>>>>",self.effect)
            if self.effect then
                self:removeUIEffect(self.effect)
                self.effect = nil
            end
            if self.modelObj then
                self:removeModel(self.modelObj)
                self.modelObj = nil
            end
            local pos = self.nowConfData.pos
            local xyz = self.nowConfData.xyz
            self.modelObj,cansee = self:addModel(modelId,node)
            --plog(modelId,"modelId")
            local sign = tonumber(string.sub(modelId,1,5))
            if sign == 30301 or sign == 30304 then--仙羽
                cansee = self.modelObj:setSkins(GuDingmodel[1],nil,modelId)
            elseif sign == 30303 then--灵羽
                cansee = self.modelObj:setSkins(GuDingmodel[2],nil,modelId)
            end
            self.modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            self.modelObj:setScale(self.nowConfData.scale)
            self.modelObj:setPosition(pos[1], pos[2], pos[3])
            self.view:GetChild("n16").visible = false
        elseif type(modelId) == "string" then
            local imageIcon = self.view:GetChild("n16")
            if self.modelObj then
                self:removeModel(self.modelObj)
                self.modelObj = nil
            end
            if self.effect then
                self:removeUIEffect(self.effect)
                self.effect = nil
            end
            local node = self.view:GetChild("n22")
            local node1 = self.view:GetChild("n17")
            local node2 = self.view:GetChild("n35")
            node2.visible = false
            node1.visible = false
                -- print("添加特效",modelId,3020101)
            if tonumber(string.sub(modelId,1,4)) then
                local sign = tonumber(string.sub(modelId,1,5))
                if string.find(modelId,"_ui") and sign ~= 40402 and sign ~= 40403 
                    and sign ~= 40405 and sign ~= 40406 and sign ~= 40409 then
                    if sign == 40404 then--神兵
                        self.modelObj = self:addModel(GuDingmodel[3],node)
                        self.modelObj:addModelEct(modelId)
                    elseif sign == 40411 then--光环
                        -- print("光环特效",modelId)
                        self.modelObj = self:addModel(GuDingmodel[1],node)
                        local modelEct = self.modelObj:addModelEct(modelId)
                        modelEct.Scale =  Vector3.New(0.35,0.35,0.35)
                    else
                        self.modelObj = self:addModel(GuDingmodel[2],node)
                        self.modelObj:addWeaponEct(modelId)
                    end
                    local pos = self.nowConfData.pos
                    local xyz = self.nowConfData.xyz
                    self.modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
                    self.modelObj:setScale(self.nowConfData.scale)
                    self.modelObj:setPosition(pos[1], pos[2], pos[3])
                else--法宝仙器灵宝灵器神器
                    local effectId = string.sub(modelId,1,7)
                    node1.visible = true
                    self.effect = self:addEffect(effectId,node1)
                    local pos = self.nowConfData.pos
                    self.effect.LocalPosition = Vector3(pos[1],pos[2],pos[3])
                    self.effect.Scale = Vector3.New(self.nowConfData.scale, self.nowConfData.scale, self.nowConfData.scale)
                    local sign = tonumber(string.sub(modelId,1,5))
                    if sign ~= 40402 then--仙器不加动效
                        self.t0:Play()
                    end
                end
                imageIcon.visible = false
            else
                self.t1:Play()
                imageIcon.visible = true
                node2.visible = true
                local icon = UIItemRes.activeIcons..self.nowConfData.model_id
                local check = PathTool.CheckResDown(icon..".unity3d")
                if check or g_extend_res == false then
                    -- print("11111111",icon)
                    local url = UIItemRes.activeIcons..self.nowConfData.model_id
                    imageIcon.url = url
                else
                    -- print("22222222")
                    imageIcon.url = UIPackage.GetItemURL("activity" , self.nowConfData.model_id)
                end
                self.effect = self:addEffect(4020202,node2)
                self.effect.LocalPosition = Vector3(0,-0,200)
                node1.visible = true
                local effect = self:addEffect(4020203,node1)
            end
        elseif type(modelId) == "table" then
            local node = self.view:GetChild("n22")
            if self.effect then
                self:removeUIEffect(self.effect)
                self.effect = nil
            end
            if self.modelObj then
                self:removeModel(self.modelObj)
                self.modelObj = nil
            end
            local pos = self.nowConfData.pos
            local xyz = self.nowConfData.xyz
            self.modelObj,cansee = self:addModel(modelId[1],node)
            self.modelObj:setSkins(nil,modelId[2],modelId[3])
            self.modelObj:setRotationXYZ(xyz[1],xyz[2],xyz[3])
            self.modelObj:setScale(self.nowConfData.scale)
            self.modelObj:setPosition(pos[1], pos[2], pos[3])
            self.view:GetChild("n16").visible = false
        end
        downImg.visible = cansee
    end

    --设置奖励列表
    local len = 0
    self.awardsData = {}
    if self.nowConfData then
        self.awardsData = self.nowConfData.awards
        len = #self.awardsData
    end
    self.listView.numItems = len
    
    local hasCharge = self.view:GetChild("n20")
    local YbNum = self.data.YbNum or 0
    local textData = {
                    {text = language.gonggong88,color = globalConst.DayFirstChargeView01},
                    {text = YbNum,color = globalConst.DayFirstChargeView02},
            }
    hasCharge.text = mgr.TextMgr:getTextByTable(textData)
end

function DayFirstChargeView:celldata(index, obj)
    -- body
    local data = self.awardsData[index+1]
    local mId = data[1]
    local amount = data[2]
    local bind = data[3]
    local info = {mid = mId,amount = amount,bind = bind}
    GSetItemData(obj,info,true)
end



--领取成功后跳转到下一个页签
function DayFirstChargeView:skipToNextPage(data)
    if self.index ~= 0 then
        if self.index == self.controllerC.selectedIndex then
            self.index = 0
            self:onController()
        else
            self.controllerC.selectedIndex = self.index
        end
        return
    end

    local conf = conf.ActivityConf:getDaliyChargeData()
    local confData = {}
    local oldIndex = self.controllerC.selectedIndex
    for k,v in pairs(conf) do
        if data.day >= v.day[1] and data.day <= v.day[2] then
            table.insert(confData,v)
        end
    end
    table.sort(confData,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    for k,v in pairs(confData) do
        local flag = false
        if data.ItemStatus[v.id] == 2 then
            flag = true
        end
        if not flag then
            self.controllerC.selectedIndex = k - 1
            break
        else
            -- local var = 3
            -- if GIsCharged() then--首充过显示7档
            --     var = 7
            -- end
            if k ~= #self.confData then
                self.controllerC.selectedIndex = k
            else
                self.controllerC.selectedIndex = k - 1
            end
        end
    end

    if oldIndex == self.controllerC.selectedIndex then
        self:onController()
    end
end

function DayFirstChargeView:onClickCharge( context )
    -- body
    local cell = context.sender
    local status = cell.data
    if status == 0 then
        self.effect = nil
        self.modelObj = nil
        GOpenView({id = 1042})
    elseif status == 1 then
        proxy.ActivityProxy:sendMsg(1030121,{reqType = 1,awardId = self.nowConfData.id})
    end
end

function DayFirstChargeView:onClickClose()
    -- body
    self:closeView()
end

function DayFirstChargeView:dispose(clear)
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    if self.modelObj then
        self:removeModel(self.modelObj)
        self.modelObj = nil
    end
    self.super.dispose(self,clear)
end

function DayFirstChargeView:add5030121(data)
    -- body
    self.data = data
    --printt("000000000000000",data)
    if self.data.reqType == 0 then
        self.confData = {}
        --获取当前天的奖励配置
        local confData = conf.ActivityConf:getDaliyChargeData()

        for k,v in pairs(confData) do
            if data.day >= v.day[1] and data.day <= v.day[2] then
                table.insert(self.confData,v)
            end
        end

        for k,v in pairs(self.btnlist) do
            self.btnlist[k].visible = false
        end
        for i=1,#self.confData do
            self.btnlist[i].visible = true
        end
        
        table.sort(self.confData,function(a,b)
            return a.id < b.id
        end)
        --设置7个按钮状态
        for k ,v in pairs(self.confData) do
            local btn = self.btnlist[k]
            if btn and v.title1 then
                local c1 = btn:GetController("c1")
                c1.selectedIndex = 1
                local icon1 = btn:GetChild("n7") 
                icon1.url = UIPackage.GetItemURL("activity" , tostring(v.title1))
            end
        end
        -- --按档次显示
        -- self:onController()
    else
        --刷新
        -- self:skipToNextPage(data)
        GOpenAlert3(data.Items)
    end
end

return DayFirstChargeView