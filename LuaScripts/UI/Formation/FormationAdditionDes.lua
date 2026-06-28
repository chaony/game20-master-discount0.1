--- 多阵容
local M = class("FormationAdditionDes", LikeOO.OOUIbase)

M.m_uiName = "Formation/FormationAdditionDes"

M.FATTER_TAB = {
    {id = 1, lv = 2, text_name = "card3_count1", com_id = 71},
    {id = 2, lv = 3, text_name = "card3_count2", com_id = 72},
    {id = 3, lv = 4, text_name = "card3_count3", com_id = 73},
    {id = 4, lv = 5, text_name = "card3_count4", com_id = 74}
}

M.HERO = {101,102,103}

function M:onEnter()
    self.m_transfer = "up_to_down"
    self:refreshUI()
    -- for k,v in pairs(self.HERO) do
    --     local hk_obj = self:findGameObject("hero_sk_"..k)
    --     local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v)
    --     local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
    --     GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
    -- end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" or name == "big_close_btn" then
		self:destroy()
	end
end

function M:refreshUI()
    self:setTextByLanKey("card1_title", "fb_str_0016")
    self:setTextByLanKey("card2_title", "fb_str_0017")
    self:setTextByLanKey("card3_title", "fb_str_0018")
    self:setTextByLanKey("card_1_des", "fb_str_0019")
    self:setTextByLanKey("card_2_des", "fb_str_0020")
    self:setTextByLanKey("card_3_des", "fb_str_0021")
    self:setTextByLanKey("card_2_des2", "fb_str_0022",3)

    self:setTextByLanKey("card3_title1", "fb_str_0022", 3)
    self:setTextByLanKey("card3_title2", "fb_str_0023")
    self:setTextByLanKey("card3_title3", "fb_str_0022", 4)
    self:setTextByLanKey("card3_title4", "fb_str_0022", 5)
    self:setTextByLanKey("card3_count1", "fb_str_0022", 5)
    -- for k, v in pairs(self.FATTER_TAB) do
    --     local data = self:getBuffNum(self.FATTER_TAB[k].com_id)
    --     local num1 = data[1]
    --     local num2 = data[2]
    --     local num_text = self:findText(self.FATTER_TAB[k].text_name)
    --     if num_text then
    --         num_text.text = Language:getTextByKey("fb_str_0007", num1).."%    "..Language:getTextByKey("fb_str_0008", num2).."%"
    --     end
    --     if self.FATTER_TAB[k].lv == 2 then
    --         self:setTextByLanKey("card_2_des3", Language:getTextByKey("fb_str_0007", num1).."%    "..Language:getTextByKey("fb_str_0008", num2).."%")
    --     end
	-- end
end

function M:getBuffNum(id)
    if id < 71 and id > 74 then
        return nil
    end
    local data = ConfigManager:getBattleCommonValueById(id)
    local new_tab = {}
    for k, v in pairs(data) do
        new_tab[k] = v * 100
    end
    return new_tab
end

function M:destroy()
    GameUtil:resetFormationDes()
    M.super.destroy(self)
end

return M
