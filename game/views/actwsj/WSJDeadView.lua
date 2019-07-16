--
-- Author: 
-- Date: 2018-10-24 16:39:59
--

local WSJDeadView = class("WSJDeadView", base.BaseView)

function WSJDeadView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function WSJDeadView:initView()
    self.view:GetChild("n0"):GetChild("n2").visible = false
    -- self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.label = self.view:GetChild("n1")
    --普通复活
    local btn1 = self.view:GetChild("n8")
    btn1.onClick:Add(self.onClickRevive1, self)
    --原地复活
    local btn2 = self.view:GetChild("n9")
    btn2.onClick:Add(self.onClickRevive2, self)
    self.time = self.view:GetChild("n10")   

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0 
    self.listView.onClickItem:Add(self.onCallGoto,self)

end

function WSJDeadView:initData(data)
    self.data = data
    local name = data.atkName
    local textData = {
        {text= "您已被",color = 8},
        {text=name,color = 14},
        {text=language.fuben09,color = 8},
    }
    self.label.text = mgr.TextMgr:getTextByTable(textData)
    local costYb = conf.SysConf:getValue("cur_revive_cost")
    self.view:GetChild("n5").text = costYb
    self:addTimer(1, -1, handler(self,handler(self,self.onTimer)))
    local reviveSec = conf.WSJConf:getValue("revive_time")
    self.overTime = reviveSec
    self.time.text = string.format(language.wsj15,self.overTime)

    self.confIcon = conf.WSJConf:getValue("dead_up_icon")
    self.confModelId = conf.WSJConf:getValue("dead_up_modelid")
    self.listView.numItems = #self.confIcon

end

function WSJDeadView:onTimer()
    -- body
    if self.overTime <= 0 then
        self:onClickRevive1()
        return
    end
    self.overTime = self.overTime - 1
    self.time.text = string.format(language.wsj15,self.overTime)
end

function WSJDeadView:cellData(index,obj)
    local iconData = self.confIcon[index+1]
    local modelData = self.confModelId[index+1]
    if iconData and modelData then
        obj.icon = UIPackage.GetItemURL("_icons2" , tostring(iconData))
        obj.data = modelData
    end
end

--跳转到对应系统
function WSJDeadView:onCallGoto(context)
    local formView = context.data.data
    GOpenView({id = formView[1], childIndex = formView[2]})
end


function WSJDeadView:onClickRevive1()
    proxy.ThingProxy:sRevive(3)
end
function WSJDeadView:onClickRevive2()
    proxy.ThingProxy:sRevive(2)
end

return WSJDeadView