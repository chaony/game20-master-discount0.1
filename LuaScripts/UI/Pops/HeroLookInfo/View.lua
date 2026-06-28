---@class HeroLookInfoView:OOPopBase
---@field m_model HeroLookInfoModel
local M = class("HeroLookInfoView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Pops/HeroLookInfo"

local langTab = {"hero_role_upgrade_text8","hero_role_upgrade_text9","hero_role_upgrade_text10"
,"hero_role_upgrade_text11","hero_role_upgrade_text12","hero_role_upgrade_text13"}

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
    --local text = string.gsub(Language:getTextByKey( self.m_model.m_hero_cfg.type_des03),"·", "\n    ")
    self:setTextByLanKey("hero_tips_text", self.m_model.m_hero_cfg.type_des03)
    self:setTextByLanKey("evo_text", "hero_ui_str_0009")
    self:setTextByLanKey("race_text", "hero_ui_str_0001")
    self:setTextByLanKey("pro_text", "hero_ui_str_0002")
    self:setTextByLanKey("race_value_text", GlobalConfig.TYPE_HERO_RACE[self.m_model.m_hero_cfg.race].name)
    self:setTextByLanKey("pro_value_text", GlobalConfig.TYPE_HERO_PROPERTY[self.m_model.m_hero_cfg.type].name)
    self.big_close_btn = self:findGameObject("big_close_btn")
    --local frame_data = GlobalConfig.QUALITY_FRAME[self.m_model.m_hero_cfg.max_evo]
    local line_frame_name =GameUtil:get_lineframename(self.m_model.m_hero_cfg.Ex_hero,self.m_model.m_hero_cfg.max_evo)
    self:setTextByLanKey("get_title_text", "new_str_0554")
    self:setObjectVisible("tujian_upgrade_info", false)
    self:setObjectVisible("img_tips_text", true)
    self:setObjectVisible("tujian_upgrade", false)
    self:setObjectVisible("tujian_btn_list", false)
    self:setObjectVisible("upgrade_max", false)
    self:setObjectVisible("UI_HeroBag_ZhanLi_002", false)
    self:setTextByLanKey("buff_type_text", "")
    self:setTextByLanKey("tujian_upgrade_max_tips", "hero_role_upgrade_text14")
    self:setObjectVisible("all_loopscroll", false)
    self:setImg(line_frame_name, "common_ui","hero_evo")
    self:setParticleRenderOrder(self.content_node)
    self:setSpine()
    self:updateSkill()
    self:updateProType()
    self:updateGetList()
    self:setObjectVisible("evaluate_btn", false)
    --self:setObjectVisible("evaluate_btn", UserDataManager.hero_data:checkHeroCollect(self.m_model.m_hero_cfg.id) == true)
    self:updateFriendShip()
    if self.m_model.m_hero_cfg.vo and self.m_model.m_hero_cfg.vo ~= "" then
        ResourceUtil:LoadRoleSound(self.m_model.m_hero_cfg.bank)
        self.cur_cv = audio:SendEvtUI(self.m_model.m_hero_cfg.vo)
        audio:PauseMusicBusVol()
    end

    local cur_season = UserDataManager:getCurSeason() -- 当前赛季
    local season = ConfigManager:getCommonValueById(607,2) -- 图鉴按赛季开启
    local isOpen = self.m_control:hasChild("HeroBook") -- 判断必须在推荐界面才能展示图鉴升级相关内容
    if cur_season >= season and isOpen then
        self:refreshHeroRoleInfo()
    end
    self:setTextByLanKey("pinglun_text", "pinglun_tex")
    self:setTextByLanKey("prestige_text", "new_str_0056")
    self:refreshPrestigeBtn()
    self:refreshSP()
end

function M:refreshSP()
    local is_sp,sp_bg_name,sp_mul_lan_name,sp_efffect_name = self.m_model:getHero_SPInfo()
    self:setObjectVisible("hero_sp_flag", is_sp)
    if is_sp then
        self:setImg(sp_bg_name,"hero_ui","hero_sp_bg")
        self:setTextByLanKey("hero_sp_name",sp_mul_lan_name)
        if self.cur_sp_eff_go then
            self.cur_sp_eff_go:SetActive(false)
        end
        if sp_efffect_name then
            self.cur_sp_eff_go=self:setObjectVisible(sp_efffect_name,true)
        end
    end


end

--检查是否可以领取威望系统棋子
function M:refreshPrestigeBtn()
    local cur_season = UserDataManager:getCurSeason() -- 当前赛季cur_season
    local cur_stage = UserDataManager:getCurStage()
    local open_condition = ConfigManager:getCfgByName("open_condition")
    local prestige = open_condition[383]
    local unlock3 = prestige.unlock_condition_param3 or 0
    if (cur_season < prestige.season_unlock and (unlock3 <= 0 or unlock3 > cur_stage)) or self.m_model.m_is_open_type == 1 then  --赛季未解锁，并且，超前开启条件未设置或者设置了但不满足
        self:setObjectVisible("prestige_root",false)
        return
    end
    local data = UserDataManager:getHeroPrestigeData()
    local evo = self.m_model.m_heroRoleEvo
    local id = self.m_model.m_hero_id
    local prestige_piece_hero_free = ConfigManager:getCfgByName("prestige_piece_hero_free")
    local cur_hero_cfg = prestige_piece_hero_free[id]
    if cur_hero_cfg then
        local have = false
        for k,v in ipairs(data) do
            if id == v then
                have = true
                break
            end
        end
        self:setObjectVisible("prestige_root",evo >= cur_hero_cfg.unlock_quality and not have)
    else
        self:setObjectVisible("prestige_root",false)
    end
end

-- 刷新职业等级相关
function M:refreshHeroRoleInfo()
    local roleUpGradeLv = ConfigManager:getCommonValueById(602,0) -- 图鉴升级开启等级
    local heroRoleCfg, evo = self.m_model.m_heroRoleCfg, self.m_model.m_heroRoleEvo
    if evo >= tonumber(roleUpGradeLv) and self.m_model.m_role_level > 0 and heroRoleCfg and _G.next(heroRoleCfg) then
        self:setObjectVisible("friend_ship_node", false)
        self:setObjectVisible("img_tips_text", false)
        self:setObjectVisible("friend_lv_img", false)
        self:setObjectVisible("tujian_upgrade_info", true)
        self:setTextByLanKey("tujian_upgrade_title", "hero_role_upgrade_text1")
        self:setTextByLanKey("tips_new_text1", "hero_role_upgrade_text2")
        self:setTextByLanKey("tips_new_text2", heroRoleCfg.role_name)
        self:setTextByLanKey("tips_new_text3", heroRoleCfg.equip_name)
        self:setTextByLanKey("tujian_skill_title",heroRoleCfg.role_name)
        self:setTextByLanKey("tujian_skill_des", heroRoleCfg.skill_des)
        self:updateHeroRoleAttrList(heroRoleCfg.att) -- 个人等级加成
        self:refreshHeroRoleCostNode()
        local roleAttrs = self.m_model:getRoleAtt()
        self:updateHeroRoleAllAttrList(roleAttrs) -- 职业等级加成
        local role_type = self.m_model.m_hero_cfg.role_type
        if table.nums(roleAttrs) >0 and role_type and role_type ~= 0 and langTab[role_type] then
            self:setTextByLanKey("buff_type_text", langTab[role_type])
            self:setObjectVisible("all_loopscroll", true)
        end
        local upgrade_type_info = GlobalConfig.HERO_ROLE_UPGRADE_TYPE[tonumber(heroRoleCfg.icon)]
        if upgrade_type_info then
            self:setImg(upgrade_type_info.icon or "a_tjsj_zhiye_1green", "hero_ui", "tips_new_img")
            local tips_new_text2 = self:setTextColor("tips_new_text2", upgrade_type_info.color)
            UIUtil.setOutlineExEffectColor(tips_new_text2.transform,nil, upgrade_type_info.outLineColor,2)
        end
    elseif evo >= tonumber(roleUpGradeLv) and heroRoleCfg and _G.next(heroRoleCfg) then
        self:refreshHeroRoleCostNode()
    end
    if self.m_model.m_role_level == 0 then
        self:setObjectVisible("reset_btn", false)
    else
        self:setObjectVisible("reset_btn", true)
    end
end

function M:refreshHeroRoleCostNode()
    local sel_list, needNum, quality, consume_item, universal = self.m_model:getCanCostHeroList()
    self:setObjectVisible("tujian_btn_list", true)
    self:setObjectVisible("UI_Achievement_JiangLi_001", false)
    if needNum == 0 then
        self:setObjectVisible("tujian_upgrade", false)
        self:setObjectVisible("upgrade_max", true)
        return
    else
        self:setObjectVisible("tujian_upgrade", true)
        self:setObjectVisible("upgrade_max", false)
    end
    for i=1,3 do
        local trans = self:findGameObject("hero_item_"..i).transform
        trans.gameObject:SetActive(true)
        UIUtil.destroyAllChild(trans)
        if sel_list[i] then
            local oid = sel_list[i]
            local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
            local icon, ui_element = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false)
            local hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByOid(oid)
            if hero_skin_cfg and next(hero_skin_cfg) then
                LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", hero_skin_cfg.icon, "hero_head_ui")
            else
                LuaBehaviourUtil.setImg(ui_element.luaBehaviour,"item_img", cfg.icon, "hero_head_ui")
            end
            icon.transform:SetParent(trans, false)
            UIUtil.setLocalScale(icon.transform, 0.6, 0.6, 0.6)
        else
            if i > needNum then
                trans.gameObject:SetActive(false)
            else
                local function noUniversal()
                    local id = self.m_model.m_hero_id
                    local icon, ui_element = CommonUIUtil:createHeroElement({RewardUtil.REWARD_TYPE_KEYS.HEROS,id,1, quality = quality}, false, false)
                    icon.transform:SetParent(trans, false)
                    UIUtil.setLocalScale(icon.transform, 0.6, 0.6, 0.6)
                    local luaBehaviour = icon:GetComponent("LuaBehaviour")
                    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
                    lv_bg_img:SetActive(false)
                    UIUtil.setOpacity(icon.transform, 0.6)
                    local no_panel = luaBehaviour:FindGameObject("no_panel")
                    no_panel:SetActive(true)
                    local no_quality_img = luaBehaviour:FindGameObject("no_quality_img")
                    no_quality_img:SetActive(false)
                    local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
                    no_quality_up_img:SetActive(false)
                end

                if universal then
                    local universal_data = RewardUtil:getProcessRewardData(universal)
                    if universal_data.user_num >= universal_data.data_num then
                        local icon, ui_element = GameUtil:createItemElementByData(universal_data,true,true)
                        icon.transform:SetParent(trans, false)
                        UIUtil.setLocalScale(icon.transform, 0.9, 0.9, 0.9)
                    else
                        noUniversal()
                    end
                else
                    noUniversal()
                end
                
            end
        end
    end

    -- 道具消耗
    local consItem = RewardUtil:getProcessRewardData(consume_item[1])
    self:setImg(consItem.icon_name, consItem.atlas_name, "cons_img")
    if consItem.user_num < consItem.data_num then
        self:setTextByLanKey("cons_num", "equip_str_033" ,tostring(consItem.user_num) ,tostring(consItem.data_num))
    else
        self:setTextByLanKey("cons_num", tostring(consItem.user_num).."/"..tostring(consItem.data_num))
    end
    if #sel_list>= needNum and consItem.user_num >= consItem.data_num then
        self:setObjectVisible("UI_Achievement_JiangLi_001", true)
    end
end

function M:updateGetList()
    local data = self.m_model.m_hero_cfg.jump_id
    local cfg_season = self.m_model.m_hero_cfg.season or 0
    local cfg_season_day = self.m_model.m_hero_cfg.season_day or 0
    local season = UserDataManager:getCurSeason()
    local season_day = UserDataManager:getCurSeasonDay()
    if season < cfg_season or (season == cfg_season and cfg_season_day ~= 0 and season_day < cfg_season_day) then
        data = {999999}
    end
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        if v == 999999 then
            if cfg_season_day ~= 0 then
                all_cell_size[i] = Vector2(200, 30)
            else
                all_cell_size[i] = Vector2(150, 30)
            end
        else
            all_cell_size[i] = Vector2(120, 30)
        end
    end
    
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                local jump = ConfigManager:getCfgByName("jump")
                local jump_item = jump[cell_data]
                if jump_item then
                    if cell_data == 999999 then
                        local line_img = luaBehaviour:FindGameObject("line_img")
                        local item_bg_rt = UIUtil.findRectTransform(line_img.gameObject)
                        if cfg_season_day ~= 0 then --第x赛季第x天开放
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", "hero_ui_str_0047", cfg_season, cfg_season_day)
                            item_bg_rt.sizeDelta = Vector2(200, 2)
                        elseif cfg_season ~= 0 then --第x赛季开放
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", "hero_ui_str_0048", cfg_season)
                            item_bg_rt.sizeDelta = Vector2(150, 2)
                        else --后续版本开放
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", "hero_ui_str_0044")
                            item_bg_rt.sizeDelta = Vector2(150, 2)
                        end
                    else
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
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data == 999999 then
                    if cfg_season_day ~= 0 then
                        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_ui_str_0047", cfg_season, cfg_season_day), delay_close = 2})
                    elseif cfg_season~= 0then
                        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_ui_str_0048", cfg_season), delay_close = 2})
                    else
                        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("hero_ui_str_0044"), delay_close = 2})
                    end
                    
                else
                    self.m_control:closeView("Item.ItemDetail")
                    QuickOpenFuncUtil:openFunc(cell_data)
                    self:updateMsg(99999)
                end
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
    --local sg = play_img:GetComponent("SkeletonGraphic")
    --local hehe = ResourceUtil:GetSk(spine_name, "rolespine_"..string.lower(spine_name))
    --sg.skeletonDataAsset = hehe
    --sg:Initialize(true)
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --local data_pos = self.m_model.m_hero_cfg["spine_position"]
    --local pos = Vector3.New(10,-162,0)
    -- if data_pos and next(data_pos) ~= nil then
    --     pos.x = pos.x + data_pos[1] 
    --     pos.y = pos.x + data_pos[2]
    --     play_img.transform.localPosition = pos
    -- end
end

function M:updateSkill()
    local skills = self.m_model.m_hero_cfg.skill or {}
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

--好感
function M:updateFriendShip()
    local friend_data = UserDataManager.m_friendliness[tostring(self.m_model.m_hero_id)] 
    if friend_data and friend_data.lv > 0 then
        local fetter_data = self.m_model:getCurFetterLv(friend_data.lv)
        if fetter_data then
            self:setObjectVisible("friend_ship_node", true)
            self:setObjectVisible("friend_lv_img", true)
            self:setTextByLanKey("friend_lv_text", friend_data.lv)
            self:setTextByLanKey("friend_ship_title", "hero_ui_str_0034",friend_data.lv)
            self:updateFriendList(fetter_data.Meridian_attr)
        else
            self:setObjectVisible("friend_ship_node", false)  
            self:setObjectVisible("friend_lv_img", false)
        end
    else
        self:setObjectVisible("friend_ship_node", false)
        self:setObjectVisible("friend_lv_img", false)    
    end
end

function M:updateFriendList(data)
    if self.f_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local key = GameUtil:getAttrsKey(cell_data[1])
		            local name = GameUtil:getAttrsName(key)
                    local num = cell_data[2]
                    if GameUtil:canPerAttrTransition(key) == true then
                        num = GameUtil:formatNum(num * 100) 
                    end
                    if GameUtil:attrTransition(key) == true then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name.."+"..tostring(num).."%")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name.."+"..tostring(num))
                    end
                end
            end,
            ui_name = self.m_uiName,
        }
        self.f_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.f_loop_scroll_view:reloadData(self.mapData,true)
    end
end

-- 图鉴升级加成
function M:updateHeroRoleAttrList(data)
    if self.hr_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("heroRole_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local key = GameUtil:getAttrsKey(cell_data[1])
                    local name = GameUtil:getAttrsName(key)
                    local num = cell_data[2]
                    if GameUtil:canPerAttrTransition(key) == true then
                        num = GameUtil:formatNum(num * 100)
                    end
                    if GameUtil:attrTransition(key) == true then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name.."+"..tostring(num).."%")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name.."+"..tostring(num))
                    end
                end
            end,
            ui_name = self.m_uiName,
        }
        self.hr_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.hr_loop_scroll_view:reloadData(data,true)
    end
end

function M:lvUpZoom()
    self:setObjectVisible("UI_HeroBag_ZhanLi_002", true)
    local com_parent = self:findGameObject("hero_effect_parent")
    local lizi_02 = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_ShengJi_002", com_parent)
    self:setParticleRenderOrder(lizi_02)
    if self.m_control then
        self.m_control:setOnceTimer(0.6, function()
            U3DUtil:Destroy(lizi_02)
            self:setObjectVisible("UI_HeroBag_ZhanLi_002", false)
        end)
    end
end


-- 图鉴升级职业加成
function M:updateHeroRoleAllAttrList(data)
    if self.all_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("all_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local key = GameUtil:getAttrsKey(cell_data[1])
                    local name = GameUtil:getAttrsName(key)
                    local num = cell_data[2]
                    if GameUtil:canPerAttrTransition(key) == true then
                        num = GameUtil:formatNum(num * 100)
                    end
                    if GameUtil:attrTransition(key) == true then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name.."+"..tostring(num).."%")
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name.."+"..tostring(num))
                    end
                end
            end,
            ui_name = self.m_uiName,
        }
        self.all_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.all_loop_scroll_view:reloadData(data,true)
    end
end


function M:destroy()
    audio:StopPlayingID(self.cur_cv)
    self.cur_cv = nil
    audio:ResumeMusicBusVol()
    M.super.destroy(self)
end

return M