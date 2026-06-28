local M = class("MysticUpgradePopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "cancel_btn" then
    	self:closeView()
    elseif msg == "yes_btn" then
    	local param = self.m_model:getEvolutionData()
        self:updateMsg("evolution", {params = param}, "Mystic")
        self:closeView()
    end
end

return M;
