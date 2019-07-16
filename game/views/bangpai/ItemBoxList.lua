--
-- Author: 
-- Date: 2017-03-10 14:58:31
--

local ItemBoxList = class("ItemBoxList",import("game.base.Ref"))

function ItemBoxList:ctor(param)
    self.view = param
    self:initView()
end

function ItemBoxList:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    local btnGuize = self.view:GetChild("n7")
    btnGuize.onClick:Add(self.onGuize,self)
    --额外奖励
    self.Itemobj = self.view:GetChild("n8")
    --开始挖宝
    self.btnStart = self.view:GetChild("n9")
    self.btnStart.onClick:Add(self.onStart,self)
    --免费开启
    self.btnFreeOpen = self.view:GetChild("n10")
    self.btnTitle = self.view:GetChild("n36")
    self.btnFreeOpen.onClick:Add(self.onFreeOpen,self)

    --顶级预览
    local btnTop =  self.view:GetChild("n12")
    btnTop.onClick:Add(self.onSeeInfo,self)
    --5个箱子
    self.boxlist = {}
    for i = 13,17 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.boxlist,btn)
    end
    self.value1 = self.view:GetChild("n20")
    self.value1.text = ""

    
    self.boxNameIcon = self.view:GetChild("n18")
    ----------
    --查看奖励
    self.seeicon = self.view:GetChild("n26")
    self.seeiconName = self.view:GetChild("n27")
    self.seeiconName.text = ""

    self.listView = self.view:GetChild("n23")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    --
    self.curbox = self.view:GetChild("n37") 

    self:initDec()
end

function ItemBoxList:onTimer()
    -- body
    for k ,v in pairs(self.data.boxList) do
        self:setTimeText(v,self.boxlist[k])
    end

    local temp = os.date("*t", mgr.NetMgr:getServerTime())
    if temp.hour >= 10 then
        self.btnStart.grayed = false
        self.btnStart.touchable = true
    else
        self.btnStart.grayed = true
        self.btnStart.touchable = false
    end

end

function ItemBoxList:initDec()
    -- body
    local dec = self.view:GetChild("n31")
    dec.text = language.bangpai85

    local dec = self.view:GetChild("n32")
    dec.text = language.bangpai86

    local dec = self.view:GetChild("n19")
    dec.text = language.bangpai87    

     local dec = self.view:GetChild("n21")
    dec.text = mgr.TextMgr:getTextByTable(language.bangpai89) 

end

function ItemBoxList:celldata(index, obj)
    -- body
end
function ItemBoxList:setTimeText(v,btn)
    -- body

    local c1 = btn:GetController("c1")
    if c1.selectedIndex == 0 then
        return
    end

    local imgTime = btn:GetChild("n4")
    local labtimer = btn:GetChild("n5")
    local need = v.needSec - (mgr.NetMgr:getServerTime()- v.startTime)
    if  need <= 0 then
        c1.selectedIndex = 3
        labtimer.text = language.bangpai92
    else
        local str = ""
        local t = GGetTimeData(need)
        if t.day and t.day>0 then
            str = str..t.day..language.gonggong20[1]
        end
        if t.hour and t.hour>0 then
            str = str..t.hour..language.gonggong20[2]
        end
        if t.min and t.min>0 then
            str = str..t.min..language.gonggong20[3]
        end
        if t.sec and t.sec>0 then
            str = str..t.sec..language.gonggong20[4]
        end
        labtimer.text = str
    end

end
function ItemBoxList:setBoxData(k,v)
    -- body

    local btn = self.boxlist[k]
    local c1 = btn:GetController("c1")
    c1.selectedIndex = 0

    local boxbtn = btn:GetChild("n6")
    boxbtn.data = v
    boxbtn.onClick:Add(self.on5box,self)
    --plog("v.boxColor",v.boxColor)
    boxbtn:GetChild("icon").url = UIItemRes.bangpai02[v.boxColor]

    
    if v.assistName~="" then
        c1.selectedIndex = 1
        local labname = btn:GetChild("n7")
        labname.text = string.format(language.bangpai91,v.assistName)
    else
        c1.selectedIndex = 2
        local btnFind = btn:GetChild("n3")
        btnFind.data = v.boxIndex
        btnFind.onClick:Add(self.onFind,self)
        btnFind:GetChild("title").text = language.bangpai107
    end
    self:setTimeText(v,btn)
end

function ItemBoxList:setData()
    -- body
    self.data = cache.BangPaiCache:getBoxData()
    --当前宝箱
    --plog("self.data.boxColor",self.data.boxColor)
    self.curbox.url = UIItemRes.bangpai02[self.data.boxColor]
    self.confData = conf.BangPaiConf:getBoxItem(self.data.boxColor)
    self.boxNameIcon.url = UIItemRes.bangpai01[self.data.boxColor]
    -- if self.confData.ext_items then --有额外奖励
    --     self.c2.selectedIndex = 1
    --     local t = {mid =self.confData.ext_items[1][1] ,amount = self.confData.ext_items[1][2],bind=self.confData.ext_items[1][3]}
    --     GSetItemData(self.Itemobj,t,true)

    -- else
    --     self.c2.selectedIndex = 0
    -- end
    --开启次数
    local var = conf.BangPaiConf:getValue("day_box_open_count")
    local varCha = var - self.data.dayBoxOpenCount
    if varCha < 0 then
        varCha = 0
    end
    local t = clone(language.bangpai90)
    t[2].text = string.format(t[2].text,varCha)
    self.value1.text = mgr.TextMgr:getTextByTable(t)
    if  varCha<=0 then
        self.btnTitle.data = nil 
        self.btnStart.visible = false
        self.btnFreeOpen.visible = false
        self.btnTitle.text = ""
    else
        self.btnFreeOpen.visible = true
        self.btnStart.visible = true        
        --刷新宝箱次数
        local var_free = conf.BangPaiConf:getValue("day_box_color_free_count")
        local varTime =  var_free - self.data.dayBoxColorCount
        if  varTime <= 0 then --免费次数没有了
            --self.btnFreeOpen.visible = false
            local c_data = conf.BangPaiConf:getValue("box_color_cost_gold")
            local money = c_data[math.abs(varTime)+1] or c_data[#c_data]

            local haveMoney = cache.PlayerCache:getTypeMoney(MoneyType.gold) +
                                cache.PlayerCache:getTypeMoney(MoneyType.bindGold)

            if money > haveMoney then --不够钱
            else
            end
            self.btnTitle.data = money
            self.btnTitle.text = string.format(language.bangpai114,money)

            self.c2.selectedIndex = 1
            local t = {mid =MoneyPro2[MoneyType.bindGold],amount = money,bind=1}
            GSetItemData(self.Itemobj,t,true)
        else
            self.btnTitle.data = nil 
            self.btnTitle.text = string.format(language.bangpai88,varTime,var_free)

            self.c2.selectedIndex = 0
        end
    end
    for i = #self.data.boxList +1, #self.boxlist do
        local c1 = self.boxlist[i]:GetController("c1")
        c1.selectedIndex = 0
    end
    ---设置宝箱
    for k ,v in pairs(self.data.boxList) do
        self:setBoxData(k,v)
    end

    
    
end

function ItemBoxList:boxInfoByColor( color )
    -- body
    --local confData = conf.BangPaiConf:getBoxItem(color)
    mgr.ViewMgr:openView(ViewName.BangPaiBoxInfo, function(view)
        -- body
        view:setData(color)
    end)

end

--开始挖宝
function ItemBoxList:onStart()
    -- body
    if #self.data.boxList == #UIItemRes.bangpai01 then
        GComAlter(language.bangpai118)
        return
    end

    proxy.BangPaiProxy:sendMsg(1250309)
end

function ItemBoxList:onFreeOpen()
    -- body
    if #UIItemRes.bangpai01 == self.data.boxColor then
        GComAlter(language.bangpai116)
        return
    end
    --策划要求去掉2次确认
    proxy.BangPaiProxy:sendMsg(1250308)
    -- if self.btnTitle.data then
    --     local param = {}
    --     param.type = 2
    --     param.sure = function()
    --         -- body
    --         proxy.BangPaiProxy:sendMsg(1250308)
    --     end
    --     local t = clone(language.bangpai115)
    --     t[2].text = string.format(t[2].text,self.btnTitle.data)
    --     param.richtext = mgr.TextMgr:getTextByTable(t)
    --     GComAlter(param)
    -- else
    --     proxy.BangPaiProxy:sendMsg(1250308)
    -- end

    
end
function ItemBoxList:onSeeInfo()
    -- body
    self:boxInfoByColor(#UIItemRes.bangpai01)
end

function ItemBoxList:on5box(context)
    -- body
    local v = context.sender.data
    local need = v.needSec - (mgr.NetMgr:getServerTime()- v.startTime)
    if need<= 0 then
        proxy.BangPaiProxy:sendMsg(1250310, {boxIndex=v.boxIndex})
    else
        self:boxInfoByColor(v.boxColor)
    end
end

function ItemBoxList:onFind(context)
    -- body
    local t1 = cache.BangPaiCache:getTime2(context.sender.data)
    if t1 == 0 then
        --cache.BangPaiCache:setTime2(context.sender.data,mgr.NetMgr:getServerTime())
    else
        local var = mgr.NetMgr:getServerTime() - t1
        local t2 = conf.BangPaiConf:getValue("box_help_word_time")
        if var <=  t2 then
            GComAlter(string.format(language.bangpai93,t2))
            return
        end
    end
    cache.BangPaiCache:setTime2(context.sender.data,mgr.NetMgr:getServerTime())
    local param = {}
    param.boxIndex = context.sender.data
    proxy.BangPaiProxy:sendMsg(1250313, param)
end
function ItemBoxList:onGuize( ... )
    -- body
    GOpenRuleView(1018)
end

return ItemBoxList