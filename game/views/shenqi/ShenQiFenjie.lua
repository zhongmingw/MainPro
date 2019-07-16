--
-- Author: Your Name
-- Date: 2018-07-01 13:21:32
--

local ShenQiFenjie = class("ShenQiFenjie", base.BaseView)

local qhsMid ={221042661,221042662,221042663,221042664,221042665,221042666,221043903,221043904}
local QHSIcon = {
    [1] = "221071124",
    [2] = "221071125",
    [3] = "221071192",
    [4] = "221071820",
}
function ShenQiFenjie:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ShenQiFenjie:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n2")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.fenjieBtn = self.view:GetChild("n8")
    self.fenjieBtn.onClick:Add(self.onClickFenjie,self)

    self.selectQhs = {0,0,0,0}

    self.qhsList = {}
    for i=1,4 do
        local item = self.view:GetChild("n"..(3+i))
        table.insert(self.qhsList,item)
    end
end

function ShenQiFenjie:cellData(index,obj)
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

function ShenQiFenjie:onClickSelect(context)
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
    -- printt("当前选择的>>>>>>>>>",self.selectData)
end

function ShenQiFenjie:initSelectQhs()
    self.selectQhs = {0,0,0,0}
    for k,v in pairs(self.selectData) do
        local fenjieConf = conf.ShenQiConf:getFenjieDataById(v.mid)
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
            if fenjieConf.fs then
                self.selectQhs[4] = self.selectQhs[4] + fenjieConf.fs * v.amount
            end
        end
    end
    self:initQhsTxt()
end

function ShenQiFenjie:initData(data)
    self.qhsMap = data
    self:initListview()
end

function ShenQiFenjie:initQhsTxt()
    if not self.selectQhs then
        return
    end
    for k,v in pairs(self.selectQhs) do
        local numTxt = self.qhsList[k]:GetChild("n2")
        numTxt.text = v
        local icon = self.qhsList[k]:GetChild("n1")
        icon.url = UIPackage.GetItemURL("_icons" , QHSIcon[k])
    end
end

function ShenQiFenjie:initListview()
    self.qhsData = {}
    self.selectData = {}
    for k,v in pairs(qhsMid) do
        local data = cache.PackCache:getPackDataById(v,true)
        if data.amount > 0 then
            data.isquan = 0
            table.insert(self.qhsData,data)
            table.insert(self.selectData,data)
        end
    end

    self:initSelectQhs()

    self.listView.numItems = math.max((math.ceil(#self.qhsData/40)*40),40)
    -- self:initQhsTxt()
end

function ShenQiFenjie:onClickFenjie()
    if not self.selectData then
        return
    end
    local data = {}
    for k,v in pairs(self.selectData) do
        table.insert(data,v.index)
    end
    if #self.selectData > 0 then
        printt("当前选择的>>>>>>>>>>>",data)
        proxy.ShenQiProxy:sendMsg(1520105,{indexs = data})
    else
        GComAlter(language.shenqi06)
    end
end

function ShenQiFenjie:refreshQhsMap(data)
    for k,v in pairs(self.qhsMap) do
        if data[k] then
            self.qhsMap[k] = self.qhsMap[k] + data[k]
        end
    end
end

return ShenQiFenjie