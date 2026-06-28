---@class GifBagGuaNode
---@field m_model GiftBagModel
local M = class("GifBagGuaNode", LikeOO.OOUIbase)
--卦签
M.m_uiName = "GiftBag/GifBagGuaNode"

function M:onEnter()
    self.m_remain_ts = 0
    self:setObjectVisible("spine_qian", false)
    self:setObjectVisible("mask_qian", false)
    self:setTextByLanKey("active_btn_text", "gf_str_0078")
    self:setTextByLanKey("title_qian1", "title_qian_1")
    self:setTextByLanKey("title_qian2", "title_qian_2")
    self:setTextByLanKey("title_qian3", "title_qian_3")
    self:setTextByLanKey("buy_growup_text", "buy_growup_tex")
    self:setTextByLanKey("get_text", "buy_growup_get")
    self:showUI(false)
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
        if self:checkAutoOpen() == true then
            self:updateMsg("get_text")
        end
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
    if self:checkAutoOpen() == true then
        self:updateMsg("get_text")
    end
end

function M:refreshUI()
    local m_draw_data = self.m_model.m_draw_data
    if m_draw_data == nil or next(m_draw_data) == nil then
        return
    end
    self:showUI(true)
    local active_id = 0
    for i,v in pairs(m_draw_data.actives or {}) do
        if v.open_status == 1 then
            self.gua_star_ts = v.start_ts
            active_id = v.id
        end 
    end
    self.gua_s_day = self:getDay()
    self.end_ts = self.m_model:getActiveEndTime(m_draw_data.actives)
    self:updateTime()
    local consume_data = self.m_model:getDrawConsume()
    self:setTextByLanKey("hy_text", "gf_str_0052", consume_data.name)
    self:setTextByLanKey("hy_num", consume_data.user_num)
    if consume_data.data_num == 0 then
        self:setTextByLanKey("data_num", "new_str_0278")
        self:setObjectVisible("buy_growup_red_point", true)
    else
        self:setObjectVisible("buy_growup_red_point", self.m_model:getGuaRedPoint() == true)
        if consume_data.data_num > consume_data.user_num then
            self:setTextByLanKey("data_num", "<color=#F33535>"..consume_data.user_num.."</color>/"..consume_data.data_num)
        else
            self:setTextByLanKey("data_num", consume_data.user_num.."/"..consume_data.data_num)
        end
    end
    self:setImg(consume_data.icon_name, consume_data.atlas_name, "data_icon")
    self:setImg(consume_data.icon_name, consume_data.atlas_name, "xiaohao_icon")
    local shang_parent = self:findGameObject("qian_1")
    local zhong_parent = self:findGameObject("qian_2")
    local xia_parent = self:findGameObject("qian_3")
    local draw_tab_1 = self.m_model:getDrawRewardCfg(1)
    local draw_tab_2 = self.m_model:getDrawRewardCfg(2)
    local draw_tab_3 = self.m_model:getDrawRewardCfg(3)
    UIUtil.destroyAllChild(shang_parent.transform)
    UIUtil.destroyAllChild(zhong_parent.transform)
    UIUtil.destroyAllChild(xia_parent.transform)
    for i=1, #draw_tab_1 do
        local reward_cfg = draw_tab_1[i]
        local draw_get = self.m_model:getDrawRewardData(reward_cfg.id)
        local itemNode = GameUtil:createItemElement(reward_cfg.reward[1],true,true)
        self:updateReward(itemNode, reward_cfg)
        local data = RewardUtil:getProcessRewardData(reward_cfg.reward[1])
        GameUtil:creatCommonActiveEffect(itemNode, data.quality, 1)
        itemNode.transform:SetParent(shang_parent.transform, false)
    end
    for i=1, #draw_tab_2 do
        local reward_cfg = draw_tab_2[i]
        local draw_get = self.m_model:getDrawRewardData(reward_cfg.id)
        local itemNode = GameUtil:createItemElement(reward_cfg.reward[1],true,true)
        self:updateReward(itemNode, reward_cfg)
        itemNode.transform:SetParent(zhong_parent.transform, false)
    end
    for i=1, #draw_tab_3 do
        local reward_cfg = draw_tab_3[i]
        local itemNode = GameUtil:createItemElement(reward_cfg.reward[1],true,true)
        self:updateReward(itemNode, reward_cfg)
        itemNode.transform:SetParent(xia_parent.transform, false)
    end
    self:setObjectVisible("quests_red_point", self:checkRedPoint() == true)
    local active_tab = ConfigManager:getCfgByName("active")
    local active_cfg = active_tab[active_id]
    if active_cfg then
        local btn_open = BtnOpenUtil:isBtnOpen(170)
        self:setObjectVisible("to_active_obj", active_cfg.hero_id > 0 and btn_open == true)
    else
        self:setObjectVisible("to_active_obj", false)
    end

    --
    local hero_id = self.m_model:getDrawHeroID()
    self:refreshSpine(hero_id)
end

function M:playSpine(index, callback)
    local spine_qian = self:findSkeletonGraphic("spine_qian");
    local draw_tab = self.m_model:get_draw_cfg()
    local draw_cfg = draw_tab[index]
    if draw_cfg then
        local spine_str = "haoyunqian"
        if draw_cfg.sort == 1 then
            spine_str = "shangshangqian"
        elseif draw_cfg.sort == 2 then
            spine_str = "shangqian"
        elseif draw_cfg.sort == 3 then
            spine_str = "haoyunqian"
        end
        local function play_end()
            self:setObjectVisible("spine_qian", false)
            self:setObjectVisible("mask_qian", false)
            callback()
        end  
        self:setObjectVisible("spine_qian", true)
        self:setObjectVisible("mask_qian", true)
        spine_qian.AnimationState:SetAnimation(0, spine_str, false)   
        self:addSpineComplete(spine_qian.AnimationState, play_end)
    end
end

function M:checkRedPoint()
    for k,v in pairs(self.m_model.m_draw_data.quests) do
        local c_cfg = self:getQuestsByID(k)
        if v.status == 1 and self.gua_s_day >= c_cfg.day then
            return true
        end
    end
    for i = 1, self.gua_s_day  do
        if self:checkHaveLoginDay(i) == true then
            return true
        end 
    end
    return RedPointUtil:gerDrawTaskRedPoint() == true
end

function M:checkAutoOpen()
    local m_draw_data = self.m_model.m_draw_data
    if m_draw_data == nil then
        return false
    end
    for k,v in pairs(self.m_model.m_draw_data.quests) do
        local c_cfg = self:getQuestsByID(k)
        if v.status == 1 and self.gua_s_day >= c_cfg.day then
            return true
        end
    end
    for i = 1, self.gua_s_day  do
        if self:checkHaveLoginDay(i) == true then
            return true
        end 
    end
    return false
end

function M:getQuestsByID(id)
    local draw_quest_tab = ConfigManager:getCfgByName("draw_quest")
	local version_tab = draw_quest_tab[self.m_model.m_draw_data.version]
	return version_tab[tonumber(id)]
end

function M:checkHaveLoginDay(day)
    for k,v in pairs(self.m_model.m_draw_data.login_done) do
        if day == v then
            return false
        end
    end
    return true
end

function M:onButtonClick(obj, name)
    if name == "to_active_obj" then --侠客试炼
        self.m_control:closeView("Activities.WorldBoss.HeroBossTrainPop")
        QuickOpenFuncUtil:openFunc(78)
        self.m_control:setOnceTimer(0.1, function ()
            self:updateMsg(99999)
        end)
    else
        self:updateMsg(name)
    end
end


function M:getDay()
    local server_ts = UserDataManager:getServerTime()
    local day = GameUtil:NumberOfDaysInterval(server_ts, self.gua_star_ts, 0)
    local m_day = day + 1
	return day + 1
end

function M:updateTime()
	if self.end_ts and self.end_ts > 0 then
		local time_show = GameUtil:formatTimeBySecond(self.end_ts - UserDataManager:getServerTime())
		self:setTextByLanKey("down_time", "activities_str_0012", time_show)
	end
end

function M:updateReward(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
    if luaBehaviour then
        local draw_get = self.m_model:getDrawRewardData(data.id)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", draw_get == true)
    end
end


function M:showUI(bl)
    self:setObjectVisible("Image(2)", bl)
    self:setObjectVisible("get_text", bl)
    self:setObjectVisible("buy_growup_btn", bl)
    self:setObjectVisible("Image (1)", bl)
    self:setObjectVisible("data_icon", bl)
    self:setObjectVisible("to_active_obj", false)
end

function M:refreshSpine(id)
    if id == nil then
        self:setObjectVisible("hero_spine", false)
        return
    end
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    if cfg == nil then
        self:setObjectVisible("hero_spine", false)
        return
    end
    local skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = nil}, cfg)
    local spine_name = skin_cfg.hero_spine or "hero_0412_SkeletonData"
    --spine
    self:setObjectVisible("hero_spine", true)
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --[[
    --evo
    self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui","hero_evo")
    --name
    local class_str = Language:getTextByKey(cfg.class)
    local name_str = Language:getTextByKey(skin_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    --race
    local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    ]]--
end

function M:destroy()
    M.super.destroy(self)
end

return M