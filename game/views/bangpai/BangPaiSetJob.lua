--
-- Author: 
-- Date: 2017-03-07 19:05:47
--

local BangPaiSetJob = class("BangPaiSetJob", base.BaseView)

local language_pos = {
    language.bangpai47,
    language.bangpai04,
    language.bangpai03,
    language.bangpai02,
    language.bangpai01,
}
local jobmax = {
    [1] = 4,
    [2] = 4,
    [3] = 2   
}

function BangPaiSetJob:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BangPaiSetJob:initData(data)
    -- body
    self.data = data
end


function BangPaiSetJob:initView()
    self.c1 = self.view:GetController("c1")
    self.c2 =  self.view:GetController("c2")
    self.view:GetChild("n12"):GetChild("n2").visible = false

    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.labname = self.view:GetChild("n23")
    self.lablv = self.view:GetChild("n24")
    self.labpower = self.view:GetChild("n25")
    self.labpos = self.view:GetChild("n26")

    self.radio1 = self.view:GetChild("n6")
    self.radio2 = self.view:GetChild("n18")
    self.radio3 = self.view:GetChild("n17")

    self.labvar1 = self.view:GetChild("n28")
    self.labvar2 = self.view:GetChild("n30")
    self.labvar3 = self.view:GetChild("n29")

    local btnSet = self.view:GetChild("n10")
    btnSet:GetChild("title").text = language.bangpai55
    btnSet.onClick:Add(self.onSetPos,self)

    local btnSure = self.view:GetChild("n7")
    btnSure.onClick:Add(self.onSure,self)

    self.listview = self.view:GetChild("n35")
    self.listview.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listview.numItems = 1

    self:initDec()
end

function BangPaiSetJob:celldata(index,obj)
    -- body
    local lab = obj:GetChild("n0")
    lab.text = language.bangpai56

    obj.height = lab.height + 3
end

function BangPaiSetJob:initDec( )
    -- body
    local lab = self.view:GetChild("n19")
    lab.text = language.bangpai35

    local lab = self.view:GetChild("n20")
    lab.text = language.bangpai36

    local lab = self.view:GetChild("n21")
    lab.text = language.bangpai37

    local lab = self.view:GetChild("n22")
    lab.text = language.bangpai53

    local lab = self.view:GetChild("n27")
    lab.text = language.bangpai54

    -- local lab = self.view:GetChild("n31")
    -- lab.text = language.bangpai56

    self.labname.text = ""
    self.lablv.text =""
    self.labpower.text=""
    self.labpos.text ="" 

    self.labvar1.text =""
    self.labvar2.text=""
    self.labvar3.text=""


end

function BangPaiSetJob:initRoleMsg()
    -- body
    local str = string.split(self.data.roleName,".")
    if #str == 2 then
        local param = {
            {text = str[1]..".",color = 7},
            {text = str[2]..".",color = 6}
        }
        self.labname.text = mgr.TextMgr:getTextByTable(param)
    else
        self.labname.text = mgr.TextMgr:getTextColorStr(self.data.roleName, 6)
    end

    self.lablv.text = self.data.roleLev
    self.labpower.text = self.data.power
    self.labpos.text = language_pos[self.data.job+1]

    local job = cache.BangPaiCache:getgangJob()
    local index = 1
    for i = job-1,0 ,-1 do
        if i ~= self.data.job then
            local number = cache.BangPaiCache:getNumberByJob(i)
            self["labvar"..index].text = language_pos[i+1] 
            if i~=0 then
                self["labvar"..index].text = language_pos[i+1] .. "("..number.."/"..jobmax[i]..")"
            end
            self["labvar"..index].data = i 

            index = index + 1 
        end
    end

    for i = index , 3 do
        self["radio"..i].visible = false
    end
end

function BangPaiSetJob:setData(data_)
    self:initRoleMsg()
end

function BangPaiSetJob:onSetPos()
    -- body
    if self.c2.selectedIndex == 0 then
        self.c2.selectedIndex = 1
    else
        self.c2.selectedIndex = 0
    end
end

function BangPaiSetJob:onSure()
    -- body

    local job = self["labvar"..(self.c1.selectedIndex+1)].data
    local param = {
        job = job,
        roleId = self.data.roleId
    }

    proxy.BangPaiProxy:sendMsg(1250207, param)
    self:closeView()
end

function BangPaiSetJob:onBtnClose( )
    -- body
    self:closeView()
end

return BangPaiSetJob