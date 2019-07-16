--
-- Author: 
-- Date: 2018-08-06 11:34:11
--

local ZeroXianTong = class("ZeroXianTong",import("game.base.Ref"))

function ZeroXianTong:ctor(mParent)
    self.mParent = mParent
    self.view = self.mParent.view:GetChild("n12")
    self:initView()
end

function ZeroXianTong:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 1

    self.labtop1 = self.view:GetChild("n18")
    self.labtop1.text = ""
    self.labtop2 = self.view:GetChild("n19")
    self.labtop2.text = ""

   
    local dec1 = self.view:GetChild("n17")
    dec1.text = language.xiantong01


    self.item1 = self.view:GetChild("n9")
    self.lab1 = self.view:GetChild("n15")

    self.item2 = self.view:GetChild("n10")
    self.lab2 = self.view:GetChild("n16")

    self.listView = self.view:GetChild("n8")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    --self.listView:SetVirtual()
    self.listView.numItems = 0

    local btn1 = self.view:GetChild("n11")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.view:GetChild("n12")
    btn2.onClick:Add(self.onBtnCallBack,self)
    self.btnRed = self.view:GetChild("red")
end

function ZeroXianTong:celldata( index, obj )
    -- body
    local data = self.reward2[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = 1
    t.bind = data[3]
    GSetItemData(obj, t, true)
end

function ZeroXianTong:setData()
    -- body
    --self.data = cache.PlayerCache:getData()
    --local sex = cache.PlayerCache:getSex() 
    if cache.PlayerCache:getSex() == 1 then
        self.labtop1.text = string.format(language.kuafu87,cache.PlayerCache:getRoleName())
        self.labtop2.text = string.format(language.kuafu88,cache.PlayerCache:getCoupleName())
    else
        self.labtop1.text = string.format(language.kuafu87,cache.PlayerCache:getCoupleName())
        self.labtop2.text = string.format(language.kuafu88,cache.PlayerCache:getRoleName())
    end

    if cache.PlayerCache:getCoupleName() ~= "" then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end

    --设置奖励
    local reward1 = conf.MarryConf:getXTRewardPoolByType(2)
    for k ,v in pairs(reward1) do
        --printt("v",v)
        if k > 2 then
            break
        end
        local itemObj = self["item"..k]
        local lab = self["lab"..k]
        local t = {}
        t.mid = v[1]
        t.amount = v[2]
        t.bind = v[3]
        GSetItemData(itemObj, t, true)
        --print(v[1],"t.mid")
        lab.text = mgr.TextMgr:getColorNameByMid(t.mid)
    end

    self.reward2 = conf.MarryConf:getXTRewardPoolByType(1)
    self.listView.numItems = #self.reward2

end

function ZeroXianTong:setVisible( flag )
    -- body
    self.view.visible = flag
    self.btnRed.visible =  cache.PlayerCache:getRedPointById(10263) > 0
end

function ZeroXianTong:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local key = btn.name
    if "n11" == key then
        if self.c1.selectedIndex == 0 then
            --洞房
            mgr.ViewMgr:openView2(ViewName.XianTongtfhz)
        else
            --前往结婚
            if mgr.FubenMgr:checkScene() then
                GComAlter(language.gonggong41)
                return
            end
            local mainTaskId = cache.TaskCache:getCurMainId()
            --print("mainTaskId",mainTaskId)
            if mainTaskId ~= 0 and  mainTaskId <= 1014 then
                GComAlter(language.task20)
                return
            end
            
            mgr.TaskMgr:setCurTaskId(9003)
            mgr.TaskMgr.mState = 2
            mgr.TaskMgr:resumeTask()
        end
    elseif "n12" == key then
        --培养仙童
        self.mParent:goToById(1304)
    end
end

return ZeroXianTong