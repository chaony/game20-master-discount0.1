local M = class("QuickHangUpPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/QuickHangUpPop"
M.m_size_type = 2

local TAB_SHOW_GET = {
	{RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0},
	{RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0},
	{RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0}
}

function M:onEnter()	
	self.m_gray_image = self:findImage("gray_img")
	self.reward_node = self:findGameObject("reward_node")
	self:refreshUI()
	self:setTextByLanKey("common_title_text","qh_str_0001")
	self:setTextByLanKey("msg_text","qh_str_0002")
	self:setTextByLanKey("msg2_text","qh_str_0003")
	self:setTextByLanKey("quick_idle_text","qh_str_0004")
end

function M:refreshUI()
	self:setText("quick_idle_times",self.m_model.m_quick_idle_times)
	local red_flag = RedPointUtil:isFuncRedPointById(8)
	self:setObjectVisible("red_point_img", red_flag == true)
	UIUtil.destroyAllChild(self.reward_node.transform)
	for k,v in pairs(TAB_SHOW_GET) do
		self:creatItem(v)
	end
	local cfg = self.m_model:getCost()
	if cfg and cfg[3] == 0 then
		local ok_text = self:setTextByLanKey("ok_text", "qh_str_0010")
		UIUtil.setLocalPosition(ok_text.transform, 0)
		self:setObjectVisible("money_img", false)
	else	
		local ok_text = self:setTextByLanKey("ok_text", "qh_str_0011",cfg[3])
		UIUtil.setLocalPosition(ok_text.transform, 20)
		self:setObjectVisible("money_img", true)
	end
	local ok_btn = self:findImage("ok_btn")
	if self.m_model.m_quick_idle_times > 0 then
		ok_btn.material = nil
	else
		ok_btn.material = self.m_gray_image.material
	end
end


function M:creatItem(data)
	data[3] = self.m_model:getNumByType(data[1])
	local itemData = RewardUtil:getProcessRewardData(data)
	local itemNode = GameUtil:createItemElementByData(itemData, true)
	-- UIUtil.setLocalScale(itemNode.transform,0.65,0.65,0.65)
	itemNode.transform:SetParent(self.reward_node.transform, false)
end

function M:setDountDown(count_down)
	local tim = GameUtil:formatTimeBySecond(count_down)
	self:setText("downtime_text",tim)
end

return M