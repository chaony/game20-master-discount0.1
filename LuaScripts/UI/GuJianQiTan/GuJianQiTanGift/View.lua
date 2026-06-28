local M = class("GuJianQiTanGiftView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanGift"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
    {btn_key = "toggle_btn_1", lua_name = "", btn_text = "toggle_btn_1_text", text_key = "gu_jian_qi_tan_str_025", red_point = "toggle_red_point_1_img"},
    {btn_key = "toggle_btn_2", lua_name = "", btn_text = "toggle_btn_2_text", text_key = "gu_jian_qi_tan_str_026", red_point = "toggle_red_point_2_img"},
    {btn_key = "toggle_btn_3", lua_name = "", btn_text = "toggle_btn_3_text", text_key = "gu_jian_qi_tan_str_027", red_point = "toggle_red_point_3_img"},
    {btn_key = "toggle_btn_4", lua_name = "", btn_text = "toggle_btn_4_text", text_key = "gu_jian_qi_tan_str_028", red_point = "toggle_red_point_4_img"},
}

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 13})
    RedPointUtil:saveLocalRedPointFreshTime("GuJianQiTanGiftRedDot")
    self.m_gray_image = self:findImage("gray_img")
    self.m_scroll_stay_flag = true
    self.m_toggle_btns = {}
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.gameObject:SetActive(self.m_model:checkToggleOpenStatus(k))
        self.m_toggle_btns[k] = tog_btn
        tog_btn.isOn = k == self.m_model:getSelectedIndex()
        UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
    end
    self:switchTabNode(self.m_model:getSelectedIndex())
    self:setSpine()
    self:setTextByLanKey("close_title_text", "gu_jian_qi_tan_str_004")
    self:refreshUI()
end

function M:refreshUI()
    self:updateLoopScroll()
    self:updateHeroSkinShop()
    self:updateToggleRedPoint()
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self:updateMsg(update_key)
    end
end

function M:switchTabNode(index)
    for k,v in pairs(__TAB_BTN_NODE) do
       self:setObjectVisible("Checkmark_" .. k, k == index)
    end
    self.m_scroll_stay_flag = false
    self:updateLoopScroll()
end

function M:updateToggleRedPoint()
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setObjectVisible(v.red_point, self.m_model:checkToggleRedPoint(k))
    end
end

function M:updateLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getGiftData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data then
                    self:updateMsg("buy_gift", cell_data)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
        self.m_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_scroll_view:reloadData(data, self.m_scroll_stay_flag)
        self.m_scroll_stay_flag = true
    end
    self:updateJianTou()
end

function M:onValueChanged(pos)
    self:updateJianTou()
end

function M:updateCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.cfg
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("cell_title_text")
        name_text.text = Language:getTextByKey(cfg.gift_name)
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278")
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end

        local sort = cfg.price_type or 1
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", sort == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn_text", sort == 2 )
        if sort == 1 then -- 元宝
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cost_num_text", tostring(cfg.price))
        elseif sort == 2 then -- 充值金额
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"buy_btn_text", GameUtil:getMoneyTypeNum(cfg.price))
        else
            Logger.logError(sort, "ship_gift sort is error ")
        end
        
        
        local return_per_text = luaBehaviour:FindText("return_per_text")
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
        local parent = luaBehaviour:FindGameObject("itemParent")
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil)
        -- isCanBuy 展示上一礼包
        local bg_img = luaBehaviour:FindGameObject("cell_bg_image")
        if not (data.status == 1) then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
            GameUtil:updateResourcesImg(bg_img, "Texture/moon_shadow/a_yycs_yilinqulibaochendi")
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", false)
            GameUtil:updateResourcesImg(bg_img, "Texture/gujianqitan/a_gjqt_lbcd")
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            local residueCount = (cfg.time_limit - data.times)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", residueCount)
        end
        
        --置灰
        local buy_img = luaBehaviour:FindImage("cell_bg_image")
        buy_img.material = data.status_paper == 0 and self.m_gray_image.material or nil
        --self:updateJianTou()
        --local color = data.status_paper == 0 and Color(100/255, 100/255, 100/255) or Color(125/255, 40/255, 22/255)
        --LuaBehaviourUtil.setTextColor(luaBehaviour, "buy_btn_text", color)
        
    end
end

function M:updateJianTou()
    local loop_view = self.m_scroll_view
    local loop_view_num = 2
    if loop_view and loop_view.m_line_count > loop_view_num then
        if loop_view:getVerticalNormalizedPosition() < 0.1 then
            self:setObjectVisible("jiantou_bottom_img", false)
        else
            self:setObjectVisible("jiantou_bottom_img", true)
        end
        if loop_view:getVerticalNormalizedPosition() > 0.9 then
            --self:setObjectVisible("jiantou_top_img", false)
        else
            --self:setObjectVisible("jiantou_top_img", true)
        end
    else
        --local show_data = self.m_model:getShowData()
        --if #show_data < 5 then
        --    self:setObjectVisible("jiantou_bottom_img", true)
        --else
        --end
        self:setObjectVisible("jiantou_bottom_img", false)
        --self:setObjectVisible("jiantou_top_img", false)
    end
end


function M:setSpine()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    local reward_data = RewardUtil:getProcessRewardData(hero_skin_cfg.reward[1])
    local skin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, reward_data.item_cfg)
    
    GameUtil:updateSpineLoadSet(self:findGameObject("hero_spine"), "RoleSpine/".. skin_data_cfg.hero_spine, "idle", 0, true)
    if reward_data then
        self:setText("hero_name2", string.cutTextForString(Language:getTextByKey(reward_data.item_cfg.name)))
        local race =  GlobalConfig.TYPE_HERO_RACE[reward_data.item_cfg.race]
        self:setImg(race.race_icon, ResourceUtil:getLanAtlas(), "hero_race")
        self:setObjectVisible("hero_name_con", true)
    else
        self:setObjectVisible("hero_name_con", false)
    end
end

function M:updateHeroSkinShop()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    if hero_skin_cfg then
        self:setTextByLanKey("old_price", GameUtil:getMoneyTypeNum(hero_skin_cfg.price_old))
        self:setTextByLanKey("per_text", hero_skin_cfg.return_per)
        local buy_img = self:findImage("buy_skip_btn")
        local pre_img = self:findImage("pre_img")
        if self.m_model:checkHeroSkinTimesLimited() == false then
            self:setTextByLanKey("buy_skip_btn_text", "lantern_text_0014", GameUtil:switchMoneyType(hero_skin_cfg.price_new))
            buy_img.material = nil
            pre_img.material = nil
            self:setObjectVisible("buy_skip_btn_text", true)
            self:setObjectVisible("buy_skip_get_text", false)
        else
            buy_img.material = self.m_gray_image.material
            pre_img.material = self.m_gray_image.material
            self:setTextByLanKey("buy_skip_btn_text", "gf_str_0048")
            self:setObjectVisible("buy_skip_btn_text", false)
            self:setObjectVisible("buy_skip_get_text", true)
        end
    end
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getTimeEnd()
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time, 999)
		self:setTextByLanKey("text_timer", text)
    elseif down_time == 0 then
        self:updateMsg("refresh_data")
	end
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M