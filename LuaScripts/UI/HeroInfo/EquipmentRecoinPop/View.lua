local M = class("EquipmentRecoinPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/EquipmentRecoinPop"

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0514")
    self:setTextByLanKey("recoin_text", "new_str_0514")
    self:setTextByLanKey("ok_text", "new_str_0006")
    self:setTextByLanKey("cancle_text", "new_str_0007")
    self.light_tab = {}
    for i = 1,5 do
        local light_img = self:findGameObject("light_"..i)
        light_img:SetActive(false)
        self.light_tab[i] = light_img
    end

    self.m_icon_node = self:findGameObject("item_parent")
    local data, cfg = self.m_model:getEqpData()
    if cfg then
        if data then
            self.cur_equip = GameUtil:createItemElement({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race}, false, false)
            self.cur_equip.transform:SetParent(self.m_icon_node.transform, false)
            GameUtil:updateItemEquipInfo(self.cur_equip, data)
            local luaBehaviour = UIUtil.findLuaBehaviour(self.cur_equip)
        else
            self.cur_equip = GameUtil:createItemElement({ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cfg.id, 0}, false, false)
            self.cur_equip.transform:SetParent(self.m_icon_node.transform, false)
        end
    end
    local consItem = self.m_model:getCons()
    self:setImg(consItem.icon_name, consItem.atlas_name, "cons_img")
    self:setText("cons_num", consItem.user_num)
    self:setRecoinBtn(true)
    self:setOkBtn(false)
    self:refreshUI()
end

function M:refreshUI()
    for k,v in pairs(self.m_model.m_race_tab) do
        local race_name = "race_"..k
        local race_data = GlobalConfig.TYPE_HERO_RACE[v]
        self:setImg(race_data.big_race_icon,  ResourceUtil:getLanAtlas(), race_name)
    end
    for k,v in pairs(self.light_tab) do
        v:SetActive(false)
    end
end

function M:setLightImg()
    local index = self.m_model.m_random_index
    for k,v in pairs(self.light_tab) do
        v:SetActive(index == k)
    end
end

function M:updataEqp()
    local data, cfg = self.m_model:getEqpData()
    if cfg then
        if data then
            GameUtil:updateItemEquipInfo(self.cur_equip, data)
            local luaBehaviour = UIUtil.findLuaBehaviour(self.cur_equip)
        else
            self.cur_equip = GameUtil:updateItemElement(self.cur_equip,{ RewardUtil.REWARD_TYPE_KEYS.EQUIPS, cfg.id, 0}, false, false)
        end
    end
    self:updataCons()
end

function M:updataCons()
    local consItem = self.m_model:getCons()
    self:setImg(consItem.icon_name, consItem.atlas_name, "cons_img")
    self:setText("cons_num", consItem.user_num)
end

function M:setRecoinBtn(bl)
    self:setObjectVisible("recoin_btn", bl)
end

function M:setOkBtn(bl)
    self:setObjectVisible("ok_btn", bl)
    self:setObjectVisible("cancle_btn", bl)
end

return M