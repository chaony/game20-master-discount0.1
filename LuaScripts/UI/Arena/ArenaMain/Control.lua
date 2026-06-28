local M = class("ArenaMainControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "arena_normal_btn" then --竞技场
        QuickOpenFuncUtil:openFunc(24)
    elseif msg == "arena_higher_btn" then --高阶竞技场   
        QuickOpenFuncUtil:openFunc(25)
    elseif msg == "arena_peak_btn" then --巅峰竞技场
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
    end
end

return M
