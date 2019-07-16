--
-- Author: wx
-- Date: 2018-07-16 14:30:51
--

local JianLing = class("JianLing",import("game.base.Ref"))

function JianLing:ctor(mParent)
    self.mParent = mParent
    self:initView()
end

function JianLing:initView()
    -- body
    self.view = self.mParent.view:GetChild("n14")
    --5个部位
    self.panelleft = self.view:GetChild("n2")

    self.effpanel = self.panelleft:GetChild("n7")
   

    self.btnlist = {}
    for i =  1 , 5 do
        local btn = self.panelleft:GetChild("part"..i)
       -- error(i)
        btn.data = i
        btn.onClick:Add(self.onBtnCallBack,self)
        self:setPartMsg({part = i})
        table.insert(self.btnlist,btn)
    end

    self.c1 = self.view:GetController("c1")
    --属性
    self.panelprop = self.view:GetChild("n0")
    self.listprop = self.panelprop:GetChild("n38")
    self.listprop.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listprop.numItems = 0


    local btnone = self.panelprop:GetChild("n45")
    btnone.data = 1
    btnone.onClick:Add(self.onQiangHua,self)

    local btnone = self.panelprop:GetChild("n46")
    btnone.data = 2
    btnone.onClick:Add(self.onQiangHua,self)
    --背包
    self.panelpack = self.view:GetChild("n3")
    self.listView =self.panelpack:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellpackdata(index, obj)
    end
    self.listView.numItems = 0

    local btnfenjie = self.panelpack:GetChild("n1")
    btnfenjie.onClick:Add(self.onbtnFenJie,self)

    local btnqianghua = self.panelpack:GetChild("n2")
    btnqianghua.onClick:Add(self.onMsgCall,self)

    local btnPack = self.view:GetChild("n6")
    btnPack.onClick:Add(self.onPack,self)

    local btnTaoZhuang = self.view:GetChild("n7")
    btnTaoZhuang.onClick:Add(self.onTaozhuang,self)



    
end

function JianLing:setData()
    -- body
    self.maxConf = conf.WuxingConf:getValue("color_max_streng_lev")
    self.partdata = {}
    local data = cache.PackCache:getJianLingquipData(Pack.JianLing)
    for k ,v in pairs(data) do
        local confdata = conf.ItemConf:getItem(v.mid)
        if not confdata then
            print("前后端配置一样,缺少 mid = "..mid)
        else
            self.partdata[confdata.part] = v 
        end
    end
    self.mParent:removeUIEffect(self.effect1)
    self.effect1 = self.mParent:addEffect(4020161,self.effpanel)
    self.effect1.LocalPosition = Vector3(59.37,-75,0)
end

function JianLing:setPartMsg( data )
    -- body
    local btn = self.btnlist[data.part]
    if not btn then
        --error("data.part = "..data.part)
        return
    end

    local icon = btn:GetChild("n2")
    local txtlv =  btn:GetChild("n6")
    local txt_di = btn:GetChild("n1")
    local c1 = btn:GetController("c1")
    
    local info = self.partdata[data.part]
    if info then
        local confdata = conf.ItemConf:getItem(info.mid)
        icon.url = confdata.src and  ResPath.iconRes(confdata.src) or nil
        txtlv.text = string.format(language.awaken48 ,data.strenLev)
        c1.selectedIndex = mgr.ItemMgr:getColorBNum(info)
        txt_di.visible = true
    else
        icon.url = nil
        txtlv.text = ""
        txt_di.visible = false
        c1.selectedIndex = 0

        icon.url = UIItemRes.awaken01[data.part]
    end
end

function JianLing:celldata( index,obj )
    -- body
    local data = self.curprop[index+1]
    local txt = obj:GetChild("n0")
    local txt1 = obj:GetChild("n1")
    txt1.text = ""

    local str = conf.RedPointConf:getProName(data[1]) .. " " .. GProPrecnt(data[1],math.floor(data[2]))
    txt.text = str
    for k , v in pairs(self.nextprop or {}) do
        if v[1] == data[1] then
            local cc = math.floor(v[2]-data[2])
            txt1.text = mgr.TextMgr:getTextColorStr("+"..GProPrecnt(v[1],cc),7)
            break
        end
    end
    
end

function JianLing:setPropMsg(data)
    -- body
    local confdata = conf.ItemConf:getItem(data.mid)
    local partdata 
    --print(confdata.part)
    for k , v in pairs(self.data.partInfos) do
        --print(v.part)
        if v.part == confdata.part then
            partdata = v 
            break
        end
    end
    local curstrenLev = partdata.strenLev
    local nextstrenLev = curstrenLev + 1
    local maxstrenLev = 0
    for k ,v in pairs(self.maxConf) do
        if v[1] == confdata.color then
            maxstrenLev = v[2]
            break
        end
    end
    curstrenLev = math.min(curstrenLev,maxstrenLev)

    local curdata = conf.WuxingConf:getStrenInfo(confdata.part,confdata.color,curstrenLev)
    local nextdata = conf.WuxingConf:getStrenInfo(confdata.part,confdata.color,nextstrenLev)
    if nextstrenLev > maxstrenLev then
        nextdata = nil--超出当前最大等级了
    end

    local c1 = self.panelprop:GetController("c1")
    c1.selectedIndex = 0

    local itemobj = self.panelprop:GetChild("n27")
    local info = clone(data)
    info.isquan = true
    GSetItemData(itemobj,info)

    local name = self.panelprop:GetChild("n28")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local prop = self.panelprop:GetChild("n31")
    prop.text = string.format(language.awaken49,language.awaken51[confdata.part])

    local color =  self.panelprop:GetChild("n32")
    color.text = string.format(language.awaken50,language.pack35[confdata.color])

    local curlv = self.panelprop:GetChild("n33")
    curlv.text = string.format(language.awaken48,curstrenLev)

    local nextlv = self.panelprop:GetChild("n34")
    nextlv.text = ""

    --属性
    self.curprop = GConfDataSort(curdata)
    self.nextprop =  GConfDataSort(nextdata)

    local curpower = self.panelprop:GetChild("n42")
    curpower.text = curdata.power

    local nextpower = self.panelprop:GetChild("n43")
    nextpower.text = ""

    local txtcost = self.panelprop:GetChild("n51")
    txtcost.text = ""

    self.need = curdata.cost_lhjj
    self.nextdata = nextdata
    if nextdata then
        nextlv.text = string.format(language.awaken48, nextstrenLev)
        nextpower.text = nextdata.power
        local str = language.gonggong128 .. "("
        --txtcost.text =  --..cache.PlayerCache:getTypeMoney(MoneyType.lj).."/"..self.need..")"
        
        if cache.PlayerCache:getTypeMoney(MoneyType.lj) >= self.need then
            str = str .. mgr.TextMgr:getTextColorStr(cache.PlayerCache:getTypeMoney(MoneyType.lj),7)
        else
            str = str .. mgr.TextMgr:getTextColorStr(cache.PlayerCache:getTypeMoney(MoneyType.lj),14)
        end
        str = str .. mgr.TextMgr:getTextColorStr("/"..self.need,7)
        txtcost.text = str .. ")"
    else
        c1.selectedIndex = 1
        nextlv.text = mgr.TextMgr:getTextColorStr(language.awaken64,14) 
    end

    self.listprop.numItems = #self.curprop
end

function JianLing:cellpackdata(index,obj)
    -- body
    local data = self.packdata[index+1]
    --printt(data)
    if data then
        local info = clone(data)
        info.func = function( ... )
            -- body
            info.level = 0
            for k , v in pairs(self.data.partInfos) do
                local confdata = conf.ItemConf:getItem(data.mid)
                if v.part == confdata.part then
                    info.level = v.strenLev
                    break
                end
            end
            
            GSeeLocalItem(info)
        end
        info.isquan = true
        info.isArrow = true
        GSetItemData(obj:GetChild("n0"),info,true)
    else
        GSetItemData(obj:GetChild("n0"),{})
    end
    
end

function JianLing:setPackData(part)
    -- body
    self.packdata = {}
    local data = cache.PackCache:getPackData()
    for k ,v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.type == Pack.wuxing then--and condata.part ==  part 
            table.insert(self.packdata,v)
        end
    end
    --排序
    table.sort(self.packdata,function(a,b)
        -- body
        return a.index < b.index
    end)
    self.listView.numItems = math.max((math.ceil(#self.packdata/20)*20),20)
end

function JianLing:onPack(part)
    -- body
    self.c1.selectedIndex = 1
    self:setPackData(self.part)
end

function JianLing:onMsgCall()
    -- body

    local level 
    local partinfo = {}
    for i = 1 , 5 do
        if self.partdata[i] then
            for k , v in pairs(self.data.partInfos) do
                if v.part == i then
                    table.insert(partinfo,{v.strenLev,i})
                    break
                end
            end
        end
    end

    table.sort(partinfo,function(a,b)
        -- body
        if a[1] == b[1] then
            return a[2]<b[2]
        else
            return a[1]<b[1]
        end
    end)
   
    if partinfo[1] then
        self:onSetinfo(partinfo[1][2])
    else
        GComAlter(language.awaken55)
    end
end

function JianLing:onQiangHua( context )
    -- body
    local btn = context.sender 
    local data = btn.data 

    if not data or not self.data then
        return
    end

    if not self.part then
        GComAlter(language.awaken52)
        return
    end
    local info = self.partdata[self.part]
    if not info then
        GComAlter(language.awaken52)
        return
    end

    if cache.PlayerCache:getTypeMoney(MoneyType.lj) < self.need then
        GComAlter(language.gonggong129)
        return
    end

    if not self.nextdata then
        GComAlter(language.awaken65)
        return
    end

    local param = {}
    param.reqType = data
    param.part = self.part
    proxy.AwakenProxy:send(1530103,param)
end

function JianLing:onSetinfo(part)
    -- body
    local info = self.partdata[part]
    self.part = part 
    if info then
        self.c1.selectedIndex = 0
        self:setPropMsg(info) 
    else
        --切到背包去
        self.c1.selectedIndex = 1
        self:setPackData(part)
    end
end

function JianLing:onBtnCallBack(context)
    -- body
    local btn = context.sender 
    local data = btn.data 
    if self.c1.selectedIndex == 0 then
        self:onSetinfo(data)
    else
        local info = self.partdata[data]
        if info then
            for k , v in pairs(self.data.partInfos) do
                local confdata = conf.ItemConf:getItem(info.mid)
                if v.part == confdata.part then
                    info.level = v.strenLev
                    break
                end
            end
            GSeeLocalItem(info)
        else
            self:onSetinfo(data)
        end 
    end
end

function JianLing:onbtnFenJie()
    -- body
    mgr.ViewMgr:openView2(ViewName.HuobanExpPop,{way = "JianLing"})
end

function JianLing:onTaozhuang()
    -- body
    proxy.AwakenProxy:send(1530104)
end

function JianLing:addMsgCallBack(data,param)
    -- body
    if data.msgId == 5530101 then
        self.data = data 
        --显示全部的部位信息
        for k ,v in pairs(data.partInfos) do
            self:setPartMsg(v)
        end
        self:refreshRed()
        --默认选择一个
        for i = 1 , 5 do
            if self.partdata[i] then
                self:onSetinfo(i)
                self:onPack()
                return
            end
        end

        self:onSetinfo(1)
        
    elseif data.msgId == 5530102 then
        self:setData()
        for k ,v in pairs(self.data.partInfos) do
            self:setPartMsg(v)
        end
        self:onPack()
        mgr.GuiMgr:refreshRedBottom()
        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:refreshRed()
        end
    elseif data.msgId == 5530103 then
        --装备强化
        for k ,v in pairs(self.data.partInfos) do
            if v.part == data.part then
                self.data.partInfos[k] = data.partInfo
                break
            end
        end
        self:setPartMsg(data.partInfo)
        self:onSetinfo(data.part)
        self:refreshRed()
        self.mParent:refreshRed()
    elseif  data.msgId == 5100109 then
        if self.c1.selectedIndex == 0 and self.part then
            self:onSetinfo(self.part)
        else
            self:onPack()
        end
    end
end

function JianLing:refreshRed()
    -- body
    for i = 1 , 5 do
        self.btnlist[i]:GetChild("red").visible = G_RedWuXingQianghua(i)>0
    end
end


return JianLing