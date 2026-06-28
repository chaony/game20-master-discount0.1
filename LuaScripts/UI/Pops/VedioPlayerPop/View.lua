local M = class("VedioPlayerPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/VedioPlayerPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.vedio = self:findGameObject("vedio")	
	local video_control = self.vedio:GetComponent("VideoControl")
	local full_path,file_type = io.fileFullPath(self.m_model.m_vedio_path)
	if full_path then
		video_control:VideoPlay(file_type,self.m_model.m_vedio_path,true,self.m_model.m_delay);
	else
		self:updateMsg(99999)
		Logger.logError(full_path,"mp4 not found : ")
	end
	video_control:RegisterPlayFinish(handler(self, self.videoPlayFinish))
	self:setObjectVisible("close_btn", false)
	self:setObjectVisible("big_close_btn", false)
	if not self.m_model.m_no_close_btn then
		self.m_control:setOnceTimer(self.m_model.m_close_btn_delay, function()
			self:setObjectVisible("close_btn", self.m_model.m_close_btn_type == 1)
			self:setObjectVisible("big_close_btn", self.m_model.m_close_btn_type == 0)
		end)
	end
	self:refreshUI()
end

function M:refreshUI()

end

function M:videoPlayFinish()
	self:updateMsg(99999)
end

return M