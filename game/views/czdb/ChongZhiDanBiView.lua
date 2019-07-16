--
-- Author: 
-- Date: 2018-08-04 19:40:05
--

local ChongZhiDanBiView = class("ChongZhiDanBiView", base.BaseView)

function ChongZhiDanBiView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ChongZhiDanBiView:initView()
   local closeBtn = self.view:GetChild("n0"):GetChild("n7")
   self:setCloseBtn(closeBtn)
   self.lastTime = self.view:GetChild("n12")
   self.listView = self.view:GetChild("n18")
   self.Text_1 = self.view:GetChild("n4") 
   self.Text_2 = self.view:GetChild("n7")
   self.titleIcon = self.view:GetChild("n19")
   self.listView.itemRenderer = function ( index,obj)
        self:celldata(index,obj)
   end     
end

function ChongZhiDanBiView:setData(data)
    self.data = data
    printt(data)
    if data and #data.items >0 then
        GOpenAlert3(data.items,true)
    end     
    self.Itemlist = conf.ActivityConf:getCzdbAwards(self.data.mulActId)
    self.Text_1.text = string.format(language.czdb03,
        mgr.TextMgr:getTextColorStr(tostring(self.Itemlist[1].quota),7),
        mgr.TextMgr:getTextColorStr(tostring(self.Itemlist[2].quota),7),
        mgr.TextMgr:getTextColorStr(tostring(self.Itemlist[3].quota),7)) 
    self.Text_2.text = language.czdb02
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "chaozhidanbi_001"
    self.titleIcon.url = UIPackage.GetItemURL("czdb" , titleIconStr)
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.listView.numItems = 3  
end

function ChongZhiDanBiView:celldata(index,obj )
    local data = self.Itemlist[index+ 1]
    if self.data then
        if self.data.actDay == 2  then   --取Excel表下对应天数的那一行数据,写死了
         data = self.Itemlist[index+ 1+3]
        elseif self.data.actDay == 3  then
         data = self.Itemlist[index+ 1+6]
        end
        local t = {}
        t.mid = data.awards[1][1]
        t.amount = data.awards[1][2]
        t.bind = data.awards[1][3]
        local item = obj:GetChild("n7")
        GSetItemData(item,t,true)
        local icon = obj:GetChild("n5")
        local priceText = obj:GetChild("n3")
        local bar = obj:GetChild("n6")
        local priceText1 = obj:GetChild("n9") --显示
        priceText1.text = data.quota
        if bar then
          bar.value = self.data.quota
          bar.max = data.quota 
          local barNum = bar:GetChild("title") --获取进度条下数字
           if self.data.quota <= data.quota then
              barNum.text = self.data.quota.."/"..data.quota
            else 
              barNum.text = data.quota.."/"..data.quota
           end
        end 
        local currentday = self.data.actDay
        local dataId = tonumber(string.sub(data.id,1,1))
        local dayIndex = tonumber(string.sub(data.id,4,4))
        local str = mgr.TextMgr:getTextColorStr(tostring(data.rmb),3)
        priceText.text = string.format(language.czdb01,str)
        icon.url = UIItemRes.chongzhiDanBi[1]    
        local btn = obj:GetChild("n1") 
        local controller = obj:GetController("c1")
          controller.selectedIndex = 0
        if #self.data.gotData>0 then
            for i=1,#self.data.gotData do
               if data.id == self.data.gotData[i] then
                 controller.selectedIndex = 1
               end
            end
        end
        if controller.selectedIndex == 0 then --前往充值 or 马上领取
            if self.data.quota < data.quota then 
             btn:GetChild("icon").url = UIItemRes.chongzhiDanBi[5] 
             btn:GetChild("red").visible = false
             data.go = 0
            else
             btn:GetChild("icon").url = UIItemRes.chongzhiDanBi[4] 
             btn:GetChild("red").visible = true
             data.go = 1  
            end
        end
        btn.data = data
        btn.onClick:Add(self.onChoose,self)
    end
   
end


function ChongZhiDanBiView:onTimer()
    if not self.data then
        return
    end
    self.data.lastTime = math.max(self.data.lastTime - 1 , 0 ) 
    if self.data.lastTime <= 0 then
        self:closeView()
        self:releaseTimer()
        return
    end
    self.lastTime.text = GGetTimeData4(self.data.lastTime)
end

function ChongZhiDanBiView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function ChongZhiDanBiView:onChoose(context)
    if not self.data then
        return
    end
    local data = context.sender.data
    if data.go == 1 then
        printt(data)
        proxy.ActivityProxy:sendMsg(1030232,{reqType = 1,cid = data.id})
         local var = cache.PlayerCache:getRedPointById(20197)
        cache.PlayerCache:setRedpoint(20197,var-1)
        local mainview = mgr.ViewMgr:get(ViewName.MainView)
        if mainview then
            mainview:refreshRed()
        end
    else
          self:releaseTimer()
          self:closeView()
          mgr.ModuleMgr:OpenView({id = 1042})
    end
end

return ChongZhiDanBiView