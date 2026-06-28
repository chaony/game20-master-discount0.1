local M = class("HuntTreasuresGuildAreaPop",LikeOO.OOControlBase)

function M:onEnter()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "change_HuntTreasuresGuild_scene" then
        --SceneManager:changeScene(SceneManager.SceneID.JiaoWai)
        self.m_view:refreshUI()
    elseif msg == "item_click" then
        if data.open_flag then
            local region_id = self.m_model.m_sel_tab_index
            local location_id = self.m_model:getLocationId(data.index)
            self:updateMsg("change_area", { region_id = self.m_model.m_region_id, location_id = location_id, close_view_name = "HuntTreasuresGuildAreaPop"  }, "HuntTreasuresGuild")
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
        -- self:openView("HuntTreasuresGuild.HuntTreasuresGuildBigMapPop")
        -- self:closeView()
    elseif msg == "refresh_index" then
        self:getActiveMiningRegionData()
    elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
        self:switchRegionTabBtn(msg)
    end
end

-- 按钮切换
function M:switchRegionTabBtn(index)
    if self.m_model.m_sel_region_index ~= index then
        self.m_model.m_sel_region_index = index
        self:switchTabBtn(0,true,nil,self.m_model.m_region_id_tab[index])
        self.m_view:switchTabNode(index)
    end
end

-- 刷新区域数据
function M:getActiveMiningRegionData()
    local function callFunc(response)
        if self.m_timer_id then
            self:removeTimer(self.m_timer_id)
        end
        --self.m_model.m_sel_tab_index = index
        self.m_model:updateData(response)
        self.m_view:refreshUI()
        self.m_view:refreshCellStatus()
    end
    self.m_model:getNetData("active_mining_region_index", {region_id = self.m_model.m_region_id, sub_id = self.m_model.m_sel_tab_index, ver = self.m_model.m_version}, callFunc)

end

-- 按钮切换
function M:switchTabBtn(index, open_flag, tips_str, region_id)
    if self.m_model.m_sel_tab_index ~= index then
        if open_flag and not region_id then
            local function callFunc(response)
                self.m_model:updateData(response)
                self.m_view:refreshUI()
            end
            self.m_model:getNetData("active_mining_region_index", {region_id = self.m_model.m_region_id, sub_id = index, ver = self.m_model.m_version}, callFunc)
            self.m_model.m_sel_tab_index = index
            self.m_view:refreshCellStatus()
        elseif open_flag and region_id then
            local function callFunc(response)
                self.m_model.m_region_id = region_id
                self.m_model.m_sel_tab_index = self.m_model.m_sub_id
                self.m_model:updateData(response)
                self.m_model:initAreaCfg()
                self.m_view:refreshAllUI()
            end
            self.m_model:getNetData("active_mining_region_index", {region_id = region_id, sub_id = self.m_model.m_sub_id, ver = self.m_model.m_version}, callFunc)
            self.m_model.m_sel_tab_index = 1
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
