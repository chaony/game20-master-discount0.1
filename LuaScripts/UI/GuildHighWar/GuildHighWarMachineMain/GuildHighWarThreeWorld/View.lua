--==================================
-- file:  View.lua
-- brief:  巅峰帮会战结算界面
-- author:  LiuMiao
-- date:  2022/7/28
--==================================
local M = class("GuildHighWarThreeWorldView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarMachineMain/GuildHighWarThreeWorld"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("common_title_text", "guild_high_war_new_0051")
	self:setTextByLanKey("recvert_btn_text","guild_high_war_new_0055")
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	--刷新界面
	--self:updateButtonAndScreen()
	self:setTextByLanKey("des_txt1","tid#DFBHZBuildBuff_1")
	self:setTextByLanKey("des_txt2","tid#DFBHZBuildBuff_2")
	self:setTextByLanKey("des_txt3","tid#DFBHZBuildBuff_3")
end


function M:destroy()

    M.super.destroy(self)
end


return M