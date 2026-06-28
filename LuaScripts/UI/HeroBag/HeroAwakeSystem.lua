local M = class("HeroAwakeSystem", LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroAwakeSystem"

function M:onEnter()
    self:initCfg()
    self.star_start_hui_naterial = self:findImage("star_img_hui").material
    self.m_collect_attrs_node = self:findGameObject("collect_attrs_node")
    self.m_attr_node = self:findGameObject("attr_node")
    self:setTextByLanKey("goto_destiny_star_btn_text", "awake_system_text_0047")
    self:refreshUI()

end

function M:initCfg()
    self.m_awaken_fly_cfg = ConfigManager:getCfgByName("awaken_fly")  --羽化阶段的配置
    self.m_awaken_god_cfg = ConfigManager:getCfgByName("awaken_god")  --登仙阶段的配置
    self.skill_detail = ConfigManager:getCfgByName("skill_detail")  --
    self.m_awaken_cfg = ConfigManager:getCfgByName("awaken")
end

function M:refreshUI()
    self:refreshHeadNode()
end

function M:refreshHeadNode()
    local node = self:findGameObject("hero_node")
    local data1, cfg = self.m_model:getSelectHeroData(self.m_model.m_selected_id)
    local hero_id = data1.id
    local itemData = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_id, 1, self.m_model.m_currentHeroIndex })
    GameUtil:updateItemElementByData(node, itemData)
    GameUtil:updateHeroInfo(node, itemData)
    self:setTextByLanKey("hero_shili_text", cfg.name)
    self:setObjectVisible("skill_list", false)
    self:setObjectVisible("cur_skill_name_img", false)
    self:setObjectVisible("goto_awaken_system_btn", self.m_model.m_mode ~= 3)
    local index = self.m_model.m_current_mode
    if index == 1 then
        --羽化阶段
        local cur_fly_cfg = self.m_awaken_fly_cfg[hero_id]
        local cur_fly_level = self.m_model.m_fly_heros[tostring(hero_id)]
        if cur_fly_cfg and cur_fly_level then
            local cur_attrs = cur_fly_cfg[cur_fly_level.lv].attr
            local cur_name = cur_fly_cfg[cur_fly_level.lv].name
            local cur_text = self:setTextByLanKey("cur_state_name_text", cur_name)
            self:updateLoopScroll(cur_attrs, self.m_collect_attrs_node, self.m_attr_node, true) -- 当前阶段
        end
    elseif index == 2 then
        --登仙阶段
        --返回当前的渡劫配置
        local cur_fly_cfg = {}
        cur_fly_cfg = self.m_awaken_god_cfg[hero_id]
        local cur_fly_level = self.m_model.m_god_god_heros[tostring(hero_id)]
        if cur_fly_cfg and cur_fly_level then
            local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
            local cur_attrs = cur_cfg.attr
            local cur_name = cur_cfg.name
            local cur_god_skill = self.m_model.m_replace_skill[tostring(hero_id)] or {}
            local skill_nums = table.nums(cur_god_skill)
            local cur_text = self:setTextByLanKey("cur_state_name_text", cur_name)
            self:updateLoopScroll(cur_attrs, self.m_collect_attrs_node, self.m_attr_node, true) -- 当前阶段
            if skill_nums ~= 0 then
                self:setObjectVisible("skill_list", true)
                self:setObjectVisible("cur_skill_name_img", true)
                self:updateSkill()
            end
        end
    end
end

--[[	
	属性列表
]]
function M:updateLoopScroll(cur_attrs, parentNode, itemNode, cur_flag)
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
        attr_value = math.floor(attr_value * 100 + 0.5) / 100
        if GameUtil:newAttrTransition(cell_data[1]) == true then
            attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value) .. "%", "attr_value_text")
        else
            attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "attr_value_text")
        end
        local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
        UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
    end
    parentNode:SetActive(true)
end

function M:updateSkill()
    --skill_id replaced
    local cfg_awaken_skill = "awaken_skill"
    local cfg_replace_skill = "replace_skill"
    local data1, cfg = self.m_model:getSelectHeroData(self.m_model.m_selected_id)
    local cur_cfg = self.m_awaken_cfg[data1.id]
    local cur_hero_skill = self.m_model:getCurSKill()
    for i = 1, 2 do
        local cell_object = self:findGameObject("skill" .. i)
        if not IsNull(cell_object) then
            local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
            local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. i]
            local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. i]
            local can_replace_skill_id = 0
            local cur_skill = cur_hero_skill[tostring(cur_replace_skill_pos)]
            if cur_skill and cur_skill.skill_id then
                can_replace_skill_id = cur_skill.skill_id
                --设置ui
                local be_replace_skill_list = self.m_model:getTargetSkillData(can_replace_skill_id,cur_awaken_skill_cfg) --被替换的那组id
                if #be_replace_skill_list == 4 then
                    local skill = GameUtil:getSkill(can_replace_skill_id)
                    local temp_name = Language:getTextByKey(skill.name)
                    local temp_list = string.split(temp_name,'(')
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"desc_text","awake_system_text_0050",temp_list[1] and temp_list[1] or skill.name)
                end
                local skill = GameUtil:getSkill(can_replace_skill_id)
                LuaBehaviourUtil.setImg(luaBehaviour, "skill1_img_star", skill.icon, "skill_icon")
                --local replace_img = luaBehaviour:FindImage("replace_skill_btn")
                --replace_img.material = cur_skill.replaced == 1 and self.star_start_hui_naterial or nil
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"replace_skill_text",cur_skill.replaced ==1 and "awake_system_text_0049" or "awake_system_text_0048" )
                --  添加监听
                local params = {skill_idx = cur_replace_skill_pos,skill_id = can_replace_skill_id}
                local replace_btn = LuaBehaviourUtil.findGameObject(luaBehaviour,"replace_skill_btn")
                replace_btn:SetActive(self.m_model.m_mode ~= 3)
                local skill_detail = LuaBehaviourUtil.findGameObject(luaBehaviour,"skill1_img_star")
                local function btnClick1(trans, params)
                        self:updateMsg("replace_btn", params)
                end
                UIUtil.setButtonClick(replace_btn.transform, btnClick1, params)
                local function btnClick2(trans, params)
                    params.click_obj = trans
                    self:updateMsg("skill_detail", params)
                end
                UIUtil.setButtonClick(skill_detail.transform, btnClick2, params)
                cell_object:SetActive(true)
            else
                cell_object:SetActive(false)
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M

