--
-- Author: 
-- Date: 2018-06-29 21:11:00
--

local GetProView = class("GetProView", base.BaseView)

function GetProView:ctor()
    GetProView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale

end

function GetProView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n4")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
end
function GetProView:initData()
    self.modelData = conf.ActivityConf:getHolidayGlobal("get_flower_modelId")
    -- printt(self.modelData)
    self.listView.numItems = #self.modelData
end

function GetProView:cellData(index,obj)
    local id = self.modelData[index + 1]
    local data = conf.SysConf:getModuleById(id[1])
    local lab = obj:GetChild("n1")
    lab.text = data.desc
    local btn = obj:GetChild("n0")
    btn.data = {data = data,id = id}
    btn.onClick:Add(self.onbtnGo,self)
end

function GetProView:onbtnGo(context)
    local data = context.sender.data.data
    local childIndex = context.sender.data.id[2]  or 0
    local param = {id = data.id,childIndex = childIndex }
    -- print("data.id",data.id)
    GOpenView(param)
end

return GetProView