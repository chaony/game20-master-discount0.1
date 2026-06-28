--江湖传说
local M = class("LegendControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
	if msg == 99999 then
		self:updateMsg("update_red_point", nil, "Activities.WorldBoss.WorldBossSelectMain")
		self:closeView()
	elseif msg == "guide_btn" then --快速导航
		self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 88})
	elseif msg == "enter_btn" then
		self:goBattle()
	elseif msg == "mopup_btn" then
		self:questForMopup()
	elseif msg == "legend_box_btn" then
		self:openView("Legend.LegendReward", {data = self.m_model.m_data})
	elseif msg == "rank_btn" then
		self:openView("Legend.LegendRank", {stage_cfg = self.m_model:getLegend()})
	elseif msg == "refresh_data" then
		self:refreshData(data)
	elseif msg == "help_btn" then --说明
		self:openView("Pops.CommonHelpPop", { title = "legend_str_001", content = "tid#legend1" })
	end
end

function M:refreshData(data)
	table.merge(self.m_model.m_data, data)
	self.m_model:updateData()
	self.m_view:refreshUI()
end

function M:questForMopup()
	local function netCallback(response)
		self:refreshData(response)
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("legend_str_034"), delay_close = 2})
	end
	self.m_model:getNetData("legend_quick_pass", nil, netCallback)
end

function M:goBattle()
	local legend = self.m_model:getLegend()
	if legend ~= nil then
		self:openView("Formation", {battle_id = self.m_model.m_data.stage_id, mode = GlobalConfig.BATTLE_MODE.LEGEND, legend_data = self.m_model.m_data})
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M;
