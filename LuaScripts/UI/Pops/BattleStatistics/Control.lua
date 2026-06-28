local M = class("BattleStatisticsControl",LikeOO.OOControlBase)

function M:onEnter()
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(80)
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == 'play_btn' then -- 播放
        -- self:updateMsg("battle",{data = self.m_model.m_data, mode = self.m_model.m_data.battle.sort, replay = true, round = self.m_model.m_round},"parent")
        if self.m_model.m_data.battle.sort == GlobalConfig.BATTLE_MODE.HIGH_ARENA or self.m_model.m_data.battle.sort == GlobalConfig.BATTLE_MODE.HUASHAN_SWORD then
            SceneManager:continue()
        end
        self:openView("GamePanel", {data = self.m_model.m_data,
                                    mode = self.m_model.m_data.battle.sort,
                                    replay = true,
                                    round = self.m_model.m_round,
                                    battle_config_id = self.m_model.m_battle_config_id,
                                    boss_id = self.m_model.m_boss_id,
                                    m_boss_max_hp = self.m_model.m_data.max_hp,
                                    m_boss_hp_cid = self.m_model.m_data.boss_hp_cid,
                                    budo_floor = self.m_model.m_budo_floor,
                                    m_races = self.m_model.m_races,
                                    stage_id = self.m_model.m_data.gve_stage_id,
        })
        if self:hasChild("Settlement") then
            self:closeView()
            self:closeView("Settlement")
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    if SceneManager.curScene.showMove ~= nil then
        SceneManager.curScene.showMove:SetDepth(120)
    end
end

return M
