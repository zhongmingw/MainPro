--
-- Author: 
-- Date: 2018-01-24 17:46:52
--春节活动 好运灵签
local ChouQian = class("ChouQian",import("game.base.Ref"))

function ChouQian:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId or 1201
    self:initPanel()
end

function ChouQian:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)

    self.dec1 = panelObj:GetChild("n2")
    self.dec1.text = ""--language.chunjie01

    local dec1 = panelObj:GetChild("n3")
    dec1.text = mgr.TextMgr:getTextByTable(language.chunjie05)

    --上上签
    local titile1 = panelObj:GetChild("n20"):GetController("c1")
    titile1.selectedIndex = 1
    self.reward1 = conf.ActivityConf:getHolidayGlobal("lucky_sign_best_awards")

    self.listView1 = panelObj:GetChild("n21")
    self.listView1:SetVirtual()
    self.listView1.itemRenderer = function(index,obj)
        self:celldata1(index, obj)
    end
    self.listView1.numItems = 0
    -- 大吉签
    local titile1 = panelObj:GetChild("n22"):GetController("c1")
    titile1.selectedIndex = 2

    self.reward2 = conf.ActivityConf:getHolidayGlobal("lucky_sign_normal_awards")
    self.listView2 = panelObj:GetChild("n4")
    self.listView2:SetVirtual()
    self.listView2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.listView2.numItems = #self.reward2
    -- 本轮奖励
    local titile1 = panelObj:GetChild("n7"):GetController("c1")
    titile1.selectedIndex = 0

    self.panel = panelObj:GetChild("n8")

    local btn1 = panelObj:GetChild("n11")
    btn1.data = 2
    btn1.onClick:Add(self.onChouQu,self)

    local btn1 = panelObj:GetChild("n10")
    btn1.data = 1
    btn1.onClick:Add(self.onChouQu,self)

    self.cost10 = conf.ActivityConf:getHolidayGlobal("lucky_sign_ten_cost")
    self.cost1 = conf.ActivityConf:getHolidayGlobal("lucky_sign_one_cost")

    local cost10 = panelObj:GetChild("n17")
    cost10.text = self.cost10

    local cost1 = panelObj:GetChild("n18")
    cost1.text = self.cost1

    local dec1 = panelObj:GetChild("n23")
    dec1.text = language.chunjie08

    self.lastCost =  panelObj:GetChild("n24")
    self.lastCost.text = "0"

    self.max = self:getMax() 
end

function ChouQian:getMax()
    -- body
    local index = 0
    local condata = conf.ActivityConf:getHolidayGlobal("lucky_sign_random") 
    for k , v in pairs(condata) do
        index = index + v[2]
    end
    return index
end

function ChouQian:celldata1(index,obj)
    -- body
    local data = self.rewardcur[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)
end
function ChouQian:celldata2(index,obj)
    -- body
    local data = self.reward2[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)
end

function ChouQian:sendMsg()
    -- body
    local param = {}
    param.reqType = 0
    param.actId = 1071
    proxy.ActivityProxy:sendMsg(1030315,param)
end

function ChouQian:onChouQu(context)
    -- body
    local data = context.sender.data
    if not self.data then
        return
    end
    if (self.max - self.data.useSign) <= 0 then
        GComAlter(language.chunjie07)
        return
    end
    local param = {}
    param.reqType = data
    param.actId = 1071
    proxy.ActivityProxy:sendMsg(1030315,param)
end

function ChouQian:setCurinfo()
    -- body


    if not self.data then
        return
    end
    local condata = conf.ItemConf:getItem(self.data.curr.mid)
    if not condata then
        print("返回的mid 在道具配置找不到",self.data.curr.mid)
        return
    end

    --self.reward1 = {{mid = self.data.curr.mid , amount = 1 ,bind = 0}}
    self.rewardcur = {}
    for k ,v in pairs(self.reward1) do
        if v[1] == self.data.curr.mid then
            table.insert(self.rewardcur,v)
        end
    end

    self.listView1.numItems = #self.rewardcur

    local id = condata.model 
    if not id  and condata.args and  condata.args.s_arg1 then
        --print("condata.s_arg1[1][3]",condata.args.s_arg1.s_arg1[1][3])
        local _condata =  conf.MonsterConf:getInfoById(condata.args.s_arg1[1][3]) 
        id = _condata.src
        --print("condata.s_arg1[1][3]",_condata.src)
    end
    if not id then
        print("找不到模型",self.data.curr.mid)
        return
    end
  
    self.model = self.mParent:addModel(id,self.panel)
    self.model:setScale(50)
    self.model:setRotationXYZ(0,129.7,0)
    self.model:setPosition(50,-280.9,500)
end

function ChouQian:setData(data)
    -- body

    if data.msgId ~= 5030315 then
        return
    end

    local confdata = conf.ActivityConf:getActiveById(1071)
    if confdata and confdata.startTime and confdata.endDay then
        local str = mgr.ActivityMgr:formatTimeStr(confdata.startTime,confdata.startTime+3*86400-1)
        self.dec1.text = mgr.TextMgr:getTextByTable(str)
    else
        self.dec1.text = ""
    end

    

    self.data = data
    self.lastCost.text = self.max - data.useSign
    --print("抽取",data.reqType)
    if data.reqType == 0 then
        --设置本轮奖励
        self:setCurinfo()
    else
        local param = {}
        param.items = data.items
        param.type = 5
        param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
        local ss = language.chunjie09[2]
        print("param.select",data.select)
        if data.select ~= 0 then
            param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
            self:setCurinfo()
            ss = language.chunjie09[1]
        end
        local str = clone(language.chunjie06)
        str[2].text = string.format(str[2].text,ss)
        param.richtext = mgr.TextMgr:getTextByTable(str)

        mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
    end
end


return ChouQian