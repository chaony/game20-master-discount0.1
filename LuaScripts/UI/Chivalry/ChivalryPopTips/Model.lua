local M = class("ChivalryPopTipsModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_title = self.m_params.title or Language:getTextByKey("new_str_0005")
	self.m_receive_stage = self.m_params.receive_stage or 0 --奖励领取状态,0:未领取  1:领取
	self.is_show_btn = self.m_params.is_show_btn or 0 --领取按钮显示状态,0:显示  1:不显示
	self.show_bg_img = self.m_params.show_bg_img or "a_lbxkx_sshj_tc_tanchuangBJ1" --显示的背景
end

--获取显示信息
function M:getShowContent()
	local legend_monument = ConfigManager:getCfgByName("legend_monument")
	return legend_monument[self.m_params.version+6]
end

return M
