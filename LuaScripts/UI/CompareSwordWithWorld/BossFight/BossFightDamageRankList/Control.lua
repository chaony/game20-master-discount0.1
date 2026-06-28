local M = class("BossFightDamageRankListControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "reward_btn" then
        self:openView("Rank.RankReward",{id = self.m_model.m_id, rank_cfg = self.m_model.m_rank_cfg})
    elseif msg == "load_rank" then
        self:requestLoadRank()
    elseif msg == "check_tag" then 
        self:switchTabBtn(data)
    elseif msg == "check_formation" then
        local item_data = self.m_model:getCurRankDataByIndex(data.id)
        local open_tab_index = data.open_tab_index
        self:openView("Pops.PlayerInfo", {uid = item_data.user.uid , look_model = 11 , open_tab_index = open_tab_index})
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_model.m_cur_tab_index = index
        if not next(self.m_model.m_total_rank_list[self.m_model.m_cur_tab_index].ranks)  then  
            self:requestRankData(index)
        else
            self:requestRankData(index)
            self.m_view:switchNode(index)
        end
    end
end

-- 排行榜入口 sort: 排行榜类型 start: 开始的排名 stop: 结束的排名
function M:requestRankData(sort, start_pos, end_pos)
    local function netCallback(response)
        if response and self.m_model then
            self.m_model:initData(response)
            self.m_view:switchNode()
        end
    end
    start_pos = start_pos or 1
    end_pos = end_pos or 10  --todo: 默认列表个数
    local params = { battle_id = self.m_model.m_total_rank_list[sort].battle_id, start = start_pos, stop = end_pos }
    self.m_model:getNetData("full_service_get_boss_damage_rank", params, netCallback, nil, nil, nil)
end

--下拉刷新的加载逻辑
function M:requestLoadRank()    
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_mail_load = true
                self.m_model:insertRankData(response.ranks)
                self.m_view:switchNode()
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        params.sort = self.m_model.m_sel_tab_index
        self.m_model:getNetData("full_service_get_boss_damage_rank", params, netCallback)
    end
end

return M
