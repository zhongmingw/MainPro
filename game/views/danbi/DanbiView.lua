--
-- Author: 
-- Date: 2018-07-25 14:53:04
--

local DanbiView = class("DanbiView", base.BaseView)

function DanbiView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function DanbiView:initView()
    local btnclose = self.view:GetChild("n4")
    self:setCloseBtn(btnclose)
    self.titleIcon = self.view:GetChild("n0")


    self.listView = self.view:GetChild("n2")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self.c1 = self.view:GetController("c1")

    self.time1 = self.view:GetChild("n8") 

    local btn = self.view:GetChild("n6") 
    btn.onClick:Add(self.onGetCall,self)
end

function DanbiView:initData(data)
    if data then
        self:addMsgCallBack(data)
    end

    

    if self.timer then
        self:removeTimer(self.timer)
    end
    self.timer = self:addTimer(1,-1,handler(self, self.onTimer))


end

function DanbiView:onTimer( ... )
    -- body
    if not self.data then
        self.time1.text = ""
        return 
    end
    self.data.lastTime = math.max(self.data.lastTime - 1,0) 
    self.time1.text = GGetTimeData2(self.data.lastTime)
    if self.data.lastTime<= 0 then
        self:closeView()
    end
end

function DanbiView:celldata(index, obj)
    -- body
    local data = self.condata[1].awards[index + 1]
    local itemobj = obj:GetChild("n0")
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    GSetItemData(itemobj, t, true)

    local name = obj:GetChild("n1")
    name.text = mgr.TextMgr:getColorNameByMid(t.mid) 
end

function DanbiView:onGetCall()
    -- body
    if self.c1.selectedIndex == 2 then
        return GComAlter(language.danbi01)
    elseif self.c1.selectedIndex == 1 then
        local param = {}
        param.reqType = 1
        proxy.ActivityProxy:sendMsg(1030225,param)
    else
        GOpenView({id = 1042})
        
    end

end

function DanbiView:addMsgCallBack(data)
    -- body
    self.data = data 
    print("多开id",data.mulActId)
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "danbihaoli_003"
    self.titleIcon.url = UIPackage.GetItemURL("danbi" , titleIconStr)
     --前缀
    local pre = self.mulConfData.award_pre
    self.condata = conf.ActivityConf:getDanBiAward(pre)
    local minQuota = self.condata[1].min_quota
    self.view:GetChild("n10").text = minQuota / 10
    if data.gotFlag == 1 then
        self.c1.selectedIndex = 2

         mgr.GuiMgr:redpointByVar(20194,0,1)
    else
        if data.czYb >= minQuota then
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 0
        end
    end


    self.listView.numItems = #self.condata[1].awards

    GOpenAlert3(data.items)
end

return DanbiView