--
-- Author: 
-- Date: 2018-12-14 18:35:44
--

local BiaoQingView = class("BiaoQingView", base.BaseView)

function BiaoQingView:ctor()
    self.super.ctor(self)
     self.isBlack = true 
    self.uiLevel = UILevel.level3 
end

function BiaoQingView:initView()
       self.liaoTianList = self.view:GetChild("n51")
    self.liaoTianList.itemRenderer = function(index,obj)
        self:cellPhizData(index, obj)
    end
    self.liaoTianList.numItems = ChatType.phizNum
    self.liaoTianList.onClickItem:Add(self.onPhizClickCall,self)
    self.context = ""
    self.blackView.onClick:Add(self.onCloseView,self)
end

function BiaoQingView:initData(data_)

end


function BiaoQingView:cellPhizData(index,cell)
    local phizId = index + 1
    if phizId < 10 then
        cell.data = "0"..phizId
    else
        cell.data = phizId
    end
    local imgObj = cell:GetChild("n0")
    imgObj.url = ResPath.phizRes(cell.data)
end

function BiaoQingView:onPhizClickCall(context)
    local cell = context.data
    local index = cell.data
    local len = string.utf8len(self.context)
    if len >= language.chatNum then--输入限制
        GComAlter(string.format(language.chatSend6, language.chatNum))
        return
    end
    local view= mgr.ViewMgr:get(ViewName.JiYJiaoYanView)
    if view and view.Inputtext then
        if index then
            view.Inputtext.text = view.Inputtext.text.."#"..index
        else
            view.Inputtext.text = mgr.TextMgr:getPhiz(index)
        end
    end
end

function BiaoQingView:onCloseView()
    self:closeView()
end

return BiaoQingView