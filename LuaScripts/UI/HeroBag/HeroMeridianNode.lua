---@class HeroMeridianNode:OOUIbase
---@field  m_model HeroBagModel
local M = class("HeroMeridianNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroMeridianNode"

M.SKILL_POS = {
    {pos = {0,-15,0}}
}

function M:onEnter()
    self.gray = self:findImage("gray")
    self:resetGroup()
    self:refreshUI()    
    self:setTextByLanKey("activate_text", "anecdote_select")
    self:setTextByLanKey("intensify_text", "anecdote_001")
    self:setTextByLanKey("addition_title_text", "new_str_0742")
    self:setTextByLanKey("secret_script_title_text", "new_str_0743")
    self:setTextByLanKey("sutra_btn_text", "mystic_str_0065")
    local function callback()
        self:setObjectVisible("skill_content", false)
    end
    self.m_control:setOnceTimer(0.1, callback)
    local function callback()
        self:setObjectVisible("skill_content", true)
    end
    self.m_control:setOnceTimer(0.15, callback)
end

function M:resetGroup()
    self.m_activation_group_cfgs = {}
    self.m_init_group = false
end

function M:refreshUI(data)
    if data ~= nil and data.state == nil then
        self:resetGroup()
    end
    self:setObjectVisible("sutra_btn", self.m_model.m_mode ~= 3)
    if self.m_model.m_mode ~= 3 then
        self:setObjectVisible("meridian_parent", BtnOpenUtil:isBtnOpen(62) == true)
        self:setObjectVisible("meridian_lock", BtnOpenUtil:isBtnOpen(62) == false)
    else
        self:setObjectVisible("meridian_parent", true)
        self:setObjectVisible("meridian_lock", false)
    end
    self:updateMeridianAttrs()
    local h_data, h_cfg = self.m_model:getSelectHeroData()
    local hero_lv = h_data and h_data.lv
    hero_lv = hero_lv or 1
    for i = 1, 5 do
        local mai_eq_btn = self:findGameObject("mystic_eq_btn_" .. i)
        local luaBehaviour = UIUtil.findLuaBehaviour(mai_eq_btn)
        local show_flag = self.m_model:meridianShowByID(i)
        local show_type = self.m_model:meridianShowTypeByID(i) --先天1  绝技2  都可以0
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mystic_eq_btn_" .. i, show_flag == true)
        local open_flag = self.m_model:meridanPosOpenFlagByPos(i)
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", not open_flag)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_xiantian_img", not open_flag)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", open_flag)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mystic_type_name", false)
        local mystic_id = self.m_model:checkMysticEqpForId(i)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", mystic_id ~= nil)
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_bg", false)
        --if open_flag == false then
        --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_xiantian_img", show_type == 1 or show_type == 3 )
        --    -- if show_type == 1 then
        --    --     LuaBehaviourUtil.setImg(luaBehaviour, "lock_xiantian_img", "suo_xiantian", ResourceUtil:getLanAtlas())
        --    -- elseif show_type == 3 then
        --    --     LuaBehaviourUtil.setImg(luaBehaviour, "lock_xiantian_img", "suo_shenpin", ResourceUtil:getLanAtlas())
        --    -- end
        --    if show_type == 1 or show_type == 3 then
        --        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
        --    end
        --end
        if mystic_id ~= nil then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
            local data = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.MYSTIC, mystic_id, 0})
            local equ_img = LuaBehaviourUtil.setImg(luaBehaviour, "equ_img", data.icon_name, data.atlas_name or "item_icon")
            equ_img.gameObject:SetActive(true)
            local itemCfg = data.item_cfg or {}
            local type_meridian_item = GlobalConfig.TYPE_MERIDIAN[itemCfg.type] or {}
            LuaBehaviourUtil.setImg(luaBehaviour, "add_jiao_img", type_meridian_item.pro_icon,  ResourceUtil:getLanAtlas())
            local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
            local frame_name = quality_item.mystic_frame_name
            LuaBehaviourUtil.setImg(luaBehaviour, "bg", frame_name, "equip_icon")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mystic_red_point", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", true)
            if data.item_cfg then
                local  short_name = GlobalConfig.TYPE_MERIDIAN[data.item_cfg.type].short_name
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "mystic_type_name", short_name)
                local  name_color = GlobalConfig.TYPE_MERIDIAN[data.item_cfg.type].name_color
                LuaBehaviourUtil.setTextColor(luaBehaviour,"mystic_type_name",name_color)
            end
            GameUtil:creatEffectForEquip(mai_eq_btn, data)
            local class_meridian = GlobalConfig.CLASS_MERIDIAN[itemCfg.role_type or 0] or 0
            if class_meridian == 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",true)
                LuaBehaviourUtil.setImg(luaBehaviour, "vocation_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
            end

            local mystic_data=self.m_model:getMysticDataById(mystic_id)
            local starGo = luaBehaviour:FindGameObject("stars")
            self:setStarLv(starGo.transform,mystic_data.star)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"vocation_img",false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mystic_type_name", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", false)
            LuaBehaviourUtil.setImg(luaBehaviour, "bg", "a_ui_currency_dj_kong", "equip_icon")
            local equip_ids = self.m_model:getMysticByType(show_type)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mystic_red_point", self.m_model.m_mode ~= 3 and open_flag and hero_lv > 1 and #equip_ids>0)
            local back_effect = luaBehaviour:FindGameObject("back_effect")
            local front_effect = luaBehaviour:FindGameObject("front_effect")

        
            if show_type >= 0 and open_flag == true then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", true)
                if show_type == 1 then
                    LuaBehaviourUtil.setImg(luaBehaviour, "add_jiao_img", "a_lhg_xiantian_weikaiqi", ResourceUtil:getLanAtlas())
                elseif show_type == 2 then
                    LuaBehaviourUtil.setImg(luaBehaviour, "add_jiao_img", "a_lhg_juexue_weikaiqi",  ResourceUtil:getLanAtlas())
                elseif show_type == 3 then
                    LuaBehaviourUtil.setImg(luaBehaviour, "add_jiao_img", "a_lhg_shenpin_weikaiqi",  ResourceUtil:getLanAtlas())
                end
            end
            if back_effect and front_effect then
                UIUtil.destroyAllChild(back_effect.transform)
                UIUtil.destroyAllChild(front_effect.transform)
            end
        end
    end
    local mystics = self.m_model:getHeroMysticData()
    local activation_group=self.m_model:getMysticGroup(mystics)
    --local _, activation_group  = UserDataManager.mystic_data:getMysticGroup(mystics)
    self.m_activation_group = {}
    for i, id in pairs(mystics) do
        self.m_activation_group[tonumber(i)] = activation_group[id]
    end
    local groups_obj = {}
    for i = 1, 5 do
        local activation_group_item = self.m_activation_group[i]
        if activation_group_item then
            local skill_btn = self:setObjectVisible("skill_btn_" .. i, true)
            table.insert(groups_obj, skill_btn)
            self:setObjectVisible("skill_icon_" .. i, true)
            self:setImg(activation_group_item.icon,"skill_icon","skill_icon_" .. i)
            if self.m_init_group then
                if self.m_activation_group_cfgs[i] ~= activation_group_item then
                    if data and data.state == "up" then
                        audio:SendEvtUI("UI_LHG_Gong_Unlock")
                        self:setObjectVisible("UI_HeroBag_JieSuo_00" .. i, true)
                    end
                    self.m_activation_group_cfgs[i] = activation_group_item
                end
            else
                self:setObjectVisible("UI_HeroBag_JieSuo_00" .. i, false)
                self.m_activation_group_cfgs[i] = activation_group_item
            end
        else
            self:setObjectVisible("skill_btn_" .. i, false)
            self:setObjectVisible("UI_HeroBag_JieSuo_00" .. i, false)
            self.m_activation_group_cfgs[i] = nil
        end
    end
    local skill_num = table.nums(self.m_activation_group)
    if self.m_activation_group[5] then
        skill_num = skill_num - 1
    end
    if skill_num == 1 then
        if groups_obj[1] then
            local skill_obj = groups_obj[1]
            UIUtil.setLocalPosition(skill_obj.transform, 0,-15,0)
        end
    elseif skill_num == 2 then
        if groups_obj[1] then
            local skill_obj = groups_obj[1]
            UIUtil.setLocalPosition(skill_obj.transform, -56,-2.6,0)
        end
        if groups_obj[2] then
            local skill_obj = groups_obj[2]
            UIUtil.setLocalPosition(skill_obj.transform, 56,-2.6,0)
        end
    elseif skill_num == 3 then
        if groups_obj[1] then
            local skill_obj = groups_obj[1]
            UIUtil.setLocalPosition(skill_obj.transform, 0,-15,0)
        end
        if groups_obj[2] then
            local skill_obj = groups_obj[2]
            UIUtil.setLocalPosition(skill_obj.transform, -90,27,0)
        end
        if groups_obj[3] then
            local skill_obj = groups_obj[3]
            UIUtil.setLocalPosition(skill_obj.transform, 90,27,0)
        end
    end
    --神技
    if self.m_activation_group[5] then
        self:setObjectVisible("skill_btn_5", true)
    else
        self:setObjectVisible("skill_btn_5", false)
    end
    self.m_init_group = true 
    if table.nums(self.m_activation_group) == 0 then
        self:setObjectVisible("group_1", true)
        self:setObjectVisible("group_icon_1", false)
        self:setObjectVisible("group_name_1", false)
        self:setObjectVisible("group_lock_img_1", true)
        self:setTextByLanKey("group_title_name_1", "new_str_0751")
        local group_lock_text = self:setTextByLanKey("group_lock_text_1", "gf_str_0015")
        group_lock_text.gameObject:SetActive(true)
    end

    EventDispatcher:registerTimeEvent( "hide_ui_herobag_jiesuo_timer", function()
        self:setObjectVisible("UI_HeroBag_JieSuo_001", false)
        self:setObjectVisible("UI_HeroBag_JieSuo_002", false)
        self:setObjectVisible("UI_HeroBag_JieSuo_003", false)
    end, 2, 2)
end


function M:setStarLv(starParentTrans, curStarLv)
    local childCount=starParentTrans.childCount
    local index=0
    local starGo=nil
    for i = 1, childCount do
        starGo=starParentTrans:Find("star_"..i).gameObject
        starGo:SetActive(i<=curStarLv)
    end
end

function M:updateMeridianAttrs()
    local atr_1, atr_2 = self.m_model:getMeridianAttrs()
    self:updateLoopScroll(atr_1, atr_2)
end

--[[	
	属性列表
]]
function M:updateLoopScroll(attrs, next_attrs)
	local tab = {}
    for i, v in pairs(attrs) do
        if next_attrs then
            if next_attrs[i] ~= nil then
                table.insert(tab, {v[1], v[2], next_attrs[i][2]})
            else
                table.insert(tab, {v[1], v[2], 0})     
            end
        else
            table.insert(tab, {v[1], v[2], 0})
        end
    end
    local base_attrs = {}
    for k,v in pairs(tab) do
        if v[1] == 901 or v[1] == 902 or v[1] == 903 then
            table.insert( base_attrs, v)
        end
    end
	local function sortFun(data1, data2)
		return data1[1] < data2[1]
	end
	table.sort(base_attrs, sortFun)
    for k=1,3 do
        local atr_cell = self:findGameObject("atr_cell_"..k)
        self:setProCell(atr_cell, base_attrs[k])
    end

    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("attr_loopscroll")
        local params = {
            show_data = tab,
            one_line_count = 2, -- 行或列的数量
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:setProCell(cell_object, cell_data)
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(tab)
    end
end

function M:setProCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local cp = GameUtil:getAttrsName(GameUtil:getAttrsKey(data[1]))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", cp)
        local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
        local hero_enumeration_item = hero_enumeration[data[1]]
        if hero_enumeration_item.is_percent ~= 0 then
            local attr_value = data[2] * 100 or 0
            local attr_value2 = data[3] * 100 or 0
            attr_value = math.floor(attr_value*10 + 0.5)/10
            attr_value2 = math.floor(attr_value2*10 + 0.5)/10
            local attr_value_text = LuaBehaviourUtil.setText(luaBehaviour, "num_1", "+ "..GameUtil:formatValueToString(attr_value).."%")
            local attr_value2_text = LuaBehaviourUtil.setText(luaBehaviour, "num_2", "+ "..GameUtil:formatValueToString(attr_value2).."%")
        else
            local attr_value = data[2] or 0
            attr_value = math.floor(attr_value + 0.5)
            local attr_value_text = LuaBehaviourUtil.setText(luaBehaviour, "num_1", "+ "..GameUtil:formatValueToString(attr_value))
            local attr_value2 = data[3] or 0
            attr_value2 = math.floor(attr_value2 + 0.5)
            local attr_value2_text = LuaBehaviourUtil.setText(luaBehaviour, "num_2", "+ "..GameUtil:formatValueToString(attr_value2))
            if attr_value2 == 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_2", false)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_2", true)
            end
        end
    end
end

function M:onButtonClick(obj, name)
    if name == "skill_btn_1" then
        self:openMeridianSkillPop(1)
    elseif name == "skill_btn_2" then
        self:openMeridianSkillPop(2)
    elseif name == "skill_btn_3" then
        self:openMeridianSkillPop(3)
    elseif name == "skill_btn_5" then
        self:openMeridianSkillPop(5)
    elseif name == "sutra_btn" then
        QuickOpenFuncUtil:openFunc(28)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:openMeridianSkillPop(index)
    local activation_group_item = self.m_activation_group[index]
    local icon = self:findGameObject("skill_icon_" .. index)
    if not IsNull(icon) then
        local desc = "new_str_0757"
        if activation_group_item and activation_group_item.des then
            desc = Language:getTextByKey(activation_group_item.des).."\n"..Language:getTextByKey(activation_group_item.des_class)
        end
        self.m_control:openView("Pops.MeridianSkillPop", {click_transform = icon.transform, desc = desc })
    end
end

--[[
    排序
]]
function M:sort(pros)
    pros = pros or {}
    local function sortFunc(id_one, id_two)
        local id_1 = self.m_model:getIndexByHeroEnumId(id_one)
        local id_2 = self.m_model:getIndexByHeroEnumId(id_two)
        return id_one[1] < id_two[1]
    end
    table.sort(pros, sortFunc)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("hide_ui_herobag_jiesuo_timer")
    M.super.destroy(self)
end

return M