---@class CommonUIUtil
local M = class("CommonUIUtil")

function M:createHeroElement(data, is_big, parent, callback)
    local item  = nil
    item = GameUtil:createPrefab("Common/HeroNode", parent)   

    local ui_element = self:updateHeroElement(item, data, is_big, callback)
    return item, ui_element
end

function M:createHeroElementByData(data, is_big, parent)
    local item  = nil
    item = GameUtil:createPrefab("Common/HeroNode", parent) 
    local ui_element = self:updateHeroElementByData(item, data, nil, is_big)
    return item, ui_element
end

function M:updateHeroElement(object, dataTable, is_big, callback)
    if object == nil or type(dataTable) ~= "table" then 
        Logger.log("CommonUIUtil fun updateItemElement parameter error！！！")
        return 
    end
    local data = RewardUtil:getProcessRewardData(dataTable)
    local ui_element = self:updateHeroElementByData(object, data, callback, is_big)
    return ui_element
end

function M:updateHeroElementByData(object, data, callback, is_big,is_quality)
    local ui_element = {}
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local hero_skin_cfg = Battle.BattleConfigManager:getHeroCurSkinCfgByData_Battle(data.hero_data, data.item_cfg)
    local icon_name = data.icon_name
    if hero_skin_cfg ~= nil and next(hero_skin_cfg) ~= nil and icon_name ~= "a_mjmb_wodekaungdong_touxiang_kong" then
        icon_name = hero_skin_cfg.icon
    end
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", icon_name, data.atlas_name or "hero_head_ui")
    local fate_icon_img = LuaBehaviourUtil.setImg(luaBehaviour,"fate_icon_img", "a_tmhx_jiaobiao","language_zh_cn")
    -- TODO : 等出图后修改
    -- local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", "a_TX_bagua", data.atlas_name or "item_icon")
    ui_element.item_img = item_img
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    local battle_img = luaBehaviour:FindGameObject("battle_img")
    local mask_img = luaBehaviour:FindGameObject("mask_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local type_bg = luaBehaviour:FindGameObject("type_bg")
    local duigou_img = luaBehaviour:FindGameObject("duigou_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local stars = luaBehaviour:FindGameObject("stars")
    local lv_text = luaBehaviour:FindText("lv_text")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    local item_img = luaBehaviour:FindGameObject("item_img")
    local add_panel = luaBehaviour:FindGameObject("add_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local assist_img = luaBehaviour:FindGameObject("assist_img")
    local master_img = luaBehaviour:FindGameObject("master_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local tips_text = luaBehaviour:FindGameObject("tips_text")
    local recommend_img = luaBehaviour:FindGameObject("recommend_img")
    local chuangong_img = luaBehaviour:FindGameObject("chuangong_img")
    local UI_Formation_ShangZhen_001 = luaBehaviour:FindGameObject("UI_Formation_ShangZhen_001")
    local UI_Formation_XiaZhen_001 = luaBehaviour:FindGameObject("UI_Formation_XiaZhen_001")
    if UI_Formation_ShangZhen_001 then
        UI_Formation_ShangZhen_001:SetActive(false)
    end
    if UI_Formation_XiaZhen_001 then
        UI_Formation_XiaZhen_001:SetActive(false)
    end
    recommend_img:SetActive(false)
    tips_text:SetActive(false)
    type_img:SetActive(false)
    lv_bg_img:SetActive(false)
    lv_text.gameObject:SetActive(false)
    battle_img:SetActive(false)
    ui_element.red_point_img = red_point_img
    ui_element.duigou_img = duigou_img
    ui_element.luaBehaviour = luaBehaviour
    item_img:SetActive(true)
    red_point_img:SetActive(false)
    lock_img:SetActive(false)
    duigou_img:SetActive(false)
    stars:SetActive(false)
    if chuangong_img then
        chuangong_img:SetActive(false)
    end
    camp_bg:SetActive(false)
    mask_img:SetActive(false)
    add_img:SetActive(false)
    apostle_applay_img:SetActive(false)
    add_panel:SetActive(false)
    up_image:SetActive(false)
    assist_img:SetActive(false)
    master_img:SetActive(false)
    local frame_name = nil
    local quality_img = nil
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
        camp_bg:SetActive(true)
        type_bg:SetActive(true)
        local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
        local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
        if race_data then
            LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
        end
        if type_data then
            LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon, "hero_ui")
        end
        local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
        local quality_data_item = GlobalConfig.QUALITY_FRAME[data.quality] or GlobalConfig.QUALITY_FRAME[1]
        -- if is_big then
        --     frame_name = quality_item.card_frame_name3
        -- else
        --     frame_name = quality_item.card_frame_name3.."1"
        -- end
        frame_name = quality_item.hero_item_frame
        if is_quality == nil then
            quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
        end
        
        -- if quality_item.is_add == true or data.quality > 10 then
            LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", quality_data_item.big_frame_add_name or "", "hero_head_ui")
        -- end

        --GameUtil:updateHeroInfo(object, data)

        -- quality_up_img:SetActive(quality_item.is_add or data.quality > 10)
        quality_up_img:SetActive(quality_item.is_add)
        if data.oid then
            local hero_data,hero_cfg = UserDataManager.hero_data:getHeroDataById(data.oid)
            if hero_data then
                self:updateHeroLvByData(object, hero_data)
            end
        end
        --if data.quality and data.quality > 11 then --白色之后加星
        GameUtil:updateHeroInfo(object,data)
        --end
        local fate = data.fate or 0 -- 天命化星
        if fate_icon_img and fate > 0 then
            fate_icon_img.gameObject:SetActive(fate > 0)
            stars:SetActive(false)
        end
    end
    ui_element.quality_img = quality_img
    if callback then
        luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
            callback(click_object, click_name, idx, data)
        end)
    end
    return ui_element
end

function M:updateHeroHpSlider(object, hp_value, qi_value)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "slider", true)
        local hp_img = luaBehaviour:FindImage("hpValue")
        local qi_img = luaBehaviour:FindImage("lanValue")
        if hp_img ~= nil then
            hp_img.fillAmount = hp_value
        else
            Logger.log(" UI 找不到 hp_Img "..object.name )
        end
        if qi_img ~= nil then
            qi_img.fillAmount = qi_value
        end
    end
end

function M:updateHeroElementAdd(object, data, show_add,is_quality_img)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local item_img = luaBehaviour:FindGameObject("item_img")
    local mask_img = luaBehaviour:FindGameObject("mask_img")
    local battle_img = luaBehaviour:FindGameObject("battle_img")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local lock_img = luaBehaviour:FindGameObject("lock_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local type_bg = luaBehaviour:FindGameObject("type_bg")
    local duigou_img = luaBehaviour:FindGameObject("duigou_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local stars = luaBehaviour:FindGameObject("stars")
    local lv_text = luaBehaviour:FindText("lv_text")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    local add_panel = luaBehaviour:FindGameObject("add_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local assist_img = luaBehaviour:FindGameObject("assist_img")
    local master_img = luaBehaviour:FindGameObject("master_img")
    local quality_img = luaBehaviour:FindGameObject("quality_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local tips_text = luaBehaviour:FindGameObject("tips_text")
    local recommend_img = luaBehaviour:FindGameObject("recommend_img")
    local chuangong_img = luaBehaviour:FindGameObject("chuangong_img")
    recommend_img:SetActive(false)
    if chuangong_img then
        chuangong_img:SetActive(false)
    end
    tips_text:SetActive(false)
    battle_img:SetActive(false)
    lv_bg_img:SetActive(false)
    assist_img:SetActive(false)
    type_bg:SetActive(false)
    master_img:SetActive(false)
    quality_img:SetActive(true)
    mask_img:SetActive(false)
    red_point_img:SetActive(false)
    lock_img:SetActive(false)
    duigou_img:SetActive(false)
    stars:SetActive(false)
    camp_bg:SetActive(false)
    item_img:SetActive(false)
    quality_up_img:SetActive(false)
    lv_text.gameObject:SetActive(false)
    add_panel:SetActive(false)
    up_image:SetActive(false)
    local UI_Formation_ShangZhen_001 = luaBehaviour:FindGameObject("UI_Formation_ShangZhen_001")
    local UI_Formation_XiaZhen_001 = luaBehaviour:FindGameObject("UI_Formation_XiaZhen_001")
    if UI_Formation_ShangZhen_001 then
        UI_Formation_ShangZhen_001:SetActive(false)
    end
    if UI_Formation_XiaZhen_001 then
        UI_Formation_XiaZhen_001:SetActive(false)
    end
    if is_quality_img == nil then
        local quality_img = LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_currency_ws_lan_small", "hero_head_ui")
        quality_img.color = Color.New(1,1,1,0.7)
    end
    
    if show_add then
        add_img:SetActive(true)
    else
        add_img:SetActive(false)
    end
    apostle_applay_img:SetActive(false)
    luaBehaviour:RegistButtonClick() -- 重置事件
end

function M:updateHeroLvByData(object, data, is_big)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_text", true)
    local hero_data = data
    if hero_data then
        local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
        if hero_data.clv and hero_data.clv > 0 then
            local upgrade_cfg = hero_upgrade[tonumber(hero_data.clv)]
            local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", "new_str_0075", upgrade_cfg.display_level)
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_22
        else
            local upgrade_cfg = hero_upgrade[tonumber(hero_data.lv)]
            local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", "new_str_0075", upgrade_cfg.display_level)
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        end
        local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
        local quality = hero_data.evo or 1
        local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
        local quality_data_item = GlobalConfig.QUALITY_FRAME[quality] or GlobalConfig.QUALITY_FRAME[1]
        local frame_name =""
        -- if is_big then
        --     frame_name = quality_item.card_frame_name3
        -- else
        --     frame_name = quality_item.card_frame_name3.."1"
        -- end
        frame_name = quality_item.hero_item_frame
        local quality_img = LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame_name, "hero_head_ui")
        -- if quality_item.is_add == true then
        LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", quality_data_item.big_frame_add_name, "hero_head_ui")
        -- end
        -- quality_up_img:SetActive(quality_item.is_add or quality > 10)
        quality_up_img:SetActive(quality_item.is_add)
        -- 显示品质等级
        GameUtil:updateHeroInfo(object, hero_data)
    else
        local lv_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", "1级")
        lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
    end
end

function M:createTeamHerosNode(team_node, rewards, scale, show_add, is_big)
    scale = scale or 1
    local rewards = rewards or {}
    UIUtil.destroyAllChild(team_node)
    for k,v in ipairs(rewards) do
        local item = nil
        if is_big then
            item = GameUtil:createPrefab("Common/HeroNode2")
        else
            item = GameUtil:createPrefab("Common/HeroNode")
        end
		if _G.next(v) then
            self:updateHeroElementByData(item, v, nil, is_big)
            self:updateHeroLvByData(item, v.hero_data, is_big)
		else
			self:updateHeroElementAdd(item, v, show_add)
		end
		UIUtil.setScale(item.transform, scale, scale)
        item.transform:SetParent(team_node, false)
    end
end

-- 3D模型展示
function M:createPlayerModel(rol_obj, user)
    if rol_obj == nil then return end
    local transform = rol_obj.transform
    UIUtil.destroyAllChild(transform)
    if user then
        local avatar = user.avatar or "0"  
        local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(checknumber(avatar))  
        if hero_cfg then
            local prefab_name = hero_cfg["prefab"]
            local obj = ResourceUtil:LoadRole3d(prefab_name)
            if obj then
                --local helper = obj:GetComponent("LuaTransformHelper")
                --helper:SetAnimator(true);
                obj.transform.localPosition = Vector3(0,0,0);
                obj.transform.localRotation = Quaternion.Euler(0,0,0);
                obj.transform:SetParent(rol_obj.transform, false)
                GlobalTools:CloseShadow(obj.transform)
            end
        end
    end
end

function M:setSegmentInfo(segment_node, cfg, show_name, atlas_name)
    if segment_node == nil then 
        return 
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(segment_node)
	local star_num = cfg.star_num or 0
    local offset_star = atlas_name and 10 or 0
    for i = 1, 9 do
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_" .. i + offset_star, i <= star_num)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"segment_stars",atlas_name == nil)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"segment_stars2",atlas_name ~= nil)
	
    atlas_name = atlas_name or "item_icon"
    LuaBehaviourUtil.setImg(luaBehaviour,"segment_img",cfg.division_icon,atlas_name)
    local segment_name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "segment_name_text", tostring(cfg.division_name))
    if show_name then
        segment_name_text.gameObject:SetActive(true)
    else
        segment_name_text.gameObject:SetActive(false)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"name_segment_img_bg",show_name == true)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "segment_rank_text", tostring(cfg.rank_min))
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"segment_rank_text",star_num == 0)
    local division = cfg.division or -1
    segment_name_text.color = GlobalConfig.ARENA_SEGMENT_COLLOR[division] or GlobalConfig.ARENA_SEGMENT_COLLOR[1]
end

function M:setCameraTargetNull(camera_obj)
    if not IsNull(camera_obj) then
        local camera = UIUtil.findCamera(camera_obj)
        camera.targetTexture = nil
    end
end

function M:setObjectPosByTarget(src_obj, target_obj)
    if IsNull(src_obj) or IsNull(target_obj) then
        return
    end
    local target_obj_trans = target_obj.transform
    local src_trans = src_obj.transform
    local pos = target_obj_trans.parent:TransformPoint(target_obj_trans.localPosition) --世界坐标
    pos = src_trans.parent:InverseTransformPoint(pos) -- 相对坐标
    src_trans.localPosition = pos
end

function M:updateBigHeroElement(obj, hero_data, hero_cfg, select_flag, look_flag, callback)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon, ResourceUtil:getLanAtlas())
    end
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[hero_cfg.type]
    if type_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon, "hero_ui")
    end
    local lv_text = luaBehaviour:FindText("lv_text")
    local evo = hero_cfg.evo
    local lv = 1
    if hero_data then
        evo =  hero_data.evo
        if hero_data.clv and hero_data.clv > 0 then
            lv = hero_data.clv
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_22
        else
            lv = hero_data.lv
            lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_1
        end
    end

    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[tonumber(lv)] or {}
    local show_lv = upgrade_cfg.display_level or 1
    local icon = hero_cfg.icon
    local cur_hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, hero_cfg)
    if cur_hero_skin_cfg then
        icon = cur_hero_skin_cfg.icon
    end
    local icon_name = "h_".. icon .."_l"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
    local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    local big_quality_data= GlobalConfig.QUALITY_FRAME[evo] or GlobalConfig.QUALITY_FRAME[1]
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", hero_cfg.name)
    if evo and evo > 11 then --白色之后加星
        GameUtil:updateHeroStarsByQuality(obj, evo)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", true)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang", quality_item.is_add)
    if quality_item.is_add and big_quality_data.big_frame_add_name then
        LuaBehaviourUtil.setImg(luaBehaviour, "kuang", big_quality_data.big_frame_add_name, "hero_head_ui")
    end
    local hero_img = luaBehaviour:FindGameObject("hero_img")
    local hero_bg = luaBehaviour:FindGameObject("hero_bg")
    GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. icon_name)
    GameUtil:updateResourcesImg(hero_bg, "Texture/HeroIcon/" .. big_quality_data.card_frame_name)
    local duigou_img = luaBehaviour:FindGameObject("duigou_img")
    duigou_img:SetActive(select_flag == true)
    if look_flag or callback then
        luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
            if callback then
                callback(click_object, click_name, idx, hero_data, hero_cfg)
            else
                if look_flag then
                    static_rootControl:openView("Pops.HeroLookInfo", {hero_id = hero_cfg.id, is_new = false})
                end
            end
        end)
    end
end

function M:updateMazeStageRelicElement(obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local lib_quality_item = GlobalConfig.HEIRLOOM_LIBRARY_QUALITY[cfg.quality] or GlobalConfig.HEIRLOOM_LIBRARY_QUALITY[3]
    LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", lib_quality_item.bg, "equip_icon")
    LuaBehaviourUtil.setImg(luaBehaviour, "quality_icon_img", lib_quality_item.icon, "common_ui")
    LuaBehaviourUtil.setImg(luaBehaviour, "icon_Img", cfg.icon, "item_icon")
    LuaBehaviourUtil.setImg(luaBehaviour, "attr_icon", cfg.type_icon, "language_zh_cn")
    local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cfg.name)
    local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[cfg.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
    name_text.color = quality_item.RGBA
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "detail_text", cfg.des)
end

return M
