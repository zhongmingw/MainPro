--
-- Author: 
-- Date: 2018-08-02 10:33:44
--

local KaiFuLeiji = class("KaiFuLeiji", base.BaseView)

function KaiFuLeiji:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function KaiFuLeiji:initView()
    local btnclose = self.view:GetChild("n24")
    self:setCloseBtn(btnclose)
    self.modelpanel = self.view:GetChild("n27"):GetChild("n0")
    self.t0 = self.view:GetChild("n27"):GetTransition("t0")

    self.itemObj = self.view:GetChild("n23")
    self.chargeTxt = self.view:GetChild("n30")
    self.icon2 = self.view:GetChild("n17")
    self.icon3 = self.view:GetChild("n18")

    self.icon = self.view:GetChild("n27"):GetChild("n2")

    self.listpage = self.view:GetChild("n12")
    self.listpage.numItems = 0
    self.listpage.itemRenderer = function (index,obj)
        --self:celldata(index, obj)
        obj.data = index + 1
    end
    self.listpage.onClickItem:Add(self.onCallBack,self) 
    --self.listpage:SetVirtual()

    self.listpro = self.view:GetChild("n21")
    self.listpro.numItems = 0
    self.listpro.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listpro:SetVirtual()

    local btnsee = self.view:GetChild("n4")
    btnsee.onClick:Add(self.onSee,self)

    self.btnleft = self.view:GetChild("n7")
    self.btnleft.data = - 1
    self.btnleft.onClick:Add(self.onMove,self)

    self.btnRight = self.view:GetChild("n6")
    self.btnRight.data = 1
    self.btnRight.onClick:Add(self.onMove,self)

    self.panel = self.view:GetChild("n29")

    --
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onControlChange,self)
end

function KaiFuLeiji:onControlChange()
    if self.c1.selectedIndex == 0 then
        self.confdata = conf.ActivityConf:getKaifudbrk()        
    elseif self.c1.selectedIndex == 1 then
        self.confdata = conf.ActivityConf:getKaifulcrk()
    end
    table.sort(self.confdata,function(a,b)
        -- body
        return a.money < b.money
    end)
    self:setData()
    if self.c1.selectedIndex == 1 then 
        proxy.ActivityProxy:sendMsg(1030184, {reqType = 0,awardId = 0,actId = 1076})
    end
end

function KaiFuLeiji:initData(data)
    -- body
    if self.c1.selectedIndex ~= 0 then
        self.c1.selectedIndex = 0
    else
        self:onControlChange()
    end

    self.mindModel = nil 

    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil 
    end

    self.effect =  self:addEffect(4020137,self.panel)
    self.effect.LocalPosition = Vector3(50.16,-73.8,0)
end

function KaiFuLeiji:setData()
    -- body
    self.max = #self.confdata
    self.listpage.numItems = self.max
    self.listpage:AddSelection(0,false)
    self:setMsg(1)
end

function KaiFuLeiji:celldata( index, obj )
    -- body
    local data = self.showdata.prolsit[index+1]
    local lab = obj:GetChild("n0")
    lab.text = conf.RedPointConf:getProName(data[1])..": "..mgr.TextMgr:getTextColorStr(GProPrecnt(data[1],data[2]),7) 
end

function KaiFuLeiji:initModel()
    -- body
     --移除特效
    self:removeUIEffect(self.effectModel)
    self.effectModel = nil 
	--移除带有人物展示的特效
	if self.effectModel2 then
		self:removeModel(self.effectModel2)
		self.effectModel2 = nil
	end
    --资源类型
    --print("self.showdata.dongzuo",self.showdata.dongzuo)
    if self.showdata.dongzuo and self.showdata.dongzuo == 1 then
        self.t0:Play()
    else
        self.t0:Stop()
    end

    self.icon.url = nil 
    self.modelId = self.showdata.model_id
    if cache.PlayerCache:getSex() == 2 then
        self.modelId = self.showdata.model_id_nv
    end
    --print("self.modelId",self.modelId)
    self.panel.visible = true
    if self.showdata["res_type"] == 1 then
        if self.modelId == 3030416 then--仙羽特殊处理
            self.mindModel = self:addModel(GuDingmodel[1],self.modelpanel)
            self.mindModel:setSkins(nil,nil,self.modelId)
        else
            self.mindModel = self:addModel(self.modelId,self.modelpanel)
            self.mindModel:setSkins(self.modelId)
        end

        if self.showdata.scale then
            self.mindModel:setScale(self.showdata.scale)
        end
        if self.showdata["rz"] then
            self.mindModel:setRotationXYZ(self.showdata["rz"][1],self.showdata["rz"][2],self.showdata["rz"][3])
        end

        self.mindModel:setPosition(self.showdata["pos"][1], self.showdata["pos"][2],self.showdata["pos"][3]) 
    elseif self.showdata["res_type"] == 2 then
        if self.mindModel then
            self:removeModel(self.mindModel)
            self.mindModel = nil
        end
        local useid =  cache.PlayerCache:getSkins(Skins.clothes)
        if useid == 0 then
            useid = GuDingmodel[1]
        end
        if self.modelId == 4041108 then--光环
            self.panel.visible = false
            self.effectModel2 = self:addModel(useid, self.modelpanel) 
            local effect = self.effectModel2:addModelEct( self.modelId.."_ui")
            effect.Scale = Vector3.New(0.35,0.35,0.35)

            self.effectModel2:setScale(self.showdata.scale)
            self.effectModel2:setPosition(self.showdata["pos"][1], self.showdata["pos"][2],self.showdata["pos"][3])
            self.effectModel2:setRotationXYZ(self.showdata["rz"][1],self.showdata["rz"][2],self.showdata["rz"][3])
        elseif self.modelId == 4041201 then--风车
            self.effectModel2 = self:addModel(useid, self.modelpanel) 
            self.effectModel2:addHeadEct(4041201)
            self.effectModel2:setScale(self.showdata.scale)
            self.effectModel2:setPosition(self.showdata["pos"][1], self.showdata["pos"][2],self.showdata["pos"][3])
            self.effectModel2:setRotationXYZ(self.showdata["rz"][1],self.showdata["rz"][2],self.showdata["rz"][3])
        else
            self.effectModel = self:addEffect(self.modelId, self.modelpanel)
            self.effectModel.LocalPosition = Vector3.New(self.showdata["pos"][1], self.showdata["pos"][2],self.showdata["pos"][3])
            if self.showdata.scale then
                self.effectModel.Scale = Vector3.New(self.showdata.scale,self.showdata.scale,self.showdata.scale)
            end
        end
    elseif self.showdata["res_type"] == 3 then
        --图片
        if self.mindModel then
            self:removeModel(self.mindModel)
            self.mindModel = nil
        end
        self.icon.url = UIPackage.GetItemURL("kaifuleiji" , self.modelId)
    elseif self.showdata["res_type"] == 4 then--剑神
        local buffData = conf.BuffConf:getBuffConf(self.modelId)
        local modelData = buffData.bs_args
        self.mindModel = self:addModel(modelData[1],self.modelpanel)

        self.mindModel:setSkins(modelData[1],modelData[2],modelData[3])

        if self.showdata.scale then
            self.mindModel:setScale(self.showdata.scale)
        end
        if self.showdata["rz"] then
            self.mindModel:setRotationXYZ(self.showdata["rz"][1],self.showdata["rz"][2],self.showdata["rz"][3])
        end
        self.mindModel:setPosition(self.showdata["pos"][1], self.showdata["pos"][2],self.showdata["pos"][3])
    elseif self.showdata["res_type"] == 5 then--头饰
        local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
        self.mindModel = self:addModel(skins1,self.modelpanel)
        self.mindModel:addHeadEct(self.modelId)
        if self.showdata.scale then
            self.mindModel:setScale(self.showdata.scale)
        end
        if self.showdata["rz"] then
            self.mindModel:setRotationXYZ(self.showdata["rz"][1],self.showdata["rz"][2],self.showdata["rz"][3])
        end
        self.mindModel:setPosition(self.showdata["pos"][1], self.showdata["pos"][2],self.showdata["pos"][3]) 
    end
end

function KaiFuLeiji:onCallBack(context)
    local index = context.data.data 
    --print(index,"index")
    self:setMsg(index)
end

function KaiFuLeiji:onSee()
    -- body
    if self.c1.selectedIndex == 0 then
        local param = {id = 1028,index = 1077}
        GOpenView(param)
    elseif self.c1.selectedIndex == 1 then
        local param = {id = 1028,index = 1076}
        GOpenView(param)
    end
end

function KaiFuLeiji:setMsg( index )
    -- body
    self.index = index
    local confdata = self.confdata[index]
    self.showdata = confdata
    self.chargeTxt.text = confdata.money

    self.icon2.url = UIPackage.GetItemURL("kaifuleiji" , confdata.icon2)
    self.icon3.url = UIPackage.GetItemURL("kaifuleiji" , confdata.icon3)

    local item = confdata.itemmid
    if cache.PlayerCache:getSex() == 2 then
        item = confdata.itemmid_nv
    end
    if item then
        local t = {}
        t.mid = item[1]
        t.amount = item[2]
        t.bind = item[3]
        GSetItemData(self.itemObj, t,true)
    else
        GSetItemData(self.itemObj, {})
    end

  
    if self.showdata.prolsit then
        self.listpro.numItems = #self.showdata.prolsit
    else
        self.listpro.numItems = 0
    end

    self:initModel()


    self.btnleft.visible = true
    self.btnRight.visible = true
    if self.index == 1 then
        self.btnleft.visible = false
    elseif self.index == self.max then
        self.btnRight.visible = false
    end
end

function KaiFuLeiji:onMove( context )
    -- body
    local data = context.sender.data 
    
    local index = self.index or 0
    index = index + data
    
    self.index = math.max(1,index)
    self.index = math.min(self.index,self.max)
    --print(index,self.index)
    self.listpage:AddSelection(self.index-1,false)
    self:setMsg(self.index)
end

function KaiFuLeiji:addMsgCallBack(data)
    -- body
    if data.msgId == 5030184 then
        self.data = data 
        local number = #self.confdata
        for k ,v in pairs(self.confdata) do
            if data.czYB<v.money then
                number = k 
                break
            end
        end
        
        self.listpage:AddSelection(number-1,false)
        self:setMsg(number)
    end
end

function KaiFuLeiji:dispose(clear)
    if self.effectModel then
        self:removeUIEffect(self.effectModel)
        self.effectModel = nil 
    end
    --移除带有人物展示的特效
    if self.effectModel2 then
        self:removeModel(self.effectModel2)
        self.effectModel2 = nil
    end
    if self.mindModel then
        self:removeModel(self.mindModel)
        self.mindModel = nil
    end
    self.super.dispose(self,clear)
end

return KaiFuLeiji