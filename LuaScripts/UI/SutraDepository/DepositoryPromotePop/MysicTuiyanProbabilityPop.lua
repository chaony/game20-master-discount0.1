--- 秘籍推演概率
local M = class("MysicTuiyanProbabilityPopNode",LikeOO.OOUIbase)

M.m_uiName = "SutraDepository/MysicTuiyanProbabilityPop"

function M:onCreate()
	self.m_call_func = self.m_params.call_func
	self.m_transfer = "scale"
end

function M:onButtonClick(obj, name, data)
	if name == "close_btn" then
		self:destroy()
	end
end

function M:onEnter()
	self:setTextByLanKey("composite_title_text", "mystic_str_0077")
	local rate_1 = self.m_params.xian_rate
	local rate1 = string.format("%.2f", rate_1*100)
	self:setTextByLanKey("composite_text1",  Language:getTextByKey("mystic_str_0078", rate1))
	local rate_2 = self.m_params.jue_rate
	local rate2 = string.format("%.2f", rate_2*100)
	self:setTextByLanKey("composite_text2",  Language:getTextByKey("mystic_str_0079", rate2))
	local season = UserDataManager:getCurSeason()
	if season >= 4 then
		self:setObjectVisible("composite_text3", true)
		local rate_3 = self.m_params.shen_num
		local rate3 = string.format("%.2f", rate_3*100)
		self:setTextByLanKey("composite_text3",  Language:getTextByKey("mystic_str_0087", rate3))
	else
		self:setObjectVisible("composite_text3", false)
	end
end

function M:destroy()
	if self.m_call_func then
		self.m_call_func()
	end
	M.super.destroy(self)
end

return M