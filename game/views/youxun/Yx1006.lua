--
-- Author: 
-- Date: 2018-09-05 20:11:03
--

local Yx1006 = class("Yx1006",import("game.base.Ref"))

function Yx1006:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Yx1006:onTimer()
    -- body
end

function Yx1006:initView()
    -- body
    local dec1 = self.view:GetChild("n3"):GetChild("n1")
    dec1.text = language.yx10

    local dec2 = self.view:GetChild("n4"):GetChild("n1")
    dec2.text = language.yx11

    local dec3 = self.view:GetChild("n5"):GetChild("n1")
    dec3.text = language.yx22

    self.confdata = conf.YouXunConf:getValue("mobile_gift")
    self.listewaiView = self.view:GetChild("n6")
    self.listewaiView.itemRenderer = function(index,obj)
        local info = self.confdata[index+1]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3] or 0
        GSetItemData(obj, t, true)
    end
    self.listewaiView.numItems = #self.confdata

    self.btn = self.view:GetChild("n7")
    self.btn.title = ""--language.yx12
    self.btn.onClick:Add(self.onBtnCallBack,self)

    self.labtitle = self.view:GetChild("n8")
    self.labtitle.text = language.yx12

    self.c1 = self.view:GetController("c1")
end

function Yx1006:onBtnCallBack( context )
    -- body
    if not self.data then return end
    if self.data.mobile == 1 then
        if self.data.gotSign == 1 then
            GComAlter(language.yx14)
        else
            local param = {}
            param.reqType = 1
            proxy.YouXunProxy:sendMsg(1030606,param)
        end
    else
        self.parent:onOpenPhone()
    end
end

function Yx1006:addMsgCallBack(data)
    -- body
    if data.msgId == 5030606 then
        self.rednum = 0
        GOpenAlert3(data.items)
        self.data = data 

        self.btn:GetChild("red").visible = false
        if self.data.mobile == 1 then
            self.labtitle.text = language.yx04
            if self.data.gotSign == 1 then
                self.c1.selectedIndex = 2

                self.rednum = 999
            else
                self.c1.selectedIndex = 1
                self.rednum = 1
                self.btn:GetChild("red").visible = true
            end
        else
            self.c1.selectedIndex = 0
            self.labtitle.text = language.yx12
        end
        mgr.GuiMgr:redpointByVar(30206,self.rednum,1)
    end
end


return Yx1006