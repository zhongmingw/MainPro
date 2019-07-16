--
-- Author: 
-- Date: 2017-06-27 16:12:44
--

local KuaFuCreateTeam = class("KuaFuCreateTeam", base.BaseView)

function KuaFuCreateTeam:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function KuaFuCreateTeam:initData(data)
    -- body
    self.data = data
    self:setData()
end

function KuaFuCreateTeam:initView()
    local btnCreate = self.view:GetChild("n6")
    btnCreate.onClick:Add(self.onCreate,self)

    local btnClose = self.view:GetChild("n1"):GetChild("n2") 
    btnClose.onClick:Add(self.onBtnClose,self)

    self.radio1 = self.view:GetChild("n7")
    self.radio1.onClick:Add(self.onAutoStart,self)

    self.radio2 = self.view:GetChild("n8")

    self.checkBox = self.view:GetChild("n9")



    self.inputtext = self.view:GetChild("n11")

    self.view:GetChild("n6").text = language.kuafu06
    self.view:GetChild("n3").text = language.kuafu07
    self.view:GetChild("n4").text = language.kuafu08
    self.view:GetChild("n5").text = language.kuafu09

    --屏蔽
    self.radio2.visible = false
    self.view:GetChild("n5").visible = false
    self.inputtext.visible = false
    self.view:GetChild("n10").visible = false
end

function KuaFuCreateTeam:setData(data_)
    --printt(self.data[3].maxAutoPlay)

    self.radio1.selected = (self.data[3].maxAutoPlay == 1)
    --self.radio2.selected = false
    --默认选择房间
    local _items = {}
    local _title = ""
    local _values = {}

    local selectedIndex = 0
    for k ,v in pairs(self.data[1]) do
        --等级检测
        if cache.PlayerCache:getRoleLevel()>= v.lvl then
            table.insert(_items,v.name)
            table.insert(_values,tostring(v.id) )
            if tonumber(v.id) == tonumber(self.data[2]) then
                selectedIndex = k - 1
            end
        end
    end
    --plog("selectedIndex",selectedIndex)

    self.checkBox.items = _items
    self.checkBox.values = _values

    self.checkBox.selectedIndex = selectedIndex
    --self.checkBox.title = _title
end
--创建队伍
function KuaFuCreateTeam:onCreate()
    -- body
    local param = {}
    param.reqType = 1
    if self.radio2.selected  and self.inputtext.text~="" then
        param.password = self.inputtext.text
    end
    param.teamId = 0
    param.sceneId = tonumber(self.checkBox.value) 
    --printt("self.checkBox.value",param)
    proxy.KuaFuProxy:sendMsg(1380102,param)
    self:onBtnClose()
end

function KuaFuCreateTeam:onAutoStart()
    -- body
    local param = {}
    param.reqType = 3
    proxy.KuaFuProxy:sendMsg(1380103,param)
end

function KuaFuCreateTeam:onBtnClose()
    -- body
    self:closeView()
end

return KuaFuCreateTeam