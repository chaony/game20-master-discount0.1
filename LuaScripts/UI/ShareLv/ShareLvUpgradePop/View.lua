local M = class("ShareLvUpgradePopView",LikeOO.OOPopBase)

M.m_uiName = "ShareLv/ShareLvUpgradePop"
M.m_size_type = 2

function M:onEnter()	
	self:setText("yes_btn", Language:getTextByKey("new_str_0006"))
    self:setText("cancle_btn", Language:getTextByKey("new_str_0007"))
	self:setText("common_title_text", Language:getTextByKey("shareLv_str_0013"))

    self:setText("lv_text", Language:getTextByKey("shareLv_str_0014"))
    self:setText("power_text", Language:getTextByKey("shareLv_str_0015"))
    self:setText("cost_text", Language:getTextByKey("shareLv_str_0016"))
	self:refreshUI()
end

function M:refreshUI()
	local crystal_upgrade = ConfigManager:getCfgByName("crystal_upgrade")
	local cfg = crystal_upgrade[self.m_model.m_data.clv]
	local user_data = UserDataManager.user_data
	local coin = user_data:getUserStatusDataByKey("coin")
	local coin_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 1})
	self:setImg(coin_img.icon_name, coin_img.atlas_name or "item_icon", "coin_img")
	if coin < cfg.coin then
		self:setText("coin_text", "<color=#AE5441>" .. GameUtil:formatValueToString(coin) .. "</color>/" .. GameUtil:formatValueToString(cfg.coin))
	else
		self:setText("coin_text", GameUtil:formatValueToString(coin) .. "/" .. GameUtil:formatValueToString(cfg.coin))
	end
	
	local hero_exp = user_data:getUserStatusDataByKey("hero_exp")
	local exp_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 1})
	self:setImg(exp_img.icon_name, exp_img.atlas_name or "item_icon", "hero_exp_img")
	if hero_exp < cfg.exp then
		self:setText("hero_exp_text", "<color=#AE5441>" .. GameUtil:formatValueToString(hero_exp) .. "</color>/" .. GameUtil:formatValueToString(cfg.exp))
	else
		self:setText("hero_exp_text", GameUtil:formatValueToString(hero_exp) .. "/" .. GameUtil:formatValueToString(cfg.exp))
	end
	
	local dust = user_data:getUserStatusDataByKey("dust")
	local dust_img = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 1})
	self:setImg(dust_img.icon_name, dust_img.atlas_name or "item_icon", "dust_img")
	if dust < cfg.special_num then
		self:setText("dust_text", "<color=#AE5441>" .. GameUtil:formatValueToString(dust) .. "</color>/" .. GameUtil:formatValueToString(cfg.special_num))
	else
		self:setText("dust_text", GameUtil:formatValueToString(dust) .. "/" .. GameUtil:formatValueToString(cfg.special_num))
	end
	
	self:setText("lv_value_text", string.format(Language:getTextByKey("new_str_0075"), cfg.display_level))
	self:setText("lv_next_text", string.format(Language:getTextByKey("new_str_0075"), cfg.display_level + 1))
	local now_combat = self.m_model:getCombat()
	self:setText("power_value_text", GameUtil:formatValueToString(now_combat))
	local next_combat = self.m_model:computeCombat()
	self:setText("power_next_text", GameUtil:formatValueToString(next_combat))
end

return M