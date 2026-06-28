local M = class("MagicWeaponHeroPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "cultivate_btn" then
			
	end
end


return M
