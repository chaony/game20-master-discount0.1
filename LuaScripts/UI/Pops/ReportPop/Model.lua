local M = class("ReportPopModel", LikeOO.OODataBase)

local REPORT_TYPE = {"2_2", "2_1", "3_1", "1_1", "12_1",}
function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_report_id = nil
	self.m_report_type = nil
	self.m_module_id = self.m_params.module_id -- 对应举报界面的id  1:玩家信息 2：英雄评价 3：聊天
	self.m_user_name = self.m_params.name
	self.m_uid = self.m_params.uid
	self.m_chat = self.m_params.chat
end

function M:setReportIndex(report_Index)
	self.m_report_id = report_Index
	self.m_report_type = REPORT_TYPE[report_Index]
end

return M
