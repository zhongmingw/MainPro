--
-- Author: 
-- Date: 2018-09-05 19:27:50
--

local Yx1002 = class("Yx1002",import("game.base.Ref"))

function Yx1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Yx1002:initView()
    -- body
    self.confdata = conf.YouXunConf:getYzVipDayGift()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.id < b.id 
    end)
    self.ewai = table.remove(self.confdata,#self.confdata)

    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView.numItems = #self.confdata
    --self.listView.onClickItem:Add(self.onCallBack,self)


    self.listewaiView = self.view:GetChild("n4")
    self.listewaiView.itemRenderer = function(index,obj)
        local info = self.ewai.item[index+1]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3] or 0
        GSetItemData(obj, t, true)
    end
    self.listewaiView.numItems = #self.ewai.item

    self.btnget = self.view:GetChild("n5")
    self.btnget.data = self.ewai
    self.btnget.title = ""
    self.btnget.onClick:Add(self.onBtnCallBack,self)

    self.labtitle = self.view:GetChild("n13")
    self.labtitle.text = language.yx04

    self.btn = self.view:GetChild("n8")
    self.btn.title = language.yx02
    self.btn.onClick:Add(self.onBtnCallBack,self)

    local dec = self.view:GetChild("n2")
    
    local dec1 = self.view:GetChild("n10")
    dec1.text = language.yx06
    local titleImg = self.view:GetChild("n0"):GetChild("n1")
    local tqType = conf.YouXunConf:getTeQuanType()
    if tqType == 3 then
        dec.text = language.yx05_0
        titleImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_039")
    else
        dec.text = language.yx05
        titleImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_036")
    end
end

function Yx1002:cellBaseData( index, obj )
    -- body
    local data = self.confdata[index + 1]
    local lab = obj:GetChild("n1")
    lab.text = string.format(language.yx03,data.yx_vip_lev)

    local listview = obj:GetChild("n2")
    listview.itemRenderer = function(_index,_obj)
        local info = data.item[_index + 1 ]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3] or 0
        GSetItemData(_obj, t, true)
    end
    listview.numItems = #data.item

    local btn = obj:GetChild("n3")
    btn.title = ""
    btn.data = data 
    btn.onClick:Add(self.onCallBack,self)

     local red = btn:GetChild("red")
    red.visible = false

    local labtitle = obj:GetChild("n4")
    labtitle.text = language.yx04

    local c1 = obj:GetController("c1")
    c1.selectedIndex = 1
    if self.data then
        if self.data.vipGotSigns[data.id] then
            --labtitle.text = language.yx14
            c1.selectedIndex =  2
        else
            if self.data.yxVipLev >= data.yx_vip_lev and self.data.yz > 0 then
                c1.selectedIndex = 0

                self.rednum = self.rednum + 1
                red.visible = true
            end
        end
    end
end

function Yx1002:onCallBack( context )
    -- body
    local btn = context.sender
    local data = btn.data 
    if not self.data then
        return
    end
    if self.data.vipGotSigns[data.id] then
        GComAlter(language.yx14)
        return
    end
    if self.data.yz <= 0 then
        GComAlter(language.yx17)
        return
    end
    if self.data.yxVipLev < data.yx_vip_lev then
        GComAlter(language.yx16)
        return
    end
    local param = {}
    param.reqType = 1
    param.cfgId = data.id 
    proxy.YouXunProxy:sendMsg(1030602,param)
end

function Yx1002:onBtnCallBack( context )
    -- body
    local btn = context.sender
    local data = btn.data 
    if not self.data then
        return
    end
    if "n5" == btn.name then
        if self.data.extGotSign >= 1 then
            return
        end
        if self.data.yz ~= 3 then
            return GComAlter(language.yx13[1003])
        end
        local param = {}
        param.reqType = 2
        param.cfgId = data.id 
        proxy.YouXunProxy:sendMsg(1030602,param)
    elseif "n8" ==  btn.name then
        self.parent:onOpenVip()
    end
end

function Yx1002:onTimer()
    -- body
end

function Yx1002:addMsgCallBack(data)
    -- body
    if data.msgId == 5030602 then
        self.rednum = 0

        GOpenAlert3(data.items)
        --printt("self.data.extGotSign",data)
        self.data = data 
        self.btn.visible = self.data.yz <= 0
        --self.btnget.visible = self.data.extGotSign ~= 1
        self.btnget.grayed = self.data.yz ~= 3
        self.btnget:GetChild("red").visible = (self.data.extGotSign ~= 1 and self.data.yz == 3)
        self.btnget.visible = self.data.extGotSign ~= 1
        self.view:GetChild("n12").visible = not self.btnget.visible
        self.labtitle.visible = self.btnget.visible


        table.sort(self.confdata,function(a,b)
            -- body
            local a_isget = self.data.vipGotSigns[a.id] or 0
            local b_isget = self.data.vipGotSigns[b.id] or 0
            if a_isget == b_isget then
                return a.id < b.id 
            else
                return a_isget < b_isget
            end
        end)
        self.listView.numItems = #self.confdata

        
        if self.data.extGotSign ~= 1 and self.data.yz == 3 then
            self.rednum = self.rednum + 1

        end
        mgr.GuiMgr:redpointByVar(30202,self.rednum,1)
    end
end

return Yx1002