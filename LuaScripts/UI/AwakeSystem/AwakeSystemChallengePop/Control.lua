---
---
local M = class("AwakeSystemChallengePopControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "change_btn" then
        local function Callback()
            local stage_id  = self.m_model.m_stage_id
            local battle_id  = self.m_model.m_stage
            self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.AWAKE_SYSTEM,
                                       stage_id = stage_id,
                                       battle_id = battle_id,
                                       cur_stage_cfg = self.m_model.m_stage_cfg,
            })
            self:closeView()
        end
        --self:openView("AwakeSystem.AwakeSystemShowBeforeStory", {open_event = self.m_model.m_stage_cfg.open_event})
        self:openView("Guide.GuideDrama", {dialog_id = self.m_model.m_stage_cfg.open_event, callback = Callback})
        end
end

function M:destroy()
    M.super.destroy(self)
end

return M