local M = class("FateStoryChallengePopView",LikeOO.OOPopBase)

M.m_uiName = "Hotel/FateStoryChallengePop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:setTextByLanKey("challenge_btn_text", "fate_text_011")
    self:setTextByLanKey("enemy_count", "awake_system_text_0020")
    self:setTextByLanKey("reward_count", "awake_system_text_0021")
    local stage = self.m_model.m_stage
    self:setTextByLanKey("common_title_text", stage.name)
    self:setTextByLanKey("content_text", stage.des)
    --敌方信息
    local enemy_node = self:findGameObject("enemy_node")
    UIUtil.destroyAllChild(enemy_node.transform)
    local battle_cfg = ConfigManager:getCfgStageBattle(stage.stage)
    local enemy_cfg = battle_cfg.monster
    if enemy_cfg then
        for i = 1, #enemy_cfg do
            local data = enemy_cfg[i]
            if next(data) ~= nil and data.id ~= 0 then
                local hero_tab = {101, data.id, 0}
                local item = CommonUIUtil:createHeroElement(hero_tab,false,nil)
                CommonUIUtil:updateHeroLvByData(item, data)
                item.transform:SetParent(enemy_node.transform, false)
            end
        end
    end
    --掉落
    local reward_node = self:findGameObject("reward_node")
    UIUtil.destroyAllChild(reward_node.transform)
    local reward_cfg = stage.drop
    if reward_cfg then
        for i = 1, #reward_cfg do
            local data = reward_cfg[i]
            local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
            local item = GameUtil:createItemElement(data, showNum, true)
            UIUtil.setScale(item.transform, 0.9)
            item.transform:SetParent(reward_node.transform, false)
        end
    end
    --state
    local gray_img = self:findImage("gray_image")
    local button = self:findButton("challenge_btn")
    local button_img = self:findImage("challenge_btn")
    if self.m_model.m_state == 0 then --不可打
        self:setObjectVisible("challenge_btn", true)
        button.interactable = false
        button_img.material = gray_img.material
    elseif self.m_model.m_state == 1 then --可打
        self:setObjectVisible("lock_img", false)
        self:setObjectVisible("challenge_btn", true)
        button.interactable = true
        button_img.material = nil
    elseif self.m_model.m_state == 2 then --通关
        self:setObjectVisible("challenge_btn", false)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M