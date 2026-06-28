local M = class("HeroEvnntlyPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/HeroEvnntlyPop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("hero_name_text",self.m_model.herocfg.name)
	self:setTextByLanKey("common_title_text", "<size=46>逸</size>文")
	self:setObjectVisible("cover_img",true)
	self:setObjectVisible("count_obj",false)
	self:setObjectVisible("can_get_reward_obj", self.m_model:checkRedPoint())
	self:refreshUI()
end

function M:refreshUI()
	local reward_node = self:findGameObject("reward_item_parent")
	local itemNode = ResourceUtil:LoadUIGameObject("Common/ItemNode", Vector3.zero, reward_node.transform)
	UIUtil.setLocalScale(itemNode.transform, 0.8, 0.8, 0.8)
	itemNode.transform:SetParent(reward_node.transform, false)
	local itemData = RewardUtil:getProcessRewardData(self.m_model:checkReward())
	GameUtil:updateItemElementByData(itemNode, itemData, true, false)
end

function M:hideReward()
	self:setObjectVisible("can_get_reward_obj", false)
end

function M:opneCount()
	self:setObjectVisible("cover_img",false)
	self:setObjectVisible("count_obj",true)
end

function M:closeCount()
	self:setObjectVisible("cover_img",true)
	self:setObjectVisible("count_obj",false)
end

return M