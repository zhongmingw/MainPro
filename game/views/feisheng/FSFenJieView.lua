--
-- Author: 
-- Date: 2018-08-21 17:09:26
--

local FSFenJieView = class("FSFenJieView", base.BaseView)

function FSFenJieView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.openTween = ViewOpenTween.scale
end

function FSFenJieView:initView()
    local btn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btn)

    local btn1 = self.view:GetChild("n4")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n11")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n14")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n18")
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.component =  self.view:GetChild("n16")
    self.listSelect = self.component:GetChild("n2")
    self.listSelect.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listSelect.numItems = 0
    self.listSelect.onClickItem:Add(self.onCallBack,self) 

    self.lab1 = self.view:GetChild("n5")
    self.lab2 = self.view:GetChild("n12")
    self.lab3 = self.view:GetChild("n15")

    self.labexp = self.view:GetChild("n17")

    self.listView = self.view:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function (index,obj)
        self:cellPackdata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onPackCallBack,self) 

end

function FSFenJieView:initData()
    self.lastbtn = nil 
    self._s_color = cache.FeiShengCache:getColor()
    self._s_zuan = cache.FeiShengCache:getZuan()
    self._s_xing = cache.FeiShengCache:getXing()
    self.selecttable = {}
    self.component.visible = false
    self.labexp.text = language.fs05..mgr.TextMgr:getTextColorStr("0", 7)
    --获取背包数据
    self:getPackData()
    --按默认选择设置一下
    self.lab1.text = language.fs01[self._s_color + 1]
    self.lab2.text = language.fs02[self._s_zuan + 1]
    self.lab3.text = language.fs03[self._s_xing + 1]

    self:filtrate()
end

function FSFenJieView:getPackData()
    -- body
    self.data = {}
    local data = cache.PackCache:getPackDataByType(Pack.xianzhuang)
    for k,v in pairs(data) do
        local color = conf.ItemConf:getQuality(v.mid)
        if color < 7 then
            table.insert(self.data,v)
        end
    end
    local number = 45
    self.listView.numItems = math.max((math.ceil(#self.data/number)*number),number)
end

function FSFenJieView:celldata( index, obj )
    -- body
    local data = self.conftitle[index+1]
    obj.title = data
    obj.data = index 
end

function FSFenJieView:onCallBack( context )
    -- body
    self.component.visible = false
    local index = context.data.data 
    if self.conftitle == language.fs01 then
        self.lab1.text = self.conftitle[index + 1]
        self._s_color = index
        cache.FeiShengCache:setColor(self._s_color) 
    elseif self.conftitle == language.fs02 then
        self.lab2.text = self.conftitle[index + 1]
        self._s_zuan = index
        cache.FeiShengCache:setZuan(self._s_zuan) 
    elseif self.conftitle == language.fs03 then
        self._s_xing = index
        self.lab3.text = self.conftitle[index + 1]
        cache.FeiShengCache:setXing(self._s_xing) 
    end
    self:filtrate()--按条件选择
end

function FSFenJieView:cellPackdata( index, obj )
    -- body
    local data = self.data[index+1]
    obj.data = data 

    local itemObj = obj:GetChild("n5")
    
    if data  then
        if self.selecttable[data.index] then
            obj.selected = true
        else
            obj.selected = false
        end

        local t = clone(data)
        t.isquan = true
        GSetItemData(itemObj, t)
    else
        obj.selected = false
        GSetItemData(itemObj, {})
    end
end

function FSFenJieView:onPackCallBack(context)
    -- body
    local btn = context.data 
    local data = btn.data 
    if data then
        if self.selecttable[data.index] then
            self.selecttable[data.index] = nil 
        else
            self.selecttable[data.index] = data 
        end
        self:setSelectExp()
    else
        btn.selected = false
    end
    self.component.visible = false
end

function FSFenJieView:onBtnCallBack(context)
    -- body
    if not self.data then
        return
    end
    local btn = context.sender
    local data = btn.data 
    if self.component.visible then
        if self.lastbtn and self.lastbtn == btn then
            self.component.visible = false
            return
        end
    end
    self.lastbtn = btn
    self.component.visible = false
    self.component.x = btn.x - 131
    self.component.y = btn.y - 220
    if "n4" == btn.name then
        --color
        self.component.visible = true
        self.conftitle = language.fs01
        self.listSelect.numItems = #self.conftitle
        self.listSelect:AddSelection(self._s_color,false)

        
    elseif "n11" == btn.name then
        --转
        self.component.visible = true
        self.conftitle = language.fs02
        self.listSelect.numItems = #self.conftitle
        self.listSelect:AddSelection(self._s_zuan,false)

       
    elseif "n14" == btn.name then
        --星
        self.component.visible = true
        self.conftitle = language.fs03
        self.listSelect.numItems = #self.conftitle
        self.listSelect:AddSelection(self._s_xing,false)

        
    elseif "n18" == btn.name then
        --开始分解
        if table.nums(self.selecttable) == 0 then
            return GComAlter(language.fs04)
        end
        local param = {}
        param.indexs = {}
        local flag = false
        for k ,v in pairs(self.selecttable) do
            table.insert(param.indexs,v.index)
            if mgr.ItemMgr:getColorBNum(v) >= 2 then
                flag = true
            end
        end

        local info = {}
        info.type = 2
        info.richtext = language.fs42
        info.sure = function()
            -- body
            proxy.FeiShengProxy:sendMsg(1580102,param)
        end
        info.cancel = function()
            
        end
        if flag then
            GComAlter(info)
        else
            proxy.FeiShengProxy:sendMsg(1580102,param)
        end
    end
end



function FSFenJieView:filtrate()
    -- body
    local color = {
        4,5,6
    }
    local zuan = {
        9999,1,2,3
    }
    local xing = {
        9999,1,2,3
    }
    self.selecttable = {}
    for k ,v in pairs(self.data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.color <= color[self._s_color+1] then
            --颜色满足
            if condata.stage_lvl <= zuan[self._s_zuan+1] then
                --转满足
                if mgr.ItemMgr:getColorBNum(v) <= xing[self._s_xing+1] then
                    --星满足
                    self.selecttable[v.index] = v 
                end
            end
        end
    end

    --选择后刷新一下列表
    self.listView:SelectNone()
    self.listView:RefreshVirtualList()
    --计算一下分解获得
    self:setSelectExp()
end

function FSFenJieView:setSelectExp()
    -- body
    local exp = 0
    for k ,v in pairs(self.selecttable) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.partner_exp  then
            exp = exp + condata.partner_exp 
        else
            print("叼策划没有配置分解获得 partner_exp ",v.mid)
        end
    end
    self.exp = exp
    self.labexp.text = language.fs05..mgr.TextMgr:getTextColorStr(tostring(exp), 7)
end

function FSFenJieView:addMsgCallBack(data)
    -- body
    --GComAlter(language.fs26..(self.exp or 0))

    --挨个飘字
    for k ,v in pairs(self.selecttable) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata and condata.partner_exp  then
            local str = clone(language.fs44)
            str[1].text = string.format(str[1].text , condata.name )
            str[4].text = string.format(str[4].text , condata.partner_exp )

            local info = {text =   mgr.TextMgr:getTextByTable(str),count = 0}
            mgr.TipsMgr:addRightTip(info)--道具飘字
            --GComAlter(param)
        end
    end

    self.selecttable = {}
    self:setSelectExp()

    self:getPackData()
    self:filtrate()
end

return FSFenJieView