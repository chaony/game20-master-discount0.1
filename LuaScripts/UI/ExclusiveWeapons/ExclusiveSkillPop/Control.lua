local M = class("ExclusiveSkillPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "intensify_btn" then
        self:openView("ExclusiveWeapons")
    elseif msg == "check1_btn" then
        
    elseif msg == "check2_btn" then

	end
	
end

return M
