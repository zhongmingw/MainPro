--
-- Author: 
-- Date: 2018-08-22 11:03:59
--

local FSXianYuanView = class("FSXianYuanView", base.BaseView)

function FSXianYuanView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function FSXianYuanView:initView()
    local btn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btn)

    self.imgfill = self.view:GetChild("n9"):GetChild("n4")
    self.imgfill.fillAmount = 0

    self.panel = self.view:GetChild("n2")

    local btn1 = self.view:GetChild("n3")
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 0

    self.labpercent = self.view:GetChild("n11")
    self.labneed = self.view:GetChild("n10")
    self._img = self.view:GetChild("n12")

end

function FSXianYuanView:onBtnCallBack(context)
    local btn = context.sender
    local data = btn.data 
    if "n3" == btn.name then
        if 0 == self.c1.selectedIndex then
            --提升仙缘
            mgr.ViewMgr:openView2(ViewName.FSXianYuanUp)
        else
            --飞升
            proxy.FeiShengProxy:sendMsg(1580202)
        end
    end
    self:closeView()
end

function FSXianYuanView:setModel(id)
    -- body
    self.model = self:addModel(id,self.panel)
    self.model:setScale(100)
    self.model:setPosition(50,-125,0)
    self.model:setRotationXYZ(0,180,0)
end

function FSXianYuanView:initData()
    -- body
    self.model = nil 
    --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)
    -- /** 当前仙缘 **/
    local A542 = cache.PlayerCache:getAttribute(542)

    local condata = conf.FeiShengConf:getLevUpItem(A541)
    local str = language.fs08

    local flag = true
    if A542 < (condata.need_xy or 0)  then
        self.c1.selectedIndex = 0
        self.imgfill.fillAmount = A542 / (condata.need_xy or 100)

        str  = str .. mgr.TextMgr:getTextColorStr(A542, 14)

        flag = false
    else
        self.c1.selectedIndex = 1 
        self.imgfill.fillAmount = 1
        str  = str .. mgr.TextMgr:getTextColorStr(A542, 7)
    end




    str  = str .. "/" .. (condata.need_xy or 0)
    self.labneed.text = str
    self:setModel(condata.model)

    
    if not  condata.percent then
        self.labpercent.text = ""
        self._img.visible = false
    else
        self.labpercent.text = condata.percent
        self._img.visible = true
    end
end

return FSXianYuanView