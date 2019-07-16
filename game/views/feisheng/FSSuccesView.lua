--
-- Author: 
-- Date: 2018-08-21 20:29:02
--
local delayTime = 10
local FSSuccesView = class("FSSuccesView", base.BaseView)

function FSSuccesView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function FSSuccesView:initView()
    --self:setCloseBtn(self.view)

    self.lab1 = self.view:GetChild("n4")
    self.lab1.text = ""

    self.listView1 = self.view:GetChild("n2")
    self.listView1.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView1.numItems = 0

    self.labtime = self.view:GetChild("n5")
    self.labtime.text = ""

    self.icon = self.view:GetChild("n3")
    self.number = self.view:GetChild("n12")

    self.view.onClick:Add(self.onCloseView,self)
end

function FSSuccesView:celldata( index, obj )
    -- body
    local data = self.protable[index + 1]
    local lab = obj:GetChild("n0")
    local lab1 = obj:GetChild("n1")
    lab.text =   mgr.TextMgr:getTextColorStr(conf.RedPointConf:getProName(data[1]), 5) 
    

    local str = ""
    if self.beforedata["att_"..data[1]] then
        str = GProPrecnt(data[1],(data[2] - self.beforedata["att_"..data[1]]))
    end 
    lab1.text = "+" .. str
end

function FSSuccesView:initData()
    delayTime = 10
    --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)
    self.lab1.text = language.fs06 .. mgr.TextMgr:getTextColorStr(A541..language.fs21,4)
    local condata = conf.FeiShengConf:getLevUpItem(A541)
    self.beforedata = conf.FeiShengConf:getLevUpItem(A541 - 1)

    self.protable = GConfDataSort(condata)
    self.listView1.numItems = #self.protable
    self.number.text = ""
    self.view:GetChild("n11").visible = false
    if condata.icon then
        if type(condata.icon) == "string" then
            self.icon.url = "ui://feisheng/"..condata.icon
        elseif type(condata.icon) == "table" then
            self.icon.url = "ui://feisheng/"..condata.icon[1]

            self.view:GetChild("n11").visible = true
            self.number.text = condata.icon[2]
        else
            self.icon.url = nil 

            self.view:GetChild("n11").visible = true
            self.number.text = condata.icon
        end
    else

        self.icon.url = nil 
    end


    if not self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end
    self.timer = self:addTimer(1,delayTime, handler(self, self.onTimer))


end

function FSSuccesView:onTimer()
    -- body
    delayTime = delayTime - 1
    self.labtime.text = string.format(language.fs09,delayTime)

    if delayTime <= 0 then
        self:onCloseView()
    end
end

function FSSuccesView:onCloseView()
    -- body
    self:closeView()
end


function FSSuccesView:initModel()
    -- body
end
return FSSuccesView