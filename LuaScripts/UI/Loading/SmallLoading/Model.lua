local M = class("LoadingModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
    local params = self.m_params or  {}
    self.m_show_time = params.show_time or 0 -- 显示多长时间自动关闭
    self.m_callfunc = params.callfunc
    self.m_delay_show = params.delay_show or 0 -- 延迟显示
end

return M
