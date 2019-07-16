--
-- Author: 
-- Date: 2018-08-06 14:37:13
--

local XianTongtfhz = class("XianTongtfhz", base.BaseView)

function XianTongtfhz:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
end

function XianTongtfhz:initView()
    local btn = self.view:GetChild("n23")
    self:setCloseBtn(btn)

    local btnGuize = self.view:GetChild("n22")
    btnGuize.onClick:Add(self.onBtnCallBack,self)

    local btnstart = self.view:GetChild("n11")
    btnstart.onClick:Add(self.onBtnCallBack,self)

    self.leftmodepanel = self.view:GetChild("n31")
    self.rightmodepanel = self.view:GetChild("n32")

    local dec1 = self.view:GetChild("n26")
    dec1.text = language.xiantong03

    self.labcost = self.view:GetChild("n28")
    self.labcost.text = ""

    self.n24 = self.view:GetChild("n24") 
    self.labtimer = self.view:GetChild("n25")
    self.labtimer.text = ""

    self.listView = self.view:GetChild("n20")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    --self.listView:SetVirtual()
    self.listView.numItems = 0

    self.btncheck = self.view:GetChild("n33")
    --self.btncheck.onClick:Add(self.onBtnCallBack,self)

    self.view:GetChild("n34").text = language.xiantong30
end

function XianTongtfhz:initData()
    -- body
    --避免切换场景
    if not mgr.FubenMgr:checkScene() then
        mgr.TaskMgr:stopTask()
    end


    self.n24.visible = false
    self.leftmode = nil 
    self.rightmode = nil

    self.btncheck.selected = false

    local condata = conf.MarryConf:getPetItem(conf.ItemConf:getItemExt(PackMid.xiantong_nan))
    local condata1 = conf.MarryConf:getPetItem(conf.ItemConf:getItemExt(PackMid.xiantong_nv))
    --print(condata.model.."@",condata1.model,"#######")
    self:initModel(self.leftmodepanel,self.leftmode,condata.model)
    self:initModel(self.rightmodepanel,self.rightmode,condata1.model)

    self.labcost.text = conf.MarryConf:getXTValue("df_cost") --费用

    self.reward1 = conf.MarryConf:getXTRewardPoolByType(2)
    local confdata = conf.MarryConf:getXTRewardPoolByType(1)
    for k ,v in pairs(confdata) do
        table.insert(self.reward1,v)
    end
    
    self.listView.numItems = #self.reward1
end

function XianTongtfhz:onTimer()
    -- body
    if not self.data then
        return
    end
    self.overtime = math.max(self.overtime - 1,0)
    if self.overtime > 0 then
        self.n24.visible = true
        self.labtimer.text = string.format(language.xiantong04,self.overtime)
    else
        self.n24.visible = false
        self.labtimer.text = ""
    end
end

function XianTongtfhz:initModel(p,m,id)
    -- body
    m = self:addModel(id,p)
    m:setRotationXYZ(0,180,0)
    m:setPosition(48.6,-288.2,500)
end

function XianTongtfhz:celldata(index, obj)
    local data = self.reward1[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3]
    GSetItemData(obj, t, true)
end

function XianTongtfhz:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local key = btn.name 

    if key == "n22" then
        GOpenRuleView(1119)
    elseif key == "n11" then
        if cache.PlayerCache:getTypeMoney(MoneyType.gold)  < conf.MarryConf:getXTValue("df_cost") then
            GOpenView({id = 1042})
            return
        end
        local param = {}
        param.reqType = 0
        param.times = self.btncheck.selected and 10 or 1

        proxy.MarryProxy:sendMsg(1390501,param)
    end
end

function XianTongtfhz:addMsgCallBack(data)
    -- body
    if 5390501 == data.msgId then
        self.data = data    
        if data.reqType == 0 then
            self.overtime = conf.MarryConf:getXTValue("tongfang_requst_overtime")-1
            self:addTimer(1,self.overtime,handler(self,self.onTimer))  
        end
    end
end

return XianTongtfhz