local M = class("CompareSwordDefendPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "btn_Name" then

	end
end

function M:destroy()

	M.super.destroy(self)
end


return M