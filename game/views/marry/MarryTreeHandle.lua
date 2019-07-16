--
-- Author: 
-- Date: 2017-08-15 14:51:50
--

local MarryTreeHandle = class("MarryTreeHandle", base.BaseView)

function MarryTreeHandle:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function MarryTreeHandle:initView()
    local close = self.view:GetChild("n5")
    close.onClick:Add(self.onClickClose,self)
    close.onTouchBegin:Add(self.onTouchBegin,self)
    close.onTouchEnd:Add(self.onTouchEnd,self)
    local info = self.view:GetChild("n0")
    info.onClick:Add(self.onClickInfo,self)

    self.treeBtnList = {}

    local waterBtn = self.view:GetChild("n1")
    waterBtn.onClick:Add(self.onClickWater,self)
    table.insert(self.treeBtnList, waterBtn)

    local insectBtn = self.view:GetChild("n2")
    insectBtn.onClick:Add(self.onClickInsect,self)
    table.insert(self.treeBtnList, insectBtn)

    local ripperBtn = self.view:GetChild("n3")
    ripperBtn.onClick:Add(self.onClickRipper,self)
    table.insert(self.treeBtnList, ripperBtn)

    local getBtn = self.view:GetChild("n4")
    getBtn.onClick:Add(self.onClickGet,self)
    table.insert(self.treeBtnList, getBtn)
end

function MarryTreeHandle:initData(data)
    self.treeData = data
    if not self.treeTimer then
        self:onTimer()
        self.treeTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
function MarryTreeHandle:onTimer()
    if self.treeData then
        local tree = mgr.ThingMgr:getObj(ThingType.monster, self.treeData.roleId)
        if tree then
            local treeStep = tree:getTreeStep()
            for k,v in pairs(self.treeBtnList) do
                if k == treeStep then
                    v.enabled = true
                else
                    v.enabled = false
                end
            end
        end
    end
end

function MarryTreeHandle:onClickInfo()
    self:sendMsg(0)
end
 --1:浇水 2:除虫 3:松土 4:收货
function MarryTreeHandle:onClickWater()
    self:sendMsg(1)
end

function MarryTreeHandle:onClickInsect()
    self:sendMsg(2)
end

function MarryTreeHandle:onClickRipper()
    self:sendMsg(3)
end

function MarryTreeHandle:onClickGet()
    self:sendMsg(4)
end

function MarryTreeHandle:sendMsg(optType)
    if self.treeData then
        -- plog(1810303,self.treeData.roleId,optType)
        proxy.MarryProxy:send(1810303,{treeId = self.treeData.roleId,optType = optType})
    end
end

function MarryTreeHandle:onTouchBegin()
    self:onClickClose()
end

function MarryTreeHandle:onTouchMove()
    -- self:onClickClose()
end

function MarryTreeHandle:onTouchEnd()
    -- Stage.inst.onTouchMove:Remove(self.onTouchMove,self)
end

function MarryTreeHandle:onClickClose()
    if self.treeTimer then
        self:removeTimer(self.treeTimer)
        self.treeTimer = nil
    end
    self:closeView()
end

return MarryTreeHandle