--
-- Author: 
-- Date: 2017-03-06 14:15:56
--

local PanelBangPaiList = class("PanelBangPaiList",import("game.base.Ref"))

function PanelBangPaiList:ctor(param)
    self.view = param
    self:initView()
end

function PanelBangPaiList:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    self.c2.onChanged:Add(self.onController2,self)
    --一件申请
    local btnOneKeyApply = self.view:GetChild("n7")
    btnOneKeyApply.onClick:Add(self.onOneKeyApply,self)

    local btnCreate = self.view:GetChild("n8")
    btnCreate.onClick:Add(self.onBtnCreate,self)

    local btnApply = self.view:GetChild("n10")
    btnApply.onClick:Add(self.onBtnApply,self)

    local btnSearch = self.view:GetChild("n11")
    btnSearch.onClick:Add(self.onSearch,self)

    self.listView = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onItemCallBack,self)

    self.labBangName = self.view:GetChild("n13")
    self.labLv = self.view:GetChild("n17")
    self.bar = self.view:GetChild("n9")
    self.labDec = self.view:GetChild("n15")
    self.labName = self.view:GetChild("n19")
    self.labDec1 = self.view:GetChild("n16")
    self.lanNotice = self.view:GetChild("n18")
    self.labCount = self.view:GetChild("n14") 
    self.inputtext = self.view:GetChild("n20")

    --帮派合并按钮
    self.combineBtn = self.view:GetChild("n29")
    self.combineBtn.onClick:Add(self.onClickCombin,self)
    self.checkBtn = self.view:GetChild("n28")
    self.checkBtn.onChanged:Add(self.selelctCheck,self)

    self:onController2()
    self:initDec()
end

function PanelBangPaiList:setSelectC2(index)
    -- body
    self.c2.selectedIndex = index
end

function PanelBangPaiList:selelctCheck()
    if self.checkBtn.selected then
        proxy.BangPaiProxy:sendMsg(1250701,{reqType = 3,acceptType = 1})
    else
        proxy.BangPaiProxy:sendMsg(1250701,{reqType = 3,acceptType = 0})
    end
end

function PanelBangPaiList:onController2()
    self.combineBtn.visible = false
    self.checkBtn.visible = false
    self.view:GetChild("n27").visible = false
    if self.c2.selectedIndex == 0 then

    elseif self.c2.selectedIndex == 1 then
        local gangJob = cache.PlayerCache:getGangJob()
        if tonumber(gangJob) >= 4 then
            self.combineBtn.visible = true
            self.checkBtn.visible = true
            self.view:GetChild("n27").visible = true
        end
    end
end

function PanelBangPaiList:clear()
    -- body
    self.bar.value = 0
    self.bar.max = 0
    self.labBangName.text = ""
    self.labLv.text = "LV0"
    self.labDec.text = language.bangpai01 
    self.labName.text = ""
    self.labDec1.text = language.bangpai05
    self.lanNotice.text = ""
    self.inputtext.text = ""
    self.labCount.text = ""
end

function PanelBangPaiList:initDec()
    -- body
    self:clear()
    
    local dec1 = self.view:GetChild("n21")
    dec1.text =  language.bangpai06

    local dec2 = self.view:GetChild("n22")
    dec2.text =  language.bangpai07

    local dec1 = self.view:GetChild("n23")
    dec1.text =  language.bangpai01

    local dec1 = self.view:GetChild("n24")
    dec1.text =  language.bangpai08

    local dec1 = self.view:GetChild("n25")
    dec1.text =  language.bangpai09
end

function PanelBangPaiList:celldata(index, obj)
    -- body
    local data = self.data.gangList[index+1]
    if index + 1 == self.number then
        if self.data.page~=self.data.maxPage then
            proxy.BangPaiProxy:sendMsg(1250102, {page = self.data.page+1,gangName = self.inputtext.text or "" })
        end
    end

    obj.data = data
    local lab1 = obj:GetChild("n2") 
    lab1.text = data.gangName or ""

    local lab2 = obj:GetChild("n3") 
    lab2.text = string.format(language.bangpai10,data.gangLev)

    local lab3 = obj:GetChild("n4")
    lab3.text = data.adminName
    -- local str = string.split(data.adminName,".")
    -- if #str == 2 then
    --     local param = {
    --         {text = str[1]..".",color = 7},
    --         {text = str[2],color = 6}
    --     }
    --     lab3.text = mgr.TextMgr:getTextByTable(param)
    -- else
    --     lab3.text = data.adminName
    -- end

    local lab4 = obj:GetChild("n5")
    lab4.text = GTransFormNum(data.gangPower)

    local isvip = obj:GetChild("n8") 
    isvip.visible = false
    if data.gangType == 1 then
        isvip.visible = true
    end

    local lab5 = obj:GetChild("n6")
    local condata = conf.BangPaiConf:getBangLev(data.gangLev,data.gangType)
    local str = data.memberNum.."/"..data.maxMemberNum
    if data.maxMemberNum>data.memberNum then
        lab5.text = mgr.TextMgr:getTextColorStr(str,7)
    else
        lab5.text = mgr.TextMgr:getTextColorStr(str,14)
    end

    local n7 = obj:GetChild("n7") 
    n7.visible = false
    if self.c2.selectedIndex == 0 then
        if data.applyStatu == 1 then
            n7.visible = true
        end
    end


end

function PanelBangPaiList:setRight(data)
    -- body
    self.curData = data
    self.labBangName.text = data.gangName
    self.bar.value = data.gangExp
    local condata = conf.BangPaiConf:getBangLev(data.gangLev,data.gangType)
    self.bar.max = condata.exp or data.gangExp
    self.labLv.text = "Lv"..data.gangLev
    self.labName.text = data.adminName
    self.lanNotice.text = data.gangNotice or ""
    -- if self.bar.value < self.bar.max then
    --     self.labCount.text = mgr.TextMgr:getTextColorStr(self.bar.value.."/"..self.bar.max,7) 
    -- else
    --     self.labCount.text = mgr.TextMgr:getTextColorStr(self.bar.value.."/"..self.bar.max,14) 
    -- end
    -- plog(data.applyStatu,"data.applyStatu")
    local gangId = cache.PlayerCache:getGangId()
    local gangJob = cache.PlayerCache:getGangJob()
    if gangId == data.gangId or tonumber(gangJob) < 4 then
        self.combineBtn.visible = false
    else
        self.combineBtn.visible = true
    end
    self.c1.selectedIndex = data.applyStatu or 0
    if self.c2.selectedIndex == 1 then
        self.combineBtn.data = data
    end
end

function PanelBangPaiList:updateCurData()
    -- body
    if self.curData then
        for k ,v in pairs(self.data.gangList) do
            if v.gangId == self.curData.gangId then
                self:setRight(v)
                break
            end
        end
    end
end

function PanelBangPaiList:onItemCallBack(context)
    -- body
    local data = context.data.data
    self:setRight(data) 
end

function PanelBangPaiList:setData(data)
    -- body
    self.data = data
    self.number = #data.gangList
    self.listView.numItems = self.number
    --self.c2.selectedIndex = 0
end

function PanelBangPaiList:gotoTop()
    -- body
    self.listView:RefreshVirtualList()
    self.listView.scrollPane:ScrollTop()
end

function PanelBangPaiList:selectTop()
    -- body
    self.listView:AddSelection(0,false)
    local data = self.data.gangList[1]
    if data then
        self:setRight(data)
    else
        self.curData = nil
        self:clear()
    end
end

--生气
function PanelBangPaiList:onBtnApply()
    -- body
    local param = {}
    param.gangIds = {}
    --称号位置调整
    if gRole then 
        gRole:setChenghao()
    end
    if self.curData then
        local condata = conf.BangPaiConf:getBangLev(self.curData.gangLev,self.curData.gangType)
        if self.curData.applyStatu == 0 then
            if self.curData.maxMemberNum>self.curData.memberNum then
                table.insert(param.gangIds,self.curData.gangId)
                proxy.BangPaiProxy:sendMsg(1250201, param)
            else
                GComAlter(language.bangpai139)
            end
        else
            GComAlter(language.bangpai13)
        end
    else
        GComAlter(language.bangpai11)
    end
end

function PanelBangPaiList:onOneKeyApply()
    -- body
    --一件申请
    local param = {}
    param.gangIds = {}
    param.reqType = 1
    if self.number == 0 then
        GComAlter(language.bangpai12)
        return
    end

    -- for k ,v in pairs(self.data.gangList) do
    --     if v.applyStatu == 0  then
    --         local condata = conf.BangPaiConf:getBangLev(v.gangLev,v.gangType)
    --         if maxMemberNum>v.memberNum then
    --             table.insert(param.gangIds,v.gangId)
    --         end
    --     end
    -- end
    --proxy.BangPaiProxy:sendMsg(1250201, param)
    if #self.data.gangList>0 then
        proxy.BangPaiProxy:sendMsg(1250201, param)
    else
        GComAlter(language.bangpai13)
    end
end
--创建帮会
function PanelBangPaiList:onBtnCreate()
    -- body
    mgr.ViewMgr:openView(ViewName.BangPaiCreate,function(view)
        -- body
    end)
end
--find
function PanelBangPaiList:onSearch()
    -- body
    local param = {}
    param.gangName = self.inputtext.text
    param.page = 1
    proxy.BangPaiProxy:sendMsg(1250102, param)
end

--请求帮派入伙
function PanelBangPaiList:onClickCombin(context)
    local data = context.sender.data
    if data then
        local gangId = data.gangId
        -- print("合入帮派id>>>>>>>>>>",gangId)
        local time = cache.BangPaiCache:getCombineTime()
        if time > 0 then
            GComAlter(string.format(language.bangpai201,time))
            return
        end
        cache.BangPaiCache:setCombineTime(60)
        proxy.BangPaiProxy:sendMsg(1250701,{reqType = 0,gangId = gangId})
    end
end

return PanelBangPaiList