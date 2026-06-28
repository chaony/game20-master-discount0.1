local M = class("MythArenaSecondRecordPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cell_hit_btn" then
        if data then
            local stage_id = self.m_model.m_cur_big_stage_id
            local group_id = data
            local params = {}
            params.last_stage = stage_id
            params.last_group_id = group_id
            params.open_type = "last"
            params.real_big_stage = self.m_model.m_real_big_stage
            if self.m_model.m_real_big_stage == 8 then
                self:openView("MythArena.MythArenaSecond", params)
            else
                self:updateMsg("look_history", params, "MythArena.MythArenaSecond")
            end
            self:closeView()
        end
    elseif msg == "switch_tag" then
        if data ~= self.m_model.m_select_index then
            if self.m_model.m_select_index % 2 ~= data % 2 then
                self.m_view.m_loopScroll_view = nil
            end
            self.m_model.m_select_index = data
            self.m_model.m_cur_big_stage_id = self.m_model.m_tab_id[data]
            if  self.m_model.m_total_logs[self.m_model.m_cur_big_stage_id] then
                self.m_view:switch_UI(data)
                --self.m_view:refreshUI()
            else
                self:requestChangeStage(data, self.m_model.m_cur_big_stage_id)
            end
        end
    elseif msg == "look_player" then
        if data then
            self:openView("Pops.PlayerInfo", {uid = data, look_model = 10})
        end
    end
end

function M:requestChangeStage(cur_index, stage_id)
    local function callfunc(response)
        self.m_model:updateData(response)
        self.m_view:switch_UI(cur_index)
        --self.m_view:refreshUI()
    end
    self.m_model:getNetData("myth_arena_stage_logs", {stage_id = stage_id}, callfunc)
end

function M:destroy()
    M.super.destroy(self)
end

return M;
