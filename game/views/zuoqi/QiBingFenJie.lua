local QiBingFenJie = class("QiBingFenJie", base.BaseView)

-- local qhsMid ={221042661,221042662,221042663,221042664,221042665,221042666}

function QiBingFenJie:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function QiBingFenJie:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.fenjieBtn = self.view:GetChild("n7")
    self.fenjieBtn.onClick:Add(self.onClickFenjie,self)

    self.selectQhs = {0,0,0}

    self.qhsList = {}
    for i=1,3 do
        local item = self.view:GetChild("n"..(3+i))
        table.insert(self.qhsList,item)
    end
end

function QiBingFenJie:cellData(index,obj)
    local data = self.qhsData[index+1]
    local itemObj = obj:GetChild("n5")
    if data then
        itemObj.visible = true
        GSetItemData(itemObj, data, false)
        local flag = false
        for k,v in pairs(self.selectData) do
            if v.index == data.index then
                flag = true
                break
            end
        end
        obj.selected = flag
        obj.touchable = true
        obj.data = data
        obj.onClick:Add(self.onClickSelect,self)
    else
        obj.selected = false
        obj.touchable = false
        itemObj.visible = false
    end
end

function QiBingFenJie:onClickSelect(context)
    local cell = context.sender
    local data = cell.data
    local flag = true
    local key = #self.selectData
    for k,v in pairs(self.selectData) do
        if v.index == data.index and not cell.selected then
            flag = false
            key = k
            break
        end
    end
    if not flag then
        table.remove(self.selectData,key)
    else
        if cell.selected then
            table.insert(self.selectData,data)
        end
    end

    self:initSelectQhs()
end

function QiBingFenJie:initSelectQhs()
    self.selectQhs = {0,0,0}
    for k,v in pairs(self.selectData) do
        local fenjieConf = conf.QiBingConf:getFenjieDataById(v.mid)
        if fenjieConf then
            if fenjieConf.zs then
                self.selectQhs[1] = self.selectQhs[1] + fenjieConf.zs * v.amount
            end
            if fenjieConf.cs then
                self.selectQhs[2] = self.selectQhs[2] + fenjieConf.cs * v.amount
            end
            if fenjieConf.hs then
                self.selectQhs[3] = self.selectQhs[3] + fenjieConf.hs * v.amount
            end
        end
    end
    self:initQhsTxt()
end

function QiBingFenJie:initData(data)
    -- self.qhsMap = cache.QiBingCache:getAllInfo().qhsMap
    self:initListview()
end

function QiBingFenJie:initQhsTxt()
    if not self.selectQhs then
        return
    end
    for k,v in pairs(self.selectQhs) do
        local numTxt = self.qhsList[k]:GetChild("n2")
        numTxt.text = v
        local icon = self.qhsList[k]:GetChild("n1")
        icon.url = UIPackage.GetItemURL("_icons" , cache.QiBingCache.QHSIcon[k])
    end
end

function QiBingFenJie:initListview()
    self.qhsData = {}
    self.selectData = {}
    local qhsMid = conf.QiBingConf:getFenjieList()
    for k,v in pairs(qhsMid) do
        local data = cache.PackCache:getPackDataById(v, true)
        if data.amount > 0 then
            data.isquan = 0
            table.insert(self.qhsData, data)
            table.insert(self.selectData, data)
        end
    end

    self:initSelectQhs()

    self.listView.numItems = math.max((math.ceil(#self.qhsData/40)*40),40)
end

function QiBingFenJie:onClickFenjie()
    if not self.selectData then
        return
    end
    local data = {}
    for k,v in pairs(self.selectData) do
        table.insert(data, v.index)
    end
    if #self.selectData > 0 then
        proxy.QiBingProxy:sendDecompose(data)
    else
        GComAlter(language.shenqi06)
    end
end

function QiBingFenJie:refreshQhsMap(data)
    -- for k,v in pairs(self.qhsMap) do
    --     if data[k] then
    --         self.qhsMap[k] = self.qhsMap[k] + data[k]
    --     end
    -- end
    self:initListview()
end

return QiBingFenJie