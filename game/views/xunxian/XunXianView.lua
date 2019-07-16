--
-- Author: 
-- Date: 2018-07-16 15:21:42
--寻仙探宝

local XunXianView = class("XunXianView", base.BaseView)

local BoxIcon = {
    [1] = "ui://xunxian/xunxiantanbao_010",--白银未开
    [2] = "ui://xunxian/xunxiantanbao_011",--白银已开
    [3] = "ui://xunxian/xunxiantanbao_012",--黄金未开
    [4] = "ui://xunxian/xunxiantanbao_013",--黄金已开
}


function XunXianView:ctor()
    XunXianView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XunXianView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n6")
    closeBtn.onClick:Add(self.onBtnClose,self)
    -- local ruleTxt = self.view:GetChild("n9")  
    -- ruleTxt.text =  mgr.TextMgr:getTextColorStr(language.xunXian01,6,"")
    -- ruleTxt.onClickLink:Add(self.onClickRule,self)
    local ruleBtn = self.view:GetChild("n15")
    ruleBtn.onClick:Add(self.onClickRule,self)
    local dec = self.view:GetChild("n7")
    dec.text = language.xunXian02
    self.lastTime = self.view:GetChild("n8")

    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function ( index,obj )
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()

    self.oneBtn = self.view:GetChild("n13")
    self.oneBtn.icon = UIItemRes.xunXian[1]
    self.oneBtn.data = 1
    self.oneBtn.onClick:Add(self.goFind,self)

    self.allBtn = self.view:GetChild("n14")
    self.allBtn.icon = UIItemRes.xunXian[2]
    self.allBtn.data = 2
    self.allBtn.onClick:Add(self.goFind,self)

    
    self.playerPanel = self.view:GetChild("n11")
    self.zuoqiPanel = self.view:GetChild("n12")
    --宝箱
    self.allBox = {}
    for i=1,8 do
        local com = self.view:GetChild("n10"..i)
        table.insert(self.allBox,com)
    end

end
function XunXianView:initData()
    self.effectImg = self.view:GetChild("n31")
    self.effect = self:addEffect(4020160, self.effectImg)
    self.effect.Scale = Vector3.New(100,100,100)
    -- self.effect.LocalPosition = Vector3.New()

    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 0
    self:initModel()
end
function XunXianView:initModel()
    local suitid = {3010313,3040308,3020413} --防止配置报错，加一个固定模型
    local sex = cache.PlayerCache:getSex()
    if sex == 1 then
        suitid  = conf.ActivityConf:getHolidayGlobal("xxtb_boy_suit_id")
    else
        suitid = conf.ActivityConf:getHolidayGlobal("xxtb_girl_suit_id")
    end
    --人物
    local player = self:addModel(suitid[1],self.playerPanel)
    player:setSkins(suitid[1], suitid[3])--添加武器
    player:setScale(140)
    player:setRotationXYZ(0,166,0)
    player:setPosition(45,-170,100)
    --坐骑
    local zuoqi = self:addModel(suitid[2],self.zuoqiPanel)
    zuoqi:setScale(80)
    zuoqi:setRotationXYZ(19,90,0)
    zuoqi:setPosition(50,-281,338)

end
function XunXianView:cellData( index,obj )
    local data = self.confData[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end

function XunXianView:setData(data)
    self.data = data
    printt("寻仙探宝>>>",data)
    self.time = data.lastTime
    
    self.confData = conf.ActivityConf:getHolidayGlobal("xxtb_show_awadr")
    self.listView.numItems = #self.confData
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    local leftBoxNum = 0--剩余箱子个数
    for k,v in pairs(data.boxInfos) do
        if (v % 100) == 1 then
            leftBoxNum = leftBoxNum + 1
        end
    end
    --设置按钮
    self:setBtnShow(leftBoxNum)
    --设置宝箱显示
    self:setBoxShow(data.boxInfos)
end

function XunXianView:setBtnShow(leftBoxNum)
    local oneCost = conf.ActivityConf:getHolidayGlobal("xxtb_one_cost")
    self.oneBtn.title = oneCost
    self.allBtn.title = oneCost*leftBoxNum
end

--设置宝箱显示
function XunXianView:setBoxShow(boxInfos)
    for k,v in pairs(boxInfos) do
        local com = self.allBox[k]
        com.data = k
        com.onClick:Add(self.onChoose,self)
        local boxType = math.floor(v / 100)
        local boxIcon = com:GetChild("n1")
        if boxType == 1 then--白银宝箱
            local state = v % 100
            if state == 1 then--未开
                boxIcon.url = BoxIcon[1]
                com.touchable = true
            elseif state == 2 then--已开
                boxIcon.url = BoxIcon[2]
                com.touchable = false
            end            
        elseif boxType == 2 then--黄金宝箱
            local state = v % 200
            if state == 1 then--未开
                boxIcon.url = BoxIcon[3]
                com.touchable = true
            elseif state == 2 then--已开
                boxIcon.url = BoxIcon[4]
                com.touchable = false
            end  
        end
    end
end


function XunXianView:onChoose(context)
    local data = context.sender.data
    self.tsIndex = data
end

function XunXianView:goFind(context)
    local data = context.sender.data
    if data == 1 then
        if not self.tsIndex then
            GComAlter(language.xunXian03)
            return
        else
            proxy.ActivityProxy:sendMsg(1030213,{reqType = 1,tsIndex = self.tsIndex})
            self.c1.selectedIndex = 0--一个都不选
            self.tsIndex = nil
        end
    elseif data == 2 then
        proxy.ActivityProxy:sendMsg(1030213,{reqType = 2,tsIndex = 0})
        self.c1.selectedIndex = 0--一个都不选
    end
end
function XunXianView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end


function XunXianView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function XunXianView:onClickRule()
    GOpenRuleView(1102)
end

function XunXianView:onBtnClose()
    self.randomCfgId = nil
    self:releaseTimer()
    self:closeView()
end

return XunXianView