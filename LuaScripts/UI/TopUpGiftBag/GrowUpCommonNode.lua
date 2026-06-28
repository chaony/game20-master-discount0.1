local M = class("GrowUpCommonNode", LikeOO.OOUIbase)
--多期通用成长礼包
M.m_uiName = "OperateActivity/GrowUpCommonNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self.gray_img = self:findImage("gray_img")
    self.title_img = self:findImage("title_img")
    self.title_img.gameObject:SetActive(false)
end

function M:switchUI(data, id)
    self.open_id = data or 0
    self.id = id or 0
    self:refreshUI()
    if self.m_scroll_view then
        if self.is_update and self.is_update == true then
            local pos = self.m_scroll_view:getContentOffset()
            if pos then
                self.m_scroll_view:setContentOffset(pos)
            end
        else
            local index = self.m_model:getStarGrowUpCanGetReward(self.version)
            self.m_scroll_view:moveToCellIndex(index)
        end
    end
end


function M:refreshUI()
    if self.m_model.m_growth_gift_data == nil or self.id == nil then
        return
    end
    self.m_growth_gift_data = self.m_model.m_growth_gift_data
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_growth_gift_actives, self.id)
    local cur_active = self.m_model:getActiveData(self.m_model.m_growth_gift_actives)
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
    self.item_show, self.gift_list = self.m_model:get_common_grow_up_cfg(self.version)
    self:createLoopScroll(self.gift_list)
    local background1 = self.item_show.background1 or "a_tmhx_tianminghuaxing"
    GameUtil:updateResourcesImg(self.title_img, "Texture/zh_cn/".. background1)
    self:setSpine(self.item_show.spine[1])
    self.title_img.gameObject:SetActive(true)
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
                local buy_free, pay_num = self.m_model:geCommonGrowUpRewardData(self.version, cell_data.id)
                local hv_num = self.m_model:checkCanGetGrowUpReward(cell_data.type, cell_data.quality, cell_data.num)
                if hv_num == true then
                    if click_name == "free_btn" and buy_free == false then
                        self:updateMsg("get_common_grow_up_gift", {version = self.version, id = cell_data.id })
                    elseif click_name == "pay_btn" and cell_data.time - pay_num > 0 then    
                        self:updateMsg("buy", cell_data.charge_id)
                    end
                else
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("gf_str_0137", Language:getTextByKey(cell_data.des)), delay_close = 2})
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
        local buy_pay = false --付费礼包是否已购买
        local buy_free, pay_num = self.m_model:geCommonGrowUpRewardData(self.version, cell_data.id) --免费礼包是否已购买
        buy_pay = pay_num >= cell_data.time and true or false
        local ItemNode = luaBehaviour:FindGameObject("ItemNode")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", GameUtil:getMoneyTypeNum(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", GameUtil:getMoneyTypeNum(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0278")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0278")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "quota_text", "gf_str_0073", cell_data.time - pay_num)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_star_text",  cell_data.des)
        self:createMiddleItemIcon(ItemNode, cell_data.quality, cell_data.type) -- 通过type创建中间的道具
        UIUtil.destroyAllChild(free_node.transform)
        UIUtil.destroyAllChild(pay_items.transform)
        GameUtil:createRewards(free_node.transform, cell_data.free_reward, true, true)
        GameUtil:createRewards(pay_items.transform, cell_data.charge_reward, true, true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_light", buy_pay == true )
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_dark", buy_pay == false )
        local hv_num = self.m_model:checkCanGetGrowUpReward(cell_data.type, cell_data.quality, cell_data.num)
        if buy_free == true then
            --已购买
            local free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_bukedianj", "active_ui")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0080")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0080")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", true )
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", false )
            local free_btn = UIUtil.findButton(free_img.transform)
            free_btn.interactable = false
        else 
            --未购买
            local free_img =  nil
            if hv_num == true then --可购买
                free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_kedianji", "active_ui")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", false )
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", true )
            else --不可购买
                free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", "a_yxczlb_btn_bukedianj", "active_ui")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_light", true )
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "free_btn_text_dark", false )
            end
            if free_img then
                local free_btn = UIUtil.findButton(free_img.transform)
                free_btn.interactable = true
            end
        end 
        if buy_pay == true then
            --已购买
            local pay_img = LuaBehaviourUtil.setImg(luaBehaviour, "pay_btn", "a_yxczlb_btn_bukedianj", "active_ui")
            local pay_btn = UIUtil.findButton(pay_img.transform)
            pay_btn.interactable = false
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", "new_str_0080")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", "new_str_0080")
        else 
            --未购买
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

--- 创建中间的道具icon
function M:createMiddleItemIcon(ItemNode, quality, show_type)
    if show_type == 3 then --xx个x品质的英雄
        local hero_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, 0,1})
        hero_data.icon_name = self.item_show.icon
        hero_data.quality = quality
        hero_data.race = 0
        hero_data.atlas_name = "item_icon"
        GameUtil:updateItemElementByData(ItemNode, hero_data, false, false)
        local luaBehaviour = UIUtil.findLuaBehaviour(ItemNode)
        local camp_img = luaBehaviour:FindGameObject("camp_img")
        camp_img:SetActive(false)
    elseif show_type == 4 then --天命英雄
        local hero_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, 0,1})
        hero_data.icon_name = self.item_show.icon
        hero_data.quality = 24
        hero_data.race = 0
        hero_data.atlas_name = "item_icon"
        GameUtil:updateItemElementByData(ItemNode, hero_data, false, false)
        local luaBehaviour = UIUtil.findLuaBehaviour(ItemNode)
        local camp_img = luaBehaviour:FindGameObject("camp_img")
        camp_img:SetActive(false)
        GameUtil:getFateIcon(ItemNode)
    elseif show_type == 5 then --道具
        local item_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, 0,1})
        item_data.icon_name = self.item_show.icon
        item_data.atlas_name = "item_icon"
        GameUtil:updateItemElementByData(ItemNode, item_data, false, false)
    end
    
end

function M:setSpine(hero_data)
    local reward_data = RewardUtil:getProcessRewardData(hero_data)
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
        end
    end
end

function M:destroy()
    if self.up_timer then
        self.m_control:removeTimer(self.up_timer)    
    end
    M.super.destroy(self)
end


return M
