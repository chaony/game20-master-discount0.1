local M = class("CelebrateNewYearView", LikeOO.OOPopBase)
--新春庆典
M.m_uiName = "GiftBag/CelebrateNewYear/CelebrateNewYear"
M.m_iphoneXAdapter = true

M.LOCAL_TAB = {
    {open_id = 262, lua_name = "GiftBag.CelebrateNewYear.NewYearSkipShop",btn_name = "open_btn_1", enter_data = {}}, -- 春意盛装 皮肤
    {open_id = 263, lua_name = "GiftBag.CelebrateNewYear.NewYearGift",btn_name = "open_btn_2",enter_data = {}}, -- 吉派利是-礼包 
    {open_id = 264, lua_name = "GiftBag.CelebrateNewYear.NewYearTeam",btn_name = "open_btn_3",enter_data = {}}, -- 阖家团圆-吃饭
    {open_id = 265, lua_name = "GiftBag.CelebrateNewYear.NewYearLottery",btn_name = "open_btn_4",enter_data = {}}, -- 岁岁平安-罐子
    {open_id = 266, lua_name = "GiftBag.CelebrateNewYear.NewYearDailyShare",btn_name = "open_btn_5",enter_data = {}}, -- 新桃旧符-七登
    {open_id = 267, lua_name = "GiftBag.CelebrateNewYear.NewYearMiNiGame",btn_name = "open_btn_6",enter_data = {}}, -- 闲侠庙会-小游戏
}

function M:onEnter()
    local open_data = self.m_model:getActiveCfgByOpenId(261)
    if open_data then
        self:setTextByLanKey("close_title_text", open_data.name)
    else
        self:setTextByLanKey("close_title_text", "金虎贺岁")    
    end
    for i, v in ipairs(self.LOCAL_TAB) do
        self:setObjectVisible("atv_btn_"..i, false)
    end
    self:refreshUI();
    local zhulin = self:findRectTransform("new_year_sk")
    local bg_scale_w = self.m_view_width/GlobalConfig.BG_UI_DESIGN_WIDTH
    local bg_scale_h = self.m_view_height/GlobalConfig.BG_UI_DESIGN_HEIGHT
    local new_rate = math.max(bg_scale_w , bg_scale_h)
    UIUtil.setLocalScale(zhulin, new_rate, new_rate)
end


function M:setPanelData( open_id, data )
    for i, v in ipairs(self.LOCAL_TAB) do
        if v.open_id == open_id then
            v.enter_data = data;
        end
    end
end


function M:refreshUI()
    --clothes_done 已经购买过的皮肤
    self:setPanelData(262, { data = self.m_model.clothes_done, actives = self.m_model:getActivesByOpenId(262), version = self.m_model.version, open_id = 262 });
    --spring_gifts 春节礼包 [服务器直接给数据]
    self:setPanelData(263, { gift_data = self.m_model.spring_gifts, actives = self.m_model:getActivesByOpenId(263), version = self.m_model.version, day = self.m_model.cur_day, open_id = 263 });
    --dinner_gifts 团圆饭礼包 [服务器直接给数据]
    self:setPanelData(264, { data = self.m_model.dinner_gifts, actives = self.m_model:getActivesByOpenId(264), guid_score = self.m_model.m_guild_score, dinner_done = self.m_model.m_dinner_done, version = self.m_model.version, day = self.m_model.cur_day, open_id = 264 });
    --draw_gifts 碎碎平安礼包 这个礼包需要从配置里读数据 [读取本地表]
    self:setPanelData(265, { data = self.m_model.draw_gifts, msg_data = self.m_model.m_draw_msgs, actives = self.m_model:getActivesByOpenId(265), times = self.m_model.draw_times, open_id = 265, version = self.m_model.version });
    --sign_done 签到奖励 已领取的签到奖励id
    self:setPanelData(266, { data = self.m_model.sign_done, actives = self.m_model:getActivesByOpenId(266), open_id = 266, version = self.m_model.version, cur_day = self.m_model.cur_day });

    self:setPanelData(267, { data = self.m_model.little_games, actives = self.m_model:getActivesByOpenId(267), version = self.m_model.version,key = self.m_model.m_key, open_id = 267 });
    
    for k,v in pairs(self.LOCAL_TAB) do
        local active_cfg = self.m_model:getActiveCfgByOpenId(v.open_id)
        self:setObjectVisible("atv_btn_"..k, true)
        if active_cfg then
            self:setTextByLanKey("atv_btn_text_"..k, string.cutTextForString(Language:getTextByKey(active_cfg.name)))
        end
        local atv_btn_img = self:findImage("atv_btn_"..k)
        local openFlag = self.m_model:isActOpenByOpenId(v.open_id)
        if openFlag then
            atv_btn_img.color = Color.New(1,1,1)
            self:setTextColor("atv_btn_text_"..k,Color.New(243/255,228/255,131/255))
        else
            atv_btn_img.color = Color.New(150/255,150/255,150/255)
            self:setTextColor("atv_btn_text_"..k,Color.New(146/255,137/255,79/255))
        end
    end
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    for k,v in pairs(self.LOCAL_TAB) do
        local red_bl = self.m_model:checkRedPointByOpenId(v.open_id)
        local btn_obj = self:findGameObject("atv_btn_"..k)
        UIUtil.setObjectVisible(btn_obj.transform, red_bl, "red_point_img")
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M
