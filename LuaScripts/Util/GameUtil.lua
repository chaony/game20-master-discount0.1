------------------- GameUtil
local __math_modf = math.modf
local __math_floor = math.floor
local __math_max = math.max

-- local __AudioHelper = CS.wt.framework.AudioHelper.Instance
local M = {}

local __ITEM_TITLE_SHOW = {[4] = 1, [5] = 1, [6] = 1, [7] = 1, [22] = 1}

local __application_platform = "Other"

if U3DUtil:Is_Platform("OSXEditor") or U3DUtil:Is_Platform("WindowsEditor") then
    __application_platform = "Editor"
elseif U3DUtil:Is_Platform("WindowsPlayer") then
    __application_platform = "Windows"
elseif U3DUtil:Is_Platform("Android") then
    __application_platform = "Android"
elseif U3DUtil:Is_Platform("IPhonePlayer") then
    __application_platform = "Ios"
else
    __application_platform = "Other"
end

-- 获取平台类型
function M:getpPlatform()
    return __application_platform
end


function M:updateToggleButton( object, ison )
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local checkmark = luaBehaviour:FindGameObject("Checkmark")
    checkmark:SetActive(ison)
end


-- 获取网络类型
function M:getNetworkReachability()
    return U3DUtil:Get_NetWorkMode()
end

--创建奇遇icon
function M:updateMedalElement(object, medal_id, isShowDetail, is_self, callback, frame_effect,show_effect)
    if object == nil or medal_id == nil then
        Logger.log("GameUtil fun updateMedalElement parameter error！！！")
        return
    end
    local dataTable = ConfigManager:getMedalCfgById(medal_id)
    local ui_element = {}
    if dataTable ~= nil and type(dataTable) =="table" then
        local luaBehaviour = UIUtil.findLuaBehaviour(object)
        luaBehaviour:InjectionFunc()
        local item_img = LuaBehaviourUtil.setImg(luaBehaviour, "item_img", dataTable.icon, dataTable.atlas_name or "pub_ui")
        ui_element.item_img = item_img
        item_img.enabled = true
        UIUtil.destroyAllChild(item_img.transform)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_img", false)
        local function clickCallback()
            if isShowDetail then
                static_rootControl:openView("Options.MedalInfoPop", {id = medal_id, lookSelf = is_self})
            end
            if type(callback) == "function" then
                callback(object, data)
            end
        end
        UIUtil.setButtonClick(object, clickCallback)
        return ui_element
    end
end

-- 通用道具元素创建
function M:createItemElement(dataTable, isShowNum, isShowDetail, callback, frame_effect,show_effect)
    local item = ResourceUtil:LoadUIGameObject("Common/ItemNode", Vector3.zero, nil)
    local ui_element = self:updateItemElement(item, dataTable, isShowNum, isShowDetail, callback, frame_effect,show_effect)
    return item, ui_element
end

function M:updateItemElement(object, dataTable, isShowNum, isShowDetail, callback, frame_effect,show_effect)
    if object == nil or type(dataTable) ~= "table" then
        Logger.log("GameUtil fun updateItemElement parameter error！！！")
        return
    end

    local data = RewardUtil:getProcessRewardData(dataTable)
    local ui_element = self:updateItemElementByData(object, data, isShowNum, isShowDetail, callback, frame_effect,show_effect)
    ui_element.process_data = data
    return ui_element
end

-- 通用道具元素创建
function M:createItemElementByData(data, isShowNum, isShowDetail, callback, parent, frame_effect,show_effect)
    local item = self:createPrefab("Common/ItemNode", parent)
    local ui_element = self:updateItemElementByData(item, data, isShowNum, isShowDetail, callback, frame_effect,show_effect)
    return item, ui_element
end

--show_effect 是否展示装备特效
function M:updateItemElementByData(object, data, isShowNum, isShowDetail, callback, frame_effect, show_effect)
    local ui_element = {}
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    luaBehaviour:InjectionFunc()
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour, "item_img", data.icon_name, data.atlas_name or "item_icon")
    ui_element.item_img = item_img
    item_img.enabled = true
    UIUtil.destroyAllChild(item_img.transform)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "privilege_text", "privilege_tex")
    local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", GameUtil:formatValueToString(data.data_num))
    local title_node = luaBehaviour:FindGameObject("title_node")
    local title_text = luaBehaviour:FindText("title_text")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local stars = luaBehaviour:FindGameObject("stars")
    local star_bg = luaBehaviour:FindGameObject("star_bg")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local equip_add = luaBehaviour:FindGameObject("equip_add")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    local apostle_img = luaBehaviour:FindGameObject("apostle_img")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local used_img = luaBehaviour:FindGameObject("used_img")
    local add_panel = luaBehaviour:FindGameObject("add_panel")
    local piece_img = luaBehaviour:FindGameObject("piece_img")
    local piece_mask = luaBehaviour:FindGameObject("piece_mask")
    local piece_duigou = luaBehaviour:FindGameObject("piece_duigou")
    local center_text = luaBehaviour:FindGameObject("center_text")
    local select_image = luaBehaviour:FindGameObject("select_image")
    local inten_lv = luaBehaviour:FindGameObject("inten_lv")
    local fristReward = luaBehaviour:FindGameObject("fristReward")
    local hero_equip = luaBehaviour:FindGameObject("hero_equip")
    local t_corner_mark = luaBehaviour:FindGameObject("equip_t_corner_mark")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local camp_text = luaBehaviour:FindGameObject("camp_text")
    local fate_icon_img = luaBehaviour:FindGameObject("fate_icon_img")
    ui_element.red_point_img = red_point_img
    ui_element.duigoudi_img = duigoudi_img
    ui_element.fate_icon_img = fate_icon_img
    ui_element.luaBehaviour = luaBehaviour
    apostle_applay_img:SetActive(false)
    quality_up_img:SetActive(false)
    inten_lv:SetActive(false)
    center_text:SetActive(false)
    apostle_img:SetActive(false)
    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    piece_img:SetActive(false)
    piece_mask:SetActive(false)
    piece_duigou:SetActive(false)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    stars:SetActive(false)
    star_bg:SetActive(false)
    tips_img:SetActive(false)
    camp_img:SetActive(false)
    camp_bg:SetActive(false)
    lv_bg_img:SetActive(false)
    used_img:SetActive(false)
    select_image:SetActive(false)
    if t_corner_mark then
        t_corner_mark:SetActive(false)
    end
    if equip_add then
        equip_add:SetActive(false)
    end
    if type_img then
        type_img:SetActive(false)
    end
    if camp_text then
        camp_text:SetActive(false)
    end
    count_text_bg_img:SetActive(isShowNum and data.data_num > 1)
    count_text.gameObject:SetActive(isShowNum and data.data_num > 1)
    if fristReward ~= nil then
        fristReward:SetActive(false)
        if data.isFristReward == true then
            fristReward:SetActive(true)
        end
    end
    if hero_equip then
        hero_equip:SetActive(false)
    end
    -- count_text_bg_img:SetActive(false)
    UIUtil.destroyAllChild(add_panel.transform)
    local frame_name = nil
    local quality_img = nil
    local quality_item = nil
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.SEAL_CHARACTER then
        camp_img:SetActive(true)
        local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
        if race_data then
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
        end
        if data.data_type == RewardUtil.REWARD_TYPE_KEYS.SEAL_CHARACTER then
            camp_img:SetActive(false)
        end
        quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
        frame_name = quality_item.hero_item_frame
        quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
        quality_up_img:SetActive(quality_item.is_add == true)
        if quality_item.is_add then
            LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", quality_item.add_img, "hero_head_ui")
        end
        if data.oid then
            local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(data.oid)
            self:updateHeroLvByData(object, hero_data)
        end
        if data.quality and data.quality > 11 then --白色之后加星
            self:updateHeroInfo(object, data)
        else
            self:setDateIcon(object,false)
        end
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
        quality_item = GlobalConfig.QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        frame_name = quality_item.mystic_frame_name
        quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "equip_icon")
        quality_up_img:SetActive(false)
        local type_data = GlobalConfig.TYPE_MYSTIC[data.item_cfg.type]
        if type_data then
            camp_img:SetActive(true)
            LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", type_data.pro_icon,  ResourceUtil:getLanAtlas())
        end
        local class_meridian = GlobalConfig.CLASS_MERIDIAN[data.item_cfg.role_type or 0] or 0
        if class_meridian == 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"type_img",false)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"type_img",true)
            LuaBehaviourUtil.setImg(luaBehaviour, "type_img", class_meridian.pro_icon,  ResourceUtil:getLanAtlas())
        end
    else
        quality_item = GlobalConfig.QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        frame_name = quality_item.frame_name
        quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "equip_icon")
        if data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
            if __ITEM_TITLE_SHOW[data.item_cfg.type] then
                title_node:SetActive(true)
                local effect = data.item_cfg.effect or 0
                title_text.text = Language:getTextByKey("new_str_0061", effect / 3600)
            end
            if data.item_cfg.sort == 4 or data.item_cfg.sort == 28 then -- 秘籍残页
                item_img.enabled = false
                local mystic_piece_icon = self:createPrefab("Common/MysticPieceIcon", item_img.transform)
                local mystic_lua_behaviour = UIUtil.findLuaBehaviour(mystic_piece_icon)
                LuaBehaviourUtil.setImg(mystic_lua_behaviour, "item_img", data.icon_name, data.atlas_name or "item_icon")
                local mystic_quality_item = GlobalConfig.MYSTIC_ICON_COMMON_SETTING[data.quality]
                if mystic_quality_item then
                    LuaBehaviourUtil.setImg(mystic_lua_behaviour, "item_img_mask", mystic_quality_item.mask_img, "item_icon")
                    LuaBehaviourUtil.setImg(mystic_lua_behaviour, "item_img_di", mystic_quality_item.icon_img_di, "item_icon")
                end
            elseif data.item_cfg.sort == 5 then -- 侠客好感道具
                camp_img:SetActive(true)
                LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", "a_zd_sz_juesezhenying_di", "common_ui")
                if camp_text then
                    camp_text:SetActive(true)
                end
                local sub_type_cfg = GlobalConfig.HERO_FETTER_TYPE[data.item_cfg.sub_type or 1]
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "camp_text", sub_type_cfg.name)
            end
        elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
            if data.oid then
                local equip_data = UserDataManager.equip_data:getEquipDataById(data.oid)
                self:updateItemEquipInfo(object, equip_data, data)
            else
                self:updateItemEquipInfo(object, nil, data)
            end
        elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIP_AFFIX then
            self:updateItemEquipInfo(object, nil, data)
        elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.ARTIFACTS then
            
        elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.PETS then
            title_node:SetActive(false)
            frame_name = quality_item.pet_frame
            quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "equip_icon")
            LuaBehaviourUtil.setImg(luaBehaviour, "item_img", data.icon_name, data.atlas_name or "item_icon")

        elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEIRLOOM then
            --显示奇物标签
            if t_corner_mark then
                t_corner_mark:SetActive(true)
            end
            local c_mark_img = LuaBehaviourUtil.setImg(luaBehaviour, "c_mark_img", "a_sh_qiwu_di", "common_ui")
            if c_mark_img then
                c_mark_img:SetNativeSize()
            end
        end
    end
    if show_effect == nil or show_effect and show_effect == true then
        self:creatEffectForEquip(object, data)
    end
    ui_element.quality_img = quality_img
    piece_img:SetActive(data.is_piece or data.item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_CHANGE_HERO)
    piece_mask:SetActive(data.is_piece)
    piece_duigou:SetActive(data.is_piece)
    if isShowNum == true then
        count_text.gameObject:SetActive(true)
    else
        count_text.gameObject:SetActive(false)
    end
    local temp_piece_img = nil
    if data.item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_CHANGE_HERO then
        temp_piece_img = LuaBehaviourUtil.setImg(luaBehaviour, "piece_img", "a_xkyc_jiaobiao", "common_ui")
    else
        temp_piece_img = LuaBehaviourUtil.setImg(luaBehaviour, "piece_img", "icon_suipian", "common_ui")
    end
    if temp_piece_img then
        temp_piece_img:SetNativeSize()
    end
    if frame_effect and quality_item and quality_item.item_effect then
        --Logger.log(quality_item.item_effect, "quality_item.item_effect ==")
        local effect_obj = ResourceUtil:LoadCommonEffect(quality_item.item_effect, nil)
        UIUtil.setScale(effect_obj.transform, 1.3)
        effect_obj.transform.position = Vector3.zero
        effect_obj.transform:SetParent(add_panel.transform, false)
    elseif data.item_cfg.UI_effect ~= nil and data.item_cfg.UI_effect ~= "" then
        local effect_obj = ResourceUtil:GetUIEffectItem("ItemNode/"..data.item_cfg.UI_effect, nil)
        UIUtil.setScale(effect_obj.transform, 1.3)
        effect_obj.transform.position = Vector3.zero
        effect_obj.transform:SetParent(add_panel.transform, false)
    end
    

    local function clickCallback()
        if isShowDetail then
            if data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
                static_rootControl:closeView("HeroInfo.EquipmentPop",nil, false)
                if data.oid then
                    static_rootControl:openView("HeroInfo.EquipmentPop", {equip_id = data.oid})
                else
                    static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg_id = data.data_id, race = data.race, look_model = 3})
                end
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIP_AFFIX then
                static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg = data, look_model = 3, affix = true})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
                local tempCfg = data.item_cfg
                if tempCfg and (tempCfg.sort == 1) and (tempCfg.type == 1) and tempCfg.effect ~= nil and tempCfg.effect[1] ~= nil then
                    --- 阵营白色武器随机箱奖励特殊处理
                    local random_chest = ConfigManager:getCfgByName("random_chest") or {}
                    local tempEftData = tempCfg.effect[1]
                    local random_chest_item = random_chest[tempEftData[2]]
                    if random_chest_item then
                        local sort = random_chest_item.sort
                        local configs = random_chest_item.configs or {}
                        if sort == 2 then -- 赛季展示
                            local index, season = self:getCurSeasonRewardIndex(configs)
                            if configs[index] and configs[index].rewards then
                                tempCfg.content_show = configs[index].rewards
                            end
                        end
                    end
                end
                static_rootControl:closeView("Item.ItemDetail",nil, false)
                static_rootControl:openView("Item.ItemDetail", {show_data = data, display = true})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
                static_rootControl:closeView("Pops.HeroLookInfo",nil, false)
                static_rootControl:openView("Pops.HeroLookInfo", {hero_id = data.data_id, is_new = false})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
                --local hero_id = data.item_cfg.hero
                static_rootControl:closeView("Pops.HeroSkinLookInfo",nil, false)
                static_rootControl:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = data.data_id})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
                static_rootControl:closeView("SutraDepository.DepositoryPop",nil, false)
                static_rootControl:openView("SutraDepository.DepositoryPop", {oid = data.data_id, mode = 2})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
                static_rootControl:closeView("Title.TitleDetailp",nil, false)
                static_rootControl:openView("Title.TitleDetail", {show_data = data, display = true})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.MEDAL then --奇遇详情
                static_rootControl:openView("Options.MedalInfoPop", {id = data.data_id})
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.PETS then -- 宠物展示
                static_rootControl:closeView("PetBreeding.PetGetNewPop",nil, false)
                static_rootControl:openView("PetBreeding.PetGetNewPop", {cid = data.data_id, is_new = false})
            --elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.GHW_COIN then -- 巅峰币
            --    static_rootControl:openView("Shop", {shop_type = 34})
            --    --QuickOpenFuncUtil:openFunc(43)
            else
                static_rootControl:closeView("Pops.CommonItemTipsPop",nil, false)
                static_rootControl:openView("Pops.CommonItemTipsPop", {data = data, target_obj = item_img.gameObject})
            end
        end
        if type(callback) == "function" then
            callback(object, data)
        end
    end
    UIUtil.setButtonClick(object, clickCallback)
    return ui_element
end

-- 获取当前赛季的Index,和赛季
function M:getCurSeasonRewardIndex(configs)
    local cur_season = UserDataManager:getCurSeason() -- 获取赛季
    local season = 0
    local index = 1
    for idx, item in ipairs(configs) do
        if item.param <= cur_season and item.param >= season then
            season = item.param
            index = idx
        end
    end
    return index, season
end

function M:clickItemByData(data, dataTable, obj)
    local rewardCfg = nil
    if data == nil then
        rewardCfg = RewardUtil:getProcessRewardData(dataTable)
    else
        rewardCfg = data
    end
    if data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
        static_rootControl:closeView("HeroInfo.EquipmentPop",nil, false)
        if data.oid then
            static_rootControl:openView("HeroInfo.EquipmentPop", {equip_id = data.oid})
        else
            static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg_id = data.data_id, look_model = 3})
        end
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIP_AFFIX then
        static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg = data, look_model = 3, affix = true})
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
        static_rootControl:closeView("Item.ItemDetail",nil, false)
        static_rootControl:openView("Item.ItemDetail", {show_data = data, display = true})
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
        static_rootControl:closeView("Pops.HeroLookInfo",nil, false)
        static_rootControl:openView("Pops.HeroLookInfo", {hero_id = data.data_id, is_new = false})
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
        --local hero_id = data.item_cfg.hero
        static_rootControl:closeView("Pops.HeroSkinLookInfo",nil, false)
        static_rootControl:openView("Pops.HeroSkinLookInfo", {is_new = false, skin_id = data.data_id})
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
        static_rootControl:closeView("SutraDepository.DepositoryPop",nil, false)
        static_rootControl:openView("SutraDepository.DepositoryPop", {oid = data.data_id, mode = 2})
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
        static_rootControl:closeView("Title.TitleDetailp",nil, false)
        static_rootControl:openView("Title.TitleDetail", {show_data = data, display = true})
    elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.PETS then -- 宠物展示
        static_rootControl:closeView("PetBreeding.PetGetNewPop",nil, false)
        static_rootControl:openView("PetBreeding.PetGetNewPop", {cid = data.data_id, is_new = false})
    else
        if not IsNull(obj) then
            static_rootControl:closeView("Pops.CommonItemTipsPop",nil, false)
            static_rootControl:openView("Pops.CommonItemTipsPop", {data = data, target_obj = obj})
        end
    end
end



--金色装备和红色装备创建特效
function M:creatEffectForEquip(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LODUtil:isShowUiFx() and luaBehaviour then
        local back_effect = luaBehaviour:FindGameObject("back_effect")
        local front_effect = luaBehaviour:FindGameObject("front_effect")
        if back_effect and front_effect then
            UIUtil.destroyAllChild(back_effect.transform)
            UIUtil.destroyAllChild(front_effect.transform)
            if data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
                -- 修改品质特效规则，删除橙品、红品的特效，白及以上显示红品特效
                if data.item_cfg and data.item_cfg.type == 0 then
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Glow_002", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    return
                end
                local quality = data.quality or 0
                if quality >= 12 then
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_004", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif quality == 11 then
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_003", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif quality == 10 then
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_002", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif quality == 9 or quality == 8  then
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_001", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif quality >= 7 then
                    local eqp_effect = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_back", obj)
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_front", obj)
                    eqp_effect.transform:SetParent(back_effect.transform, false)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect.transform.localPosition = Vector3(0,0,0)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                end
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS then
                -- 修改品质特效规则，删除橙品、红品的特效，白及以上显示红品特效
                local quality = data.quality or 0
                if quality >= 20 then
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_003", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif quality >= 14 then --白
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_001", obj)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif quality >= 10 then
                    local eqp_effect = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_back", obj)
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_front", obj)
                    eqp_effect.transform:SetParent(back_effect.transform, false)
                    eqp_effect2.transform:SetParent(front_effect.transform, false)
                    eqp_effect.transform.localPosition = Vector3(0,0,0)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                end
            elseif data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
                if data.item_cfg and data.item_cfg.type == 3 then
                    local quality = data.quality or 0
                    if quality >= 12 then
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_004", obj)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    elseif quality >= 8 then
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_002", obj)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    elseif quality >= 7 then
                        local eqp_effect = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_back", obj)
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_front", obj)
                        eqp_effect.transform:SetParent(back_effect.transform, false)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect.transform.localPosition = Vector3(0,0,0)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    end
                else
                    local quality = data.quality or 0
                    if quality >= 12 then
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_004", obj)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    elseif quality == 11 then
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_003", obj)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    elseif quality == 10 then
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_002", obj)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    elseif quality == 9 then
                        local eqp_effect2 = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_001", obj)
                        eqp_effect2.transform:SetParent(front_effect.transform, false)
                        eqp_effect2.transform.localPosition = Vector3(0,0,0)
                    end
                end
            end
        end
    end
end


function M:updateItemEquipInfo(object, data, reward_data, hero_oid)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local stars = luaBehaviour:FindGameObject("inten_lv")
    local hero_equip = luaBehaviour:FindGameObject("hero_equip")
    local t_corner_mark = luaBehaviour:FindGameObject("equip_t_corner_mark")
    local type_img = luaBehaviour:FindGameObject("type_img")
    local type_num = 1
    if t_corner_mark then
        t_corner_mark:SetActive(false)
    end
    if type_img then
        type_img:SetActive(false)
    end
    if hero_oid == nil then
        if hero_equip then
            hero_equip:SetActive(false)
        end
    else
        local herodata, herocfg = UserDataManager.hero_data:getHeroDataById(hero_oid)
        if hero_equip then
            if herodata then
                hero_equip:SetActive(true)
                local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, herodata.id, 0})
                LuaBehaviourUtil.setImg(luaBehaviour, "tx_img", reward_data.icon_name, reward_data.atlas_name)  
            else
                hero_equip:SetActive(false)    
            end
        end    
    end
    if reward_data == nil and data then
        reward_data = RewardUtil:getProcessRewardData({102, data.id, 0, data.oid})
    end
    if reward_data and reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
        local eqp_data = GlobalConfig.QUALITY_COMMON_SETTING[reward_data.quality]
        local eqp_type_data = GlobalConfig.TYPE_HERO_PROPERTY[reward_data.item_cfg.type]
        type_num = reward_data.item_cfg.type
        if eqp_type_data and reward_data.item_cfg.type > 0 then
            LuaBehaviourUtil.setImg(luaBehaviour, "type_img", "zbjb_leixing_0"..reward_data.item_cfg.type, ResourceUtil:getLanAtlas())
            if type_img then
                type_img:SetActive(true)
            end
        end
    end
    if reward_data and reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS and reward_data.quality >= 12 then 
        for i = 1,5 do
            LuaBehaviourUtil.setImg(luaBehaviour, "inten_lv"..i, "a_ui_currency_ws_xingji", "equip_icon")
        end
    else
        for i = 1,5 do
            LuaBehaviourUtil.setImg(luaBehaviour, "inten_lv"..i, "a_ui_currency_dj_xinji", "equip_icon")
        end
    end
    if IsNull(stars) then
        return
    end
    local race = 0
    if data then
        race = data.race or 0
        -- 显示升级等级
        local lv = data.lv or 0
        if lv > 0 then
            stars:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("inten_lv" .. i)
                if star then
                    star:SetActive(i <= lv)
                end
            end
        end
    else
        stars:SetActive(false)
    end
    if race == 0 and reward_data then
        race = reward_data.race or 0
    end
    camp_img:SetActive(true)
    if race >= 0 then
        local race_data = GlobalConfig.TYPE_HERO_RACE[race]
        -- 字段拼接 zbjb_0+装备种族属性_"根据品质分 getEquipLevel "
        if race <= 0 then
            race = 0
        end
        local equ_lv = self:getEquipLevel(reward_data.quality)
        local eqp_jb_str = "zbjb_0"..race.."_0"..equ_lv
        LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", eqp_jb_str,  ResourceUtil:getLanAtlas())
        if race == 0 then
            if reward_data.oid or (data and data.oid) then
                if reward_data.quality <= 8 then
                    camp_img:SetActive(false)     
                end
            else
                if reward_data.quality < 8 then
                    camp_img:SetActive(false)     
                end
            end    
        end
    else
        local eqp_jb_str = "a_ui_currency_icon_wenhao"
        if race == -2 then
            eqp_jb_str = "a_ui_currency_icon_wenhao"
        end
        LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", eqp_jb_str,  ResourceUtil:getLanAtlas())
        if reward_data.quality < 8 then
            camp_img:SetActive(false)   
        end
    end

    -- if reward_data.quality >= 12 then
    --     camp_img:SetActive(false)
    -- end
end

function M:updateHeroLvByData(object, data)
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local lv_text = luaBehaviour:FindText("lv_text")
    lv_bg_img:SetActive(true)
    local hero_data = data or {lv = 1}
    if hero_data.clv and hero_data.clv > 0 then
        lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_22
        local upgrade_cfg = hero_upgrade[tonumber(hero_data.clv)]
        lv_text.text = string.format(Language:getTextByKey("new_str_0075"), upgrade_cfg.display_level)
    else
        lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_3
        local upgrade_cfg = hero_upgrade[tonumber(hero_data.lv)]
        lv_text.text = string.format(Language:getTextByKey("new_str_0075"), upgrade_cfg.display_level)
    end
end

function M:updateArtifactInfo(object, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local stars = luaBehaviour:FindGameObject("stars")
    if data then
        if data.lv > 0 then
            stars:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("star_" .. i)
                if star then
                    star:SetActive(i <= data.lv)
                end
            end
        end
    end
end

--更新专属武器
function M:updateExclusiveWeaponsInfo(object, hero_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local title_node = luaBehaviour:FindGameObject("title_node")
    local title_text = luaBehaviour:FindText("title_text")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local stars = luaBehaviour:FindGameObject("stars")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local equip_add = luaBehaviour:FindGameObject("equip_add")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local camp_bg = luaBehaviour:FindGameObject("camp_bg")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local apostle_applay_img = luaBehaviour:FindGameObject("apostle_applay_img")
    local apostle_img = luaBehaviour:FindGameObject("apostle_img")
    local piece_img = luaBehaviour:FindGameObject("piece_img")
    local count_text = luaBehaviour:FindGameObject("count_text")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local ex_we_text = luaBehaviour:FindText("ex_we_text")
    count_text_bg_img:SetActive(false)
    ex_we_bg:SetActive(false)
    count_text:SetActive(false)
    piece_img:SetActive(false)
    apostle_applay_img:SetActive(false)
    apostle_img:SetActive(false)
    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    stars:SetActive(false)
    tips_img:SetActive(false)
    camp_img:SetActive(false)
    camp_bg:SetActive(false)
    lv_bg_img:SetActive(false)
    quality_up_img:SetActive(false)
    equip_add:SetActive(false)
    local frame_name = nil
    local quality_img = nil
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(hero_id)
    local tab = ConfigManager:getCfgByName("equip_heroes")
    local ex_cfg = tab[hero_cfg.equip_heroes_id]
    if ex_cfg then
        local item_img = LuaBehaviourUtil.setImg(luaBehaviour, "item_img", ex_cfg.icon, "equip_icon")
        local cur_data = ex_cfg.level_up[hero_data.sig.lv]
        local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[cur_data.quality] or GlobalConfig.QUALITY_COMMON_SETTING[1]
        frame_name = quality_item.card_frame_name
        quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
        quality_up_img:SetActive(quality_item.is_add)
        if hero_data.sig.lv > 0 then
            ex_we_bg:SetActive(true)
            ex_we_text.text = "+" .. hero_data.sig.lv
        end
    end
end

function M:updateHeroInfo(object, data)
    if data then
        local is_fate = false
        if data.oid ~= nil then
            is_fate = UserDataManager:getHeroIsFates(data.oid)
        end
        if is_fate then --点亮了天命化星
            self:getFateIcon(object)
        else --没点亮天命化星
            local quality = data.quality
            self:updateHeroStarsByQuality(object, quality)
        end
    end
end

--配置显示天命图标
function M:getFateIcon(object)
    self:setDateIcon(object,true)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local stars = luaBehaviour:FindGameObject("stars")
    stars:SetActive(false)
end

function M:setDateIcon(object,is_show)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local fate_icon_img = luaBehaviour:FindGameObject("fate_icon_img")
    if fate_icon_img ~= nil then
        fate_icon_img:SetActive(is_show)
    end
end

----配置显示天命图标（废弃）
--function M:getFateIcon(object)
--    local luaBehaviour = UIUtil.findLuaBehaviour(object)
--    local fate_icon_img = luaBehaviour:FindGameObject("fate_icon_img")
--    if fate_icon_img ~= nil then
--        fate_icon_img:SetActive(true)
--    end
--    local stars = luaBehaviour:FindGameObject("stars")
--    stars:SetActive(false)
--end

function M:updateHeroStarsByQuality(object, quality)
    quality = quality or 1
    self:setDateIcon(object,false)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local fate_icon_img = luaBehaviour:FindGameObject("fate_icon_img")
    if fate_icon_img ~= nil then
        fate_icon_img:SetActive(false)
    end
    local stars = luaBehaviour:FindGameObject("stars")
    local star_bg = luaBehaviour:FindGameObject("star_bg")
    if star_bg == nil then
        star_bg = luaBehaviour:FindGameObject("star_bg_img")
    end
    local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    for i = 1,5 do
        local card_name = quality_item.card_frame_name.."_big_xing"
        -- if i == 1 then
        --     LuaBehaviourUtil.setImg(luaBehaviour, "star_" .. i, quality_item.add_img, "hero_head_ui")
        -- else
            LuaBehaviourUtil.setImg(luaBehaviour, "star_" .. i, card_name, "hero_head_ui")  
        -- end
    end
    if quality_item.hero_star then
        stars:SetActive(true)
        if star_bg then
            if quality_item.hero_star > 1 then
                star_bg:SetActive(true)
            else
                star_bg:SetActive(false)
            end
           
        end
        for i = 1, 5 do
            local star = luaBehaviour:FindGameObject("star_" .. i)
            if star then
                star:SetActive(quality_item.hero_star >= i)
            end
        end

    else
        stars:SetActive(false)
        if star_bg then
            star_bg:SetActive(false)
        end
    end
    -- 显示升级等级
    --local lv = quality - 11 or 0
    --if lv > 0 then
    --    stars:SetActive(true)
    --    if star_bg then
    --        star_bg:SetActive(true)
    --    end
    --    for i = 1, 5 do
    --        local star = luaBehaviour:FindGameObject("star_" .. i)
    --        if star then
    --            star:SetActive(i <= lv)
    --        end
    --    end
    --end
end

function M:updateMysticInfo(object, data)
    if data then
        local luaBehaviour = UIUtil.findLuaBehaviour(object)
        local stars = luaBehaviour:FindGameObject("stars")
        if stars==nil then
            return
        end
        local star_bg = luaBehaviour:FindGameObject("star_bg")
        -- 显示升级等级
        --local lv = data.quality - 5 or 0
        local lv = data.star or 0
        if lv > 0 then
            stars:SetActive(true)
            star_bg:SetActive(true)
            for i = 1, 5 do
                local star = luaBehaviour:FindGameObject("star_" .. i)
                if star then
                    star:SetActive(i <= lv)
                end
            end
        end
    end
end

-- 刷新空的道具格子
function M:updateItemElementNoData(object, itemType, data, callback)
    local ui_element = {}
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local add_img = luaBehaviour:FindGameObject("add_img")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local stars = luaBehaviour:FindGameObject("stars")
    local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
    local star_bg = luaBehaviour:FindGameObject("star_bg")
    have_panel:SetActive(false)
    no_panel:SetActive(true)
    up_image:SetActive(false)
    lock_image:SetActive(false)
    red_point_img:SetActive(false)
    no_quality_up_img:SetActive(false)
    stars:SetActive(false)
    star_bg:SetActive(false)
    ui_element.add_img = add_img
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_up_img", false)
    local fate_icon_img = luaBehaviour:FindGameObject("fate_icon_img")
    if fate_icon_img ~= nil then
        fate_icon_img:SetActive(false)
    end
    if itemType == RewardUtil.REWARD_TYPE_KEYS.HEROS then
        LuaBehaviourUtil.setImg(luaBehaviour, "no_quality_img", "xs_tianjiatouxiang", "equip_icon")
    else
    end

    local function clickCallback()
        if type(callback) == "function" then
            callback(object, data)
        end
    end
    UIUtil.setButtonClick(object, clickCallback)
    return ui_element
end

-- 通用英雄卡牌创建
function M:createHeroCell(heroOid, callback)
    local hero = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
    self:updateHeroContent(hero, heroOid, callback)
    return hero
end

function M:creatBaseHeroCell(data, callback)
    local hero = ResourceUtil:LoadUIGameObject("Main/MainHeroNodeCell", Vector3.zero, nil)
    self:updateHeroContentByRewardData(hero, data, callback)
    return hero
end

--刷新英雄数据
function M:updateHeroContent(obj, heroOid)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroContent obj error！！！")
        return
    end
    
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(heroOid)
    self:updateHeroContentByData(obj, hero_data, hero_cfg)
end

-- 通用奖励格式刷新
function M:updateHeroContentByRewardData(obj, data, callback)
    local reward_data = RewardUtil:getProcessRewardData(data)
    local hero_data = nil
    if reward_data.oid then
        hero_data = UserDataManager.hero_data:getHeroDataById(reward_data.oid)
    end
    self:updateHeroContentByData(obj, hero_data, reward_data.item_cfg, nil, nil, callback)
end

function M:updateHeroContentByData(obj, hero_data, hero_cfg, select_flag, look_flag, callback)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
    end
    self:updateSpByData(luaBehaviour,hero_cfg)

    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[hero_cfg.type]
    if type_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon, "hero_ui")
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "weihuode_text", "wei_hd_tex")
    local evo = hero_cfg.evo
    local lv = 0
    local show_lv = ""
    local lv_text_color = nil
    if hero_data then
        evo =  hero_data.evo or evo
        if hero_data.clv and hero_data.clv > 0 then
            lv = hero_data.clv
            lv_text_color = GlobalConfig.COMMON_COLLOR.COMMON_22
        else
            lv = hero_data.lv
            lv_text_color = GlobalConfig.COMMON_COLLOR.COMMON_1
        end
    end
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[tonumber(lv)] or {}
    show_lv = upgrade_cfg.display_level or 1
    local icon = hero_cfg.icon
    local cur_hero_skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData(hero_data, hero_cfg)
    if cur_hero_skin_cfg and next(cur_hero_skin_cfg) then
        icon = cur_hero_skin_cfg.icon
        if hero_data ~= nil and hero_data.showSkinQuality == true and cur_hero_skin_cfg.skin_quality ~= 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skin_quality", true)
            LuaBehaviourUtil.setImg(luaBehaviour, "skin_quality", GlobalConfig.HERO_SKIN_QUALITY[cur_hero_skin_cfg.skin_quality].icon, ResourceUtil:getLanAtlas())
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skin_quality", false)
        end
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skin_quality", false)  
    end
    if hero_cfg.islink == 1 or hero_cfg.id > 700 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "linkage_obj", true)
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "linkage_obj", false) 
    end

    local icon_name = "h_".. icon .."_l"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
    local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    local big_quality_data= GlobalConfig.QUALITY_FRAME[evo] or GlobalConfig.QUALITY_FRAME[1]
    local lv_text =  LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text", "new_str_0075", show_lv)

     if lv_text and lv_text_color then
         lv_text.color = lv_text_color
     end
    
    LuaBehaviourUtil.setText(luaBehaviour,"name_text", Language:getTextByKey(hero_cfg.name))
    --if evo and evo > 11 then --白色之后加星
    local is_fate = false
    if hero_data ~= nil and hero_data.oid ~= nil then
        is_fate = UserDataManager:getHeroIsFates(hero_data.oid)
    end
    if is_fate then
        self:getFateIcon(obj)
    else
        self:updateHeroStarsByQuality(obj, evo)
    end
    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", true)
    --end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang", quality_item.is_add)
    if quality_item.is_add and big_quality_data.big_frame_add_name then
        local img=LuaBehaviourUtil.setImg(luaBehaviour, "kuang", big_quality_data.big_frame_add_name, "hero_head_ui")
        img:SetNativeSize()
    end
    local hero_img = luaBehaviour:FindGameObject("hero_img")
    local hero_bg = luaBehaviour:FindGameObject("hero_bg")
    GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. icon_name)
    GameUtil:updateResourcesImg(hero_bg, "Texture/HeroIcon/" .. big_quality_data.card_frame_name)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", false)
    if look_flag or callback then
        luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
            if callback then
                callback(click_object, click_name, idx, hero_data, hero_cfg)
            else
                if look_flag and hero_cfg then
                    static_rootControl:openView("Pops.HeroLookInfo", {hero_id = hero_cfg.id, is_new = false})
                end
            end
        end)
    end
    self:updateBigHeroCardEffect(obj, evo)
end

function M:updateSpByData(luaBehaviour,hero_cfg)
    if hero_cfg.is_sp then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img",hero_cfg.is_sp>0) --SP侠客标识
        local typeData=nil
        if hero_cfg.is_sp>0 then
            typeData=GlobalConfig.SP_TYPE_SETTING[hero_cfg.is_sp]
            LuaBehaviourUtil.setImg(luaBehaviour,"sp_img",typeData.icon,"hero_ui")
        end
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sp_img",false)
    end
end

function M:updateBigHeroHpSlider(object, hp_value, qi_value)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hp_obj", true)
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

--宠物卡牌数据刷新
function M:updatePetContentByData(obj, data, callback, mode)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_bg", true) 
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "skin_quality", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "camp_img", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pet_generation_img", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "qishi_img", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mood_img", false)
    local generation_data  = self:getPetInfoByData(data)
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_generation_text", generation_data.evo_text)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_type_text", "pet_bag_text_0020")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "qishi_text", "pet_douji_text_05")
 
    local power = 0
    if data and data.attrs and data.attrs.power then
        power =  data.attrs.power
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "qishi_num_text", math.ceil(power))
    local mood = 0
    if data and data.mood then
        mood =  data.mood
    end
    if mood > 0 then
        local mood_tab = ConfigManager:getCfgByName("mood_random")
        local mood_cfg = mood_tab[data.mood] or  mood_tab[1]
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mood_img", true)
        LuaBehaviourUtil.setImg(luaBehaviour, "mood_img", mood_cfg.icon, "main_ui2")
    end
    local cur_pet_cfg = UserDataManager.pet_data:getPetConfigByCid(data.id)
    local icon_name = "h_".. cur_pet_cfg.icon .."_l"
    local hero_img = luaBehaviour:FindGameObject("hero_img")
    local hero_bg = luaBehaviour:FindGameObject("hero_bg")
    GameUtil:updateResourcesImg(hero_bg, "Texture/HeroIcon/" .. generation_data.big_bg)
    GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/" .. icon_name)
    if data.lv then
        local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
        if upgradeCfg[data.lv] then
            local level = upgradeCfg[data.lv].display_level
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", level)
        end
    end
    if mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_type_text", "pet_bag_text_0019")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "qishi_img", true)
    end
    local skill_id = 0
    local skill_type_2 = false --是否有协战技能
    for k,v in pairs(data.skills) do
        if mode == GlobalConfig.BATTLE_MODE.PET_DOUJI then
            if self:checkPetSkillType(v) == 1 then
                skill_type_2 = true
                skill_id = v
            end
        else
            if self:checkPetSkillType(v) == 2 then
                skill_type_2 = true
                skill_id = v
            end    
        end
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"pet_type_img", skill_type_2 == true)
    if skill_id > 0 then
        local skill_bg_str = GameUtil:getPetSkillBg(skill_id)
        LuaBehaviourUtil.setImg(luaBehaviour,"pet_type_img", skill_bg_str, "main_ui2")
    end
    if callback then
        luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
            if callback then
                callback(click_object, click_name, idx)
            end
        end)
    end
    local quality = self:getPetQualityByData(data)
    self:updateBigPetCardEffect(obj, quality or 1)
end


--检查技能类型
function M:checkPetSkillType(skill_id)
    local pet_skill_random_tab = ConfigManager:getCfgByName("pet_skill_random")
    if pet_skill_random_tab[skill_id] then
        return pet_skill_random_tab[skill_id].type
    end
    return 0
end

--宠物
function M:updateBigPetCardEffect(obj, evo)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Golden01", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red02", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red01", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col02", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col01", false)   
    if  evo < 3 then
       return
    end
    if luaBehaviour then 
        if evo == 3 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red02", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red01", true)      
        elseif evo >= 4 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col02", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col01", true)       
        end
    end
end


--英雄
function M:updateBigHeroCardEffect(obj, evo)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Golden01", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red02", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red01", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col02", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col01", false)   
    if  evo < 7 then
       return
    end
    if luaBehaviour then 
        if evo == 7 or evo == 8 or evo == 9 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Golden01", true)
        elseif evo == 10 or evo == 11 or evo == 12  or evo == 13 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red02", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Red01", true)      
        elseif evo >= 14 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col02", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroBag_Col01", true)       
        end
    end
end

--刷新职业页签tog
function M:updateProCell(obj, data, func, ui_name)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    LuaBehaviourUtil.setImg(luaBehaviour, "pro_img", data.icon, "language_zh_cn")
    local btn = UIUtil.findToggle(obj.transform)
    UIUtil.addToggleListener(btn, func, nil, ui_name)
    local pro_img = luaBehaviour:FindImage("pro_img")
    if data.race < 5 then
        pro_img.material = nil
    else
        btn.interactable = false
    end
end

--刷新职业页签tog2
function M:updateProCell2(obj, data, func, ui_name)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local all_text = luaBehaviour:FindGameObject("all_text")
    if data.race == 0 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "all_text", "全部")
        LuaBehaviourUtil.setImg(luaBehaviour, "back_img", "h_yeqian_c", "battle_ui")
        LuaBehaviourUtil.setImg(luaBehaviour, "front_img", "h_yeqian_d", "battle_ui")
    else
        local race_cfg = GlobalConfig.TYPE_HERO_RACE[data.race]
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "all_text", race_cfg.name)
        LuaBehaviourUtil.setImg(luaBehaviour, "back_img", "h_yeqian_b", "battle_ui")
        LuaBehaviourUtil.setImg(luaBehaviour, "front_img", "h_yeqian_a", "battle_ui")
    end
    local btn = UIUtil.findToggle(obj.transform)
    UIUtil.addToggleListener(btn, func, nil, ui_name)
    local pro_img = luaBehaviour:FindImage("back_img")
    if data.race < 5 then
        pro_img.material = nil
    else
        btn.interactable = false
    end
end

--正方形的英雄头像数据统一配置（Formation/FormationCell）
function M:updateHeroCountByFoursquare(obj, heroOid, callback)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroCountByFoursquare obj error！！！")
        return
    end
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(heroOid)
    UIUtil.setImg(obj.transform, hero_cfg.icon, "hero_head_ui", "cardIcon_img") --英雄icon
    local quality_ = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_cfg.evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    UIUtil.setImg(obj.transform, quality_.card_frame_name, "hero_head_ui", "db_img") --等级边框
    UIUtil.setObjectVisible(obj.transform, quality_.is_add, "db_fj_img") --精英特有的金色边
    local function clickCallback()
        if type(callback) == "function" then
            callback()
        end
    end
    UIUtil.setButtonClick(obj, clickCallback)
end

--通过配置id刷新英雄数据
function M:updateHeroContentByCid(obj, heroCid, callback)
    if obj == nil then
        Logger.log("GameUtil fun updateHeroContentById obj error！！！")
        return
    end
    --local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(heroCid)
    --UIUtil.setImg(obj.transform,hero_cfg.s_battle_icon,"hero_icon","cardIcon_img") --英雄icon
    --UIUtil.setImg(obj.transform,"ui_zd_card_cai","hero_icon","db_img") --等级边框
    UIUtil.setObjectVisible(obj.transform, false, "db_fj_img") --精英特有的金色边
    UIUtil.setText(obj.transform, "Lv.1", "cardName_text") --等级
    local function clickCallback()
        if type(callback) == "function" then
            callback()
        end
    end
    UIUtil.setButtonClick(obj, clickCallback)
end

--创建挂机界面获得奖励
function M:creatHangMoney(parent_obj)
    self:createPrefab("HangReward/get_hang_money", parent_obj)
end

--获取奖励飞金币
function M:creatFlyMoney(parent, params)
    local anim = ResourceUtil:LoadUIGameObject("HangReward/gold_fly", Vector3.zero, parent)
    if not params.coin then
        UIUtil.setObjectVisible(anim.transform, false, "money_spine")
    end

    if not params.exp then
        UIUtil.setObjectVisible(anim.transform, false, "jy_spine")
    end

    if not params.diamond then
        UIUtil.setObjectVisible(anim.transform, false, "yb_spine")
    end

    if not params.hero_exp then
        UIUtil.setObjectVisible(anim.transform, false, "yl_spine")
    end
    return anim
end

--地图信息(根据关卡id获取)
function M:creatMap(parent, id, isMain, cur_node)
    local map_obj = ResourceUtil:LoadUIGameObject("Map/cur_map", Vector3.zero, parent)
    local luaBehaviour = UIUtil.findLuaBehaviour(map_obj)
    local progress_nodes = luaBehaviour:FindGameObject("progress_nodes") --关隘集合父节点
    local stage_tab = ConfigManager:getCfgByName("stage")
    local cur_stage = stage_tab[id]
    local cur_chapers = self:getChapersTab(id)
    local xian_name = cur_stage.line_resources
    local line = string.sub(xian_name, 1, -5)
    local map_img = luaBehaviour:FindGameObject("map_img")
    self:updateResourcesImg(map_img, "Map/" .. cur_stage.map_resources)

    local cur_stage_pos = nil --当前偏移坐标
    local scaleRate = 0.8
    for k, v in pairs(cur_chapers) do
        if v.map_point_id[1] < 10000 then
            local pass_obj = ResourceUtil:LoadUIGameObject("Map/map_pop_node", Vector3.zero, progress_nodes.gameObject)
            self.setMapItem(pass_obj, k, v, isMain, cur_node)
            if id == k then
                cur_stage_pos = Vector3.New(0 - v.map_point_id[1], 0 - v.map_point_id[2], 0)
            end
        end
    end

    local offset_x = (cur_stage_pos.x + 330) * scaleRate
    local offset_y = (cur_stage_pos.y - 137) * scaleRate
    if offset_x > 236 then
        offset_x = 236
    elseif offset_x < -236 then
        offset_x = -236
    end
    offset_y = offset_y
    if offset_y < -110 then
        offset_y = -110
    elseif offset_y > 120 then
        offset_y = 120
    end
    if isMain == true then
        map_obj.transform.localScale = Vector3.New(scaleRate, scaleRate, 1)
        UIUtil.setLocalPosition(map_obj.transform, offset_x, offset_y, 0)
    end
    return map_obj
end

--地图信息（根据章节创建）
function M:creatMapByChapter(parent, c_id, cur_node)
    local map_obj = ResourceUtil:LoadUIGameObject("Map/cur_map", Vector3.zero, parent)
    local luaBehaviour = UIUtil.findLuaBehaviour(map_obj)
    local progress_nodes = luaBehaviour:FindGameObject("progress_nodes") --关隘集合父节点
    local map_xian_img = luaBehaviour:FindGameObject("map_xian_img") --
    local stage_tab = ConfigManager:getCfgByName("stage")
    local xian_name = ""
    for k, v in pairs(stage_tab) do
        if v.chapter_id == c_id then
            local pass_obj = ResourceUtil:LoadUIGameObject("Map/map_pop_node", Vector3.zero, progress_nodes.gameObject)
            self.setMapItem(pass_obj, k, v, cur_node)
            xian_name = v.line_resources
        end
    end
    local line = string.sub(xian_name, 1, -5)
    LuaBehaviourUtil.setImg(luaBehaviour, "map_xian_img", line, "common_ui")
end

function M.setMapItem(obj, id, data, isMain, cur_node)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    UIUtil.setLocalPosition(obj.transform, data.map_point_id[1], data.map_point_id[2], data.map_point_id[3])
    --local player_obj = luaBehaviour:FindGameObject("player")
    local player_obj = luaBehaviour:FindGameObject("light_img")
    local arrive_img = luaBehaviour:FindGameObject("arrive_img")
    local big_img = luaBehaviour:FindGameObject("big_img")
    player_obj:SetActive(false)
    arrive_img:SetActive(true)

    local cur_id = UserDataManager:getCurStage()
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_img", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Map_ZhiShi_001", false)
    if id > cur_id then
        -- 未到达的区域
        LuaBehaviourUtil.setImg(luaBehaviour, "arrive_img", "a_gj_ditu_guanqia_wtg", "common_ui")
        LuaBehaviourUtil.setImg(luaBehaviour, "big_img", "a_gj_ditu_daguanqia_wtg", "common_ui")
        if data.type == 2 then
            big_img:SetActive(true)
            arrive_img:SetActive(false)
        else
            big_img:SetActive(false)
            arrive_img:SetActive(true)
        end
    elseif id == cur_id then
        --正在攻略
        LuaBehaviourUtil.setImg(luaBehaviour, "big_img", "a_gj_ditu_daguanqia_dangqian", "common_ui")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Map_ZhiShi_001", true)
        if data.type == 2 then
            big_img:SetActive(true)
            player_obj:SetActive(false)
            arrive_img:SetActive(false)
        else
            player_obj:SetActive(true)
            big_img:SetActive(false)
        end
    else
        --已攻略
        LuaBehaviourUtil.setImg(luaBehaviour, "arrive_img", "a_gj_ditu_guanqia_tg", "common_ui")
        LuaBehaviourUtil.setImg(luaBehaviour, "big_img", "a_gj_ditu_daguanqia_tg", "common_ui")
        if data.type == 2 then
            big_img:SetActive(true)
            arrive_img:SetActive(false)
        else
            arrive_img:SetActive(true)
            big_img:SetActive(false)
        end
    end
    --local battle_stage_id = UserDataManager:getBattleStage()
    -- if cur_id and id == battle_stage_id then
    --     if isMain then
    --         player_obj:SetActive(false)
    --         local point_img = luaBehaviour:FindGameObject("point_img")
    --         point_img:SetActive(true)
    --         local chapter_tab = GameUtil:getChapersTab(id)
    --         local next_data = chapter_tab[id+1]
    --         if next_data == nil then
    --             next_data = chapter_tab[#chapter_tab]
    --             if next_data == nil then
    --                 next_data = chapter_tab[id]
    --             end
    --         end
    --         local cur_stage_pos = Vector3.New( 0 - data.map_point_id[1], 0 - data.map_point_id[2],0)
    --         local next_stage_pos = Vector3.New( 0 - next_data.map_point_id[1], 0 - next_data.map_point_id[2],0)

    --         local from = Vector3.left
    --         local to = next_stage_pos - cur_stage_pos
    --         point_img:GetComponent("Transform").rotation = Quaternion.FromToRotation(from, to)
    --     else
    --         player_obj:SetActive(true)
    --         function callfunc()
    --             luaBehaviour:RunAnim("MapPopLoop", nil, 0.5)
    --         end
    --         luaBehaviour:RunAnim("MapPopShow", callfunc, 1)
    --     end
    --     if type(cur_node) == "table" then
    --         cur_node.node = obj
    --     end
    -- end
end

function M:getChapersTab(id)
    local stage_tab = ConfigManager:getCfgByName("stage")
    local cur_stage = stage_tab[id]
    local cur_chapers = {}
    for k, v in pairs(stage_tab) do
        if cur_stage.chapter_id == v.chapter_id then
            cur_chapers[k] = v
        end
    end
    return cur_chapers
end

-- 创建预制体
function M:createPrefab(prefab_name, parent)
    local prefab = ResourceUtil:LoadUIGameObject(prefab_name, Vector3.zero, nil)
    if prefab ~= nil then
        if parent then
            prefab.transform:SetParent(parent, false)
        end
    else
        Logger.logWarning(" 要创建的预制体 " .. prefab_name .. " 没有找到 ")
    end
    return prefab
end

-- 装备升级属性信息创建
function M:createEqpLevelUp_Cell(key, num, num2)
    num2 = num2 or 0
    local cell = ResourceUtil:LoadUIGameObject("HeroInfo/EqpLevelUp_Cell", Vector3.zero, nil)
    local LuaBehaviour = UIUtil.findLuaBehaviour(cell.transform)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "num", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "num2", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "star_last", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "star_new", false)
        if key == "new_str_0066" then
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title", "new_str_0066")
            local last_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "star_last", true)
            local new_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "star_new", false)
            for i = 1,5 do
                UIUtil.setObjectVisible(last_obj.transform, num >= i, "star_"..i)
            end
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "num", "new_str_0075", num)
            if new_obj and num2 and num2 > 0 and num2 > num then
                for i = 1,5 do
                    UIUtil.setObjectVisible(new_obj.transform, num2 >= i, "star_"..i)
                end
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "num2", "new_str_0075", num2)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "star_new", true)
            end
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "num", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "num2", false)
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title", self:getAttrsName(key))
            -- if self:canPerAttrTransition(key) == true then
            --     num = num*100
            --     num2 = num2*100
            -- end
            if self:attrTransition(key) == true then
                LuaBehaviourUtil.setText(LuaBehaviour, "num", self:formatNum(num) .. "%")
            else
                LuaBehaviourUtil.setText(LuaBehaviour, "num", self:formatNum(num))
            end

            if num2 and num2 > 0 then
                if self:attrTransition(key) == true then
                    LuaBehaviourUtil.setText(LuaBehaviour, "num2", self:formatNum(num2) .. "%")
                else
                    LuaBehaviourUtil.setText(LuaBehaviour, "num2", self:formatNum(num2))
                end
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "num2", true)
            end
        end
    end
    return cell
end

--[[
    获得升级消耗
    cur_lv --当前等级
    tab{exp(经验),coin(金币),special(id-106粉尘),rate(倍数)}
]]
function M:getHeroUpGrade(cur_lv, min_lv)
    local tab = ConfigManager:getCfgByName("hero_upgrade")
    if min_lv == nil then -- 返回升下一级的消耗
        return tab[cur_lv]
    end

    -- 返回两个等级之间的总共消耗
    if cur_lv >= min_lv then
        local data = table.copy(tab[min_lv])
        for i = min_lv + 1, cur_lv do
            for k, v in pairs(tab[i]) do
                data[k] = data[k] + v
            end
        end
        return data
    end
end

--[[
    @desc: 获得装备升级消耗
    time:2019-12-26 14:58:06
    --@eqp_evo: 装备的品质
	--@lv: 第几次强化
    @return:
]]
function M:getEquipUpGrade(eqp_evo, lv, pos)
    local tab = ConfigManager:getCfgByName("equip_levelup")
    local cur_cfg = nil
    if tab[eqp_evo] == nil then
        return 0
    end
    if tab[eqp_evo][lv + 1] then
        cur_cfg = tab[eqp_evo][lv + 1]
    else
        cur_cfg = tab[11][lv + 1]    
    end
    if pos and pos == 1 and cur_cfg.arms_exp then
        return cur_cfg.arms_exp
    else
        if cur_cfg then
            if  cur_cfg.exp then
                return cur_cfg.exp
            else
                return cur_cfg
            end
        else
            return 0
        end
    end
    return 0
end


--[[
    @desc: 获取技能信息
]]
function M:getSkill(id)
    local tab = ConfigManager:getCfgByName("skill_detail")
    return tab[id]
end

--[[
    计算时间样式
]]
function M:getTimeLayoutBySecond(second)
    local n = __math_max(0, second)
    local day = __math_modf(n / 86400)
    n = n % 86400
    local hour = __math_modf(n / 3600)
    n = n % 3600
    local min = __math_modf(n / 60)
    local sec = __math_floor(n % 60 + 0.5)
    return day, hour, min, sec
end

--[[
    格式化时间格式
]]
function M:formatTimeBySecond(second, format)
    if format == 999 then
        local day, hour, min, sec = self:getTimeLayoutBySecond(second)
        format = format or 0
        if day > 0 then
           return string.format(Language:getTextByKey("new_str_0252"), day, hour, min, sec)
        else
           if hour > 0 then
               return string.format("%02d:%02d:%02d", hour, min, sec)
           else
               if format == 1 then
                   if min > 0 then
                       return string.format("%02d:%02d", min, sec)
                   else
                       return string.format("%d", sec)
                   end
               else
                   return string.format("%02d:%02d", min, sec)
               end
           end
        end 
    elseif format == 2 then
        return self:formatTimeBySecond3(second)
    end
    return self:formatTimeBySecond2(second)
end

function M:formatTimeBySecond2(second)
    local day, hour, min, sec = self:getTimeLayoutBySecond(second)
    if day > 0 then
        return string.format(Language:getTextByKey("new_str_0415"), day) -- .. string.format(Language:getTextByKey("new_str_0416"), hour)
    elseif hour > 0 then
        return string.format(Language:getTextByKey("new_str_0416"), hour) -- .. string.format(Language:getTextByKey("new_str_0417"), min)
    elseif min > 0 then
        return string.format(Language:getTextByKey("new_str_0417"), min) -- .. string.format(Language:getTextByKey("new_str_0418"), sec)
    else
        return string.format(Language:getTextByKey("new_str_0418"), sec)
    end
end

function M:formatTimeBySecond3(second)
    local day, hour, min, sec = self:getTimeLayoutBySecond(second)
    if day > 0 then
        hour = hour + day * 24
    end
    if hour > 0 then
        return string.format(Language:getTextByKey("new_str_0416"), hour) -- .. string.format(Language:getTextByKey("new_str_0417"), min)
    elseif min > 0 then
        return string.format(Language:getTextByKey("new_str_0417"), min) -- .. string.format(Language:getTextByKey("new_str_0418"), sec)
    else
        return string.format(Language:getTextByKey("new_str_0418"), sec)
    end
end

function M:formatEndTimeBySecond(second)
    local day, hour, min = self:getTimeLayoutBySecond(second)
    if day > 0 then
        return string.format(Language:getTextByKey("new_str_0530"), day)
    elseif hour > 0 then
        return string.format(Language:getTextByKey("new_str_0220"), hour)
    elseif min > 0 then
        return string.format(Language:getTextByKey("new_str_0529"), min)
    else
        return string.format(Language:getTextByKey("new_str_0529"), 1)
    end
end

--[[--
    格式化数字
]]
function M:formatValueToString(value, comb_flag, about)
    comb_flag = comb_flag == nil and true or comb_flag
    local temp_value = "0"
    local unit = ""
    about = about or "%d"
    if type(value) == "string" then
        value = tonumber(value)
    end
    if value == nil or type(value) ~= "number" then
        return temp_value, unit
    end
    if value > 0 and value < 100000 then
        temp_value = tostring(value)
    elseif value >= 100000 and value < 100000000 then
        local v1 = __math_floor(value % 1000 / 100)
        if v1 > 0 then
            about = "%.1f"
        else
            local v2 = __math_floor(value % 10000 / 1000)
            if v2 > 0 then
                about = "%.1f"
            else
                about = "%d"
            end
        end
        if value < 10000000 then
            temp_value, unit = string.format(about, __math_floor(value * 0.001) / 10), Language:getTextByKey("new_str_0040")
        else
            temp_value, unit = string.format(about, __math_floor(value * 0.001) / 10), Language:getTextByKey("new_str_0040")
        end
    elseif value >= 100000000 and value < 1000000000000 then
        local v1 = __math_floor(value % 10000000 / 1000000)
        if v1 > 0 then
            about = "%.1f"
        else
            local v2 = __math_floor(value % 100000000 / 10000000)
            if v2 > 0 then
                about = "%.1f"
            else
                about = "%d"
            end
        end
        temp_value, unit = string.format(about, __math_floor(value * 0.000001) / 100), Language:getTextByKey("new_str_0039")
    elseif value >= 1000000000000 then
        local v1 = __math_floor(value % 100000000000 / 10000000000)
        if v1 > 0 then
            about = "%.1f"
        else
            local v2 = __math_floor(value % 1000000000000 / 100000000000)
            if v2 > 0 then
                about = "%.1f"
            else
                about = "%d"
            end
        end
        temp_value, unit = string.format(about, __math_floor(value * 0.0000000001) / 100), Language:getTextByKey("new_str_1107")
    end
    if comb_flag then
        temp_value = temp_value .. unit
        unit = ""
    end
    return temp_value, unit
end

local cur_look_info_tips = nil

function M:lookInfoTips(control, params)
    if cur_look_info_tips then
        cur_look_info_tips:destroy()
    end
    local LookInfoTips = CustomRequire("UI.Common.LookInfoTips")
    cur_look_info_tips = LookInfoTips.new(control, params)
end

function M:resetLookInfoTips()
    cur_look_info_tips = nil
end

function M:destroyLookInfoTips()
    if cur_look_info_tips then
        cur_look_info_tips:destroy()
    end
end

local cur_good_feel_pop = nil --好感属性弹窗

function M:lookGoodFeelInfoTips(control, params)
    if cur_good_feel_pop then
        cur_good_feel_pop:destroy()
    end
    local LookInfoTips = CustomRequire("UI.Common.GoodFeelProPop")
    cur_good_feel_pop = LookInfoTips.new(control, params)
end

function M:resetGoodFeelLookInfoTips()
    cur_good_feel_pop = nil
end

function M:destroyGoodFeelLookInfoTips()
    if cur_good_feel_pop then
        cur_good_feel_pop:destroy()
    end
end

--法宝弹窗
local cur_look_weapon_info_tips = nil

function M:lookWeaponInfoTips(control, params)
    if cur_look_weapon_info_tips then
        cur_look_weapon_info_tips:destroy()
    end
    local LookInfoTips = CustomRequire("UI.Common.LookWeaponInfoTips")
    cur_look_weapon_info_tips = LookInfoTips.new(control, params)
end

function M:resetWeaponLookInfoTips()
    cur_look_weapon_info_tips = nil
end

function M:destroyWeaponLookInfoTips()
    if cur_look_weapon_info_tips then
        cur_look_weapon_info_tips:destroy()
    end
end

--*****宠物协战弹窗-----------------------------------------------------------------------------------------------------------------------------------------------------
local cur_look_pet_info_tips = nil

function M:lookPetInfoTips(control, params)
    if cur_look_pet_info_tips then
        cur_look_pet_info_tips:destroy()
    end
    local LookInfoTips = CustomRequire("UI.Common.LookPetInfoTips")
    cur_look_pet_info_tips = LookInfoTips.new(control, params)
end

function M:resetPetLookInfoTips()
    cur_look_pet_info_tips = nil
end

function M:destroyPetLookInfoTips()
    if cur_look_pet_info_tips then
        cur_look_pet_info_tips:destroy()
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------




local cur_art_info_tips = nil
function M:lookArtInfoTips(control, params)
    if cur_art_info_tips then
        cur_art_info_tips:destroy()
    end
    local LookInfoTips = CustomRequire("UI.Common.LookArtifactInfoTips")
    cur_art_info_tips = LookInfoTips.new(control, params)
end

function M:resetLookArtInfoTips()
    cur_art_info_tips = nil
end

local cur_bounty_info_tips = nil
function M:lookBountyTips(control, params)
    if cur_bounty_info_tips then
        cur_bounty_info_tips:destroy()
    end
    local LookInfoTips = CustomRequire("UI.Common.RewardDes_Pop")
    cur_bounty_info_tips = LookInfoTips.new(control, params)
    cur_bounty_info_tips.m_rootView.transform:SetParent(params.parent.m_rootView.transform)
end

function M:resetBountyInfoTips()
    cur_bounty_info_tips = nil
end


local player_info_tips = nil
function M:lookPlayerTips(control, params)
    if player_info_tips then
        player_info_tips:destroy()
    end
    for k,v in pairs(control.m_chilrenList) do
        if v.__cname == "FormationControl" then
            local PlayerInfoTips = CustomRequire("UI.Common.CommonPlayerTips")
            player_info_tips = PlayerInfoTips.new(v, params)
        end
    end
end

function M:updatePlayerTips(data)
    if player_info_tips then
        player_info_tips:TipsHandler(data)
    end
end

function M:resetPlayerInfoTips()
    if player_info_tips then
        player_info_tips:destroy()
    end
    player_info_tips = nil
end

local player_relation_tips = nil
function M:lookPlayerRelationTips(control, params)
    if player_relation_tips then
        for k,v in pairs(player_relation_tips) do
            v:destroy()
        end
    end
    player_relation_tips = {}
    for k,v in pairs(control.m_chilrenList) do
        if v.__cname == "FormationControl" then
            local PlayerRelationTips = CustomRequire("UI.Common.CommonPlayerRelationTips")
            local enemys = SceneManager:getCurSceneView().plyMgr:getPlayers(-params:get_camp())
            for i = 1, enemys.Count do
                local enemy = enemys:get(i - 1)
                local relation = GlobalTools:checkRace(enemy, params)
                if relation > 0 or relation < 0 then
                    local player_tip = PlayerRelationTips.new(v,{player = enemy, relation = relation})
                    table.insert(player_relation_tips, player_tip)
                end
            end

        end
    end
end

function M:resetPlayerRelationTips()
    if player_relation_tips then
        for k,v in pairs(player_relation_tips) do
            v:destroy()
        end
    end
    player_relation_tips = nil
end

local cur_formation_add = nil
function M:formationAddition(control, params)
    if cur_formation_add then
        cur_formation_add:destroy()
    end
    local FormationAdd = CustomRequire("UI.Formation.FormationAddition")
    cur_formation_add = FormationAdd.new(control, params)
end

function M:resetFormationAddition()
    cur_formation_add = nil
end

local cur_formation_des = nil
function M:formationDes(control, params)
    if cur_formation_des then
        cur_formation_des:destroy()
    end
    local FormationDes = CustomRequire("UI.Formation.FormationAdditionDes")
    cur_formation_des = FormationDes.new(control, params)
end

function M:resetFormationDes()
    cur_formation_des = nil
end


function M:commonAttrNode(control, params)
    local CommonAttrNode = CustomRequire("UI.Common.CommonAttrNode")
    return CommonAttrNode.new(control, params)
end

function M:instanceObject(obj, parent)
    local inst = U3DUtil:Instantiate(obj)
    if parent then
        inst.transform:SetParent(parent.transform, false)
    end
    return inst
end

function M:setTextureLoadSetLanImgText(img, img_name)
    local texture_path = ResourceUtil:getTexturePath()
    GameUtil:updateResourcesImg(img, texture_path .. "/skill_name_img/".. img_name)
end

-- 加载称号图片
function M:setTextureLoadTitleLanImgText(img, img_name)
    local texture_path = ResourceUtil:getTexturePath()
    GameUtil:updateResourcesImg(img, texture_path .. "/title/".. img_name)
end

function M:setLanImgText(trans, img_name, path)
    local lan_atlas = ResourceUtil:getLanAtlas()
    return UIUtil.setImg(trans, img_name, lan_atlas, path)
end

--[[
    计算装备升级下一级的属性
]]
function M:getEquipLvUpInfo(c_id, num)
    local ed = UserDataManager.equip_data:getEquipConfigByCid(c_id)
    local cur_attrs = UserDataManager:appendAttrs(ed.attr)
    local lv_growth_rate = ed.lv_growth_rate
    local nex_attrs = clone(cur_attrs)
    for k, v in pairs(nex_attrs) do
        for kk, vv in pairs(GlobalConfig.TYPE_HERO_PRO) do
            if k == vv.pro_name then
                v = v + v * lv_growth_rate * num
            end
        end
    end
    return cur_attrs, nex_attrs
end

--对应属性的中文 def --> 防御
function M:getAttrsName(value,cfg_id)
    if value == "lv" then
        return Language:getTextByKey("new_str_0436")
    end
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    for k, v in pairs(hero_enumeration) do
        if cfg_id then
            if cfg_id == k then
                Logger.log("k对应的name" .. k .. v.name)
                return Language:getTextByKey(v.name)
            end
        elseif v.user_key == value then
            return Language:getTextByKey(v.name)
        end
    end
    return value
end

function M:getAttrCfg(value)
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    return hero_enumeration[value]
end

--根据属性id获取 901 --> atk
function M:getAttrsKey(value)
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    return hero_enumeration[value].user_key
end

--根据属性英文获得对应id atk --> 901
function M:getAttrsId(value)
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    for k, v in pairs(hero_enumeration) do
        if v.user_key == value then
            return k
        end
    end
    return 0
end

--分别检测属性显示是否需要展示百分比(只用于UI展示)
function M:attrTransition(data)
    local hero_enum_tab = ConfigManager:getCfgByName("hero_enumeration")
    local cur_data = nil
    for k, v in pairs(hero_enum_tab) do
        if v.user_key == data then
            cur_data = v
        end
    end
    if data == "critrate" then --暴击（特殊）
        return true
    end
    if cur_data.is_percent and cur_data.is_percent == 1 then
        return true
    end
    return false
end

--分别检测属性显示是否需要展示百分比(只用于UI展示)        ---- 新的
function M:newAttrTransition(attrId)
    local hero_enum_tab = ConfigManager:getCfgByName("hero_enumeration")
    local attrData = hero_enum_tab[attrId]
    if attrData.user_key == "critrate" then     -- 暴击（特殊）
        return true
    end
    return (attrData.is_percent and attrData.is_percent == 1)
end

--分别检测属性显示是否需要展示百分比(只用于UI展示)        ---- 新新的(针对抗暴和暴击)
function M:newattrTransition2(data)
    local hero_enum_tab = ConfigManager:getCfgByName("hero_enumeration")
    local cur_data = nil
    for k, v in pairs(hero_enum_tab) do
        if v.user_key == data then
            cur_data = v
        end
    end
    if data == "critrate" then --暴击（特殊）
        return true
    end
    if data == "resi" then 
        return true
    end
    if data == "discrit" then 
        return true
    end
    if data == "crit" then 
        return true
    end
    if data == "rageregenper" then
        return true
    end
    if cur_data.is_percent and cur_data.is_percent == 1 then
        return true
    end
    return false
end

--检测属性显示是否需要*100展示百分比
function M:canPerAttrTransition(data)
    local hero_enum_tab = ConfigManager:getCfgByName("hero_enumeration")
    local cur_data = nil
    for k, v in pairs(hero_enum_tab) do
        if v.user_key == data then
            cur_data = v
        end
    end
    if cur_data.is_percent and cur_data.is_percent == 1 then
        return true
    end
    return false
end

--获取某装备的基础属性
function M:getEqpBaseTypeNum(eqp_id, type)
    local tab = ConfigManager:getCfgByName("equip_detail")
    local cur_eqp = tab[eqp_id]
    local type_id = self:getAttrsId(type)
    local type_num = 0
    if cur_eqp then
        for k, v in pairs(cur_eqp.attr) do
            if v[1] == type_id then
                type_num = v[2]
            end
        end
    end
    return type_num, cur_eqp.lv_growth_rate
end

function M:createRewards(reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    scale = scale or 1
    local reward_element = {}
    UIUtil.destroyAllChild(reward_node)
    for k, v in pairs(rewards) do
        local item = self:createItemElement(v, is_show_num, is_show_detail, callback, frame_effect)
        item.transform:SetParent(reward_node, false)
        UIUtil.setScale(item.transform, scale)
        table.insert(reward_element, item)
    end
    return reward_element
end

function M:createGiftRewards(reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    scale = scale or 1
    local gift_items = {}
    UIUtil.destroyAllChild(reward_node)
    for k, v in pairs(rewards) do
        local item = self:creatGiftItem(v, is_show_num, is_show_detail, callback, frame_effect)
        item.transform:SetParent(reward_node, false)
        table.insert(gift_items, item)
        UIUtil.setScale(item.transform, scale)
    end
    return gift_items
end

function M:creatGiftItem(dataTable, isShowNum, isShowDetail, callback, frame_effect)
    local gift_item = ResourceUtil:LoadUIGameObject("Common/giftItemNode", Vector3.zero, nil)
    local item = self:createItemElement(dataTable, isShowNum, isShowDetail, callback, frame_effect)
    local itemParent = UIUtil.findTrans(gift_item.transform, "itemParent")
    if itemParent then
        item.transform:SetParent(itemParent.transform, false)
    else
        item.transform:SetParent(gift_item.transform, false)
    end
    return gift_item
end

function M:getChapterIdByStageId(stage_id)
    stage_id = stage_id or 0
    local stage = ConfigManager:getCfgByName("stage")
    local stage_item = stage[stage_id] or {}
    local chapter_id = stage_item.chapter_id or 0
    return chapter_id, stage_id, stage_item
end

-- show_title {show_flag = true, scale = 1 }
function M:setUserAvatar(obj, user, show_lv, show_exp, show_title)
    if obj == nil then
        return
    end
    local transform = obj.transform
    if user == nil then
        UIUtil.setImg(transform, "item_icon_wenhao", "item_icon", "tx_mask/tx_img")
        UIUtil.setObjectVisible(transform, false, "lv_bg")
    else
        local avatar = user.avatar or "0"
        local cfg = ConfigManager:getPlayerPictureCfg(avatar)
        local hero_head_ui = nil
        if cfg ~= nil and next(cfg) then
            hero_head_ui = UIUtil.setImg(transform, cfg.icon, "hero_head_ui", "tx_mask/tx_img")
            if not IsNull(hero_head_ui) then
                UIUtil.destroyAllChild(hero_head_ui.transform)
            end
        else
            hero_head_ui = UIUtil.setImg(transform, "TX_Temp", "hero_head_ui", "tx_mask/tx_img")
            if not IsNull(hero_head_ui) then
                UIUtil.destroyAllChild(hero_head_ui.transform)
            end
        end
        local frame_cfg = ConfigManager:getPlayerFrameCfg(user.frame)
        if frame_cfg ~= nil and next(frame_cfg) then
            UIUtil.setImg(transform, frame_cfg.icon, "hero_head_ui", "border_img")
            local border_img_tran = UIUtil.setObjectVisible(transform, true, "border_img")
            if not IsNull(border_img_tran) then
                UIUtil.destroyAllChild(border_img_tran)
            end
            if frame_cfg.UI_effect1 and frame_cfg.UI_effect2 and not IsNull(hero_head_ui) and not IsNull(border_img_tran) then
                ResourceUtil:GetUIEffectItem("Common/" .. frame_cfg.UI_effect1, border_img_tran.gameObject)
                ResourceUtil:GetUIEffectItem("Common/" .. frame_cfg.UI_effect2, hero_head_ui.gameObject)
            end
        else
            local border_img_tran = UIUtil.setObjectVisible(transform, false, "border_img")
            if not IsNull(border_img_tran) then
                UIUtil.destroyAllChild(border_img_tran)
            end
        end
        if show_lv or show_lv == nil and user.level then
            UIUtil.setTextByLanKey(transform, "lv_bg/lv_text", tostring(user.level))
            UIUtil.setObjectVisible(transform, true, "lv_bg")
        else
            UIUtil.setObjectVisible(transform, false, "lv_bg")
        end
        if show_exp and show_exp == true then
            UIUtil.setObjectVisible(transform, true, "bg")
        else
            UIUtil.setObjectVisible(transform, false, "bg")
        end
        --- 设置称号图片
        local title_id = user.title
        if show_title and show_title.title_id then
            title_id = show_title.title_idq
        end
        if title_id and title_id ~= 0 and show_title then
            local head_title_obj = UIUtil.setObjectVisible(transform, true, "head_title_img")
            local name_img = UIUtil.findImage(transform, "head_title_img")
            local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
            if head_title_obj and cfg and name_img then
                if not show_title.scale then show_title.scale = 1 end
                if show_title.scale == 1 then
                    show_title.scale = 0.7
                end
                UIUtil.setScale(head_title_obj, show_title.scale)
                UIUtil.destroyAllChild(name_img.gameObject.transform)
                if cfg.title_effect and cfg.title_effect ~= "" then
                    name_img.enabled = false
                    ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
                else
                    name_img.enabled = true
                    GameUtil:setTextureLoadTitleLanImgText(name_img, cfg.icon) -- 设置称号图片
                    name_img:SetNativeSize()
                end
            end
        else
            UIUtil.setObjectVisible(transform, false, "head_title_img")
        end
        local self_uid = UserDataManager.user_data:getUserStatusDataByKey("uid")
        local is_self = user.uid == self_uid
        local medals = user.medals or {}
        if is_self then
            medals = UserDataManager.m_medals
        else
            medals = self:transNetMedals(medals)
        end
        local wear_medal = table.nums(medals) > 0
        local medal_obj = UIUtil.setObjectVisible(transform, wear_medal, "MedalNode")
        if wear_medal then
            local medals_id_tab = table.keys(medals)
            table.sort(medals_id_tab)
            local medal_id = medals_id_tab[#medals_id_tab]
            self:setHeadMedalNode(medal_obj, medal_id, is_self)
            UIUtil.setObjectVisible(transform, false, "lv_bg")--赵鑫说的 所有头像的等级都不用显示了
        end
    end
end

--聊天数据的奇遇数据和正常格式不一样，需要转换一下
function M:transNetMedals(net_medals)
    local medals = {}
    if net_medals[1] and net_medals[1].expire_time then
        for i, v in pairs(net_medals) do
            medals[tostring(v.medal_id)] = v.expire_time
        end
    else
        medals = net_medals
    end
    return medals
end

function M:setHeadMedalNode(medal_obj, medal_id, is_self)
    GameUtil:updateMedalElement(medal_obj, medal_id, true, is_self)
end

function M:setHeroAvatar(obj, user, show_lv, show_exp)
    if obj == nil then
        return
    end
    local transform = obj.transform
    if user == nil then
        UIUtil.setImg(transform, "item_icon_wenhao", "item_icon", "tx_mask/tx_img")
        UIUtil.setObjectVisible(transform, false, "lv_bg")
    else
        local avatar = user.avatar or "0"
        local cfg = ConfigManager:getPlayerPictureCfg(avatar)
        --local cfg = UserDataManager.hero_data:getHeroConfigByCid(checknumber(avatar))
        if cfg then
            UIUtil.setImg(transform, cfg.icon, "hero_head_ui", "tx_mask/tx_img")
        else
            UIUtil.setImg(transform, "item_icon_wenhao", "item_icon", "tx_mask/tx_img")
        end
        if show_lv or show_lv == nil and user.level then
            UIUtil.setTextByLanKey(transform, "lv_bg/lv_text", tostring(user.level))
            UIUtil.setObjectVisible(transform, true, "lv_bg")
        else
            UIUtil.setObjectVisible(transform, false, "lv_bg")
        end
        if show_exp and show_exp == true then
            UIUtil.setObjectVisible(transform, true, "bg")
        else
            UIUtil.setObjectVisible(transform, false, "bg")
        end
    end
end

function M:getUserOwnAvatar()
    local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
    local avatar_id = checknumber(avatar)
    local cfg = ConfigManager:getPlayerPictureCfg(avatar_id)
    if cfg then
        if cfg.unlock == 1 then -- 获得卡牌解锁
            return avatar_id
        elseif cfg.unlock == 2 then -- 运营活动解锁,可能卡牌表中没有，用104的卡牌改变模型
            return 104, cfg.prefab
        elseif cfg.unlock == 3 then -- 获得皮肤解锁,可能卡牌表中没有，用104的卡牌改变模型
            local skin = ConfigManager:getHeroSkinCfg(avatar_id)
            return 104, skin.prefab
        end
    end
    return 104
end

function M:setHeroSpineAnim(hero_spine_obj, id)
    local sg = hero_spine_obj:GetComponent("SkeletonGraphic")
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    local skeletonData = ResourceUtil:GetSk(cfg.hero_spine, "rolespine_" .. string.lower(cfg.hero_spine))
    sg.skeletonDataAsset = skeletonData
    sg:Initialize(true)
end

function M:setHeroRace(transform, id)
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    if cfg then
        local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].race_icon --英雄种族icon
        UIUtil.setImg(transform, race,  ResourceUtil:getLanAtlas())
    end
end

function M:getRefreshCost(refresh_count, renovate_type)
    local refresh_count = refresh_count or 0
    local renovate = ConfigManager:getCfgByName("renovate")
    local cur_renovate = renovate[renovate_type] or {}
    local count_list = cur_renovate.count_list or {}
    local cost = cur_renovate.cost or {}
    local cur_cost = nil
    for i, v in ipairs(count_list) do
        if refresh_count < v then
            cur_cost = cost[i]
            break
        end
    end
    return cur_cost or cost[#cost]
end

function M:getHeroById(id)
    local hero_info, hero_cfg = UserDataManager.hero_data:getHeroDataById(id)
    return hero_info, hero_cfg
end

function M:addTips(attrs, gain, parent, order)
    if next(attrs) == nil then
        return
    end
    local tips = ResourceUtil:LoadUIGameObject("Common/Tips", Vector3.zero, parent)
    if tips then
        local m_canvas = tips:GetComponent("Canvas")
        m_canvas.sortingOrder = order + 2
        local luaBehaviour = UIUtil.findLuaBehaviour(tips)
        local add_attrs = luaBehaviour:FindGameObject("add_attr")
        local sub_attrs = luaBehaviour:FindGameObject("sub_attr")
        add_attrs:SetActive(false)
        sub_attrs:SetActive(false)
        local function endCallFunc()
            if tips ~= nil then
                U3DUtil:Destroy(tips)
            end
        end
        if gain == true then
            add_attrs:SetActive(true)
            for k, v in pairs(attrs) do
                local atr_obj_name = "attr" .. k
                local attr_obj = UIUtil.findTrans(add_attrs.transform, atr_obj_name)
                UIUtil.setTextByLanKey(attr_obj.transform, "name_text", v.name)
                if v.num > 0 then
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", "+" .. v.num)
                else
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", v.num)
                end
                UIUtil.setObjectVisible(add_attrs.transform, true, atr_obj_name)
            end
        else
            sub_attrs:SetActive(true)
            for k, v in pairs(attrs) do
                local atr_obj_name = "attr" .. k
                local attr_obj = UIUtil.findTrans(sub_attrs.transform, atr_obj_name)
                UIUtil.setTextByLanKey(attr_obj.transform, "name_text", v.name)
                if v.num > 0 then
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", "+" .. v.num)
                else
                    UIUtil.setTextByLanKey(attr_obj.transform, "num_text", v.num)
                end
                UIUtil.setObjectVisible(sub_attrs.transform, true, atr_obj_name)
            end
        end
        luaBehaviour:RunAnim("Tips_Show", endCallFunc, 1)
    end
end

--缩放动效
function M:ZoomObj(obj)
    obj.transform.localScale = Vector3(0.8, 0.8, 0.8)
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(obj.transform:DOScale(1.2, 0.15))
    sequence:Append(obj.transform:DOScale(1.0, 0.15))
    sequence:SetAutoKill(true)
end

--
function M:dotweenMoveX(obj, x, endCallFunc)
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(obj.transform:DOLocalMoveX(x, 0.35):SetEase(Tweening.Ease.OutSine))
	sequence:OnComplete(endCallFunc)
	sequence:SetAutoKill(true)
end


function M:playBtnSound(full_btn_name)
    local sound_name = BtnSoundConfig[full_btn_name]
    if sound_name and sound_name ~= "" then
        audio:SendEvtUI(sound_name)
    end
end

function M:getCanEquipHeroIds(equip_c_id)
    local crystal_heros_id = {}
    local open_flag, _ = BtnOpenUtil:isBtnOpen(29)
    if open_flag then
        crystal_heros_id = UserDataManager.hero_data:getCrystalAllHerosId()
    end
    local sel_equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(equip_c_id)
    if sel_equip_cfg == nil then
        Logger.logError(equip_c_id, "equip_c_id not found : ")
        return {}
    end
    local equip_type = sel_equip_cfg.type
    local pos = sel_equip_cfg.pos
    local quality = sel_equip_cfg.quality
    local function filterFunc(data, cfg)
        local flag = false
        if (data.lv > 1 or crystal_heros_id[data.oid] ~= nil) and cfg.type == equip_type then
            local equips = data.equips or {}
            local equip_data = equips[tostring(pos)] or {}
            if _G.next(equip_data) then
                local equip_cfg = UserDataManager.equip_data:getEquipConfigByCid(equip_data.id)
                if equip_cfg then
                    flag = quality > equip_cfg.quality
                end
            else
                flag = true
            end
        end
        return flag
    end
    local hero_ids = UserDataManager.hero_data:getHerosIdByFilterFunc(filterFunc)
    return hero_ids
end

--更新贸易港礼包数据
function M:updateGiftBagNode(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local gift_name = luaBehaviour:FindText("name_text")
    local gift_price = luaBehaviour:FindText("price_text")
    gift_name.text = Language:getTextByKey(data.name)
    gift_price.text = Language:getTextByKey(data.price_rmb)
end

-- 倒计时
function M:remainingTimeUpdate(control, time_key, time_text, end_time, end_time_event, format, format_text_key)
    local end_time = end_time or (UserDataManager:getServerTime() + 86400 * 9)
    local diff_time = end_time - UserDataManager:getServerTime()
    diff_time = math.max(diff_time, 1)
    local ft = GameUtil:formatTimeBySecond(diff_time, format)
    time_text.text = format_text_key and Language:getTextByKey(format_text_key, ft) or ft
    local function tick(event, dt, remaining_time)
        local diff_time = end_time - UserDataManager:getServerTime()
        local ft = GameUtil:formatTimeBySecond(diff_time, format)
        time_text.text = format_text_key and Language:getTextByKey(format_text_key, ft) or ft
        if remaining_time <= 0 then
            control:updateMsg(end_time_event or "time_end_refresh")
        end
    end
    EventDispatcher:registerTimeEvent(time_key, tick, 1, diff_time)
end

function M:getHeirloomNum(heirlooms)
    local show_data = {}
    local heirlooms = heirlooms or {}
    local heirloom = ConfigManager:getCfgByName("heirloom")
    for k, v in pairs(heirlooms) do
        local cfg = heirloom[v]
        if cfg then
            local quality = cfg.quality or 0
            local atkrating_ratio = cfg.atkrating_ratio or 0
            if show_data[quality] == nil then
                show_data[quality] = {num = 1, atkrating_ratio = atkrating_ratio}
            else
                show_data[quality].num = show_data[quality].num + 1
                show_data[quality].atkrating_ratio = show_data[quality].atkrating_ratio + atkrating_ratio
            end
        end
    end
    return show_data
end

function M:setUserGender(luaBehaviour, gender, gender_img_key, gender_text_key)
    gender = gender or -1
    local gender_cfg_item = GlobalConfig.GENDER_CFG[gender]
    if gender_cfg_item then
        if gender_text_key then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, gender_text_key, gender_cfg_item.name)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_text_key, false)
        end
        if gender_img_key then
            LuaBehaviourUtil.setImg(luaBehaviour, gender_img_key, gender_cfg_item.icon, gender_cfg_item.atlas)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_img_key, false)
        end
    else
        if gender_text_key then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_text_key, false)
        end
        if gender_img_key then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, gender_img_key, false)
        end
    end
end

function M:createTeamHeros(team_node, rewards, is_show_num, is_show_detail, callback, scale, update_func)
    scale = scale or 1
    local rewards = rewards or {}
    UIUtil.destroyAllChild(team_node)
    for k, v in ipairs(rewards) do
        local item = nil
        if _G.next(v) then
            item = self:createItemElementByData(v, is_show_num, is_show_detail, callback)
            if update_func then
                update_func(item, v)
            end
        else
            item = self:createPrefab("Common/ItemNode")
            local ui_element = GameUtil:updateItemElementNoData(item)
            ui_element.add_img:SetActive(false)
        end
        UIUtil.setScale(item.transform, scale, scale)
        item.transform:SetParent(team_node, false)
    end
end

function M:getFormatTeamData(team, other_heros, has_null)
    local show_data = {}
    local high_arena_defense = self.mult_main_teams
    team = team or {}
    other_heros = other_heros or {}
    local team_heros_data = {}
    for index = 1, 5 do
        local hero_id = team[index] or ""
        local hero_data = other_heros[hero_id] or UserDataManager.hero_data:getHeroDataById(hero_id)
        local data = nil
        if hero_data then
            data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 0})
            data.quality = hero_data.evo
            data.card_id = hero_id
            data.hero_data = hero_data
        end
        if has_null == nil or has_null == true then
            table.insert(team_heros_data, data or {})
        else
            if data then
                table.insert(team_heros_data, data)
            end
        end
    end
    return team_heros_data
end

-- 宠物战斗数据统计
function M:getFormatPetTeamData(team, other_heros, has_null)
    team = team or {}
    other_heros = other_heros or {}
    local team_heros_data = {}
    for index = 1, 5 do
        local hero_id = team[index] or ""
        local hero_data = other_heros[hero_id] or UserDataManager.pet_data:getPetDataById(hero_id)
        local data = nil
        if hero_data then
            data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.PETS, hero_data.id, 0})
            data.quality = self:getPetQualityByData(hero_data)
            data.card_id = hero_id
            data.hero_data = hero_data
            data.evo = hero_data.evo
        end
        if has_null == nil or has_null == true then
            table.insert(team_heros_data, data or {})
        else
            if data then
                table.insert(team_heros_data, data)
            end
        end
    end
    return team_heros_data
end

--格式化小数点后的0
function M:formatNum(count)
    local num = tonumber(count)
    if num == nil then
        return 0
    end
    if num <= 0 then
        return 0
    else
        local t1, t2 = math.modf(num)
        if t2 > 0.001 then
            return num
        else
            return t1
        end
    end
end

-- 保留n位小数
function M:getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 1/(10 ^ n)
    if nDecimal == 1 then
        nDecimal = nNum;
    end
    local nLeft = nNum % nDecimal;
    return nNum - nLeft;
end

--前面空位补齐0
function M:fillNumWithZero(mNum, count)
    local num_str = tostring(mNum)
    count = count or string.len(num_str)
    if string.len(num_str) < count then
        for i = 1, count - string.len(num_str) do
            num_str = "0" .. num_str
        end
    end
    return num_str
end

function M:setHeroSpineBySG(hero_cid, spine)
    hero_cid = hero_cid or 0
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_cid)
    if hero_cfg then
        spine.gameObject:SetActive(true)
        local hero_spine = hero_cfg.hero_spine
        local sk_data = ResourceUtil:GetSk(hero_spine, "rolespine_" .. string.lower(hero_spine))
        if spine.skeletonDataAsset ~= nil then
            spine.skeletonDataAsset = sk_data
            spine:Initialize(true)
        end
    else
        spine.gameObject:SetActive(false)
    end
    return hero_cfg
end

function M:setHeroSpineByObj(hero_cid, spine_obj)
    local spine = spine_obj:GetComponent("SkeletonGraphic")
    self:setHeroSpineBySG(hero_cid, spine_obj)
end

function M:getCurStageCfg()
    local level = UserDataManager:getCurStage()
    local stage = ConfigManager:getCfgByName("stage")
    return stage[level] or {}
end

function M:getBattleStageCfg()
    local stage_id = UserDataManager:getBattleStage()
    local stage_cfg = ConfigManager:getCfgByName("stage")
    local is_mult = false
    local team_nums = 1
    if stage_cfg and stage_cfg[stage_id].battle_id and stage_cfg[stage_id].battle_id == 0 then
        is_mult = true
        local battle_id_tab = stage_cfg[stage_id]["battle"] or {}
        team_nums = #battle_id_tab
    end
    return stage_cfg[stage_id] or {}, is_mult, team_nums
end

function M:getGuJianStageCfg()
    local stage_id = UserDataManager:getGuJianStage()
    local stage_cfg = ConfigManager:getCfgByName("stage")
    local is_mult = false
    local team_nums = 1
    if stage_cfg and stage_cfg[stage_id].battle_id and stage_cfg[stage_id].battle_id == 0 then
        is_mult = true
        local battle_id_tab = stage_cfg[stage_id]["battle"] or {}
        team_nums = #battle_id_tab
    end
    return stage_cfg[stage_id] or {}, is_mult, team_nums
end

function M:getXiaKeDaoLayerCfg(layer)
    local stage_tab = ConfigManager:getCfgByName("hero_isle_layer")
    local data = stage_tab[layer]
    local battle_id_tab = data["battles"] or {}
    battle_id = battle_id_tab[1] or self.m_battle_id

    local team_nums = 1
    team_nums = #battle_id_tab
    return data or {},true,team_nums
end

function M:getCurStageIdleData()
    local stage = self:getCurStageCfg()
    local staget_idle = stage.idle_id
    local stage = ConfigManager:getCfgByName("stage_idle")
    local curIdle = stage[staget_idle]
    local battle_id = curIdle.battle_id
    return ConfigManager:getCfgStageBattle(battle_id)
    --local stage_battle = ConfigManager:getCfgByName("stage_battle")
    --local battle_data = stage_battle[battle_id]
    --return battle_data
end

-- 英雄背包是否已满
function M:heroBagIsFull()
    local max_cell = 100 + UserDataManager.extra_hero_grid
    local heros = UserDataManager.hero_data:getHerosId()
    return #heros >= max_cell
end

--[[
    uiTarget UI层的图标，3D物体要飞到的位置
    distance UI元素的距离   
    time 时间
]]
function M:_3DMoveTo2DUI(obj_Target, uiTarget, distance, time)
    local camera_3d = nil
    local cameraObj = SceneManager.curScene.obj.transform:Find("Camera")
    if cameraObj ~= nil then
        local _3dcamera = cameraObj.transform:Find("3DCamera")
        camera_3d = UIUtil.findComponent(_3dcamera.transform, typeof(U3DUtil:Get_Camera()))
    end
    local destination = UIUtil.worldToScreenPoint(uiTarget.transform.position)
    local ray = camera_3d:ScreenPointToRay(destination)
    local target_pos = ray:GetPoint(distance)
    return target_pos
end



function M:formatTextString(text, params, time_format)
    local enum_cfg = ConfigManager:getCfgByName("text_enum")
    local function getString(s)
        s = string.sub(s, 2, -2)
        local str_tab = string.split(s, "_")
        local id = tonumber(str_tab[1])
        local value_type = ""
        for i = 2, #str_tab do
            value_type = value_type .. str_tab[i]
            if i < #str_tab then
                value_type = value_type .. "_"
            end
        end
        if value_type == "value" then
            return params[id] or "error"
        elseif value_type == "time" then
            time_format = time_format or "%m-%d %H:%M"
            local time = params[id]
            if time then
                return os.date(time_format, time)
            else
                return "error"
            end
        elseif value_type == "language" then
            local key = params[id]
            return Language:getTextByKey(key or "error")
        else
            local cfg = enum_cfg[value_type]
            if cfg then
                local key = params[id]
                if key then
                    return Language:getTextByKey(cfg[key] or "error")
                end
            end
            return "error"
        end
    end

    return string.gsub(text, "{[%w_]*}", getString)
end



function M:getDisplayLvByHeroData( hero_data ,mode )
    local level = math.max(hero_data.lv, hero_data.clv)
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[level]
    local m_display_level = hero_data.lv
    if upgrade_cfg ~= nil then
        m_display_level = upgrade_cfg.display_level
        --if mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_ARRAY then
        --    if m_display_level <= 300 then
        --        m_display_level = 300;
        --    end
        --end
    end
    return m_display_level;
end


function M:getDisplayLvByLevel( level ,mode, defaultlevel )
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[level]
    local m_display_level = defaultlevel or level
    if upgrade_cfg ~= nil then
        m_display_level = upgrade_cfg.display_level
        --if mode == Battle.BattleGlobalConfig.BATTLE_MODE.FIVE_ARRAY then
        --    if m_display_level <= 300 then
        --        m_display_level = 300;
        --    end
        --end
    end
    return m_display_level;
end


-- 遗物战斗力加成计算
function M:getHeirloomCombatAddRatio(team, assist_heros, heirlooms, wea_solts, mode)
    --wea_solts：法宝列表 有此数据优先使用当前的法宝数据
    local hero_add_ratio_table = {}
    local hero_cid_table = {} --卡牌id
    local hero_rece_table = {} -- 种族id
    local hero_type_table = {} -- 职业类型
    local hero_combat_table = {}
    local use_default_slots = 1
    team = team or {}
    assist_heros = assist_heros or {} --雇佣的英雄
    for k, v in pairs(team) do
        local hero_data = assist_heros[v]
        local hero_cfg = nil
        if hero_data then
            hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
        else
            hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        end
        if hero_data and hero_cfg then
            if mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY 
                    or mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW  
                    or mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
                    or mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE
                    or mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
                hero_data = table.copy(hero_data)
                local lv = math.max(hero_data.lv, hero_data.clv)
                local r_lv = math.max(lv, 300)
                hero_data.lv = r_lv;
                if lv < 300 then
                    hero_data.attrs = UserDataManager:computCfgAttrs(hero_cfg, hero_data.lv, hero_data.evo)
                end
            elseif mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS then
                local cur_season = UserDataManager:getCurSeason()
                local gve_cfg = ConfigManager:getCfgByName("gve")
                local gve_cfg_season = gve_cfg[cur_season] or {}
                local conversion_a = gve_cfg_season.conversion_a or 300 -- 最小等級
                hero_data = table.copy(hero_data)
                local lv = math.max(hero_data.lv, hero_data.clv)
                local r_lv = math.max(lv, conversion_a)
                hero_data.lv = r_lv;
                if lv < conversion_a then
                    hero_data.attrs = UserDataManager:computCfgAttrs(hero_cfg, hero_data.lv, hero_data.evo)
                end
            elseif mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS then
                if SceneManager:getCurSceneModel().m_data.level_up == 1 then
                    local min_lv = 300 -- 最小等級
                    hero_data = table.copy(hero_data)
                    local lv = math.max(hero_data.lv, hero_data.clv)
                    if lv < min_lv then
                        local r_lv = math.max(lv, min_lv)
                        hero_data.lv = r_lv;
                        hero_data.attrs = UserDataManager:computCfgAttrs(hero_cfg, hero_data.lv, hero_data.evo)
                    end
                end
            elseif mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_ONE
                    or mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_THREE
                    or mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_ONE
                    or mode == GlobalConfig.BATTLE_MODE.FULWIN_AREA_ATTACK_LOCAL_THREE then
                local openJusticeIndex = UserDataManager.local_data:getUserDataByKey("fulwin_arena_is_justice", 0)
                -- 0 不公平，1公平
                if openJusticeIndex == 1 then
                    local show_lvXlsxData = ConfigManager:getCommonValueById(721) or {{3,150},{5,300}}
                    local xlsxEvo = hero_cfg.evo
                    local heroLv = 1
                    local commonHeroData1 = show_lvXlsxData[1]
                    local commonHeroData2 = show_lvXlsxData[2]
                    if xlsxEvo == commonHeroData1[1] then
                        heroLv = commonHeroData1[2]
                    elseif xlsxEvo == commonHeroData2[1] then
                        heroLv = commonHeroData2[2]
                    end
                    hero_data = table.copy(hero_data)
                    hero_data.lv = heroLv;
                    hero_data.attrs = UserDataManager:computCfgAttrs(hero_cfg, hero_data.lv, hero_data.evo)
                    use_default_slots = 0
                end
            elseif mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA or mode == GlobalConfig.BATTLE_MODE.MYTH_ARENA_DEFENSE then
                local show_lvXlsxData = ConfigManager:getCommonValueById(727) or {{3,150},{5,300}}
                local xlsxEvo = hero_cfg.evo
                local heroLv = 1
                local commonHeroData1 = show_lvXlsxData[1]
                local commonHeroData2 = show_lvXlsxData[2]
                if xlsxEvo == commonHeroData1[1] then
                    heroLv = commonHeroData1[2]
                elseif xlsxEvo == commonHeroData2[1] then
                    heroLv = commonHeroData2[2]
                end
                hero_data = table.copy(hero_data)
                hero_data.lv = heroLv;
                hero_data.attrs = UserDataManager:computCfgAttrs(hero_cfg, hero_data.lv, hero_data.evo)
                use_default_slots = 0
            end
            local id = hero_data.id
            if hero_cid_table[id] == nil then
                hero_cid_table[id] = {}
            end
            table.insert(hero_cid_table[id], v)

            local race = hero_cfg.race
            if hero_rece_table[race] == nil then
                hero_rece_table[race] = {}
            end
            table.insert(hero_rece_table[race], v)

            local hero_type = hero_cfg.type
            if hero_type_table[hero_type] == nil then
                hero_type_table[hero_type] = {}
            end
            table.insert(hero_type_table[hero_type], v)

            hero_add_ratio_table[v] = 0

            local combat = UserDataManager:computeHeroCombat(hero_data, hero_cfg, true, nil ,wea_solts, nil, use_default_slots)
            hero_combat_table[v] = combat
        end
    end

    heirlooms = heirlooms or {}
    local heirloom = ConfigManager:getCfgByName("heirloom")
    for k, v in pairs(heirlooms) do
        local cfg = heirloom[v]
        if cfg then
            local react = cfg.react or {}
            local atkrating_ratio = cfg.atkrating_ratio or 0
            if #react == 0 then -- 作用全部
                for k, v in pairs(hero_add_ratio_table) do
                    hero_add_ratio_table[k] = v + atkrating_ratio
                end
            else
                local react_type = react[1]
                local react_value = react[2]
                if react_type == 1 then -- 1:作用卡牌id
                    for k, v in pairs(hero_cid_table[react_value] or {}) do
                        hero_add_ratio_table[v] = hero_add_ratio_table[v] + atkrating_ratio
                    end
                elseif react_type == 2 then -- 2:作用种族id
                    for k, v in pairs(hero_rece_table[react_value] or {}) do
                        hero_add_ratio_table[v] = hero_add_ratio_table[v] + atkrating_ratio
                    end
                elseif react_type == 3 then -- 3:作用职业类型
                    for k, v in pairs(hero_type_table[react_value] or {}) do
                        hero_add_ratio_table[v] = hero_add_ratio_table[v] + atkrating_ratio
                    end
                end
            end
        end
    end

    local have_heirloom_combat = 0
    local heros_combat = 0
    for k, v in pairs(hero_add_ratio_table) do
        have_heirloom_combat = have_heirloom_combat + hero_combat_table[k] * (1 + v / 100)
        heros_combat = heros_combat + hero_combat_table[k]
    end
    -- 界面中显示的总战斗力加成的百分比=(上阵队伍有遗物的战斗力-上阵队伍无遗物的战斗力)/上阵队伍无遗物的战斗力
    if heros_combat > 0 then
        return (have_heirloom_combat - heros_combat) / heros_combat, math.ceil(have_heirloom_combat)
    end
    return 0, math.ceil(heros_combat)
end

function M:updateBuffShow(obj, buff_data)
    if IsNull(obj) == true then
        Logger.logError(" updateBuffShow obj is nil ")
        return;
    end
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        for i = 1, 5 do
            local name = "hero_buff_" .. i
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, false)
            --LuaBehaviourUtil.setImg(LuaBehaviour, name, "a_szjc_yin", "common_ui")
        end
        --显示阵营加成特效
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "purple", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "blue", buff_data.lv1 >= 1)

        local race6_list = {}
        if buff_data.lv1 == 1 then
            for i = 2, 5 do
                local name = "hero_buff_" .. i
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, i-1)
            end
            table.insert(race6_list, 1)
        elseif buff_data.lv1 == 2 then
            for i = 1, 3 do
                local name = "hero_buff_" .. i
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, buff_data.race1)
            end
            table.insert(race6_list, 4)
            table.insert(race6_list, 5)
        elseif buff_data.lv1 == 3 then
            for i = 1, 3 do
                local name = "hero_buff_" .. i
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, buff_data.race1)
            end
            for i = 4, 5 do
                local name = "hero_buff_" .. i
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, buff_data.race2)
            end
        elseif buff_data.lv1 == 4 then
            for i = 2, 5 do
                local name = "hero_buff_" .. i
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, buff_data.race1)
            end
            table.insert(race6_list, 1)
        elseif buff_data.lv1 == 5 then
            for i = 1, 5 do
                local name = "hero_buff_" .. i
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, buff_data.race1)
            end
        else
            for i = 1, 5 do
                table.insert(race6_list, i)
            end
        end

        for i = 1, buff_data.lv2 - 10 do
            if i <= #race6_list then
                local name = "hero_buff_" .. race6_list[i]
                local bf_icon = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, name, true)
                self:heroBuffSetImg(bf_icon, 6)
            end
        end
    end
end

function M:heroBuffSetImg(obj, race_id)
    if race_id == 0 or IsNull(obj) then
        return 
    end
    local race_data = GlobalConfig.TYPE_HERO_RACE[race_id]
    UIUtil.setImg(obj.transform, race_data.jc_icon,  "common_ui")
end

-- 上报lua错误信息
local device_error_logs = {}
function M:sendLuaError(error_msg, error_detail)
    do return end -- 报错不直接发送后端服务器
    if GameVersionConfig and GameVersionConfig.MASTER_URL and not GameVersionConfig.Debug then
        local send_time = device_error_logs[error_msg]
        if send_time ~= nil then
            return
        end
        device_error_logs[error_msg] = os.time()
        local errorMessage = error_msg .. "\n" .. tostring(error_detail)
        errorMessage = string.sub(errorMessage, 1, 1000)
        local own_uid = UserDataManager.user_data:getUid()
        errorMessage = tostring(own_uid) .. "\n" .. "c_ver=" .. tostring(GameVersionConfig.CLIENT_VERSION) .. ",r_ver=" .. tostring(GameVersionConfig.GAME_RESOURCES_VERION) .. "\n" .. errorMessage
        -- errorMessage = string.urlencode(errorMessage)
        local md5_str = ""
        if CS.wt.framework.LuaFileHelper.Inst.MD5EncryptString then
            md5_str = CS.wt.framework.LuaFileHelper.Inst:MD5EncryptString(error_msg)
        end
        local url = GameVersionConfig.MASTER_URL .. "/front_err/?err_id=" .. md5_str .. "&" .. NetUrl.getExtUrlParam()
        local params = {title = "LUA ERROR : " .. GameVersionConfig.MASTER_URL, text = errorMessage}
        NetWork:httpRequest(
            function()
            end,
            url,
            GlobalConfig.POST,
            params,
            "front_err",
            0
        )
    end
end

-- 上报中控防沉迷
function M:sendHopeReport(hope)
    local url = NetUrl.getUrlForKey("hope_report")
    local params = {rule_name = hope.ruleName, instr_trace_id = hope.trace_id}
    NetWork:httpRequest(
        function()
        end,
        url,
        GlobalConfig.POST,
        params,
        "hope_report",
        0
    )
end

--支付接口 - 做统计使用 1发起  2成功 3取消 4失败
function M:sendPayment(charge_id, type,payInfo)

    Logger.logAlways("sendPayment ====== " .. tostring(type))
        
    local url = NetUrl.getUrlForKey("payment")
    local params = {
        charge_id = charge_id,
        action = type,
        package_name = SDKUtil.sdk_params.applicationId or "com.jxjh.default",

        product_id        = "", --产品ID
        game_order_id     = "", --游戏订单号
        platform_order_id = "", -- 平台订单号
        app_account_token = ""

    }

    if payInfo then
        params.product_id = payInfo.cost
        params.game_order_id = payInfo.order_id
    end
    
        Logger.logAlways(params,"sendPayment ====== ")


    --"package_name": "", // 包名
    --"product_id": "", //产品ID
    --"game_order_id": "", //游戏订单号
    --"platform_order_id": "", // 平台订单号
    --"app_account_token": "", // iOS 订单的appAccountToken


    NetWork:httpRequest(
        function()
        end,
        url,
        GlobalConfig.POST,
        params,
        "payment",
        0
    )
end


--[[
    存储数据到本地
]]
function M:saveTableDataWithName(data, file_name)
    data = {type = tostring(type(data)), data = data}
    local str = Json.encode(data) or ""
    local ret = io.writefile(file_name, str)
    return ret
end

function M:getTableDataByName(file_name)
    local exist_flag = io.exists(file_name)
    if exist_flag then
        local read_data = io.readfile(file_name)
        if read_data then
            local data = Json.decode(read_data)
            if data then
                return data.data
            end
        end
    end
    return {}
end

function M:updateBgImg(img, img_name)
    if not IsNull(img) then
        local texture_bg = img.gameObject:GetComponent("TextureLoadSet")
        local bg_atlas = "atlas_" .. img_name
        if texture_bg then
            texture_bg:SetSprite(img_name, bg_atlas, true)
        end
    end
    return img
end

function M:updateResourcesImg(img, img_name)
    if not IsNull(img) then
        local texture_bg = img.gameObject:GetComponent("TextureLoadSet")
        if texture_bg then
            local ab_name = string.gsub(img_name, "/", "_")
            texture_bg:SetSprite(img_name, string.lower(ab_name), false)
        end
    end
    return img
end

function M:updateResourcesTexture(tex, tex_name)
    if not IsNull(tex) then
        local texture_bg = tex.gameObject:GetComponent("RawImageLoadSet")
        if texture_bg then
            local ab_name = string.gsub(tex_name, "/", "_")
            texture_bg:SetTexture(tex_name, string.lower(ab_name), false)
        end
    end
    return tex
end

function M:updateSpineLoadSet(obj, spineName, animName, trackIndex, isLoop)
    if not IsNull(obj) then
        local spineLoadSet = obj.gameObject:GetComponent("SpineLoadSet")
        if spineLoadSet then
            local ab_name = string.gsub(spineName, "/", "_")
            spineLoadSet:SetSpine(spineName, string.lower(ab_name), animName, trackIndex, isLoop)
        end
    end
    return obj
end

--[[
	挂机奖励
]]
function M:getHangUpReward(item_cfg, use_num)
    if item_cfg == nil then
        return
    end
    use_num = use_num or 0
    local effect = item_cfg.effect
    local item_type = item_cfg.type
    local stage = ConfigManager:getCfgByName("stage")
    local cur_stage = UserDataManager:getCurStage()
    local stage_item = stage[cur_stage]
    local reward = {}
    if stage_item then
        local stage_idle = ConfigManager:getCfgByName("stage_idle")
        local idle_drop = ConfigManager:getCfgByName("idle_drop")
        local stage_idle_item = stage_idle[stage_item.idle_id]
        if stage_idle_item then
            -- 4 金币 5 英雄经验 6 粉尘
            if item_type == GlobalConfig.ITEM_TYPE.IDLE_COIN then
                local reward_coin = stage_idle_item.coin * effect / stage_idle_item.rewards_cd
                table.insert(reward, {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, Mathf.Round(reward_coin * use_num)})
            elseif item_type == GlobalConfig.ITEM_TYPE.IDLE_HERO_EXP then
                local reward_hero_exp = stage_idle_item.hero_exp * effect / stage_idle_item.rewards_cd
                table.insert(reward, {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, Mathf.Round(reward_hero_exp * use_num)})
            elseif item_type == GlobalConfig.ITEM_TYPE.IDLE_DUST then
                local dust = stage_idle_item.idle_drop.dust
                local idle_drop_item = idle_drop[dust[1]] or {}
                local random_reward = idle_drop_item.random_reward or {}
                local rewards = random_reward.rewards or {}
                local reward_dust = 0
                if rewards[1] and rewards[1][3] then
                    reward_dust = rewards[1][3] * effect / dust[2]
                end
                table.insert(reward, {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, Mathf.Round(reward_dust * use_num)})
            else
                local reward_coin = stage_idle_item.coin * effect / stage_idle_item.rewards_cd
                table.insert(reward, {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, Mathf.Round(reward_coin * use_num)})

                local reward_hero_exp = stage_idle_item.hero_exp * effect / stage_idle_item.rewards_cd
                table.insert(reward, {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, Mathf.Round(reward_hero_exp * use_num)})

                local dust = stage_idle_item.idle_drop.dust
                local idle_drop_item = idle_drop[dust[1]] or {}
                local random_reward = idle_drop_item.random_reward or {}
                local rewards = random_reward.rewards or {}
                local reward_dust = 0
                if rewards[1] and rewards[1][3] then
                    reward_dust = rewards[1][3] * effect / dust[2]
                end
                table.insert(reward, {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, Mathf.Round(reward_dust * use_num)})
            end
        end
    end
    return reward
end

function M:getStageUnlock(unlock_condition)
    unlock_condition = unlock_condition or 0
    local open_flag = false
    local tips_str = Language:getTextByKey("new_str_0055")
    local cur_stage = UserDataManager:getCurStage()
    if cur_stage >= unlock_condition then
        open_flag = true
    else
        local stage = ConfigManager:getCfgByName("stage")
        local stage_item = stage[unlock_condition] or {}
        local name = Language:getTextByKey(tostring(stage_item.map_point_name))
        tips_str = Language:getTextByKey("new_str_0522", name)
    end
    return open_flag, tips_str
end

function M:teamNoHero(team)
    local no_hero = true
    team = team or {}
    for k,v in pairs(team) do
        if #v > 0 then
            no_hero = false
            break
        end
    end
    return no_hero
end

function M:replacePlayerName(word_key)
    local word = Language:getTextByKey(word_key)
    local name_raw = UserDataManager.user_data:getUserStatusDataByKey("name")
    local name = string.filterInvalidChars(name_raw)
    local num = 0
    word, num = string.gsub(word, "{player_name}", tostring(name))
    return word, num
end

--通用道具流光特效
function M:creatCommonItemEffect(parent, evo, scale)
    local effect_obj = self:createPrefab("Common/CommonItemEffect", parent.transform)
    if effect_obj then
        evo = evo or 11
        --effect_obj.transform:SetParent(parent.transform, false)
        UIUtil.setScale(effect_obj.transform, scale or 1)
        UIUtil.setObjectVisible(effect_obj.transform, false, "UI_RewardHeroDispatchPop_TuBiao_Blue01")
        UIUtil.setObjectVisible(effect_obj.transform, false, "UI_RewardHeroDispatchPop_TuBiao_Col01")
        UIUtil.setObjectVisible(effect_obj.transform, false, "UI_RewardHeroDispatchPop_TuBiao_Green01")
        UIUtil.setObjectVisible(effect_obj.transform, false, "UI_RewardHeroDispatchPop_TuBiao_Red01")
        UIUtil.setObjectVisible(effect_obj.transform, false, "UI_RewardHeroDispatchPop_TuBiao_Violet01")
        UIUtil.setObjectVisible(effect_obj.transform, false, "UI_RewardHeroDispatchPop_TuBiao_Yellow01")
        if evo == 1 or evo == 2 then
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Green01")
        elseif evo == 3 or evo == 4 then
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Blue01")
        elseif evo == 5 or evo == 6 then
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Violet01")
        elseif evo == 7 or evo == 8 then
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Yellow01")
        elseif evo == 9 or evo == 10 then   
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Red01") 
        elseif evo >= 10 then
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Col01")
        else
            UIUtil.setObjectVisible(effect_obj.transform, true, "UI_RewardHeroDispatchPop_TuBiao_Violet01")
        end
    end
    return effect_obj
end

--运营活动大奖展示特效
function M:creatCommonActiveEffect(parent, evo, scale)
    if parent == nil then
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(parent)
    if luaBehaviour then
        local back_ef = luaBehaviour:FindGameObject("back_effect")
        UIUtil.destroyAllChild(back_ef.transform)
        local gift_item = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Glow_005", back_ef)
        return gift_item
    end
    return nil
end

function M:creatChargeEffect(parent, data)
    local reward_data = RewardUtil:getProcessRewardData(data)
    if GameUtil:checkShowActivesEffect(reward_data.icon_name) == true and reward_data.quality > 5 then
        GameUtil:creatCommonActiveEffect(parent, reward_data.quality, 0.9)
    end
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS and reward_data.quality >=5 then
        GameUtil:creatCommonActiveEffect(parent, reward_data.quality, 0.9)
    end
end

function M:dayCompute()
    local reg_ts = UserDataManager.reg_ts
    local server_ts = UserDataManager:getServerTime()
    local ms = server_ts - reg_ts
    local day = self:NumberOfDaysInterval(server_ts, reg_ts, 0)
    local m_day = day + 1
    return self:formatNum(m_day) 
end

-- 计算账号已注册天数
function M:playerRegisterDays()
    local reg_ts = UserDataManager.reg_ts
    local server_ts = UserDataManager:getServerTime()
    local day = math.floor((TimeUtil.getIntTimestamp(server_ts) - TimeUtil.getIntTimestamp(reg_ts))/86400) + 1
    return day
end

--两个时间的天数差              --时间戳1  时间戳2  多少点开始算第二天
function M:NumberOfDaysInterval(unixTime1,unixTime2,dayFlagHour)
    if dayFlagHour == nil then dayFlagHour = 0 end
    if unixTime1 == 0 or unixTime2 == 0 then
        Logger.logError("获取时间差输入时间戳为0--")
        return 0
    end
    -- local key1,str1,time1 = self:GetDayKeyByUnixTime(unixTime1,dayFlagHour)
    -- local key2,str2,time2 = self:GetDayKeyByUnixTime(unixTime2,dayFlagHour)
    local time3 = TimeUtil.getIntTimestamp(unixTime1)
    local time4 = TimeUtil.getIntTimestamp(unixTime2)
    local sub = math.abs(time4 - time3)/(24*60*60)
    return sub
end

-- 获取两个时间差后，得到当前第几天，不满足一天按一天算
function M:NumberOfDaysIntervalDay(unixTime1,unixTime2)
    local differenceTimer = unixTime2 - unixTime1
    return math.ceil(differenceTimer / (60*60*24))
end

-- 活动开启了几天
function M:getActityOpenDayCount(startTimer)
    local serverTimer = UserDataManager:getServerTime()
    local openDayCount = GameUtil:NumberOfDaysIntervalDay(startTimer,serverTimer)
    openDayCount = math.floor(openDayCount)
    openDayCount = openDayCount <= 0 and 1 or openDayCount
    return openDayCount
end

--获取时间戳对应的天数（天数规则不是自然天，是(hour)点前当前一天算）
function M:GetDayKeyByUnixTime(unixTime,hour)
    if hour == nil then hour = 0 end
    local retStr = os.date("%Y-%m-%d %H:%M:%S",unixTime)
    local time = unixTime
    local data = os.date("*t",time)
    --dump(data)

    --(hour)点前按前一天算
    if data.hour < hour then
        time = time - 24*60*60        
    end

    local data2 = os.date("*t",time)
    --dump(data2)
    data2.hour = 0
    data2.min = 0
    data2.sec = 0

    local time2 = os.time(data2)

    local dayKey = os.date("Key%Y%m%d",time2)
    local timeBase = time2

    --天数key，日期格式字符串，天数key 0点的时间戳
    return dayKey,retStr,timeBase
end

function M:taskDataSort(data)
    table.sort(data, function(data1, data2)
        local lock1 = data1.lock_flag == true and 1 or 0
        local lock2 = data2.lock_flag == true and 1 or 0
        local play_guide1 = data1.cfg.play_guide or 0
        local play_guide2 = data2.cfg.play_guide or 0
        local order1 = data1.cfg.order or 0
        local order2 = data2.cfg.order or 0
        if data1.status == data2.status then
            if lock1 == 1 and lock2 == 1 then
                if order1 == order2 then
                    return data1.id < data2.id
                else
                    return order1 < order2
                end
            elseif lock1 == 0 and lock2 == 0 then
                if play_guide1 == play_guide2 then
                    if order1 == order2 then
                        return data1.id < data2.id
                    else
                        return order1 < order2
                    end
                else
                    return play_guide1 > play_guide2
                end
            else
                return lock1 > lock2
            end
        else
            return data1.status > data2.status
        end
    end)
end

function M:heroInLocalArenaDefenseTips(hero_oids, callback_func, lan_key)
    local tips_flag = false
    local hero_names = ""
    for _,hero_oid in pairs(hero_oids) do
        local in_flag = UserDataManager.hero_data:heroInLocalArenaDefense(hero_oid)
        if in_flag then -- 是否在竞技场防守队伍中
            tips_flag = true
            local _,hero_cfg =  UserDataManager.hero_data:getHeroDataById(hero_oid)
            local hero_name = Language:getTextByKey(hero_cfg.name)
            hero_names = hero_names .. (hero_names == "" and "" or "、") .. hero_name
        end
    end
    if tips_flag then
        local pop_params =
        {
            on_ok_call = function(msg)
                if callback_func then
                    callback_func()
                end
            end,
            no_close_btn = false,
            tow_close_btn = true,
            text = Language:getTextByKey(lan_key, hero_names),
        }
        static_rootControl:openView("Pops.CommonPop", pop_params, "local_arena_defense_tips")
    else
        if callback_func then
            callback_func()
        end
    end
    return tips_flag
end

--添加status类型， 0--原本类型，奖励全部领取之后不显示里程奖励入口   1--聚宝山类型，奖励全部领取之后仍然可以看到里程碑奖励入口，展示最后一个奖励icon，文字显示已领完
function M:updateQuestSpecialNode(view, quest_type, scale, param, status)
    local m_status = status or 0 
    local m_scale = scale or 0.7
    local chapter_quest = UserDataManager:getChapterQuestSpecialData(quest_type, param)
    local chapter_quest_first = chapter_quest[1]
    if chapter_quest_first then
        if chapter_quest_first.status == 2 then -- 完成可领取
            view:setTextByLanKey("quest_special_btn_text", "new_str_0655")
            view:setObjectVisible("effect_lq", true)
        elseif chapter_quest_first.status == 0 then -- 未完成
            local diff_stage = chapter_quest_first.target_value - chapter_quest_first.cur_progress
            view:setObjectVisible("effect_lq", false)
            if quest_type == 44 then
                view:setTextByLanKey("quest_special_btn_text", "new_str_0656", diff_stage)
            elseif quest_type == 1 then
                view:setTextByLanKey("quest_special_btn_text", "new_str_0652", diff_stage)
            else
                view:setTextByLanKey("quest_special_btn_text", "new_str_0657", diff_stage)
            end
        elseif chapter_quest_first.status == -1 and m_status == 1 then
            view:setTextByLanKey("quest_special_btn_text", "gf_str_0097") --设置文本，已领完
        end
        local quest_special_reward_node = view:findGameObject("quest_special_reward_node")
        if quest_special_reward_node then
            local transform = quest_special_reward_node.transform
            UIUtil.destroyAllChild(transform)
            local drop = {}
            if chapter_quest_first.status ~= -1 then
                drop = chapter_quest_first.cfg.drop or {}
            elseif chapter_quest_first.status == -1 and m_status == 1 then
                drop = chapter_quest[#chapter_quest].cfg.drop or {}
            end
            if #drop > 0 then
                local item = GameUtil:createItemElement(drop[1], true, false, nil, true)
                local canvas_group = item:GetComponent("CanvasGroup")
                canvas_group.blocksRaycasts = false
                item.transform:SetParent(transform, false)
                local data = RewardUtil:getProcessRewardData(drop[1])
                if chapter_quest_first.status ~= -1 then
                    GameUtil:creatCommonItemEffect(item, data.quality, 0.9)
                end
                UIUtil.setScale(item.transform, m_scale)
            end
        end
        view:setObjectVisible("quest_special_btn", chapter_quest_first.status ~= -1 or m_status == 1)
    else
        view:setObjectVisible("quest_special_btn", false)
    end
end

function M:getMoneyTypeNum(price, ratio)
    local money_type = ConfigManager:getCommonValueById(331)
    local unit =  "¥"
    for k,v in pairs(GlobalConfig.TYPE_MONEY) do
        if money_type == v.name then
            unit = v.sign_name
        end
    end
    local switch_num = self:switchMoneyType(price)
    if switch_num then
        if ratio and ratio ~= 1 then
            return GameUtil:formatNum(switch_num*ratio)..unit
        end
        if money_type == "CNY" then
            --如果货币是人民币还保持符号在后面不变
            return switch_num..unit
        else
            return unit..switch_num
        end
    end
    return ""
end

function M:getMoneyTypeStr()
    local money_type = ConfigManager:getCommonValueById(331)
    local unit =  "¥"
    for k,v in pairs(GlobalConfig.TYPE_MONEY) do
        if money_type == v.name then
            unit = v.sign_name
        end
    end
    return unit
end

function M:switchMoneyType(price)
    local money_type = ConfigManager:getCommonValueById(331)
    local charge_tab = ConfigManager:getCfgByName("price_show")
    local price_data = charge_tab[price]
    if price_data == nil then
        return price
    end
    local num = price_data[money_type] or price
    return GameUtil:formatNum(num) 
end


--将一个字符串转换为时间戳
function M:stringToTimesTamp(str)
    local date_pattern = "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)"
	local start_time = str or "1971-01-01 1:00:00"
    local _, _, _y, _m, _d, _hour, _min, _sec = string.find(start_time, date_pattern)
    local timestamp = os.time({year=_y, month = _m, day = _d, hour = _hour, min = _min, sec = _sec})
    return timestamp
end

function M:getFunmationStatus()
    for k,v in pairs(static_rootControl.m_chilrenList) do
		if v.m_model and v.m_model:getName() == "Formation" then
            return v.m_model.can_click or false
        end
	end
end

function M:playSceneConfigBGM(config_id)
    local scene_config = ConfigManager:getCfgByName("scene_config")
    local scene_info = scene_config[config_id]
    local bgm =  scene_info and scene_info.bgm or ""
    if bgm ~= "" then
        audio:SendEvtBGM(bgm)
    end
end

--查看双倍活动开启
function M:checkDoubleActiveByType(type_id)
    --type 1挂机\ 2迷宫\ 3悬赏\ 4苗疆
    if UserDataManager.active_double_id == 0 and UserDataManager.m_cur_calendar_id == 0 then
        return false
    end
    if UserDataManager.active_double_id ~= 0 and self:checkActDoubleByType(type_id) then
        return true
    end
    if UserDataManager.m_cur_calendar_id ~= 0 and self:checkSwordDoubleByType(type_id) then
        return true
    end
    return false
end

function M:checkActDoubleByType(type_id)
    local act_tab = ConfigManager:getCfgByName("active")
    local doub_tab = ConfigManager:getCfgByName("double_reward")
    local act_cfg = nil
    act_cfg = act_tab[UserDataManager.active_double_id]
    if act_cfg then
        local do_version_tab = doub_tab[act_cfg.version]
        if do_version_tab then
            for k,v in pairs(do_version_tab) do
                if k == type_id then
                    return true
                end
            end
            return false
        else
            return false
        end
    else
        return false
    end
end

function M:checkSwordDoubleByType(type_id)
    local sword_double_cfg = ConfigManager:getCfgByName("sword_double") or {}
    local active_data = UserDataManager:getActivesDataByOpenId(280)
    if active_data then
        local vsn = active_data.version
        local cur_vsn_cfg = sword_double_cfg[vsn] or {}
        local cur_calendar_cfg = cur_vsn_cfg[UserDataManager.m_cur_calendar_id] or {}
        if cur_calendar_cfg.type and tonumber(cur_calendar_cfg.type) == tonumber(type_id) then
            return true
        end
    end
    return false
end

--大侠试炼版本期数,当前天数
function M:checkRecruit()
    local act_tab = ConfigManager:getCfgByName("active")
    local recruit_tab = ConfigManager:getCfgByName("recruit")
    local vers = {}
    local day = 1
    local c_ver = 1
    local last_vsn = false
    if UserDataManager.m_actives then
        for k,v in pairs(UserDataManager.m_actives) do
            local c_cfg = act_tab[v.id]
            if c_cfg and c_cfg.open_id == 71 then
                table.insert( vers, c_cfg.version)
                if v.remain_ts > 0  then
                    c_ver = c_cfg.version
                    day = self:NumberOfDaysInterval(UserDataManager:getServerTime(), v.start_ts, 0)    
                end
                if v.remain_ts == -1 and c_cfg.version == #recruit_tab then
                    return {c_cfg.version},c_cfg.version,7
                end
            end
        end
        return vers, c_ver, day+1
    end
    return {},1,1
end

local __chinese_num = {}
local __chinese_unit = {}

-- 数字转大写
function M:numberToChineseString(num)
    if next(__chinese_num) == nil then
         for k,v in ipairs(GlobalConfig.CHINESE_NUM_LAN) do
             __chinese_num[k] = Language:getTextByKey(v)
         end
    end
    if next(__chinese_unit) == nil then
        for k,v in ipairs(GlobalConfig.CHINESE_UNIT_LAN) do
            __chinese_unit[k] = Language:getTextByKey(v)
        end
    end
    local ten_str = __chinese_num[2] .. __chinese_unit[2]
    local ten_len = string.len(ten_str)
    num = math.floor(num)
    if num == 0 then
        return __chinese_num[1]
    end
    local num_len = string.len(num)
    if num_len > 13 or num_len == 0 or num < 0 then
        return tostring(num)
    end
    local num_str = ""
    local zero_num = 0
    for i=1,num_len do
        local one_num = tonumber(string.sub(num, i,i))
        if one_num == 0 then
            zero_num = zero_num + 1
        else
            if zero_num > 0 then
                num_str = num_str .. __chinese_num[1]
            end
            num_str = num_str .. __chinese_num[one_num+1]
            zero_num = 0
        end
        if zero_num < 4 and ((num_len - i) % 4 == 0 or one_num ~= 0) then
            num_str = num_str .. __chinese_unit[num_len-i+1]
        end
    end
    local sub_str = string.sub(num_str, 1, ten_len)
    --- 开头的 "一十" 转成 "十"
    if sub_str == ten_str then
        num_str = string.sub(num_str, ten_len//2 + 1, string.len(num_str))
    end
    return num_str
end

function M:insertProcessItemData(show_data, filter_func)
    local data = UserDataManager.item_data:getItemsIdByFilterFunc(filter_func)
    for i,v in ipairs(data) do
        local item_data = UserDataManager.item_data:getItemDataById(v)
        local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, v, item_data.num})
        table.insert(show_data ,data)
    end
    self:bagDataSort(show_data)
    return show_data
end

function M:insertMysticesData(show_data)
    local mystics_data = {}
    local mystic_ids = UserDataManager.mystic_data:getMysticesId()
    for i,v in ipairs(mystic_ids) do
        local mystic_data = UserDataManager.mystic_data:getMysticDataById(v)
        local wear = mystic_data.wear or ""
        if #wear == 0 then --不被其他人装备的
            local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, mystic_data.id, mystic_data.star or 1})
            data.user_num = 1
            table.insert(mystics_data ,data)
        end
    end
    table.insertto(show_data, mystics_data)
end

function M:insertEquipsData(show_data)
    local equips_data = {}
    local equips_id = UserDataManager.equip_data:getEquipsId()
    for i,v in ipairs(equips_id) do
        local equip_data = UserDataManager.equip_data:getEquipDataById(v)
        local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, equip_data.id, equip_data.race, v, equip_num=equip_data.amount or 0})
        data.user_num = equip_data.amount or 0
        table.insert(equips_data ,data)
    end
    GameUtil:bagDataSort(equips_data)
    table.insertto(show_data, equips_data)
end

function M:insertRedPacketData(show_data)
    local redpacket_data = {}
    local red_packet_data = UserDataManager:getmRedPacketData()
    for i,v in pairs(red_packet_data) do
        if i ~= "send_count" then
            local id = tonumber(i)
            local nums = v.num or 0
            local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.RED_ENVELOPE, id,nums})
            data.user_num = nums
            table.insert(redpacket_data ,data)
        end
    end
    table.insertto(show_data, redpacket_data)
end

function M:getRedPacketData(id)
    local redpacket_data = {}
    local red_packet_data = UserDataManager:getmRedPacketData()
    for i,v in pairs(red_packet_data) do
        if id == tonumber(i) then
            
        end
        local nums = v
        local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.RED_ENVELOPE, id,nums})
        data.user_num = nums or 0
        return data
    end
end


function M:bagDataSort(data)
    local function sortType(data1, data2)
        local quality1 = data1.item_cfg.quality
        local quality2 = data2.item_cfg.quality
        local sort1 = data1.item_cfg.sort
        local sort2 = data2.item_cfg.sort
        if sort1 == 5 or sort2 == 5 then  --好感道具排序排在普通道具后面
            if sort1 == sort2 then 
                if quality1 == quality2 then
                    return tonumber(data1.data_id) < tonumber(data2.data_id)
                else
                    return quality1 > quality2
                end
            else
                return sort1 < sort2
            end
        else
            if quality1 == quality2 then
                return tonumber(data1.data_id) < tonumber(data2.data_id)
            else
                return quality1 > quality2
            end
        end
    end
    table.sort(data, sortType)
end

--运营活动 展示特效特殊商品
function M:checkShowActivesEffect(str)
    if str == "a_ui_jingying" or str == "a_ui_jingying_jin" or str == "a_ui_jingying_huo"
        or str == "a_ui_jingying_mu" or str == "a_ui_jingying_shui" or str == "a_ui_sixuanyi"
        or str == "icon_fangju" or str == "icon_huoxi"or str == "icon_jinxi"or str == "icon_miji"
        or str == "icon_muxi"or str == "icon_shuixi"or str == "icon_wuqi"or str == "icon_yangxi"
        or str == "icon_yinxi"or str == "icon_yinyang"or str == "icon_zixuanka" then
        return true
    end    
    return false
end

--江湖获取当前关卡位置
function M:getCurMapData()
    local jianzhu_tab = {}
    local cur_stage = UserDataManager:getCurStage()
    local map_tab = ConfigManager:getCfgByName("regional_map")
    local task_tab = ConfigManager:getCfgByName("regional_task")
    local scene_info_tab = ConfigManager:getCfgByName("worldsceneevent_info")
    local map_area_tab = ConfigManager:getCfgByName("map_area")
    local regional_task_done = UserDataManager:getRegionalTaskDoneData()
    local curSeason = UserDataManager:getCurSeason()
    local curDay = GameUtil:dayCompute()
    --[[
    for k,v in pairs(scene_info_tab) do
        if v.type == 1 then
            local map = map_tab[k]
            if map then
                local map_area_data = map_area_tab[map.area] or {}
                local map_season = map_area_data.season or 0
                local unlock_days = map.unlock_days or 1
                if map.stage_open > 0 and map.stage_open <= cur_stage and curDay >= unlock_days and map_season <= curSeason then
                    table.insert(jianzhu_tab, map)
                end
            else
                Logger.logWarningAlways(k,"regional_map and worldsceneevent_info config is error")
            end
        end
    end
    ]]--
    table.sort(jianzhu_tab, function(a,b)
        return a.stage_open < b.stage_open
    end)
    local cur_map = nil
    local isDone = false
    for k,v in ipairs(jianzhu_tab) do
        local task_count = 0
        local area = regional_task_done[tostring(v.area)]
        if area ~= nil then
            local scene = area.scenes[tostring(v.map_id)]
            if scene ~= nil then
                for k,v in pairs(scene.tasks) do
                    local task = task_tab[v]
                    if task ~= nil and task.task_count ~= 1 then
                        task_count = task_count + 1
                    end
                end
            end
        end
        local map_data = map_tab[v.map_id]
        if task_count <= map_data.regional then
            cur_map = v
            isDone = task_count == map_data.regional
            if task_count < map_data.regional then
                break
            end
        end
    end
    return cur_map, isDone
end

function M:formatInputText(text)
    local new_text = string.gsub(tostring(text),"<quad(.*)>*","***")
    new_text = string.gsub(tostring(new_text),"<size(.*)>*","***")
    new_text = string.gsub(tostring(new_text),"<material(.*)>*","***")
    return new_text
end


function M:BitAnd(num1, num2)
	local str1, str2, len = self:makeSameLength(num1, num2)
	local rtmp = ""
	for i = 1, len do
		local st1 = tonumber(string.sub(str1, i, i))
		local st2 = tonumber(string.sub(str2, i, i))
		if(st1 == 0) then
			rtmp = rtmp .. "0"	
		else
			if (st2 ~= 0) then
				rtmp = rtmp .. "1"
			else
				rtmp = rtmp .. "0"
			end
		end
	end
	rtmp = tostring(rtmp)
	return rtmp
end

function M:makeSameLength(num1, num2)
	local str1 = self:ToSecond(num1) 
	local str2 = self:ToSecond(num2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local len = 0
	local x = 0
	
	if (len1 > len2) then
		x = len1 - len2
		for i = 1, x do
			str2 = "0" .. str2
		end
		len = len1
	elseif (len2 > len1) then
		x = len2 - len1
		for i = 1, x do
			str1 = "0" .. str1
		end
		len = len2
	end
	len = len1
	return str1, str2, len
end

--数字转二进制
function M:ToSecond(num)
	local str = ""
	local tmp = num
	while (tmp > 0) do
		if (tmp % 2 == 1) then
			str = str .. "1"
		else
			str = str .. "0"
		end
		
		tmp = math.modf(tmp / 2)
	end
	str = string.reverse(str)
	return str
end

--创建激活装备种族特效
function M:creatEqpActiveRaceEffect(race_img, race, scale)
    if race_img then
        UIUtil.destroyAllChild(race_img.transform)
        local tx_name = ""
        if race == 1 then
            tx_name = "UI_ItemNode_Jin_01"
        elseif race == 2 then   
            tx_name = "UI_ItemNode_Huo_01"
        elseif race == 3 then   
            tx_name = "UI_ItemNode_Mu_01"
        elseif race == 4 then   
            tx_name = "UI_ItemNode_Shui_01"
        elseif race == 5 or race == 6 then   
            tx_name = "UI_ItemNode_Yang_01"
        end
        local item = ResourceUtil:GetUIEffectItem("ItemNode/" .. tx_name, race_img)
        if scale then
            UIUtil.setScale(item.transform, scale)
        else
            UIUtil.setScale(item.transform, 2.4)
        end
        return item
    end
end

function M:getRacesByRegionId(region_id)
    local mining_region_cfg = ConfigManager:getCfgByName("mining_region")
    local races = nil
    if mining_region_cfg and mining_region_cfg[tonumber(region_id)] then
        races = mining_region_cfg[tonumber(region_id)].race
    end
    return races
end

-- 夺宝奇兵
function M:getActiveRacesByRegionId(region_id, version)
    local mining_region_cfg = ConfigManager:getCfgByName("active_mining_region")
    local races = nil
    if mining_region_cfg and mining_region_cfg[version] and mining_region_cfg[version][tonumber(region_id)] then
        races = mining_region_cfg[version][tonumber(region_id)].race
    end
    return races
end

--词缀品质获取颜色
function M:checkAttrsQuality(id)
	local equip_affix_tab = ConfigManager:getCfgByName("equip_affix")
	local affix_cfg = equip_affix_tab[id]
	local quality = 1
	if affix_cfg then
		quality = affix_cfg.affix_quality
	end
	if quality == 1 then
		return Color.New(83/255, 176/255, 1/255)
	elseif quality == 2 then
		return Color.New(59/255, 173/255, 231/255)	
	elseif quality == 3 then
		return Color.New(237/255, 116/255, 248/255)	
	elseif quality == 4 then
		return Color.New(231/255, 125/255, 10/255)	
	end
	return Color.New(83/255, 176/255, 1/255)
end

function M:getEquipLevel(quality)
    if quality>= 1 and quality <= 8 then
        return 1
    elseif quality == 9 then
        return 2
    elseif quality == 10 then
        return 3
    elseif quality == 11 then
        return 4    
    elseif quality == 12 then
        return 5
    else
        return 4    
    end
end

--侠客品质
function M:getHeroQualityData(quality)
    return GlobalConfig.HERO_QUALITY_SETTING[quality] or GlobalConfig.HERO_QUALITY_SETTING[1]
    --return GlobalConfig.HERO_QUALITY_COMMON_SETTING[quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
end

function M:getRacesByTopArenaRaceTeamIdx(team_index, races)
    local new_races = {}
    new_races = {races[team_index], races[3]}
    return new_races
end

function M:getUnionWarCellStartIndex(union_war_data)
    local own_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
    local left_guild_id = union_war_data.vs[1]
    local start_index = 0
    if own_guild_id ~= left_guild_id then
        start_index = GlobalConfig.UNION_WAR_BUILDINGS_COUNT + 1
    end
    return start_index
end

--更新特殊道具
function M:updateItemEffect(reward_data)
    if reward_data and reward_data.item_effect == nil and reward_data.item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
        local effect_tab = {}
        local season = UserDataManager:getCurSeason()
        local season_day = UserDataManager:getCurSeasonDay()
        local gacha_hero_tab = ConfigManager:getCfgByName("gacha_hero")
        local gache_hero_need_tab = gacha_hero_tab[reward_data.item_cfg.effect]
        if gache_hero_need_tab then
            for i, val in ipairs(gache_hero_need_tab) do
                local isInSeason = false
                if val.season < season or (val.season == season and val.season_day <= season_day) then
                    isInSeason = true
                end
                if isInSeason == true and val.weight ~= 0 then
                --if season >= val.season and val.weight ~= 0 then
                    if val.reward[1] then
                        val.reward[1].id = val.id
                        table.insert(effect_tab, #effect_tab + 1, val.reward[1])
                    end
                end
            end
        end
        reward_data.item_effect = effect_tab
        reward_data.item_content_show = effect_tab

        --背包详情处理逻辑
--[[
            local effect_tab = {}
            local cur_season = UserDataManager:getCurSeason()
            local cur_season_day = UserDataManager:getCurSeasonDay()
            local cfg_season
            local cfg_season_day
            local hero_item
            for k, v in pairs(reward_data.item_effect) do
                hero_item = RewardUtil:getProcessRewardData(v)
                cfg_season = hero_item.item_cfg.season
                cfg_season_day = hero_item.item_cfg.season_day or 0
                if (cfg_season < cur_season) or (cfg_season == cur_season and ((cfg_season_day == 0) or (cfg_season_day ~= 0 and cfg_season_day <= cur_season_day))) then
                    table.insert(effect_tab, v)
                end
            end
            reward_data.item_effect = effect_tab
            reward_data.item_content_show = effect_tab
            ]]--
    end
end

function M:isSeasonPreviewOpen()
    local is_open = false
    local end_time = UserDataManager:getCurSeasonEndTime() + 1
    local occ_time = end_time - UserDataManager:getServerTime()
    local show_day = ConfigManager:getCommonValueById(575 , 7)
    if occ_time < show_day * 24 * 60 * 60 then
        is_open = true
    end
    return is_open
end

-- 打开ios好评价
--[[
string title, string secondTitle, string positiveButtonText,string negativeButtonText,Action<int> callBack
--]]
function M:openAppRating()
    -- ios 才有评价系统
    if SDKUtil.sdk_params.app == 2 and self:checkDayCanAppRating() then
        local title = Language:getTextByKey("tid#ShareLocalTitle")
        local secondTitle = Language:getTextByKey("tid#ShareLocalSecondTitle")
        local positiveButtonText = Language:getTextByKey("tid#ShareLocalPositiveButton")
        local negativeButtonText = Language:getTextByKey("tid#ShareLocalNegativeButton")
        local function callBack(state)
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("app_rating_tips"), delay_close = 2})
        end
        local haveFlag = xlua.import_type("AppRatingController")
        if haveFlag == true then
            CS.AppRatingController.OnShowDefaultBtnClick(title, secondTitle, positiveButtonText, negativeButtonText,callBack)
        end
    end
end

-- 检查day是否能弹评价
function M:checkDayCanAppRating()
    local flag = false
    local appRating_count = U3DUtil:PlayerPrefs_GetInt("appRating_count", 0) -- 弹出次数（每天至多弹一次所以也是弹出天数）
    local server_time = UserDataManager:getServerTime()
    local reg_ts = UserDataManager.reg_ts
    local day = math.floor((TimeUtil.getIntTimestamp(server_time) - TimeUtil.getIntTimestamp(reg_ts))/86400)+1
    local rating_list = {}
    if ConfigManager:getCfgByName("common")[587] then
        rating_list = ConfigManager:getCfgByName("common")[587].value
    end
    local popCount = 0 -- 建号天数至今可弹出评价次数
    for i = 1, #rating_list do
        if rating_list[i]<= day then
            popCount = popCount +1  -- 算出建号天数至今可弹出评价次数
        end
    end
    if appRating_count < popCount then
        U3DUtil:PlayerPrefs_SetInt("appRating_count", tonumber(popCount))
        flag = true
    end
    return flag
end

function M:getGiftStatusByOpenId(cur_open_id)
    local cur_open_id = cur_open_id
    local choice_gifts = UserDataManager.m_choice_gifts or {}
    local status = false
    for i, v in pairs(choice_gifts) do
        local cfg_id = tonumber(i)
        local gift_tab = ConfigManager:getCfgByName("limit_gift") or {}
        if gift_tab[cfg_id] then
            local limit_cfg = gift_tab[cfg_id] or {}
            if limit_cfg["open_id"] and limit_cfg["open_id"][1] then
                local open_id = limit_cfg["open_id"][1] or -1
                local vsn = limit_cfg["open_id"][2] or -1
                local show_type = limit_cfg["show_type"] or -1
                if open_id == cur_open_id and (show_type == 1 or show_type == 2) then
                   return true
                end
            end
        end
    end
    return false
end

-- 设置称号图片
function M:setTitleImage(title_id, titleObj)
    if title_id and title_id ~= 0 then
        titleObj:SetActive(true)
        local name_img = titleObj:GetComponent("Image")
        local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
        UIUtil.destroyAllChild(name_img.gameObject.transform)
        if cfg.title_effect and cfg.title_effect ~= "" then
            ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
            name_img.enabled = false
        else
            GameUtil:setTextureLoadTitleLanImgText(titleObj, cfg.icon) -- 设置称号图片
            name_img:SetNativeSize()
            name_img.enabled = true
        end
    else
        titleObj:SetActive(false)
    end
end

function M:getGuildHighWarTeamNums()
    local team_nums = ConfigManager:getCommonValueById(700 , 5)
    return team_nums
end

function M:getCompareSwordDefendTeams()
    local team_nums = 5
    return team_nums
end

function M:getCompareSwordDefendTeamsRedFlag()
    local flag = false
    local mult_main_teams = table.copy(UserDataManager.hero_data:getMultTeamByKey("full_service_promotion"))
    local nums = self:getCompareSwordDefendTeams()
    for idx = 1, nums do
        local one_team = mult_main_teams[idx] or {}
        for i = 1, 5 do
            local hero_oid = one_team[i] or ""
            if hero_oid == "" then
                flag = true
                return flag
            end
        end
    end
end

-- 创建宠物头像
function M:createPetElement(pet_oid, parent_node, isShowLevel, isShowGeneration , callback, scale, isShowEffect, isShowSkillFlag)
    scale = scale or 1
    local pet_obj = ResourceUtil:LoadUIGameObject("PetBreeding/pet_cell", Vector3.zero, nil)
    pet_obj.transform:SetParent(parent_node, false)
    UIUtil.setScale(pet_obj.transform, scale)
    local luaBehaviour = UIUtil.findLuaBehaviour(pet_obj)
    local pet_level_go = luaBehaviour:FindGameObject("pet_level_text_bg")
    local pet_generation_go = luaBehaviour:FindGameObject("pet_generation_img")
    local data, cfg = UserDataManager.pet_data:getPetDataById(pet_oid)
    if not data or not cfg then
        return
    end
    pet_level_go:SetActive(isShowLevel)
    pet_generation_go:SetActive(isShowGeneration)
    
    local level = 1
    local evo_text = Language:getTextByKey("upper_num_str_0001")
    local evo_bg = "a_ui_cwxzdi_ziseyuan"
    local icon_evo_bg = "a_ui_currency_dj_zi"
    if isShowLevel then
        local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
        if upgradeCfg[data.lv] then
            level = upgradeCfg[data.lv].display_level
        end
    end
    if isShowGeneration then
        local generation_data  = self:getPetInfoByData(data)
        evo_text = generation_data.evo_text
        evo_bg = generation_data.evo_bg
        icon_evo_bg = generation_data.icon_evo_bg
    end
    if isShowEffect then
        self:creatEffectForPet(pet_obj, data)
    end

    local skill_node = luaBehaviour:FindGameObject("skill_node")
    local team_go = luaBehaviour:FindGameObject("team_img")

    if skill_node and team_go then
        if isShowSkillFlag then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "killer_skill_text","pet_bag_text_0019")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "helper_skill_text","pet_bag_text_0020")
            
            local pet_skill_cfg = ConfigManager:getCfgByName("pet_skill_random")
            local isInTeam = self:checkPetInTeam(pet_oid)
            team_go:SetActive(isInTeam)
            skill_node:SetActive(not isInTeam)
            if not isInTeam then
                local killer_res = false
                local killer_icon_str = ""
                for _, v in ipairs(data.skills) do
                    if pet_skill_cfg[v].skill3 == 1 then
                        killer_res = true
                        killer_icon_str = self:getPetSkillBg(v)
                        break
                    end
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "killer_skill_img", killer_res)
                if killer_res then
                    LuaBehaviourUtil.setImg(luaBehaviour, "killer_skill_img", killer_icon_str, "main_ui2")
                end

                local helper_res = false
                local helper_icon_str = ""
                for _, v in ipairs(data.skills) do
                    if pet_skill_cfg[v].type == 2 then
                        helper_res = true
                        helper_icon_str = self:getPetSkillBg(v)
                        break
                    end
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "helper_skill_img", helper_res)
                if helper_res then
                    LuaBehaviourUtil.setImg(luaBehaviour, "helper_skill_img", helper_icon_str, "main_ui2")
                end
            end
        else
            skill_node:SetActive(false)
            team_go:SetActive(false)
        end
    end
    
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", level)
    LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",evo_text)
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", evo_bg, "main_ui2")
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", cfg.icon, "item_icon")
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_evo_bg", icon_evo_bg, "equip_icon")
    
    local function clickCallback()
        --if isShowDetail then
        --    static_rootControl:closeView("HeroInfo.EquipmentPop",nil, false)
        --    static_rootControl:openView("HeroInfo.EquipmentPop", {pet_id = pet_id})
        --   end
        if type(callback) == "function" then
            callback(pet_obj, pet_oid)
        end
    end
    UIUtil.setButtonClick(pet_obj, clickCallback)
    return pet_obj, luaBehaviour
end

-- 加载宠物头像
function M:loadPetElement(parent_node, scale)
    scale = scale or 1
    local pet_obj = ResourceUtil:LoadUIGameObject("PetBreeding/pet_cell", Vector3.zero, nil)
    pet_obj.transform:SetParent(parent_node, false)
    UIUtil.setScale(pet_obj.transform, scale)
    local luaBehaviour = UIUtil.findLuaBehaviour(pet_obj)
    return pet_obj, luaBehaviour
end

-- 更新宠物头像
function M:updatePetElementInfo(pet_oid, obj, isShowEffect, isShowSkillFlag)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data, cfg = UserDataManager.pet_data:getPetDataById(pet_oid)
    if not data or not cfg then
        return
    end

    local level = 1
    local evo_text = Language:getTextByKey("upper_num_str_0001")
    local evo_bg = "a_ui_cwxzdi_ziseyuan"
    local icon_evo_bg = "a_ui_currency_dj_zi"
    local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
    if upgradeCfg[data.lv] then
        level = upgradeCfg[data.lv].display_level
    end
    local generation_data  = self:getPetInfoByData(data)
    evo_text = generation_data.evo_text
    evo_bg = generation_data.evo_bg
    icon_evo_bg = generation_data.icon_evo_bg
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", level)
    LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",evo_text)
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", evo_bg, "main_ui2")
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", cfg.icon, "item_icon")
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_evo_bg", icon_evo_bg, "equip_icon")
    if isShowEffect then
        self:creatEffectForPet(obj, data)
    end
    local skill_node = luaBehaviour:FindGameObject("skill_node")
    local team_go = luaBehaviour:FindGameObject("team_img")

    if skill_node and team_go then
        if isShowSkillFlag then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "killer_skill_text","pet_bag_text_0019")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "helper_skill_text","pet_bag_text_0020")

            local pet_skill_cfg = ConfigManager:getCfgByName("pet_skill_random")
            local isInTeam = self:checkPetInTeam(pet_oid)
            team_go:SetActive(isInTeam)
            skill_node:SetActive(not isInTeam)
            if not isInTeam then
                local killer_res = false
                local killer_icon_str = ""
                for _, v in ipairs(data.skills) do
                    if pet_skill_cfg[v].skill3 == 1 then
                        killer_res = true
                        killer_icon_str = self:getPetSkillBg(v)
                        break
                    end
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "killer_skill_img", killer_res)
                if killer_res then
                    LuaBehaviourUtil.setImg(luaBehaviour, "killer_skill_img", killer_icon_str, "main_ui2")
                end

                local helper_res = false
                local helper_icon_str = ""
                for _, v in ipairs(data.skills) do
                    if pet_skill_cfg[v].type == 2 then
                        helper_res = true
                        helper_icon_str = self:getPetSkillBg(v)
                        break
                    end
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "helper_skill_img", helper_res)
                if helper_res then
                    LuaBehaviourUtil.setImg(luaBehaviour, "helper_skill_img", helper_icon_str, "main_ui2")
                end
            end
        else
            skill_node:SetActive(false)
            team_go:SetActive(false)
        end
    end
    
    return luaBehaviour
end

-- 更新宠物头像
function M:updatePetElement(obj, data, isShowLevel, isShowGeneration, isShowSkillFlag, callback, scale)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local pet_level_go = luaBehaviour:FindGameObject("pet_level_text_bg")
    local pet_generation_go = luaBehaviour:FindGameObject("pet_generation_img")
    local pet_data = nil
    local pet_cfg = nil
    if data.oid then
        pet_data, pet_cfg = UserDataManager.pet_data:getPetDataById(data.oid)
    else
        pet_cfg = UserDataManager.pet_data:getPetConfigByCid(data.data_id)
    end
    local level = 1
    pet_level_go:SetActive(isShowLevel)
    pet_generation_go:SetActive(isShowGeneration)
    if pet_data then
        if isShowLevel then
            local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
            if upgradeCfg[pet_data.lv] then
                level = upgradeCfg[pet_data.lv].display_level
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", level)
        end
        if isShowGeneration then
            local generation_data  = self:getPetInfoByData(pet_data)
            LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",generation_data.evo_text)
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_evo_bg", generation_data.icon_evo_bg, "equip_icon")
        end
        
        local skill_node = luaBehaviour:FindGameObject("skill_node")
        local team_go = luaBehaviour:FindGameObject("team_img")

        if skill_node and team_go then
            if isShowSkillFlag then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "killer_skill_text","pet_bag_text_0019")
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "helper_skill_text","pet_bag_text_0020")
                
                local pet_skill_cfg = ConfigManager:getCfgByName("pet_skill_random")
                local isInTeam = self:checkPetInTeam(data.oid)
                team_go:SetActive(isInTeam)
                skill_node:SetActive(not isInTeam)
                if not isInTeam then
                    local killer_res = false
                    local killer_icon_str = ""
                    for _, v in ipairs(pet_data.skills) do
                        if pet_skill_cfg[v].skill3 == 1 then
                            killer_res = true
                            killer_icon_str = self:getPetSkillBg(v)
                        end
                    end
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "killer_skill_img", killer_res)
                    if killer_res then
                        LuaBehaviourUtil.setImg(luaBehaviour, "killer_skill_img", killer_icon_str, "main_ui2")
                    end

                    local helper_res = false
                    local helper_icon_str = ""
                    for _, v in ipairs(pet_data.skills) do
                        if pet_skill_cfg[v].type == 2 then
                            helper_res = true
                            helper_icon_str = self:getPetSkillBg(v)
                        end
                    end
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "helper_skill_img", helper_res)
                    if helper_res then
                        LuaBehaviourUtil.setImg(luaBehaviour, "helper_skill_img", helper_icon_str, "main_ui2")
                    end
                end
            else
                skill_node:SetActive(false)
                team_go:SetActive(false)
            end
        end
    else
        if isShowLevel then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pet_level_text","new_str_0075", level)
        end

        if isShowGeneration then
            local generation_data  = self:getPetInfoByData(pet_data)
            LuaBehaviourUtil.setText(luaBehaviour, "pet_generation_text",generation_data.evo_text)
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_generation_img", generation_data.evo_bg, "main_ui2")
            LuaBehaviourUtil.setImg(luaBehaviour, "pet_evo_bg", generation_data.icon_evo_bg, "equip_icon")
        end
    end
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_icon", pet_cfg.icon, "item_icon")
end

function M:checkPetInTeam(oid)
    local team_ids = UserDataManager.hero_data:getTeamByKey("pet_pvp")
    for i = 1, 3 do
        if team_ids[i] ~= "" and team_ids[i] == oid then
            return true
        end
    end
    return false
end

--创建宠物代数
function M:createPetGeneration(pet_oid, parent_node, scale)
    local data, cfg = UserDataManager.pet_data:getPetDataById(pet_oid)
    if not data or not cfg then
        return
    end
    scale = scale or 1
    UIUtil.destroyAllChild(parent_node)
    local item = ResourceUtil:LoadUIGameObject("PetBreeding/PetInfo", Vector3.zero, nil)
    item.transform:SetParent(parent_node, false)
    UIUtil.setScale(item.transform, scale)
    local luaBehaviour = UIUtil.findLuaBehaviour(item)
    local generation_data = self:getPetInfoByData(data)
    local pet_variation_img = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "pet_variation_img", #data.variation > 0)
    LuaBehaviourUtil.setText(luaBehaviour, "generation_text", generation_data.evo_text)
    LuaBehaviourUtil.setImg(luaBehaviour, "generation_bg", generation_data.evo_bg, "main_ui2")
    LuaBehaviourUtil.setImg(luaBehaviour, "pet_info_img", generation_data.evo_bar_bg, "main_ui2")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",cfg.name)

    UIUtil.setButtonClick(pet_variation_img.transform, function()
        static_rootControl:openView("PetBreeding.PetVariationPop", { pet_oid = pet_oid })
    end)
    return item, luaBehaviour
end

function M:getPetQualityByData(data)
    local quality = 1
    if data and data.quality then
        local quality_cfg = ConfigManager:getCommonValueById(749, {})
        local hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
        local total_quality = 0
        local attr_id
        local num
        local cnt = 0
        for k, v in pairs(data.quality) do
            attr_id = v.base[1]
            num = v.param[2]
            if hero_enumeration_cfg[attr_id] then
                total_quality = total_quality + num
                cnt  = cnt + 1
            end
        end
        if cnt > 0 then
            local average_quality = math.ceil(total_quality / cnt)
            for k ,v in ipairs(quality_cfg) do
                if average_quality > v then
                    quality = quality + 1
                else
                    break
                end
            end
        end
        if quality > 5 then
            quality = 5
        end
    end
    return quality
end

--获得宠物代数背景信息
function M:getPetInfoByData(data, cfg)
    local text_key = "upper_num_str_0001"
    local evo_bg = "a_ui_cwxzdi_ziseyuan"
    local evo_bar_bg = "a_ui_cwxzdi_zi"
    local icon_evo_bg = "a_ui_currency_dj_zi"
    local big_bg = "a_ui_currency_ws_zi_big"
    local zd_bg = "a_zd_kapai_lan"
    local quality = 1
    local evo = 1
    if data then
        quality = self:getPetQualityByData(data)
        evo = data.evo
    elseif cfg then
        quality = cfg.show_quality or 1
        evo = 1
    end
    text_key = "upper_num_str_000" .. evo
    
    if quality == 1 then
        evo_bg = "a_ui_cwxzdi_ziseyuan"
        evo_bar_bg = "a_ui_cwxzdi_zi"
        icon_evo_bg = "a_ui_currency_dj_zi"
        big_bg = "a_ui_currency_ws_zi_big"
        zd_bg = "a_zd_kapai_zi"
    elseif quality == 2 then
        evo_bg = "a_ui_cwxzdi_chengseyuan"
        evo_bar_bg = "a_ui_cwxzdi_cheng"
        icon_evo_bg = "a_ui_currency_dj_jin"
        big_bg = "a_ui_currency_ws_jin_big"
        zd_bg = "a_zd_kapai_cheng"
    elseif quality == 3 then
        evo_bg = "a_ui_cwxzdi_hongseyuan"
        evo_bar_bg = "a_ui_cwxzdi_hong"
        icon_evo_bg = "a_ui_currency_dj_hong"
        big_bg = "a_ui_currency_ws_hong_big"
        zd_bg = "a_zd_kapai_hong"
    elseif quality == 4 then
        evo_bg = "a_ui_cwxzdi_baiseyuan"
        evo_bar_bg = "a_ui_cwxzdi_bai"
        icon_evo_bg = "a_ui_currency_dj_bojin"
        big_bg = "a_ui_currency_ws_bojin_big"
        zd_bg = "a_zd_kapai_bojin"
    elseif quality == 5 then
        evo_bg = "a_ui_cwxzdi_caiseyuan"
        evo_bar_bg = "a_ui_cwxzdi_cai"
        icon_evo_bg = "a_ui_currency_dj_cai"
        big_bg = "a_ui_currency_ws_cai_big"
        zd_bg = "a_zd_kapai_cai"
    end
    return {evo_text = Language:getTextByKey(text_key),evo_bg = evo_bg, evo_bar_bg = evo_bar_bg, icon_evo_bg = icon_evo_bg ,big_bg=big_bg, zd_bg = zd_bg}
end

-- 获取宠物战斗中evo icon
function M:getPetEvoIconByEvo( evo )
    if evo == nil then return "" end
    local iconName = "a_bh_bz_yidui"
    local pet_evolution_cfg = ConfigManager:getCfgByName("pet_evolution")
    if pet_evolution_cfg[evo] then
        iconName = pet_evolution_cfg[evo].icon
    end
    return iconName
end
-- 获取宠物配置等级
function M:getPetRealLevelByLv(lv)
    local level = 0
    local upgradeCfg = ConfigManager:getCfgByName("pet_upgrade")
    if upgradeCfg[lv] then
        level = upgradeCfg[lv].display_level
    end
    return level
end

--获取宠物技能等级底板
function M:getPetSkillBg(skillId)
    local skillCfg = ConfigManager:getCfgByName("pet_skill_random")
    local skill_bg = ""
    if skillCfg[skillId] then
        local skill_quality = skillCfg[skillId].quality
        if skill_quality == 1 then
            skill_bg = "a_cwyc_qsjn_jb06"
        elseif skill_quality == 2 then
            skill_bg = "a_cwyc_qsjn_jb05"
        elseif skill_quality == 3 then
            skill_bg = "a_cwyc_qsjn_jb"
        end
    end
    return skill_bg
end

--获取宠物资质
function M:getPetQualityByData(data)
    local common_cfg = ConfigManager:getCfgByName("common")
    if not common_cfg[749] then
        Logger.LogError("There is no 747 in common config")
        return
    end
    local quality_cfg = common_cfg[749].value
    local total_quality = 0
    local hero_enumeration_cfg = ConfigManager:getCfgByName("hero_enumeration")
    local attr_id
    local num = 0
    local quality = 1
    local cnt = 0
    for k, v in pairs(data.quality) do
        attr_id = v.base[1]
        num = v.param[2]
        if hero_enumeration_cfg[attr_id] then
            total_quality = total_quality + num
            cnt  = cnt + 1
        end
    end
    if cnt > 0 then
        local average_quality = math.ceil(total_quality / cnt)
        for k ,v in ipairs(quality_cfg) do
            if average_quality > v then
                quality = quality + 1
            else
                break
            end
        end
    end
    if quality > 5 then
        quality = 5
    end
    return quality
end

--创建宠物特效
function M:creatEffectForPet(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local quality = self:getPetQualityByData(data)
    if LODUtil:isShowUiFx() and luaBehaviour then
        local effect_node = luaBehaviour:FindGameObject("effect_node")
        if effect_node then
            UIUtil.destroyAllChild(effect_node.transform)
            if quality == 3 then
                -- 红色
                local effect = ResourceUtil:GetUIEffectItem("Common/UI_Common_Red_front", obj)
                effect.transform:SetParent(effect_node.transform, false)
                effect.transform.localPosition = Vector3(0,0,0)
                return
            elseif quality == 4 then
                -- 白色
                local effect = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_002", obj)
                effect.transform:SetParent(effect_node.transform, false)
                effect.transform.localPosition = Vector3(0, 0, 0)
                return
            elseif quality == 5 then
                -- 彩色
                local effect = ResourceUtil:GetUIEffectItem("Common/UI_Common_Cai_004", obj)
                effect.transform:SetParent(effect_node.transform, false)
                effect.transform.localPosition = Vector3(0, 0, 0)
                return
            end
        end
    end
end

--计算伤害加深类型属性
function M:countAttr(attr)
    local enumerationXlsxData = ConfigManager:getCfgByName("hero_enumeration")
    local curAttrId = attr[1]
    local curAttrXlsx = enumerationXlsxData[curAttrId] or {}
    local base_id = curAttrXlsx.base_on_id
    if base_id ~= 0 then
        local prestige_fetter_attr = {}
        prestige_fetter_attr[1] = base_id
        if curAttrXlsx.is_percent == 1 then
            prestige_fetter_attr[2] = math.floor(attr[2] * 1000 + 0.5) / 10
        else
            prestige_fetter_attr[2] = math.floor(attr[2] + 0.5)
        end
        return prestige_fetter_attr
    else
        return attr
    end
end

--判断根据id，判断属性是值加成还是百分比加成
function M:countAttrType(id)
    local enumerationXlsxData = ConfigManager:getCfgByName("hero_enumeration")
    local curAttrXlsx = enumerationXlsxData[id] or {}
    local base_id = curAttrXlsx.base_on_id
    return base_id ~= 0
end

--获取配置中add_type = 1
function M:countCombatRepressGrade(oid,hero_data)
    local nums = 0
    local locate_value_table = {}
    local combat_repress_cfg = ConfigManager:getCfgByName("combat_repress")
    for k,v in pairs(combat_repress_cfg)do
        if v.add_type == 1 then
            locate_value_table[v.locate_type] = 0
        end
    end
    if hero_data == nil then
        hero_data,_ = UserDataManager.hero_data:getHeroDataById(oid)    
    end
    if hero_data == nil then
        return locate_value_table,nums
    end
    local hero_combat_repress_data = hero_data.combat_repress or {}
    for k,v in pairs(hero_combat_repress_data)do
        local cfg = combat_repress_cfg[k]
        if cfg and next(cfg) then
            locate_value_table[cfg.locate_type] = locate_value_table[cfg.locate_type] + v 
        else
            Logger.log("战力压制后端字段和策划配置不匹配")
        end
    end
    
    for k,v in pairs(locate_value_table) do
        nums = nums + v
    end
    return locate_value_table,nums
end

--获取配置中add_type = 2
function M:countGlobalCombatRepressGrade(global_data)
    local locate_value_table = {}
    local combat_repress_cfg = ConfigManager:getCfgByName("combat_repress")
    local nums = 0
    for k,v in pairs(combat_repress_cfg)do
        if v.add_type == 2 then
            locate_value_table[v.locate_type] = 0
        end
    end
    
    if global_data == nil then
        global_data = UserDataManager:getGlobalCombatRepressData()    
    end
    if global_data == nil then
        return locate_value_table,nums
    end
    for k,v in pairs(global_data) do
        local cfg = combat_repress_cfg[k]
        if cfg and next(cfg) then
            locate_value_table[cfg.locate_type] = locate_value_table[cfg.locate_type] + v
        else
            Logger.log("战力压制后端字段和策划配置不匹配")
        end
    end
    for k,v in pairs(locate_value_table) do
        nums = nums + v
    end
    return locate_value_table,nums
end

--根据分数来获得等级
function M:getCombatSupressLevel(score,newLevel)
    local my_level = 0
    newLevel = newLevel or 0
    local cfg_combat_repress = ConfigManager:getCfgByName("combat_repress_level")
    for level,value in ipairs(cfg_combat_repress) do
        if score > value.min_level then
            my_level = level
        end
    end
    my_level= my_level + newLevel
    my_level = 10 > my_level and my_level or 10
    return my_level
end

--获取配置中各类型的最大值
function M:countMaxCfg()
    local combat_repress_cfg = ConfigManager:getCfgByName("combat_repress")
    local locate_value_table = {}
    for k,v in pairs(combat_repress_cfg)do
        locate_value_table[v.locate_type] = 0
    end
    for k,v in pairs(combat_repress_cfg) do
        locate_value_table[v.locate_type] = locate_value_table[v.locate_type] + v.max_combat_num
    end
    return locate_value_table
end

function M:insertMysticesDataandOid(show_data)
    local mystics_data = {}
    local mystic_ids = UserDataManager.mystic_data:getMysticesId()
    for i,v in ipairs(mystic_ids) do
        local mystic_data = UserDataManager.mystic_data:getMysticDataById(v)
        local wear = mystic_data.wear or ""
        if #wear == 0 then --不被其他人装备的
            local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, mystic_data.id, mystic_data.star or 1})
            data.user_num = 1
            data.oid = v
            table.insert(mystics_data ,data)
        end
    end
    table.insertto(show_data, mystics_data)
end

function M:getTimeStrByActivves(v)
    local time_str = ""
    if v and next(v) then
        local start_srt = string.sub(v.start_time,1,10)
        local end_srt = string.sub(v.end_time,1,10)
        start_srt = string.gsub(start_srt,"-","/")
        end_srt = string.gsub(end_srt,"-","/")
        time_str = start_srt .. "-" .. end_srt 
    end

    return time_str
end

--获取活动信息
function M:getActiveData(open_id)
    --local active_data = UserDataManager:getActivesDataByOpenId(open_id)
    --local active_recharge_data = UserDataManager:getActivesRechargeDataByOpenId(open_id)
    --local data_table = active_data or active_recharge_data
    --if data_table then
    --    return data_table
    --end

    local active = ConfigManager:getCfgByName("active")
    for i,v in pairs(active) do
        if v.open_id == open_id then
            local cur_tim =  UserDataManager:getServerTime()
            local start_ts = GameUtil:stringToTimesTamp(v.start_time)
            local end_ts = GameUtil:stringToTimesTamp(v.end_time)
            local show_ts = 0
            if v.show_time ~= "" then
                show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
            end
            local is_end = cur_tim < end_ts or show_ts == 1
            if cur_tim > start_ts and is_end then
                return v
            end
        end
    end

    local active_recharge_tab = ConfigManager:getCfgByName("active_recharge")
    for i,v in pairs(active_recharge_tab) do
        if v.open_id == open_id then
            local cur_tim =  UserDataManager:getServerTime()
            local start_ts = GameUtil:stringToTimesTamp(v.start_time)
            local end_ts = GameUtil:stringToTimesTamp(v.end_time)
            local show_ts = 0
            if v.show_time ~= "" then
                show_ts = cur_tim < GameUtil:stringToTimesTamp(v.show_time) and 1 or 0
            end
            local is_end = cur_tim < end_ts or show_ts == 1
            if cur_tim > start_ts and is_end then
                return v
            end
        end
    end
end

function M:getRedPacketCfg(id)
    local itemcfg = {}
    local cfg = ConfigManager:getCfgByName("red_envelope")
    if cfg then
        itemcfg = cfg[tonumber(id)]
    end
    return itemcfg
end

function M:get_lineframename(ex_hero,evo)
    if ex_hero==0 or ex_hero==nil  then
        return "a_ui_currency_pinzhidi_zi"
    elseif ex_hero==1 then
        return "a_ui_currency_pinzhidi_cheng"
    end
end


return M
