local M = class("LuckyRabbitHutProgressPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "" then
	
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M