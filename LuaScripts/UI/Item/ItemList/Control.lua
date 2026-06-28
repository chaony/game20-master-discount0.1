local M = class("ItemListControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point",nil,"parent")
        self:closeView()
    -- 1道具、2装备、3灵魂石、4全部、5江湖道具
    elseif type(msg) == "number" and msg >= 1 and msg <= 5 then
        self:switchTabBtn(msg)
    elseif msg == "item_click" then
        if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            if data.item_cfg.type == 3 then --可选宝箱
                if self.m_model:isHeroReward(data.item_cfg) == true then
                    self:openView("Item.HeroBox", {show_data = data})
                else
                    self:openView("Item.ItemBox", {show_data = data})
                end
            else
                self:openView("Item.ItemDetail", {show_data = data})
            end
        elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
            self:openView("HeroInfo.EquipmentPop",{equip_id = data.oid})    --查看装备
        end
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model:refreshListData(index)
        self.m_view:switchTabNode(index)
        self.m_model.m_sel_tab_index = index
    end
end

function M:dataUpdateEvent(event, data)
    local curEvent = data.event
    if curEvent == "items_update" or curEvent == "equips_update" or curEvent == "mystices_update"  or curEvent == "red_packet_update" then
        self.m_model:refreshListData(self.m_model.m_sel_tab_index, true)
        self.m_view:switchTabNode(self.m_model.m_sel_tab_index, true)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    M.super.destroy(self)
end

return M
