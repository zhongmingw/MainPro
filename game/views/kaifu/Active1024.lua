--
-- Author: 
-- Date: 2017-03-29 21:47:06
--

local Active1024 = class("Active1024",import("game.base.Ref"))

function Active1024:ctor(param)
    self.view = param
    self:initView()
end

function Active1024:initView()
    -- body
    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local btnCZ = self.view:GetChild("n5")
    btnCZ.onClick:Add(self.onChongzhi,self)
    btnCZ:GetChild("title").text = language.kaifu14

    self:initDec()
end
function Active1024:initDec()
    -- body
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.kaifu15

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.kaifu16

    self.time = self.view:GetChild("n8")
    self.time.text = ""

    self.money = self.view:GetChild("n9") 
    self.money.text = ""
end


function Active1024:onTimer()
    -- body
    if not self.data then
        return
    end
    if self.data.actLastTime<=0 then
        mgr.ViewMgr:closeAllView2()
        GComAlter(language.kaifu05)
        return
    end
    self.data.actLastTime = self.data.actLastTime - 1
    self.time.text = GGetTimeData2(self.data.actLastTime)
    self.money.text = string.format(language.kaifu17,self.data.seriesDay)
end

function Active1024:celldata( index, obj )
    -- body
    local data = self.confdata[index+1]
    for i = 7 , 10 do 
        local itemObj = obj:GetChild("n"..i)
        if data.awards[i-6] then --存在奖励
            itemObj.visible = true
            local t = {mid = data.awards[i-6][1],amount = data.awards[i-6][2],
            bind =data.awards[i-6][3]}
            GSetItemData(itemObj,t,true)
        else
            itemObj.visible = false
        end
    end

    local lab = obj:GetChild("n6")
    local t = clone(language.kaifu20)
    t[2].text = string.format(t[2].text,data.days)
    t[4].text = string.format(t[4].text,conf.ActivityConf:getValue("series_cz_quota") )
    lab.text = mgr.TextMgr:getTextByTable(t)

    local c1 =  obj:GetController("c1")
    c1.selectedIndex = self.data.itemStatus[data.days]

    local btn = obj:GetChild("n3")
    btn.onClick:Add(self.onget,self)
    btn.data = data
end

function Active1024:setCurId(id)
    -- body
    self.id = id 
end

function Active1024:onChongzhi()
    -- body
    mgr.ViewMgr:closeAllView2()
    GGoVipTequan(0)
end
function Active1024:onget(context)
    local data = context.sender.data
    if self.data.itemStatus[data.days]  == 2 then
        return
    elseif self.data.itemStatus[data.days] == 0 then
        GComAlter(language.kaifu21)
        return
    end
    proxy.ActivityProxy:sendMsg(1030112, {reqType = 1,awardId = data.days})
end

function Active1024:add5030112( data )
    -- body
    self.data = data
    self.confdata = conf.ActivityConf:getSeriesCzAwards()

    table.sort(self.confdata,function(a,b)
        -- body
        local astatue = data.itemStatus[a.days] 
        local bstatue = data.itemStatus[b.days] 

        if astatue == 1 then
            astatue = 0
        elseif astatue == 0 then
            astatue = 1
        end

        if bstatue == 1 then
            bstatue = 0
        elseif bstatue == 0 then
            bstatue = 1
        end

        if astatue ~= bstatue then
            return astatue < bstatue
        else
            return a.days < b.days
        end
    end)


    self.listView.numItems = #self.confdata


    GOpenAlert3(data.items)

end



return Active1024