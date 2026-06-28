---@class OutskirtsView:OOPopBase
local M = class("OutskirtsView",LikeOO.OOPopBase)

M.m_uiName = "Main/Outskirts"
M.m_iphoneXAdapter = true
--key对应open_condition中的id
M.m_btn_lock_img = {
    [9999] =  {btn_key = "sect_build_btn", lock_img_name = "sect_build_btn_lock_img", red_point_img = "sect_build_red_point_img", name_key = "sect_build_btn_text", name_text = "new_str_0508", open = false},--门派
    [24] = {btn_key = "arena_btn", lock_img_name = "arena_btn_lock_img", red_point_img = "arena_red_point_img", name_key = "arena_btn_text", name_text = "world_str_002", open = true},--英雄擂     
    --[3] = {btn_key = "treasure_btn", lock_img_name = "treasure_lock_img", red_point_img = "treasure_red_point_img", name_key = "treasure_text", name_text = "world_str_001", open = false},--闯王宝藏
    [169] = {btn_key = "trial_btn", lock_img_name = "trial_lock_img", red_point_img = "trial_red_point_img", name_key = "trial_text", name_text = "world_str_003", open = true},--真武试炼
    [194] = {btn_key = "matrix_btn", lock_img_name = "matrix_lock_img", red_point_img = "matrix_red_point_img", name_key = "matrix_text", name_text = "world_str_004", open = true},--四象阵
    [27] = {btn_key = "xuanshang_btn", lock_img_name = "xs_lock_img", red_point_img = "xuanshang_red_point_img", name_key = "xuanshang_text", name_text = "new_str_0399", open = true},--悬赏
    [104] = {btn_key = "tianji_btn", lock_img_name = "tianji_red_point_img", red_point_img = "tianji_red_point_img", name_key = "tianji_text", name_text = "world_str_009", open = true},--天机楼
    [171] = {btn_key = "biography_btn", lock_img_name = "biography_lock_img", red_point_img = "biography_red_point_img", name_key = "biography_text", name_text = "world_str_013", open = true},--聚宝山 
    [157] = {btn_key = "taoist_btn", lock_img_name = "taoist_lock_img", red_point_img = "taoist_red_point_img", name_key = "taoist_text", name_text = "world_str_012", open = true},--武道场
   	[142] = {btn_key = "compass_btn", lock_img_name = "compass_lock_img", red_point_img = "compass_red_point_img", name_key = "compass_text", name_text = "tid#roulette1", open = true},--原事务里的探宝营地
    [349] = {btn_key = "bazzar_btn", lock_img_name = "bazzar_lock_img", red_point_img = "bazzar_red_point_img", name_key = "bazzar_text", name_text = "pengLai_text_003", open = false},--原蓬莱里的蓬莱集市
    [450] = {btn_key = "xiakedao_btn", lock_img_name = "xiakedao_lock_img", red_point_img = "xiakedao_red_point_img", name_key = "xiakedao_text", name_text = "world_str_020", open = true},--侠客岛
    [475] = {btn_key = "hero_boss_btn", lock_img_name = "hero_boss_lock_img", red_point_img = "hero_boss_red_point_img", name_key = "hero_boss_text", name_text = "hero_boss_text_001", open = true},--天府夺刀
}

M.N_COLOR = Color( 255/255, 253/255, 242/255)
M.S_COLOR = Color( 0/255, 0/255, 0/255)

M.w_COLOR = Color( 255/255, 255/255, 255/255,255/255)
M.b_COLOR = Color( 255/255, 255/255, 255/255,190/255)

function M:onEnter()
    self.m_sliding = false
    self.m_gray_image = self:findImage("gray_image")
    local scroll_view = self:findGameObject("map_scroll")
    self.m_scroll_rect = scroll_view:GetComponent("ScrollRect")
    local main_rect = self.m_control.m_view.m_rt.rect
    --self.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
    if main_rect.height > 1280 then
        --local bg_node = self:findGameObject("bg_node")
        --UIUtil.setScale(bg_node.transform, main_rect.height/1280)
    end
    --local new_rate = self.m_control.m_view.m_bg_scale
    --local m_1 = self:findGameObject("bg_img")
    --UIUtil.setLocalScale(m_1.transform, new_rate, new_rate)

    for k,v in pairs(self.m_btn_lock_img) do
        self:setObjectVisible(v.btn_key,v.open)
        self:setText(v.name_key,string.cutTextForString(Language:getTextByKey(v.name_text)))
        --if v.open then
            -- self:addTriggerEnter(v.btn_key) 
        --end
    end
    self:setTextByLanKey("close_title_text", "new_str_0016")
    self:refreshUI()
end

function M:refreshUI()
    local OutlineEx = U3DUtil:Get_OutlineEx()
    for k, v in pairs(self.m_btn_lock_img) do
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(k)
        if k > 999 then
            open_flag = true
        end
        --侠客岛开启条件，除了open_condition里的关卡，还有时间限制
        if k == 450 and open_flag == true then
            local vsn = UserDataManager.m_hero_isle_vsn
            if vsn == nil or vsn <= 0 then
                open_flag = false
            end
            --[[
            local xiakedao_open_cfg = ConfigManager:getCfgByName("hero_isle_open")
            local cfg = xiakedao_open_cfg[vsn]
            if cfg == nil then
                open_flag = false
            else
                local cur_ts =  UserDataManager:getServerTime()
                local start_ts = GameUtil:stringToTimesTamp(cfg.start_time)
                local end_ts = GameUtil:stringToTimesTamp(cfg.end_time)
                if cur_ts > start_ts and start_ts < end_ts then
                    open_flag = true
                else
                    open_flag = false
                end
            end
            ]]--
        end
        local btn_node = self:findGameObject(v.btn_key)
        local c_text = self:findText(v.name_key)
        local icon = UIUtil.findImage(btn_node.transform, "Image")
        self:setObjectVisible(v.lock_img_name, false)
        --self:setObjectVisible(v.lock_img_name, open_flag == false)
        local btn_text = UIUtil.findComponent(btn_node.transform, typeof(OutlineEx), c_text)
        if open_flag == true then
            icon.material = nil
            if c_text then
                c_text.color = self.N_COLOR
                --c_text.color = self.S_COLOR
            end
            UIUtil.setImg( icon, "a_xy_mingchenghui_BG", "mystic_ui")
            --icon.color = self.b_COLOR
        else
            icon.material = self.m_gray_image.material
            if c_text then
                c_text.color = self.S_COLOR
            end
            UIUtil.setImg( icon, "a_xy_mingchenghui_BG", "mystic_ui")
            --UIUtil.setImg(icon, "a_xy_mingchenghui_BG2", "mystic_ui")
            --icon.color = self.w_COLOR
        end
        icon:SetNativeSize()
        --UIUtil:setLocalDelta(icon.gameObject.transform, 46,182)
        -- self:setObjectVisible(v.btn_key,open_flag and v.open)
        local red_flag = RedPointUtil:isFuncRedPointById(k)
        self:setObjectVisible(v.red_point_img, red_flag == true)
    end

    --快速导航
    self:setObjectVisible("guide_btn", true)
end


function M:refreshRedPoint()
    for k, v in pairs(self.m_btn_lock_img) do
        local red_flag = RedPointUtil:isFuncRedPointById(k)
        self:setObjectVisible(v.red_point_img, red_flag == true)
    end
end

function M:jumpBuild(open_id)
    --local build_cfg = self.m_btn_lock_img[open_id]
    --if build_cfg then
    --    local map_scroll = self:findGameObject("map_scroll")
    --    local scroll_rect = map_scroll:GetComponent("ScrollRect")
    --    local viewport = self:findGameObject("Viewport")
    --    local view_rect = viewport.transform.rect
    --    local build = self:findGameObject(build_cfg.btn_key)
    --    local parent = build.transform.parent
    --    local rect = parent.rect
    --    local posx = build.transform.localPosition.x
    --    local value = 0.5 + posx/(rect.width-view_rect.width*0.5)
    --    scroll_rect.horizontalNormalizedPosition = value
    --end
end

function M:fingerSliding(locat)
    if not self.m_sliding then
        return
    end
    if self.m_control:checkHasChild() then
        return
    end
    if locat == true then
        --self:updateMsg("fingerSliding",2)
    elseif locat == false then
        local chivalry_lock = BtnOpenUtil:isBtnOpen(40)
        if chivalry_lock == true then
            self:updateMsg("fingerSliding",3)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M