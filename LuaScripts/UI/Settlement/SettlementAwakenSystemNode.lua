--- 竞技场结算 成功
local M = class("SettlementAwakenSystemNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementAwakenSystemNode"

function M:onEnter()
    self:showReward()
end

--[[
    奖励列表
]]
function M:showReward()
    self:setTextByLanKey("reward_title_text", "hunt_treasure_str_036")
    local reward_grid = self:findGameObject("reward_grid")
    local reward = self.m_model.m_rewards or {}
    local num = #reward
    for i = 1, num do
        local data = reward[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        item.transform:SetParent(reward_grid.transform, false)
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS then
            local itemLuabehaviour = UIUtil.findLuaBehaviour(item)
            local show_flag = false
            if GameUtil:checkDoubleActiveByType(6) == true then
                show_flag = true
            end
            LuaBehaviourUtil.setObjectVisible(itemLuabehaviour, "double_earn", show_flag)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M