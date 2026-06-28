local M = class("TowerStagePlayerControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "item_click" then
    	local player_data = self.m_model:getPlayerDataByIndex(data.index)
    	self:openView("Pops.PlayerInfo", {uid = player_data.uid})
    end
end

return M
