--
-- Author: 
-- Date: 2017-02-22 16:17:05
--
--30天登录奖励
local LoginAwardView = class("LoginAwardView", base.BaseView)


function LoginAwardView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function LoginAwardView:initView()
    local btnClose = self.view:GetChild("n46"):GetChild("n3")
    btnClose.onClick:Add(self.onClickClose,self)

    self.dayText = self.view:GetChild("n29")
    self.dayText.text="1"

    self.descImage = self.view:GetChild("n37")
    self.itemImage = self.view:GetChild("n30")
    self.titleImage = self.view:GetChild("n31")
    self.node = self.view:GetChild("n47")

    self.btnGetAward = self.view:GetChild("n4")
    self.btnGetAward.onClick:Add(self.onClickGet,self)
    self.list = self.view:GetChild("n34")
    self:initListView()
    self.itemsPanels={}
    for i=1,4 do
        table.insert(self.itemsPanels,self.view:GetChild("n"..37+i))
    end
end

function LoginAwardView:initListView()
    self.list.numItems = 0
    self.list.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list:SetVirtual()
end

function LoginAwardView:initData()
    self.confData=conf.ActivityConf:getLoginAward()

    self.select=1
    self.first=true

    self.super.initData()
end

function LoginAwardView:add5030106(data)
    self.data = data
    self.dayText.text = data.curDay

    self.select = data.curDay > 30 and 30 or data.curDay
    for k,v in pairs(self.confData) do
        if not self:isInArray(k) then
            self.select = k
            break
        end
    end
    self.select = self.select > data.curDay and data.curDay or self.select
    self.list.numItems = #self.confData

    for i=0,#self.confData-1 do
        if i == self.select-1 then
            self.list:AddSelection(i,true)
            break
        end
    end
    self:setView()
    -- GOpenAlert3(data.items)
end

function LoginAwardView:isInArray(val)
    for _, v in ipairs(self.data.gotAwardIdList) do  
        if v == val then  
            return true  
        end  
    end  
    return false  
end

function LoginAwardView:setView()
    local confdata=self.confData[self.select]
    
    if not(confdata) then
        return
    end

    local flag=self:isInArray(self.select)
    self.btnGetAward.data={id=self.select}
    if flag then
        self.btnGetAward:GetChild("icon").url = UIPackage.GetItemURL("loginaward","sanshitiandenglu_035")
    else
        self.btnGetAward:GetChild("icon").url = UIPackage.GetItemURL("loginaward","sanshitiandenglu_034")
    end
    if self.select>self.data.curDay then
        flag=true
    end
    self.btnGetAward.grayed=flag
        self.btnGetAward:GetChild("red").visible = not flag

    self.dayText.text=self.select

    local downImg = self.view:GetChild("n49")
    downImg.visible = false
    local cansee = false
    if type(confdata.item_url) == "string" then
        local iconUrl = UIItemRes.activeIcons..confdata.item_url
        local check = PathTool.CheckResDown(iconUrl..".unity3d")
        if check or g_extend_res == false then
            self.itemImage.url = iconUrl
        else
            self.itemImage.url = UIPackage.GetItemURL("loginaward" , "sanshitiandenglu_028")
        end
        self.itemImage.visible = true
        local effect = self:addEffect(4020110,self.node)
    elseif type(confdata.item_url) == "number" then
        self.itemImage.visible = false
        local model = nil
        model,cansee = self:addModel(confdata.item_url,self.node)
        model:setScale(130)
        model:setRotationXYZ(0,180,0)
        model:setPosition(0,-self.node.actualHeight/2-30,100) 
    else
        self.itemImage.visible = false
    end
    downImg.visible = cansee
    
    if confdata.item_title then
        self.titleImage.url=UIPackage.GetItemURL("loginaward",confdata.item_title)
        self.titleImage.visible = true
    else
        self.titleImage.visible = false
    end
    if confdata.title_url then
        self.descImage.url=UIPackage.GetItemURL("loginaward",confdata.title_url)
        self.descImage.visible = true
    else
        self.descImage.visible = false
    end

    for i=1,4 do
        local param={mid=nil}
        if confdata.awards[i] then
            param.mid=confdata.awards[i][1]
            param.amount=confdata.awards[i][2]
            -- param.bind = conf.ItemConf:getBind(confdata.awards[i][1]) or 0
            param.bind=confdata.awards[i][3]
            GSetItemData(self.itemsPanels[i],param,true)
            self.itemsPanels[i].visible = true
        else
            self.itemsPanels[i].visible = false
        end
    end
end

function LoginAwardView:onClickGet(context)
    local btn = context.sender
    local flag=self:isInArray(btn.data.id)
    if not(flag) and self.data.curDay>=btn.data.id then
        proxy.ActivityProxy:sendMsg(1030106,{reqType=1,awardId=btn.data.id})
    end
end

function LoginAwardView:celldata(index, obj)
    -- body
    local data=self.confData[index+1]
    local title=obj:GetChild("n7")
    title.text="[color=#000000]"..language.loginaward01.."[/color][color=#0b8109]"..(index+1).."[/color][color=#000000]"..language.loginaward02.."[/color]"
    local name=obj:GetChild("n9")
    name.text=data.name

    local getImg = obj:GetChild("n13")--已领取图
    getImg.visible = false
    local clip = obj:GetChild("n12") --帧动画
    clip.visible = false
    local bar = obj:GetChild("n11")
    if self.data.curDay == index+1 then
        bar.value = 50
    elseif self.data.curDay < index+1 then
        bar.value = 0
    else
        bar.value = 100
    end
    local icon=obj:GetChild("n3")
    if data.icon then
        -- local iconUrl = UIItemRes.activeIcons..data.icon
        -- local check = PathTool.CheckResDown(iconUrl..".unity3d")
        -- if check or g_extend_res == false then
        --     icon.url = iconUrl
        -- else
            icon.url = UIPackage.GetItemURL("loginaward" , data.icon)
        -- end
    end

    local flag=self:isInArray(index+1)
    icon.grayed=flag
    if flag then
        clip.visible = false
        getImg.visible = true
    else
        if self.data.curDay >= index+1 then --有奖励可领取
            clip.visible = true
        else
            clip.visible = false
        end
    end

    local btnSelect = obj:GetChild("n3")
    btnSelect.data={}
    btnSelect.data.id=index+1
    btnSelect.onClick:Add(self.onClickCall,self)
end

function LoginAwardView:onClickCall( context )--展开
    local btn = context.sender
    self.select = btn.data.id
    self:setView()
end

function LoginAwardView:onClickClose()
    mgr.TimerMgr:removeTimer(self.timer)
    self:closeView()
end

return LoginAwardView