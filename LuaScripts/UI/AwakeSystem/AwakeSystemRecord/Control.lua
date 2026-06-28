local M = class("AwakeSystemRecordControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:closeView()
    elseif msg == "next_btn" then -- 下一页
        self.m_view:setLengentNum("next")
    elseif msg == "last_btn" then --上一页
        self.m_view:setLengentNum("last")
    end
end



return M