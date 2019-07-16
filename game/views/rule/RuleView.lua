--
-- Author: 
-- Date: 2017-02-06 15:34:48
--

local RuleView = class("RuleView", base.BaseView)

function RuleView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function RuleView:initData(data)
    
end

function RuleView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.listViewNext = self.view:GetChild("n1")
    self.listViewNext.itemRenderer = function(index,obj)
        self:cellNextdata(index, obj)
    end
    self.listViewNext.numItems = 0    
    
end

function RuleView:cellNextdata( index,obj  )
    -- body
    --plog(index)
    local data=self.conf.desc[index+1]
    local str=""
    for i=1,#data do
        local dat=data[i]
        str=str.."[color="..dat[1].."][size="..dat[2].."]"..dat[3].."[/size][/color]"
    end
    
    local _lab = obj:GetChild("n0")
    _lab.text =  str
    obj.height = _lab.height + 2
end

function RuleView:setData(id)
    self.conf=conf.RuleConf:getRuleById(id)
    self.listViewNext.numItems = #self.conf.desc
end

function RuleView:onClickClose()
    -- body
    self:closeView()
end

return RuleView