local M = class("ArenaHigherRankControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" and msg >= 1 and msg <= 2 then
        self:switchTabBtn(msg)
    elseif msg == "item_click" then
    	local item_data = data.cell_data
        local show_battle_array = data.cell_data.rank > 10
        self:openView("Pops.PlayerInfo", {uid = item_data.user.uid, look_model = 2,show_battle_array = show_battle_array})
    elseif msg == "explain_btn" then
        self:openView("Arena.ArenaHigher.ArenaHigherScoreExplain")
    end
end


-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        if self.m_model:getDataByIndex(index) then
            self.m_model.m_sel_tab_index = index
            self.m_view:switchTabNode(index)
        else
            local tab_btn_node = self.m_model:getTabBtnNode()
            local btn_tab = tab_btn_node[index]
            local function netCallback(response)
                if response and self.m_model then
                    self.m_model.m_sel_tab_index = index
                    self.m_model:initData(response, index)
                    self.m_view:switchTabNode(index)
                end
            end
            local params = {start = 1, stop = 50}
            self.m_model:getNetData(btn_tab.url_key, params, netCallback)
        end
    end
end

return M
