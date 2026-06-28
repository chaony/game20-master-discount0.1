---@class WishMustPopView:OOPopBase
---@field m_model WishMustPopModel
local M = class("WishMustPopView",LikeOO.OOPopBase)

M.m_uiName = "Pub/WishMustPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
    --{btn = "martial_all_toggle", name = "martial_all_text", lan_text = "new_str_0065",race = 0},
    {btn = "martial_1_toggle", name = "martial_1_text", lan_text = "new_str_0144",race = 1},
    {btn = "martial_2_toggle", name = "martial_2_text", lan_text = "new_str_0145",race = 2},
    {btn = "martial_3_toggle", name = "martial_3_text", lan_text = "new_str_0143",race = 3},
    {btn = "martial_4_toggle", name = "martial_4_text", lan_text = "new_str_0142",race = 4},
    {btn = "martial_5_toggle", name = "martial_5_text", lan_text = "new_str_0237",race = 6},
    {btn = "martial_6_toggle", name = "martial_6_text", lan_text = "new_str_0238",race = 5},
    -- {btn = "martial_7_toggle", name = "martial_7_text", lan_text = "new_str_0238",race = 7},
}

function M:onEnter()
    self.hero_cell = self:findGameObject("hero_cell")
    self.hui = self:findImage("hui");
    self.sliderbg = self:findImage("sliderbg");
    self.zhufu_text = self:findText("zhufu_text");
    self.m_yinyang_tips = self:findText("yinyang_tips");
    self.topTips = self:findText("topTips");
    self.bottomTips = self:findText("bottomTips");
    self.otherTips = self:findText("othersTips");
    self.m_model.selectType_index = 1;
    self:setTextByLanKey("common_title_text", "Pub_str_0034")
    self:setTextByLanKey("set_btn_text", "new_str_0006")
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
    self:refreshZhuFu();
    self.race_hero = self.m_model:switchHeroList(1)
    UserDataManager:updateBlessNeedChange(1)
    self:updateMsg("refreshRedPoint", nil, "Pub")
    self:refreshUI()
end

function M:setToggleIsOn( index )
    local tab_item = __TAB_BTN_NODE[index]
    if tab_item then
        local tog_btn = self:findToggle(tab_item.btn)
        tog_btn.isOn = true
    end
end

function M:updateZhuFuValue( value )
    self.targetSliderValue = value
    self.sliderbg.fillAmount = self.targetSliderValue / self.m_model.maxValue
    self.zhufu_text.text = Language:getTextByKey("new_str_0924",self.targetSliderValue, self.m_model.maxValue)
    if self.targetSliderValue >= self.m_model.maxValue then
        local isBless = self.m_model:hasBless(self.m_model.m_hero_id)
        if isBless == true then
            self:setTextByLanKey("next_bi_text", "Pub_str_0052")
        else
            self:setTextByLanKey("next_bi_text", "new_str_0655")
        end
        self:setObjectVisible("next_bi_text", true)
    else
        self:setObjectVisible("next_bi_text", false)
    end
end

function M:refreshZhuFu()
    --祝福英雄
    local hero_id = self.m_model.m_bless_data.bless_hero
    if hero_id > 0 then
        local itemData = self.m_model:getHeroData(hero_id)
        --设置头像到槽位上
        GameUtil:updateItemElementByData(self.hero_cell, itemData)
        local luaBehaviour = UIUtil.findLuaBehaviour(self.hero_cell.transform)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
    end
    self:updateZhuFuValue( self.m_model.m_bless_data.bless_value )
    self:setTextByLanKey("times_text", "budo_str_005", self.m_model.m_bless_data.max_bless_times - self.m_model.m_bless_data.cur_bless_times)
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

function M:refreshUI()
    local yinyang_index, index = self.m_model:getBlessTimes()
    --当前关卡
    local stage = UserDataManager:getCurStage()
    local stage_com = ConfigManager:getCommonValueById(430);
    local zhufu_time = 0;
    local yinyang_zhufu_times = self.m_model:getYinYangTimes()
    for i, v in pairs(stage_com) do
        if stage > v then
            zhufu_time = zhufu_time + 1
        end
    end
    --已经使用了最大次数
    if index == zhufu_time then
        self:setObjectVisible("next_bi_text", false)
        local luaBehaviour = UIUtil.findLuaBehaviour(self.hero_cell.transform)
        local item_img = luaBehaviour:FindImage("item_img")
        item_img.material = self.hui.material;
    end
    local open_flag,_  = self.m_model:getOpenYinYang()
    self:setObjectVisible("yinyang_tips", open_flag)
    --祝福次数
    self.topTips.text = Language:getTextByKey("Pub_str_0037",  index)
    self.bottomTips.text = Language:getTextByKey("Pub_str_0038")
    self.m_yinyang_tips.text = Language:getTextByKey("Pub_str_0044",  yinyang_index)
    self.otherTips.text = Language:getTextByKey("Pub_str_0046")
    --if zhufu_time < #stage_com then
    --    local config_stage = stage_com[zhufu_time + 1]
    --    if config_stage ~= nil then
    --        local front = math.floor(config_stage/100);
    --        local back = config_stage - front * 100;
    --        local backStr = back..""
    --        if back < 10 then
    --            backStr = "0"..back;
    --        end
    --        local frontStr = front..""
    --        if front < 10 then
    --            frontStr = "0"..front;
    --        end
    --        self.otherTips.text = Language:getTextByKey("Pub_str_0039", frontStr, backStr )
    --    else
    --        self.otherTips.text = ""
    --    end
    --else
    --    self.otherTips.text = ""
    --end
    
    --最大了
    if (not self.m_model.m_is_yinyang and index == #stage_com) or (self.m_model.m_is_yinyang and yinyang_index == yinyang_zhufu_times) then
        self:setObjectVisible("next_bi_text", false)
        local luaBehaviour = UIUtil.findLuaBehaviour(self.hero_cell.transform)
        local item_img = luaBehaviour:FindImage("item_img")
        item_img.material = self.hui.material;
    end
    
    self:createLoopScroll();
end

--英雄列表
function M:createLoopScroll()
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
                self.select_cell_object = cell_object;
                self:updateMsg("select_hero", cell_data)
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

--刷新英雄数据
function M:updateHeroContent(obj, hero_id)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroContent obj error！！！")
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local hero_item_data = self.m_model:getHeroData(hero_id)
    if hero_item_data then
        --self:alterData(ItemNode,itemData)
        GameUtil:updateItemElementByData(obj, hero_item_data)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:isInSlot(hero_id) == true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
    end
    local has_hero = self.m_model:hasHeros(hero_id)
    if has_hero == false then
        local item_img = luaBehaviour:FindImage("item_img")
        item_img.material = self.hui.material;
    else
        local item_img = luaBehaviour:FindImage("item_img")
        item_img.material = nil;
    end
end


--刷新槽位
function M:updateSendList()
    --槽位上的英雄
    local solt_players = self.m_model:getSendSlot()
        --槽位数据
    if solt_players[1] ~= "" then
        local playerid = solt_players[1];
        --找到槽位
        local luaBehaviour = UIUtil.findLuaBehaviour(self.hero_cell.transform)
        local function btns()
            self:updateMsg("check_send_btn", { hero_id = playerid })
            audio:SendEvtUI("Play_UI_HeroSelected")
        end
        luaBehaviour:RegistButtonClick(btns)

        local have_panel = luaBehaviour:FindGameObject("have_panel")
        have_panel:SetActive(true);
        --获取道具人物头像数据
        local itemData = self.m_model:getHeroData(playerid);
        --设置头像到槽位上
        GameUtil:updateItemElementByData(self.hero_cell, itemData)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_bg_img", false)
    else
        self:initHeroCell("hero_cell")
    end
end


function M:alterData(obj, data )
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local item = luaBehaviour:FindGameObject("item_img")--任务名字
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    item:SetActive(true)
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local frame = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.hero_item_frame, "hero_head_ui")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_panel", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "camp_img", true)
    local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
    end
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    quality_up_img:SetActive(frame.is_add == true)
    if frame.is_add == true then
        LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", frame.add_img, "hero_head_ui")
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M