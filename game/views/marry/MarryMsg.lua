--
-- Author: 
-- Date: 2017-07-25 17:39:59
--

local MarryMsg = class("MarryMsg",import("game.base.Ref"))

function MarryMsg:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n7")
    self:initView()
end

function MarryMsg:initView()
    -- body
    self.btnGo = self.view:GetChild("n4")
    self.img = self.view:GetChild("n9")
    self.btnGo.onClick:Add(self.onGoMarry,self)

    self.listView = self.view:GetChild("n20")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 4

    self.c1 = self.view:GetController("c1")

    local dec1 = self.view:GetChild("n35")
    local dec2 = self.view:GetChild("n36")

    if cache.PlayerCache:getSex() == 1 then
        dec1.text = string.format(language.kuafu87,cache.PlayerCache:getRoleName())
        dec2.text = string.format(language.kuafu88,cache.PlayerCache:getCoupleName())
    else
        dec1.text = string.format(language.kuafu87,cache.PlayerCache:getCoupleName())
        dec2.text = string.format(language.kuafu88,cache.PlayerCache:getRoleName())
    end

    self.dec1 = self.view:GetChild("n28")
    self.dec2 = self.view:GetChild("n29")
    self.dec3 = self.view:GetChild("n30")
    self.dec4 = self.view:GetChild("n31")
    self.dec5 = self.view:GetChild("n32")
    self.dec6 = self.view:GetChild("n33")
    self.dec7 = self.view:GetChild("n34")

    local divorceTxt = self.view:GetChild("n37") --bxp离婚
    divorceTxt.text = mgr.TextMgr:getTextColorStr(language.kuafu168,7,"")
    divorceTxt.onClickLink:Add(self.onGoMarry,self)
end

function MarryMsg:celldata( index, obj )
    -- body
    local c1 = obj:GetController("c1")
    c1.selectedIndex = index
end

function MarryMsg:initName()
    -- body
    self.data = cache.PlayerCache:getData()
    local sex = cache.PlayerCache:getSex() 
    if self.data.coupleName ~= "" then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
end

function MarryMsg:onGoMarry()
    -- body
    if mgr.FubenMgr:checkScene() then
        GComAlter(language.gonggong41)
        return
    end
    local mainTaskId = cache.TaskCache:getCurMainId()
    -- print("当前主线任务id>>>>>>>>>",mainTaskId)
    if mainTaskId <= 1014 and mainTaskId ~= 0 then
        GComAlter(language.task20)
        return
    end
    
    mgr.TaskMgr:setCurTaskId(9003)
    mgr.TaskMgr.mState = 2
    mgr.TaskMgr:resumeTask()
end

function MarryMsg:addMsgCallBack(data)
    -- body
    if data.msgId == 5390201 then
        local condata = conf.MarryConf:getRingItem(data.ringLev)

        if condata and condata.step and  condata.star and condata.step > 0 then
            local var = string.format(language.kuafu95,
                language.gonggong21[condata.step],language.gonggong21[condata.star]
                or language.gonggong84)
            self.dec1.text = string.format(language.kuafu89,var)
        else
            self.dec1.text = string.format(language.kuafu89,language.kuafu110)
        end

        local condata = conf.MarryConf:getQingyuanItem(data.qyLev)
        if condata and condata.step and  condata.star then
            local var = string.format(language.kuafu95,
                language.gonggong21[condata.step],language.gonggong21[condata.star]
                or language.gonggong84)
            self.dec2.text = string.format(language.kuafu90,var)
        else
            self.dec2.text = string.format(language.kuafu90,language.kuafu110)
        end

        local condata = conf.MarryConf:getTreeItem(data.treeLev)
        if condata and condata.step and  condata.star then
            local var = string.format(language.kuafu95,
                language.gonggong21[condata.step],language.gonggong21[condata.star]
                or language.gonggong84)
            self.dec3.text = string.format(language.kuafu91,var)
        else
            self.dec3.text = string.format(language.kuafu91,language.kuafu110)
        end
        if cache.PlayerCache:getCoupleName()~="" then
            local temp = os.date("*t",data.weddingTime)
            --年月日
            local str = ""
            str = str .. temp.year .. language.gonggong78
            str = str .. temp.month .. language.gonggong79
            str = str .. temp.day  .. language.gonggong80

            local t = {
                language.gonggong80,
                language.gonggong21[1],
                language.gonggong21[2],
                language.gonggong21[3],
                language.gonggong21[4],
                language.gonggong21[5],
                language.gonggong21[6]
            }

            str = str .. "(" ..language.gonggong81..t[temp.wday]..")"
            self.dec4.text = string.format(language.kuafu92,str)
            --时长
            local time = mgr.NetMgr:getServerTime() - data.weddingTime
            time = math.max(math.ceil(time/86400),1)
            self.dec5.text =string.format(language.kuafu93,time..language.gonggong82)
            --特惠
            self.dec6.text = string.format(language.kuafu94,language.gonggong81..t[temp.wday]) 
            self.dec7.text = language.kuafu96

            --self.imgmarry.visible = false
        else
            self.dec4.text = ""
            self.dec5.text = ""
            self.dec6.text = ""
            self.dec7.text = ""
            --self.imgmarry.visible = true
        end

        
    end
end

return MarryMsg