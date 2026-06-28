local M = class("GifHeroTrainNode", LikeOO.OOUIbase)
--侠客试炼
M.m_uiName = "GiftBag/GifHeroTrainNode"

function M:onEnter()
    self:setTextByLanKey("no_rank_list_text", "gf_str_0068")
    self:setTextByLanKey("can_get_text", "gf_str_0069")
    self.version = 0;
    UserDataManager:removeRedDotByKey("hero_train_login")
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self.version = data.version;
        self:refreshUI()
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_hero_train_data == nil then
        return
    end
    if self.m_model.m_hero_train_data and next(self.m_model.m_hero_train_data.actives) == nil then
        return
    end
    self.end_ts = self.m_model:getActiveEndTime(self.m_model.m_hero_train_data.actives)
    self.m_control:updateTime()
    self:setTextByLanKey("top_output_text", "gf_str_0075", GameUtil:formatValueToString(self.m_model.m_hero_train_data.max_damage) or 0)
    self:createLoopScroll()
    self:setSpine()
    self:updateRanks()
    for k,v in pairs(self.m_model.m_hero_train_data.races) do
        local race_cft = GlobalConfig.TYPE_HERO_RACE[v] 
        self:setImg(race_cft.race_icon, ResourceUtil:getLanAtlas(), "buf_img_"..k)
    end
    if self.m_model.m_hero_train_data.max_damage == 0 then
        self:setObjectVisible("rank_bg", false)
        self:setObjectVisible("top_output_text", false)
        self:setObjectVisible("time_text", false)
        self:setObjectVisible("can_get_text", false)
        self:setObjectVisible("reward_des_text", true)
        self:setTextByLanKey("reward_des_text", "gf_str_0099")
    else
        self:setObjectVisible("reward_des_text", false)
        self:setObjectVisible("rank_bg", true)
        self:setObjectVisible("top_output_text", true)
        self:setObjectVisible("time_text", true)
        self:setObjectVisible("can_get_text", true)
    end
    local red_bl = RedPointUtil:isFuncRedPointById(132)   
    self:setObjectVisible("rank_task_btn_redpoint", red_bl == true)
end


--榜单
function M:updateRanks()
    local ranks = self.m_model.m_hero_train_data.ranks
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
            else
                self:setObjectVisible("rank_name_"..i, false)
                self:setObjectVisible("rank_img_"..i, false)
            end
        end
    else
        self:setObjectVisible("rank_list", false)
        self:setObjectVisible("no_rank_list_text", true)
        self:setObjectVisible("check_rank_btn", false)
    end
end


--奖励列表
function M:createLoopScroll()
    local data = self.m_model:getHeroTrainRankReward()
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
        self.m_scroll_view:reloadData(data)
    end
end

--展示英雄spine
function M:setSpine()
    local train_cfg = self.m_model:getHeroTrainCfg()
    local reward_data = RewardUtil:getProcessRewardData({101, train_cfg.hero_id ,1})
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
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
end


function M:onButtonClick(obj, name)
    if name == "challenge_btn" then --挑战
        self:updateMsg("battle")
    elseif name == "rank_task_btn" then --挑战任务
        self:updateMsg("open_hero_task_pop") 
    elseif name == "rank_reward_btn" then --排行奖励
        self:updateMsg("open_hero_train_pop", 2)
    elseif name == "check_rank_btn" then -- 查看榜单  
        self:updateMsg("open_hero_train_pop", 1)
    elseif name == "buf_img_1" then --buff  
        local btns = self:findGameObject(name)
        local train_cfg = self.m_model:getHeroTrainCfg()
        local race_cft = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_train_data.races[1]] 
        local per_num =  GameUtil:formatNum(train_cfg.percent*100)
        local show_str = Language:getTextByKey("gf_str_0079", Language:getTextByKey(race_cft.name),per_num)
        if btns then
            GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = show_str } )
        end
    elseif name == "buf_img_2" then --buff   
        local btns = self:findGameObject(name)
        local train_cfg = self.m_model:getHeroTrainCfg()
        local race_cft = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_train_data.races[2]] 
        local per_num =  GameUtil:formatNum(train_cfg.percent*100)
        local show_str = Language:getTextByKey("gf_str_0079", Language:getTextByKey(race_cft.name),per_num)
        if btns then
            GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = show_str } )
        end  
    elseif name == "hint_btn" then
        local train_cfg = self.m_model:getHeroTrainCfg()
        local params = {}
        params.title = "gf_str_0078"
        params.content = Language:getTextByKey(train_cfg.des)
        self.m_control:openView("Pops.CommonHelpPop", params)
    else
        self:updateMsg(name)
    end
end

function M:updateTime()
	if self.end_ts and self.end_ts > 0 then
		local time_show = GameUtil:formatTimeBySecond(self.end_ts - UserDataManager:getServerTime())
		self:setTextByLanKey("time_text", time_show)
	end
end

function M:destroy()
    M.super.destroy(self)
end

return M
