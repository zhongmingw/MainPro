--
-- Author: wx 
-- Date: 2018-08-20 17:20:25
-- 飞升

local FeiSheng = class("FeiSheng",import("game.base.Ref"))

function FeiSheng:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n27")
    self:initView()
end

function FeiSheng:initView()
    -- body
    self.dec1 = self.view:GetChild("n4")
    self.dec1.text = ""

    self.dec2 = self.view:GetChild("n5")
    self.dec2.text = ""

    self.dec3 = self.view:GetChild("n6")
    self.dec3.text = ""

    local dec4 = self.view:GetChild("n7")
    dec4.text = language.fs32 
    local dec5 = self.view:GetChild("n10")
    dec5.text = language.fs30
    local dec6 = self.view:GetChild("n12")
    dec6.text = language.fs31
    --属性加成
    self.listpro1 = self.view:GetChild("n13")
    self.listpro1.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listpro1.numItems = 0
    --极品属性
    self.listpro2 = self.view:GetChild("n14")
    self.listpro2.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listpro2.numItems = 0

    local btn1 = self.view:GetChild("n15")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n16")
    btn1.onClick:Add(self.onBtnCallBack,self)
    self.btn = btn1

    self.number = self.view:GetChild("n17")
end

function FeiSheng:initData()
    -- body
     --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)
    -- /** 当前仙缘 **/
    local A542 = cache.PlayerCache:getAttribute(542)
    --/** 仙力等级 **/
    local A543 = cache.PlayerCache:getAttribute(543)

    self.number.text = A541

    self.dec1.text = language.fs27 .. mgr.TextMgr:getTextColorStr(A541 .. language.fs21 , 7) 

    local confdata = conf.FeiShengConf:getLevUpItem(A541)
    if confdata.need_xy and cache.FeiShengCache:hasNext() then
        if A542 >= confdata.need_xy then
            self.dec2.text = language.fs28 .. mgr.TextMgr:getTextColorStr(A542 .."/".. confdata.need_xy  , 7)  
        else
            self.dec2.text = language.fs28 .. mgr.TextMgr:getTextColorStr(tostring(A542),14) .. "/"..mgr.TextMgr:getTextColorStr(confdata.need_xy,7)  
        end
    else
        self.dec2.text = ""
    end

    if A541 == 0 then
        --0级的时候先确定是否够等级
        if confdata.need_lev then
            if cache.PlayerCache:getRoleLevel() >= confdata.need_lev then
                self.btn.visible = true 
            else
                self.btn.visible = false
            end
        end
    else
        self.btn.visible = true
    end 

    self.dec3.text = language.fs29 .. mgr.TextMgr:getTextColorStr(A543,7)

    --属性累计计算
    self.prolist = cache.FeiShengCache:getAllPro()
    self.listpro1.numItems = #self.prolist
    --极品属性累计
    self.probestlist = cache.FeiShengCache:getAllBestPro()
    self.listpro2.numItems = #self.probestlist
end

function FeiSheng:cellBaseData(index, obj)
    -- body
    local data = self.prolist[index + 1]
    local lab = obj:GetChild("n0")
    local str = conf.RedPointConf:getProName(data[1]) 
    str = str .. "  " .. mgr.TextMgr:getTextColorStr(GProPrecnt(data[1],data[2]), 7) 
    lab.text = str  
end

function FeiSheng:cellData(index, obj)
    -- body
    local data = self.probestlist[index + 1]
    local lab = obj:GetChild("n0")
    local str = conf.RedPointConf:getProName(data[1]) 
    str = str  .. mgr.TextMgr:getTextColorStr("+"..GProPrecnt(data[1],data[2]), 7) 
    lab.text = str  
end

function FeiSheng:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if "n15" == btn.name then
        mgr.ViewMgr:openView2(ViewName.FSXianLiView)
    elseif "n16" == btn.name then
        if cache.FeiShengCache:hasNext() then
            if cache.PlayerCache:getAttribute(541) == 0 then
                mgr.ViewMgr:openView2(ViewName.FSXianYuanView)
            else
                mgr.ViewMgr:openView2(ViewName.FSOverView)
            end
        else
            GComAlter(language.fs33)
        end
    end
end

function FeiSheng:addMsgCallBack(data)
    -- body
    if data.msgId == 5580201 or data.msgId == 5580202 then
        self:initData()
    end
end


return FeiSheng