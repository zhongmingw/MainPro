--
-- Author: 
-- Date: 2018-08-21 20:39:18
--

local FSXianLiView = class("FSXianLiView", base.BaseView)

function FSXianLiView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function FSXianLiView:initView()
    local btn = self.view:GetChild("n2"):GetChild("n2")
    self:setCloseBtn(btn)

    self.listView1 = self.view:GetChild("n13")
    self.listView1.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView1.numItems = 0

    local btn1 = self.view:GetChild("n17")
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.num1 = self.view:GetChild("n18")
    self.num1.text = ""

    self.bar = self.view:GetChild("n6") 

    local lab = self.view:GetChild("n9")
    lab.text = language.fs10
    local lab = self.view:GetChild("n12")
    lab.text = language.fs11
    local lab = self.view:GetChild("n14")
    lab.text = language.fs12
    local lab = self.view:GetChild("n15")
    --lab.text = language.fs13
    self.labdec1 = lab
    self.labdec1.text = ""
end

function FSXianLiView:celldata( index, obj )
    -- body
    local data = self.protable[index + 1]
    local labname = obj:GetChild("n0")
    local lab1 = obj:GetChild("n1")
    labname.text = conf.RedPointConf:getProName(data[1])
    lab1.text =  mgr.TextMgr:getTextColorStr(GProPrecnt(data[1],data[2]), 7) 
end

function FSXianLiView:onBtnCallBack(context)
    local btn = context.sender
    local data = btn.data 
    if "n17" == btn.name then
        mgr.ViewMgr:openView2(ViewName.FSFenJieView)
    end
    self:closeView()
end

function FSXianLiView:initData()
    -- body
    --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)
    -- /** 当前仙缘 **/
    local A542 = cache.PlayerCache:getAttribute(542)
    --/** 仙力等级 **/
    local A543 = cache.PlayerCache:getAttribute(543)

    self.num1.text = A543

    local confdata = conf.FeiShengConf:getXlLevUpItem(A543)
    if conf.FeiShengConf:getXlLevUpItem(A543 + 1) then
        self.bar.visible = true
        self.bar.value = cache.FeiShengCache:getXl()
        self.bar.max = confdata.need_xl 
    else
        self.bar.visible = false
    end

    self.protable = GConfDataSort(confdata)
    self.listView1.numItems = #self.protable

    local confdata = conf.FeiShengConf:getdiffLevItem(1)
    self.labdec1.text = string.format(language.fs13,confdata.lev[1])

end

return FSXianLiView