--
-- Author: Your Name
-- Date: 2018-07-24 19:31:14
--

local StarAttrView = class("StarAttrView", base.BaseView)

function StarAttrView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function StarAttrView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.presentAttrList = self.view:GetChild("n13")
    self.presentAttrList.numItems = 0

    self.nextAttrList = self.view:GetChild("n12")
    self.nextAttrList.numItems = 0
    self.presentTxt = self.view:GetChild("n4")
    self.nextTxt = self.view:GetChild("n10")
    self.nowStars = self.view:GetChild("n6")
    self.c1 = self.view:GetController("c1")
end

-- {level=0,mid=112066006,propMap={89740,319,948,1532267054,421,9274,3422},
-- updateNum=0,amount=1,index=300006,bind=0,exp=0,
-- colorAttris={1={type=5025,value=319},2={type=5056,value=948},3={type=5036,value=421}}},
function StarAttrView:initData()
    local equipData = cache.PackCache:getEquipData()
    local starsNum = 0
    for k,v in pairs(equipData) do
        local stars = mgr.ItemMgr:getColorBNum(v)
        local color = conf.ItemConf:getQuality(v.mid)
        if color >= 5 then
            starsNum = starsNum + stars
        end
    end
    -- print("当前装备星级数>>>>>>",starsNum)
    self.presentData,self.nextData = conf.ForgingConf:getEquipStarAttr(starsNum)
    self.c1.selectedIndex = 1
    local textData2 = clone(language.equip11)
    textData2[2].text = string.format(textData2[2].text,starsNum)
    self.nowStars.text = mgr.TextMgr:getTextByTable(textData2)
    if self.presentData then
        local presentData = GConfDataSort(self.presentData)
        self.presentAttrList.itemRenderer = function (index,obj)
            local data = presentData[index+1]
            if data then
                local txt1 = obj:GetChild("n1")
                local txt2 = obj:GetChild("n2")
                txt1.text = conf.RedPointConf:getProName(data[1])
                txt2.text = GProPrecnt(data[1],math.floor(data[2]))
            end
        end
        self.presentAttrList.numItems = #presentData
        local textData = clone(language.equip09)
        textData[2].text = string.format(textData[2].text,self.presentData.star)
        self.presentTxt.text = mgr.TextMgr:getTextByTable(textData)
    else
        self.c1.selectedIndex = 0
        local textData = clone(language.equip09)
        textData[2].text = string.format(textData[2].text,self.nextData.star)
        self.presentTxt.text = mgr.TextMgr:getTextByTable(textData)
    end
    --下一阶段属性
    if self.nextData then
        local nextData = GConfDataSort(self.nextData)
        self.nextAttrList.itemRenderer = function (index,obj)
            local data = nextData[index+1]
            if data then
                local txt1 = obj:GetChild("n1")
                local txt2 = obj:GetChild("n2")
                txt1.text = conf.RedPointConf:getProName(data[1])
                txt2.text = GProPrecnt(data[1],math.floor(data[2]))
            end
        end
        self.nextAttrList.numItems = #nextData
        local textData = clone(language.equip10)
        textData[2].text = string.format(textData[2].text,self.nextData.star)
        self.nextTxt.text = mgr.TextMgr:getTextByTable(textData)
        
    else
        self.c1.selectedIndex = 2
    end
end

return StarAttrView