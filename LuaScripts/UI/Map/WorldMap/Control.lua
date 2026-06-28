local M = class("WorldMapControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "click_stage" then
        self:openView("Map.MapPop",{chapter_id = data}) 
    end
end

return M