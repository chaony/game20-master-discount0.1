local M = class("PassLineupPopControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then
        self:closeView()
    elseif msg == "open" then
        if data then
            local item_data = data
            local round = 1
            if item_data.click_name and item_data.click_name == "check_btn2" then
                round = 2
            elseif  item_data.click_name and item_data.click_name == "check_btn3" then
                round = 3
            end
            self:openView("Pops.BattleStatistics",  {mode = self.m_model.m_mode, battle_id = item_data.battle_id, round = round, log_data = item_data})    
        else
            GameUtil:lookInfoTips(self, { msg = Language:getTextByKey("new_str_0512"), delay_close = 2})
        end
   end
end


function M:destroy()
    M.super.destroy(self)
end

return M;
