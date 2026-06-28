local M = class("MysticSmartPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "cancel_btn" then
    	self:updateMsg(99999)
    elseif msg == "yes_btn" then
    	local param = self.m_model:getSelectData()
    	self:updateMsg("evolution", {params = param}, "Mystic")

    	self:updateMsg(99999)
    elseif msg == "select" then
    	self.m_model:changeSelect(data)
    	self.m_view:refreshUI()
    end
end

return M;
