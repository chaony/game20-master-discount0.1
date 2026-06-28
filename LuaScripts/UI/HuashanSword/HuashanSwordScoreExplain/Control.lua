local M = class("HuashanSwordScoreExplainControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "order_btn_text" then -- 调整顺序

    elseif msg == "ok_btn_text" then -- 保存

    elseif msg == "cancle_btn_text" then -- 取消

    end
end

return M
