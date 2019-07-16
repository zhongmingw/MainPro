--
-- Author: 
-- Date: 2018-08-06 15:24:18
--

local XianTongchoose = class("XianTongchoose", base.BaseView)

function XianTongchoose:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongchoose:initView()
    self.leftmodepanel = self.view:GetChild("n10")
    self.rightmodepanel = self.view:GetChild("n15")

    self.leftname = self.view:GetChild("n12")
    self.rightname = self.view:GetChild("n17")

    self.lab1 = self.view:GetChild("n13")
    self.lab2 = self.view:GetChild("n18")

    self.labtimer = self.view:GetChild("n20") 

    self.btn1 = self.view:GetChild("n11")
    self.btn1.onClick:Add(self.onCheck,self)

    self.btn2 = self.view:GetChild("n16")
    self.btn2.onClick:Add(self.onCheck,self)
end

function XianTongchoose:initData(roleId)
    self.choose = true
    if roleId and roleId == cache.PlayerCache:getRoleId() then
        self.choose = false
    end

    self.myChoose = nil
    self.otherChoose = nil

    self.lab1.text = ""
    self.lab2.text = ""

    self.leftmode = nil 
    self.rightmode = nil

    local condata = conf.MarryConf:getPetItem(conf.ItemConf:getItemExt(PackMid.xiantong_nan))
    local condata1 = conf.MarryConf:getPetItem(conf.ItemConf:getItemExt(PackMid.xiantong_nv))
    self:initModel(self.leftmodepanel,self.leftmode,condata.model)
    self:initModel(self.rightmodepanel,self.rightmode,condata1.model)

    self.leftname.text = condata.name
    self.rightname.text = condata1.name

    self.btn1.selected = false
    self.btn2.selected = false

    self.btn1.visible = self.choose
    self.btn2.visible = self.choose

    self.overtime = 30
    self:addTimer(1,self.overtime,handler(self,self.onTimer))
end

function XianTongchoose:onTimer()
    -- bod
   
    self.overtime = self.overtime - 1
    if self.overtime<=0 then
        --检测是否有选择
        if self.choose then
            if not self.myChoose then
                local param = {}
                param.reqType = 0
                param.awardId = cache.MarryCache:getAwardId()
                if math.random(100)< 50 then
                    param.mid = PackMid.xiantong_nan
                else
                    param.mid = PackMid.xiantong_nv
                end
                proxy.MarryProxy:sendMsg(1390502,param)
            end
        end
        self:closeView()
        return 
    end
    if self.choose then
        self.labtimer.text = string.format(language.xiantong08,self.overtime)
    else
        self.labtimer.text = language.xiantong28
    end
end

function XianTongchoose:initModel(p,m,id)
    -- body
    m = self:addModel(id,p)
    m:setRotationXYZ(0,180,0)
    m:setPosition(48.6,-265,400)
end

function XianTongchoose:onCheck(context)
    -- body
    local btn = context.sender
    local name = btn.name 
    local param = {}
    param.reqType = 0
    param.awardId = cache.MarryCache:getAwardId()
    if name == "n11" then
        --左
        param.mid = PackMid.xiantong_nan
    else
        --右
        param.mid = PackMid.xiantong_nv
    end
    proxy.MarryProxy:sendMsg(1390502,param)
end

function XianTongchoose:addMsgCallBack(data,param)
    -- body
    --0:对方选择 1:坚持选择 2:同意更换
    if data.msgId == 8170202 then
        --print("8170202 . mid ",data.mid)
        self.myChoose = data.mid
    elseif data.msgId == 5390502 then
        self.myChoose = param.mid 
    end
    self:onCloseView()
end

function XianTongchoose:onCloseView()
    -- body
    --显示最后自己的选择
    --print("最后的选择",self.myChoose)
    mgr.ViewMgr:openView2(ViewName.GuideZuoqi,{index = 16,mid = self.myChoose})
    self:closeView()
end
return XianTongchoose