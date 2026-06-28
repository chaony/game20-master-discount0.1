local M = class("CompareSwordMyRacePlayerInfoControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "btn_Name" then
		
	elseif msg == "btn_formation" then --个人侠客
		
	elseif msg == "btn_editor" then --战报

	end
end

function M:destroy()

	M.super.destroy(self)
end


return M