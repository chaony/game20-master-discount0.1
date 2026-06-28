local M = class("EquipAwakenPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 or msg "big_close_btn" then    -- 返回
        self:closeView()
	end
	
end

return M
