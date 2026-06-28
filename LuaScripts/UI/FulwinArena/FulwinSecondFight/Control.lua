
local M = class("FulwinSecondFightControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        local params =
        {
            on_ok_call = function(msg)
                self:closeView()
            end,
            text = Language:getTextByKey("fylt_str_0099"),
        }
        self:openView("Pops.CommonPop", params)
    elseif msg == "round_battle" then
        self.m_model:addRound()
        self.m_view:refreshUI()
        self.m_view:setBattleDownTime()
    elseif msg == "play_battle" then
        local log = self.m_model:getBattleData(data)
        --local mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE
        --if self.m_model.m_params.ring_info.team_type ~= 1 then
        --    mode = GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
        --end
        --self:openView("Pops.BattleStatistics",  {mode = mode, battle_id = log.battle_record_id, round = 1})
        self:openView("HuashanSword.HuashanSwordBattleDetail", {battle_id = log.battle_record_id, log_data = log})
    elseif msg == "show_player" then
        self:openView("Pops.PlayerInfo", {uid = data.uid})
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M
