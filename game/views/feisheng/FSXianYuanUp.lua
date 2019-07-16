--
-- Author: 
-- Date: 2018-08-21 20:48:15
--

local FSXianYuanUp = class("FSXianYuanUp", base.BaseView)

function FSXianYuanUp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function FSXianYuanUp:initView()
    local btn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btn)

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.fs14
    local dec1 = self.view:GetChild("n17")
    dec1.text = language.fs15
    local dec1 = self.view:GetChild("n7")
    dec1.text = language.fs10
    local dec1 = self.view:GetChild("n11")
    dec1.text = language.fs16
    self.dec1 = self.view:GetChild("n25")
    self.dec1.text = ""--language.fs18

    self.num1 = self.view:GetChild("n9")
    self.num1.text = ""

    self.num2 = self.view:GetChild("n13")
    self.num2.text = ""

    self.lab1 = self.view:GetChild("n24")
    self.lab1.text = ""

    self.lab2 = self.view:GetChild("n23") 
    self.lab2.text = ""

    local btn1 = self.view:GetChild("n21")
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.listView1 = self.view:GetChild("n20")
    self.listView1.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView1.numItems = 0

    self.labusetime = self.view:GetChild("n26")
end

function FSXianYuanUp:onBtnCallBack(context)
    local btn = context.sender
    local data = btn.data 
    if "n21" == btn.name then
        --转化
        local A541 = cache.PlayerCache:getAttribute(541)
        local confdata = conf.FeiShengConf:getXlexchangeItem(A541)
        if not confdata then
            GComAlter(language.fs36)
            return
        end
        local A543 = cache.PlayerCache:getAttribute(543)
        if A543 <= confdata.limit_xl_lev then
            GComAlter(string.format(language.fs34,confdata.limit_xl_lev))
            return
        end

        if cache.FeiShengCache:getExchangeTimes() >= confdata.max_daily_times then
            GComAlter(language.fs35)
            return
        end
        local param = {}
        param.reqType = 1
        proxy.FeiShengProxy:sendMsg(1580201,param)
    end
end

function FSXianYuanUp:celldata(index, obj)
    -- body
    local data = self.itemshow[index+1]
    local itemObj = obj:GetChild("n0")
    local labname = obj:GetChild("n1")
    local labcount = obj:GetChild("n3")
    local labdesc = obj:GetChild("n4")
    local btn = obj:GetChild("n5")
    local c1 = obj:GetController("c1")
    btn.onClick:Add(self.onItemCallBack,self)

    local t = {}
    t.mid = data
    t.isquan = true
    GSetItemData(itemObj, t, true)

    labname.text = mgr.TextMgr:getColorNameByMid(t.mid)

    local packData = cache.PackCache:getPackDataById(t.mid)
    labcount.text = language.fs19 .. packData.amount

    local arg = conf.ItemConf:getItemValueOfEXP(t.mid)
    labdesc.text = string.format(language.fs39,arg.arg1)  --conf.ItemConf:getDescribe(t.mid)

    if packData.amount == 0 then
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
    end

    btn.data = packData 
end

function FSXianYuanUp:onItemCallBack( context )
    -- body
    local btn = context.sender
    local data = btn.data 
    local param = clone(data)
   
    --道具使用
    if data.amount <= 0 then
        GGoBuyItem(data)
        --GComAlter(language.gonggong11)
    else
        proxy.PackProxy:sendUsePro(param)
    end
end

function FSXianYuanUp:initData()
    -- body
     --/** 飞升等级 **/
    local A541 = cache.PlayerCache:getAttribute(541)
    -- /** 当前仙缘 **/
    local A542 = cache.PlayerCache:getAttribute(542)
    --/** 仙力等级 **/
    local A543 = cache.PlayerCache:getAttribute(543)

    self.num1.text = A543

    self.afterlv , self.exp = cache.FeiShengCache:afterExchange()

    self.num2.text = self.afterlv--转换后的等级需要计算
    self.lab1.text = language.fs17 ..  mgr.TextMgr:getTextColorStr("+" .. self.exp , 7)   --需要计算
    local str = language.fs20
    local confdata = conf.FeiShengConf:getXlexchangeItem(A541)
    if confdata then
        self.max = confdata.max_daily_use
        if cache.FeiShengCache:getUseTimes() >= confdata.max_daily_use then
            str = str .. mgr.TextMgr:getTextColorStr(cache.FeiShengCache:getUseTimes(),7)
        else
            str = str .. mgr.TextMgr:getTextColorStr(cache.FeiShengCache:getUseTimes(),14)
        end
        str = str .. mgr.TextMgr:getTextColorStr("/"..confdata.max_daily_use,7) 
        self.lab2.text = str --language.fs20 .. mgr.TextMgr:getTextColorStr(cache.FeiShengCache:getUseTimes() .. self.exp , 7) --useTimes
    
        local _ss = language.fs45
        if cache.FeiShengCache:getExchangeTimes() >= confdata.max_daily_times then
            _ss = _ss .. mgr.TextMgr:getTextColorStr(cache.FeiShengCache:getExchangeTimes(), 7)
        else
            _ss = _ss .. mgr.TextMgr:getTextColorStr(cache.FeiShengCache:getExchangeTimes(), 14)
        end
        _ss = _ss .. "/" .. mgr.TextMgr:getTextColorStr(confdata.max_daily_times, 7) 
        self.labusetime.text = _ss
    else
        self.max = 0
        self.lab2.text = "这个 每日最大仙果使用 没有配置"
        self.labusetime.text = ""
    end
    self.itemshow = conf.FeiShengConf:getValue("xianguo_item")
    self.listView1.numItems = #self.itemshow


    self.dec1.text = string.format(language.fs18,confdata.limit_xl_lev)
end

function FSXianYuanUp:addMsgCallBack(data)
    -- body
    if 5580201 == data.msgId then
        self:initData()
    elseif 5040401 == data.msgId then
        proxy.FeiShengProxy:sendMsg(1580201,{reqType = 0})
    end
end

return FSXianYuanUp