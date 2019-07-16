--
-- Author: 
-- Date: 2017-03-03 16:54:11
--

local BagInOutRecord = class("BagInOutRecord", base.BaseView)

function BagInOutRecord:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3
    self.isBlack = true 
end

function BagInOutRecord:initView()
    local btnClose = self.view:GetChild("n17")--:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.listView = self.view:GetChild("n9")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local lab1 = self.view:GetChild("n10") 
    lab1.text = language.bangpai80

    local lab1 = self.view:GetChild("n11") 
    lab1.text = language.bangpai81

    local lab1 = self.view:GetChild("n12") 
    lab1.text = language.bangpai82

    local lab1 = self.view:GetChild("n13") 
    lab1.text = language.bangpai83
end

function BagInOutRecord:celldata(index, obj)
    -- body
    local data = self.data.logs[index+1]
    local t = string.split(data,"#")

    local lab1 = obj:GetChild("n1") 
    lab1.text = t[1]

    local lab2 = obj:GetChild("n2") 
    local str = string.split(t[2],".")
    if #str == 2 then
        local param = {
            {text = str[1]..".",color = 7},
            {text = str[2],color = 6}
        }
        lab2.text = mgr.TextMgr:getTextByTable(param)
    else
        lab2.text = mgr.TextMgr:getTextColorStr(t[2],6)
    end

    local lab3 = obj:GetChild("n3") 
    lab3.text = t[3]

    local itemObj = obj:GetChild("n0") 
    local param = {mid = tonumber(t[4]),amount = tonumber(t[5]),eStar = tonumber(t[6] or 0) }
    GSetItemData(itemObj,param,true)
    if index + 1 >= self.listView.numItems then
        if not self.data.logs then
            return
        end
        if self.data.page < self.data.pageSum then 
           -- plog("下一页",self.mData.page + 1)
           proxy.TeamProxy:send(1250306,{page = self.data.page + 1})
        end
    end
end

function BagInOutRecord:setData(data)
    local page = data.page
    if self.data and page and page > 1 then
        if data and self.data.page < page and data.logs then
            self.data.page = page
            self.data.pageSum = data.pageSum
            for _,v in pairs(data.logs) do
                table.insert(self.data.logs, v)
            end
        end
    else
        self.data = {}
        self.data.page = data.page
        self.data.pageSum = data.pageSum
        self.data.logs = data.logs
    end
    self.listView.numItems = #self.data.logs
end

function BagInOutRecord:onBtnClose()
    -- body
    self:closeView()
end

return BagInOutRecord