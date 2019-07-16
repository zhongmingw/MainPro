--
-- Author: EVE
-- Date: 2017-08-31 15:20:11
--

local FashionTipsView = class("FashionTipsView", base.BaseView)
local t = {   --模块/活动
        [1114] = 3010,   -- 百倍/0元购？
        [1111] = 1038,   -- 夏日活动
        [1113] = 1037,   -- 活跃红包
        [1115] = 1042,   -- 宝树
        [1121] = 1046,   -- 电石成金      
        [1122] = 1047,   -- 疯狂砸蛋
}
function FashionTipsView:ctor()
    self.super.ctor(self)
    self.isBlack = true 
    self.uiLevel = UILevel.level3 
end

function FashionTipsView:initData()
    self:onControlChange()

end

function FashionTipsView:initView()
    --属性模块
    self.panelObj1 = self.view:GetChild("n0")
    --模型模块
    self.panelObj2 = self.view:GetChild("n1")
    self.panel = self.panelObj2:GetChild("n4")
    self.originalPos = self.panel.xy

    self.bindTxt = self.panelObj1:GetChild("n26")

    self:initPanel1()

    self.anim = self.panelObj2:GetTransition("t0")
    self.imageIcon = self.panelObj2:GetChild("n7")
    self.effectnode = self.panelObj2:GetChild("effect")

    
    self.blackView.onClick:Add(self.onCloseView,self)

    local panel = self.view:GetChild("n7")

    self.wearsBtn = panel:GetChild("n2") --激活按钮bxp
    self.wearsBtn.onClick:Add(self.onWearsBtn,self)
    
    local discardBtn = panel:GetChild("n3") --丢弃时装按钮bxp
    discardBtn.onClick:Add(self.onClickDiscard,self)

    --放入按钮
    self.putBtn = panel:GetChild("n4")
    self.putBtn.onClick:Add(self.onClickPut,self)
   
    self.controller1 = panel:GetController("c1")

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onControlChange,self)
end
--装备属性页面
function FashionTipsView:initPanel1()
    self.itemObj1 = self.panelObj1:GetChild("n19") --LOGO
    self.itemObj1.visible = false

    self.itemName1 = self.panelObj1:GetChild("n24") --装备名称
    self.itemName1.text = ""

    self.power1 = self.panelObj1:GetChild("n18")--战斗力
    self.power1.text = 0

    self.attListView1 = self.panelObj1:GetChild("n41") --属性

    self.listView1 = self.panelObj1:GetChild("n47")  --获取途径
    self.listView1.itemRenderer = function(index,obj)
        self:cellData1(index, obj)
    end
    
    local selectSuitBtn = self.panelObj1:GetChild("n48")--套装属性按钮
    self.selectSuitBtn = selectSuitBtn
    selectSuitBtn.onClick:Add(self.onClickGoSuit,self)
end
--模型展示页面
function FashionTipsView:initModel()
    -- body
    local isSuit = conf.ItemConf:getSuitmodel(self.data.mid)
    if isSuit and type(isSuit) == "table" then--特效和模型
        self.imageIcon.visible = false
        self.panel.visible = true
        local canFloat = conf.ItemConf:getIsCanFloat(self.data.mid) --是否有浮动效果
        if canFloat then 
            self.anim:Play()
        else
            -- print("AAAAAAAAAAA")
            self.anim:Stop()
            self.panel.xy = self.originalPos   
        end 

        local sex = 1
        local sexCloth = conf.ItemConf:getSuitmodel(self.data.mid)
        if #sexCloth == 2 then
            local roleIcon = cache.PlayerCache:getRoleIcon()
            sex = GGetMsgByRoleIcon(roleIcon).sex--性别
        end

        local skin_oldShow = conf.ItemConf:getSuitmodel(self.data.mid)[sex]  --读取suitshow的第一个模型
        local suitTransform = conf.ItemConf:getSuitTransformDataById(self.data.mid)

        local a = suitTransform[1]
        local b = suitTransform[2]
        local c = suitTransform[3]
     
        -- plog("当前模型ID为：",self.data.mid)
        --self:addModel
        if not skin_oldShow then
            return
        end
        if skin_oldShow[2] == 1 and suitTransform then --模型
            if skin_oldShow[3] then 
                if skin_oldShow[3] == 1 then
                    self.model = self:addModel(GuDingmodel[1],self.panel)
                elseif skin_oldShow[3] >= 1000000 then
                    self.model = self:addModel(skin_oldShow[3],self.panel)
                else
                    self.model = self:addModel(GuDingmodel[2],self.panel)
                end
                self.model:setSkins(nil,nil,skin_oldShow[1])

            elseif tonumber(string.sub(skin_oldShow[1],1,1)) == 6 then--剑神道具
                local buffId = skin_oldShow[1]
                local buffConf = conf.BuffConf:getBuffConf(buffId)
                if buffConf.bs_args then
                    self.model = self:addModel(buffConf.bs_args[1],self.panel)
                    self.model:setSkins(nil,buffConf.bs_args[2],buffConf.bs_args[3])
                end
            else
                local needModel = conf.ItemConf:getIsNeedModel(self.data.mid) --是否需要模特载体
                if needModel then 
                    local body 
                    if needModel == 1 then  --常规
                        body = cache.PlayerCache:getSkins(Skins.clothes)--衣服载体
                    elseif needModel == 2 then --需要男模
                        body = 3010101
                    elseif needModel == 3 then --需要女模
                        body = 3010201
                    end
                  
                    self.model = self:addModel(body, self.panel)
                    self.model:setSkins(nil, skin_oldShow[1], nil) --添加需要展示的武器
                else
                    self.model = self:addModel(skin_oldShow[1],self.panel)
                end 
            end

            -- self.model:setPosition(self.panel.actualWidth/2,-self.panel.actualHeight-200,100)
            -- self.model:setRotationXYZ(0,100,0)
            -- self.model:setScale(100)
            if a  then 
                self.model:setPosition(a[1],a[2],a[3])
            end
            if b then
                self.model:setRotationXYZ(b[1],b[2],b[3])
            end
            if c then
                self.model:setScale(c[1])
            end  
                   
        else --特效
            print("skin_oldShow")
            printt(skin_oldShow)
            if skin_oldShow[3] then 
                local useid 
                if skin_oldShow[3] == 1 then
      

                    useid =  cache.PlayerCache:getSkins(Skins.wuqi)
                    if useid == 0 then
                        useid = GuDingmodel[3]
                    end
                elseif skin_oldShow[3] == 3 or skin_oldShow[3] == 4 or skin_oldShow[3] == 7 then
           
                    useid =  cache.PlayerCache:getSkins(Skins.clothes)
                    if useid == 0 then
                        useid = GuDingmodel[1]
                    end
                elseif skin_oldShow[3] == 5 then --男面具
                     useid = GuDingmodel[6]
                elseif skin_oldShow[3] == 6 then --女面具
                     useid = GuDingmodel[7]
                else
              
                    useid = GuDingmodel[2]
                end
                self.model = self:addModel(useid, self.panel) 
         
                if a and b and c then 
                    self.model:setPosition(a[1],a[2],a[3])
                    self.model:setRotationXYZ(b[1],b[2],b[3])
                    self.model:setScale(c[1])
                end
                  
                --添加神兵特效
                if skin_oldShow[3] == 1 then
                    self.model:addModelEct(skin_oldShow[1].."_ui")
                elseif skin_oldShow[3] == 3 then
                    local effect = self.model:addModelEct(skin_oldShow[1].."_ui")
                    effect.Scale = Vector3.New(0.35,0.35,0.35)
                elseif skin_oldShow[3] == 4 then--头饰
                    self.model:addHeadEct(skin_oldShow[1])
                elseif skin_oldShow[3] == 5 or skin_oldShow[3] == 6 then --面具
                    self.model:removeModelEct()
                    local effect = self:addEffect(skin_oldShow[1],self.effectnode)
                    local mianjuData = conf.MianJuConf:getMianjuIdData(self.data.mid) 
                
                    if mianjuData then
                        effect.LocalPosition = Vector3(mianjuData.transform_daoju[1],mianjuData.transform_daoju[2],mianjuData.transform_daoju[3])
                        effect.LocalRotation = Vector3(mianjuData.rotation_daoju[1],mianjuData.rotation_daoju[2],mianjuData.rotation_daoju[3])
                        effect.Scale = Vector3.New(mianjuData.scale_daoju,mianjuData.scale_daoju,mianjuData.scale_daoju)
                    end
                elseif skin_oldShow[3] == 7 then--面具碎片
                    self.model:addMianJuEct(skin_oldShow[1])
                else
                    self.model:addWeaponEct(skin_oldShow[1].."_ui")
                end
                          
            else
                if a and c then
                    self.model = self:addEffect(skin_oldShow[1],self.panel)
                    if self.model then 
                        self.model.LocalPosition = Vector3(a[1],a[2],a[3])
                        self.model.Scale = Vector3.New(c[1],c[2],c[3])

                        if b then
                            self.model.LocalRotation = Vector3(b[1],b[2],b[3])
                        end
                        -- plog("牛耕田")
                    else
                        plog("@策划，当前特效不存在！",skin_oldShow[1])
                    end 
                end
            end
        end
    elseif isSuit and type(isSuit) == "string" then--图片
        self.anim:Play()
        self.imageIcon.visible = true
        self.panel.visible = false
        self.imageIcon.url = UIPackage.GetItemURL("_others" , isSuit)
    end

end
--开始写入数据
function FashionTipsView:setData(data)
    -- printt(data)
    self.attListView1.numItems = 0
    self.listView1.numItems = 0
    -- plog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~@@", data.mid)
    self.data = data
    -- self.data.mid = 221071039
    --激活or丢弃bxp
    local isNotDiscard = conf.ItemConf:getIsNotDiscard(self.data.mid)
    self.controller1.selectedIndex = isNotDiscard == 1 and 0 or 1

    --是否是时装碎片
    local isSuipian = conf.ItemConf:getIsSuitSuiPian(self.data.mid)
    if isSuipian then--使用
        self.wearsBtn:GetChild("title").text = language.pack03
    else--激活
        self.wearsBtn:GetChild("title").text = language.pack03_1
    end

    if mgr.ItemMgr:getPackIndex() == Pack.wareIndex then --仓库
        if mgr.ItemMgr:isPackItem(data.index) then
            self.controller1.selectedIndex = 2
            self.putBtn:GetChild("title").text = language.pack06
        else
            self.controller1.selectedIndex = 3
            self.putBtn:GetChild("title").text = language.pack07
        end
    end
    --显示icon
    GSetItemData(self.itemObj1, self.data)
    --道具名字
    self.itemName1.text = mgr.TextMgr:getColorNameByMid(self.data.mid)
    --战斗力
    self.power1.text = conf.ItemConf:getPower(self.data.mid)
    -- local bind = conf.ItemConf:getBind(self.data.mid)
    if self.data.bind and self.data.bind == 1 then
        self.bindTxt.text = language.gonggong105
    else
        self.bindTxt.text = language.gonggong106
    end
    --基础描述
    local var = UIPackage.GetItemURL("alert" , "Component1")
    local _compent1 = self.attListView1:AddItemFromPool(var)
    _compent1:GetChild("n0").text = conf.ItemConf:getDescribe(self.data.mid)
    --_compent1.height = _compent1:GetChild("n0").height
    --基础属性
    local var = UIPackage.GetItemURL("alert" , "Component2")
    local _compent2 = self.attListView1:AddItemFromPool(var)
    _compent2:GetChild("n0").text = language.fashionTips01
    local _t = GConfDataSort(conf.ItemArriConf:getItemAtt(self.data.mid))
    -- printt(_t)
    local str = ""
    local percentAttribute = ""
    for k ,v in pairs(_t) do
        -- printt(v)
        if v[1] ~= 221 then 
            local tempData = mgr.TextMgr:getQualityStr2("+"..GProPrecnt(v[1],v[2]), 6)
            str = str ..  conf.RedPointConf:getProName(v[1]).."   "..tempData    --GProPrecnt(v[1],v[2]) 
        else
            if tonumber(v[2])%100 == 0 then
                local tempData = mgr.TextMgr:getQualityStr2("+"..tostring(tonumber(v[2])/100).."%", 6)
                percentAttribute = language.fashionTips04 .. tempData--tostring(tonumber(v[2])/100).."%"
            else
                local tempData = mgr.TextMgr:getQualityStr2("+"..string.format("%.2f",tonumber(v[2])/100).."%", 6)
                percentAttribute = language.fashionTips04 .. tempData--string.format("%.2f",tonumber(v[2])/100).."%"
            end
        end 

        if k ~= #_t then
            str = str .. "\n"
        elseif percentAttribute ~= "" then 
            str = percentAttribute .. "\n" .. str
        end
    end
    --plog("str "..str)
    local var = UIPackage.GetItemURL("alert" , "Component3")
    local _compent3 = self.attListView1:AddItemFromPool(var)
    _compent3:GetChild("n0").text = str
    _compent3:GetChild("n1").text = ""

    _compent3.height = _compent3:GetChild("n0").height + 5
    --升星属性
    local suitStarData = conf.ItemConf:getFashionStarData(data.mid)
    if suitStarData then
        local var = UIPackage.GetItemURL("alert" , "Component2")
        local _compent2 = self.attListView1:AddItemFromPool(var)
        _compent2:GetChild("n0").text = language.equip02[5]
        local suitStarConf = conf.RoleConf:getSkinsStarAttrData(suitStarData[2],suitStarData[1])
        local skinName2 = ""
        local suitId = 0
        for k,v in pairs(suitStarConf) do
            local var2 = UIPackage.GetItemURL("alert" , "Component3")
            local _compent3 = self.attListView1:AddItemFromPool(var2)
            for _,skinId in pairs(v.skins) do
                if skinId ~= suitStarData[2] then
                    suitId = skinId
                    break
                end
            end
            if suitId ~= 0 then
                local suitData = conf.RoleConf:getFashData(suitId)--配套时装
                local suitStarPre = suitData and suitData.star_pre or 0
                local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
                skinName2 = suitData.name
                local textData = {
                    {text = string.format(language.fashion20,skinName2).. language.fashion14_1 .. language.fashion17[1].text,color = 8},
                    {text = string.format("%d",v.need_star),color = 7},
                    {text = language.gonggong118,color = 8},
                }
                _compent3:GetChild("n0").text = mgr.TextMgr:getTextByTable(textData)
                local textData = {
                    {text = language.fashion22,color = 8},
                    {text = "+" ..(v.attr_show/100) .. "%",color = 7}
                }
                _compent3:GetChild("n1").text = mgr.TextMgr:getTextByTable(textData)
                _compent3.height = _compent3:GetChild("n1").height + 5
            else
                local textData = {
                    {text = language.fashion19 .. language.fashion17[1].text,color = 8},
                    {text = string.format("%d",v.need_star),color = 7},
                    {text = language.gonggong118,color = 8},
                }
                _compent3:GetChild("n0").text = mgr.TextMgr:getTextByTable(textData)
                local textData = {
                    {text = string.format(language.fashion17[4].text,language.gonggong94[suitStarData[1]]),color = 8},
                    {text = string.format(language.fashion17[5].text,(v.attr_show/100)),color = 7}
                }
                _compent3:GetChild("n1").text = mgr.TextMgr:getTextByTable(textData)
                _compent3.height = _compent3:GetChild("n1").height + 5
            end
        end
    end
    --套装属性
    local index = conf.ItemConf:getFashionsSuitId(data.mid)
    if index then --套装属性不存在则不显示套装 
        self.confdata2 = conf.ForgingConf:getSuitEffect(index)
        -- plog("套装属性异常说明：", data.mid, index)
        local var = UIPackage.GetItemURL("alert" , "Component2")
        local _compent2 = self.attListView1:AddItemFromPool(var)
        _compent2:GetChild("n0").text = language.fashionTips02
        table.sort(self.confdata2,function(a,b)
            -- body
            return a.id < b.id
        end)

        for k ,v in pairs(self.confdata2) do  
            local data = conf.ForgingConf:getSuitEffect(index,v.equip_num,true)
            for k,v in pairs(data) do
                if v == 0 then 
                    data[k] = nil         
                end 
            end

            local str = ""
            local _t = GConfDataSort(data) 
            for i ,j in pairs(_t) do
                str = str ..  conf.RedPointConf:getProName(j[1]).."   +".. GProPrecnt(j[1],j[2])
                if i ~= #_t then
                    str = str .. "\n"
                end
            end

            local var = UIPackage.GetItemURL("alert" , "Component3")
            local _compent3 = self.attListView1:AddItemFromPool(var)
            _compent3:GetChild("n0").text = string.format(language.fashionTips03,v.equip_num)
            _compent3:GetChild("n1").text = str
            _compent3.height = _compent3:GetChild("n1").height + 5
        end
    end

    self:initModel() --模型展示

    self.formview = conf.ItemConf:getFormview(self.data.mid)--跳转路径
    if self.formview and self.formview ~= 0 then
        self.listView1.numItems = #self.formview
    elseif self.formview == 0 then 
        print("@策划 道具配表ID：",self.data.mid,"获取途径配置不正确")
    end
    --套装属性按钮
    local suitMod = conf.ItemConf:getSuitModule(self.data.mid)
    if suitMod then
        self.selectSuitBtn.visible = true
    else
        self.selectSuitBtn.visible = false
    end

end
-- --装备固定信息
-- function FashionTipsView:setPanel1Data()   
--     self.listView1.numItems = 0
--     if self.formview1 then
--         local len = #self.formview1
--         self.listView1.numItems = len
--         if len > 0 then
--             self.listView1:ScrollToView(0)
--         end
--     end

-- end

--获取途径
function FashionTipsView:cellData1(index, obj)
    self:setCellData(self.formview[index + 1],obj)
end
function FashionTipsView:setCellData(moduleData,obj)
    local id = moduleData and moduleData[1]
    local childIndex = moduleData and moduleData[2]
    local goBtnVisible = moduleData and moduleData[3] 
    local data = conf.SysConf:getModuleById(id)
    local lab = obj:GetChild("n1")
    lab.text = data.desc
    local btn = obj:GetChild("n0")
    if not goBtnVisible or (goBtnVisible and goBtnVisible == 0) then
        btn.visible = true
    else
        btn.visible = false
    end
    btn.data = {id = id,childIndex = childIndex}
    btn.onClick:Add(self.onBtnGo,self)
end

function FashionTipsView:onClickGoSuit()
    if not self.data then return end
    local suitMod = conf.ItemConf:getSuitModule(self.data.mid)
    if suitMod then
        local param = {id = suitMod[1],childIndex = suitMod[2],grandson = suitMod[3]}
        GOpenView(param)
    else
        plog("@改道具请配suit_module跳转路径",self.data.mid)
    end
end
--路径跳转
function FashionTipsView:onBtnGo(context)
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}

    if t[data.id] then
        if t[data.id] == 3010 then
            local temp = cache.PlayerCache:getRedPointById(30111)
            if temp > 0 then 
                GOpenView(param)
            else
                GComAlter(language.acthall03)
            end 
        else
            local actData = cache.ActivityCache:get5030111()
            if actData.acts[t[data.id]] == 1 then
                GOpenView(param)
            else
                GComAlter(language.acthall03)
            end
        end 
    else
        GOpenView(param)
    end  
end

function FashionTipsView:onControlChange()
    local packView = mgr.ViewMgr:get(ViewName.PackView)
    local propMsgView = mgr.ViewMgr:get(ViewName.PropMsgView)
    if packView then 
        if propMsgView then--从礼盒中打开的时装界面，右侧的按钮隐藏bxp
            self.c1.selectedIndex = 0
        else
            self.c1.selectedIndex = 1
        end
    else
        self.c1.selectedIndex = 0
    end 
end

--激活时装按钮
function FashionTipsView:onWearsBtn()
    local isSuipian = conf.ItemConf:getIsSuitSuiPian(self.data.mid)
    if isSuipian then--时装碎片跳转到合成
        local tabType = conf.ItemConf:getTabType(self.data.mid)
        if tabType then
            GOpenView({id = tabType[1],childIndex = tabType[2]})
        end
    else
        local isSuit = conf.ItemConf:getSuitmodel(self.data.mid)
        if type(isSuit) == "string" then--聊天头像框和气泡 跳转
            local tabType = conf.ItemConf:getTabType(self.data.mid)
            if tabType then
                GOpenView({id = tabType[1],childIndex = tabType[2]})
            end
        else
            local cachedata = cache.PackCache:getPackDataById(self.data.mid)
            if cachedata.amount > 0 then
                local param = {}
                param.index = cachedata.index
                param.amount = 1
                proxy.PackProxy:sendUsePro(param)

                self:onCloseView()
            end
        end
    end
end
--丢弃时装按钮
function FashionTipsView:onClickDiscard()
    local function func()
        self:onCloseView()
    end
    mgr.ItemMgr:delete(self.data.index,func)
end

--放入按钮
function FashionTipsView:onClickPut()
    if mgr.ItemMgr:getPackIndex() == Pack.wareIndex then --仓库
        proxy.PackProxy:sendWareTake(self.data)
        self:closeView()
    end
end

function FashionTipsView:onCloseView()
    self:closeView()
end

return FashionTipsView