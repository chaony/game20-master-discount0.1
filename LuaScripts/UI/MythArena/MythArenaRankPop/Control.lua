local M = class("MythArenaRankPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "load_rank" then
        self:requestLoadRank()
    elseif msg == "item_click" then
    	local item_data = data.cell_data
    	self:openView("Pops.PlayerInfo", {uid = item_data.user.uid, look_model = 10})
    end
end

function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_mail_load = true
                self.m_model:insertRankData(response.ranks)
                self.m_view:refreshUI()
            end
        end
        local params = {}
        params.start = start_pos
        params.stop = end_pos
        self.m_model:getNetData("myth_arena_select_arena_rank", params, netCallback)
    end
end
return M
