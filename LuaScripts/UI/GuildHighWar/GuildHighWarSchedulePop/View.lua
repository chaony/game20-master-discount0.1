--==================================
-- file:  View.lua
-- brief:  巅峰帮会战结算界面
-- author:  LiuMiao
-- date:  2022/7/28
--==================================
local M = class("GuildHighWarSchedulePopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarSchedulePop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("close_title_text", "guild_high_war_text_00113")

	self:setTextByLanKey("cur_des_text", "guild_high_war_text_0085")
	self:setTextByLanKey("last_des_text", "guild_high_war_text_0086")
	self:setTextByLanKey("big_close_btn_txt", "guild_high_war_text_0087")
	self:setObjectVisible("guide_btn",false)
	self:refreshUI()
end

--刷新UI
function M:refreshUI()

	self:updateText()
end

function M:updateText()
	for i=1,17 do
		self:setTextByLanKey("schedule_txt"..i, "guild_high_war_sch_text_"..i)
	end
end

function M:destroy()

    M.super.destroy(self)
end


return M