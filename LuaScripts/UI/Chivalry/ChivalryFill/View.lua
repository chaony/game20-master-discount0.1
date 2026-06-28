local M = class("ChivalryFillView", LikeOO.OOPopBase)

M.m_uiName = "Chivalry/ChivalryFill"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    --local one_cost = self.m_model:getOneCost()
    --local one_item = table.copy(self.m_model:getGachaItem())
    --table.insert(one_item, one_cost)
    --self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {ext_data = one_item})
    self.hui_img_material = self:findImage("hui_img").material
    self.legend_btn_img = self:findImage("legend_btn")
	if self.m_model.m_actives and self.m_model.m_actives.name then
		self:setTextByLanKey("close_title_text", (Language:getTextByKey(self.m_model.m_actives.name)))
    else
        self:setTextByLanKey("close_title_text", "luckyDraw_str_0001")    
	end
    --设置text文本
    self:setTextByLanKey("rank_btn_text", "new_str_0235") --排行
    self:setTextByLanKey("reward_btn_text", "new_str_0224") --奖励
    self:setTextByLanKey("gift_btn_text", "new_str_0732") --礼包
    self:setTextByLanKey("legend_btn_text", "hero_ui_str_0010") --传奇
    self:setTextByLanKey("legend_btn_text_1", "hero_ui_str_0010") --传奇
    self:setTextByLanKey("legend_btn_text_2", "hero_ui_str_0010") --传奇
    self:setTextByLanKey("legend_btn_text_3", "hero_ui_str_0010") --传奇
    self:setTextByLanKey("coujiang_title_text", "chivalry_text_0005") --抽奖记录
    self:setTextByLanKey("fill_title_text", "chivalry_text_0006") --抽奖填充
    self:setTextByLanKey("speed_name_text", "chivalry_text_0009") --全服进度
    self:setTextByLanKey("change_btn_text", "chivalry_text_0010") --兑换商店
    self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
    self:setObjectVisible("active_stude",true)
    self:setObjectVisible("active_show",false)
    self:refreshUI()
    self:refreshstage()
    self:updateTime()
end

-- 刷新UI
function M:refreshUI()
    
    local one_cost = self.m_model:getOneCost()
    local one_cost_data = RewardUtil:getProcessRewardData(one_cost)
    self:setTextByLanKey("patch_num_text", "chivalry_text_0008",one_cost_data.user_num)
    
    self:refreshLeftCountUI()
    self:refreshRedPoint()
    self:updateMsg("update_quest_data")
end

function M:refreshRedPoint()
    local red_bl = RedPointUtil:hasRedPointById(396)
    self:setObjectVisible("change_btn_red_point_img", red_bl == true)
end

function M:refreshLeftCountUI()
    self:setTextByLanKey("left_count", self.m_model:getBigRewardStr())
end

--刷新三个模式入口状态
function M:refreshstage()
    local red_bl = RedPointUtil:hasRedPointById(314)
    for i = 1, 3 do
        self:setObjectVisible("open_img_"..i,i == self.m_model.open_num)
        self:setObjectVisible("no_open_img_"..i,i > self.m_model.open_num)
        self:setObjectVisible("over_img_"..i,i < self.m_model.open_num)
        self:setObjectVisible("legend_btn_"..i,i < self.m_model.open_num)
        self:setObjectVisible("stage_red_point_img_"..i,i == self.m_model.open_num and red_bl == true)
        local stage_text = "activities_str_0007" --已结束
        if i > self.m_model.open_num then
            stage_text = "new_str_0259" --未开启
        elseif i == self.m_model.open_num then
            stage_text = ""
            self.show_time_name = "stage_img_text_"..i
        end
        self:setTextByLanKey("stage_img_text_"..i, stage_text)
    end
end

--刷新时间
function M:updateTime()
    local end_ts = self.m_model:getEndTs()
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
        local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(down_time) --换算剩余时间
        local show_time = ""
        if remain_day > 0 then
            show_time = Language:getTextByKey("three_heroes_five_gallants_text_0013",remain_day,remain_hour,remain_min)
        else
            show_time = Language:getTextByKey("three_heroes_five_gallants_text_0014",remain_hour,remain_min,remain_sec)
        end
        if self.show_time_name then
            self:setTextByLanKey(self.show_time_name, "budoServer_text_0019",show_time) --重置剩余时间
            if self.m_model.show_stage ~= nil and self.m_model.show_stage + 6 == self.m_model.m_data.version then
                self:setTextByLanKey("timer_text", "budoServer_text_0019",show_time) --重置剩余时间
            end
            
        end
	else
		--self:updateMsg(99999)
	end
end

--刷新全服奖励
function M:refreshQuestData(score)
    local slider_value = 0
    if self.m_model.show_stage ~= nil and self.m_model.show_stage + 6 ~= self.m_model.m_data.version then
        slider_value = 1
    end
    local totle_score = self.m_model:getShowContent().score2
    local show_value = (score/totle_score) *100
    slider_value = score/totle_score
    local score_num = string.format("%0.1f",show_value) .. "%"
    if show_value >= 100 then
        score_num = "100%"
        slider_value = 1
    end
    self:setTextByLanKey("speed_num_text", score_num)
    self.m_week_box_reward_slider.value = slider_value
    if slider_value >= 1 then
        self.legend_btn_img.material = nil
    else
        self.legend_btn_img.material = self.hui_img_material
    end
end

--刷新故事详情
function M:refreshStore(show_store_id)
    self:setTextByLanKey("timer_text","activities_str_0007" ) --已结束
    self:setObjectVisible("active_stude",false)
    self:setObjectVisible("active_show",true)
    self.active_datas = self.m_model:getActiveData(show_store_id+6)
    --设置背景和spine
    if self.active_datas then
        local Img_bg = self:findGameObject("bg_img")
        GameUtil:updateResourcesImg(Img_bg,"Texture/chivalry/"..self.active_datas.background)
        self:setTextByLanKey("fill_one_btn_text", self.active_datas.gacha_des)
        self:setTextByLanKey("fill_ten_btn_text", self.active_datas.gacha_des1)
    end
    if not self.show_time_name then
        self:setTextByLanKey("timer_text", "activities_str_0007") --已结束
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M