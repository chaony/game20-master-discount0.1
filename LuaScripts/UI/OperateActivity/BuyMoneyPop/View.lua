local M = class("BuyMoneyPopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/BuyMoneyPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "gf_str_0055")
	self:setTextByLanKey("title_text2", "gf_str_0056")
	self:refreshUI()
	self:setSpine()
end

function M:refreshUI()
	local reward_1 = self:findGameObject("reward_1")
	local reward_2 = self:findGameObject("reward_2")
	UIUtil.destroyAllChild(reward_1.transform)
	UIUtil.destroyAllChild(reward_2.transform)
	local rewards_all = self.m_model:getAllReward()
	local rewards_have = self.m_model:getCanHaveReward()
	for i,v in pairs(rewards_all) do
		local itemNode = GameUtil:createItemElement(v, true, true)
		itemNode.transform:SetParent(reward_1.transform, false)
	end
	for i,v in pairs(rewards_have) do
		local itemNode = GameUtil:createItemElement(v, true, true)
		itemNode.transform:SetParent(reward_2.transform, false)
	end
	local war_cfg = self.m_model:getWarCfg()
	local show_price = GameUtil:getMoneyTypeNum(war_cfg.price).. Language:getTextByKey("new_str_0037")
	self:setTextByLanKey("buy_text", show_price)
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