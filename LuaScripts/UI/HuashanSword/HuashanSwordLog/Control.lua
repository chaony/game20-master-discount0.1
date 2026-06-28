local M = class("HuashanSwordLogControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cell_item_node" then
        local item_data = data.cell_data
        local status = item_data.status or 0
        local rank = status == 0 and item_data.defender_rank or item_data.rank
    	self:openView("Pops.PlayerInfo", {uid = item_data.user_info.uid, look_model = 2, rank = rank})
    elseif msg == "statistics_btn" then
        local item_data = data.cell_data
        self:openView("HuashanSword.HuashanSwordBattleDetail", {battle_id = item_data.battle_id, log_data = item_data})
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
