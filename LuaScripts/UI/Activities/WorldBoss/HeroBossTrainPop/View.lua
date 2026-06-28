local M = class("HeroBossTrainPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/WorldBoss/HeroBossTrainPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("no_rank_list_text", "gf_str_0068")
    self:setTextByLanKey("close_title_text", "gf_str_0078")
    self:setTextByLanKey("buff_add_text", "dragonsword_text_0013")
    self:setTextByLanKey("rank_task_btn_text", "gf_str_0070")
    self:setTextByLanKey("challenge_btn_text", "new_str_0386")
    self:setTextByLanKey("go_text", "new_str_0970")

    self:refreshUI()
    self:updateTime()
end

function M:refreshUI()
    UserDataManager:removeRedDotByKey("hero_train_login")
    self:setTextByLanKey("top_output_text",  GameUtil:formatValueToString(self.m_model:getDamage()))
    self:setSpine()
    self:setInfo()

    for k,v in pairs(self.m_model:getRaces()) do
        local race_cft = GlobalConfig.TYPE_HERO_RACE[v] 
        self:setImg(race_cft.race_icon, ResourceUtil:getLanAtlas(), "buf_img_"..k)
    end
    if self.m_model:getDamage() == 0 then
        self:setObjectVisible("top_output_text", true)
    else
        self:setObjectVisible("top_output_text", true)
    end
    if self.m_model.active_cfg then
        local btn_cfg = BtnOpenUtil:getBtnCfg(self.m_model.active_cfg.open_id)
        self:setTextByLanKey("active_btn_text", btn_cfg.name)
        self:setObjectVisible("to_active_obj", true)
    else
        self:setObjectVisible("to_active_obj", false)    
    end
    self:refreshRedPoint()
    if self.m_model.show_task_cfg then
        self:setObjectVisible("right_bottom_bg", true)
        self:setTextByLanKey("can_get_text", "gf_str_0134",Language:getTextByKey(self.m_model.show_task_cfg.name1))
        self:createLoopScroll(self.m_model.show_task_cfg.reward)
    else
        self:setObjectVisible("right_bottom_bg", false)
    end

    --快速导航
    self:setObjectVisible("guide_btn", true)
end

function M:refreshRedPoint()
    local red_bl = RedPointUtil:hasRedPointById(139)   
    self:setObjectVisible("rank_task_btn_redpoint", red_bl == true)
end

--前三排行榜(已弃用)
function M:updateRanks()
    local ranks = self.m_model:getRanks()
    if #ranks > 0 then
        self:setObjectVisible("rank_list", true)
        self:setObjectVisible("no_rank_list_text", false)
        self:setObjectVisible("check_rank_btn", true)
        for i = 1, 3 do
            if ranks[i] then
                local rank_data = ranks[i]
                self:setTextByLanKey("rank_name_"..i, rank_data.user.name)
                self:setObjectVisible("rank_name_"..i, true)
                self:setObjectVisible("rank_img_"..i, true)
                self:setObjectVisible("rank_bg_img_"..i, true)
            else
                self:setObjectVisible("rank_name_"..i, false)
                self:setObjectVisible("rank_img_"..i, false)
                self:setObjectVisible("rank_bg_img_"..i, false)
            end
        end
    else
        self:setObjectVisible("rank_list", false)
        self:setObjectVisible("no_rank_list_text", true)
        self:setObjectVisible("check_rank_btn", false)
    end
end


--奖励列表
function M:createLoopScroll(data)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                GameUtil:updateItemElement(cell_obj, cell_data,true, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
         
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

--展示英雄spine
function M:setSpine()
    local train_cfg = self.m_model:getHeroTrainCfg()
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(train_cfg.hero_id)
    if cfg then
        --local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = train_cfg.skin_id}, cfg)
        local icon = cfg.hero_spine
        if self.cacheSpineName == icon then
            return
        else
            self.cacheSpineName = icon
        end
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
    end
end

--展示文本提示
function M:setInfo()
    local train_cfg = self.m_model:getHeroTrainCfg()
    local info = Language:getTextByKey(train_cfg.hero_des)
    local info1 = string.sub(info, 1,12)
    local info2 = string.sub(info, 13,24)
    self:setText("info1_text", info1)
    self:setText("info2_text", info2)

end

function M:updateTime()
	if self.m_model.end_ts and self.m_model.end_ts > 0 then
		local time_show = GameUtil:formatTimeBySecond(self.m_model.end_ts - UserDataManager:getServerTime())
        if UserDataManager:getServerTime() > self.m_model.end_ts then
            self:updateMsg("update_hero_train")
            return
        end
		self:setTextByLanKey("down_time", "world_boss_str_0004",time_show)
	end
end

return M