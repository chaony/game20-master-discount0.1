local M = class("UnionUpgradeView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionUpgradePop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("common_title_text", "union_str_0029")
	self:setTextByLanKey("cancel_text", "new_str_0007")
	self:setTextByLanKey("ok_text", "shareLv_str_0013")
	self:refreshUI()
end

function M:refreshUI()
	local data = self.m_model.m_data
	local guild = ConfigManager:getCfgByName("guild")
	local cur_cfg = guild[data.guild.level]
	local next_cfg = guild[data.guild.level + 1]
	if next_cfg then
		self:setTextByLanKey("cost_text", "union_str_0036", data.guild.exp, cur_cfg.exp)
		self:setTextByLanKey("union_lv_text", "union_str_0037", data.guild.level)
		self:setText("union_new_lv_text", data.guild.level + 1)
		self:setTextByLanKey("union_member_text", "union_str_0038", cur_cfg.number)
		self:setText("union_new_member_text", next_cfg.number)
		self:setTextByLanKey("union_artifact_text", "union_str_0039", cur_cfg.tripod_lv)
		self:setText("union_new_artifact_text", next_cfg.tripod_lv)
		local cur_emblem_num = self.m_model:getEmblemNumber(data.guild.level)
		local next_emblem_num = self.m_model:getEmblemNumber(data.guild.level+1)
		self:setTextByLanKey("union_emblem_text", "union_str_0040", cur_emblem_num)
		self:setText("union_new_emblem_text", next_emblem_num)
	end
end

return M