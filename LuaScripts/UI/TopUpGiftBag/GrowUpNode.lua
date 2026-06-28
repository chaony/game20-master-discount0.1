local M = class("GrowUpNode", LikeOO.OOUIbase)
--成长礼包
M.m_uiName = "OperateActivity/GrowUpNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self.m_content_panel = self:findGameObject("parent_obj")
    self.gray_img = self:findImage("gray_img")
    self:setTextByLanKey("time_down_text", "new_str_0919")
end

function M:switchInit(url, url_data, id, callback, is_update)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] then
            return
        end
        self:refreshUI()
    end
    self.open_id = url_data
    self.id = id
    self.is_update = is_update
    self.m_model:initData(url, callFunc)
end

function M:switchUI(data, id)
    self.open_id = data or 0
    self.id = id or 0
    self:refreshUI()
end


function M:refreshUI()
    if self.m_model.m_hero_gift_data == nil or self.id == nil then
        return
    end
    self.m_hero_gift_data = self.m_model.m_hero_gift_data
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_hero_gift_actives, self.id)
    local cur_active = self.m_model:getActiveData(self.m_model.m_hero_gift_actives)
    if self.id == nil then
        self.id = cur_active.id
    end
    self.m_control:updateTime()
    self.version = 1
    if self.id then
        local active_tab = ConfigManager:getCfgByName("active_recharge")
        local active_cfg = active_tab[self.id]
        self.version = active_cfg.version
    end
    self.hero_show, self.gift_list = self.m_model:get_grow_up_cfg(self.version)
    if self.hero_show == nil then
        return
    end
    local max_data = UserDataManager:getHeroMaxEvo(self.hero_show.hero_id)
    if max_data then
        self.max_evo = max_data.max_evo or 0
    else
        self.max_evo = 0
    end
    self:createLoopScroll(self.gift_list)
    self:setSpine(self.hero_show.hero_id)
    if self.m_scroll_view then
        if self.is_update and self.is_update == true then
            local pos = self.m_scroll_view:getContentOffset()
            if pos then
                self.m_scroll_view:setContentOffset(pos)
            end
        else
            local index = self.m_model:getGrowUpCanGetReward(self.version, self.max_evo)
            self.m_scroll_view:moveToCellIndex(index)
        end
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll(gift_list)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = gift_list,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self:update_Gift(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                    self:updateMsg("buy_sdk_update")
                    return
                end
                local buy_free, pay_num = self.m_model:getGrowUpRewardData(self.version, cell_data.id)
                if self.max_evo >= cell_data.quality then
                    if click_name == "free_btn" and buy_free == false then
                        self:updateMsg("get_hero_gift", {version = self.version, id = cell_data.id })
                    elseif click_name == "pay_btn" and cell_data.time - pay_num > 0 then    
                        self:updateMsg("buy", cell_data.charge_id)
                    end
                else
                    local reward_data = RewardUtil:getProcessRewardData({101, self.hero_show.hero_id,1})
                    local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cell_data.quality]
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0100", reward_data.name, Language:getTextByKey(farm_data.name)), delay_close = 2})
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(gift_list, true)
    end 
end

function M:update_Gift(index, cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local free_node = luaBehaviour:FindGameObject("free_items")
        local pay_items = luaBehaviour:FindGameObject("pay_items")
        local buy_free = false
        local buy_pay = false
        local buy_free, pay_num = self.m_model:getGrowUpRewardData(self.version, cell_data.id)
        buy_pay = pay_num >= cell_data.time and true or false
        local heroNode = luaBehaviour:FindGameObject("HeroNode")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", GameUtil:getMoneyTypeNum(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", GameUtil:getMoneyTypeNum(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0278")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0278")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "quota_text", "gf_str_0073", cell_data.time - pay_num)
        local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cell_data.quality]
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_star_text", "gf_str_0074", Language:getTextByKey(farm_data.name))
        local hero_data = RewardUtil:getProcessRewardData({101,self.hero_show.hero_id,1})
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img_mask", farm_data.hero_star > 0) -- 遮罩的角
        hero_data.quality = cell_data.quality
        CommonUIUtil:updateHeroElementByData(heroNode, hero_data)
        UIUtil.destroyAllChild(free_node.transform)
        UIUtil.destroyAllChild(pay_items.transform)
        GameUtil:createRewards(free_node.transform, cell_data.free_reward, true, true)
        GameUtil:createRewards(pay_items.transform, cell_data.charge_reward, true, true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_light", buy_pay == true )
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_dark", buy_pay == false )
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "suo_img", self.max_evo < cell_data.quality )
        if buy_free == true then
            local free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_bukedianj", "active_ui")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0080")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0080")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", true )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", false )
            local free_btn = UIUtil.findButton(free_img.transform)
            free_btn.interactable = false
        else 
            local free_img =  nil
            if self.max_evo < cell_data.quality then
                free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_bukedianj", "active_ui")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", true )
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", false )
            else
                free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_kedianji", "active_ui")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", false )
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", true )
            end
            if free_img then
                local free_btn = UIUtil.findButton(free_img.transform)
                free_btn.interactable = true
            end
        end 
        if buy_pay == true then
            local pay_img = LuaBehaviourUtil.setImg(luaBehaviour, "pay_btn", "a_yxczlb_btn_bukedianj", "active_ui")
            local pay_btn = UIUtil.findButton(pay_img.transform)
            pay_btn.interactable = false
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", "new_str_0080")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", "new_str_0080")
        else 
            local pay_img = LuaBehaviourUtil.setImg(luaBehaviour, "pay_btn", "a_yxczlb_btn_kedianji", "active_ui")
            local pay_btn = UIUtil.findButton(pay_img.transform)
            pay_btn.interactable = true
        end 
    end
end

function M:onButtonClick(obj, name)
    if name == "grow_check_btn" then
        local reward_data = RewardUtil:getProcessRewardData({101, self.hero_show.hero_id,1})
        static_rootControl:openView("Pops.HeroLookInfo", {hero_id = self.hero_show.hero_id, is_new = false})
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:setSpine(hero_data)
    local reward_data = RewardUtil:getProcessRewardData({101, hero_data,1})
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
            local play_img = self:findGameObject("hero_spine")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
            local race_data = GlobalConfig.TYPE_HERO_RACE[reward_data.race]
            self:setImg(race_data.race_icon, ResourceUtil:getLanAtlas(), "race_img")
            self:setObjectVisible("race_img", true)
            self:setTextByLanKey("hero_name", cfg.class)
            self:setTextByLanKey("hero_name2", cfg.name)
            self:setObjectVisible("grow_hero_name", true)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M
