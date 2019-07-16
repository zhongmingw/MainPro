--
-- Author: Your Name
-- Date: 2017-11-25 16:43:22
--

local GetMarriedView = class("GetMarriedView", base.BaseView)

function GetMarriedView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function GetMarriedView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self.view:GetChild("n0"):GetChild("n6").visible = true
    self:setCloseBtn(closeBtn)

    for i=1,6 do
        local btn = self.view:GetChild("n"..i)
        btn.data = i
        btn.onClick:Add(self.onClickGo,self)
    end
end

function GetMarriedView:onClickGo(context)
    local index = context.sender.data
    local coupleName = cache.PlayerCache:getCoupleName()
    if index == 1 then--求婚
        mgr.ViewMgr:openView2(ViewName.MarryApplyView)
    elseif index == 2 then--缔结姻缘
        if coupleName and coupleName ~= "" then
            proxy.MarryProxy:sendMsg(1390305,nil,1)
        else
            GComAlter(language.marryiage32)
        end
    elseif index == 3 then--预约界面
        if coupleName and coupleName ~= "" then
            proxy.MarryProxy:sendMsg(1390302,{reqType = 0})
        else
            GComAlter(language.marryiage32)
        end
    elseif index == 4 then--邀请宾客
        if coupleName and coupleName ~= "" then
            proxy.MarryProxy:sendMsg(1390303,{reqType = 1})
        else
            GComAlter(language.marryiage32)
        end
    elseif index == 5 then--喜宴举办
        proxy.MarryProxy:sendMsg(1390306,{reqType = 0})
    elseif index == 6 then--眷侣查看
        if coupleName and coupleName ~= "" then
            proxy.MarryProxy:sendMsg(1390305,nil,5)
        else
            GComAlter(language.marryiage32)
        end
    end
end

function GetMarriedView:setData(data)

end

return GetMarriedView