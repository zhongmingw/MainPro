--
-- Author: ohf
-- Date: 2017-02-24 10:50:51
--
--影卫星星弹窗
local KageeTipsView2 = class("KageeTipsView2", base.BaseView)

function KageeTipsView2:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.uiClear = UICacheType.cacheTime
    self.isBlack = true
end

function KageeTipsView2:initView()
    self.panelObj1 = self.view:GetChild("n10")
    self.panelObj2 = self.view:GetChild("n16")
    self.blackView.onClick:Add(self.onClickClose,self)
end
--data = {pos = 位置,data = {mId = 影卫id,jhValue = 是否点亮,starlv = 影卫总级别,index = index}}
function KageeTipsView2:setData(data)
    self.panelObj1.visible = false
    self.panelObj2.visible = false
    self.mData = data.data
    local pos = data.pos
    self.name = conf.KageeConf:getYwLimitById(self.mData.mId).name
    self.starlv = GGetStarLev2(self.mData.starlv)[2]
    if self.mData.jhValue <= 0 then
        self.panelObj1.visible = true
        -- self.panelObj1.x = pos.x
        -- self.panelObj1.y = pos.y
        self:initPanel1()
    else
        self.panelObj2.visible = true
        -- self.panelObj2.x = pos.x
        -- self.panelObj2.y = pos.y
        self:initPanel2()
    end
end
--未激活面板
function KageeTipsView2:initPanel1()
    local nameText = self.view:GetChild("n2")
    nameText.text = string.format(language.kagee24, self.name,self.mData.index)
    local attiList = {}
    table.insert(attiList, self.view:GetChild("n4"))
    table.insert(attiList, self.view:GetChild("n17"))
    self:setAttiData(attiList)
    local lightText = self.view:GetChild("n3")--未点亮
    lightText.text = language.kagee22
    local desc1 = self.view:GetChild("n8")
    desc1.text = language.kagee20
    local desc2 = self.view:GetChild("n9")
    local curAttData = conf.KageeConf:getUpattr(self.mData.mId,self.mData.starlv)
    local lv = curAttData and curAttData.lvl or 0
    desc2.text = string.format(language.kagee21, lv)
end
--已激活面板
function KageeTipsView2:initPanel2()
    local nameText = self.view:GetChild("n13")
    nameText.text = string.format(language.kagee24, self.name,self.mData.index)
    local attiList = {}
    table.insert(attiList, self.view:GetChild("n15"))
    table.insert(attiList, self.view:GetChild("n18"))
    self:setAttiData(attiList)
    local lightText = self.view:GetChild("n14")--已点亮
    lightText.text = language.kagee23
end

function KageeTipsView2:setAttiData(attiList)
    local curAttData = conf.KageeConf:getUpattr(self.mData.mId,self.mData.starlv)
    if curAttData then
        local t = GConfDataSort(curAttData)
        for k,v in pairs(t) do
            attiList[k].text = conf.RedPointConf:getProName(v[1])..GProPrecnt(v[1],v[2])
        end
    end--属性
end

function KageeTipsView2:onClickClose()
    self:closeView()
end

return KageeTipsView2