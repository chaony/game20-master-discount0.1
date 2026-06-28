local M = class("HeroSkinLookInfoView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Pops/HeroSkinLookInfo"

function M:onEnter()
    audio:SendEvtUI("UI_NormalClick1")
    local class_str = Language:getTextByKey(self.m_model.m_hero_cfg.class)
    local name_str = Language:getTextByKey(self.m_model.m_shin_data_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    local pro = GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].pro_icon
    self:setImg(pro, "hero_ui", "pro_img_btn")
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    self:setTextByLanKey("img_tips_text", "hero_ui_str_0026")
    self:setTextByLanKey("skin_attr_text", "hero_ui_str_0027")
    self.big_close_btn = self:findGameObject("big_close_btn")
    --local frame_data = GlobalConfig.QUALITY_FRAME[self.m_model.m_hero_cfg.max_evo]
    self:setTextByLanKey("get_title_text", "new_str_0554")
    local poetry = string.gsub(Language:getTextByKey(self.m_model.m_shin_data_cfg.poetry), "\\n", "\n")
    self:setText("skin_info_text", poetry)
    local skin_name_img = self:setImg("a_name_"..self.m_model.m_skin_id,  ResourceUtil:getLanAtlas(), "skin_name_img")
    skin_name_img:SetNativeSize()
    self:setTextByLanKey("new_skin_text", "new_str_0421")
    self:setObjectVisible("new_skin", self.m_model.m_is_new)
    self:setTextByLanKey("pinglun_text", "new_str_0677")
    self:setImg(GameUtil:get_lineframename(self.m_model.m_hero_cfg.Ex_hero,self.m_model.m_hero_cfg.max_evo), "common_ui","hero_evo")
    self:setParticleRenderOrder(self.content_node)
    self:setSpine()
    self:setSkinQuality()
    self:setSkinAttr()
    self:updateSkill()
    self:updateProType()
    self:updateGetList()
    --if self.m_model.random_cfg then
    --    ResourceUtil:LoadRoleSound(self.m_model.random_cfg.bank)
    --    self.cur_cv = audio:SendEvtUI(self.m_model.random_cfg.se_id)
    --    audio:PauseMusicBusVol()
    --else
        local skinCfg = self.m_model:getHeroSkinCfg(self.m_model.m_skin_id)
        if skinCfg.vo and skinCfg.vo ~= "" then
            ResourceUtil:LoadRoleSound(skinCfg.bank)
            self.cur_cv = audio:SendEvtUI(skinCfg.vo)
            audio:PauseMusicBusVol()
        end 
    --end
    self:setObjectVisible("evaluate_btn", UserDataManager.hero_data:checkHeroCollect(self.m_model.m_hero_cfg.id) == true)
end

function M:updateGetList()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = self.m_model.m_shin_data_cfg.go_type,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local jump = ConfigManager:getCfgByName("jump")
                local jump_item = jump[cell_data]
                if jump_item then
                    local open_condition_id = jump_item.open_condition_id or 0
                    local open_condition = ConfigManager:getCfgByName("open_condition")
                    local open_condition_cfg = open_condition[open_condition_id]
                    if open_condition_cfg then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", open_condition_cfg.name)
                        local str = Language:getTextByKey(open_condition_cfg.name)
                        local line_img = luaBehaviour:FindGameObject("line_img")
                        local item_bg_rt = UIUtil.findRectTransform(line_img.gameObject)
                        if #str == 6 then
                            item_bg_rt.sizeDelta = Vector2(40, 2)
                        elseif #str == 9 then
                            item_bg_rt.sizeDelta = Vector2(60, 2)
                        end
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(99999)
                QuickOpenFuncUtil:openFunc(cell_data)
            end,
            ui_name = self.m_uiName,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(self.mapData,true)
    end
end

--英雄类型
function M:updateProType()
	local temp_cfg = self.m_model.m_hero_cfg
	if temp_cfg then
		local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
		local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[temp_cfg.locate[1] or 1]
		local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[temp_cfg.locate[2] or 1]
		self:setImg(type_data.pro_icon, "hero_ui", "pro_img_1")
		self:setImg(locate1_data.loc_icon, "hero_ui", "pro_img_2")
		self:setImg(locate2_data.loc_icon, "hero_ui", "pro_img_3")
		self:setTextByLanKey("pro_text_1", type_data.name)
		self:setTextByLanKey("pro_text_2", locate1_data.name)
		self:setTextByLanKey("pro_text_3", locate2_data.name)
	end
end

function M:setSpine()
    local spine_name = self.m_model.m_shin_data_cfg.hero_spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")

    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

function M:setSkinQuality()
    local skin_quality = self.m_model.m_shin_data_cfg.skin_quality
    if skin_quality ~= 0 then
        self:setObjectVisible("skin_quality", true)
        self:setImg("a_hero_skin_"..GameUtil:fillNumWithZero(skin_quality, 2), ResourceUtil:getLanAtlas(), "skin_quality")
    else
        self:setObjectVisible("skin_quality", false)
    end
end

function M:updateSkill()
    local skills = self.m_model.m_hero_cfg.skill
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

function M:setSkinAttr()
    local attrs = UserDataManager:appendAttrs(self.m_model.m_shin_data_cfg.attr)
    local attr_data = {}
    for i, v in pairs(attrs) do
        table.insert(attr_data, {i, v})
    end
    if table.nums(attr_data) > 0 then
        self:updateSkipArtList(attr_data)
    else
        self:setTextByLanKey("attr_value_text", "new_str_0825")
    end
end

function M:setAttr(attr_data)
    local attr_str_tab = {}
    for i, v in ipairs(attr_data) do
        local cp = GameUtil:getAttrsName(v[1])
        -- 四舍五入保留小数点后一位
        local attr_value = v[2] or 0
        attr_value = math.floor(attr_value)
        if GameUtil:attrTransition(v[1]) == true then
            table.insert(attr_str_tab, cp .. "    " .. GameUtil:formatNum(attr_value).."%")
        else
            table.insert(attr_str_tab, cp .. "    " .. GameUtil:formatNum(attr_value))
        end
    end
    self:setText("attr_value_text", table.concat(attr_str_tab, "\n"))
end

function M:updateSkipArtList(attr_data)
    if self.m_art_scroll_view == nil then
        local loopscroll = self:findGameObject("skin_attr_scroll")
        local params = {
            show_data = attr_data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local art_name = GameUtil:getAttrsName(cell_data[1])
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "art_name", art_name)
                    local attr_value = cell_data[2] or 0
                    attr_value = math.floor(attr_value)
                    if GameUtil:attrTransition(cell_data[1]) == true then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "art_num", GameUtil:formatNum(attr_value).."%")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "art_num", GameUtil:formatNum(attr_value))
                    end
                end
            end,
            ui_name = self.m_uiName,
        }
        self.m_art_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_art_scroll_view:reloadData(attr_data,true)
    end
end

function M:destroy()
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    --if self.m_model.random_cfg then
    --    ResourceUtil:UnLoadRoleSound(self.m_model.random_cfg.bank)
    --else
        local skinCfg = self.m_model:getHeroSkinCfg(self.m_model.m_skin_id)
        if skinCfg.vo and skinCfg.vo ~= "" then
            ResourceUtil:UnLoadRoleSound(skinCfg.bank)
        end
    --end
    audio:ResumeMusicBusVol()
    M.super.destroy(self)
end

return M