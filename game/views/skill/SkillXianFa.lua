--
-- Author: 
-- Date: 2017-12-12 14:19:17
--

local SkillXianFa = class("SkillXianFa",import("game.base.Ref"))

function SkillXianFa:ctor(param)
    self.parent = param
    self.view = param.view:GetChild("n47")
    self:initView()
    self:initData()
end

function SkillXianFa:initData()
    -- body
    self.confdata = conf.SkillConf:getSkillXianFa()

    self:initData2()
end

--EVE 这个类每次打开就调用一次
function SkillXianFa:initData2()
     self.powerText.text = math.floor(self.confdata[1].power/10*1.1)
end 

function SkillXianFa:initView()
    -- body
    self.listView = self.view:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onUIClickCall,self)

    self.icon = self.view:GetChild("n4") 
    self.name = self.view:GetChild("n9")
    self.desc = self.view:GetChild("n12")

    self.powerText = self.view:GetChild("n14") --EVE 仙法技能战斗力显示
end

function SkillXianFa:celldata(index, obj)
    -- body
    local data = self.confdata[index+1]

    local icon = obj:GetChild("n6")
    icon.url =  ResPath.iconRes(data.icon)

    local labname = obj:GetChild("n4")
    labname.text = data.name

    local lablevel = obj:GetChild("n5")
    lablevel.text = data.desc

    local lock = obj:GetChild("n8")

    if self.data[data.id] then
        lock.visible = false
        lablevel.text = ""
        labname.y = 32
    else
        lock.visible = true
        labname.y = 14
    end

    obj.data = data
end

function SkillXianFa:onUIClickCall(context)
    -- body
    local data = context.data.data

    self.powerText.text = math.floor(data.power/10*1.1) --EVE

    self._curdata = data
    self:setSelectData()
end

function SkillXianFa:setData(data)
    -- body
    self.data = {}
    for k ,v in pairs(data) do
        self.data[v.skillId] = v.skillLevel
    end

    self.listView.numItems = #self.confdata
    self.listView:AddSelection(0,false)
    self._curdata =self.confdata[1]
    self:setSelectData()
end

function SkillXianFa:setSelectData()
    -- body
    local level = 1
    if self.data[self._curdata.id] then
        level = self.data[self._curdata.id]
    end
    self.icon.url = ResPath.iconRes(self._curdata.icon)
    self.name.text = self._curdata.name

    local affectData = conf.SkillConf:getSkillByIdAndLevel(self._curdata.id,level)
    if affectData then
        self.desc.text = affectData.dec or ""
    else
        self.desc.text = ""
    end
end


return SkillXianFa