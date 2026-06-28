local M = class("SimulateTokenLevelUpPopView", LikeOO.OOPopBase)

M.m_uiName = "SimulateLift/SimulateTokenLevelUpPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
	self:setSpine()
end

function M:refreshUI()
	local sum_lv = self.m_model.m_buy_lv +  self.m_model.m_lv
	self:setTextByLanKey("title_text", "gf_str_0057", sum_lv)
	self:setTextByLanKey("title_text2", "gf_str_0058", self.m_model.m_buy_lv, sum_lv)
	self:setTextByLanKey("lv_num_text", self.m_model.m_buy_lv)
	if self.m_model:getNeedMoney() then
		local money_data = self.m_model:getNeedMoney()
		self:setImg(money_data.icon_name, money_data.atlas_name, "money_icon")
		local show_buy_str = money_data.data_num..Language:getTextByKey("new_str_0037")
		self:setTextByLanKey("buy_text", show_buy_str)
	end
	local reward_1 = self:findGameObject("reward_1")
	local reward_2 = self:findGameObject("reward_2")
	UIUtil.destroyAllChild(reward_1.transform)
	UIUtil.destroyAllChild(reward_2.transform)
	local rewards_free = self.m_model:getCanHaveReward2()
	local rewards_fee = self.m_model:getCanHaveReward()
	for i,v in pairs(rewards_free) do
		local itemNode = GameUtil:createItemElement(v, true, true)
		itemNode.transform:SetParent(reward_1.transform, false)
	end
	for i,v in pairs(rewards_fee) do
		local itemNode = GameUtil:createItemElement(v, true, true)
		itemNode.transform:SetParent(reward_2.transform, false)
	end
end

function M:setSpine()
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(213)
	if cfg then
		local icon = cfg.hero_spine
		if self.cacheSpineName == icon then
			return
		else
			self.cacheSpineName = icon
		end
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	end
end

return M