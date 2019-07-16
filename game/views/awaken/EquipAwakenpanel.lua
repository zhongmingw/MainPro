--
-- Author: 
-- Date: 2017-09-14 20:15:31
--

local EquipAwakenpanel = class("EquipAwakenpanel",import("game.base.Ref"))

function EquipAwakenpanel:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n9")
    self:initView()
end

function EquipAwakenpanel:initView()
    -- body
    self.left = self.view:GetChild("n0")
    self:initLeft()

    self.right = self.view:GetChild("n3")
    self:initright()
end

function EquipAwakenpanel:clear()
    -- body
    -- if self.model then
    --     self.parent:removeModel(self.model)
    --     self.model = nil 
    -- end

    --self._llevel.text = ""
    for k,v in pairs(self._lequiplist) do
        GSetItemData(v,{})
    end
    self._lisDownloadImg.visible = false

    self._rlistView.numItems = 0
    self._rlistpage.numItems = 0
end

function EquipAwakenpanel:initLeft()
    -- body
    self.left:GetChild("n43").visible = false
    self.left:GetChild("n44").visible = false

    self.name = self.view:GetChild("n5")
    self.iconjie = self.view:GetChild("n4")
    

    self._lequiplist = {}
    for i = 71 , 80 do
        local btn = self.left:GetChild("n"..i)
        table.insert(self._lequiplist,btn)
    end
    self._lisDownloadImg = self.left:GetChild("n85")

    self._lmodelpanel = self.left:GetChild("n0")
    self._leffectpanel = self.left:GetChild("n47")
end

function EquipAwakenpanel:initright()
    -- body
    local btnGet = self.right:GetChild("n19")
    btnGet.onClick:Add(self.onGetWay,self)

    self._rlistView = self.right:GetChild("n31")
    self._rlistView:SetVirtual()
    self._rlistView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self._rlistView.numItems = 0


    self._rlistpage = self.right:GetChild("n32")
    self._rlistpage:SetVirtual()
    self._rlistpage.itemRenderer = function(index,obj)
        self:cellPagedata(index, obj)
    end
    self._rlistpage.numItems = 0
    self._rlistpage.onClickItem:Add(self.onPageCallBack,self)
end



--装备信息
function EquipAwakenpanel:celldata(index, obj)
    -- body
    local start = (index)*16+1
    local _16data = {} ----16个格子数据
    for i = start, start + 16 do
        if not self.rightdata[i] then
            break
        end
        table.insert(_16data,self.rightdata[i])
    end

    for i = 1 , 16 do
        local btn = obj:GetChild("n"..i)
        local itemObj = btn:GetChild("n5")
        local _t = {}
        if not _16data[i] then
            _t = {}
        else
            _t = {mid = _16data[i].mid,amount = _16data[i].amount,bind =_16data[i].bind,index = _16data[i].index}
        end
        GSetItemData(itemObj,_t,true)
    end
end
--页数信息
function EquipAwakenpanel:cellPagedata(index, obj)
    -- body
    obj.data = index
end
function EquipAwakenpanel:onPageCallBack(context)
    -- body
    local data = context.data.data
    if data < self._rlistView.numItems then
        self._rlistView:ScrollToView(data,false)
    end
end

function EquipAwakenpanel:initModel()
    -- body
    self.jsLevel = cache.PlayerCache:getRedPointById(10205) --剑神等级
    self.attrData = conf.AwakenConf:getJsAttr(self.jsLevel)

    local curModelId = self.attrData and self.attrData.starlv or 1 --阶
    self.iconjie.url = UIItemRes.jieshu[curModelId]
    self.name.text = conf.AwakenConf:getName(curModelId)

    local buffId = conf.AwakenConf:getBuffId(curModelId)
    local buffData = conf.BuffConf:getBuffConf(buffId)
    local model = buffData.bs_args
    local cansee = false
    if not self.model or self.model:isDispose() then
        self.model = self.parent:addModel(model[1],self._lmodelpanel)
        cansee = self.model:setSkins(nil,model[2],model[3])
    else
        cansee = self.model:setSkins(model[1],model[2],model[3])
    end
    --self._lmodelpanel
    self.model:setPosition(self._lmodelpanel.actualWidth/2,-self._lmodelpanel.actualHeight-200,500)
    self.model:setScale(150)
    local sex = cache.PlayerCache:getSex()
    local angle = RoleSexModel[sex].angle
    self.model:setRotation(angle)

    local effect = self.parent:addEffect(4020102,self._leffectpanel)
    effect.LocalPosition = Vector3(self._leffectpanel.actualWidth/2,-self._leffectpanel.actualHeight,500)

    self._lisDownloadImg.visible = cansee
end

function EquipAwakenpanel:setData()
    -- body
    --已经穿戴
    self:setEquipData()
    self:setPackData()
end

function EquipAwakenpanel:setEquipData()
    -- body
    for k,v in pairs(self._lequiplist) do
        v.data = nil 
        GSetItemData(v,{})
    end
    self.lefdata = cache.PackCache:getAwakenEquipData()
    for k ,v in pairs(self.lefdata) do --K -- index,v -- data
        local part = conf.ItemConf:getPart(v.mid)
        
        if self._lequiplist[part] then
            GSetItemData(self._lequiplist[part],v,true) 
        end
    end
end

function EquipAwakenpanel:setPackData()
    -- body
    --背包
    self.rightdata = cache.PackCache:getPackAwakenEquipData()
    self.maxPage = math.ceil( #self.rightdata / 16 )
    self.maxPage = math.max(1,self.maxPage)
    self._rlistpage.numItems = self.maxPage
    self._rlistView.numItems = self.maxPage
end

--获取途径
function EquipAwakenpanel:onGetWay()
    -- body
end

function EquipAwakenpanel:addMsgCallBack(data)
    -- body
    if data.msgId == 5040403 then --丢弃之后刷新背包数据
        self:setPackData()
    elseif data.msgId == 5190201 then --穿脱
        self:setEquipData()
        self:setPackData()
    end
end

return EquipAwakenpanel