local M = class("ArenaRaceRankControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "item_click" then
    	local item_data = data.cell_data
        local look_model =  1
        if self.m_model.m_open_type == 5  then
            if self.m_model.team_num==2 then
                look_model =  6
            elseif self.m_model.team_num==3 then
                look_model =  7
            end
        else
            if self.m_model:getMatchTypeByIndex(self.m_model.m_sel_tab_index)  == 1 then
                look_model =  6
            elseif self.m_model:getMatchTypeByIndex(self.m_model.m_sel_tab_index)  == 2 then
                look_model =  7
            end
        end

        self:openView("Pops.PlayerInfo", {socre = item_data.score, rank = item_data.rank, uid = item_data.user.uid, look_model = look_model})
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        if  next(self.m_model:getDataByIndex(index))  then
            self.m_model.m_sel_tab_index = index
            self.m_view:switchNode(index)
        else
            local function netCallback(response)
                if response and self.m_model then
                    self.m_model.m_sel_tab_index = index
                    self.m_model:updateRankData(index, response.ranks)
                    self.m_view:switchNode(index)
                end
            end
            local match_type = self.m_model:getMatchTypeByIndex(index)
            local params = {start = 1, stop = 50, match_type = match_type}
            if self.m_open_type == 2 then
                self.m_model:getNetData("race_arena_season_select_arena_rank", params, netCallback)
            else
                self.m_model:getNetData("race_arena_select_arena_rank", params, netCallback)
            end
        end
    end
end

return M
