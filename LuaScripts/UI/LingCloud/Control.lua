local M = class("LingCloudControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.LingCloud.Guide"
    self.m_view:refreshTimeUI()
    self:setTimer(1,function()
        self.m_view:refreshTimeUI()
        if self.m_model:checkLastTime() == true then
            self:arenaIndex()
        end
    end)
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 返回
        self:updateMsg("refreshRedPoint" ,nil ,"Main.TotalWorld")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "left_start_btn" then
        QuickOpenFuncUtil:openFunc(25)
    elseif msg == "right_start_btn" then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(64)
        if open_flag == true then
            self:openView("PeakArena.PeakArenaMain")
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(tips_str), delay_close = 2})
        end
    elseif msg == "update_top_rank" then
        if self.m_model.m_top_arena.rank ~= data then
            self.m_model.m_top_arena.rank = data
        end
    end
end

function M:arenaIndex()
    local function netCallback(response)
        self.m_model:initData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("world_index", {}, netCallback)
end


function M:destroy()
    M.super.destroy(self)
end

return M
