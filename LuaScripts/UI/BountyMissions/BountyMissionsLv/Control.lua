--悬赏列表
local M = class("BountyMissionsLvControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
	end
	
end


return M;
