local M = class("SeasonChangeHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/SeasonChangeHeroPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text", lan_text = "new_str_0065",race = 0},
    {btn = "martial_1_toggle", name = "martial_1_text", lan_text = "new_str_0144",race = 1},
    {btn = "martial_2_toggle", name = "martial_2_text", lan_text = "new_str_0145",race = 2},
    {btn = "martial_3_toggle", name = "martial_3_text", lan_text = "new_str_0143",race = 3},
    {btn = "martial_4_toggle", name = "martial_4_text", lan_text = "new_str_0142",race = 4},
    --{btn = "martial_5_toggle", name = "martial_5_text", lan_text = "new_str_0237",race = 6},
    --{btn = "martial_6_toggle", name = "martial_6_text", lan_text = "new_str_0238",race = 5},
    -- {btn = "martial_7_toggle", name = "martial_7_text", lan_text = "new_str_0238",race = 7},
}

function M:onEnter()
    self.hero_cell = self:findGameObject("hero_cell")
    self.hui = self:findImage("hui");
    self.m_use_btn_img = self:findImage("use_btn");
    self.sliderbg = self:findImage("sliderbg");
    self:setTextByLanKey("common_title_text", self.m_model.m_show_data and self.m_model.m_show_data.name or "")
    self:setTextByLanKey("des_text1", "season_change_hero_text_001", self.m_model.m_core_cfg_num)
    self:setTextByLanKey("des_text2", "season_change_hero_text_002", self.m_model.m_normal_cfg_num )
    self:setTextByLanKey("des_text3", "season_change_hero_text_003")
    self:setTextByLanKey("check_btn_text", "season_change_hero_text_005")
    self.m_model.selectType_index = 1;
    --local gacha_hyperbless = self.m_model:getGachaHyperbless()
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        local item = self:findGameObject(v.btn)
        --self:setObjectVisible(v.btn, i <= 4 or (i > 4 and gacha_hyperbless > 0))
        --local lan_text = "new_str_0065"
        self:setObjectVisible(v.btn, true)
        if self.m_model.selectType_index == i then
            UIUtil.setToggleIsOn(item.transform, true)
            UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
        end
        UIUtil.addToggleListener(tog_btn, function(is_on, data)
            if is_on then
                self:updateMsg("tab_btn",{index = data,value = __TAB_BTN_NODE[data]})
                UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
            else
                UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
            end
        end, i, self.m_uiName)
    end
    
    self:initHeroCell("hero_cell")
    self:refreshChangeHero();
    self.race_hero = self.m_model:switchHeroList(0)
    self:refreshUI()
end

function M:setToggleIsOn( index )
    local tab_item = __TAB_BTN_NODE[index]
    if tab_item then
        local tog_btn = self:findToggle(tab_item.btn)
        tog_btn.isOn = true
    end
end

function M:refreshChangeHero()
    --兑换英雄
    local itemData = self.m_model:getTargetHeroData()
    --设置头像到槽位上
    GameUtil:updateItemElementByData(self.hero_cell, itemData)
    local luaBehaviour = UIUtil.findLuaBehaviour(self.hero_cell.transform)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
    self.m_change_hero_img = luaBehaviour:FindImage("item_img")
    if self.m_model:isCanChange() == false then
        self.m_change_hero_img.material = self.hui.material;
    else
        self.m_change_hero_img.material = nil;
    end
end

function M:initHeroCell( cell_name )
    local cell_object = self:findGameObject(cell_name);
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object.transform)
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local stars = luaBehaviour:FindGameObject("stars")
    local lv = luaBehaviour:FindGameObject("lv_bg_img")
    have_panel:SetActive(false);
    lv:SetActive(false);
    stars:SetActive(false);
    no_panel:SetActive(true);
end

function M:refreshUI(keep_offset)
    self:setObjectVisible("yinyang_tips", false)
    self:setObjectVisible("check_select_img", self.m_model.m_is_check)
  
    self:refreshText()
    self:createLoopScroll(keep_offset);
    if self.m_change_hero_img then
        if self.m_model:isCanChange() == false then
            self.m_change_hero_img.material = self.hui.material;
        else
            self.m_change_hero_img.material = nil;
        end
    end
    if self.m_model:isCanChange() == false then
        self.m_use_btn_img.material = self.hui.material;
    else
        self.m_use_btn_img.material = nil;
    end
end

function M:refreshText()
    --season_change_hero_text_008
    local core_nums = math.min(self.m_model.m_core_hero_nums, self.m_model.m_core_cfg_num)
    if core_nums < self.m_model.m_core_cfg_num then
        self:setTextByLanKey("value_text1", "season_change_hero_text_008", core_nums, self.m_model.m_core_cfg_num)
    else
        self:setTextByLanKey("value_text1", core_nums .. "/" .. self.m_model.m_core_cfg_num)
    end
    local normal_nums = self.m_model:getCurNormalNums() --self.m_model.m_normal_hero_nums + self.m_model.m_core_hero_nums
    local total_nums  = self.m_model.m_normal_cfg_num-- + self.m_model.m_core_cfg_num
    if normal_nums < total_nums then
        self:setTextByLanKey("value_text2", "season_change_hero_text_008", normal_nums, total_nums)
    else
        self:setTextByLanKey("value_text2", normal_nums .. "/" .. total_nums)
    end
end

--英雄列表
function M:createLoopScroll(keep_offset)
    local data = self.race_hero;
    local spacing = 0
    if self.m_model.m_type ~= 1 then
        spacing = 40
    end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 4,
            spacing = spacing,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHeroContent(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --self.select_cell_object = cell_object;
                self:updateMsg("select_hero", cell_data)
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, keep_offset)
    end
end

--刷新英雄数据
function M:updateHeroContent(obj, hero_id)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroContent obj error！！！")
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local hero_item_data = self.m_model:getHeroDataById(hero_id)
    if hero_item_data then
        GameUtil:updateItemElementByData(obj, hero_item_data)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
    end
    local has_hero = self.m_model:isSelectHero(hero_id)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", has_hero)
end

--刷新槽位
function M:updateSendList()
    --槽位上的英雄
    self:initHeroCell("hero_cell")
end

function M:destroy()
    M.super.destroy(self)
end

return M