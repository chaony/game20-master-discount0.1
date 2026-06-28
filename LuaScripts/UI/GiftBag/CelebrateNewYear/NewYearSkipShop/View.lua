local M = class("NewYearSkipShopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/CelebrateNewYear/NewYearSkipShop"
M.m_iphoneXAdapter = true

function M:onEnter()
    self.left_hero_spine = self:findGameObject("left_hero_spine")
    self.right_hero_spine = self:findGameObject("right_hero_spine")
    self.left_buy_btn = self:findButton("left_buy_btn")
    self.left_buy_btn_img = self:findImage("left_buy_btn")
    self.right_buy_btn = self:findButton("right_buy_btn")
    self.right_buy_btn_img = self:findImage("right_buy_btn")
    self.hui = self:findImage("hui");
    RedPointUtil:saveLocalRedPointFreshTime("new_year_skipday")
    self:refreshUI();
end

function M:refreshUI()
    self:setTextByLanKey("close_title_text", self.m_model:getTitleName());
    --获取所有的皮肤
    local skins = self.m_model:getSkins()
    if #skins >= 2 then
        local left_skin = skins[2]
        if left_skin ~= nil then
            self:showSpineReward(self.left_hero_spine, left_skin.reward[1], "left_hero_txt")
            self:setTextByLanKey("left_btn_text", GameUtil:getMoneyTypeNum(left_skin.price_new));
            self:setTextByLanKey("left_btn_text2", GameUtil:getMoneyTypeNum(left_skin.price_old) );
            self:setTextByLanKey("left_cut_text", left_skin.return_per);
            if left_skin.hasBuy then
                self.left_buy_btn_img.material = self.hui.material;
                self.left_buy_btn.interactable = false;
                UIUtil.setObjectVisible(self.left_buy_btn_img.gameObject.transform, false, "UI_NewYearSkipShop_001")
            end
        end
        local right_skin = skins[1]
        if right_skin ~= nil then
            self:showSpineReward(self.right_hero_spine, right_skin.reward[1], "right_hero_txt")
            self:setTextByLanKey("right_btn_text", GameUtil:getMoneyTypeNum(right_skin.price_new));
            self:setTextByLanKey("right_btn_text2", GameUtil:getMoneyTypeNum(right_skin.price_old));
            self:setTextByLanKey("right_cut_text", right_skin.return_per);
            if right_skin.hasBuy then
                self.right_buy_btn_img.material = self.hui.material;
                self.right_buy_btn.interactable = false;
                UIUtil.setObjectVisible(self.right_buy_btn_img.gameObject.transform, false ,"UI_NewYearSkipShop_001")
            end
        end
    end
end

--显示Spine
function M:showSpineReward( obj, reward, txtName )
    local item_data = RewardUtil:getProcessRewardData(reward)
    if item_data ~= nil and item_data.item_cfg ~= nil then
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(item_data.item_cfg.hero)
        self:setTextByLanKey(txtName, hero_cfg.name);
        GameUtil:updateSpineLoadSet(obj, "RoleSpine/"..item_data.item_cfg.hero_spine, "idle", 0, true)
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = GameUtil:formatTimeBySecond(down_time)
        self:setTextByLanKey("time_text", "activities_str_0012", text)
    else
        self:updateMsg(99999)
    end
end

return M