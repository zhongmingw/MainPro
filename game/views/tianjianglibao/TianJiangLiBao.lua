--
-- Author: 
-- Date: 2018-11-20 11:59:52
--

local TianJiangLiBao = class("TianJiangLiBao", base.BaseView)

local pox = {385,281}
function TianJiangLiBao:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function TianJiangLiBao:initView()
   local closeBtn = self.view:GetChild("n1")
   self:setCloseBtn(closeBtn)
   self.lastTime = self.view:GetChild("n12")
   self.listView1 = self.view:GetChild("n15")
   self.listView1.itemRenderer = function(index,obj)
        self:cellData(index, obj)
   end
   self.c1 = self.view:GetController("c1")
   self.tex1 = self.view:GetChild("n8")
   self.progress = self.view:GetChild("n18")
   self.btn1 = self.view:GetChild("n5")
   self.btneffect = self.view:GetChild("n29")

   self.btnList = {}
   for i = 22,26 do 
       local btn = self.view:GetChild("n"..i)
       btn.visible = false
       btn.touchable = false
       self.btnList[i-21] = btn
   end
   self.titleIcon = self.view:GetChild("n9")
end

function TianJiangLiBao:setData(data)
    self.data = data
    printt(self.data,"天降礼包")
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "tianjianglibao_002"
    self.titleIcon.url = UIPackage.GetItemURL("tianjianglibao" , titleIconStr)

    self.pre = self.mulConfData.award_pre

    if data.reqType == 1 then
        GOpenAlert3(data.items,true)
    end
    self.gotSigns = {}
    for k,v in pairs(self.data.gotSigns) do
        self.gotSigns[k] = v
    end   
    self.chooseQuota = nil
    self.choosecid = nil
    self.confData = {}
    self.confData1 = conf.ActivityConf:TianJiangLiBaoquata(self.data.type,self.pre)
    self:updateJinDuTiao()


    self:releaseTimer()
    self.time = self.data.leftTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function TianJiangLiBao:updateJinDuTiao()
    self.tex1.text =  self.data.czSum..""
    local fenduanshu = #self.confData1
    
    local promax = self.confData1[#self.confData1].quota
    for k,v in pairs(self.confData1) do
        self.btnList[k].visible = true
        self.btnList[k].touchable = true
        self.btnList[k].data = {quota = v.quota,index = k,cid = v.id}
        self.btnList[k].onClick:Add(self.XianShi,self)
        self.confData[v.quota] = conf.ActivityConf:TianJiangLiBao(self.data.type,v.quota,self.pre)
        self.btnList[k]:GetChild("n22"):GetChild("title").text = ""..v.quota 
        -- local  addpox  = (v.quota/promax)*self.progress.width -62
        local addpox = ((self.progress.width-28)/fenduanshu)*k - 48
        self.btnList[k]:SetXY( pox[1]+ addpox,pox[2])
        if promax == v.quota then
            self.btnList[k]:GetChild("n21").visible= false
            self.btnList[k]:SetXY( pox[1]+ self.progress.width-74 ,pox[2])
        end   
    end
    for k,v in pairs(self.confData1) do
        if self.data.czSum >= v.quota and not self.gotSigns[v.id] then --没选择时
            self.chooseQuota = self.confData1[k].quota
            self.choosecid  = v.id
            self.btnList[k].onClick:Call() 
            break
        elseif self.data.czSum < v.quota then
            self.chooseQuota = self.confData1[k].quota
            self.choosecid  = v.id
            self.btnList[k].onClick:Call() 
            break
        end
    end

    if self.chooseQuota == nil then  
        if self.data.czSum >= promax then
            self.chooseQuota = self.confData1[#self.confData1].quota
            self.choosecid = self.confData1[#self.confData1].id
            self.btnList[#self.confData1].onClick:Call()
        else
             self.chooseQuota = self.confData1[1].quota
             self.choosecid = self.confData1[1].id
              self.btnList[1].onClick:Call()
        end
    end


    local num = 100
    self.progress.max = num
    local a = false
    local numvalue = math.floor(num/fenduanshu )
    for k,v in pairs(self.confData1) do
        self.progress.value = 0
        if self.data.czSum >=  v.quota then
            self.progress.value = k*numvalue 
            if (k+1) <= #self.confData1   then
                if self.confData1[k+1].quota >= self.data.czSum then
                        self.progress.value = self.progress.value + (((self.data.czSum- v.quota)/(self.confData1[k+1].quota- v.quota))*numvalue)
                    return
                end
            end
            a= true
        end
    end
    if not a then
        self.progress.value = (self.data.czSum/(self.confData1[1].quota))*numvalue 
    end
    
end



function TianJiangLiBao:cellData(index,obj)
    local data = self.confData[self.chooseQuota]
    local itemData = {mid = data[1][index+ 1][1],amount = data[1][index+ 1][2],bind = data[1][index+ 1][3]}
    GSetItemData(obj,itemData,true) 

end

function TianJiangLiBao:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

function TianJiangLiBao:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function TianJiangLiBao:goTo(context)
    local data = context.sender.data
    if data.index == 1 then
        proxy.ActivityProxy:send(1030656,{reqType = 1,cid = self.choosecid})
    elseif data.index == 2 then
        GOpenView({id = 1042})
    end

end



function TianJiangLiBao:XianShi(context)
    local data = context.sender.data
    self.chooseQuota = data.quota
    self.choosecid = data.cid
    self.btneffect:SetXY(self.btnList[data.index].x+1,313)
    self.listView1.numItems = #self.confData[data.quota][1]
    -- print(self.gotSigns[self.choosecid],"shifouyongyou ")
    if self.gotSigns[self.choosecid] then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
        self.btn1:RemoveEventListeners()
        if self.data.czSum >=  data.quota then
            self.btn1:GetChild("red").visible = true
            self.btn1.data = {cid =  data.cid ,index = 1}
            self.btn1.onClick:Add(self.goTo,self)
            self.btn1:GetChild("title").text  =  language.friend22
        else
            self.btn1:GetChild("red").visible = false
            self.btn1.data = {cid =  data.cid ,index = 2}
            self.btn1.onClick:Add(self.goTo,self)
             self.btn1:GetChild("title").text  =  language.kaifu14
        end
    end

end

return TianJiangLiBao