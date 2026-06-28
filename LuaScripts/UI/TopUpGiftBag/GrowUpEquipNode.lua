local M = class("GrowUpEquipNode", LikeOO.OOUIbase)
--神兵成长礼包
M.m_uiName = "OperateActivity/GrowUpEquipNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self.gray_img = self:findImage("gray_img")
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
    if self.m_scroll_view then
        if self.is_update and self.is_update == true then
            local pos = self.m_scroll_view:getContentOffset()
            if pos then
                self.m_scroll_view:setContentOffset(pos)
            end
        else
            local index = self.m_model:getEquipGrowUpCanGetReward(self.version)
            self.m_scroll_view:moveToCellIndex(index)
        end
    end
end


function M:refreshUI()
    if self.m_model.m_equip_gift_data == nil or self.id == nil then
        return
    end
    self.m_equip_gift_data = self.m_model.m_equip_gift_data
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_equip_gift_actives, self.id)
    local cur_active = self.m_model:getActiveData(self.m_model.m_equip_gift_actives)
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
    self.equip_show, self.gift_list = self.m_model:get_equip_grow_up_cfg(self.version)
    self:createLoopScroll(self.gift_list)
    self:setEequp()
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
                local buy_free, pay_num = self.m_model:geEquiptGrowUpRewardData(self.version, cell_data.id)
                local hv_num = self.m_model:checkEquipCanGet(cell_data.quality, cell_data.num)
                if hv_num == true then
                    if click_name == "free_btn" and buy_free == false then
                        self:updateMsg("get_equip_gift", {version = self.version, id = cell_data.id })
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
        local buy_free = false --免费礼包是否已购买
        local buy_pay = false --付费礼包是否已购买
        local buy_free, pay_num = self.m_model:geEquiptGrowUpRewardData(self.version, cell_data.id)
        buy_pay = pay_num >= cell_data.time and true or false
        local ItemNode = luaBehaviour:FindGameObject("ItemNode")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_light", GameUtil:getMoneyTypeNum(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pay_btn_text_dark", GameUtil:getMoneyTypeNum(cell_data.price))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", "new_str_0278")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_dark", "new_str_0278")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "quota_text", "gf_str_0073", cell_data.time - pay_num)
        local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cell_data.quality]
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_star_text",  cell_data.des)
        local equip_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, 0,1})
        equip_data.icon_name = self.equip_show.equip_icon
        equip_data.quality = cell_data.quality
        equip_data.race = 0
        GameUtil:updateItemElementByData(ItemNode, equip_data, false, false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img_mask", farm_data.hero_star > 0) -- 遮罩的角
        UIUtil.destroyAllChild(free_node.transform)
        UIUtil.destroyAllChild(pay_items.transform)
        GameUtil:createRewards(free_node.transform, cell_data.free_reward, true, true)
        GameUtil:createRewards(pay_items.transform, cell_data.charge_reward, true, true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_light", buy_pay == true )
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pay_btn_text_dark", buy_pay == false )
        local hv_num = self.m_model:checkEquipCanGet(cell_data.quality, cell_data.num)
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

--设置装备
function M:setEequp()
    local index = 1
    self.up_timer = self.m_control:setTimer(10, function ()
        local yu_num = index%3
        local cur_id = self.equip_show.equip_id[yu_num + 1] or 120101
        local cfg = UserDataManager.equip_data:getEquipConfigByCid(cur_id)
        self:setTextByLanKey("equip_name_text", cfg.name)
        self:creatEquipObj(cfg)
        index = index + 1
    end)
    local cur_id = self.equip_show.equip_id[index] or 120101
    local cfg = UserDataManager.equip_data:getEquipConfigByCid(cur_id)
    self:setTextByLanKey("equip_name_text", cfg.name)
    self:creatEquipObj(cfg)
end

--创建动效预制体
function M:creatEquipObj(equip_cfg)
    if self.equip_obj and not IsNull(self.equip_obj) then
        UIUtil.destroyObject(self.equip_obj)
    end
    local str_name
    local str = string.split(equip_cfg.picture_effect, "UI_")
    str_name = str[2]
    local fx_ui_effect = ResourceUtil:GetUIEffectItem("EquipAwaken/"..str_name)
    self.equip_obj = fx_ui_effect
    local parent = self:findGameObject("equip_parent_obj")
    if IsNull(parent) then
        return
    end
    fx_ui_effect.transform:SetParent(parent.transform, false)
	if IsNull(fx_ui_effect) then
		return
	end
    local body_size = 1
	if equip_cfg then
		if equip_cfg.body_size == 0 then
			body_size = 1
		else
			body_size = equip_cfg.body_size
		end
	end
	UIUtil.setLocalScale(fx_ui_effect.transform, body_size, body_size, 1)
    self.anim = fx_ui_effect:GetComponent("Animator")
	if self.anim then
        self.anim:CrossFade("03",1)
        self.anim.enabled = false
	end
    local childrens = fx_ui_effect.transform.childCount
    local forn_name = ""
    for i,v in pairs(fx_ui_effect.transform) do
        local img = UIUtil.findImage(fx_ui_effect.transform, v.name)
        if not IsNull(img) then
            img.material = nil
        end
    end
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_H")
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_Hou")
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_Q")
    UIUtil.setObjectVisible(fx_ui_effect.transform, true, "Fx_Qian")
end

function M:destroy()
    if self.up_timer then
        self.m_control:removeTimer(self.up_timer)    
    end
    M.super.destroy(self)
end


return M
