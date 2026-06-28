local M = class("HuntTreasuresAreaPop",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.HuntTreasures.HuntTreasuresAreaPop.Guide"
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end
--function M:startGuide()
--    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(57, 0)
--    if have_guide then
--        if self.m_guide then
--            self.m_guide:start()
--        end
--    end
--end
function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "change_HuntTreasures_scene" then
        --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
        self.m_view:refreshUI()
    elseif msg == "item_click" then
        if data.open_flag then
            local region_id = self.m_model.m_sel_tab_index
            local location_id = self.m_model:getLocationId(data.index)
            self:updateMsg("change_area", { region_id = self.m_model.m_region_id, location_id = location_id, close_view_name = "HuntTreasuresAreaPop"  }, "HuntTreasures")
        else
            GameUtil:lookInfoTips(self, {msg = data.tips_str, delay_close = 2})
        end
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPgoint() 
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "left_item_click" then
        self:switchTabBtn(data.index, data.open_flag, data.tips_str )
    elseif msg == "big_map_btn" then
        self:openView("HuntTreasures.HuntTreasuresBigMapPop")
        self:closeView()
    elseif msg == "refresh_index" then
        local function callFunc(response)
            if self.m_timer_id then
                self:removeTimer(self.m_timer_id)
            end
            --self.m_model.m_sel_tab_index = index
            self.m_model:updateData(response)
            self.m_view:refreshUI()
            self.m_view:refreshCellStatus()
        end
        self.m_model:getNetData("mining_region_index", {region_id = self.m_model.m_region_id, sub_id = self.m_model.m_sel_tab_index}, callFunc)
    end
end
-- 按钮切换
function M:switchTabBtn(index, open_flag, tips_str)
    if self.m_model.m_sel_tab_index ~= index then
        if open_flag then
            local function callFunc(response)
                self.m_model:updateData(response)
                self.m_view:refreshUI()
            end
            self.m_model:getNetData("mining_region_index", {region_id = self.m_model.m_region_id, sub_id = index}, callFunc)
            self.m_model.m_sel_tab_index = index
            self.m_view:refreshCellStatus()
        else
            self.m_model.m_sel_tab_index = index
            self.m_view:refreshCellStatus()
            self.m_view:refreshUI(tips_str)
        end
    end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M;
