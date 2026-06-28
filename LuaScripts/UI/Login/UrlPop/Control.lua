local M = class("LoginServerControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "select_server" then
        GameUtil:lookInfoTips(self, {msg = "切换到 <color=#E0793B>" .. data.name .. "</color>", delay_close = 2})
        UserDataManager.server_data:setSelectServerInfo(data)
        UserDataManager.client_data.user_account = nil
    	self:closeView()
    end
end

return M;