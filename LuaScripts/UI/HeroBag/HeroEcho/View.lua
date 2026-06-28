local M = class("HeroEchoView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroEcho"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "echo_text_001")
    self:setTextByLanKey("total_btn_text", "echo_text_001")
    self:setTextByLanKey("upgrade_btn_text", "echo_text_004")
    self:setTextByLanKey("attr_title_text", "echo_text_007")
    self:setTextByLanKey("skill_title_text", "echo_text_008")
    self.m_cost_hero = self:findGameObject("cost_hero")
    self.m_cost_hero_self = self:findGameObject("cost_hero_self")
    self.m_cost_item = self:findGameObject("cost_item")
    self.m_echo_btn_img = self:findImage("upgrade_btn")
    self.m_gray_material = self:findImage("gray_img").material
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 52})
    self:refreshUI()
end

function M:refreshUI()
    self:updateListScroll()
    local hero_left_sp = self:findGameObject("hero_left_sp")
    self:refreshHeroSpine(hero_left_sp, self.m_model.m_hero_id)
    self:refreshEcho()
end

function M:updateListScroll()
    local data = self.m_model.m_heroes
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                --local transform = cell_object.transform
                self:updateHeroData(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", cell_data)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:updateHeroData(obj, data)
    local hero, cfg = UserDataManager.hero_data:getHeroDataById(data)
    local hero_id = cfg.id
    GameUtil:updateItemElement(obj,{RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_id, 1}, false, false)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"light_img", data == self.m_model.m_hero_oid)
end

function M:refreshHeroSpine(object, hero_id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
    local hero_skin_cfg = UserDataManager.hero_data:getHeroDefaultSkinCfgByHeroCfg(cfg)
    local spine = hero_skin_cfg.hero_spine or "hero_0001_SkeletonData"
    GameUtil:updateSpineLoadSet(object, "RoleSpine/"..spine, "idle", 0, true)
    --[[
    if self.m_model.m_hero_id and self.m_model.m_hero_id > 0 then
        self:setObjectVisible("hero_left_sp",true)
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_hero_id)
        local hero_skin_cfg = UserDataManager.hero_data:getHeroDefaultSkinCfgByHeroCfg(cfg)
        local spine = hero_skin_cfg.hero_spine or "hero_0001_SkeletonData"
        local hero_left_sp = self:findGameObject("hero_left_sp")
        GameUtil:updateSpineLoadSet(hero_left_sp, "RoleSpine/"..spine, "idle", 0, true)
        --local hero_right_sp = self:findGameObject("hero_right_sp")
        --GameUtil:updateSpineLoadSet(hero_right_sp, "RoleSpine/"..spine, "idle", 0, true)
    else
        self:setObjectVisible("hero_left_sp",false)
        --self:setObjectVisible("hero_right_sp",false)
    end
    ]]--
end

function M:refreshEcho()
    local hero, cfg = self.m_model:getHero(self.m_model.m_hero_oid)
    local echo_lv = hero.resonance_lv or 0
    --当前侠客共鸣等级
    self:setTextByLanKey("hero_echo_level_text", "echo_text_003", echo_lv)
    --共鸣斋等级(总共鸣等级)
    self:setTextByLanKey("total_echo_level_text", "echo_text_005", self.m_model.m_total_level)
    --属性
    local attrs = self.m_model:getEchoAttrs()
    self:refreshAttrs(attrs, echo_lv <= 0)
    --技能
    local params = self.m_model:getEchoSkillCfg()
    self:setObjectVisible("skill1", false)
    self:setObjectVisible("skill2", false)
    for i, v in pairs(params) do
        self:refreshSkill(v, echo_lv)
    end
    --消耗
    local cost = self.m_model:getEchoCost()
    self:setEchoBtnState(true)
    self.m_cost_hero_self:SetActive(false)
    self.m_cost_hero:SetActive(false)
    self.m_cost_item:SetActive(false)
    local hero_count = 0
    if type(cost) == "number" then
    --if cost == nil then
        self:setObjectVisible("upgrade_btn",false)
        local cfg = self.m_model:getEchoCostEvo(cost)
        local hero_right_sp = self:findGameObject("hero_right_sp")
        self:refreshHeroSpine(hero_right_sp, cfg.id)
        --self:setEchoBtnState(false)--满级
    else
        self:setObjectVisible("upgrade_btn",true)
        for i, v in pairs(cost) do
            if v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS or v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
                local cfg = self.m_model:getEchoCostEvo(v[2])
                local heroes = UserDataManager.hero_data:getHeroIdsByCid(cfg.id, cfg.evo)
                local user_num = heroes and #heroes or 0
                local object = hero_count == 0 and self.m_cost_hero or self.m_cost_hero_self
                hero_count = hero_count + 1
                self:refreshCost(object, v, user_num)
                --右侧spine，配置上约定，消耗的第一个为道具，第二个为右侧spine的侠客
                if hero_count == 1 then
                    local hero_right_sp = self:findGameObject("hero_right_sp")
                    self:refreshHeroSpine(hero_right_sp, cfg.id)
                end
            elseif v[1] == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                self:refreshCost(self.m_cost_item, v)
            end
        end
    end
end

function M:refreshAttrs(cur_attrs, is_gray)
    local attrs = UserDataManager:newAppendAttrs(cur_attrs)
    local gray = is_gray == true and 0 or 1
    local data = {}
    for i, v in pairs(attrs) do
        table.insert(data, { i, v, gray })
    end
    if self.m_attrs_scroll == nil then
        local list_scroll = self:findGameObject("attrs_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local cp = UserDataManager:getNewAttrsNameByAttrId(cell_data[1])
                local transform = cell_object.transform
                local attr_name_text = UIUtil.setText(transform, cp, "attr_name_text")
                local attr_value_text = nil
                -- 四舍五入保留小数点后一位
                local attr_value = cell_data[2] or 0
                attr_value = math.floor(attr_value * 100 + 0.5) / 100
                if GameUtil:newAttrTransition(cell_data[1]) == true then
                    attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value) .. "%", "attr_value_text")
                else
                    attr_value_text = UIUtil.setText(transform, GameUtil:formatNum(attr_value), "attr_value_text")
                end
                --local attr_value_text_trans = UIUtil.findRectTransform(attr_value_text)
                --UIUtil.setLocalPosition(attr_value_text_trans, attr_name_text.preferredWidth + 20)
                if cell_data[3] == 0 then
                    --attr_name_text.color = Color.New(1,1,1, 0.6)
                    attr_value_text.color = Color.New(1,1,1, 0.6)
                else
                    --attr_name_text.color = Color.New(1,1,1, 1)
                    attr_value_text.color = Color.New(1,1,1, 1)
                end
            end
            --click_func = function(index, cell_object, cell_data, click_object, click_name)
            --    self:updateMsg("select_hero", cell_data)
            --end
        }
        self.m_attrs_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_attrs_scroll:reloadData(data, true)
    end
end

function M:refreshSkill(param, echo_lv)
    local index = param.index
    local lv = param.lv
    local object = self:findGameObject("skill" .. index)
    if object == nil then
        return
    end
    object:SetActive(true)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local icon_img = LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", param.icon, "skill_icon")
    local desc = ""
    if echo_lv < lv then
        desc = Language:getTextByKey(param.name) .. Language:getTextByKey("echo_text_006", lv) .. "\n" .. Language:getTextByKey(param.des)
        icon_img.material = self.m_gray_material
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", true)
    else
        desc = Language:getTextByKey(param.name) .. "\n" ..Language:getTextByKey(param.des)
        icon_img.material = nil
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
    end
    local desc_text = LuaBehaviourUtil.setText(luaBehaviour,"desc_text", desc)
    --  添加监听
    --[[local params = {skill_id = skillID}
    local skill_detail = LuaBehaviourUtil.findGameObject(luaBehaviour,"icon_img")
    local function btnClick2(trans, params)
        params.click_obj = trans
        self:updateMsg("skill_detail", params)
    end
    UIUtil.setButtonClick(skill_detail.transform, btnClick2, params)]]--
end

function M:refreshCost(object, cost, user_num)
    object:SetActive(true)
    GameUtil:updateItemElement(object, cost, true, true, nil)
    local Item_LuaBehaviour = UIUtil.findLuaBehaviour(object)
    local count_text = Item_LuaBehaviour:FindText("count_text")
    local item_img = Item_LuaBehaviour:FindImage("item_img")
    local quality_img = Item_LuaBehaviour:FindImage("quality_img")
    local itemData = RewardUtil:getProcessRewardData(cost)
    if user_num then
        itemData.user_num = user_num
    end
    if itemData.user_num >= itemData.data_num then
        count_text.color = Color.New(1,1,1)
        item_img.material = nil
        quality_img.material = nil
    else
        count_text.color = Color.New(1,0,0)
        item_img.material = self.m_gray_material
        quality_img.material = self.m_gray_material
        self:setEchoBtnState(false)
    end
end

function M:setEchoBtnState(is_can)
    if is_can == true then
        self.m_echo_btn_img.material = nil
    else
        self.m_echo_btn_img.material = self.m_gray_material
    end
    self.m_model.m_is_can_echo = is_can
end

function M:playEffect()
    self:setObjectVisible("UI_HeroBag_HeroEcho_jieyuan", false)
    self:setObjectVisible("UI_HeroBag_HeroEcho_jieyuan", true)
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M