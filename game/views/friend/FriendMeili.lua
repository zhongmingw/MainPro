--
-- Author: 
-- Date: 2017-02-07 15:03:02
--

local FriendMeili = class("FriendMeili", import("game.base.Ref"))

function FriendMeili:ctor(param)
    self.view = param
    self:initView()
end

function FriendMeili:initView()
    -- body
    --几个星
    local _zujian = self.view:GetChild("n63")
    self.controllerC1 = _zujian:GetController("c1")

    self.controllerC2 = self.view:GetController("c2")
    --魅力阶
    self.imgJie = self.view:GetChild("n40")
    self.imgfontJie = self.view:GetChild("n42")
    self.labname = self.view:GetChild("n45")
    self.labname.text = ""
    --属性加成
    self.listJia = {}
    for i = 46 , 53 do 
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.listJia,text)
    end
    self.labpower = self.view:GetChild("n61") 
    --
    self.progressbar = self.view:GetChild("n111")
    self.progressbar.value = 0

    self.frame = self.view:GetChild("n43")
    self.icon = self.view:GetChild("n44")

    local dec = self.view:GetChild("n55")
    dec.text = language.meili01
    self.LabmeiValue = self.view:GetChild("n56")
    self.LabmeiValue.text = ""

    local btnUp = self.view:GetChild("n10")
    btnUp.onClick:Add(self.onbtnCallBack,self)
    self.btnUp = btnUp

    self.redimg = btnUp:GetChild("red")
    --
    local dec1 = self.view:GetChild("n57")
    local dec2 = self.view:GetChild("n58")
    local dec3 = self.view:GetChild("n59")
    dec1.text = language.meili02
    dec2.text = language.meili03
    dec3.text = language.meili04

    self.listview = self.view:GetChild("n60")
    self.listview:SetVirtual()
    self.listview.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listview.numItems = 0

    
end

function FriendMeili:send()
    -- body
    proxy.FriendProxy:sendMsg(1070303, {reqType = 1})
    proxy.FriendProxy:sendMsg(1070304, {page = 1})
end

function FriendMeili:celldata( index,obj )
    -- body
    if index + 1 >= self.listview.numItems then
        if self.listdata.totalSum == self.listdata.page then 
            --没有下一页了
            --return
        else
            --proxy.FriendProxy:sendMsg(1070304,{page = self.listdata.page + 1})
        end
    end
     --头像
    local data = self.listdata.heartRecord[index+1]
    local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId }

    local c1 = obj:GetController("c1")
    if index<=2 then
        c1.selectedIndex = index
        GBtnGongGongSuCai_050(obj:GetChild("n9"),t)
    else
        c1.selectedIndex = 3
    end

    local labrank = obj:GetChild("n6")
    labrank.text =  data.rank 

    local labname = obj:GetChild("n7")
    labname.text = data.name

    local labxin = obj:GetChild("n8")
    labxin.text = data.heartSum
end

--进阶
function FriendMeili:onbtnCallBack()
    -- body
    self.flag = true
    proxy.FriendProxy:sendMsg(1070303, {reqType = 2})
end

function FriendMeili:initLeftMsg(flag)
    -- body
    for k ,v  in pairs(self.listJia) do
        v.text = ""
    end
    --printt(self.data)
    local confData = conf.FriendConf:getDataById(self.data.charmStepId)

    self.imgJie.url = UIItemRes.meili[confData.step]
    self.imgfontJie.url = UIItemRes.jieshu[confData.step] 
    self.labname.text =confData.name
    --属性
    local t = GConfDataSort(confData)
    local index = 1 
    for k , v in pairs(t) do
        if not self.listJia[index] then
            break
        elseif v[1] == 501 then
        else
            self.listJia[index].text = conf.RedPointConf:getProName(v[1]) .. " " ..v[2]
            index = index+ 1
        end
       
    end
    --战力
    self.labpower.text = confData.att_501 or 0


    local _exp = self.data.charmValue --- confData.charm_value
    self.progressbar.value = self.data.charmValue --_exp < 0 and self.data.charmValue or _exp
    local nextconf = conf.FriendConf:getDataById(self.data.charmStepId+1)
    if not nextconf then
        self.redimg.visible = false
        self.controllerC1.selectedIndex = 20
        self.progressbar.max = confData.charm_value --self.progressbar.value
        local param = {
            {color = 14,text=self.progressbar.value},
            {color = 7,text="/"..self.progressbar.max}
        }
        if _exp <= 0 then
            param = {
            {color = 7,text=self.progressbar.value},
            {color = 7,text="/"..self.progressbar.max}
        }
        end 
        self.LabmeiValue.text = mgr.TextMgr:getTextByTable(param)
        self.btnUp.visible = false

        self.controllerC2.selectedIndex = 1
    else
        --self.controllerC2.selectedIndex = 0
        --self.isnext = true
        if self.is10 and  confData.xin~=0 then
            self.controllerC1.selectedIndex = confData.xin + 10 
        else
            self.controllerC1.selectedIndex = confData.xin
            
        end

        if confData.xin == 10 then
            self.controllerC2.selectedIndex = 2
        else
            self.controllerC2.selectedIndex = 0
        end

        self.progressbar.max =  nextconf.charm_value --nextconf.charm_value -

        local param = {

            {color = 14,text=self.progressbar.value},
            {color = 7,text="/"..self.progressbar.max}
        }
        self.redimg.visible = false
        if self.data.charmValue >= nextconf.charm_value then
            self.redimg.visible = true
            param = {
            {color = 7,text=self.progressbar.value},
            {color = 7,text="/"..self.progressbar.max}
        }
        end
        self.LabmeiValue.text = mgr.TextMgr:getTextByTable(param)
        self.btnUp.visible = true
    end

    if flag then
        if self.progressbar.value < self.progressbar.max or not nextconf then
            --红点扣除 经验不足 或者 没有下一级了
            mgr.GuiMgr:redpointByID(10228)
        end
    end
end


function FriendMeili:setData(data,param)
    -- body
    if 5070303 == data.msgId then
        if not self.data then
            self.is10 = true
        elseif self.data.charmStepId == data.charmStepId then
            self.is10 = true
        else
            self.is10 = false
        end
        if self.flag then
            mgr.SoundMgr:playSound(Audios[2])
            self.flag = false
        end
        self.data = data
        self:initLeftMsg(true)
    elseif 5070304 == data.msgId then
        if data.page == 0 then
            return
        end
        --printt(data)
        if data.page == 1 then 
            self.listdata = {} 
            self.listdata.page = data.page
            self.listdata.totalSum = data.totalSum
            self.listdata.heartRecord = data.heartRecord
        else
            if data.page ~= self.data.page then 
                self.listdata.page =  data.page
                for k ,v in pairs(data.heartRecord) do 
                    table.insert(self.listdata.heartRecord,v)
                end
            end
        end 
        --[[for k ,v in pairs(self.listdata.heartRecord) do
            print(k,v)
        end]]--
        --plog(table.nums(self.listdata.heartRecord) )
        --plog(#self.listdata.heartRecord)
        self.listview.numItems = #self.listdata.heartRecord
        --self:initRightList()
    end
end
return FriendMeili