--- 公会战结算 成功
local M = class("SettlementUnionWarNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementUnionWarNode"

function M:onEnter()
    self.m_gray_image = self:findImage("gray_image")
    self:setTextByLanKey("btn_return_text", "new_str_0478")
    self:setTextByLanKey("btn_retain_text", "union_str_0063")
    self:setTextByLanKey("next_text", "new_str_0243")
    self:setTextByLanKey("commentary_1", "UnionWar_str_077")
    self:setTextByLanKey("commentary_2", "UnionWar_str_078")
    self:refreshUI()
end

function M:refreshUI()
    local result = self.m_model.m_data.result or 0
    self:setImg(result == 1 and "a_bh_shengli" or "a_bh_shibai", ResourceUtil:getLanAtlas(), "win_img")
    self:setObjectVisible("star_bg",result == 1)
    local shengli_di = self:findImage("shengli_di")
    GameUtil:updateResourcesImg(shengli_di, "Texture/arena/" .. (result == 1 and "a_bh_shenglibiaoti_di" or "a_bh_shibaibiaoti_di"))
    local star = self.m_model.m_data.star or 0
    for i = 1, 3 do
        local star_img = self:findImage('star_' .. i)
        if i > star then
            star_img.material = self.m_gray_image.material
            star_img.gameObject:SetActive(false)
        else
            star_img.material = nil
            star_img.gameObject:SetActive(true)
        end
    end
    if result == 1 and star > 0 then
        audio:SendEvtUI("UI_Success_Star0" .. star)
    end
    self:setTextByLanKey("remain_mock_times_text", "UnionWar_str_090", self.m_model.m_data.remain_mock_times or 0)
    local mock_battle = self.m_model.m_data.mock_battle == 1 -- 模拟战
    if not mock_battle then
        self:showReward()
    end
    self:setObjectVisible("simulation_battle_node", mock_battle and result == 1)
    self:setObjectVisible("battle_node", not mock_battle)
    self:setObjectVisible("img_btn_mask", mock_battle)
    local mask_btn =  self:findButton("img_btn_mask")
    mask_btn.interactable = result == 0
end

--[[
    奖励列表
]]
function M:showReward()
    local reward_grid = self:findGameObject("reward_grid")
    local reward = self.m_model.m_rewards or {}
    local num = #reward
    for i = 1, num do
        local data = reward[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        item.transform:SetParent(reward_grid.transform, false)
    end
end

return M