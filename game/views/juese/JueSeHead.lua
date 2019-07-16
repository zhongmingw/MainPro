--
-- Author: 
-- Date: 2017-02-04 14:00:45
--

local JueSeHead = class("JueSeHead", base.BaseView)

function JueSeHead:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end
function JueSeHead:initData(data)
    -- body
    self.id = data
    self.data = cache.PlayerCache:getHeadData()
    self.confData = conf.RoleConf:getHeadConf()
    self:setData()
    if self.timeer then
        self:removeTimer(self.timeer)
    end
    self.timeer = self:addTimer(1,-1,handler(self,self.onTimer))
end



function JueSeHead:initView()
    local btnClose = self.view:GetChild("n2"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    --头像
    self.listView = self.view:GetChild("n8")
    self.listView.numItems = 0 
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end 
    self.listView.onClickItem:Add(self.onUIClickCall,self)
    --获取条件
    local dec = self.view:GetChild("n11")
    dec.text = language.juese09
    --self.dec = dec 

    self.labDec = self.view:GetChild("n10")
    self.labDec.text = ""
    --佩戴
    local btnSure = self.view:GetChild("n5")
    btnSure.onClick:Add(self.onBtnSure,self)
    self.btnSure = btnSure

    local dec1 = self.view:GetChild("n13")
    dec1.text = ""
    self.dec1 = dec1

    self.timedec = self.view:GetChild("n12")
    self.timedec.text = ""

    local dec = self.view:GetChild("n17")
    dec.text = language.juese25
    --
    self.prolist = {}
    for i = 18,24 do 
        local lab = self.view:GetChild("n"..i)
        lab.text = ""
        table.insert(self.prolist,lab)
    end
end

function JueSeHead:getMsgById(id)
    -- body
    if not self.data then
        return
    end

    for k ,v in pairs(self.data.headImgs) do
        if tonumber(v.headId) == tonumber(id) then
            return v 
        end
    end

    return nil
end

function JueSeHead:checkOutDay(condata)
    -- body
    local cachedata = self:getMsgById(condata.id)
    if not cachedata then
        return 0
    end

    if not condata.time or condata.time == 0 then --固定的
        return 1
    else
        if cachedata then --检测是否过期
            local var = mgr.NetMgr:getServerTime() - cachedata.gotTime
            if var >= condata.time then
                return 0
            end
        else
            return 0
        end
    end

    return 1
end

function JueSeHead:onTimer()
    -- body
    if not self.data then
        return
    end
    
    -- for i = 1 ,self.listView.numItems do
    --     local cell = self.listView:GetChildAt(i-1)
    --     if cell then --过去弄成不可点击
    --         local data = self.confData[i]
    --         local isget = self:checkOutDay(data)
    --         local c1 = cell:GetController("c1")
    --         c1.selectedIndex = isget 
    --     end
    -- end
    --检测当前
    if self.selectdata then
        local isget = self:checkOutDay(self.selectdata)
        if isget == 0 then --当前获得过期了
            --plog("过期处理")
            --self:doTimeout()
        else
            if not self.selectdata.time or self.selectdata.time == 0 then --固定的
                self.timedec.text = "" --永久的
                self.dec1.text = ""
            else
                self.dec1.text = language.juese24 
                local cachedata = self:getMsgById(self.selectdata.id)
                if cachedata then
                    local var = mgr.NetMgr:getServerTime() - cachedata.gotTime
                    local leftTime = self.selectdata.time - var
                    if var <= 0 then
                        --self:doTimeout()
                    else
                        self.timedec.text = GTotimeString(leftTime)
                    end
                end
            end
        end
    end
end

function JueSeHead:celldata(index,obj)
    -- body
    local data = self.confData[index+1]
    --头像
    local roleIcon = cache.PlayerCache:getSex()*100000000 + tonumber(data.id)

    local isget = self:checkOutDay(data) --self.data.headImgs[data.id] and 1 or 0
    
    local t = { roleIcon = tonumber(roleIcon) }
    GBtnGongGongSuCai_050(obj:GetChild("n1"),t)
    local c1 = obj:GetController("c1")
    c1.selectedIndex = isget 

    local labname = obj:GetChild("n3")
    labname.text = data.name

    data.isget = isget
    obj.data = data
end

function JueSeHead:onUIClickCall( context )
    -- body
    local cell = context.data
    self:setGetFromInfo(cell.data)
end

function JueSeHead:setData()
    self.listView.numItems = #self.confData
    --选中一个默认的
    local index = 0
    local data 
    for k ,v in pairs(self.confData) do 
        local var = self:checkOutDay(v)
        if self.id == v.id then
            index = k - 1 
            data = v 
            data.isget = var
            break
        elseif tonumber(var) == 1 and v.isUse == 2 then
            index = k - 1 
            data = v 
            data.isget = 1
            break
        end
    end
    --避免错误处理
    if not data then
        data = self.confData[1]
        index = 0
        data.isget = 1
    end

    if data then--默认穿戴的头像
        self.listView:AddSelection(index,false) 
        self.listView:ScrollToView(index)
        self:setGetFromInfo(data)
    end
end

function JueSeHead:setGetFromInfo(data)
    -- body
    -- if data.isget == 0 then
    --     self.labDec.text = data.dec
    --     self.dec.text = language.juese09
    -- else
    --     self.labDec.text = ""
    --     self.dec.text = ""
    -- end
    self.selectdata = data
    self.labDec.text = data.dec
    self.timedec.text = ""
    self.id = data.id 

    --设置属性
    for k ,v in pairs(self.prolist) do
        v.text = ""
    end

    local t = GConfDataSort(self.selectdata)
    --printt(self.selectdata,"self.selectdata")
    for k ,v in pairs(t) do
        if self.prolist[k] then
            self.prolist[k].text = conf.RedPointConf:getProName(v[1]).. "  " .. GProPrecnt(v[1],v[2])
        end
    end
end

function JueSeHead:onBtnSure()
    -- body
    if not self.id then
        return 
    end

    local data = self:getMsgById(self.id)
    if not data then
        GComAlter(language.juese13) 
        return
    end

    if data.isUse == 2 then
        GComAlter(language.juese12) 
        return
    end

    if self:checkOutDay(self.selectdata) == 0 then
        GComAlter(language.juese26)
        return
    end

    proxy.PlayerProxy:send(1020203,{headImgId = self.id})
    self:onBtnClose()
end

function JueSeHead:doTimeout()
    -- body
    proxy.PlayerProxy:send(1020203,{headImgId = 0})
    GComAlter(language.juese26)
    self:onBtnClose()
end

function JueSeHead:onBtnClose()
    -- body
    self:closeView()
end

return JueSeHead