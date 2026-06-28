local M = class("ArenaNormalRankControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "item_click" then
    	local item_data = data.cell_data
    	self:openView("Pops.PlayerInfo", {uid = item_data.user.uid, look_model = 1})
    end
end

return M
