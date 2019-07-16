--
-- Author: 
-- Date: 2019-01-07 20:51:08
--

local Xn1002 = class("Xn1004",import("game.base.Ref"))

function Xn1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]

    self:initView()
end

function Xn1002:initView()

    self.timeText = self.view:GetChild("n97")
    self.decText = self.view:GetChild("n98")
    self.decText.text = language.xiaonian2019_13
    self.listView = self.view:GetChild("n107")
    self.listView.itemRenderer = function (index, obj)
        self:cell1data(index, obj)
    end
 
    local  guideBtn = self.view:GetChild("n99")
    guideBtn.onClick:Add(self.guide,self)
    local  fubenBtn = self.view:GetChild("n100")
    fubenBtn.data = 1
    fubenBtn.onClick:Add(self.goTo,self)
    local  rankBtn = self.view:GetChild("n101")

    rankBtn.data = 2
    rankBtn.onClick:Add(self.goTo,self)

    self.confData1 = conf.XiaoNianConf:getXiangYaoData(1)
    self.confData2 = conf.XiaoNianConf:getXiangYaoData(2)

end

function Xn1002:onTimer()
    -- body
    if not self.data then 
        return 
    end
    local severTime =  mgr.NetMgr:getServerTime()
    if severTime >= self.data.actEndTime then
        local  view = mgr.ViewMgr:get(ViewName.XiaoNianView)
        if view then
            view:closeView()
        end
    end
end

function Xn1002:addMsgCallBack( data )
    -- body
    printt("降妖除尘",data)
    self.data =data
    GOpenAlert3(data.items,true)
    self.listView.numItems = #self.confData2
    self.timeText.text = GToTimeString12(data.actStartTime).."-"..GToTimeString12(data.actEndTime)

end

function Xn1002:cell1data( index,obj )
    local data =  self.confData2[index + 1]
    local  c1 = obj:GetController("c1")
    local  txt = obj:GetChild("n40")
    local  list = obj:GetChild("n43")
    local  btn = obj:GetChild("n45")
    local grayed =  btn:GetChild("icon").grayed
    local red = btn:GetChild("red")
    red.visible = false
    if self.data.gotSigns[data.id] then
        c1.selectedIndex = 2
    else
        if self.data.mine then
            local score = self.data.mine.score or 0 
            if score >= data.cond[1] then
                red.visible = true
                c1.selectedIndex = 0
                btn:GetChild("icon").grayed = false
            else
                btn:GetChild("icon").grayed = true
                c1.selectedIndex = 1
            end
        else
            btn:GetChild("icon").grayed = true
            c1.selectedIndex = 1
        end
    end
  
    list.itemRenderer = function (index, obj)
        local  data = data.items[index + 1]
        local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
        GSetItemData(obj, itemInfo, true)
    end
    list.numItems = #data.items
    txt.text = string.format(language.xiaonian2019_08,data.cond[1])

    btn.data = {state = c1.selectedIndex,cid = data.id }
    btn.onClick:Add(self.onGet,self)

end

function Xn1002:guide(context)
    mgr.ViewMgr:openView2(ViewName.XiaoNianGuide, {})
   
end

function Xn1002:goTo(context)
    local  data  = context.sender.data
    if data == 1 then
        GOpenView({id = 1049})
    else
        mgr.ViewMgr:openView2(ViewName.XiaoNianRank, self.data)
    end
   
end

function Xn1002:onGet(context)
    local  data  = context.sender.data
    if data.state == 0 then
 
        proxy.XiaoNianProxy:sendMsg(1030704,{reqType = 1 ,cid = data.cid })
    elseif data.state == 1 then
        GComAlter(language.xiaonian2019_09)
    end
   
end


return Xn1002