local M = class("FulwinArenaDoorControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "btn_moni" then
        self:openView("FulwinArena.FulwinArenaInvitePop")
        self:closeView()
    elseif msg == "btn_geren" then
        --local is_open, tips = BtnOpenUtil:isBtnOpen(334)
        --if is_open then
            self:openView("FulwinArena.FulwinArenaSingleSetting", {typ = 1})
            self:closeView()
        --else
        --    GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
        --end
    elseif msg == "btn_jinji" then
        local is_open, tips = BtnOpenUtil:isBtnOpen(335)
        if is_open then
            self:openView("FulwinArena.FulwinArenaSingleSetting", {typ = 2})
            self:closeView()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("Fengyun_challenge_tips_no"), delay_close = 2})
        end
    end
end

return M