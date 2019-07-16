--
-- Author: 
-- Date: 2018-04-16 17:26:07
--
local pairs = pairs
local PanelKeJi = class("PanelKeJi",import("game.base.Ref"))

function PanelKeJi:ctor(parent)
    self.parent = parent
    self.view = self.parent.view:GetChild("n36")
    self:initView()
end

function PanelKeJi:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    self.c3 = self.view:GetController("c3")

    self.c1.selectedIndex = 1
    self.c2.selectedIndex = 1
    self.c3.selectedIndex = 0

    self.effct1 = self.view:GetChild("n50")
    self.effct2 = self.view:GetChild("n51")
    self.effct3 = self.view:GetChild("n52")

    local btn1 = self.view:GetChild("n2")
    btn1.data = 1
    btn1.onClick:Add(self.onThreeCall,self)
    local btn1 = self.view:GetChild("n6")
    btn1.data = 2
    btn1.onClick:Add(self.onThreeCall,self)
    local btn1 = self.view:GetChild("n9")
    btn1.data = 3
    btn1.onClick:Add(self.onThreeCall,self)


    --3个技能
    self.listskill = {}
    local t = {}
    t.icon = self.view:GetChild("n13")
    t.name = self.view:GetChild("n14")
    t.level = self.view:GetChild("n15")
    table.insert(self.listskill,t)

    local t1 = {}
    t1.icon = self.view:GetChild("n16")
    t1.name = self.view:GetChild("n17")
    t1.level = self.view:GetChild("n18")
    table.insert(self.listskill,t1)
    
    local t2 = {}
    t2.icon = self.view:GetChild("n19")
    t2.name = self.view:GetChild("n20")
    t2.level = self.view:GetChild("n21")
    table.insert(self.listskill,t2)

    for k , v in pairs(self.listskill) do
        v.icon.visible = false
        v.name.visible = false
        v.level.visible = false

        v.icon.data = k 
        v.icon.onClick:Add(self.onskilcall,self)
    end
    --升级和所需

    self.btnup1 = self.view:GetChild("n38")
    self.btnup1.onClick:Add(self.onKeji1,self)

    self.btnup2 = self.view:GetChild("n37")
    self.btnup2.onClick:Add(self.onKeji2,self)

    self.bgurl = self.view:GetChild("n1")

    self:initDec()
end

function PanelKeJi:initDec()
    -- body
    local lab = self.view:GetChild("n48")
    lab.text = ""
    local lab = self.view:GetChild("n41")
    lab.text = ""
    -- local lab = self.view:GetChild("n53")
    -- lab.text = language.bangpai196

    self._need1 = self.view:GetChild("n49")
    self._need1.text = ""

    self.icon = self.view:GetChild("n12")
    self._name = self.view:GetChild("n33")
    self._name.text = ""
    self._type = self.view:GetChild("n29") 
    self._type.text = ""
    self._level = self.view:GetChild("n30") 
    self._level.text = ""
    self._curdec = self.view:GetChild("n34") 
    self._nextdec = self.view:GetChild("n35") 
    self._need2 = self.view:GetChild("n42")
    self._need2.text = ""
end
--科技选择
function PanelKeJi:onThreeCall(context)
    -- body
    if not self.data then
        return
    end
    

    self.skillid = nil --切换时候改变技能id
    local btn = context.sender
    self.btnid  = btn.data
    self:onClickScaleAndPlayEffect(btn)

    self:setData()
end

--EVE 点击缩放+播放特效
function PanelKeJi:onClickScaleAndPlayEffect(btn)
    --放大点击按钮
    local btnSelectedId = btn.data
    btn:SetScale(1.1,1.1)

    if btnSelectedId ~= self.btnSelectedId then 
        if self.oldbtn then
            self.oldbtn:SetScale(1.0,1.0)
        end
        self.oldbtn = btn
        --播放特效
        local effctBg = 0
        local condata = conf.BangPaiConf:getBangKejiSkilllist(btnSelectedId)

        if btnSelectedId == 1 then 
            effctBg = self.effct1
        elseif btnSelectedId == 2 then 
            effctBg = self.effct2
        else 
            effctBg = self.effct3
        end 

        if self.curEffect then 
            self.parent:removeUIEffect(self.curEffect)
        end
        -- print("condata.effect_id",condata.effect_id)
        self.curEffect = self.parent:addEffect(condata.effect_id, effctBg)
        self.curEffect.Scale = Vector3.New(80,80,80)         --特效缩放
        self.curEffect.LocalPosition = Vector3.New(19,-1,0)  --特效位置
    end

    self.btnSelectedId = btnSelectedId
end

--切换/关闭窗口时复位一些设置
function PanelKeJi:reSetData()
    -- body
    if self.oldbtn then 
        if self.btnSelectedId and self.btnSelectedId ~= 1 then 
            self.oldbtn:SetScale(1.0,1.0)
        end 
        self.oldbtn = nil
    end 

    if self.btnSelectedId then 
        self.btnSelectedId = nil
    end 
end

--科技技能选择
function PanelKeJi:onskilcall(context)
    -- body
    if not self.data or not self.condata then
        return
    end
    for k , v in pairs(self.listskill) do
        local imgChange = v.icon:GetChild("n3")
        imgChange.visible = false
    end
    local btn = context.sender
    local imgChange = btn:GetChild("n3")
    imgChange.visible = true

    local data = btn.data
    self.skillid = self.condata.list[data]
    self:setRightInfo()
end

function PanelKeJi:onKeji1()
    -- body
    if self:checkJihuo() then
        local param = {}
        param.reqType = 1 
        param.techType = self.skillid
        proxy.BangPaiProxy:sendMsg(1250601,param)
    end
end
function PanelKeJi:onKeji2()
    -- body
    if self:checkSkillUp() then
         local param = {}
        param.reqType = 2 
        param.techType = self.skillid
        proxy.BangPaiProxy:sendMsg(1250601,param)
    end
end


--职位条件：副盟主或盟主      物品条件：B资源
function PanelKeJi:checkJihuo()
    -- body
    if not self.data then
        return false
    end
    --是否顶级
    local level = self.data.gangTechLevs[self.skillid] or 0 --默认初始等级
    local _nextid = string.format("%d%02d",self.skillid,level+1)
    local nextconf = conf.BangPaiConf:getBangKejiselfinfo(_nextid)
    if not nextconf then
        print("顶级了 @wx 按钮不该出现或者应该其他表现")
        return false
    end
    --职位条件：
    local job = cache.BangPaiCache:getgangJob()
    --print("job",job)
    if not job or job <= 2 then
        GComAlter(language.bangpai190)
        return false
    end
    --物品条件
    if self.data.zj < self.needzj then
        GComAlter(language.bangpai191)
        return false
    end

    return true
end
--消耗物品：A资源
function PanelKeJi:checkSkillUp()
    -- body
    if not self.data then
        return false
    end
    local _s_level = self.data.mineTechLevs[self.skillid] or 0
    local _nextid = string.format("%d%03d",self.skillid,_s_level+1)
    local nextconf = conf.BangPaiConf:getBangTechStudy(_nextid)
    if not nextconf then
        print("顶级了 @wx 按钮不该出现或者应该其他表现")
        return false
    end
    if self.max <= _s_level then
        GComAlter(language.bangpai193)
        return false
    end

    --物品条件
    if cache.PlayerCache:getTypeMoney(MoneyType.ylxw) < self.need_ylxw then
        GComAlter(language.bangpai192)
        return false
    end

    return true
end

function PanelKeJi:setData(  )
    -- body
    if not self.btnid then
        self.btnid = 1 --避免错而已
    end
    self.condata = conf.BangPaiConf:getBangKejiSkilllist(self.btnid)
    if not self.condata or not self.condata.list then
        print("配置缺少",self.btnid)
        return
    end
    if not self.skillid then
        self.skillid = self.condata.list[1]
    end

    for k , v in pairs(self.listskill) do
        v.icon.visible = false
        v.name.visible = false
        v.level.visible = false
        local imgChange = v.icon:GetChild("n3")
        imgChange.visible = false

        local infoid = self.condata.list[k]
        if infoid then
            if infoid == self.skillid then
                imgChange.visible = true
            end

            local level = self.data.gangTechLevs[infoid] or 0 --默认初始等级
            local confdata = conf.BangPaiConf:getBangKejiinfo(infoid)
            if not confdata then
                print("配置缺少 gang_tech_info",infoid)
            end
            v.icon.visible = true
            v.name.visible = true
            v.level.visible = true
            if confdata.icon then
                v.icon:GetChild("n1").url = ResPath.iconRes(confdata.icon)
            end
            local suo = v.icon:GetChild("n2")
            if level > 0 then
                suo.visible = false
            else
                suo.visible = true
            end
            v.name.text = confdata.name or ""
            v.level.text = language.bangpai197..level

            --红点检测
            --local redImg = v.icon:GetChild("n4")
            --redImg.visible =  self:checkOneSkillup(infoid) > 0 
        end
    end

    self:setRightInfo()
end

function PanelKeJi:setRightInfo()
    -- body
    --左边消耗信息
    local level = self.data.gangTechLevs[self.skillid] or 0 --默认初始等级
    --print(level,self.skillid) 

    local id = string.format("%d%02d",self.skillid,level)
    local _nextid = string.format("%d%02d",self.skillid,level+1)
    local confdata = conf.BangPaiConf:getBangKejiselfinfo(id)
    local nextconf = conf.BangPaiConf:getBangKejiselfinfo(_nextid)

    -- local _s_level = self.data.mineTechLevs[self.skillid] or 0 --个人技能等级信息
    -- local id = string.format("%d%03d",self.skillid,_s_level)
    -- local confdata = conf.BangPaiConf:getBangKejiselfinfo(id)

    -- local _nextid = string.format("%d%03d",self.skillid,_s_level+1)
    -- local nextconf = conf.BangPaiConf:getBangKejiselfinfo(_nextid)

    --个人科技等级信息
    local _s_level = self.data.mineTechLevs[self.skillid] or 0 --个人技能等级信息

    self.max = confdata.max_study_lev
    if nextconf then
        self.c2.selectedIndex = 0 
        if level <= 0 then
            self.c3.selectedIndex = 0
        else
            self.c3.selectedIndex = 1
        end
        self.needzj = confdata.cost_zj
        local param = {
            {text = self.data.zj,color = 7},
            {text = "/"..self.needzj,color = 6},
        }
        if self.data.zj < self.needzj then
            param[1].color = 14

            --self.btnup1:GetChild("red").visible = false
        else
            --self.btnup1:GetChild("red").visible = true
        end
        self._need1.text = mgr.TextMgr:getTextByTable(param)
    else
        self.c2.selectedIndex = 1
    end

    local _flag = false
    if level <= 0 and _s_level <= 0 then
        --科技技能未开启
        _flag = true
    end


    local _confdata1 = conf.BangPaiConf:getBangKejiinfo(self.skillid)
    if _confdata1.icon then
        self.icon:GetChild("n1").url = ResPath.iconRes(_confdata1.icon)
    end
    --self._name.text = _flag and language.bangpai194 or _confdata1.name
    local suo = self.icon:GetChild("n2")
    if level <= 0 then
        self._name.text = language.bangpai195
        suo.visible = true
    else
        suo.visible = false
        if _s_level <= 0 then
            self._name.text = language.bangpai194
        else
            self._name.text = _confdata1.name or ""
        end
    end
    self._type.text = language.bangpai188.._confdata1.type
    self._level.text = language.bangpai189.._s_level

    --单个技能信息 
    local id = string.format("%d%03d",self.skillid,_s_level)
    local _nextid = string.format("%d%03d",self.skillid,_s_level+1)
    local confdata = conf.BangPaiConf:getBangTechStudy(id)
    local nextconf = conf.BangPaiConf:getBangTechStudy(_nextid)

    if nextconf then
        --self.btnup2:GetChild("red").visible = false
        if _flag then 
            --未开启
            self.c1.selectedIndex = 1
            self._curdec.text =  nextconf.dec or ""
        else
            self._nextdec.text = nextconf.dec or ""
            self.c1.selectedIndex = 0

            self._curdec.text =  confdata.dec or ""
            self.need_ylxw = confdata.cost_xw or 0
            local ylxw = cache.PlayerCache:getTypeMoney(MoneyType.ylxw)
            local param = {
                {text = ylxw,color = 7},
                {text = "/"..self.need_ylxw,color = 6},
            }

            if ylxw < self.need_ylxw then
                param[1].color = 14
            else
                --self.btnup2:GetChild("red").visible = true
            end
            self._need2.text = mgr.TextMgr:getTextByTable(param)
        end
    else
        --self.btnup2:GetChild("red").visible = false
        self._curdec.text =  confdata.dec or ""
        self._nextdec.text = ""
        self.c1.selectedIndex = 2

        self._level.text = self._level.text .. mgr.TextMgr:getTextColorStr(language.bangpai196, 7) 
    end
end

function PanelKeJi:addMsgCallBack(data)
    -- body
    if 5250601 == data.msgId then
        --printt("5250601",data)
        self.data = data
        self.bgurl.url = UIItemRes.bangpai05
        if data.reqType == 0 then
            self.btnid = 1 
            self.skillid = 101
            self.oldbtn = nil 
            self.view:GetChild("n2").onClick:Call()
        else
            self:setData()
        end  
        --计算
        self:setRedPoint()
    end 
end

function PanelKeJi:setRedPoint()
    -- body
    local number = self:checkRedpoint()
    print("number",number)
    mgr.GuiMgr:redpointByVar(attConst.A30141,number,2)
end

function PanelKeJi:checkRedpoint()
    -- body
    --获取职位
    local job = cache.PlayerCache:getGangJob()
    --print("job",job)
    local number = 0
    local confdata = conf.BangPaiConf:getAllkeji()
    if job and job > 2 then
        --检测是有 科技升级上限红点--界面左边
        for k ,v in pairs(confdata) do
            if v.list then
                for i , j in pairs(v.list) do

                    if self:checkOneGangTech(j) > 0 then
                        return 1
                    end
                end
            end
        end
    end
    for k ,v in pairs(confdata) do
        if v.list then
            for i , j in pairs(v.list) do
                --print(j,self:checkOneSkillup(j))
                if self:checkOneSkillup(j)>0 then
                    return 1
                end
            end
        end
    end
    return 0
end

function PanelKeJi:checkOneGangTech(id )
    -- body
    local job = cache.PlayerCache:getGangJob()
    if job and job > 2 then
        --是否顶级
        local level = self.data.gangTechLevs[id] or 0 --默认初始等级
        local _nextid = string.format("%d%02d",id,level+1)
        local nextconf = conf.BangPaiConf:getBangKejiselfinfo(_nextid)
        if not nextconf then
            return 0
        end
        local _lid = string.format("%d%02d",id,level)
        local confdata = conf.BangPaiConf:getBangKejiselfinfo(_lid)
        --print(_lidconfdata) 
        --物品条件
        if self.data.zj < confdata.cost_zj then
            return 0
        end

        return 1 
    end
    return 0
end

function PanelKeJi:checkOneSkillup(id)
    -- body
    if not self.data then
        return 0
    end
    local _s_level = self.data.mineTechLevs[id] or 0
    local level = self.data.gangTechLevs[id] or 0 --默认初始等级
    local _s_id = string.format("%d%02d",id,level)
    local _nextid = string.format("%d%03d",id,_s_level+1)
    local nextconf = conf.BangPaiConf:getBangTechStudy(_nextid)
    if not nextconf then
        return 0
    end
    local condata = conf.BangPaiConf:getBangKejiselfinfo(_s_id)
    --print("condata",condata,_s_id)
    if condata.max_study_lev <= _s_level then

        return 0
    end
    local _curid = string.format("%d%03d",id,_s_level)
    local condata = conf.BangPaiConf:getBangTechStudy(_curid)
    --物品条件
    if cache.PlayerCache:getTypeMoney(MoneyType.ylxw) < condata.cost_xw then
        return 0
    end

    return 1
end
return PanelKeJi