---
---

local M = class("AwakeSystemChallengePopView",LikeOO.OOPopBase)

M.m_uiName = "AwakeSystem/AwakeSystemChallengePop"  -- prefab name
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("change_text", "awake_system_text_0019")
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    local awake_state_cfg = ConfigManager:getCfgByName("awaken_stage")
    local cur_awake_state_cfg = awake_state_cfg[self.m_model.m_hero_id]
    --local state_battle_cfg = ConfigManager:getCfgByName("stage_battle")
    if cur_awake_state_cfg then
        local cur_stage = cur_awake_state_cfg[self.m_model.m_stage_id]
        if cur_stage and next(cur_stage) then
            self.m_model.m_stage = cur_stage.stage
            self.m_model.m_stage_cfg = cur_stage
            local cur_stage_cfg = ConfigManager:getCfgStageBattle(self.m_model.m_stage)--state_battle_cfg[self.m_model.m_stage]
            if cur_stage_cfg then
                local reward_cfg = cur_stage.drop
                local enemy_cfg = cur_stage_cfg.monster
                local name = cur_stage.name or ""
                local desc = cur_stage.des or ""
                self:setTextByLanKey("cur_floor_text", name)
                self:setTextByLanKey("common_title_text", name)
                self:setTextByLanKey("cur_floor_count", desc)
                self:setTextByLanKey("enemy_count", "awake_system_text_0020")
                self:setTextByLanKey("reward_count", "awake_system_text_0021")
                local enemy_node = self:findGameObject("enemy_node")
                local reward_node = self:findGameObject("reward_node")
                UIUtil.destroyAllChild(enemy_node.transform)
                UIUtil.destroyAllChild(reward_node.transform)
                for i = 1, table.nums(reward_cfg) do
                    local data = reward_cfg[i]
                    local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
                    local item = GameUtil:createItemElement(data, showNum, true)
                    UIUtil.setScale(item.transform, 0.9)
                    item.transform:SetParent(reward_node.transform, false)
                end
                for i = 1, table.nums(enemy_cfg) do
                    local data = enemy_cfg[i]
                    if next(data) ~= nil and data.id ~= 0 then
                        local hero_tab = {101, data.id, 0}
                        local item = CommonUIUtil:createHeroElement(hero_tab,false,nil)
                        CommonUIUtil:updateHeroLvByData(item, data)
                        item.transform:SetParent(enemy_node.transform, false)
                    end
                end
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
