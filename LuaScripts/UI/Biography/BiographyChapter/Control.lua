local M = class("BiographyChapterControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Biography.BiographyChapter.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "battle_btn" then
        self:goBattle()
    elseif msg == "look_btn" then
        self:goLookback()
    elseif msg == "stage_click" then
        local flag, state = self.m_model:setCurStage(data)
        if flag then
            self.m_view:refreshStageInfo()
        elseif state == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("rpg_scroll_3"), delay_close = 2})
        end
    elseif msg == "update_data" then
        self.m_model:updateData(data)
        if self.m_model.m_battle_stage == nil then
            self:closeView()
        else
            self.m_view:resfreshUI()
        end
	end
end

function M:goBattle()
    local biography_stage = ConfigManager:getCfgByName("biography_stage")
    local stage_cfg = biography_stage[self.m_model.m_cur_stage] or {}
    local battle_id = stage_cfg.battle or 0
    if battle_id > 0 then
        if stage_cfg.story01 and stage_cfg.story01 > 0 then
            local function callback()
                if self.m_model then
                    self:openView("Formation", {battle_id = battle_id, mode = GlobalConfig.BATTLE_MODE.BIOGRAPHY, bio_id = self.m_model.m_biography, chapter_id = self.m_model.m_chapter, stage_id = self.m_model.m_cur_stage})
                    --self:closeView()
                end
            end
            self:openView("Guide.GuideDrama", {dialog_id = stage_cfg.story01, callback = callback, dialogue_type = GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY})
        else
            self:openView("Formation", {battle_id = battle_id, mode = GlobalConfig.BATTLE_MODE.BIOGRAPHY, bio_id = self.m_model.m_biography, chapter_id = self.m_model.m_chapter, stage_id = self.m_model.m_cur_stage})
        end
    end
end

function M:goLookback()
    local biography_stage = ConfigManager:getCfgByName("biography_stage")
    local stage_cfg = biography_stage[self.m_model.m_cur_stage] or {}
    if stage_cfg.story01 and stage_cfg.story01 > 0 then
        local function callback()
            if stage_cfg.story02 and stage_cfg.story02 > 0 then
                self:openView("Guide.GuideDrama", {dialog_id = stage_cfg.story02, dialogue_type = GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY})
            end
        end
        self:openView("Guide.GuideDrama", {dialog_id = stage_cfg.story01, callback = callback, dialogue_type = GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY})
    elseif stage_cfg.story02 and stage_cfg.story02 > 0 then
        self:openView("Guide.GuideDrama", {dialog_id = stage_cfg.story02, dialogue_type = GlobalConfig.WORLD_MAP_EVENT.BIOGRAPHY})
    end
end

return M;
