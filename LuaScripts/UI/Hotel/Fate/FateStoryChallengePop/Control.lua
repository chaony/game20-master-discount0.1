local M = class("FateStoryChallengePopControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    self.m_guide_file_name = "UI.Hotel.Fate.FateStoryChallengePop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "challenge_btn" then
        local function dramaCallback()
            local stage_id  = self.m_model.m_stage.id
            local battle_id  = self.m_model.m_stage.stage
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.HERO_FATE,
                                       stage_id = stage_id,
                                       battle_id = battle_id,
                                       cur_stage_cfg = self.m_model.m_stage,
            })
            self:closeView()
            self:updateMsg(99999, nil, "Hotel.Fate.FateStory")
        end
        --有剧情先播放剧情
        if self.m_model.m_stage.open_event and self.m_model.m_stage.open_event ~= 0 then
            self:openView("Guide.GuideDrama", {dialog_id = self.m_model.m_stage.open_event, callback = dramaCallback})
        else
            dramaCallback()
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M