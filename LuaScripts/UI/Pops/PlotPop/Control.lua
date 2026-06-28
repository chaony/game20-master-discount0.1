local M = class("PlotPopControl",LikeOO.OOControlBase)

function M:onEnter()
	StatisticsUtil:sendPlotPopLog(1)
	if type(self.m_model.m_enter_callback) == "function" then
		self.m_model.m_enter_callback()
	end
	self:setOnceTimer(1.3, function()
		SceneManager:setData("show_loading_content", false)
		SceneManager:changeScene(SceneManager.SceneID.HangUpScene, nil, true)
	end)
end

function M:onHandle(msg , data)
    if msg == 99999 then
    	if type(self.m_model.m_callback) == "function" then
    		self.m_model.m_callback()
    	end
    	if self.m_model.m_new_heros and #self.m_model.m_new_heros > 0 then
    		EventDispatcher:dipatchEvent("show_new_hero", self.m_model.m_new_heros)
    	else
			self:updateMsg("check_first_login",nil,"parent")
            self:updateMsg("common_refresh",nil,"parent")
    	end
    	self:updateMsg("checkLvUp",nil,"parent")
        self:closeView()
	elseif msg == "continue_btn" then
		self.m_view:continueSpine()	
	elseif msg == "load_scene_finish" then
		self.m_model.m_load_scene_finish = true
		if self.m_model.m_close_pop and self.m_model.m_load_scene_finish then
			self:updateMsg(99999)
		end
    end
end

function M:destroy()
	M.super.destroy(self)
	StatisticsUtil:sendPlotPopLog(2)
end

return M;
