--
-- Author: 
-- Date: 2017-03-30 16:02:17
--

local Active1025 = class("Active1025",import("game.base.Ref"))

function Active1025:ctor(param)
    self.view = param
    self:initView()
end

function Active1025:initView()
    -- body
    self.listView = self.view:GetChild("n8")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    local btnCZ = self.view:GetChild("n11")
    btnCZ.onClick:Add(self.onChongzhi,self)
    btnCZ:GetChild("title").text = language.kaifu14

    self:initDec()

    --EVE 屏蔽第五个页签
    local btn5 = self.view:GetChild("btn5") 
    local n28 = self.view:GetChild("n28")
    local lab5 = self.view:GetChild("lab5")
    local n33 = self.view:GetChild("n33")
    btn5.scaleX = 0
    btn5.scaleY = 0
    n28.scaleX = 0
    n28.scaleY = 0
    lab5.scaleX = 0
    lab5.scaleY = 0
    n33.scaleX = 0
    n33.scaleY = 0
    --EVE END
end
function Active1025:initDec()
    -- body
    local dec1 = self.view:GetChild("n12")
    dec1.text = language.kaifu15

    local dec1 = self.view:GetChild("n13")
    dec1.text = language.kaifu18

    local dec1 = self.view:GetChild("n16")
    dec1.text = language.kaifu19
    --时间
    self.time = self.view:GetChild("n14")
    self.time.text = 0
    --人数
    self.count = self.view:GetChild("n15")
    self.count.text = 0
    --
    self.money = self.view:GetChild("n17")
    self.money.text = 0
    
    self.keys = table.keys(conf.ActivityConf:getGropNumber())
    table.sort(self.keys,function(a,b)
        -- body
        return a<b
    end)
    self.lablist = {}
    self.btnlist = {}
    for i = 1 ,4 do
        local lab = self.view:GetChild("lab"..i)
        lab.text = string.format(language.kaifu25,self.keys[i])
        table.insert(self.lablist,lab)

        table.insert(self.btnlist,self.view:GetChild("btn"..i))
    end
    self.redpanel = {}
    for i = 24 ,28 do
        table.insert(self.redpanel,self.view:GetChild("n"..i))
    end
    self.redText = {}
    for i = 29, 33 do
        table.insert(self.redText,self.view:GetChild("n"..i))
    end
end

function Active1025:onTimer()
    -- body
    if not self.data then
        return 
    end
    if self.data.lastTime<=0 then

        mgr.ViewMgr:closeAllView2()
        GComAlter(language.kaifu05)
        return
    end

    self.time.text = GGetTimeData2(self.data.lastTime)
    self.data.lastTime = self.data.lastTime - 1
end

function Active1025:celldata( index, obj )
    -- body
    local data = self.showdata[index+1]

    local lab1 = obj:GetChild("n9")
    local t = clone(language.kaifu22)
    t[2].text = string.format(t[2].text,data.group_count)
    --t[4].text = string.format(t[4].text,self.data.czCount,data.group_count)
    t[5].text = string.format(t[5].text,self.data.czCount)
    t[6].text = string.format(t[6].text,data.group_count)
    if self.data.czCount>=data.group_count then
        t[5].color = 7
    else
        t[5].color = 14
    end

    if data.quota_lc and data.quota_lc>0 then
        if data.quota_lc == 1 then
            table.insert(t,language.kaifu23)
            
        else
            local t2 = clone(language.kaifu24)
            --plog(t2[2].url)
            t2[1].text = string.format(t2[1].text,data.quota_lc)
            for k , v in pairs(t2) do
                table.insert(t,v)
            end
        end
    end
    lab1.text = mgr.TextMgr:getTextByTable(t)

    local index = 1
    for i = 7,8 do
        local itemObj = obj:GetChild("n"..i)
        if data.awards and data.awards[index] then
            local p = {mid = data.awards[index][1],amount = data.awards[index][2]
            ,bind = data.awards[index][3] }
            itemObj.visible = true
            GSetItemData(itemObj,p,true)
            index = index + 1
        else
            itemObj.visible = false
        end
    end

    local btn =  obj:GetChild("n3")
    btn.data = data
    btn.onClick:Add(self.onget,self)

    local c1 = obj:GetController("c1")
    c1.selectedIndex = self.data.itemStatus[data.id]


end

function Active1025:setCurId(id)
    -- body
    self.id = id 
    --按天数获取配置 
    --self.condata = conf.ActivityConf:getOpenJieAwardByid(self.id)
end
function Active1025:onChongzhi()
    -- body
    mgr.ViewMgr:closeAllView2()
    GGoVipTequan(0)
end
function Active1025:onget(context)
    local data = context.sender.data
    local var = self.data.itemStatus[data.id]
    if  var == 0 then
        GComAlter(language.kaifu09)
        return
    elseif var == 2 then
        return
    end
    local param = {
        reqType = 1,
        awardId = data.id,
    }
    proxy.ActivityProxy:sendMsg(1030114,param)
end

function Active1025:onController1()
    -- body
    if not self.data or not self.gruopconf then
        return
    end

    local index = self.c1.selectedIndex + 1
    self.lablist[index].x = self.btnlist[index].x+(self.btnlist[index].actualWidth - self.lablist[index].actualWidth)/2

    self.showdata = self.gruopconf[self.keys[index]]
    

    table.sort(self.showdata,function(a,b)
        -- body
        local astatue = self.data.itemStatus[a.id] 
        local bstatue = self.data.itemStatus[b.id] 

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
            return a.id < b.id
        end  
    end)

    self.listView.numItems = #self.showdata
end

function Active1025:setOpenDay( day )
    -- body
    self.openDay = day
end

function Active1025:add5030114( data )
    -- body
    self.data = data

    self.count.text = data.czCount
    self.money.text = data.czYb

    self.condata = conf.ActivityConf:getGropPurchase(self.openDay)
    self.gruopconf = {}

    self.redPoint = {}
    for k ,v in pairs(self.condata) do
        if not self.gruopconf[v.group_count] then
            self.gruopconf[v.group_count] = {}
        end
        table.insert(self.gruopconf[v.group_count],v)
        if not self.redPoint[v.group_count] then
            self.redPoint[v.group_count] = 0
        end
        if self.data.itemStatus[v.id] == 1 then
            self.redPoint[v.group_count] = self.redPoint[v.group_count] + 1
        end
    end
    self:onController1()
    --红点计算
    for i = 1 , 4 do  --EVE 此处5已改成4(不需要计算第五档的红点，第五档已被屏蔽)
        local number = self.redPoint[self.keys[i]]
        local p = self.redpanel[i]
        local txt = self.redText[i]
        txt.text = number
        if number >0 then
            p.visible = true
            txt.visible = false
        else
            p.visible = false
            txt.visible = false
        end
    end 

    GOpenAlert3(data.items)
end

return Active1025