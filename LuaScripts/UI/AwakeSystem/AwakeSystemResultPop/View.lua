---
---

local M = class("AwakeSystemResultPopView", LikeOO.OOPopBase)

M.m_uiName = "AwakeSystem/AwakeSystemResultPop"  -- prefab name
M.m_size_type = 2
M.m_iphoneXAdapter = true

local title_text_img = { "a_hd_dxl_yhcg_bt", "a_hd_dxl_dxsb_bt", "a_hd_dxl_dxcg_bt" }

local cur_level_color = Color(243 / 255, 240 / 255, 227 / 255)
local next_level_color = Color(228 / 255, 198 / 255, 141 / 255)
local change_color = Color(130 / 255, 239 / 255, 109 / 255)

function M:onEnter()
    self:initCfg()
    self.m_collect_attrs_node = self:findGameObject("collect_attrs_node")
    self.m_attr_node = self:findGameObject("attr_node")
    self.m_wear_attrs_node = self:findGameObject("wear_attrs_node")
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
    self:refreshAttr()
    self:setHeroInfo()
    local id = self.m_model.m_result + self.m_model.m_mode
    local result_img = title_text_img[id]  or id[1]
    local image_name = self:findImage("tips_img")
    GameUtil:updateResourcesImg(image_name,"Texture/zh_cn/"..result_img)
end

function M:initCfg()
    self.m_awaken_fly_cfg = ConfigManager:getCfgByName("awaken_fly")  --羽化阶段的配置
    self.m_awaken_god_cfg = ConfigManager:getCfgByName("awaken_god")  --登仙阶段的配置
end

function M:setHeroInfo()
    local spine_name = ""
    local hero_data, cfg = self.m_model:getHeroData(self.m_model.m_currentHeroIndex)
    if hero_data then
        local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, cfg)
        if shin_data_cfg and next(shin_data_cfg) then
            spine_name = shin_data_cfg.hero_spine
        elseif cfg then
            spine_name = cfg.hero_spine
        end
        local Img_bg = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(Img_bg, "RoleSpine/" .. spine_name, "idle", 0, true)
        local class_str = Language:getTextByKey(cfg.class)
        local name_str = Language:getTextByKey(cfg.name)
        self:setTextByLanKey("hero_name", name_str)
        self:setTextByLanKey("hero_name2", class_str)
        local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
        self:setImg(race, ResourceUtil:getLanAtlas(), "hero_race")
        --local frame_data = GlobalConfig.QUALITY_FRAME[cfg.max_evo]
        self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui", "hero_evo")
    end
end

function M:refreshAttr()
    self:setObjectVisible("fail_text", false)
    local hero_data, cfg = self.m_model:getHeroData()
    local hero_id = hero_data.id
    local index = self.m_model.m_mode
    self:setObjectVisible("next_state_name_text", false)
    self:setTextByLanKey("next_state_name_text", "awake_system_text_0029")
    self:setObjectVisible("skill_node", false)
    if index == 1 then
        --羽化阶段
        local cur_fly_cfg = self.m_awaken_fly_cfg[hero_id]
        local cur_fly_level = self.m_model.m_fly_heros[tostring(hero_id)]
        if cur_fly_cfg and cur_fly_level then
            local cur_attrs = cur_fly_cfg[cur_fly_level.lv].attr
            local cur_name = cur_fly_cfg[cur_fly_level.lv].name
            local next_level = cur_fly_cfg[cur_fly_level.lv].next
            local cur_text = self:setTextByLanKey("cur_state_name_text", cur_name)
            local next_attrs = next_level ~= 0 and cur_fly_cfg[next_level].attr or {}
            local next_name = next_level ~= 0 and cur_fly_cfg[next_level].name or ""
            local next_text = self:setTextByLanKey("next_state_name_text", next_name)
            cur_text.color = cur_level_color
            next_text.color = next_level_color
            self:setObjectVisible("next_state_name_text", next_level ~= 0)
            self:updateLoopScroll(cur_attrs, self.m_collect_attrs_node, self.m_attr_node,true) -- 当前阶段
            self:updateLoopScroll(next_attrs, self.m_wear_attrs_node, self.m_attr_node,false) -- 下一阶段
        end
    elseif index == 2 then
        --登仙阶段
        --返回当前的渡劫配置
        local cur_fly_cfg = {}
        cur_fly_cfg = self.m_awaken_god_cfg[hero_id]
        local cur_fly_level = self.m_model.m_god_god_heros[tostring(hero_id)]
        if cur_fly_cfg and cur_fly_level then
            local change_attr = {}
            if self.m_model.m_result == 1then
                local next_table = {}
                for k1,v1 in pairs(cur_fly_cfg) do
                    next_table[v1.next] = k1
                end
                if next_table[cur_fly_level.lv] then  -- 那么就是新阶段的属性  需要对比
                    local last_level = next_table[cur_fly_level.lv]
                    local last_cfg = cur_fly_cfg[last_level]
                    local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
                    local last_attr = last_cfg.attr
                    local cur_attr = cur_cfg.attr
                    for k2,v2 in pairs(cur_attr) do  -- 每一个新的属性 去旧的里面对比有没有变化
                        local attr_id = v2[1]
                        for k3,v3 in pairs(last_attr) do
                            if attr_id == v3[1] then --匹配到了
                                if v2[2] > v3[2] then --大
                                    change_attr[attr_id] = true
                                end
                            end
                        end
                    end
                else  --说明此时是一阶
                    local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
                    local cur_attr = cur_cfg.attr
                    for k2,v2 in pairs(cur_attr) do  --
                        local attr_id = v2[1]
                        change_attr[attr_id] = true
                    end
                end
            end
            
            local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
            local cur_attrs = cur_cfg.attr
            local cur_name = cur_cfg.name
            local skill_id = cur_cfg.skill[1] or 0
            local cur_text = self:setTextByLanKey("cur_state_name_text", cur_name)
            self:updateLoopScroll(cur_attrs, self.m_collect_attrs_node, self.m_attr_node, true,change_attr) -- 当前阶段
            local id = self.m_model.m_result + self.m_model.m_mode
            self:setObjectVisible("fail_text",id == 2)
            local show_nums = cur_cfg.fail_rate * 100
            local show_str = tostring(show_nums) .. "%"
            self:setTextByLanKey("fail_text","awake_system_text_0064",show_str)
            if skill_id ~= 0 then
                self.m_model.m_select_id = skill_id
                local skill = GameUtil:getSkill(skill_id)
                local temp_name = Language:getTextByKey(skill.name)
                local temp_list = string.split(temp_name, '(')
                self:setTextByLanKey("skill_name", temp_list[1] and temp_list[1] or skill.name)
                --self:setTextByLanKey("skill_desc", skill.des)
                self:setObjectVisible("num_di_bg", false)
                self:setObjectVisible("skill_cn_img", false)
                local skill_img = self:findGameObject("skill1_img")
                UIUtil.setImg(skill_img, skill.icon, "skill_icon")
                self:setObjectVisible("skill_node", true)
                self:setObjectVisible("skill_desc", false)
            end
        end
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(cur_attrs, parentNode, itemNode, cur_flag,change_attr)
    parentNode:SetActive(false)
    local attrs = UserDataManager:newAppendAttrs(cur_attrs)
    local data = {}
    for i, v in pairs(attrs) do
        table.insert(data, { i, v })
    end
    UIUtil.destroyAllChild(parentNode.transform)
    for k, cell_data in ipairs(data) do
        local cell_object = GameUtil:instanceObject(itemNode, parentNode.transform)
        cell_object:SetActive(true)
        local transform = cell_object.transform
        local attr_name_text = nil
        local attr_value_text = nil
        local cp = UserDataManager:getNewAttrsNameByAttrId(cell_data[1])
        attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
        -- 四舍五入保留小数点后一位
        local attr_value = cell_data[2] or 0
        attr_value = math.floor(attr_value * 10 + 0.5) / 10
        if GameUtil:newAttrTransition(cell_data[1]) == true then
            attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value) .. "%", "attr_value_text")
        else
            attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "attr_value_text")
        end
        local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
        UIUtil.setTextColor(transform, cur_flag and cur_level_color or next_level_color, "attr_name_text")
        UIUtil.setTextColor(transform, cur_flag and cur_level_color or next_level_color, "attr_value_text")
        if change_attr and change_attr[cell_data[1]] then
            UIUtil.setTextColor(transform, change_color, "attr_value_text")
        end
        UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
    end
    parentNode:SetActive(true)
end

function M:destroy()
    M.super.destroy(self)
end

return M
