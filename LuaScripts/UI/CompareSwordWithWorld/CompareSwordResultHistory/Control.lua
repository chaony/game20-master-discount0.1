local M = class("CompareSwordResultHistoryControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "onclick_btn_look" then
		if data.active then
			self:updateMsg("refresh_version", { version = data.active.version }, "CompareSwordWithWorld.CompareSwordResult")
			self:closeView()
		end
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M