---@class TotalWorldView:OOPopBase
local M = class("TotalWorldView",LikeOO.OOPopBase)

M.m_uiName = "Main/TotalWorld"
M.m_iphoneXAdapter = true
--key对应open_condition中的id
M.m_btn_lock_img = {
    [168] = {btn_key = "union_war_btn", lock_img_name = "union_war_red_point_img", red_point_img = "union_war_red_point_img", name_key = "union_war_text", name_text = "totol_world_text_2", open = true},--帮会争锋
    --[168] = {btn_key = "union_war2_btn", lock_img_name = "union_war2_red_point_img", red_point_img = "union_war2_red_point_img", name_key = "union_war2_text", name_text = "totol_world_text_5", open = true},--巅峰帮会战
    [234] = {btn_key = "five_race_arena_btn", lock_img_name = "five_race_arena_red_point_img", red_point_img = "five_race_arena_red_point_img", name_key = "five_race_arena_text", name_text = "arena_str_0030", open = true},--五行联赛
    [34] = {btn_key = "high_arena_btn", lock_img_name = "high_arena_red_point_img", red_point_img = "high_arena_red_point_img", name_key = "high_arena_text", name_text = "totol_world_text_3", open = true},--凌云阁
    [180] = {btn_key = "hunt_treasure_btn", lock_img_name = "hunt_treasure_red_point_img", red_point_img = "hunt_treasure_red_point_img", name_key = "hunt_treasure_text", name_text = "totol_world_text_1", open = true},--苗疆觅宝
    [246] = {btn_key = "qi_men_dun_jia_btn", lock_img_name = "qi_men_dun_jia_red_point_img", red_point_img = "qi_men_dun_jia_red_point_img", name_key = "qi_men_dun_jia_text", name_text = "qi_men_dun_jia_str_001", time_update_flag = true, time_node = "qi_men_dun_jia_time_node", time_label_text = "qi_men_dun_jia_time_text", open = true},--奇门遁甲

    [240] = {btn_key = "season_preview_btn", lock_img_name = "season_preview_red_point_img", red_point_img = "season_preview_red_point_img", name_key = "season_preview_text", name_text = "achievement_text13", open = true},--赛季风云
    [193] = {btn_key = "servers_group_btn", lock_img_name = "servers_group_red_point_img", red_point_img = "servers_group_red_point_img", name_key = "servers_group_text", name_text = "totol_world_text_4", open = true},--天下九州
    [22] = {btn_key = "union_btn", lock_img_name = "union_lock_img", red_point_img = "union_red_point_img", name_key = "union_text", name_text = "new_str_0403", open = true},--帮会
}

M.N_COLOR = Color( 184/255, 186/255, 210/255)
M.S_COLOR = Color( 255/255, 233/255, 185/255)

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
        local bg_node = self:findGameObject("bg_node")
        UIUtil.setScale(bg_node.transform, main_rect.height/1280)
    end
    --local new_rate = self.m_control.m_view.m_bg_scale
    --local m_1 = self:findGameObject("bg_img")
    --UIUtil.setLocalScale(m_1.transform, new_rate, new_rate)

    for k,v in pairs(self.m_btn_lock_img) do
        self:setObjectVisible(v.btn_key,v.open)
        self:setText(v.name_key,Language:getTextByKey(v.name_text))
        --self:setText(v.name_key,string.cutTextForString(Language:getTextByKey(v.name_text)))
        if v.open then
            -- self:addTriggerEnter(v.btn_key) 
        end
    end
    self:setTextByLanKey("close_title_text", "new_str_1027")
    self:refreshUI()
    if self.m_model.m_data and self.m_model.m_data.popup then
        self.m_model.m_data.popup = false
        self:popNewSeason()
    end
end

function M:popNewSeason()
    self:setObjectVisible("new_season_img", true)
    audio:SendEvtUI("UI_XSJ_Start")
    self.m_control:setOnceTimer(2, function()
        self:setObjectVisible("new_season_img", false)
    end)
end

function M:refreshUI()
    local OutlineEx = U3DUtil:Get_OutlineEx()
    for k, v in pairs(self.m_btn_lock_img) do
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(k)
        if k > 999 then
            open_flag = true
        end
        local btn_node = self:findGameObject(v.btn_key)
        local c_text = self:findText(v.name_key)
        local icon = UIUtil.findImage(btn_node.transform)
        --local icon = UIUtil.findImage(btn_node.transform, "Image")
        local btn_text = UIUtil.findComponent(btn_node.transform, typeof(OutlineEx), c_text)
        if k == 240 and not open_flag  then
            local open_flag2 = BtnOpenUtil:isBtnOpen(218)
            open_flag = open_flag2 and GameUtil:isSeasonPreviewOpen()
        end
        if k == 234 then
            local race_arena = self.m_model:getAreaData("race_arena")
            open_flag = open_flag and self.m_model:isOpenFiveRace()
        end
        if open_flag == true then
            --back.color = Color.white
            --UIUtil.setImg( icon, "a_xy_mingchenghui_BG", "mystic_ui")
            if c_text then
                c_text.color = self.S_COLOR
            end
        else
            --icon.color = Color.New(152 / 255, 152 / 255, 152 / 255)
            --UIUtil.setImg(icon, "a_xy_mingchenghui_BG2", "mystic_ui")
            if c_text then
                c_text.color = self.N_COLOR
            end
        end
        -- icon:SetNativeSize()
        --UIUtil:setLocalDelta(icon.gameObject.transform, 46,182)
        -- self:setObjectVisible(v.btn_key,open_flag and v.open)
        local red_flag = RedPointUtil:isFuncRedPointById(k)
        self:setObjectVisible(v.red_point_img, false)
        --self:setObjectVisible(v.red_point_img, red_flag == true and open_flag == true)
    end
    self:refreshRedPoint()

    --快速导航
    self:setObjectVisible("guide_btn", true)
end

function M:refreshRedPoint()
    for k, v in pairs(self.m_btn_lock_img) do
        local red_flag = RedPointUtil:isFuncRedPointById(k)
        if k == 234 then
            local race_arena = self.m_model:getAreaData("race_arena")
            red_flag = red_flag and self.m_model:isOpenFiveRace()
        end
        if k == 240 and not red_flag then
            red_flag = RedPointUtil:isFuncRedPointById(218)
        end
        if k == 240 and not red_flag and self.m_model:checkSeasonPreviewOpen() then
            red_flag = RedPointUtil:getCommonGiftRedByOpenId(313, true)
        end
        if k == 240 and not red_flag then
            red_flag = RedPointUtil:hasRedPointById(220)
        end
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

--更新时间标签
function M:updateTime()
    for k, v in pairs(self.m_btn_lock_img) do
        if v.time_update_flag == true then
            local e_tim = self.m_model:getEndTimeByOpenID(k)
            if e_tim then
                local d_time = e_tim - UserDataManager:getServerTime()
                if d_time <= 0 then
                    self:setObjectVisible(v.time_node, false)
                else
                    self:setTextByLanKey(v.time_label_text, Language:getTextByKey("qi_men_dun_jia_str_035", GameUtil:formatTimeBySecond2(d_time, 999)))
                end
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M