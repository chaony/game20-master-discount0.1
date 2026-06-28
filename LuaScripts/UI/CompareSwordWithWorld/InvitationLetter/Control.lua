local M = class("InvitationLetterControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then
		self.m_model:getNetData("full_service_read_invitation" , nil , function()
			
		end)  --发送已读邀请函
		self:closeView()
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M