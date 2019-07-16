--
-- Author: 
-- Date: 2019-01-02 15:19:50
--
--登陆有礼
local Xn1001 = class("Xn1001",import("game.base.Ref"))

function Xn1001:ctor(parent,id)
    self.moduleId = id
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Xn1001:onTimer()
    -- body

    if not self.data then return end
    local severTime =  mgr.NetMgr:getServerTime()
    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.XiaoNianView)
        if view then
            view:closeView()
        end
    end
end

function Xn1001:addMsgCallBack( data )
    printt(data)

    self.data = data
    GOpenAlert3(data.items,true)
    
    self.curDay = data.curDay
    if self.data.czSum > 0 then
        self.tex.text = language.xiaonian2019_06
    else
        self.tex.text = language.xiaonian2019_05
    end
    self.c1.selectedIndex = 0 
    if self.data.gotSign == 2 then
        self.c1.selectedIndex = 1
    elseif self.data.gotSign == 0 then
        if self.data.scoreMap[3] then
            self.getBtn:GetChild("icon").grayed = false
            self.getBtn:GetChild("red").visible = true
        else
            self.getBtn:GetChild("icon").grayed = true
            self.getBtn:GetChild("red").visible = false
        end
    elseif self.data.gotSign == 1 then
        if self.data.czSum > 0 then
            self.getBtn:GetChild("icon").grayed = false
            self.getBtn:GetChild("red").visible = true
        else
            self.getBtn:GetChild("icon").grayed = true
            self.getBtn:GetChild("red").visible = false
        end
    end

    self.getBtn.data = {state = self.getBtn:GetChild("icon").grayed }
    self.getBtn.onClick:Add(self.onClickGet,self)

    for k,v in pairs(self.coms) do
        local  item = v:GetChild("icon")
        if self.data.typeMap[k] and v.data.selectedId == k then
            -- local num = math.random(0,3)
            -- local  index = self.data.typeMap[k]*self.data.scoreMap[k]
            local  index = 13*(self.data.typeMap[k]-1)+ self.data.scoreMap[k]
            local name = conf.XiaoNianConf:getPuKe(index).name
            item.url =  UIPackage.GetItemURL("_others" , name)--
        else
            item.url =  UIPackage.GetItemURL("xiaonian" , "huanjuxiaonian_003")--背面
        end
    end
    local score = 0
    for k,v in pairs(self.data.scoreMap) do
        score = score + v
    end
    self.scoreText.text = string.format(language.xiaonian2019_07,score)
    self.timeText.text = GToTimeString12(data.actStartTime).."-"..GToTimeString12(data.actEndTime)

     if not self.actTimer then
        self:onTimer()
        self.actTimer = self.parent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function Xn1001:initView()
    -- body
    self.timeText = self.view:GetChild("n5") 
    self.decText = self.view:GetChild("n6")
    self.decText.text = language.xiaonian2019_01
    self.scoreText = self.view:GetChild("n9")
    self.scoreText.text = ""

    self.coms ={}
    for i=21,23 do 
        local btn = self.view:GetChild("n"..i)
        local txt = btn:GetChild("n1")
     
        txt.text = string.format(language.xiaonian2019_04,i-20)
        btn.data = {selectedId = i-20}
        btn.onClick:Add(self.onClickFanPai,self)
        table.insert(self.coms, btn)
    end

    self.listView1 = self.view:GetChild("n16")
    self.listView1.itemRenderer = function (index, obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.confData = conf.XiaoNianConf:getLogin()
    self.listView1.numItems = #self.confData
    self.getBtn = self.view:GetChild("n7")
    self.tex = self.view:GetChild("n10")


    self.c1 = self.view:GetController("c1")

end

function Xn1001:onClickFanPai( context )
    local data = context.sender.data
    if self.data.typeMap[data.selectedId] then
        GComAlter("已经翻过牌了")
        return
    end
    if self.data.curDay > data.selectedId then
         GComAlter("不能翻前天的牌")
         return
    end
    -- if self.data.curDay ~= self.data.scoreMap
    if not self.data.typeMap[self.data.curDay] and data.selectedId == self.data.curDay then
        proxy.XiaoNianProxy:sendMsg(1030703,{reqType = 1})
    end

end

function Xn1001:onClickGet( context )
    local data = context.sender.data
    print(data.state)
    if data.state then
        GComAlter(language.czccl08)
    else
        proxy.XiaoNianProxy:sendMsg(1030703,{reqType = 2})
    end

end

function Xn1001:cell1data( index,obj )
    -- body
    local data = self.confData[index+1]
    if data.items then
        local list = obj:GetChild("n18")
        list.itemRenderer = function (index, obj)
            local  data = data.items[index +1]
            local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
            GSetItemData(obj, itemInfo, true)
        end
        list.numItems = #data.items
    end
    local txt = obj:GetChild("n17")
    txt.text = string.format(language.xiaonian2019_03,data.score[1],data.score[2])

end



return Xn1001