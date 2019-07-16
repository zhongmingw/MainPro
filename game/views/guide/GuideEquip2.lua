--
-- Author: 
-- Date: 2017-09-04 21:50:34
--

local GuideEquip2 = class("GuideEquip2", base.BaseView)

function GuideEquip2:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level4
end

function GuideEquip2:initView()
    self.effpanel = self.view:GetChild("n0")
    self.iconlist = {}
    for i = 4 , 8 do
        local icon = self.view:GetChild("n"..i)
        icon.url = nil 
        table.insert(self.iconlist,icon)
    end

    self.labCout = self.view:GetChild("n9")
    self.imgchehao = self.view:GetChild("n10")

    self.t0 = self.view:GetTransition("t0")
    self.t1 = self.view:GetTransition("t1")
    self.t2 = self.view:GetTransition("t2")
    self.t3 = self.view:GetTransition("t3")
    self.t4 = self.view:GetTransition("t4")
end

function GuideEquip2:initData(data)
    -- body
    self.data = data
     --设置icon
    for k ,v in pairs(self.iconlist) do
        v.url = nil 
    end
    self.labCout.text = ""
    self.imgchehao.visible = false
    local effect,delay = self:addEffect(4020138,self.effpanel)
    effect.LocalPosition = Vector3.New(158.4,-366.4,100)
    --
    local delay1 = 1.2 --卷轴开始 0.6 秒后执行其他东西的出现
    self:addTimer(delay1, 1, function( ... )
        -- body
        self:setData()
    end)
    
end

function GuideEquip2:setData(data_)
    local _t = {}
    local number = 1
    for k ,v in pairs(self.data.data) do
        number = number + 1
        local _part = conf.ItemConf:getPart(v.mid) 
        if _part == 1 then
            _part = 2
        elseif _part == 2 then
            _part = 1
        end
        table.insert(_t,{part = _part , src = conf.ItemConf:getSrc(v.mid)})
    end
    --table.insert(_t,{part = _part , src = conf.ItemConf:getSrc(self.data.mId)})

    table.sort(_t,function( a,b )
        -- body
        return a.part < b.part
    end)

    local param = {}
    param[1] = {}
    param[1].text = number

    if number < 10 then
        param[1].color = 14
    else
        param[1].color = 7
    end
    param[2] = {text = "/10",color = 7}

    self.labCout.text = mgr.TextMgr:getTextByTable(param)
    self.imgchehao.visible = true

    local index
    if number - 1 >= 5 then
        index = 6
    else
        index = 1
    end

    for i = index , number - 1 do
        local _data = _t[i]
        local toIndex = i % 5
        if toIndex == 0 then toIndex = 5 end 
        local icon = self.iconlist[toIndex]
        icon.url = ResPath.iconRes(_data.src)
    end
    --设置当前icon
    local delay2 = 0.4 --信息设置 0.4秒后 执行当前装备的动效
    self:addTimer(delay2, 1, function( ... )
        -- body
        local _cur = number%5
        if _cur == 0 then _cur = 5 end
        local src = conf.ItemConf:getSrc(self.data.mId)
        self.iconlist[_cur].url = ResPath.iconRes(src)
        self["t"..(_cur-1)]:Play()
    end)

    --界面3秒关闭
    self:addTimer(5, 1,function( ... )
        -- body
        --plog(...)
        local id = self.data.nextguideid
        for k ,v in pairs(self.iconlist) do
            v.url = nil 
        end
        self.labCout.text = ""
        self.imgchehao.visible = false

        local effect,delay = self:addEffect(4020142,self.effpanel)
        effect.LocalPosition = Vector3.New(158.4,-366.4,100)

        self:addTimer(delay, 1, function( ... )
            -- body
            self:closeView()
            if id and id == 3010 then
            --打开称号获得界面
                cache.PlayerCache:addSkinsList({[Skins.title] = 1001011})
                mgr.ViewMgr:openView(ViewName.SkinTipsView,function( view )
                    -- body
                    local param = {
                        guideid = 3010,
                        guide = {"n3"}
                    }
                    view:startGuide(param)

                end, {})
            end

        end)
    end)
end

return GuideEquip2