--
-- Author: yr
-- Date: 2017-04-12 14:41:33
--

local DeadView = class("DeadView", base.BaseView)

function DeadView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function DeadView:initView()
    self.c1 = self.view:GetController("c1")--主控制器
    self.label = self.view:GetChild("n3")
    local btn1 = self.view:GetChild("n10")
    btn1.onClick:Add(self.onClickRevive1, self)
    local btn2 = self.view:GetChild("n11")
    self.time = self.view:GetChild("n14")    
    btn2.onClick:Add(self.onClickRevive2, self)
    self.timeDesc = self.view:GetChild("n18")--特殊复活弹窗倒计时描述
    self.view:GetChild("n19").text = language.dead02
end

function DeadView:initData(data)
    self.data = data
    local deadTime = mgr.NetMgr:getServerTime()
    local time = os.date("*t",deadTime)
    local name = data.atkName
    local sId = cache.PlayerCache:getSId()
    -- if mgr.FubenMgr:isWenDing(sId) then
    --     name = language.wending06[1]
    -- end
    local textData = {
                {text="["..time.hour..":"..time.min..":"..time.sec.."]" .. "被",color = 5},
                {text=name,color = 14},
                {text=language.fuben09,color = 5},
            }
    self.label.text = mgr.TextMgr:getTextByTable(textData)
    local item = self.view:GetChild("n4")
    local itemName = self.view:GetChild("n5")
    itemName.text = conf.ItemConf:getName(221011006) or ""
    local info = {mid = 221011006}
    GSetItemData(item,info,true)
    local costYb = conf.SysConf:getValue("cur_revive_cost")
    self.view:GetChild("n9").text = costYb..language.store04
    self.view:GetChild("n20").text = language.store13
    --复选框
    self.checkBox = self.view:GetChild("n7")
    self.checkBox.onChanged:Add(self.onCheck,self)
    local reviveSec = 10
    if data.reviveType == 3 then--特殊复活
        self.c1.selectedIndex = 1
        reviveSec = conf.SysConf:getValue("screen_revive_sec")
        local buffstack = conf.SysConf:getValue("boss_dead_buff_stack")
        self.strTab = clone(language.dead01)
        self.strTab[2].text = string.format(self.strTab[2].text, buffstack)
        self.strTab[6].text = string.format(self.strTab[6].text, reviveSec)
        self.timeDesc.text = mgr.TextMgr:getTextByTable(self.strTab)
    else
        self.c1.selectedIndex = 0
        reviveSec = 10
    end
    self.overTime = reviveSec
    self.time.text = self.overTime
    self:addTimer(1, -1, handler(self,handler(self,self.onTimer)))
end

function DeadView:setData(data_)

end

function DeadView:onCheck()
    -- body
    self.isSelect = self.checkBox.selected
end

function DeadView:onTimer()
    -- body
    if self.overTime <= 0 then
        self:onClickRevive1()
        return
    end
    self.overTime = self.overTime - 1
    if self.data.reviveType == 3 and self.strTab then
        self.strTab[6].text = self.overTime
        self.timeDesc.text = mgr.TextMgr:getTextByTable(self.strTab)
    end
    self.time.text = self.overTime
end

function DeadView:onClickRevive1()
    proxy.ThingProxy:sRevive(3)
end
function DeadView:onClickRevive2()
    if self.isSelect then
        proxy.ThingProxy:sRevive(2)
    else
        proxy.ThingProxy:sRevive(1)
    end
end

return DeadView