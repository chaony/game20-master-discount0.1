local M = class("SettingControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "restart_btn" then
    	GameMain.reStart()
    end
end

return M
