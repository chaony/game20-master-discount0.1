--- 英雄
local M = class("FriendNode",LikeOO.OOUIbase)

M.m_uiName = "Friend/MercenaryPanel"

local __TAB_BTN_NODE = {
    {btn = "martial_all_toggle", name = "martial_all_text", icon = "zhiye_img"},
    {btn = "martial_1_toggle", name = "martial_1_text", icon = "zhiye_img1"},
    {btn = "martial_2_toggle", name = "martial_2_text", icon = "zhiye_img2"},
    {btn = "martial_3_toggle", name = "martial_3_text", icon = "zhiye_img3"},
    {btn = "martial_4_toggle", name = "martial_4_text", icon = "zhiye_img4"},
    {btn = "martial_6_toggle", name = "martial_6_text", icon = "zhiye_img6"},
    {btn = "martial_5_toggle", name = "martial_5_text", icon = "zhiye_img5"},
    {btn = "martial_7_toggle", name = "martial_7_text", icon = "zhiye_img7"},
}
function M:onCreate()
    self.m_gray_img = self:findImage("gray_img")
    self.RaceToggle = self:findGameObject("race_toggle_bg")
    self.RaceToggle:SetActive(true)
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        local lan_text = "new_str_0065"
        if i > 1 then
            lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
        end
        self:setTextByLanKey(v.name, lan_text)
        UIUtil.addToggleListener(tog_btn, function(is_on, data)
            if is_on then
                self:updateMsg("martial_tab",data)
                local lan_text = data > 1 and GlobalConfig.TYPE_HERO_RACE[i-1].name or "new_str_0065"
                self:setTextByLanKey("race_toggle_btn_text", lan_text)
            end
        end, i, self.m_uiName)
    end
    self.RaceToggle:SetActive(false)
    self.m_race_toggle_flag = false
end

function M:onEnter()  
    self:setTextByLanKey("mercenary_control_btn_text", "mercenary_control_btn_tex")
    self:setText("list_title_text", Language:getTextByKey("friend_str_0006"))
    self:setText("list_tips_text", Language:getTextByKey("friend_str_0007"))
    self:setTextByLanKey("no_mercenary_text", "friend_str_0038")
    self.mercenary_oid = {}
    self.mercenary_hero_panel = {}
    --for i=1,3 do
    --    self.mercenary_hero_panel[i] = self:findGameObject("rol_" .. i)
    --end
    self.mercenary_control_btn_red = self:findGameObject("mercenary_control_btn_red")
    self.mercenary_control_btn_red:SetActive(false)
    self:refreshToggleProfessionIcon()
end


function M:refreshUI()
    self:refreshMercenaryHeroPanel()
    self:updateFriendScroll()
    self:refreshRedPoint()
    self:refreshToggleProfessionIcon()
end

function M:refreshToggleProfessionIcon()
    for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn)
        local icon = self:findImage(v.icon)
        if tog_btn.isOn then
            icon.material = nil
        else
            icon.material = self.m_gray_img.material
        end
    end
end

function M:onButtonClick(obj, name)
    local full_btn_name = self.m_uiName .. "/" .. name
    GameUtil:playBtnSound(full_btn_name)
    if name == "mercenary_control_btn" then
        self.m_control:openView("Friend.MercenaryHandlePop")
    elseif name == "mercenary_help_btn" then
        local params = {}
        params.title = "tid#mercenary1"
        params.content = "tid#mercenary2"
        self.m_control:openView("Pops.CommonHelpPop", params)
    elseif name == "mercenary_hero_1_btn" then
        self:showMercenary(1)
    elseif name == "mercenary_hero_2_btn" then
        self:showMercenary(2)
    elseif name == "mercenary_hero_3_btn" then
        self:showMercenary(3)
    elseif name == "race_toggle_btn" then
        self:setToggleActive(not self.m_race_toggle_flag)
    elseif name == "race_toggle_bg" then
        self:setToggleActive(false)
    end
end

function M:showMercenary(index)
    local oid = self.mercenary_oid[index]
    if oid then
        local mercenary = self.m_model:getMercenaryHero()
        local user = self.m_model:getUserData()
        local hero_data = mercenary.hero[oid]
        local user_data = user[oid]
        local player_data = {}
        player_data.heros = {[oid] = hero_data}
        player_data.user = user_data
        self.m_control:openView("HeroBag", {player_data = player_data, mode = 3, oid = oid, apostle = true})
    end
end

function M:cellBtnHandle(name, data)
    if name == "list_hero" then
        audio:SendEvtUI("UI_Hero_Click")
        self.m_control:openView("Friend.MercenaryApplayPop",data)
    end
end

function M:refreshMercenaryHeroPanel()
    local data = self.m_model:getMercenaryHero()
    if data.hero and next(data.hero) then
        if not self.m_apostle_return_tick then
            local function tick()
                local server_time = UserDataManager:getServerTime()
                local time = data.etime - server_time
                if time > 0 then
                    self:setTextByLanKey("return_times", "friend_str_0037", GameUtil:formatTimeBySecond(time))
                else
                    self.m_control:removeTimer(self.m_apostle_return_tick)
                    self.m_apostle_return_tick = nil
                    self:updateMsg("freshData")
                end
            end 
            tick()
            self.m_apostle_return_tick = self.m_control:setTimer(1,tick)
        end
    else
        if self.m_apostle_return_tick then
            self.m_control:removeTimer(self.m_apostle_return_tick)
            self.m_apostle_return_tick = nil
        end
        self:setText("return_times", Language:getTextByKey("friend_str_0005"))
    end
    self.mercenary_oid = {}
    local i = 1
    for k,v in pairs(data.hero or {}) do
        self.mercenary_oid[i] = k
        --local panel = self.mercenary_hero_panel[i]
        --UIUtil.destroyAllChild(panel.transform)
        --local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
        --local prefab_name = hero_cfg["prefab"]
        --local name_path = string.split(prefab_name,"/")
        --local obj = ResourceUtil:LoadRole3d(prefab_name)
        --obj.transform.position = Vector3.zero
        --local helper = obj:GetComponent("LuaTransformHelper")
		--helper:SetAnimator(true);
        --obj.transform:SetParent(panel.transform, false)

        --local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[hero_cfg.evo]
        --if quality_item and quality_item.hero_3d_base then
        --    local evo_effect = ResourceUtil:LoadCommonEffect(quality_item.hero_3d_base, nil)
        --    evo_effect.transform.position = Vector3.zero
        --    evo_effect.transform:SetParent(panel.transform, false)
        --    evo_effect.transform.localScale = Vector3.New(1, 1, 1)
        --end
        local rol_spine = self:findGameObject("rol_spine_" .. i)
        rol_spine:SetActive(false)
        local MercenaryHeroNode = self:findGameObject("MercenaryHeroNode" .. i)
        local luaBehaviour = MercenaryHeroNode:GetComponent("LuaBehaviour")
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(v.id)
        --local sg = rol_spine:GetComponent("SkeletonGraphic")
        --local spine = hero_cfg.hero_spine or "hero_0001_SkeletonData"
        --local hehe = ResourceUtil:GetSk(spine, "rolespine_"..string.lower(spine));
        --sg.skeletonDataAsset = hehe
        --sg:Initialize(true)
        local MainHeroNodeCell = LuaBehaviourUtil.setObjectVisible(luaBehaviour,"MainHeroNodeCell", true)
        GameUtil:updateHeroContentByData(MainHeroNodeCell, v, hero_cfg)
        
        local user_data = self.m_model.m_mercenary_data.user_data[k]
        local user_name = user_data.name
        if user_name == "" then
            user_name = Language:getTextByKey("new_str_0141") 
        end
        self:setText("mercenary" .. i .. "_name_text", user_name)
        self:setObjectVisible("name_bg" .. i, true)
        self:setObjectVisible("kong_" .. i .. "_text", false)
        i = i+1
    end

    for i=i, 3 do
        --local panel = self.mercenary_hero_panel[i]
        --UIUtil.destroyAllChild(panel.transform)

        --local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[1]
        --if quality_item and quality_item.hero_3d_base then
        --    local evo_effect = ResourceUtil:LoadCommonEffect(quality_item.hero_3d_base, nil)
        --    evo_effect.transform:SetParent(panel.transform, false)
        --    evo_effect.transform.localScale = Vector3.New(1, 1, 1)
        --end
        
        local rol_spine = self:findGameObject("rol_spine_" .. i)
        rol_spine:SetActive(false)

        local MercenaryHeroNode = self:findGameObject("MercenaryHeroNode" .. i)
        local luaBehaviour = MercenaryHeroNode:GetComponent("LuaBehaviour")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"MainHeroNodeCell", false)
        self:setText("kong_" .. i .. "_text", Language:getTextByKey("friend_str_0008"))
        self:setObjectVisible("kong_" .. i .. "_text", true)
        self:setObjectVisible("name_bg" .. i, false)
        --self:setObjectVisible("no_img_" .. i, true)
    end
end

function M:updateFriendScroll()
    local data = self.m_model.m_mercenary_hero
    self:setObjectVisible("no_mercenary_text", #data <= 0)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("heros_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 7,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:cellBtnHandle("list_hero", cell_data)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:setCellHander(obj, id, data)
    local hero = {RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, quality = data.evo, fate = data.fate}
    CommonUIUtil:updateHeroElement(obj, hero)
    --GameUtil:updateItemElement(obj, hero)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj) -- obj:GetComponent("LuaBehaviour")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    apostle_applay_img:SetActive(data.apply_flag)
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    lv_text:SetActive(false)
end

function M:refreshRedPoint()
    local red_flag = RedPointUtil:hasRedPointById(28)
    self.mercenary_control_btn_red:SetActive(red_flag)
end

function M:setToggleActive(flag)
    self.m_race_toggle_flag = flag
    self.RaceToggle:SetActive(flag)
end

function M:destroy()
    if self.m_apostle_return_tick then
        self.m_control:removeTimer(self.m_apostle_return_tick)
        self.m_apostle_return_tick = nil
    end
    M.super.destroy(self)
end
return M