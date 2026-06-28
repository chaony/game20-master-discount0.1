local M = class("MagicWeaponLvUpPopControl",LikeOO.OOControlBase)

function M:onEnter()
	audio:SendEvtUI("UI_ShengJi")
	self:setOnceTimer(0.8, function ()
		self:updateMsg(99999)
	end)
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		if self.m_model.m_callback then
			self.m_model.m_callback()
		end
		self:closeView()
	end
end


return M
