local M = class("UnionWarSituationControl",LikeOO.OOControlBase)


function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "own_battle_log_btn" then
        self:updateMsg(99999)
        --self:openView("UnionWar.UnionWarLog", {default_tab = 2, log_type = 1})
        local function callback(response)
            local function callbackindex(response_index)
                local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
                if guild_id and guild_id > 0 then
                    self:openView("UnionWar.UnionWarLog", {default_tab = 2, log_type = 1, active_data = response_index, active_list_data = response.rank_data})
                end
            end
            self.m_model:getNetData("guild_index", nil, callbackindex)
        end
        self.m_model:getNetData("gvg_active_rank", nil, callback)
    elseif msg == "battle_log_detail_btn" then
        self:updateMsg(99999)
        self:openView("UnionWar.UnionWarLog", {default_tab = 2, log_type = 2})
        local function callback(response)
            local function callbackindex(response_index)
                local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
                if guild_id and guild_id > 0 then
                    self:openView("UnionWar.UnionWarLog", {default_tab = 2, log_type = 2, active_data = response_index, active_list_data = response.rank_data})
                end
            end
            self.m_model:getNetData("guild_index", nil, callbackindex)
        end
        self.m_model:getNetData("gvg_active_rank", nil, callback)
    end
end

return M