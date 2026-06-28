local M = class("CommonQuickGoToControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "goto_btn" then
        if data.cell_data.cfg.donot_off ~= 1 then -- 不关闭
            self:updateMsg("common_refresh", nil, "parent")
            static_rootControl:closeAllViewPop()
        else
            self:closeView()
        end
        QuickOpenFuncUtil:openFunc(data.cell_data.id)
    end
end

return M
