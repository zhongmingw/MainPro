--
-- Author: 
-- Date: 2017-03-07 11:51:04
--

local PanelBag = class("PanelBag",import("game.base.Ref"))

function PanelBag:ctor(param)
    self.showleft = {} --当前左边显示
    self.view = param
    self:initView()
end

function PanelBag:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onbtnController1,self)

    self.c2 = self.view:GetController("c2")
    self.c2.onChanged:Add(self.onbtnController2,self)
    --查看记录
    local btnRecord = self.view:GetChild("n13")
    btnRecord.onClick:Add(self.onRecord,self)
    --整理
    local btnZhengli = self.view:GetChild("n14")
    btnZhengli.onClick:Add(self.onZhengli,self)
    --背包整理
    local btnPack = self.view:GetChild("n15")
    btnPack.onClick:Add(self.onPack,self)
    --仓库
    self.listView = self.view:GetChild("n9")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.scrollPane.onScroll:Add(self.doSpecialEffect, self)

    self.listView1 = self.view:GetChild("n12")
    self.listView1.itemRenderer = function( index,obj )
        -- body
        self:cellpageBag(index, obj)
    end
    self.listView1.numItems = 0
    self.listView1.onClickItem:Add(self.onPageCallBack,self)

    self.labPage = self.view:GetChild("n24")
    self.labPage.text = ""

    --背包
    self.listView3 = self.view:GetChild("n23")
    self.listView3:SetVirtual()
    self.listView3.itemRenderer = function(index,obj)
        self:cellPackdata(index, obj)
    end
    self.listView3.numItems = 0
    self.listView3.scrollPane.onScroll:Add(self.doSpecialEffectPack, self)


    self.listView4 = self.view:GetChild("n16")
    self.listView4.itemRenderer = function( index,obj )
        -- body
        self:cellpagePackBag(index, obj)
    end
    self.listView4.numItems = 0
    self.listView4.onClickItem:Add(self.onPagePackCallBack,self)

    --self.view:GetChild("n25").text = language.bangpai148
    self.meoneyckl = self.view:GetChild("n26")
    self.meoneyckl.text = "0"
    --self:onbtnController2()

    self.plxhBtn = self.view:GetChild("n28")--装备批量销毁
    self.plxhBtn.onClick:Add(self.onClickPlxh,self)
    self.plxhBtn.visible = false

    --EVE 仙盟仓库增加文字描述：紫色1星以上装备才可放入仓库
    local bagDesc = self.view:GetChild("n29")
    bagDesc.text = language.bangpai180
end

function PanelBag:sortData(data)
    -- body
    table.sort(data,function(a,b)
        -- body
        local a_confdata = conf.ItemConf:getItem(a.mid)
        local b_confdata = conf.ItemConf:getItem(b.mid)
        if a_confdata.type == b_confdata.type then
            local ajie = a_confdata.stage_lvl or 0
            local bjie = b_confdata.stage_lvl or 0
            if ajie == bjie then
                if a_confdata.color == b_confdata.color then
                    local axin = a.colorAttris and #a.colorAttris or 0
                    local bxin = b.colorAttris and #b.colorAttris or 0
                    if axin == bxin then
                        return a.mid < b.mid
                    else
                        return axin > bxin
                    end
                else
                    return a_confdata.color > b_confdata.color
                end
            else
                return ajie > bjie
            end
        else
            return a_confdata.type < b_confdata.type 
        end
    end)
end

function PanelBag:selectBag()
    -- body
    self.baginfo = {}
    local confdata = conf.BangPaiConf:getValue("gang_store_ever_item")
    local _t = {}
    self._onlymid = 0
    for k ,v in pairs(confdata) do
        self._onlymid = v[1]
        _t[v[1]] = {}
        _t[v[1]].mid = v[1]
        _t[v[1]].amount = v[2]
        _t[v[1]].bind = v[3]
        _t[v[1]].index = 0
    end

    if self.c1.selectedIndex == 0 then
        --self.baginfo  = self.data.items
        for k ,v in pairs(self.data.items) do
            if _t[v.mid] then
                _t[v.mid].amount = v.amount
                _t[v.mid].index = v.index
            else
                table.insert(self.baginfo,v)
            end
        end
    elseif self.c1.selectedIndex == 1 then
        for k ,v in pairs(self.data.items) do
            if _t[v.mid] then
                _t[v.mid].amount = v.amount
                _t[v.mid].index = v.index
            else
                local _type = conf.ItemConf:getType(v.mid)
                if _type == 2 then--道具
                    table.insert(self.baginfo,v)
                end
            end
        end
    else
        for k ,v in pairs(self.data.items) do
            if _t[v.mid] then
                _t[v.mid].amount = v.amount
                _t[v.mid].index = v.index
            else
                local _type = conf.ItemConf:getType(v.mid)
                if _type == 1 then --装
                    table.insert(self.baginfo,v)
                end
            end 
        end
    end
    self.oldselect = self.c1.selectedIndex
    if self.flag then
        self.flag = nil 
        self:sortData(self.baginfo)
    elseif not self.oldselect then
        self:sortData(self.baginfo)
    elseif self.oldselect ~= self.c1.selectedIndex then
        self:sortData(self.baginfo)
    end

    self.guding = _t  --固定显示的东西
    local index = 1
    for k ,v in pairs(_t) do
        --plog("111",v)
        table.insert(self.baginfo,index,v)
        index = index + 1
    end
end

--刷选仓库数据
function PanelBag:onbtnController1()
    -- body
    self:selectBag(true)
    local max = conf.BangPaiConf:getValue("gang_store_grid_max")
    local number = math.ceil(max/16)
    if number <= 0 then
        number = 1
    end
    self.listView.numItems = number
    self.listView1.numItems = number
    --选择第一也
    
    self.index = 1
    self.listView1:ScrollToView(self.index-1,false)
    self.listView:ScrollToView(self.index-1,false)
    self:setPageText()
end
--param 参数消息数据 5250305
function PanelBag:selectPack(param)
    -- body
    self.packinfo = {}
    local t = {}
    if self.c2.selectedIndex == 0 then --全部
        t = cache.PackCache:getPackData()
    elseif self.c2.selectedIndex == 1 then --道具
        t = cache.PackCache:getPackProsData() 
    else --装备
        t = cache.PackCache:getPackEquipData()
    end
    for k , v in pairs(t) do
        ---刷选 不能存的不要
        if v.bind == 0 and conf.BangPaiConf:getStoreItem(v.mid) then
            local condata = conf.ItemConf:getItem(v.mid)
            local info 
            if self.saveinput and self.saveinput[v.index] then
                --如果是取出数据
                info = v 
            elseif condata.type == Pack.equipType then --装v
                --仙盟仓库放入装备限制（1阶、紫色、1星以上）
                if g_bang_inout then
                    info = v 
                else
                    local number = mgr.ItemMgr:getColorBNum(v)
                    if (condata.stage_lvl or 0) >= 1 
                        and (condata.color or 0) >= 4 
                        and number>0 then
                        info = v 
                    end 
                end
            else
                info = v 
            end
            if info then
                table.insert(self.packinfo,info)
            end
        end
    end

    self:sortData(self.packinfo)
end

function PanelBag:checkTaskNeed()
    -- body
    --检测帮派任务需要物品
    local data = cache.TaskCache:getshangHuiTasks()
    self.needItem = {}
    self.needList = {}
    if data and #data then --如果商会任务未完成
        for k ,v in pairs(data) do
            local condata = conf.TaskConf:getTaskById(v.taskId)
            for i , j in pairs(condata.conditions) do

                if self.needItem[j[1]] then
                    self.needItem[j[1]] = self.needItem[j[1]] + 1
                    self.needList[j[1]] = self.needList[j[1]] + 1 
                else
                    self.needItem[j[1]] = 1
                    self.needList[j[1]] = 1
                end
            end
        end
    end

    for k ,v in pairs(self.needItem) do
        local itemData = cache.PackCache:getPackDataById(k)
        if v > itemData.amount then
            self.needItem[k] = v - itemData.amount
        else
            self.needItem[k] = nil 
        end
    end
end

--筛选背包数据
function PanelBag:onbtnController2()
    -- body
    self:checkTaskNeed()
    self.saveinput = {}
    self:selectPack()
    local max = conf.BangPaiConf:getValue("gang_store_grid_max")
    local number = math.ceil(max /16)
    if number <= 0 then
        number = 1
    end
    self.listView3.numItems = number
    self.listView4.numItems = number

    self.packIndex = 0
    self.listView3:ScrollToView(self.packIndex,false)
    self.listView4:ScrollToView(self.packIndex,false) 
end



function PanelBag:celldata(index,obj)
    -- body
    self.showleft = {}
    local _16data = {} --16个格子数据
    local start = (index)*16+1
    for i = start, start + 16 do
        if not self.baginfo[i] then
            break
        end
        table.insert(_16data,self.baginfo[i])
    end
    local number = #_16data

    local listView = obj:GetChild("n0")
    listView.itemRenderer = function(_index,_obj)
        local c1 = _obj:GetController("c1")
        local _data = _16data[_index+1]
        _obj.data = _data
        if _index + 1 <= number and _data and _data.amount>0 then
            c1.selectedIndex = 1 --有道具

            local t = clone(_data)
            t.isneed = self.needItem[_data.mid]
            t.isdone = cache.PlayerCache:getIsNeed(_data.mid)
            t.isArrow = true
            t.isquan = true
            if self.guding[_data.mid] then
                t.amount = 1
            end

            GSetItemData(_obj:GetChild("n0"),t)
            table.insert(self.showleft,_obj)
        else
            c1.selectedIndex = 0
        end

    end
    listView.numItems = 16
    listView.onClickItem:Add(self.onCallBack,self) 
end
function PanelBag:onCallBack(context)
    -- body
    local item = context.data
    local data = item.data

    if data and self.guding[data.mid] and data.amount == 0 then
        --仓库固定显示的东西
        GComAlter(language.bangpai160)
        return
    end

    if not data or data.amount == 0 then
        return
    end


    local type = conf.ItemConf:getType(data.mid)
    if type == Pack.equipType then
        mgr.ViewMgr:openView(ViewName.EquipTipsView,function(view)
            view:setData(data)
        end)
    else
        local t = clone(data)
        if self.guding[data.mid] then
            t.issetAmount = 1
        end
        mgr.ViewMgr:openView(ViewName.BagInOut, function(view)
        -- body
            view:setDataOut()
        end, t)
    end
end
function PanelBag:doSpecialEffect( context )
    -- body
    local index = self.listView.scrollPane.currentPageX
    self.index = index + 1
    self.listView1:AddSelection(index,false)
    self:setPageText()
end
--仓库第几页
function PanelBag:cellpageBag(index,obj)
    -- body
    obj.data = index 
end
function PanelBag:onPageCallBack(context)
    -- body
    local index = context.data.data
    self.index = index + 1 
    --self.listView1:AddSelection(self.index,false)
    self.listView:AddSelection(index,true)
    self:setPageText()
end
function PanelBag:setPageText()
    -- body
    local pageMax = conf.BangPaiConf:getValue("gang_store_grid_max")
    self.labPage.text = self.index.."/"..(pageMax / 16)
end
------------背包
function PanelBag:cellPackdata(index,obj)
    -- body
    --plog("计算背包数据",index)

    self.showRight = {}
    local _16data = {} --16个格子数据
    local start = (index)*16+1
    for i = start , start + 16 do
        if not self.packinfo[i] then
            break
        end
        table.insert(_16data,self.packinfo[i])
    end
    local number = #_16data

    local listView = obj:GetChild("n0")
    listView.itemRenderer = function(_index,_obj)
        local c1 = _obj:GetController("c1")
        local _data = _16data[_index+1]
        _obj.data = _data
        if _index + 1 <= number and _data and _data.amount>0 then
            c1.selectedIndex = 1 --有道具
            local t = clone(_data)
            t.isneed = self.needList[_data.mid]
            t.isArrow = true
            t.isquan = true
            -- local t = {mid = _data.mid,amount=_data.amount,bind = _data.bind
            -- ,isneed = self.needList[_data.mid]}
            t.isdone = cache.PlayerCache:getIsNeed(t.mid)
            GSetItemData(_obj:GetChild("n0"),t)

            table.insert(self.showRight,_obj)
        else
            c1.selectedIndex = 0
        end
    end
    listView.numItems = 16
    listView.onClickItem:Add(self.onCallBackPack,self) 
end
function PanelBag:onCallBackPack(context)
    -- body
    local item = context.data
    local data = item.data
    if data and self.guding[data.mid] then
        --仓库固定显示的东西
        GComAlter(language.bangpai159)
        return
    end

    if not data or data.amount == 0 then
        return
    end
    local type = conf.ItemConf:getType(data.mid)
    if type == Pack.equipType then


        mgr.ViewMgr:openView(ViewName.EquipTipsView,function(view)
            view:setData(data)
        end)
    else
        mgr.ViewMgr:openView(ViewName.BagInOut, function(view)
        -- body
            view:setDataIn()
        end, data)
    end
end

function PanelBag:doSpecialEffectPack()
    -- body
    local index = self.listView3.scrollPane.currentPageX
    self.packIndex = index
    self.listView4:AddSelection(index,true)
end

function PanelBag:cellpagePackBag(index,obj)
    -- body
    obj.data = index 
end
function PanelBag:onPagePackCallBack(context)
    -- body
    self.packIndex = context.data.data 
    self.listView3:AddSelection(self.packIndex,true)
end

function PanelBag:onRecord()
    -- body
    mgr.ViewMgr:openView(ViewName.BagInOutRecord,function(view)
        -- body
        proxy.BangPaiProxy:sendMsg(1250306,{page = 1})
    end)
end

function PanelBag:onZhengli()
    -- body
    proxy.BangPaiProxy:sendMsg(1250304)
end

function PanelBag:onPack()
    -- body
    params = {}
    params.seq = Pack.pack
    proxy.PackProxy:sendCleanPackMsg(params)
end



function PanelBag:setData(data,flag)
    -- body
    mgr.ItemMgr:setPackIndex(Pack.gangWareIndex)
    self.data = data
    self.flag = flag
    self:onbtnController1()
    local gangJob = cache.PlayerCache:getGangJob() or 0
    if gangJob == 4 or gangJob == 3 or gangJob == 2 then
        self.plxhBtn.visible = true
    else
        self.plxhBtn.visible = false
    end
    self.meoneyckl.text = cache.PlayerCache:getTypeMoney(MoneyType.ckl)
end

function PanelBag:add5250305(data,param)
    -- body
    self.meoneyckl.text = cache.PlayerCache:getTypeMoney(MoneyType.ckl)
    self:checkTaskNeed()
    if data.reqType == 2 then --取出
        self.listView:RefreshVirtualList()
        ---
        if not self.saveinput then
            self.saveinput = {}
        end
        self.saveinput[data.getIndex] = true

        self:selectPack()
        
        --获取右边数据
        local max = conf.BangPaiConf:getValue("gang_store_grid_max")
        local number = math.ceil(max/16)
         if number <= 0 then
            number = 1
        end
        self.listView3.numItems = number
        self.listView4.numItems = number
        if not self.petIndex then
            self.petIndex = 0
        end
        if self.petIndex+1 >= number then
            self.petIndex = number - 1
        end

        self.listView3:AddSelection(self.petIndex,false)
        self.listView4:AddSelection(self.petIndex,false)
    else--存入
        ---修改右边数据
        for k ,v in pairs(self.packinfo) do
            if v.index == data.index then
                v.amount = v.amount - data.amount
                break
            end
        end
        self.listView3:RefreshVirtualList()

        --获取左边数据
        local max = conf.BangPaiConf:getValue("gang_store_grid_max")
        local number = math.ceil(max/16)
        if number <= 0 then
            number = 1
        end
        self.listView.numItems = number
        self.listView1.numItems = number
        if not self.index then
            self.index = 1
        end
        if self.index > number then
            self.index = number 
        end
        self.listView1:AddSelection(self.index-1,false)
        self.listView:AddSelection(self.index-1,false)
        self:setPageText()
    end
end

function PanelBag:add8030101(data)
    -- body
    if data.itemSeq ~= 900000 then
        return
    end

    for k ,v in pairs(data.changeItems) do
        local falg = false
        for i,j in pairs(self.data.items) do
            if v.index == j.index then
                self.data.items[i] = v
                falg = true
                break
            end
        end

        if not falg then
            table.insert(self.data.items,v)
        end
    end
    --重新刷新当前
    self:selectBag()
end

function PanelBag:add5040102()
    -- body
    self:onbtnController2()
end

function PanelBag:onClickPlxh()
    if self.baginfo then
        local data = {}
        for k ,v in pairs(self.data.items) do
            local type = conf.ItemConf:getType(v.mid)
            if type == Pack.equipType then --装
                table.insert(data,v)
            end
        end
        table.sort(data,function(a,b)
            local aconfdata = conf.ItemConf:getItem(a.mid)
            local bconfdata = conf.ItemConf:getItem(b.mid)
            local ajie = aconfdata.stage_lvl or 0
            local bjie = bconfdata.stage_lvl or 0
            if ajie == bjie then
                if aconfdata.color == bconfdata.color then
                    return a.mid < b.mid
                else
                    return aconfdata.color < bconfdata.color
                end
            else
                return ajie < bjie
            end
        end)
        mgr.ViewMgr:openView2(ViewName.BangPlChooseView, data)
    end
end

return PanelBag