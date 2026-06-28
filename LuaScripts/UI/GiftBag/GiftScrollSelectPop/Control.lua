local M = class("GiftScrollSelectPopControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "select_reward" then
        self.m_model.m_select_big_id = data
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then
        self:setBigPrize()
    elseif msg == "cancle_btn" then
        self:updateMsg(99999)
    elseif msg == "check_btn" then   
        local itemData = RewardUtil:getProcessRewardData(data.dataTable)
        if itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
            if itemData.oid then
                static_rootControl:openView("HeroInfo.EquipmentPop", {equip_id = itemData.oid})
            else
                static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg_id = itemData.data_id, race = itemData.race, look_model = 3})
            end
        elseif itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            static_rootControl:openView("Item.ItemDetail", {show_data = itemData, display = true}, nil, true)
        elseif itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
            static_rootControl:openView("Pops.HeroLookInfo", {hero_id = itemData.data_id, is_new = false})
        elseif itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
            local hero_id = itemData.item_cfg.hero
            static_rootControl:openView("Pops.HeroLookInfo", {hero_id = hero_id, is_new = false, skin_id = itemData.data_id})
        elseif itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
            static_rootControl:openView("SutraDepository.DepositoryPop", {oid = itemData.data_id, mode = 2, star = itemData.star})
        elseif itemData.data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
            static_rootControl:openView("Title.TitleDetail", {show_data = itemData, display = true})
        else
            static_rootControl:openView("Pops.CommonItemTipsPop", {data = itemData, target_obj = data.obj})
        end 
    end
end

--在线奖励
function M:setBigPrize()
    local function receivetCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg("updateNewNet", nil, "GiftBag")
            self:updateMsg(99999)
            return
        end
        self:updateMsg("updateBigPrize", response.big_gift_id, "GiftBag.GiftScrollPanel")
        self:updateMsg(99999)
    end
    local params = {gift_id = self.m_model.m_select_big_id, vsn = self.m_model.m_version}
    self.m_model:getNetData("scroll_set_big_prize", params, receivetCallback)
end


return M
