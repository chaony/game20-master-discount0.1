---@class AwakeSystemMainView:OOPopBase
---@field m_model AwakeSystemMainModel
local M = class("AwakeSystemMainView", LikeOO.OOPopBase)

M.m_uiName = "AwakeSystem/AwakeSystemMain"  -- prefab name
M.m_size_type = 2
M.m_iphoneXAdapter = true

local _TAB_NODE = {
    { id = 1, lua_name = "UI.AwakeSystem.AwakeSystemLevelPop" },
    { id = 2, lua_name = "UI.AwakeSystem.AwakeSystemGodPop" },
}

local cur_level_color = Color(243 / 255, 240 / 255, 227 / 255)
local next_level_color = Color(228 / 255, 198 / 255, 141 / 255)

local gray_color = Color(146 / 255, 146 / 255, 146 / 255)

local attr_dis = 15

function M:onEnter()
    self.parent_obj = self:findGameObject("parent_obj")
    self:setTextByLanKey("close_title_text", "awake_system_text_001")
    self:setTextByLanKey("handbook_text", "awake_system_text_003")
    self:setTextByLanKey("asleep_text", "awake_system_text_004")
    self:setTextByLanKey("smelt_text", "awake_system_text_005")
    self:setTextByLanKey("without_btn_text", "awake_system_text_0065")
    self.m_attr_node = self:findGameObject("attr_node")
    self.m_collect_attrs_node = self:findGameObject("collect_attrs_node")
    self.m_wear_attrs_node = self:findGameObject("wear_attrs_node")
    self.m_final_attrs_node = self:findGameObject("final_attrs_node")
    self.m_attrs_pro_node = self:findGameObject("attrs_pro_normal")
    --self:setObjectVisible("help_btn",false)
    self.hui = self:findImage("hui")
    self:refreshUI()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.refreshByDay})
end

--刷新UI  left_update_flag  是否刷新左侧   fx_flag 是否播放特效
function M:refreshUI(left_update_flag,fx_flag)
    
    self:switchTabNode()
    self:setLockPart()
    self:refreshTabNode(fx_flag)
    if not left_update_flag then
        self:setLeftNode()
        self:setSpine()
    end
end
function M:refreshTabNode(fx_flag)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI(fx_flag)
    end
end

--刷新页面内容
function M:switchTabNode()
    local index = self.m_model.m_current_mode
    self:setObjectVisible("hero_panel", self.m_model.m_currentHeroIndex ~= 0)
    self:setObjectVisible("no_select_img", self.m_model.m_currentHeroIndex == 0)
    self:setObjectVisible("guangxiao_img", false)
    self:showWithoutText()
    self:setCost()
    if index == 0 then
        if self.m_cur_tab_node then
            self.m_cur_tab_node:destroy()
            self.m_cur_tab_node = nil
        end
        self:setObjectVisible("unlock_btn", self.m_model.m_currentHeroIndex ~= 0)
        self:updateHerosLoopScroll(true)
        
    else
        self:setObjectVisible("unlock_btn", false)
        self:setObjectVisible("guangxiao_img",true)
        self:updateHerosLoopScroll(false)
        if self.m_model.m_last_mode then  --如果模式发生了变化
            if self.m_cur_tab_node then
                self.m_cur_tab_node:destroy()
                self.m_cur_tab_node = nil
            end
            local btn_node = self:getTagCfg(index)
            if btn_node and #btn_node.lua_name > 0 then
                local tab_cls = CustomRequire(btn_node.lua_name)
                self.m_cur_tab_node = tab_cls.new(self.m_control, { parent = self.parent_obj })
            end
        end
    end
end

function M:showWithoutText()
    local data = table.copy(self.m_model.m_can_fly_heros)
    local nums = table.nums(data)
    self:setObjectVisible("without_btn_img",nums == 0 and self.m_model.m_currentHeroIndex == 0)
end

--获取列表数据
function M:getTagCfg(id)
    for i, v in ipairs(_TAB_NODE) do
        if v.id == id then
            return v
        end
    end
end

--刷新右侧列表
function M:updateHerosLoopScroll(visable)
    self:setObjectVisible("hero_Img", visable)
    local data = self.m_model.m_can_fly_heros
    if self.m_rightloop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll_node")
        local params = {
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local data1, _ = self.m_model:getSelectHeroData(cell_data)
                    local itemData = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, data1.id, 1, cell_data })
                    GameUtil:updateItemElementByData(cell_object, itemData)
                    GameUtil:updateHeroInfo(cell_object, itemData)
                    if cell_data == self.m_model.m_currentHeroIndex then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", true)
                    else
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", { index = index, data = cell_data })
            end
        }
        self.m_rightloop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rightloop_scroll_view:reloadData(data, true)
    end
end

function M:setSpine()
    local spine_name = ""
    local hero_data, cfg = self.m_model:getSelectHeroData(self.m_model.m_currentHeroIndex)
    if hero_data then
        local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, cfg)
        if shin_data_cfg and next(shin_data_cfg) then
            spine_name = shin_data_cfg.hero_spine
        elseif 	cfg then
            spine_name =  cfg.hero_spine
        end
        local Img_bg = self:findGameObject("people_hero_bg")
        GameUtil:updateSpineLoadSet(Img_bg, "RoleSpine/" .. spine_name, "idle", 0, true)
    end
end

function M:setLeftNode()
    self:setObjectVisible("icon_di_img",self.m_model.m_currentHeroIndex ~= 0)
    self:setObjectVisible("title_scroll_node",self.m_model.m_currentHeroIndex ~= 0)
    self:setObjectVisible("skill_node",false)
    self:setObjectVisible("skill_list",false)
    self:setTextByLanKey("tips_btn_text", "awake_system_text_001")
    self:setObjectVisible("head_id_img",self.m_model.m_currentHeroIndex ~= 0)
    if self.m_model.m_currentHeroIndex ~= 0 then
        local index = self.m_model.m_current_mode
        local node = self:findGameObject("hero_node")
        local data1, cfg = self.m_model:getSelectHeroData(self.m_model.m_currentHeroIndex)
        local hero_id = data1.id
        local itemData = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_id, 1, self.m_model.m_currentHeroIndex })
        GameUtil:updateItemElementByData(node, itemData)
        GameUtil:updateHeroInfo(node, itemData)
        self:setTextByLanKey("state_tips_text", "awake_system_text_0027")
        self:setTextByLanKey("hero_shili_text", cfg.name)
        self:setTextByLanKey("state_name_text", "awake_system_text_0028")     
        if index == 0 then
            self:setObjectVisible("title_scroll_node",false)
            self:updateFirstStage(hero_id)
        elseif index == 1 then  --羽化阶段
            --刷新属性
            local cur_fly_cfg = self.m_model.m_awaken_fly_cfg[hero_id]
            local cur_fly_level = self.m_model.m_fly_heros[tostring(hero_id)]
            if cur_fly_cfg and cur_fly_level then
                local cur_attrs = cur_fly_cfg[cur_fly_level.lv].attr
                local cur_name = cur_fly_cfg[cur_fly_level.lv].name
                local next_level = cur_fly_cfg[cur_fly_level.lv].next
                local next_attrs = {}
                local next_name = ""
                next_attrs = next_level ~= 0 and cur_fly_cfg[next_level].attr or {}
                next_name = next_level ~= 0 and cur_fly_cfg[next_level].name or ""
                if next_level == 0 then   --测试需求  加  加  加！
                    local cur_god_cfg,_ = self.m_model:getCurGodCfg()
                    local next_table = {}
                    local first_level = 0
                    for k1,v1 in pairs(cur_god_cfg) do
                        next_table[v1.next] = true
                    end
                    for k2,v2 in pairs(cur_god_cfg) do
                        if not next_table[k2]  then
                            first_level = k2
                        end
                    end
                    next_attrs =  cur_god_cfg[first_level].attr or {}
                    next_name = cur_god_cfg[first_level].name or {}
                end
                local cur_text = self:setTextByLanKey("cur_state_name_text", cur_name)
                local next_text = self:setTextByLanKey("next_state_name_text", next_name)
                self:setTextByLanKey("tips_btn_text", cur_name)
                self:setTextByLanKey("state_name_text", cur_name)
                cur_text.color = cur_level_color
                next_text.color = next_level_color
                self:setObjectVisible("next_state_name_text",true)
                self:setObjectVisible("cur_state_name_text", true)
                self:updateLoopScroll(cur_attrs, self.m_collect_attrs_node, self.m_attr_node,true) -- 当前阶段
                UIUtil.setVerticalLayoutGroupSpacing(self.m_collect_attrs_node.transform,0)
                UIUtil.setVerticalLayoutGroupSpacing(self.m_attrs_pro_node.transform,0)
                self:updateLoopScroll(next_attrs, self.m_wear_attrs_node, self.m_attr_node, false) -- 下一阶段
                if self.m_cur_tab_node then
                    self.m_cur_tab_node:refreshText(cur_name, next_name)
                end
            end
        elseif index == 2 then --登仙阶段
            self:setObjectVisible("next_state_name_text",false)
            self:setObjectVisible("wear_attrs_node",false)
            --刷新属性
            local cur_fly_cfg,cur_fly_level = self.m_model:getCurGodCfg()
            if cur_fly_cfg and cur_fly_level then
                local cur_cfg = cur_fly_cfg[cur_fly_level.lv]
                local cur_attrs = cur_cfg.attr
                local cur_name = cur_cfg.name
                self.m_model.m_select_id = cur_cfg.skill[1] or 0
                local cur_text = self:setTextByLanKey("cur_state_name_text", cur_name)
                local next_text = self:setTextByLanKey("next_state_name_text","awake_system_text_0029")
                cur_text.color = cur_level_color
                next_text.color = next_level_color
                self:setTextByLanKey("state_name_text", cur_name)
                self:updateLoopScroll(cur_attrs, self.m_collect_attrs_node, self.m_attr_node,true) -- 当前阶段
                UIUtil.setVerticalLayoutGroupSpacing(self.m_collect_attrs_node.transform,attr_dis)
                UIUtil.setVerticalLayoutGroupSpacing(self.m_attrs_pro_node.transform,attr_dis)
                self:setTextByLanKey("tips_btn_text", cur_name)
                if self.m_model.m_select_id == 0 then  --如果当前已经有了，那么去判断是否已经有技能了
                    local cur_hero_skill = self.m_model.m_skills[tostring(hero_id)] or {}
                    for k3,v3 in pairs(cur_hero_skill) do
                        self.m_model.m_select_id = v3.skill_id
                    end
                end
                if self.m_model.m_select_id ~= 0 then
                    local skill = GameUtil:getSkill(self.m_model.m_select_id)
                    local temp_name = Language:getTextByKey(skill.name)
                    local temp_list = string.split(temp_name,'(')
                    self:setTextByLanKey("skill_name", temp_list[1] and temp_list[1] or skill.name )
                    --self:setTextByLanKey("skill_desc", skill.des)
                    self:setObjectVisible("skill_desc", false)
                    self:setObjectVisible("num_di_bg", false)
                    self:setObjectVisible("skill_cn_img", false)
                    local skill_img = self:findGameObject("skill1_img")
                    UIUtil.setImg(skill_img, skill.icon, "skill_icon")
                    self:setObjectVisible("skill_node",true)
                    self:setObjectVisible("next_state_name_text",true)
                end
            end         
        end
    end
end

function M:updateFirstStage(hero_id)
    local cur_hero_fly_cfg = table.copy(self.m_model.m_awaken_fly_cfg[hero_id]) or {}
    local fly_last_level = self.m_model:getLastLevel(cur_hero_fly_cfg)
    local fly_level_cfg = cur_hero_fly_cfg[fly_last_level] or {}
    local fly_level_attr = fly_level_cfg.attr or {}
    local m_awaken_god_cfg = self.m_model:getCurGodCfg()
    local god_last_level = self.m_model:getLastLevel(m_awaken_god_cfg)
    local god_last_cfg = m_awaken_god_cfg[god_last_level] or {}
    local god_last_attr = god_last_cfg.attr or {}
    for k,v in pairs(god_last_attr) do
        table.insert(fly_level_attr,v)
    end
    self:updateLoopScroll(fly_level_attr, self.m_final_attrs_node, self.m_attr_node,false) -- 当前阶段
    self:setObjectVisible("skill_list",true)
    local text = self:setTextByLanKey("final_name_text", "awake_system_text_0061")   --显示当前阶段
    text.color = next_level_color
    self:updateSkill()
end

--[[	
	属性列表
]]
function M:updateLoopScroll(cur_attrs, parentNode, itemNode, cur_flag)
    parentNode:SetActive(false)
    local attrs = UserDataManager:newAppendAttrs(cur_attrs)
    local data = {}
    for i, v in pairs(attrs) do
        table.insert(data, {i, v})
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
        UIUtil.setTextColor(transform, cur_flag and cur_level_color or next_level_color, "attr_name_text")
        UIUtil.setTextColor(transform, cur_flag and cur_level_color or next_level_color, "attr_value_text")
        local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
        UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
    end
    parentNode:SetActive(true)
end

function M:setCost()
    self:setObjectVisible("res_bg",not self.m_model:countCurHeroFly())
    self:setTextByLanKey("unlock_text", self.m_model:countCurHeroFly() and "awake_system_text_0018" or "awake_system_text_002")
    if self.m_model.m_currentHeroIndex ~= 0 then
        local data, cfg = self.m_model:getSelectHeroData(self.m_model.m_currentHeroIndex)
        local cur_cfg = self.m_model.m_awaken_cfg[data.id]
        local consItem = RewardUtil:getProcessRewardData(cur_cfg.cost[1])
        self.cost_img = self:setImg(consItem.icon_name, consItem.atlas_name, "blue_block_img")
        if consItem.user_num < consItem.data_num then
            self:setTextByLanKey("blue_block_text", "equip_str_033", tostring(consItem.user_num), tostring(consItem.data_num))
        else
            self:setTextByLanKey("blue_block_text", tostring(consItem.user_num) .. "/" .. tostring(consItem.data_num))
        end
    end
end

function M:setLockPart()
    local asleep_img = self:findImage("asleep_btn")
    local smelt_img = self:findImage("smelt_btn")
    if self.m_model.m_current_mode == 0 then
        asleep_img.color = gray_color
        smelt_img.color = gray_color
        self:setObjectVisible("asleep_text", false)
        self:setObjectVisible("smelt_text", false)
    else
        local fly_flag = self.m_model:countCurHeroFly()
        local god_flag = self.m_model:countCurHeroGod()
        asleep_img.color = fly_flag and GlobalConfig.COMMON_COLLOR.COMMON_1 or gray_color
        smelt_img.color = god_flag and GlobalConfig.COMMON_COLLOR.COMMON_1 or gray_color
        self:setObjectVisible("asleep_lock_img", not fly_flag)
        self:setObjectVisible("smelt_lock_img", not god_flag)
        self:setObjectVisible("asleep_text", true)
        self:setObjectVisible("smelt_text", true)
    end

end

function M:updateSkill()
    local cfg_awaken_skill = "awaken_skill"
    local cfg_replace_skill = "replace_skill"
    local data1, cfg = self.m_model:getSelectHeroData(self.m_model.m_currentHeroIndex)
    local cur_cfg = self.m_model.m_awaken_cfg[data1.id]
    for i = 1, 2 do
        local cell_object = self:findGameObject("skill" .. i)
        if not IsNull(cell_object) then
            local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
            local cur_awaken_skill_cfg = cur_cfg[cfg_awaken_skill .. i]
            local cur_replace_skill_pos = cur_cfg[cfg_replace_skill .. i]
            local skill = GameUtil:getSkill(cur_awaken_skill_cfg[1][1])
            local temp_name = Language:getTextByKey(skill.name)
            local temp_list = string.split(temp_name, '(')
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "desc_text",temp_list[1] and temp_list[1] or skill.name)
            LuaBehaviourUtil.setImg(luaBehaviour, "skill1_img_star", skill.icon, "skill_icon")
            --添加监听
            local show_skill = {}
            for k,v in ipairs(cur_awaken_skill_cfg) do
                table.insert(show_skill,{v[1],v[3]})
            end
            local params = { skill_idx = cur_replace_skill_pos, skill_id = cur_awaken_skill_cfg[1][1],show_skill = show_skill}
            local skill_detail = LuaBehaviourUtil.findGameObject(luaBehaviour, "skill1_img_star")
            local function btnClick2(trans, params)
                params.click_obj = trans
                self:updateMsg("skill_detail", params)
            end
            UIUtil.setButtonClick(skill_detail.transform, btnClick2, params)
            cell_object:SetActive(true)
        end
    end
end

function M:flyMoveItem(cost,obj)
    self.item = {}
    if cost and next(cost) then
        self.item = GameUtil:createRewards(obj.transform,cost, true, true, nil, 1) 
        self:itemFlyAction()
    end
end

function M:itemFlyAction()
    audio:SendEvtUI("PLAY_UI_GOLD")
    local delay = 0
    local target = self:getTarget()
    local num = 0
    for k, v in pairs(self.item) do
        self:flyMove(v, delay, target)
        delay = delay + 0.03
        for i = 1, 8 do
            if num >= 20 then
                return
            end
            num = num + 1
            local item_obj = U3DUtil:Instantiate(v);
            local random_y = Mathf.Random(10, 200)
            local pos = v.transform.localPosition + Vector3(4 * i, random_y, 0)
            self:flyMove(item_obj, delay, target, pos)
            delay = delay + 0.03
        end
    end
end

function M:getTarget()
    local obj = self:findGameObject("people_hero_bg")
    return obj
end

function M:flyMove( obj, delay, target, pos )
    obj = self:getEffectByReward(obj)
    local reward_fly_ui = self:findGameObject("right_node")
    if IsNull(reward_fly_ui) then
        reward_fly_ui = self.m_ui_obj
    end
    obj.transform:SetParent(reward_fly_ui.transform, true)
    obj.transform.localScale = Vector3(1,1,1)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "double_earn", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quality_img", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text_bg_img", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "count_text", false)
    end
    if pos ~= nil then
        obj.transform.localPosition = pos;
    end
    local tweener = obj.transform:DOScale(0.5, 1)
    CS.wt.framework.TweenTool.Bezier(
            obj,
            target.transform,
            0.6,
            CS.wt.framework.BezierType.Bezier_Level2,
            delay,
            false,
            function()
                tweener:Kill()
                UIUtil.destroyObject(obj)
                static_rootControl:updateMsg("bag_action", nil, "parent")
            end
    )
end

function M:getEffectByReward(parent)
    local random_y = Mathf.Random(0,1000)
    local yanwu = nil
    yanwu = ResourceUtil:GetUIEffectItem("AwakeSystem/UI_AwakeSystem_Tr001",parent)
    return parent
end

function M:ShowFX(time,fx_name)
    local fx_obj = self:findGameObject(fx_name)
    if not IsNull(fx_obj) then
        fx_obj:SetActive(true)
        self.m_control:setOnceTimer(time, function()
            fx_obj:SetActive(false)
        end)
    end
end

--跨天刷新
function M:refreshByDay()
    self:updateMsg("update_data")
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.refreshByDay})
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    M.super.destroy(self)
end

return M
