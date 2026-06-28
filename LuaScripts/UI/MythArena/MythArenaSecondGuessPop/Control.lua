local M = class("MythArenaSecondGuessPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "guess_btn" then
        self:requestGuess()
    end
end

function M:requestGuess()
    local function netCallback(response)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0043"), delay_close = 2})
        local guess_data = response.guess_data or nil
        self:updateMsg("update_guess_data", guess_data, "MythArena.MythArenaSecond")
        self:closeView()
    end
    local params = {}
    params.guess_uid = self.m_model.m_guess_uid
    params.group_id = self.m_model.m_group_id
    self.m_model:getNetData("myth_arena_guess", params, netCallback)
end


function M:destroy()
    M.super.destroy(self)
end

return M;
