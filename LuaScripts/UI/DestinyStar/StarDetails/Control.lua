local M = class("StarDetailsControl",LikeOO.OOControlBase)

function M:onEnter()
end



function M:onHandle(msg,data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "close_btn" or "guang_img" then
        self:closeView()
    end
end



return M;
	