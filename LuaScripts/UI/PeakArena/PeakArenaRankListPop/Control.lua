local M = class("PeakArenaRankListPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "peak_game_btn" then --进入
        self:openView("PeakArena.PeakArenaGame")
    elseif msg == "set_battle_array_btn" then --布阵
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.MULT_FORMATION})
    elseif msg == "hint_btn" then 
        local params = {}
        params.title = "gf_str_0078"
        params.content = Language:getTextByKey("gf_str_0078")
        self:openView("Pops.CommonHelpPop", params) 
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "tog_lock" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("peak_str_0046"), delay_close = 2})
    end
end


-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

return M
