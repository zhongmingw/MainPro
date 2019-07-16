--
-- Author: 
-- Date: 2018-08-21 20:08:55
--

local FSOverView = class("FSOverView", base.BaseView)

function FSOverView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function FSOverView:initView()
    local btn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btn)

    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 0

    local btn1 = self.view:GetChild("n2")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n9")
    btn1.data = -1
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n8")
    btn1.data = 1
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.listView1 = self.view:GetChild("n16")
    self.listView1.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView1.numItems = 0

    self.listView2 = self.view:GetChild("n14")
    self.listView2.itemRenderer = function (index,obj)
        self:cellJumpdata(index, obj)
    end
    self.listView2.numItems = 0
    self.listView2.onClickItem:Add(self.onCallBack,self) 

    self.lab = self.view:GetChild("n15") 
    self.lab.text = ""

    self.imgfill = self.view:GetChild("n3"):GetChild("n4")
    self.imgfill.fillAmount = 0

    self.lab1 = self.view:GetChild("n18") 
    self.lab2 = self.view:GetChild("n19") 
end

function FSOverView:celldata(index, obj)
    local data = self.protable[index + 1]
    local lab = obj:GetChild("n0")
    local str = conf.RedPointConf:getProName(data[1]) .. ":  " .. GProPrecnt(data[1],data[2])
    lab.text = str

    local str = ""
    if self.nextconf["att_"..data[1]] then
        str = str .. mgr.TextMgr:getTextColorStr("  +"..(self.nextconf["att_"..data[1]] - data[2]) , 4)  .. language.fs22
    end 
    obj:GetChild("n1").text = str
end

function FSOverView:cellJumpdata( index, obj )
    -- body
    obj.data = self.nextconf.module_key[index+1] 
    local icon = obj:GetChild("n0")
    icon.url = "ui://feisheng/"..self.nextconf.module_icon[index+1]
end

function FSOverView:onCallBack(context)
    -- body
    local data = context.data.data 
    if data == 1325 then
        self:closeView()
        return
    end
    local param = {}
    param.id = data
    GOpenView(param)
end

function FSOverView:onBtnCallBack( context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if "n2" == btn.name then
        if 0 == self.c1.selectedIndex then
            --提升仙缘
            mgr.ViewMgr:openView2(ViewName.FSXianYuanUp)
        else
            --飞升
            proxy.FeiShengProxy:sendMsg(1580202)
        end
        self:closeView()
    elseif "n8" == btn.name then
        self.listView2:ScrollToView(0)
    elseif "n9" == btn.name then
        self.listView2:ScrollToView(self.listView2.numItems-1)
    end
    
end

function FSOverView:initData()
    -- body
    --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)

    local A542 = cache.PlayerCache:getAttribute(542)

    local condata = conf.FeiShengConf:getLevUpItem(A541)
    --等级
    self.lab.text = language.fs06 .. mgr.TextMgr:getTextColorStr(A541, 4)
    --所需等级
    local flag = true
    if condata.need_lev then
        local str = language.fs07 
        if cache.PlayerCache:getRoleLevel() >= condata.need_lev then
            str = str .. mgr.TextMgr:getTextColorStr(cache.PlayerCache:getRoleLevel(), 4)
        else
            str = str .. mgr.TextMgr:getTextColorStr(cache.PlayerCache:getRoleLevel(), 14)
            flag = false
        end
        str = str .. "/" .. condata.need_lev
        self.lab1.text = str
    else
        self.lab1.text = ""
    end
    --所需仙缘
    if condata.need_xy then
        local str = language.fs08 
        if A542 >= condata.need_xy then
            str = str .. mgr.TextMgr:getTextColorStr(A542, 4)
        else
            str = str .. mgr.TextMgr:getTextColorStr(A542, 14)
            flag = false
        end
        str = str .. "/" .. condata.need_xy
        self.lab2.text = str

        self.imgfill.fillAmount = A542 / condata.need_xy
    else
        self.lab2.text = ""
        self.imgfill.fillAmount = 0
    end
    if flag then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
    --下一级属性
    self.nextconf = conf.FeiShengConf:getLevUpItem(A541 + 1)
    self.protable = GConfDataSort(condata)
    self.listView1.numItems = #self.protable
    --下一级开放
    if self.nextconf.module_key then 
        self.listView2.numItems = #self.nextconf.module_key
    else
        self.listView2.numItems = 0 
    end 
end

return FSOverView