local M = class("AdvancedSmartPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "back_btn" then
    	self:updateMsg(99999)
    elseif msg == "yes_btn" then
        if self.m_model:searchMaterialIsLock() then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("coach_str_0015"), delay_close = 2})
        else
        	local param = self.m_model:getSelectData()
            if next(param) ~= nil then
                self:updateMsg("advanced_smart", {param = param}, "Advanced")
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0015"), delay_close = 2})    
            end
        end
    	self:updateMsg(99999)
    elseif msg == "select" then
    	self.m_model:changeSelect(data)
    	self.m_view:refreshUI()
    end
end

return M;
