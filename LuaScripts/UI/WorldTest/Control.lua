local M = class("WorldTestControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:closeView()
	elseif msg == "openView" then
			-- self:openView(data)
		if data == -1 then
			self:openView("WorldMap.WorldMapMain")
		elseif data == 0  then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
		else		
			QuickOpenFuncUtil:openFunc(data)
		end	
		
	end
end



return M