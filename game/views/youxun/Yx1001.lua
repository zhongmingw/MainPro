--
-- Author: wx
-- Date: 2018-09-05 17:52:08
-- 悠钻礼包

local Yx1001 = class("Yx1001",import("game.base.Ref"))

function Yx1001:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Yx1001:initView()
    -- body
    self.confdata = conf.YouXunConf:getYzGigt()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.id < b.id 
    end)

    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView.numItems = #self.confdata
    if #self.confdata > 2 then
        self.listView.columnGap = 0
    else
        self.listView.columnGap = 75
    end
    --self.listView.onClickItem:Add(self.onCallBack,self)

    self.btn = self.view:GetChild("n2")
    self.btn.title = language.yx02
    self.btn.onClick:Add(self.onVip,self)

    local dec1 = self.view:GetChild("n3")
    dec1.text = language.yx06
    local titleImg = self.view:GetChild("n0"):GetChild("n1")
    local tqType = conf.YouXunConf:getTeQuanType()
    if tqType == 3 then
        titleImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_039")
    else
        titleImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_036")
    end
end

function Yx1001:onTimer()
    -- body
end

function Yx1001:cellBaseData(index, obj)
    -- body
    local data = self.confdata[index+1]
    local listview = obj:GetChild("n1")
    listview.itemRenderer = function(_index,_obj)
        local info = data.item[_index + 1 ]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3] or 0
        GSetItemData(_obj, t, true)
    end
    listview.numItems = #data.item

    local lab = obj:GetChild("n3")
    lab.text = string.format(language.yx01,data.desc)

    local btn = obj:GetChild("n2")
    btn.title = ""--language.yx04
    btn.data = data 
    btn.onClick:Add(self.onBtnCallBack,self)

    local red = btn:GetChild("red")
    red.visible = false

    obj:GetChild("n4").text = language.yx04

    local c1 = obj:GetController("c1")
    c1.selectedIndex = data.yz - 1

    local c2 = obj:GetController("c2")
    c2.selectedIndex = 1
    if self.data and self.data.yz > 0  then
        --检测是否过期
        if self.data.gotSigns[data.id] then
            local var = mgr.NetMgr:getServerTime() - self.data.gotSigns[data.id] 
            c2.selectedIndex = 1
            print("var",var/86400,data.got_cd,var < data.got_cd * 24 * 3600)
            if var < data.got_cd * 24 * 3600 then
                obj:GetChild("n4").text = language.yx14
                c2.selectedIndex = 2
            else
                if data.yz  <=  self.data.yz then
                    self.rednum = self.rednum + 1
                    red.visible = true
                    c2.selectedIndex = 0
                else
                    c2.selectedIndex = 1
                end
            end
        else
            if data.yz  <=  self.data.yz then
                self.rednum = self.rednum + 1
                red.visible = true
                c2.selectedIndex = 0
            else
                c2.selectedIndex = 1
            end
        end
    end
end

function Yx1001:onBtnCallBack( context )
    -- body
    local btn = context.sender
    local data = btn.data 
    if not self.data then
        return
    end

    if self.data.yz > 0 and self.data.gotSigns[data.id] then
        --检测是否过期
        local var = mgr.NetMgr:getServerTime() - self.data.gotSigns[data.id] 
        if var < data.got_cd * 24 * 3600 then
            return GComAlter(language.yx14)
        end
    end
    local param = {}
    param.reqType = 1
    param.cfgId = data.id 
    if self.data.yz  >= data.yz then
        proxy.YouXunProxy:sendMsg(1030601,param)
    else
        GComAlter(language.yx13[data.id])
    end
end

function Yx1001:onVip( ... )
    -- body
    self.parent:onOpenVip()
end

function Yx1001:addMsgCallBack(data)
    -- body
    if data.msgId == 5030601 then
        self.rednum = 0

        printt("data",data)

        GOpenAlert3(data.items)

        self.data = data 
        self.btn.visible = self.data.yz <= 0

        -- table.sort(self.confdata,function( a,b )
        --     -- body
        --     local a_isget = 1
        --     if self.data.gotSigns[a.id] then
        --         --检测是否过期
        --         local var = mgr.NetMgr:getServerTime() - self.data.gotSigns[a.id] 
        --         if var < a.got_cd * 24 * 3600 then
        --             a_isget = 2
        --         else
        --             a_isget = 0
        --         end
        --     end
        --     local b_isget = 1
        --     if self.data.gotSigns[b.id] then
        --         --检测是否过期
        --         local var = mgr.NetMgr:getServerTime() - self.data.gotSigns[b.id] 
        --         if var < b.got_cd * 24 * 3600 then
        --             b_isget = 2
        --         else
        --             b_isget = 0
        --         end
        --     end

        --     if a_isget == b_isget then
        --         return a.id < b.id
        --     else
        --         return a_isget < b_isget
        --     end
        -- end)

        self.listView.numItems = #self.confdata
        mgr.GuiMgr:redpointByVar(30201,self.rednum,1)
    end
end


return Yx1001