local M = class("WorldBossMopUpView",LikeOO.OOPopBase)

M.m_uiName = "Activities/WorldBoss/WorldBossMopUp"
M.m_size_type = 2 -- 1隐藏下层ui，2不隐藏

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0573")
	self:setTextByLanKey("tips_text","new_str_0570")
	self:setTextByLanKey("title_max_damage_text","new_str_0571")
	self:setTextByLanKey("title_reward_text","new_str_0572")
	self:setTextByLanKey("cancle_text","new_str_0007")
	self:setTextByLanKey("ok_text","new_str_0573")
	self:refreshUI()
end

function M:refreshUI()
	local box_num = self.m_model:getRewardBoxNum()
	self:setTextByLanKey("treasure_box_text", tostring(box_num))
	self:setTextByLanKey("max_damage_text", tostring(self.m_model.m_data.last_damage or 0))
end

return M