local M = class("ShareLvRemoveHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "ShareLv/ShareLvRemoveHeroPop"
M.m_size_type = 2

function M:onEnter()
	self:setText("common_title_text", Language:getTextByKey("shareLv_str_0003"))
	self:setText("cancle_text", Language:getTextByKey("new_str_0007"))
	self:setText("ok_text", Language:getTextByKey("new_str_0006"))
	self:setText("msg_text", Language:getTextByKey("shareLv_str_0004"))
	local hour = ConfigManager:getCommonValueById(392,1)
	self:setText("time_text_2", Language:getTextByKey("shareLv_str_0005", hour))
	self:setText("go_text", Language:getTextByKey("shareLv_str_0006"))
	self:setText("hy_text", Language:getTextByKey("shareLv_str_0006"))
	self:refreshUI()
end

function M:refreshUI()
	local data, cfg = UserDataManager.hero_data:getHeroDataById(self.m_model.m_hero)
	-- local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cfg.id, 1, data.oid})
	-- local icon1 = CommonUIUtil:createHeroElementByData(itemData, false, self:findGameObject("hero_1_panel").transform)
	local cell1 = self:findGameObject("cell1")
    GameUtil:updateHeroContentByData(cell1,data,cfg)
    local cell2 = self:findGameObject("cell2")
	GameUtil:updateHeroContentByData(cell2,data,cfg)
	--local icon2 = CommonUIUtil:createHeroElementByData(itemData, false, self:findGameObject("hero_2_panel").transform)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell2)
	local lv_text = luaBehaviour:FindText("lv_text")
	lv_text.text = Language:getTextByKey("new_str_0075", data.lv or 1)
    lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
end

return M