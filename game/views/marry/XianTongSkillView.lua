--
-- Author: 
-- Date: 2018-08-06 16:29:02
--

local XianTongSkillView = class("XianTongSkillView", base.BaseView)

function XianTongSkillView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function XianTongSkillView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.list1 = self.view:GetChild("n5")
    self.list1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list1.numItems = 0
    self.list1.onClickItem:Add(self.onlist1CallBack,self)

    self.list2 = self.view:GetChild("n6")
    self.list2.itemRenderer = function(index,obj)
        self:cellPackdata(index, obj)
    end
    self.list2.numItems = 0
    self.list2.onClickItem:Add(self.onlist2CallBack,self)

    local dec1 = self.view:GetChild("n15")
    dec1.text = language.xiantong20
    local dec1 = self.view:GetChild("n18")
    dec1.text = language.xiantong21

    local btn = self.view:GetChild("n8")
    btn.onClick:Add(self.onSkill,self)

    local btnGuize = self.view:GetChild("n9")
    btnGuize.onClick:Add(self.onGuize,self)

    local goXunBao = self.view:GetChild("n10") 
    goXunBao.text = mgr.TextMgr:getTextColorStr(language.xiantong22 ,7,"") --EVE --ruleDesc[2][1][3]
    goXunBao.onClickLink:Add(self.onClickGOXunBao,self)
end

function XianTongSkillView:initData(data)
    -- body
    self.data = data

    self:setData()
    
end

function XianTongSkillView:setData(data_)
    self.packdata = nil 


    self.list1.numItems = 6


    self.skilllist = mgr.XianTongMgr:getPackSkillItem(self.data.xtId)
    --print("self.skilllist",#self.skilllist)
    self.list2.numItems = math.max((math.ceil(#self.skilllist/21)*21),21) --#self.
    self.list2:SelectNone()
end


function XianTongSkillView:celldata( index, obj )
    -- body
    --local data = self.keys[index+1]
    --local id = self.keys[index+1]
    local data = self.data.skillInfo[index+1]
    local icon = obj:GetChild("n0"):GetChild("n2")
    local jiaobiao = obj:GetChild("n0"):GetChild("n4")
    jiaobiao.visible = false
    obj.data = index
    
    if data then
        --print("data",data)
        local condata = conf.MarryConf:getPetSkillById(data)
        if condata and condata.icon then
            icon.url = ResPath.iconRes(condata.icon)
            if condata.jiaobiao then
                jiaobiao.visible = true
                jiaobiao.url = ResPath.iconOther(condata.jiaobiao)
            end
        else
            print("缺少icon配置,xt_skill_lev",data)
            icon.url = nil 
        end
    else
        icon.url = nil 
    end
end

function XianTongSkillView:onlist1CallBack( context )
    -- body
    local item = context.data
    local data = self.data.skillInfo[item.data+1] 
    
    if data then
        local condata = clone(conf.MarryConf:getPetSkillById(data))
        local view = mgr.ViewMgr:get(ViewName.XiantongSkillMsgTips)
        if view then
            view:initData(condata)
        else
            mgr.ViewMgr:openView2(ViewName.XiantongSkillMsgTips,condata)
        end
    end
    --self.selectIndex = data+1
    --local info = self.data.skillDatas[self.selectIndex]
    --mgr.PetMgr:seeSkillInfo(info)
end
function XianTongSkillView:cellPackdata( index, obj )
    -- body
    local data = self.skilllist[index+1]
    local itemobj = obj:GetChild("n0")
    if data then
        local packdata = cache.PackCache:getPackDataById(data.mid)
        local t = clone(packdata)
        t.shownumber = false
        obj.data = t
        GSetItemData(itemobj,t)
    else
        obj.data = data 
        GSetItemData(itemobj,{})
    end
end
function XianTongSkillView:onlist2CallBack( context )
    -- body
    local item =  context.data
    local data = item.data
    if data then
        self.packdata = data 
        local info = clone(data)
        info.index = 0
        GSeeLocalItem(info)
    else
        item.selected = false
    end
end
function XianTongSkillView:onGuize()
    -- body
    mgr.ViewMgr:openView2(ViewName.PetSkillSee,{flag = "xt"})
end

function XianTongSkillView:onSkill()
    -- body
    if not self.packdata then
        GComAlter(language.pet22)
        return
    end
    if self.packdata.amount <= 0 then
        GComAlter(language.gonggong11)
        return
    end

    --检测是否有相同的技能
    local id = conf.ItemConf:getItemExt(self.packdata.mid)
    local ptype =tonumber(string.sub(tostring(id),2,4)) 
    for k ,v in pairs(self.data.skillInfo) do
        if v == id then
            GComAlter(language.xiantong31)
            return
        end

        local _type =tonumber(string.sub(tostring(v),2,4)) 
        --local _lv = tonumber(string.sub(tostring(v),5))
        if ptype == _type then
            if id < v then
                --已经学习了类类型高级技能
                local param = {}
                param.richtext = language.xiantong25
                param.type = 2
                param.sure = function( ... )
                    -- body
                    local t = {}
                    t.xtRoleId = self.data.xtRoleId
                    t.mid = self.packdata.mid
                    --printt(t)
                    proxy.MarryProxy:sendMsg(1390605,t)
                end
                GComAlter(param)
                return
            end
        end
    end


    local param = {}
    param.xtRoleId = self.data.xtRoleId
    param.mid = self.packdata.mid
    proxy.MarryProxy:sendMsg(1390605,param)
end

function XianTongSkillView:onClickGOXunBao()
    -- body
    GOpenView({id = 1309})
end

function XianTongSkillView:addMsgCallBack(data)
    -- body
    self.data.skillInfo = data.skillInfo
    self:setData()
end

return XianTongSkillView