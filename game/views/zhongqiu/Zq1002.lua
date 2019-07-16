local Zq1002 = class("Zq1002",import("game.base.Ref"))

function Zq1002:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Zq1002:onTimer()
    -- body
    if not self.data then return end
end
function Zq1002:addMsgCallBack(data)
    if data.msgId == 5030612 then
        printt(data)
        self.data = data
        self.refreshNum = conf.ZhongQiuConf:getGlobal("zq_eliminate_devil_rank")
        self.listView3.numItems = math.max(#self.data.rankingInfos, self.refreshNum)
        self.dec.text = self.data.mine.point
         self.dec1.text = "活动时间："..GToTimeString11(self.data.actStartTime).."~"..GToTimeString11(self.data.actEndTime)
    end
end

function Zq1002:initView()
    print("initView()")
    self.dec1 = self.view:GetChild("n8")
    local dec2 = self.view:GetChild("n9")
    dec2.text = language.zq09
    self.listView1 = self.view:GetChild("n22")
    self.listView1.itemRenderer = function(index,obj)
        self:cellData1(index, obj)
    end

    self.listView2 = self.view:GetChild("n18")
    self.listView2.itemRenderer = function(index,obj)
        self:cellData2(index, obj)
    end

    self.btn = self.view:GetChild("n11")
    self.btn.title = "前去除魔 "
    self.btn.onClick:Add(self.onGet1,self)

    self.btn1 = self.view:GetChild("n12")
    self.btn1.title = "除魔排行 "
    self.btn1.onClick:Add(self.onGet2,self)

    self.confData1 = conf.ZhongQiuConf:getDevilShow()
    self.confData2 = conf.ZhongQiuConf:getDevilRank()
    table.sort(self.confData2,function (a,b)
            if a.id ~= b.id then
                return a.id < b.id
            end
        end)
    self.listView1.numItems = #self.confData1
    self.listView2.numItems = #self.confData2

    self.rankPanel = self.view:GetChild("n24")
    self.closeBtn = self.rankPanel:GetChild("n1"):GetChild("n2")
    self.closeBtn.onClick:Add(self.closePanel,self)
    self.listView3 = self.rankPanel:GetChild("n6")
    self.listView3.itemRenderer = function(index,obj)
        self:cellData3(index,obj)
    end
    self.dec = self.rankPanel:GetChild("n7")
    self.rankPanel.visible = false

end

function Zq1002:cellData1(index,obj)
    local data = self.confData1[index + 1]
    obj:GetChild("n30").text = data.type
    obj:GetChild("n31").text = data.num
end

function Zq1002:cellData2(index,obj)
    local data = self.confData2[index + 1]
    local listview = obj:GetChild("n29")
    listview.itemRenderer = function(_index,_obj)
        local _data = data.awards[_index+1]
        local t = {}
        t.mid = _data[1]
        t.amount = _data[2]
        t.bind = _data[3] or 1
        GSetItemData(_obj, t, true)
    end
    listview.numItems = #data.awards 
    local dec = obj:GetChild("n30")
    dec.text = "第"..data.ranking[1].."~"..data.ranking[2].."名"
    if index == 0 then
        dec.text = "第1名"
    end
end

function Zq1002:cellData3(index,obj) 
   local data = self.data.rankingInfos[index + 1]
   local c1 = obj:GetController("c1")
   if data then
        obj:GetChild("n1").text = data.ranking
        obj:GetChild("n2").text = data.roleName
        obj:GetChild("n3").text = data.point
        if data.ranking <= 3 then
            c1.selectedIndex = index
        else
             c1.selectedIndex = 3
        end
   else
        obj:GetChild("n1").text = index + 1
        if index <= 3 then
            c1.selectedIndex = index
        else
            c1.selectedIndex = 3
        end
   end
end


function Zq1002:onGet1(context)
    GOpenView({id = 1125})
end

function Zq1002:onGet2(context)
    proxy.ZhongqiuProxy:sendMsg(1030612)
    self.rankPanel.visible = true
end

function Zq1002:closePanel(context)
    self.rankPanel.visible =false
end

return Zq1002