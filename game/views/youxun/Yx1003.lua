--
-- Author: 
-- Date: 2018-09-05 19:52:54
--

local Yx1003 = class("Yx1003",import("game.base.Ref"))

function Yx1003:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Yx1003:initView()
    -- n3
    local dec1 = self.view:GetChild("n3")
    dec1.text = language.yx06

    self.btn = self.view:GetChild("n1")
    self.btn.title = language.yx02
    self.btn.onClick:Add(self.onBtnCallBack,self)

    self.confdata = conf.YouXunConf:getYzLevGift()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.id < b.id 
    end)
    --print("self.confdata",#self.confdata)

    self.listView = self.view:GetChild("n4")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView.numItems = #self.confdata
    local titleImg = self.view:GetChild("n0"):GetChild("n1")
    local tqType = conf.YouXunConf:getTeQuanType()
    if tqType == 3 then
        titleImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_039")
    else
        titleImg.url = UIPackage.GetItemURL("youxun" ,"yxtequan_036")
    end
end

function Yx1003:cellBaseData(index, obj )
    -- body

    local data = self.confdata[index + 1]
    --print("index",index)
    local lab = obj:GetChild("n3")
    lab.text = string.format(language.yx07,data.lev)

    local listview = obj:GetChild("n4")
    listview.itemRenderer = function(_index,_obj)
        local info = data.item[_index + 1 ]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3] or 0
        GSetItemData(_obj, t, true)
    end
    listview.numItems = #data.item

    local btn = obj:GetChild("n5")
    btn.title = ""--language.yx04
    btn.data = data 
    btn.onClick:Add(self.onCallBack,self)

     local red = btn:GetChild("red")
    red.visible = false

    local labtitle = obj:GetChild("n6")
    labtitle.text = language.yx04

    local c1 = obj:GetController("c1")
    c1.selectedIndex = 0
    if self.data  then
        if self.data.gotSigns[data.id] then
            c1.selectedIndex = 2
            --btn.title = language.yx14
        else
            if self.data.yz > 0 then
                if cache.PlayerCache:getRoleLevel() >= data.lev then
                    c1.selectedIndex = 1

                    self.rednum = self.rednum + 1

                    red.visible = true
                end
            end
        end
    end
end

function Yx1003:onCallBack(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if not self.data then
        return
    end
    
    if self.data.gotSigns[data.id] then
        GComAlter(language.yx14)
        return
    end
    if self.data.yz <= 0 then
        return GComAlter(language.yx17)
    end
    if cache.PlayerCache:getRoleLevel() < data.lev then
        GComAlter(language.yx18)
        return
    end
    local param = {}
    param.reqType = 1
    param.cfgId = data.id 
    proxy.YouXunProxy:sendMsg(1030603,param)
end

function Yx1003:onBtnCallBack( context )
    -- body
    if not self.data then return end
    self.parent:onOpenVip()
end

function Yx1003:onTimer()
    -- body
end


function Yx1003:addMsgCallBack(data)
    -- body
    if data.msgId == 5030603 then
        self.rednum = 0

        GOpenAlert3(data.items)
        self.data = data 
        self.btn.visible = self.data.yz <= 0

        table.sort(self.confdata,function(a,b)
            -- body
            local a_isget = self.data.gotSigns[a.id] or 0
            local b_isget = self.data.gotSigns[b.id] or 0
            if a_isget == b_isget then
                return a.id < b.id 
            else
                return a_isget < b_isget
            end
        end)

        self.listView.numItems = #self.confdata

        mgr.GuiMgr:redpointByVar(30203,self.rednum,1)
    end
end

return Yx1003