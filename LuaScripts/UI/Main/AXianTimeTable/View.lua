local M = class("AXianTimeTableView",LikeOO.OOPopBase)

M.m_uiName = "Main/AXianTimeTable"
M.m_iphoneXAdapter = true
M.m_size_type = 1

local language_text = "axiantimetable_text1"

local state_data = { 
    {img = "a_axkcb_yeqian01",color = Color(213/255,200/255,174/255)},
    {img = "a_axkcb_yeqian02",color = Color(147/255,144/255,135/255)},
    {img = "a_axkcb_yeqianxuanzhong",color = Color(247/255,243/255,230/255)},
}

local offset_y =  15

function M:onEnter()
    self:setTextByLanKey("title_text", "axiantimetable_text1")
    self:setTextByLanKey("close_title_text", self.m_model.m_active_data.name)
    self:setTextByLanKey("talk_text","axiantimetable_text5")
    self:refreshUI()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})
end

function M:refreshUI()
    self:createLoopCroll()
    self:refreshCourseState(self.m_model.m_select_id)
    self:setImgGray()
    self:setSpine(self.m_model.m_skin_id)
end

function M:setImgGray()
    local img_go = self:findGameObject("completetheall_btn")
    local gray = img_go:GetComponent("GrayToColor")
    local active = self.m_model:getCompletetheAllActive()
    self:setObjectVisible("completetheall_btn",active)
    local flag = self.m_model:getCompletetheAllState()
    gray:SetGray(flag)
end

function M:createLoopCroll()
    self.m_gift_tab = {}
    local data = self.m_model.m_course_data
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("course_loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(index,cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(index)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:refreshCourseState(index)
    local course_name = self.m_model.m_course_data[index].name
    if course_name then
        parent = self:findGameObject("reward_grid")
        local rewards = self.m_model.m_course_data[index].reward
        GameUtil:createRewards(parent.transform, rewards, false, true, nil)
        local cost = self.m_model.m_course_data[index].cost
        local cost_flag = false
        if cost and next(cost) then
            local costitem = RewardUtil:getProcessRewardData(cost[1])
            cost_flag =  costitem.user_num < cost[1][3]
            self:setObjectVisible("consumenode",true)
            self:setTextByLanKey("nums_text","axiantimetable_text4",tonumber(cost[1][3]))
        else
            self:setObjectVisible("consumenode",false)
        end
        
        local complete_img_go = self:findGameObject("complete_btn")
        local complete_img_gray = complete_img_go:GetComponent("GrayToColor")
        
        local state = self.m_model:getCurrentState(index)
        complete_img_gray:SetGray(state ~= 1 or cost_flag)
        local key_text = language_text .. tostring(state)
        self:setTextByLanKey("complete_text",key_text)
    end
end

function M:updateCell(index,cell_obj,cell_data)
    local luaBehaiour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaiour then
        local name_text = luaBehaiour:FindText("course_name_text")
        local lock_img = luaBehaiour:FindImage("lock_img")
        local complete_img = luaBehaiour:FindImage("complete_img")
        complete_img.gameObject:SetActive(false)
        local tab_btn = luaBehaiour:FindButton("course_state_img")
        local state_img
        if cell_data.name then
            name_text.text = cell_data.name
            lock_img.gameObject:SetActive(false)
            tab_btn.interactable = true
            if index == self.m_model.m_select_id then
                self:setText("select_name_text",cell_data.name)
                local transfrom = cell_obj.transform
                local local_pos = transfrom.localPosition
                transfrom.localPosition = Vector3(local_pos.x,local_pos.y+offset_y,local_pos.z)
                LuaBehaviourUtil.setTextColor(luaBehaiour,"course_name_text",state_data[3].color)
                state_img = LuaBehaviourUtil.setImg(luaBehaiour,"course_state_img",state_data[3].img,"main_ui2")
            else
                LuaBehaviourUtil.setTextColor(luaBehaiour,"course_name_text",state_data[1].color)
                state_img = LuaBehaviourUtil.setImg(luaBehaiour,"course_state_img",state_data[1].img,"main_ui2")
            end
        else
            tab_btn.interactable = false
            name_text.text = Language:getTextByKey("axiantimetable_text3")
            lock_img.gameObject:SetActive(true)
            LuaBehaviourUtil.setTextColor(luaBehaiour,"course_name_text",state_data[2].color)
            state_img = LuaBehaviourUtil.setImg(luaBehaiour,"course_state_img",state_data[2].img,"main_ui2")
        end
        state_img:SetNativeSize()
    end
end

function M:setSpine(skin_id)
    local fenghua_record_skin = ConfigManager:getCfgByName("fenghua_record_skin")
    local select_skin_cfg = fenghua_record_skin[skin_id]
    if select_skin_cfg == nil then
        self:setObjectVisible("hero_spine", false)
        return
    end
    self:setObjectVisible("hero_spine", true)
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(skin_id)
    --spine
    local spine_name = select_skin_cfg.spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --info
    local class_str = Language:getTextByKey(hero_cfg.class)
    local name_str = Language:getTextByKey(hero_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    --local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero, hero_cfg.max_evo), "common_ui","hero_evo")
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M