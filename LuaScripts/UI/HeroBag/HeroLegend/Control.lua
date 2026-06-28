local M = class("HeroLegend",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:closeView()
    elseif msg == "book_Btn" then --打开详情
        audio:SendEvtUI("UI_XK_ChuanQi_Open")
        self.m_view:openBook() 
    elseif msg == "next_btn" then -- 下一页
        audio:SendEvtUI("UI_XK_ChuanQi_Page")
        self.m_view:setLengentNum("next")
    elseif msg == "last_btn" then --上一页
        audio:SendEvtUI("UI_XK_ChuanQi_Page")
        self.m_view:setLengentNum("last")
    end
end



return M