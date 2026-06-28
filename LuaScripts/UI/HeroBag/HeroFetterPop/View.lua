local M = class("HeroFetterPopView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroFetterPop"
M.m_size_type = 2

function M:onEnter()
    self.reward_grid = self:findGameObject("reward_node")
    self:refreshUI()
    audio:SendEvtUI('UI_JBan')
end

function M:refreshUI()
    self:setTextByLanKey("jh_name_text", "hero_ui_str_0014", self.m_model:getFetterName())
    self:setTextByLanKey("pro_count", self.m_model:getFeeterProByLv())
    local rewards = RewardUtil:mergeRewardAndFormat(self.m_model.cur_feeter.reward)
    local num = #rewards
	for i = 1, num do
		local data = rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
	end
end


return M