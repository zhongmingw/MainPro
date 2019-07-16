--
-- Author: 
-- Date: 2018-08-06 14:55:00
--

local XianTongTongFang = class("XianTongTongFang", base.BaseView)

function XianTongTongFang:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongTongFang:initView()
    local btn = self.view:GetChild("n16")
    --self:setCloseBtn(btn)
    btn.onClick:Add(self.onBtnCallBack,self)

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onControlChange,self)

    self.lefticon = self.view:GetChild("n8"):GetChild("n2"):GetChild("n3")
    self.righticon = self.view:GetChild("n11"):GetChild("n2"):GetChild("n3")

  
    self.leftname = self.view:GetChild("n9")
    self.rightname = self.view:GetChild("n12")

    self.lab1 = self.view:GetChild("n13") 
    local dec1 = self.view:GetChild("n14") 
    dec1.text = language.xiantong07

    local btn = self.view:GetChild("n4") 
    btn.onClick:Add(self.onBtnCallBack,self)

    self.labtimer = self.view:GetChild("n18") 
    self.labtimer.text = ""

    self.listView = self.view:GetChild("n19")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    --self.listView:SetVirtual()
    self.listView.numItems = 0

    self:setData()
end

function XianTongTongFang:setData( ... )
    -- body
      --设置左右头像框
    self.lefticon.url = ResPath.iconRes(tostring(1)..string.format("%02d",0))
    self.righticon.url = ResPath.iconRes(tostring(2)..string.format("%02d",0))

    if cache.PlayerCache:getSex() == 1 then
        self.leftname.text = cache.PlayerCache:getRoleName()
        self.rightname.text = cache.PlayerCache:getCoupleName()
    else
        self.leftname.text = cache.PlayerCache:getCoupleName()
        self.rightname.text = cache.PlayerCache:getRoleName()
    end
end

function XianTongTongFang:initData(data)
    self.c1.selectedIndex = data.index
    if 0 == self.c1.selectedIndex then
        self.data = data.data
        self.overtime = conf.MarryConf:getXTValue("tongfang_requst_overtime")
        self:addTimer(1,self.overtime,handler(self,self.onTimer))
    else
        --显示奖励
        self.data = data.data 
        self.reward1 = self.data.items --conf.MarryConf:getXTRewardPool(self.data.awardId)
        --printt(self.reward1)
        self.listView.numItems = #self.reward1
    end
    self:onControlChange()
end
function XianTongTongFang:onTimer()
    -- body
    self.overtime = self.overtime - 1
    if self.overtime<=0 then
        --拒绝
        local param = {}
        param.reqType = 2
        param.times = self.data.times
        proxy.MarryProxy:sendMsg(1390501,param)
        self:closeView()
        return
    end
    self.labtimer.text = self.overtime .. "S"
end


function XianTongTongFang:celldata(index, obj)
    local data = self.reward1[index+1]
    --printt("index"..index,data)
    -- local t = {}
    -- t.mid = data[1]
    -- t.amount = data[2]
    -- t.bind = data[3]
    local t = clone(data)
    t.index = 0
    GSetItemData(obj, t, true)
end



function XianTongTongFang:onControlChange()
    -- body
    if 0 == self.c1.selectedIndex then
        self.lab1.text = language.xiantong05
    else
        self.lab1.text = language.xiantong06
    end
end

function XianTongTongFang:onBtnCallBack( context )
    -- body
    --发送请求
    local btn = context.sender
    if 0 == self.c1.selectedIndex then
        local param = {}
        if "n16" == btn.name then
            param.reqType = 2
        else
            param.reqType = 1
        end
        param.times = self.data.times
        proxy.MarryProxy:sendMsg(1390501,param)
    end

    self:closeView()
end

function XianTongTongFang:addMsgCallBack(data)
    -- body

end

return XianTongTongFang