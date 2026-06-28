local M = class("NewWelfareNode",LikeOO.OOUIbase)
--新手福利
M.m_uiName = "OperateActivity/NewWelfareNode"

function M:onEnter()
    self.m_reward_parent = self:findGameObject("reward_parent")
    self.m_reward_parent2 = self:findGameObject("reward_parent2")
    self.c_hero_data = {}
    self:setTextByLanKey("title_text1", "fu_biaoti_tex2")
    self:setTextByLanKey("title_text2", "fu_biaoti_tex3")
    self:setTextByLanKey("fu_biaoti_text1", "fu_biaoti_tex1")
    self:setTextByLanKey("fu_biaoti_text", "fu_biaoti_tex1")
    self:setTextByLanKey("time_down_text", "castingSword_str_0028")
    self:showUI(false)
end

function M:switchInit(url,data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] then
            return
        end
        self.m_end_ts = self.m_model:getActiveEndTime(data.actives)
        self:updateTime()
        self:refreshUI()
    end
    self.m_model:initData(url, callFunc)
end

function M:switchUI(data, id)
    if self.m_model.m_bright_data == nil then
        return
    end
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_bright_data.actives)
    self:updateTime()
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_bright_data == nil then
        return
    end
    if self.m_model.m_skin_gift_data == nil then --皮肤礼包数据
        return
    end
    self:showUI(true)
    local bright_tab = ConfigManager:getCfgByName("bright_bless")
    local m_version = self.m_model.m_bright_data.version == 0 and 1 or self.m_model.m_bright_data.version
    local bright_cfg = bright_tab[m_version]
    self:setTextByLanKey("desc_text", bright_cfg.name)
    local need_money = GameUtil:switchMoneyType(bright_cfg.price)
    --local get_reward_btn = self:findButton("get_reward_btn")
    if self.m_model.m_bright_data.maximum_recharge_amount >= need_money then
        if self.m_model:checkNewWelfareGet() == true then
            self:setTextByLanKey("get_reward_text", "new_str_0080")
        else
            self:setTextByLanKey("get_reward_text", "new_str_0056")
        end
        self:setObjectVisible("get_reward_btn", true)
    else
        self:setTextByLanKey("get_reward_text", "new_str_0768")
        self:setObjectVisible("get_reward_btn", false)
    end
    local num = #bright_cfg.reward
    UIUtil.destroyAllChild(self.m_reward_parent.transform)
    UIUtil.destroyAllChild(self.m_reward_parent2.transform)
    local index = 1
	for i = 1, num do
		local data = bright_cfg.reward[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        if data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROS or data[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data[1] == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
            self.c_hero_data[index] = data
            index = index + 1
        end
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.m_reward_parent.transform, false)
        if i == 1 then
            GameUtil:creatCommonActiveEffect(item)
        end
	end
    self.go_to_open_id = bright_cfg.jump_open_id
    if self.go_to_open_id and self.go_to_open_id > 0 then
        self:setTextByLanKey("go_to_text", "gf_str_0131")
        local gift_id = bright_cfg.gift_new_id
        local gift_cfg = self.m_model:getGiftNewCfgById(m_version, gift_id)
        if next(gift_cfg) ~= nil then
            local skip_num = #gift_cfg.reward
            for i = 1, skip_num do
                local data = gift_cfg.reward[i]
                local item = GameUtil:createItemElement(data, true, true)
                item.transform:SetParent(self.m_reward_parent2.transform, false)
                if i == 1 then
                    GameUtil:creatCommonActiveEffect(item)
                end
            end
        end
    else
        self.skip_index = bright_cfg.skin_gift or 1
        local by_num = self.m_model:getActivityGiftData(self.skip_index)
        if by_num > 0 then
            self:setTextByLanKey("go_to_text", "gf_str_0048")
        else
            self:setTextByLanKey("go_to_text", "gf_str_0131")
        end
        local skip_cfg = self.m_model:getSkipCfgById(self.skip_index)
        if next(skip_cfg) ~= nil then
            local skip_num = #skip_cfg.reward
            for i = 1, skip_num do
                local data = skip_cfg.reward[i]
                local item = GameUtil:createItemElement(data, true, true)
                item.transform:SetParent(self.m_reward_parent2.transform, false)
                if i == 1 then
                    GameUtil:creatCommonActiveEffect(item)
                end
            end
        end
    end
    self:setSpine()
end

function M:onButtonClick(obj, name)
    if name == "get_reward_btn" then
        local bright_tab = ConfigManager:getCfgByName("bright_bless")
        local m_version = self.m_model.m_bright_data.version == 0 and 1 or self.m_model.m_bright_data.version
        local bright_cfg = bright_tab[m_version]
        local need_money = GameUtil:switchMoneyType(bright_cfg.price)
        if self.m_model.m_bright_data.maximum_recharge_amount >= need_money then
            if self.m_model:checkNewWelfareGet() == false then
                self:updateMsg("buy_welfare")
            end
        else
            local index = self.m_model:switchByOpenId(201)
            if index > 0 then
                self:updateMsg(index)
            end
        end
    elseif name == "skill1_img" then
        local sk_obj = self:findGameObject(name)
		self:openSkillPop(1, sk_obj)
	elseif name == "skill2_img" then
        local sk_obj = self:findGameObject(name)
		self:openSkillPop(2, sk_obj)
	elseif name == "skill3_img" then
        local sk_obj = self:findGameObject(name)
		self:openSkillPop(3, sk_obj)
	elseif name == "skill4_img" then
        local sk_obj = self:findGameObject(name)
		self:openSkillPop(4, sk_obj)   --
    elseif name == "go_to_btn" then
        if self.go_to_open_id and self.go_to_open_id > 0 then
            local index = self.m_model:switchByOpenId(self.go_to_open_id)
            self:updateMsg(index)
            return
        end
        local index = self.m_model:switchByOpenId(175)
        local by_num = self.m_model:getActivityGiftData(self.skip_index)
        if by_num == 0 and index > 0 then
            self:updateMsg(index)
        end
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:updateTime()
    if self.m_end_ts then
        local show_tim = GameUtil:formatTimeBySecond(self.m_end_ts- UserDataManager:getServerTime())
        self:setTextByLanKey("time_down", show_tim)
    end
end

function M:setSpine()
    for i = 1, #self.c_hero_data do
        local reward_data = RewardUtil:getProcessRewardData(self.c_hero_data[i])
        if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
            local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
            self:setTextByLanKey("hero_name_" .. i, cfg.class)
            self:setTextByLanKey("hero_name2_" .. i, cfg.name)
            local farm_data = GlobalConfig.TYPE_HERO_RACE[cfg.race]
            self:setImg(farm_data.race_icon, ResourceUtil:getLanAtlas(), "hero_race_" .. i)
            if cfg then
                local icon = cfg.hero_spine
                if self.cacheSpineName == icon then
                    return
                else
                    self.cacheSpineName = icon
                end
                local play_img = self:findGameObject("hero_spine_" .. i)
                local spine_pos = cfg.spine_position
                local pos = play_img.transform.localPosition
                pos.x = pos.x + spine_pos[1]
                pos.y = pos.y + spine_pos[2]
                play_img.transform.localPosition = pos
                GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
                --self:updateSkill(cfg)
            end
        end
    end
    self:setObjectVisible("skill_obj", false)
end

function M:updateSkill(cfg)
    local skills = cfg.skill
    for i = 1,4 do
        self:setObjectVisible("di_"..i, false)
    end
    for k,v in pairs(skills) do 
        if k <= 4 then
            self:setObjectVisible("di_"..k, true)
            local str_name = "skill"..k.."_img"
            local show_text = "skill_"..k.."_text"
            local cur_skill = GameUtil:getSkill(v[1][1])
            self:setTextByLanKey(show_text, cur_skill.show_type)
            self:setImg(cur_skill.icon, "skill_icon", str_name)
        end
    end
end

--获取技能信息
function M:getHeroSkill()
    local reward_data = RewardUtil:getProcessRewardData(self.c_hero_data)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
	local max_lv = ConfigManager:getHeroMaxlv(105)
	return cfg.skill, max_lv
end


function M:openSkillPop(index, sk_obj)
	local skills, hero_lv = self:getHeroSkill()
    local parms = {}
    parms.skill = skills[index]
    parms.index = index
    parms.cur_lv = hero_lv
    parms.click_transform = sk_obj.transform 
    parms.pivot = Vector2(0.5,1)
	self.m_control:openView("Pops.SkillPop", parms)
end

function M:showUI(bl)
    self:setObjectVisible("hero_name_con", bl)
    self:setObjectVisible("hero_name", bl)
    self:setObjectVisible("skill_obj", bl)
    self:setObjectVisible("time_down", bl)
    self:setObjectVisible("go_to_btn", bl)
    self:setObjectVisible("get_reward_btn", false)
    --self:setObjectVisible("get_reward_btn", bl)
end

function M:destroy()
    M.super.destroy(self)
end


return M