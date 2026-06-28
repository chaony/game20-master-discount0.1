local M = class("WorldMapPrestigeControl",LikeOO.OOControlBase)

function M:onEnter()
    self:switchTabBtn(self.m_model.m_open_tab_index)
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回	
        if self.m_model.m_mode == 1 then
            self:get_idle_reward()
        end
        self:closeView()
    elseif msg == "check_tag" then
        if self.m_model.m_sel_tab_index then
            if self.m_model.m_sel_tab_index ~= data then
                self.m_model.m_sel_tab_index = data
                self.m_model.m_open_tab_index = self.m_model.m_sel_tab_index
                self.m_view:switchTabNode(data)
            end
        else
            self.m_model.m_sel_tab_index = data
            self.m_model.m_open_tab_index = self.m_model.m_sel_tab_index
            self.m_view:switchTabNode(data)
        end
    elseif msg == "select_area" then
        self.m_model.m_area_map = data
        self.m_view:refreshUI()
    elseif msg == "get_reward" then
        self:receivePrestige(data)
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchTabNode(index)
    end
end

function  M:receivePrestige(data)
    local function callfunc(response)
        if response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model.m_prestiges = response.prestiges
        self.m_model.cur_prestiges_num = response.prestiges.value
        self.m_model.cur_prestiges_done = response.prestiges.done
        self.m_view:refreshUI()
    end
    if data then
        self.m_model:getNetData("big_map_prestige_receive",{area_id = self.m_model.m_cur_map_id, p_id = data }, callfunc)	
    end
end

return M;
