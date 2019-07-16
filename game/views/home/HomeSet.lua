--
-- Author: wx
-- Date: 2017-11-20 20:15:46
-- 家园设置

local HomeSet = class("HomeSet", base.BaseView)

function HomeSet:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.openTween = ViewOpenTween.scale 
end

function HomeSet:initData()
    -- body
    if not self.timers then
        self:removeTimer(self.timers)
    end
    self.timers = self:addTimer(1,-1, handler(self,self.onTimer))

    --所有特殊皮肤
    self.allskins = {}
    local condata = conf.HomeConf:getTebieSkins()
    for i , j in pairs(condata) do
        if not self.allskins[j.type] then
            self.allskins[j.type] = {}
        end
        table.insert(self.allskins[j.type],j)
    end
    for k ,v in pairs(self.allskins) do
        table.sort(v,function(a,b)
            -- body
            return a.id < b.id
        end)
    end

    self.sss = {}
    proxy.HomeProxy:sendMsg(1460104,{reqType = 0,name = ""})
end

function HomeSet:initView()
    local btnClose = self.view:GetChild("n1"):GetChild("n2")
    self:setCloseBtn(btnClose)
    --我的家园
    local dec1 = self.view:GetChild("n16")
    dec1.text = language.home02
    self.homename = self.view:GetChild("n20")
    self.homename.text = ""
    local btnChange = self.view:GetChild("n4")
    btnChange.onClick:Add(self.onbtnChangeName,self)

    --宅邸等级
    local dec1 = self.view:GetChild("n17")
    dec1.text = language.home03
    self.homelevel = self.view:GetChild("n21")
    self.homelevel.text = ""
    local btnHomeUp = self.view:GetChild("n6")
    btnHomeUp.title = language.home42[2]
    btnHomeUp.onClick:Add(self.onHomeUp,self)
    --闭关潜修
    local dec1 = self.view:GetChild("n18")
    dec1.text = language.home32
    self.labtimer = self.view:GetChild("n22")
    self.labtimer.text = ""
    self.btn1 = self.view:GetChild("n8")
    self.btn1.text = language.home33
    self.btn1.onClick:Add(self.onQianXiu1,self)
    local btn2 = self.view:GetChild("n7") 
    btn2.title = language.home35
    btn2.onClick:Add(self.onQianXiu2,self)
    --护院神兽
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.home36
    self.homemonster = self.view:GetChild("n23")
    local btnshengshou = self.view:GetChild("n9")
    btnshengshou.onClick:Add(self.onStartDef,self)
    self.btnshengshou = btnshengshou

    local dec1 = self.view:GetChild("n24")
    dec1.text = language.home37

    self.listView = self.view:GetChild("n10")
    --self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local btnSave = self.view:GetChild("n14")
    btnSave.onClick:Add(self.onSave,self)

    self.money = self.view:GetChild("n25")
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)

    local btnPlus = self.view:GetChild("n5")
    btnPlus.onClick:Add(self.onPlus,self)
end

function HomeSet:onTimer()
    -- body
    if not self.data then
        return
    end
    if not self.homedata then
        return
    end
    if self.homedata.practiceStatu == 1 then
        self.homedata.leftPracticeSec =math.max(self.homedata.leftPracticeSec - 1,0) 
    end
    
    local ss = language.home71..GTotimeString(self.homedata.leftPracticeSec)
    if self.homedata.practiceStatu == 0 then
        ss = ss..language.home73
    else
        ss = ss..language.home72
    end
    self.labtimer.text = ss
end

function HomeSet:celldata(index, obj)
    -- body
    local data = self.listinfo[index+1]
    local title = obj:GetChild("n3")
    title.text = language.home76[index+1]

    local listView = obj:GetChild("n4")
    listView.itemRenderer = function(_index,_obj)
        local info = data[_index+1]
        --printt(info)
        local icon = _obj:GetChild("n0") 
        if info.icon then
            icon.url = UIItemRes.home2..info.icon
        end

        local title = _obj:GetChild("n2") 
        title.text = info.name

        _obj.data = info

        if not self.gotSkins[info.id] then
            title.text = info.name .. mgr.TextMgr:getTextColorStr(language.home134,14)
        end
    end
    listView.numItems = #data 
    listView.onClickItem:Add(self.onCallBack,self)

    local _selectindex
    for k , v in pairs(data) do
        local kkk = tonumber(string.sub(v.id,1,4))
        if self.sss[kkk] then
            if tonumber(v.id) == tonumber(self.sss[kkk]) then
                _selectindex = k - 1
                break
            end
        else
            if self.gotSkins[v.id] and self.gotSkins[v.id] == 1 then
                _selectindex = k - 1
                break
            end
        end
    end
    if index == 2 then
        listView:ClearSelection()
    else
        if not _selectindex then
            _selectindex = 0
        end
    end
    if _selectindex then
        listView:AddSelection(_selectindex,false)
        listView:ScrollToView(_selectindex,false)
    end
end

function HomeSet:onCallBack(context)
    -- body
    local data = context.data.data
    local key = string.sub(data.id,1,4)
    if data.skin_type and data.skin_type == 1 then
        if not self.gotSkins[data.id] then
            local ff = conf.ShopConf:getJiaYuanShopDataById(data.shop_id)
            --print("data.shop_id",data.shop_id)
            local cc = clone(language.home116)
            cc[2].text = string.format(cc[2].text,ff.price)
            local param = {}
            param.type = 2
            param.richtext = mgr.TextMgr:getTextByTable(cc) 
            param.sure = function()
                -- body
                --购买商城道具
                self.buyId = data.id
                local _sendparam = {}
                _sendparam.reqType = 9
                _sendparam.index = data.shop_id
                _sendparam.amount = 1
                proxy.ShopProxy:send(1090104,_sendparam)
                self.listView.numItems = #self.listinfo
            end
            param.cancel = function()
                -- body
                self.listView.numItems = #self.listinfo
            end
            param.closefun = function( )
                -- body
                self.listView.numItems = #self.listinfo
            end
            GComAlter(param)
            return
        end
    end
    self.sss[tonumber(key)] = data.id
end

function HomeSet:addlistinfo(id,iddd)
    -- body

    local condata = conf.HomeConf:getHomeThing(id)
    self.listinfo[tonumber(iddd)] = {}
    --等级皮肤
    local lv = condata.lev
    if iddd == 1 then
        lv = self.data.houseLev
    elseif iddd == 2 then
        lv = self.data.wallLev
    elseif iddd == 3 then
        lv = condata.maxlv
    end
    for i = condata.lev , lv do
        local index = id * 1000 + i
        local _iii = conf.HomeConf:getSkins(index)
        table.insert(self.listinfo[tonumber(iddd)],_iii)
    end
    if iddd == 3 then
        if self.allskins[6] then
            for k,v in pairs(self.allskins[6]) do
                table.insert(self.listinfo[tonumber(iddd)],v)
            end
        end
    else
        if self.allskins[iddd] then
            for k,v in pairs(self.allskins[iddd]) do
                table.insert(self.listinfo[tonumber(iddd)],v)
            end
        end
    end
    
end

function HomeSet:setData(data_)

    self.homename.text = self.data.homeName
    self.homelevel.text = string.format(language.home64,self.data.houseLev)
    self.homemonster.text= self.data.hyssName
    if self.homedata.hyssStatu == 0 then
        self.btnshengshou.title = language.home74
    else
        self.btnshengshou.title = language.home75
    end

  
    self.listinfo = {}
    --等级皮肤
    self:addlistinfo(1001,1)
    self:addlistinfo(2001,2)
    self:addlistinfo(6001,3)
    --已经获取的特殊皮肤
    self.gotSkins = self.homedata.gotSkins
   
    self.listView.numItems = #self.listinfo
end

function HomeSet:onQianXiu1()
    -- body
    if not self.data then
        return
    end

    if self.homedata.leftPracticeSec <= 0 then
        GComAlter(language.home113)
        return
    end

    if self.homedata.practiceStatu == 0 then
        local param = {}
        param.reqType = 2
        param.name = ""
        proxy.HomeProxy:sendMsg(1460104,param)
    else
        GComAlter(language.home115)
    end
end
function HomeSet:onQianXiu2()
    -- body
    if not self.data then
        return
    end

    if self.homedata.practiceStatu == 1 then
        local param = {}
        param.reqType = 3
        param.name = ""
        proxy.HomeProxy:sendMsg(1460104,param)
    else
        GComAlter(language.home114)
    end
end
function HomeSet:onStartDef()
    -- body
    if not self.data then
        return
    end
    local param = {}
    param.reqType = 4
    param.name = ""
    proxy.HomeProxy:sendMsg(1460104,param)
   
end

function HomeSet:onSave()
    -- body
    --保存形象
    --
    local param = {}
    param.skins = {}
    for k ,v in pairs(self.sss) do
        if self.gotSkins[tonumber(v)] then
            table.insert(param.skins,k)
            table.insert(param.skins,v)
        end
    end
    if #param.skins ~= 0 then
        proxy.HomeProxy:sendMsg(1460106,param)
    end
    
    self:closeView()
end

function HomeSet:onPlus()
    -- body
    GOpenView({id = 1042})
end

function HomeSet:onbtnChangeName()
    -- body
    mgr.ViewMgr:openView2(ViewName.HomeChangeName)
    self:closeView()
end

function HomeSet:onHomeUp()
    -- body
    mgr.ViewMgr:openView2(ViewName.HomeHouse)
    self:closeView()
end

function HomeSet:add5460104( data )
    -- body
    --self.selected = mgr.HomeMgr:getSelectSkin()
    self.data = cache.HomeCache:getData()
    self.homedata = data
    -- for k ,v in pairs(self.homedata.gotSkins) do
    --     print("k,v",k,v)
    -- end
    self:setData()
end

function HomeSet:add5090104( data )
    -- body
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if self.buyId then
        self.gotSkins[self.buyId] = 0
        local key = string.sub(self.buyId,1,4)
        self.sss[tonumber(key)] = self.buyId
        --print("购买成功",key,self.buyId)
        self.buyId = nil 
        self.listView.numItems = #self.listinfo
    end
end

return HomeSet