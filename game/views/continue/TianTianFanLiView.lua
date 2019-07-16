--
-- Author: 
-- Date: 2018-11-12 16:49:59
--

local TianTianFanLiView = class("TianTianFanLiView", base.BaseView)

function TianTianFanLiView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function TianTianFanLiView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.listView1 = self.view:GetChild("n15")
    self.listView1.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView1.numItems = 0

    self.listView2 =self.view:GetChild("n21")
    self.listView2.itemRenderer = function(index,obj)
        self:cellData1(index, obj)
    end
    self.listView2.numItems = 0
    self.chognzhiDay = self.view:GetChild("n4")
    
    self.modelPanel=self.view:GetChild("n6")
    self.effectPanel=self.view:GetChild("n22")

    self.decTxt = self.view:GetChild("n8")
    self.decTxt.text = string.format(language.ttfl,conf.ActivityConf:getValue("tiantianchognzhiday")[1])
end

-- 1   
-- int8
-- 变量名：reqType 说明：0:显示 1:领取
-- 2   
-- int32
-- 变量名：cfgId   说明：领取id
-- 3   
-- map<int32,int32>
-- 变量名：gotSigns    说明：奖励领取标识
-- 4   
-- int32
-- 变量名：days    说明：累计充值的天数
-- 5   
-- int32
-- 变量名：lunshu  说明：轮数
-- 6   
-- array<SimpleItemInfo>   变量名：items   说明：奖励
function TianTianFanLiView:setData(data)
    printt(data,"天天返利")
    self.data = data
    self:initModel()
    if data.items then
        GOpenAlert3(data.items,true)
    end
    self.chognzhiDay.text = self.data.days
    self.data1 = conf.ActivityConf:getTianTianFanLibyLunShu(data.lunshu,1) --下面列表
    self.data2 = conf.ActivityConf:getTianTianFanLibyLunShu(data.lunshu,2) --上面列表

    self.gots = {}
    for k,v in pairs(data.gotSigns) do
        self.gots[k] = v
    end

    self.listView1.numItems = #self.data2
    self.listView2.numItems = #self.data1

end

function TianTianFanLiView:cellData(index, obj)
    local data = self.data2[index + 1]
    local daytext = obj:GetChild("n6")
    daytext.text = string.format(language.ttfl01,data.days)
    local c1 = obj:GetController("c1")
    local item = obj:GetChild("n4")
    item.touchable = true 
    --除掉最后一个进度条
    if index ==  #self.data2 - 1 then
        obj:GetChild("n7").visible  = false
        obj:GetChild("n8").visible  = false
    end
    if self.gots[data.id] then
        if self.gots[data.id] == 1 then --判断是否已领取
            c1.selectedIndex = 2
            item.grayed = false
            local itemData = {mid = data.items[1][1],amount = data.items[1][2],bind = data.items[1][3],isquan = true}
            GSetItemData(item,itemData,true)
            --进度条百分比显示
            if  data.days <= self.data.days then
                local img = obj:GetChild("n8")
                local nextday
                if self.data.days == self.data2[#self.data2].days then
                    nextday = 1
                    img.scaleX = 1
                else
                    nextday  = self.data2[index +2 ].days 
                    img.scaleX =  (self.data.days- data.days)/(nextday-data.days) >=1 and 1 or (self.data.days- data.days)/(nextday-data.days)
                end
                -- print(img.scaleX,"已领取")
            end     
            return
        end
    else
        if self.data.days >= data.days   then --可领取
            c1.selectedIndex = 1
            obj.data = data.id
            obj:RemoveEventListeners()
            obj.onClick:Add(self.lingQu,self)
            item.touchable = false 
            item.grayed = false
            local itemData = {mid = data.items[1][1],amount = data.items[1][2],bind = data.items[1][3],isquan = c1.selectedIndex == 0 and true or false}
            GSetItemData(item,itemData,false)
            --进度条百分比显示
            if  data.days <= self.data.days then
                local img = obj:GetChild("n8")
                local nextday
                if self.data.days == self.data2[#self.data2].days then
                    nextday = 1
                    img.scaleX = 1
                else
                    nextday  = self.data2[index +2 ].days 
                    img.scaleX =  (self.data.days- data.days)/(nextday-data.days) >=1 and 1 or (self.data.days- data.days)/(nextday-data.days)
                end
                print(img.scaleX,"可领取")

            end      
            
            print("不能查看只能领取")
            return
        else
            item.grayed = true
            c1.selectedIndex = 0
        end
    end
    local itemData = {mid = data.items[1][1],amount = data.items[1][2],bind = data.items[1][3],isquan = c1.selectedIndex == 0 and true or false}
    GSetItemData(item,itemData,true)
end

function  TianTianFanLiView:lingQu( context )
    local data = context.sender.data
    printt("当前领取id",data)
    if not self.gots[data] then
        proxy.ActivityProxy:send(1030650,{reqType = 1 ,cfgId = data})
    end
end

function TianTianFanLiView:cellData1(index, obj)
    local data = self.data1[index + 1]
    local c1 = obj:GetController("c1")
    local Txt = obj:GetChild("n17")
    Txt.text = string.format(language.ttfl03,data.days)
    local Txt1 = obj:GetChild("n18")
    Txt1.text = string.format(language.ttfl02,data.quota)
    if self.gots[data.id] then
        if self.gots[data.id] == 1 then 
            c1.selectedIndex = 1
        end
    else
        if self.data.days >=  data.days then
            local btn  = obj:GetChild("n20")
            local redpoint = btn:GetChild("red")
            redpoint.visible = true
            btn:RemoveEventListeners()
            btn.data = data.id
            btn.onClick:Add(self.lingQu,self)
            c1.selectedIndex = 0 
        else
            c1.selectedIndex = 2 
        end 
    end
    
    local itemlist = obj:GetChild("n19")
    itemlist.itemRenderer = function(index,cell)
        local itemData = {mid = data.items[index + 1][1],amount = data.items[index + 1][2],bind = data.items[index + 1][3]}
        GSetItemData(cell,itemData,true)  
    end

    itemlist.numItems = #data.items

end

function TianTianFanLiView:initModel()
    local effId = conf.ActivityConf:getTianTianFanLiEffectByLunShu(self.data.lunshu)
    local effIdScale = conf.ActivityConf:getTTFLEffectScale(self.data.lunshu)
    local  transform = conf.ActivityConf:getTTFLTransform(self.data.lunshu)
    if effId then
        local sex = cache.PlayerCache:getSex()
        local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
        local skins2 = cache.PlayerCache:getSkins(Skins.wuqi)--武器
        local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
        local modelObj = self:addModel(skins1,self.modelPanel)
        modelObj:setSkins(nil,skins2,skins3)
        if transform then
            modelObj:setPosition(transform[1],transform[2],transform[3]) 
        else
            modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
        end
        modelObj:setRotation(RoleSexModel[sex].angle)
        modelObj:removeModelEct()
        local modelEct = modelObj:addModelEct(effId .. "_ui")
        local _scale = effIdScale or 0.18
        modelEct.Scale =  Vector3.New(_scale,_scale,_scale)

        return
    end
    local modelId = conf.ActivityConf:getTianTianFanLiModelByLunShu(self.data.lunshu)
    local needmodel =  conf.ActivityConf:getTianTianFanLiNeedModuleByLunShu(self.data.lunshu)
    if needmodel then
        local modelObj = self:addModel(GuDingmodel[1],self.modelPanel)
        modelObj:setScale(modelId[2]) --TODO
        if transform then
            modelObj:setPosition(transform[1],transform[2],transform[3]) 
        else
            modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
        end
        modelObj:setSkins(nil,nil, modelId[1] ) --添加需要展示的武器
        modelObj:setRotationXYZ(1,300,359)
        return
    end
    local modelObj = self:addModel(modelId[1],self.modelPanel)
    modelObj:setScale(modelId[2]) --TODO
    if transform then
            modelObj:setPosition(transform[1],transform[2],transform[3]) 
    else
            modelObj:setPosition(self.modelPanel.actualWidth/2,-self.modelPanel.actualHeight-200,500)
    end
    if modelId[3] then
         modelObj:setRotationXYZ(modelId[3],modelId[4],modelId[5])
    else
        modelObj:setRotationXYZ(0,170,0)
    end
end


return TianTianFanLiView