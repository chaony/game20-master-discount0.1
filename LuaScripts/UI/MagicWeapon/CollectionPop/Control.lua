local M = class("CollectionPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:closeView()
	elseif msg == "get_reward_btn" then
		self:closeView()
	end
end


return M
