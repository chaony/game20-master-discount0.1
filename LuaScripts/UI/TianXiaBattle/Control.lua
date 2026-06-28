local M = class("TianXiaBattleControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = -1})
    elseif msg == "head_btn" then
        if data then
            self:openView("Pops.PlayerInfo", {uid = data, look_model = 1})
        end
    elseif msg == "rank_btn" then -- 排行榜
        self:openView("TianXiaBattle.TXRankMain")
    elseif msg == "refresh" then
        self.m_model.m_refresh_flag = true
        self:shopIndex(self.m_model.m_sel_tab_index)
    end
end

function M:heroDetailPop(index, cell_data)
    --local data = cell_data
    --local remain = data.data.remain or 0
    --if remain < 1 then
    --    return
    --end
    --self.m_model.m_refresh_flag = false
    --local item = data.data.item
    --local sell = data.data.sell
    --local show_data = RewardUtil:getProcessRewardData(item)
    --local function okCallFunc()
    --    self:readyToBuy(index, cell_data)
    --end
    --if show_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
    --    self:openView("HeroInfo.EquipmentPop", {equip_cfg_id = show_data.data_id, cost = sell, ok_call_func = okCallFunc, look_model = 2, hero_ids = data.hero_ids})
    --else
    --    self:openView("Item.ItemDetail", {show_data = show_data, cost = sell, ok_call_func = okCallFunc})
    --end
end


function M:destroy()
    M.super.destroy(self)
end

return M
