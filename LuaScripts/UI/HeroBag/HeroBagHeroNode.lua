---@class HeroBagHeroNode:OOUIbase
---@field m_model HeroBagModel
local M = class("HeroBagHeroNode", LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroBagHeroNode"

M.QiHai = "UI_HeroInfo_QiHai_001" --气海 （可激活经脉的特效）
M.JuQi = "UI_HeroInfo_JuQi_001" --聚气 --（激活经脉的特效）

function M:onEnter()
    self.m_hero_spine = nil
    self.m_old_fetter_point = 0
    self.huaban_tab = {}
    self.hongxin_tab = {}
    self.m_gray_img = self:findImage("gray_img")

    self:setTextByLanKey("pinglun_text", "pinglun_tex")
    self:setTextByLanKey("legend_text", "legend_tex")
    
    self:setTextByLanKey("activate_text", "anecdote_select")
    self:setTextByLanKey("activate_one_text", "anecdote_003")
    self:setTextByLanKey("intensify_text", "anecdote_001")
    self.activate_one_btn = self:findButton("activate_one_btn")
    self.intensify_btn = self:findButton("intensify_btn")
    local com_parent = self:findGameObject("hero_effect_parent")
    self.lv_lizi = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_ShengJi_002", com_parent)
    self:setParticleRenderOrder(self.lv_lizi)
    self.lv_lizi:SetActive(false)
    self.cacheSpineName = ""
    self.m_meridian_obj = self:findGameObject("meridian_obj")
    self.heronode_animator = self:findGameObject("hero_node"):GetComponent("Animator")
    self.m_eqps = {}
    self.m_talins = {}
    self:setTextByLanKey("art_text", "art_str_002")
    for i = 1, 5 do
        local name = "eq" .. i .. "_btn"
        local icon_node = self:findGameObject(name)
        self.m_eqps[i] = icon_node
    end
    for i = 1, 4 do
        local name = "fuzhuan_eq" .. i .. "_btn"
        local icon_node = self:findGameObject(name)
        self.m_talins[i] = icon_node
    end
    self:setParticleRenderOrder(self.content_node)
    self:setObjectVisible("evaluate_btn", false)
    --self:setObjectVisible("evaluate_btn", self.m_model.m_type == 1)
    self.isOnce = true
    self.openL1 = false
    self.openR1 = false

    self.add_combat = nil --战力改变飞入预制
    local old_combat_text = self:findGameObject("old_combat_text")
    self.m_combat_change_bg_img = self:findGameObject("combat_change_bg_img")
    self.m_combat_up_effect = ResourceUtil:GetUIEffectItem("HeroBag/UI_HeroBag_ZhanLi_003", self.m_combat_change_bg_img)
    self:setParticleRenderOrder(self.m_combat_up_effect)
    self.m_combat_up_effect:SetActive(false)
    self.add_combat = self:creatEffect("add_combat", old_combat_text)
    self.add_combat:SetActive(false)
    self.m_show_combat_anim = false
    self:setObjectVisible("zhuangbei_view",true)
    self:setObjectVisible("fuzhuan_view",false)
end

function M:NumberChange(num1, num2)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self:setText("old_combat_text", GameUtil:formatValueToString(temp))
    end, num1, num2, 0.5))
    sequence:AppendInterval(0.2)
    sequence:OnComplete(function ()
        self.m_combat_up_effect:SetActive(false)
        self:setObjectVisible("combat_change_bg_img", false)
    end)
    return sequence
end

function M:AddCombatNumber(num1, num2)
    if IsNull(self.add_combat) then
        return
    end
    if self.add_combat_sequence then
        self.add_combat_sequence:Kill()
        self.add_combat_sequence = nil
    end

    if self.combat_time then
        self.m_control:removeTimer(self.combat_time)
        self.combat_time = nil
    end
    
    local show_text = self:setText("old_combat_text", GameUtil:formatValueToString(num1))
    local text_rt = show_text.gameObject:GetComponent("RectTransform")
    local rect = text_rt.rect
    local num = rect.width
    local combat_text = UIUtil.findText(self.add_combat.transform)
    local text_color = num2 - num1 > 0 and Color(74/255,237/255,109/255,1) or Color(255/255,23/255,5/255,1)
    local text_flag = num2 - num1 > 0 and "+" or ""
    combat_text.text = text_flag ..(num2 - num1)
    self.add_combat.transform.localPosition = Vector3.New((num - 55), 0, 0)
    UIUtil.setTextColor(self.add_combat.transform, text_color)
    self.add_combat:SetActive(true)
    local function awaitPlay()
        if not IsNull(self.add_combat) then
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(self.add_combat.transform:DOLocalMoveX(0, 0.5))
            sequence:Insert(0, DOTweenModuleUI.DOFade(combat_text, 0, 0.5))
            sequence:OnComplete(function ()
                if not IsNull(self.add_combat) then
                    self.m_sequence = self:NumberChange(num1, num2)
                    --self:setText("old_combat_text", GameUtil:formatValueToString(num2))
                    self.add_combat:SetActive(false)
                    --self:setObjectVisible("combat_change_bg_img", false)
                end
                audio:SendEvtUI("Play_UI_Power_Increase")
            end
            )
            sequence:SetAutoKill(false)
            self.add_combat_sequence = sequence
        end
        if self.combat_time then
            self.m_control:removeTimer(self.combat_time)
            self.combat_time = nil
        end
    end
    self.combat_time = self.m_control:setTimer(0.5, awaitPlay)
end

function M:InitType(c_type, first)
    if c_type == 1 then
        local move_x = self.m_model:getCurMoveX(266.25, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end
    elseif c_type == 2 then
        local move_x = self.m_model:getCurMoveX(-236, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end
    else
        local move_x = self.m_model:getCurMoveX(266.25, self.m_control.m_view.m_view_width)
        if first == false then
            GameUtil:dotweenMoveX(self.m_rt.gameObject, move_x)
        else
            self.m_rt.localPosition = Vector3.New(move_x, 0, 0)
        end
    end
    self:setObjectVisible("next_btn", c_type ~= 1 and self.m_model.m_sel_tab_index == 1)
    self:setObjectVisible("last_btn", c_type ~= 1 and self.m_model.m_sel_tab_index == 1)
    self:refreshUI(nil,first)
    --self:setObjectVisible("zhuangbei_view",true)
    --self:setObjectVisible("fuzhuan_view",false)
    --self:updateCurrentView(self.m_model.is_open_type)
end

function M:fingerSliding(locat)
    if locat then
        self:updateMsg("Sliding_right")
    else
        self:updateMsg("Sliding_left")
    end
end

function M:switchTabNode(index)
    self:setObjectVisible("info_obj", index == 1 or index == 5 or index == 6)
    self:setObjectVisible("friendRelationNode", index == 4 )
    self:setObjectVisible("meridian_obj", index == 2)
    self:switchMeridianByIndex(self.m_model.m_select_meridian_index)
    local play_img = self:findGameObject("hero_spine")
    local icon = self.m_model:getHeroBigAnim()
    if index == 2 then
        if self.m_hero_spine == nil then
            self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. icon, "pose", 0, false)
        end
    
        local sp_hero = self.m_hero_spine.gameObject:GetComponent("SkeletonGraphic")
        if sp_hero then
            sp_hero.color = Color(0, 0, 0)
        end
    else
        if self.m_hero_spine == nil then
            self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. icon, "pose", 0, false)
        end
        local sp_hero = self.m_hero_spine.gameObject:GetComponent("SkeletonGraphic")
        if sp_hero then
            sp_hero.color = Color(1, 1, 1)
        end
    end
    self:setObjectVisible("hero_spine", true)
    self:updateCombatAnimPos(index)
    if self.m_model:getHeroStarBtnShow() then
        self:setFatesInfo(index)
    end
end

function M:updateCombatAnimPos(index)
    if index == 1 or index == 5 or index == 6 then
        self.m_combat_change_bg_img.transform.localPosition = Vector3.New(-142.4, -156.4, 0)
    else
        self.m_combat_change_bg_img.transform.localPosition = Vector3.New(212 , -174, 0)
    end
end

function M:refreshUI(data,first)
    self:setObjectVisible("tianming_xia_img", false)
    --self:setObjectVisible("UI_Destiny_005", false) --天命特效(废弃)
    self:setObjectVisible("tianming_img_tips_text2", false)
    if self.m_model.isNil == true then
        self:setObjectVisible("onekey_equip_red_point_img", false)
        self:setObjectVisible("hero_spine", false)
        self:setObjectVisible("hero_name_con", false)
        self:setObjectVisible("class_bg", false)
        self:setObjectVisible("cultivate_btn", false)
        self:setObjectVisible("xia_img", false)
        self:setObjectVisible("main_stars", false)
        self:updateEquipInfo()
        return    
    end
    self:setObjectVisible("onekey_equip_red_point_img", true)
    self:setObjectVisible("hero_spine", true)
    self:setObjectVisible("hero_name_con", true)
    self:setObjectVisible("class_bg", true)
    self:setObjectVisible("cultivate_btn", true)
    if first == true then
        self:setObjectVisible("eqp_list", false)
        self:setObjectVisible("hero_node", false)
        self.m_control:setOnceTimer(0.5, function ()
            self:setObjectVisible("eqp_list", self.m_model.m_hero_list_type == 1) 
            self:setObjectVisible("hero_node", true)
            self:setSpine(data)
            self:updateEquipInfo()
            self:updateEquipBtn()
        end)
    else
        self:setSpine(data)
        self:updateEquipInfo()   
        self:setObjectVisible("eqp_list", self.m_model.m_hero_list_type == 1) 
    end
    self:updateArtifact()
    self:updateInfo()
    self:updateProType()
    self:updateLock()
    self:checkCombatChange()
    self:setObjectVisible("get_out_btn", self.m_model.m_hero_list_type == 1)
    self:setObjectVisible("put_on_btn", self.m_model.m_hero_list_type == 1)
    self:setObjectVisible("cultivate_btn", self.m_model.m_hero_list_type == 1 and self.m_model.m_type == 1)
    self:setObjectVisible("details_btn", self.m_model.m_hero_list_type == 2 and self.m_model.m_type == 1)
    self:setObjectVisible("UI_HeroBag_ZhiYin_001", false)
    if self.m_model.m_hero_list_type == 1 and self.m_model.m_type == 1 then
        local oid = self.m_model.m_selected_id
        local team = UserDataManager.hero_data:getTeamByKey("stage")
        local is_inteam = table.keyof(team, oid)
        if is_inteam then
            if self.m_model:checkMaxLv() == false then
                local can_lv_up = self.m_model:checkCanLevelUp()
            end
        end
    end
    if self.m_model.m_hero_list_type == 2 or self.m_model.m_type == 3 then
        self:setObjectVisible("lock_img", false)
    end
    self:setObjectVisible("lock_img", false)
    if self.m_model.m_sel_tab_index == 2 then
        self:switchMeridianByIndex(self.m_model.m_select_meridian_index)
    end
    if self.m_model.m_mode == 3 then
        self:setObjectVisible("put_on_btn", false)
        self:setObjectVisible("get_out_btn", false)
    end
    self:setObjectVisible("get_reward_btn", self.m_model:checkRedPoint() == true)
    local hero_cfg = self.m_model:getCurHeroCfg()
    if hero_cfg.evo == 3 then
        self:setObjectVisible("xia_img", false)
        self:setObjectVisible("tianming_img_tips_text1", false)
        self:setObjectVisible("tianming_img_tips_text2", false)
    else
        if hero_cfg.Ex_hero == 1 then
            self:setObjectVisible("UI_HeroBag_DX_01", false)
            self:setObjectVisible("UI_HeroBag_DX_T0_01", true)
        else
            self:setObjectVisible("UI_HeroBag_DX_01", true)
            self:setObjectVisible("UI_HeroBag_DX_T0_01", false)
        end
        self:setObjectVisible("xia_img", true)
        self:setObjectVisible("ordinary_des_img1", true)
        self:setObjectVisible("ordinary_des_img2", true)
        self:setObjectVisible("tianming_img_tips_text1", false)
        self:setObjectVisible("tianming_img_tips_text2", false)
    end
    if self.m_model.m_mode == 3 then
        self:setObjectVisible("next_btn", self.m_model.other_team == true)
        self:setObjectVisible("last_btn", self.m_model.other_team == true)
    end
    self:refreshFriendInfo()
    self:refreshHeroRoleInfo()
    --刷新按钮点击状态
    self.activate_one_btn.interactable = true
    self.intensify_btn.interactable = true
    --天命化星
    if self.m_model:getHeroStarBtnShow() then
        self:setFatesInfo(self.m_model.m_sel_tab_index)
    end
    self:updateEquipBtn()--刷新按钮状态
end

--[[
    @desc: 英雄动画
]]
function M:setSpine(data)
    if self.m_model:getPoetry() then
        local poet = self.m_model:getPoetry()
        self:setText("poet_text", poet[1])
        self:setText("poet_text2", poet[2])
    end
    local icon = self.m_model:getHeroBigAnim()
    if data == nil and self.isOnce == false and self.cacheSpineName == icon then
        return
    end
    self.cacheSpineName = icon
    local pos_x = 0
    local pos_y = 0
    local play_img = self:findGameObject("hero_spine")
    local spine_pos, spine_scale = self.m_model:getSpinePos()
    local pos = play_img.transform.localPosition
    pos.x = spine_pos[1] or 0
    pos.y = spine_pos[2] or 0
    play_img.transform.localPosition = pos
    play_img.transform.localScale = Vector3(spine_scale, spine_scale, 1)
    local animationName = nil
    local setSpine = false
    local node = self:findGameObject("hero_node")

    if self.isOnce then
        self.isOnce = false
        self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
    else
        local canvasGroup = node.transform:GetComponent("CanvasGroup")
        canvasGroup.alpha = 0
        if data ~= nil and data.dir ~= nil then
            if data.dir == 1 and self.openL1 == false then --左
                self.heronode_animator:CrossFade("Hero_L2", 0) --当前左滑走
                animationName = "Hero_L2"
            elseif data.dir == 2 and self.openR1 == false then --右
                self.heronode_animator:CrossFade("Hero_R2", 0) --当前右滑走
                animationName = "Hero_R2"
            elseif data.dir == 0 then
                self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
            end
        end
    end
    local function endAnim(msg)
        if msg == "heroL2_end" then
            self.openL1 = true
            self.heronode_animator:CrossFade("Hero_L1", 0.3) --当前左滑进
        elseif msg == "heroR2_end" then
            self.openR1 = true
            self.heronode_animator:CrossFade("Hero_R1", 0.3) --当前右滑进
        elseif msg == "heroL1_end" then
            self.openL1 = false
        elseif msg == "heroR1_end" then
            self.openR1 = false
        end
    end
    local ndoe_luabehaviour = node:GetComponent("LuaBehaviour")
    if ndoe_luabehaviour then
        ndoe_luabehaviour:RunAnim(animationName, endAnim)
    end
    self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
end


--英雄类型
function M:updateProType()
	local temp_cfg = self.m_model:getCurHeroCfg()
	if temp_cfg then
		local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
		self:setImg(type_data.pro_icon, "hero_ui", "hero_type_img")
	end
end

function M:playCombatChangeAnim(last_combat, cur_combat)
    if self.m_combat_change_bg_img then
        self:setObjectVisible("combat_change_bg_img", true)
        self.m_combat_up_effect:SetActive(last_combat < cur_combat)
        self:AddCombatNumber(last_combat, cur_combat)
        --self:setText("old_combat_text", tostring(last_combat))
    end
end

function M:checkCombatChange()
    if self.m_model.m_sel_tab_index == 1 or self.m_model.m_sel_tab_index == 2 or self.m_model.m_sel_tab_index == 5 then
        local last_combat = self.m_model.last_combat
        local cur_combat = self.m_model:getHero_Combat()
        if last_combat ~= cur_combat then
            self:playCombatChangeAnim(last_combat, cur_combat)
        end
    end
end

--更新装备信息
function M:updateEquipInfo()
    self:refreshRedPoint()
    --self:checkCombatChange()
    local eqp_data = self.m_model:getHeroEquList()
    self.m_model.m_equip_num = 0
    for k = 1, 5 do
        local data = eqp_data[tostring(k)]
        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[k])
        if luaBehaviour then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", false)
            LuaBehaviourUtil.setImg(luaBehaviour, "bg", "a_ui_currency_dj_kong", "equip_icon")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", true)
            --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "eqp_zz", true)
            if data then
                self.m_model.m_equip_num = self.m_model.m_equip_num + 1
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "eqp_zz", false)
                local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race, data.oid})
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroInfo_ZhuangBei_001", self.m_model:getRace() == data.race)
                GameUtil:creatEffectForEquip(self.m_eqps[k],itemData)
                local eqpDatra = GlobalConfig.QUALITY_COMMON_SETTING[itemData.quality]
                if eqpDatra then
                    LuaBehaviourUtil.setImg(luaBehaviour, "bg", eqpDatra.frame_name, "equip_icon")
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", false)
                if eqpDatra.t_corner_mark and eqpDatra.t_corner_mark > 0 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equip_t_corner_mark", false)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equip_t_corner_mark", false)
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
                LuaBehaviourUtil.setImg(luaBehaviour, "equ_img", itemData.icon_name, itemData.atlas_name)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", true)
                for i = 1, 5 do
                    local star = luaBehaviour:FindGameObject("inten_lv" .. i)
                    if itemData.quality >= 12 then
                        UIUtil.setImg(star.transform, "a_ui_currency_ws_xingji", "equip_icon")
                    else
                        UIUtil.setImg(star.transform, "a_ui_currency_dj_xinji", "equip_icon")
                    end
                    if star then
                        star:SetActive(i <= data.lv)
                    end
                end
                -- 字段拼接 zbjb_0+装备类型+_0+装备种族属性
                local race = data.race
                if race == 0 then
                    race = 0
                end
                local equ_lv = GameUtil:getEquipLevel(itemData.quality)
                local eqp_jb_str = "zbjb_0"..race.."_0"..equ_lv
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", true)
                if race == 0 and itemData.quality <= 8 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
                end
                -- if itemData.quality >= 12 then
                --     LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
                -- end
                LuaBehaviourUtil.setImg(luaBehaviour, "race_img", eqp_jb_str, ResourceUtil:getLanAtlas())
                if itemData.item_cfg.type > 0 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", true)  
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)  
                end
                LuaBehaviourUtil.setImg(luaBehaviour, "type_img", "zbjb_leixing_0"..itemData.item_cfg.type, ResourceUtil:getLanAtlas())
            else
                for i = 1, 5 do
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "inten_lv" .. i, false)
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroInfo_ZhuangBei_001", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equip_t_corner_mark", false)
                local back_effect = luaBehaviour:FindGameObject("back_effect")
                local front_effect = luaBehaviour:FindGameObject("front_effect")
                UIUtil.destroyAllChild(back_effect.transform)
                UIUtil.destroyAllChild(front_effect.transform)
            end
        end
    end
    self:updateEquipBtn()--刷新按钮状态
    self:updateTalinsManInfo() --刷新符篆
    self:playGetEqpEffect()
    self.m_model:detectionEqps()
end

function M:updateEquipBtn()
    if self.m_model.m_mode == 3 then
        self:setObjectVisible("put_on_btn", false)
        self:setObjectVisible("get_out_btn", false)
        return 
    end
    local red_flag = RedPointUtil:checkHeroBetterEquipRedPointById(self.m_model.m_selected_id) --是否有更好装备
    if red_flag then
        self:setObjectVisible("put_on_btn",true)
        self:setObjectVisible("get_out_btn",false)
        return 
    end
    if self.m_model.m_equip_num >= 5 then 
        self:setObjectVisible("put_on_btn",false)
        self:setObjectVisible("get_out_btn",true)
    else
        self:setObjectVisible("put_on_btn",true)
        self:setObjectVisible("get_out_btn",false)
    end
end

--装备特效
function M:playGetEqpEffect()
    local eqp_list = self.m_model:getHeroEquList()
    local last_list = self.m_model.last_eqps
    for k, v in pairs(eqp_list) do
        local last_eqp = last_list[k]
        if last_eqp == nil or v.id ~= last_eqp.id then
            local ep_name = "eq" .. k .. "_btn"
            local ep_obj = self:findGameObject(ep_name)
            local tx = ResourceUtil:GetUIEffectItem("HeroInfo/UI_HeroInfo_ZhuangBei_002", ep_obj)
            tx.transform.localScale = Vector3(1, 1, 1)
            self:setParticleRenderOrder(tx)
            if self.m_control then
                self.m_control:setOnceTimer(
                    0.6,
                    function()
                        U3DUtil:Destroy(tx)
                    end
                )
            end
        end
    end
end

--更新神器数据
function M:updateArtifact()
    -- if self.m_model:checkArtifact() == false then
    -- 	local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[6])
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", false)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Artifact_WpGlow_001", false)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_img", false)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_text", true)
    -- 	return
    -- end
    -- local art_data, art_cfg = self.m_model:getArtifactData()
    -- if art_data and art_cfg then
    -- 	local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[6])
    -- 	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ARTIFACTS, art_data.id, 1, art_data.oid})
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", true)
    -- 	LuaBehaviourUtil.setImg(luaBehaviour, "art_img", itemData.icon_name, itemData.atlas_name)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_img", true)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Artifact_WpGlow_001", true)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_text", false)
    -- 	--local red_flag = RedPointUtil:checkArtifact(art_data) --神器红点
    -- 	local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    -- 	--red_point_img:SetActive(red_flag)
    -- else
    -- 	local luaBehaviour = UIUtil.findLuaBehaviour(self.m_eqps[6])
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg", false)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_img", false)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Artifact_WpGlow_001", false)
    -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "art_text", true)
    -- end
end

--红点
function M:refreshRedPoint()
    if self.m_model.m_hero_list_type == 1 and self.m_model.m_mode ~= 3 then
        local red_flag = RedPointUtil:checkHeroBetterEquipRedPointById(self.m_model.m_selected_id)
        if self.m_model.isNil == true then
            self:setObjectVisible("onekey_equip_red_point_img", false)
            --self:updateEquipBtn(false)
        else
            self:setObjectVisible("onekey_equip_red_point_img", red_flag == true)
            --self:updateEquipBtn(red_flag)
        end
    else
        self:setObjectVisible("onekey_equip_red_point_img", false)
        --self:updateEquipBtn(false)
    end
end

function M:numberChange(num1, num2)
    local sequence = Tweening.DOTween.Sequence()
    sequence:SetAutoKill(false)
    sequence:Append(Tweening.DOTween.To(function(index)
        local temp = math.floor(index)
        self:setText("slider_num", GameUtil:formatValueToString(temp))
    end, num1, num2, 0.5))
    sequence:AppendInterval(0.2)
    sequence:OnComplete(function ()

    end)
    return sequence
end


function M:refreshFriendInfo()
    if self.m_model:checkOpenFriendShip() == false then
        return
    end

    local maxLevel = self.m_model:getMaxFriendShipLvBySeason()-- ConfigManager:getCommonValueById(533, 999)
    local fetter_data = self.m_model:getFettersData()
    if fetter_data.lv >= 10 then
        local num_1 = math.floor(fetter_data.lv/10)
        local num_2 = fetter_data.lv-(num_1*10)
        self:setImg(num_1,"active_ui","youqing_lv_img_1")
        self:setImg(num_2,"active_ui","youqing_lv_img_2")
        self:setObjectVisible("youqing_lv_img_2", true)
        self:setObjectVisible("youqing_lv_img_1", true)
        self:setObjectVisible("youqing_lv_img", false)
    else
        self:setObjectVisible("youqing_lv_img_2", false)
        self:setObjectVisible("youqing_lv_img_1", false) --
        self:setObjectVisible("youqing_lv_img", true)
        self:setImg(fetter_data.lv,"active_ui","youqing_lv_img")
    end
    local show_slider_anim = false
    local curid = self.m_selected_id or self.m_model:getRightHero()
    
    if self.m_old_hero_id == curid then
        show_slider_anim = true
    else
        self.m_old_hero_id = curid
    end
    local lv_cfg = self.m_model:getFetterEqpMaxNum()
    if self.m_old_fetter_point == 0 then
        self.m_old_fetter_point = fetter_data.point
    end
    if self.m_old_fetter_point ~= fetter_data.point and show_slider_anim then
        if self.m_num_change_sequence then
            self.m_num_change_sequence:Kill()
            self.m_num_change_sequence = nil
        end
        self.m_num_change_sequence = self:numberChange(self.m_old_fetter_point, fetter_data.point)
        self.m_old_fetter_point = fetter_data.point
    else
        self:setTextByLanKey("slider_num", tostring(fetter_data.point) )
    end
    
    self:setTextByLanKey("slider_num_max", "/"..lv_cfg.upgrade)
    local slider = self:findSlider("slider_obj")
    if self.m_slider_sequence then
        self.m_slider_sequence:Kill()
        self.m_slider_sequence = nil
    end
    if show_slider_anim or self.m_model.m_is_friend_up then
        local sequence = Tweening.DOTween.Sequence()
        if slider.value > fetter_data.point/lv_cfg.upgrade or self.m_model.m_is_friend_up then
            self.m_model.m_is_friend_up = false
            sequence:Append(DOTweenModuleUI.DOValue(slider, 1, 0.4))
            sequence:AppendCallback(function()
                slider.value = 0
            end)
            sequence:Append(DOTweenModuleUI.DOValue(slider, fetter_data.point/lv_cfg.upgrade, 0.2))
        else
            sequence:Append(DOTweenModuleUI.DOValue(slider, fetter_data.point/lv_cfg.upgrade, 0.2))
        end
        sequence:SetAutoKill(true)
        self.m_slider_sequence = sequence
    else
        slider.value = (fetter_data.point/lv_cfg.upgrade)
    end
   
    local maxLevel = self.m_model:getMaxFriendShipLvBySeason()

    local attrsData = self.m_model:getHeroAttrsData()
    local isExistData = #attrsData > 0
    if isExistData then
        if self.m_scroll_view == nil then
            local loopscroll = self:findGameObject("property_loopscroll")
            local params = {
                show_data = attrsData,
                loop_scroll_object = loopscroll,
                update_cell = function(index, cell_obj, cell_data)
                    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                    if luaBehaviour then
                        local fetter_data2 = self.m_model:getFettersData()
                        local isMaxLevel = fetter_data2.lv >= maxLevel
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "notMaxLevelNode", (not isMaxLevel))
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "maxLevelNode", isMaxLevel)
                        if (not isMaxLevel) then
                            local name_text = luaBehaviour:FindText("text_propertyName")
                            name_text.text = Language:getTextByKey(cell_data.attrsName)
                            local text_curValue = luaBehaviour:FindText("text_curValue")
                            text_curValue.text = Language:getTextByKey(cell_data.curNum)
                            local text_newValue = luaBehaviour:FindText("text_newValue")
                            text_newValue.text = Language:getTextByKey(cell_data.lastNum)
                            text_newValue.color = cell_data.isNotChange and Color.New(216/255, 157/ 255, 69/ 255, 1) or
                                                    Color.New(107/255, 243/ 255, 48/ 255, 1)
                        else
                            local name_text2 = luaBehaviour:FindText("text_propertyName2")
                            name_text2.text = Language:getTextByKey(cell_data.attrsName)
                            local text_curValue2 = luaBehaviour:FindText("text_curValue2")
                            text_curValue2.text = Language:getTextByKey(cell_data.curNum)
                        end
                    end
                end,
                click_func = function(index, cell_object, cell_data, click_object, click_name)

                end
            }
            self.m_scroll_view = LoopScrollViewUtil.new(params)
        else
            self.m_scroll_view:reloadData(attrsData, true)
        end
    end

    local tabIndex = self.m_model.m_sel_tab_index
    self:setObjectVisible("friendRelationNode", (isExistData and (tabIndex == 4)) )
end


--界面信息
function M:updateInfo()
    local race = GlobalConfig.TYPE_HERO_RACE[self.m_model:getRace()].big_race_icon --英雄种族icon
    self:setImg(race, ResourceUtil:getLanAtlas(), "hero_race")
    self:setTextByLanKey("hero_name", self.m_model:getHeroName())
    self:setTextByLanKey("class_name", self.m_model:getHeroClassName())
    self:setTextByLanKey("txt_attack_des", self.m_model:getHeroAttackDes())
    self:setObjectVisible("main_stars", false)

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

    local evo = self.m_model:getEvo()
    --local FRAME_QUA = GlobalConfig.QUALITY_FRAME[evo]
    --local SETTING_QUA = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo]
    local _, cfg = self.m_model:getSelectHeroData()
    self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,evo), "common_ui", "hero_evo")
    --self:setObjectVisible("hero_add", SETTING_QUA.is_add == true)
    self:setObjectVisible("main_stars", true)
    local main_stars = self:findGameObject("main_stars")
    local data = {quality = evo }
    GameUtil:updateHeroInfo(main_stars,data)
    local last_lv = self.m_model.last_lv
    local cur_lv = self.m_model:getHero_lv()
    if self.m_model.m_hero_list_type ~= 2 and self.m_model.m_mode ~= 3 then
        self:lvZoom(last_lv, cur_lv)
    end
end

function M:refreshLevelUpUI()
    local last_lv = self.m_model.last_lv
    local cur_lv = self.m_model:getHero_lv()
    if self.m_model.m_hero_list_type ~= 2 and self.m_model.m_mode ~= 3 then
        self:lvZoom(last_lv, cur_lv)
    end
end


function M:lvZoom(last_lv, cur_lv)
    if cur_lv > last_lv then
        self:lvUpZoom()
    end
end

function M:lvUpZoom()
    if self.lv_lizi_time then
        self.m_control:removeTimer(self.lv_lizi_time)
        self.lv_lizi:SetActive(false)
        self.lv_lizi_time = nil
    end
    self.lv_lizi:SetActive(true)
    if self.m_control then
        self.lv_lizi_time = self.m_control:setTimer(
            1,
            function()
                if self.lv_lizi_time then
                    self.m_control:removeTimer(self.lv_lizi_time)
                    self.lv_lizi:SetActive(false)
                    self.lv_lizi_time = nil
                end
            end
        )
    end
end

--加锁信息
function M:updateLock()
    local lock_bl = self.m_model:getHeroLock()
    if lock_bl == true then
        self:setImg("a_ws_icon_suo_1", "hero_ui", "lock_img")
    else
        self:setImg("a_ws_icon_suo_2", "hero_ui", "lock_img")
    end
end

--经脉信息
function M:updateMeridianInfo()
    -- if self.m_model.m_mode == 3 then
    --     return
    -- end
    self:setPass()
end

function M:setPass()
    --1.冲、2：带、3：任、4：督
    local type_meridian_item = GlobalConfig.TYPE_MERIDIAN[self.m_model.m_select_meridian_index]
    if type_meridian_item then
        self.open_point_img = type_meridian_item.open_point_img
        self.no_open_point_img = type_meridian_item.no_open_point_img
        self.pass_line_img = type_meridian_item.pass_line_img
        self.no_pass_line_img = type_meridian_item.no_pass_line_img
        self.cur_active_effect = type_meridian_item.cur_active_effect

        self.pass = self:findGameObject("points_" .. self.m_model.m_select_meridian_index)
        local index = self.m_model:getPassNumByIndex()
        local num = self.pass.transform.childCount
        for i = 1, num do
            local pass_cell = self.pass.transform:GetChild(i - 1)
            local luaBehaviour = UIUtil.findLuaBehaviour(pass_cell)
            local cell_data = self.m_model:getPassNameByIndex(i)
            luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
                self:updateMsg(click_name, {cell_data = cell_data, click_object = click_object, index = i})
            end)
            local tx_parent = luaBehaviour:FindGameObject("point_icon")
            if tx_parent then
                UIUtil.destroyAllChild(tx_parent.transform)
            end
            if luaBehaviour then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "pass_name", cell_data.lv_name)
            end
            if self.m_model.sig_active == true and i < index then
                LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", self.pass_line_img, "hero_ui")
                LuaBehaviourUtil.setImg(luaBehaviour, "point_icon", self.open_point_img, "hero_ui")
                if tx_parent then
                    self:creatEffect(self.cur_active_effect, tx_parent)
                end
            elseif self.m_model.sig_active == true and i == index then
                self.m_cur_qihai = pass_cell
                LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", self.no_pass_line_img, "hero_ui")
                LuaBehaviourUtil.setImg(luaBehaviour, "point_icon", self.no_open_point_img, "hero_ui")
                if tx_parent then
                    self:creatEffect(self.QiHai, tx_parent)
                end
            else
                LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", self.no_pass_line_img, "hero_ui")
                LuaBehaviourUtil.setImg(luaBehaviour, "point_icon", self.no_open_point_img, "hero_ui")
            end
        end
    end
end

function M:creatEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("HeroInfo/" .. tx_name, prent)
    --item.transform:SetParent(prent.transform, false)
    return item
end

function M:creatCurEffect(auto,sig_data,callback)
    if self.temp_obj then
        if not IsNull(self.temp_obj) then
            UIUtil.destroyObject(self.temp_obj)
        end
    end
    local sig_deep = sig_data.deep or 0
    local meridians_cultivation_cfg_item = self.m_model:getSigMeridiansCultivationCfg(sig_deep).lower_level or 0 --这一阶段最高级
    local meridians_cultivation_cfg_item_last = sig_deep > 0 and self.m_model:getSigMeridiansCultivationCfg(sig_deep - 1).lower_level or 0 --上一阶段最高级
    local creat_effect_num = sig_data.lv - meridians_cultivation_cfg_item_last
    local time = 0.5
    if auto == 1 then
        creat_effect_num = self.m_model.sig_one_maxlv - meridians_cultivation_cfg_item_last  --当前可冲击到的最大等级 - 上一阶段的最高等级
        time = 0.15 
        self.activate_one_btn.interactable = false
        self.intensify_btn.interactable = false
        if self.m_model.sig_one_maxlv == meridians_cultivation_cfg_item then  --能达到这一阶段的最高等级
            self:setObjectVisible("intensify_btn", false)
            self:setObjectVisible("activate_one_btn", false)
            self:setObjectVisible("cost_item_num_intensify", false)
            self:setObjectVisible("cost_item_icon_intensify", false)
            self:setObjectVisible("cost_item_num_one", false)
            self:setObjectVisible("cost_item_icon_one", false)
            self:setObjectVisible("max_tips_text", true)
        end
    end
    --刷新按钮点击状态
   
    local current_id = sig_data.lv - meridians_cultivation_cfg_item_last
    local function laterTime()
        if self.temp_obj then
            if not IsNull(self.temp_obj) then
                UIUtil.destroyObject(self.temp_obj)
            end
            if current_id >=  creat_effect_num - 1 then
                callback()
            else
                local luaBehaviour = UIUtil.findLuaBehaviour(self.m_cur_qihai)
                local tx_parent = luaBehaviour:FindGameObject("point_icon")
                LuaBehaviourUtil.setImg(luaBehaviour, "pass_img", self.pass_line_img, "hero_ui")
                if tx_parent then
                    UIUtil.destroyAllChild(tx_parent.transform)
                    self:creatEffect(self.cur_active_effect, tx_parent)
                end
                current_id = current_id + 1
                local pass_cell = self.pass.transform:GetChild(current_id)
                self.m_cur_qihai = pass_cell
                self:creatMultEffect(time,current_id,laterTime)
            end
        end
    end
    if self.m_cur_qihai and current_id <= creat_effect_num then
        self:creatMultEffect(time,current_id,laterTime)
    end
end

--创建经脉特效
function M:creatMultEffect(time,current_id,laterTime)
    local c_lv = GameUtil:numberToChineseString(current_id + 1)
    self:setTextByLanKey("mai_lv_text_" .. self.m_model.m_select_meridian_index, "new_str_0741", c_lv)
    self.temp_obj = self:creatEffect(self.JuQi, self.m_meridian_obj)
    local pos = self.content_node.transform.parent:InverseTransformPoint(self.m_cur_qihai.transform.position)
    UIUtil.setLocalPosition(self.temp_obj.transform, pos.x, pos.y, pos.z)
    self.m_control:setOnceTimer(time, laterTime)
end

function M:playSigEffect()
    self:setObjectVisible("UI_Common_AnNiu_YellowBig_02", false)
    self:setObjectVisible("UI_Common_AnNiu_YellowBig_02", true)
    if self.m_effect_remove_timer_id ~= nil then
        self.m_control:removeTimer(self.m_effect_remove_timer_id)
    end
    self.m_effect_remove_timer_id = self.m_control:setOnceTimer(0.5, function()
        self.m_effect_remove_timer_id = nil
        self:setObjectVisible("UI_Common_AnNiu_YellowBig_02", false)
    end)
end

-- 突破特效
function M:playSigBreachEffect(callback)
    self:setObjectVisible("Fx_UI_HeroBagHeroNode_JuQi_02", true)
    self:setObjectVisible("Fx_UI_HeroBagHeroNode_JuQi_01", true)
    self.m_control:setOnceTimer(2, function()
        callback()
    end)

    --self:refresh_breach_btn()
end

function M:refresh_breach_btn()
    local can_break = self.m_model:getCurHeroSigCanBreak()
    if can_break then
        if self.m_model:Skill4CanBreak() then
            self:setObjectVisible("skillbreak",true)
            self:InitBreakSkill4Show()
        else
            self:setObjectVisible("slotbreak",true)
        end
    else
        self:setObjectVisible("skillbreak",false)
        self:setObjectVisible("slotbreak",false)
    end
end

function M:onButtonClick(obj, name)
    if name == "youqing_hint_btn" then
        local params = {}
        params.content = Language:getTextByKey("tid#haogandutips_4")
        params.title = Language:getTextByKey("new_str_0338")
        self:openView("Pops.CommonHelpPop", params)
    elseif name == "last_btn" then
        self:updateMsg("Sliding_right")
    elseif name == "next_btn" then
        self:updateMsg("Sliding_left")
    elseif name == "cost_item_icon" then
        local cost = self.m_model.sig_nextdata.levelup_cost
        local can_break = self.m_model:getCurHeroSigCanBreak()
        if can_break then
            cost = self.m_model:getCurHeroSigBreakCost()
        end
        if cost[1] then
            GameUtil:lookInfoTips(self.m_control, {click_transform = obj.transform, data = cost[1], top = true})
        end
    elseif name == "hero_type_img" then
        self:clickProTips1(name)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:clickProTips1(str)
	local temp_cfg = self.m_model:getCurHeroCfg()
	local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
	local data_desc = type_data.des
	local btns = self:findGameObject(str)
	if btns then
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, top = true , msg = Language:getTextByKey(data_desc) } )
	end
end

function M:setCons()
    local cost = self.m_model.sig_nextdata.levelup_cost
    if next(cost) == nil then
        return
    end
    local data_special = RewardUtil:getProcessRewardData(cost[1])
    local need_num = cost[1][3]
    local cur_num = data_special.user_num
    local cost_item_icon = self:setImg(data_special.icon_name, data_special.atlas_name, "cost_item_icon")
    self:setImg(data_special.icon_name, data_special.atlas_name, "cost_item_icon_intensify")
    self:setImg(data_special.icon_name, data_special.atlas_name, "cost_item_icon_one")
    local str = cur_num .. "/" .. need_num
    local text = self:setTextByLanKey("cost_item_num", str)
    local text_intensify = self:setTextByLanKey("cost_item_num_intensify", str)
    local one_breach_cost_num = self.m_model.sig_onedata or 0
    local one_breach_cost_num_text = cur_num .. "/" .. one_breach_cost_num
    local text_one_breach = self:setTextByLanKey("cost_item_num_one", one_breach_cost_num_text)
    if need_num > cur_num  then
        text.color = Color.New(255/255, 100/255, 64/255)
        text_intensify.color = Color.New(255/255, 100/255, 64/255)
    else
        text.color = Color.New(239/255, 234/255, 222/255)
        text_intensify.color = Color.New(239/255, 234/255, 222/255)
    end
    if one_breach_cost_num > cur_num then
        text_one_breach.color = Color.New(255/255, 100/255, 64/255)
    else
        text_one_breach.color = Color.New(239/255, 234/255, 222/255)
    end
    UIUtil.setLocalPosition(text.gameObject.transform,-44.72)
    UIUtil.setLocalPosition(cost_item_icon.gameObject.transform,-107.4001)
    local com_parent = self:findGameObject("reset_meridian_btn")
    --UIUtil.setLocalPosition(com_parent.transform,-190, -276)
    -- 突破材料显示
    local can_break = self.m_model:getCurHeroSigCanBreak()
    if can_break then
        --UIUtil.setLocalPosition(com_parent.transform,-190, -206)
        cost = self.m_model:getCurHeroSigBreakCost()
        for i = 1, 4 do
            if cost[i] then
                self:setObjectVisible("cost_item_num"..i, true)
                self:setObjectVisible("cost_item_icon"..i, true)
                local data_special = RewardUtil:getProcessRewardData(cost[i])
                local need_num = cost[i][3]
                local cur_num = data_special.user_num
                self:setImg(data_special.icon_name, data_special.atlas_name, "cost_item_icon"..i)
                local str = cur_num.."/"..need_num
                local text = self:setTextByLanKey("cost_item_num"..i, str)
                if need_num > cur_num then
                    text.color = Color.New(255/255, 100/255, 64/255)
                else
                    text.color = Color.New(239/255, 234/255, 222/255)
                end
            else
                self:setObjectVisible("cost_item_num"..i, false)
                self:setObjectVisible("cost_item_icon"..i, false)
            end
        end
    end
end

function M:switchMeridianByIndex(index)
    --1.冲、2：带、3：任、4：督
    self.m_model.m_select_meridian_index = index
    for i = 1, GlobalConfig.HERO_SIG_NUM do
        self:setObjectVisible("points_" .. i, index == i)
        local mai_img = self:findImage("mai_img_" .. i)
        local mai = self:setImg(index == i and "a_ws_jinmai_checked" or "a_ws_jingmai_unchecked", "hero_ui", "mai_" .. i)
        local open_flag = self.m_model:meridanOpenFlagByPos(i)
        if open_flag then
            mai_img.material = nil
            mai.material = nil
        else
            mai_img.material = self.m_gray_img.material
            mai.material = self.m_gray_img.material
        end
        local sig_data = self.m_model:getSigDataByType(i)
        if sig_data then
            local sig_deep = sig_data.deep or 0
            local meridians_cultivation_cfg_item = self.m_model:getSigMeridiansCultivationCfg(sig_deep)
            local next_meridians_cultivation_cfg_item = self.m_model:getSigMeridiansCultivationCfg(sig_deep+1)
            local lock_next_mer = false --下一阶段是否开启
            if next_meridians_cultivation_cfg_item then
                lock_next_mer = UserDataManager:getCurSeason() >= next_meridians_cultivation_cfg_item.season_unlock
            end
            local lower_level = meridians_cultivation_cfg_item.lower_level or 10 -- 当前阶段的最高等级
            local lv = sig_data.lv or 0
            local show_lv = (lv < lower_level) and lv%10 or 10
            local c_lv = GameUtil:numberToChineseString(show_lv)
            self:setTextByLanKey("mai_lv_text_" .. i, "new_str_0741", c_lv)
        else
            local c_lv = GameUtil:numberToChineseString(0)
            self:setTextByLanKey("mai_lv_text_" .. i, "new_str_0741", c_lv)
        end
        local h_data, h_cfg = self.m_model:getSelectHeroData()
        local red_flag = RedPointUtil:checkHeroOneSigCanLevelUpByData(h_data, h_cfg, i)
        self:setObjectVisible("mai_red_point_" .. i, red_flag)
    end
    self.m_model:updateSigData()
    self:updateMeridianInfo()
    self:setCons()
    self:setBtnShow()
    local meridians_cultivation_cfg_item = self.m_model:getShowHeroSigBreakCfgNew()
    self:setTextByLanKey("meridians_cultivation_text", meridians_cultivation_cfg_item.lv_name)
    local sig_deep = self.m_model.sig_deep or 0
    for i = 1, GlobalConfig.HERO_SIG_DEEP_MAX do
        self:setObjectVisible("meridians_cultivation_img_" .. i, false)
    end
    for i = 1, self.m_model.m_sig_deep_max do
        self:setObjectVisible("meridians_cultivation_img_" .. i, true)
        self:setImg(i <= sig_deep and "a_ws_zhoutianjinduqiu_dianliang" or "a_ws_shoutianjingduqiu_weidianliang", "hero_ui", "meridians_cultivation_img_" .. i)
    end
    --if self.m_model.m_sig_deep_max == 3 then
    --    local meridians_cultivation_img_3 = self:findGameObject("meridians_cultivation_img_3")
    --    local meridians_cultivation_img_2 = self:findGameObject("meridians_cultivation_img_2")
    --    local meridians_cultivation_img_1 = self:findGameObject("meridians_cultivation_img_1")
    --    UIUtil.setLocalPosition(meridians_cultivation_img_3.transform, 25, -7.5)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_2.transform, 0, -22.8)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_1.transform, -23, -7.5)
    --elseif self.m_model.m_sig_deep_max == 4 then
    --    local meridians_cultivation_img_4 = self:findGameObject("meridians_cultivation_img_4")
    --    local meridians_cultivation_img_3 = self:findGameObject("meridians_cultivation_img_3")
    --    local meridians_cultivation_img_2 = self:findGameObject("meridians_cultivation_img_2")
    --    local meridians_cultivation_img_1 = self:findGameObject("meridians_cultivation_img_1")
    --    UIUtil.setLocalPosition(meridians_cultivation_img_4.transform, 23.8, 0)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_3.transform, 10.8, -20)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_2.transform, -10.8, -20)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_1.transform, -23.8, 0)
    --elseif self.m_model.m_sig_deep_max == 5 then
    --    local meridians_cultivation_img_5 = self:findGameObject("meridians_cultivation_img_5")
    --    local meridians_cultivation_img_4 = self:findGameObject("meridians_cultivation_img_4")
    --    local meridians_cultivation_img_3 = self:findGameObject("meridians_cultivation_img_3")
    --    local meridians_cultivation_img_2 = self:findGameObject("meridians_cultivation_img_2")
    --    local meridians_cultivation_img_1 = self:findGameObject("meridians_cultivation_img_1")
    --    UIUtil.setLocalPosition(meridians_cultivation_img_5.transform, 28.2, 0.9)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_4.transform, 20.8, -16.9)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_3.transform, 0, -22.8)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_2.transform, -20.8, -16.9)
    --    UIUtil.setLocalPosition(meridians_cultivation_img_1.transform, -28.2, 0.9)
    --end
end

function M:setBtnShow()
    self:setObjectVisible("Fx_UI_HeroBagHeroNode_JuQi_02", false)
    self:setObjectVisible("Fx_UI_HeroBagHeroNode_JuQi_01", false)
    self:setObjectVisible("cost_node", false) -- 经脉突破消耗材料节点
    if self.m_model:checkMaxSig() == true and self.m_model.m_mode ~= 3 then
        self:setObjectVisible("activate_btn", false)
        local can_break = self.m_model:getCurHeroSigCanBreak()
        self:setObjectVisible("breach_btn", can_break)
        if can_break then
            local skillCanBreak=self.m_model:Skill4CanBreak()
            self:setObjectVisible("skillbreak",skillCanBreak)
            self:setObjectVisible("slotbreak",not skillCanBreak)
            if skillCanBreak then
                self:InitBreakSkill4Show()
            else
                if self.preSelectedHero_CanBreakSlotGo~=nil then
                    self.preSelectedHero_CanBreakSlotGo.gameObject:SetActive(false)
                end
                local slotType=self.m_model:GetCanBreakSlotType()
                local slotStr="slottype"..slotType
                self:setObjectVisible(slotStr,true)
                self.preSelectedHero_CanBreakSlotGo=self:findGameObject(slotStr)
            end
        end

        self:setObjectVisible("intensify_btn", false)
        self:setObjectVisible("activate_one_btn", false)
        self:setTextByLanKey("intensify_text", can_break and "anecdote_002" or "anecdote_001")
        self:setObjectVisible("max_tips_text", not can_break)
        self:setObjectVisible("cost_item_num", false)
        self:setObjectVisible("cost_item_icon", false)
        self:setObjectVisible("cost_item_num_intensify", false)
        self:setObjectVisible("cost_item_icon_intensify", false)
        self:setObjectVisible("cost_item_num_one", false)
        self:setObjectVisible("cost_item_icon_one", false)
        self:setObjectVisible("cost_node", can_break) -- 经脉突破消耗材料节点
        local cur_season = UserDataManager:getCurSeason()
        local sig_deep = self.m_model.sig_deep or 0
        self:setTextByLanKey("max_tips_text", (sig_deep < GlobalConfig.HERO_SIG_DEEP_MAX and cur_season >=  self.m_model.lock_season) and "new_str_0820" or "new_str_0798")
        if can_break == true then
            for i = 1,4 do 
                self:setObjectVisible("points_"..i, false) 
                local mai_img = self:findImage("mai_img_" .. i)
                local mai = self:setImg("a_ws_jingmai_unchecked", "hero_ui", "mai_" .. i)
                mai_img.material = self.m_gray_img.material
                mai.material = self.m_gray_img.material
            end
        end
        if self.m_model.m_mode == 3 then
            self:setObjectVisible("max_tips_text", false)
        end
    elseif self.m_model.m_mode == 3 then
        self:setObjectVisible("activate_btn", false)
        self:setObjectVisible("intensify_btn", false)
        self:setObjectVisible("activate_one_btn", false)
        self:setObjectVisible("breach_btn", false)
        self:setObjectVisible("cost_item_num", false)
        self:setObjectVisible("cost_item_icon", false)
        self:setObjectVisible("cost_item_num_intensify", false)
        self:setObjectVisible("cost_item_icon_intensify", false)
        self:setObjectVisible("cost_item_num_one", false)
        self:setObjectVisible("cost_item_icon_one", false)
        self:setObjectVisible("max_tips_text", false)
    else
        self:setObjectVisible("activate_btn", not self.m_model.sig_active)
        self:setObjectVisible("intensify_btn", self.m_model.sig_active)
        self:setObjectVisible("activate_one_btn", self.m_model.sig_active)
        self:setObjectVisible("breach_btn", false)
        self:setObjectVisible("cost_item_num", not self.m_model.sig_active)
        self:setObjectVisible("cost_item_icon", not self.m_model.sig_active)
        self:setObjectVisible("cost_item_num_intensify", self.m_model.sig_active)
        self:setObjectVisible("cost_item_icon_intensify", self.m_model.sig_active)
        self:setObjectVisible("cost_item_num_one", self.m_model.sig_active)
        self:setObjectVisible("cost_item_icon_one", self.m_model.sig_active)
        self:setObjectVisible("max_tips_text", false)
        self:setTextByLanKey("intensify_text", "anecdote_001")
    end
    local can_reset = self.m_model:getSigCanReset()
    self:setObjectVisible("reset_meridian_btn", self.m_model.m_mode ~= 3 and can_reset)
end

--初始化技能突破显示
function M:InitBreakSkill4Show()
    local skill=self.m_model:getCurBreakSkill()
    local cur_skill = GameUtil:getSkill(skill[1][1])
    self:setImg(cur_skill.icon, "skill_icon", "pre_break_skill_img")
    self:setImg(cur_skill.icon, "skill_icon", "next_break_skill_img")

    self:setTextByLanKey("sk_1", cur_skill.show_type)
    self:setTextByLanKey("sk_2", cur_skill.show_type)

    local isJueSha=open_maxlv_skill_index==1
    self:setObjectVisible("juesha1",isJueSha)
    self:setObjectVisible("juesha2",isJueSha)
end

function M:getSkillIcon(index)
    return self:findGameObject(index)
end

-- 显示侠客好感度点亮特效 
function M:showFriendLightenEft(order_data, hero_id, friendLevelUpParams)
    if friendLevelUpParams then
        local isPlayOverFriendLevelUpEft = self.m_model.isPlayOverFriendLevelUpEft
        --self:setObjectVisible("eft1", (isPlayOverFriendLevelUpEft))
        if isPlayOverFriendLevelUpEft == true then
            self:creatHeroHongXin()
        end
        if not isPlayOverFriendLevelUpEft then
            return
        end
    else
        -- self:setObjectVisible("eft1", true)
        self:creatHeroHongXin()
    end
    -- self.m_control:setOnceTimer(1,function()
    --     self:setObjectVisible("eft1", false)
    -- end)
    --升级的时候播放升级特效，特效播特效的，延迟0.4秒直接弹出好感度提升界面
    self.m_control:setOnceTimer(0.4,function()
        if friendLevelUpParams then
            local isPlayOverFriendLevelUpEft2 = self.m_model.isPlayOverFriendLevelUpEft
            if not isPlayOverFriendLevelUpEft2 then
                return
            end
            local last_combat = 0
            if self.m_model.friendLevelUpData and self.m_model.friendLevelUpData.last_combat then
                last_combat = self.m_model.friendLevelUpData.last_combat
            end
            self:showFriendLikeLevelFullScreenEft(order_data, hero_id, friendLevelUpParams, last_combat)
        end
    end)
end

function M:showFriendLikeLevelFullScreenEft(order_data, hero_id, friendLevelUpParams, last_combat)
    local isPlayOverFriendLevelUpEft = self.m_model.isPlayOverFriendLevelUpEft
    -- self:setObjectVisible("eft2", (isPlayOverFriendLevelUpEft))
    if isPlayOverFriendLevelUpEft == true then
        self:creatHeroHuaBan()
    end
    if not isPlayOverFriendLevelUpEft then
        return
    end
    -- self.m_control:setOnceTimer(1,function()
    --     self:setObjectVisible("eft2", false)
    -- end)
    local isPlayOverFriendLevelUpEft2 = self.m_model.isPlayOverFriendLevelUpEft
    if not isPlayOverFriendLevelUpEft2 then
        return
    end
    self.m_model:setIsPlayOverFriendLevelUpEft(true)
    self.m_model:setFriendLevelUpData(nil)
    local cur_combat = self.m_model:getHero_Combat()
    local hero_skin_data = self.m_model:getHeroBigAnim()
    self:openView("HeroBag.HeroFriendShipLvUpPop", {hero_skin_data = hero_skin_data, cur_combat = cur_combat,last_combat = last_combat, order_data = order_data, hero_id = hero_id, friendLevelUpParams = friendLevelUpParams})
   
end

--创建红心特效
function M:creatHeroHongXin()
    if self.hongxin_tab and #self.hongxin_tab >= 3 and self.hongxin_tab[1] then
        if not IsNull(self.hongxin_tab[1].obj) then
            UIUtil.destroyObject(self.hongxin_tab[1].obj)   
            self.m_control:removeTimer(self.hongxin_tab[1].tim_key) 
            table.remove(self.hongxin_tab, 1)
        end
    end
    local eft1 = self:findGameObject("eft1")
    local hongxin = self:creatHeroBagEffect("UI_HeroBag_HongXin_001", eft1)
    local hx_time = self.m_control:setOnceTimer(1,function()
        if not IsNull(hongxin) then
            for k,v in pairs(self.hongxin_tab) do
                if hongxin == v.obj then
                    UIUtil.destroyObject(hongxin)  
                    table.remove(self.hongxin_tab, k)
                    break
                end
            end
        end
    end)
    table.insert(self.hongxin_tab, {tim_key = hx_time, obj = hongxin} )
end


--创建花瓣特效
function M:creatHeroHuaBan()
    if self.huaban_tab and #self.huaban_tab >= 3 and self.huaban_tab[1] then
        if not IsNull(self.huaban_tab[1].obj) then
            UIUtil.destroyObject(self.huaban_tab[1].obj)   
            self.m_control:removeTimer(self.huaban_tab[1].tim_key) 
            table.remove(self.huaban_tab, 1)
        end
    end
    local eft2 = self:findGameObject("eft2")
    local huaban = self:creatHeroBagEffect("UI_HeroBag_HuaBan_001", eft2)
    local hb_time = self.m_control:setOnceTimer(1,function()
        if not IsNull(huaban) then
            for k,v in pairs(self.huaban_tab) do
                if huaban == v.obj then
                    UIUtil.destroyObject(huaban)  
                    table.remove(self.huaban_tab, k)
                    break
                end
            end
        end
    end)
    table.insert(self.huaban_tab, {tim_key = hb_time, obj = huaban} )
end

function M:creatHeroBagEffect(tx_name, prent)
    local item = ResourceUtil:GetUIEffectItem("HeroBag/"..tx_name, prent)
    return item
end


--刷新联动数据
function M:updateLinkData()
    if self.m_model:IsLink() == false then
        self:setObjectVisible("linkage_obj", false)
        return false
    end
    self:setObjectVisible("linkage_obj", true)
    local HeroNode = self:findGameObject("HeroNode")
    local HeroNode2 = self:findGameObject("HeroNode2")
    local h_data, h_cfg = self.m_model:getSelectHeroData()
    CommonUIUtil:updateHeroElement(HeroNode, {101, h_data.id, 1, h_data.oid})
    if h_data.link then
        local link_data, link_cfg = UserDataManager.hero_data:getHeroDataById(h_data.link)
        CommonUIUtil:updateHeroElement(HeroNode2, {101, link_data.id, 1, link_data.oid})
    else
        CommonUIUtil:updateHeroElementAdd(HeroNode2,nil, true)
        local luaBehaviour = UIUtil.findLuaBehaviour(HeroNode2)
        luaBehaviour:RegistButtonClick(function(click_object, click_name, idx)
           self.m_control:openView("Advanced", {select_oid = h_data.oid})
        end
        ) -- 重置事件
    end
end

-- 刷新职业等级相关
function M:refreshHeroRoleInfo()
    if self.m_model:showRoleType() == true then
        self:setObjectVisible("img_attack_des", false)
        self:setObjectVisible("img_tips_text2", true)
        local m_heroRoleCfg = self.m_model:getHeroRoleCfg()
        self:setTextByLanKey("tips_new_text1", "hero_role_upgrade_text2")
        self:setTextByLanKey("tips_new_text2", m_heroRoleCfg.role_name)
        self:setTextByLanKey("tips_new_text3", m_heroRoleCfg.equip_name)
        local upgrade_type_info = GlobalConfig.HERO_ROLE_UPGRADE_TYPE[tonumber(m_heroRoleCfg.icon)]
        if upgrade_type_info then
            self:setImg(upgrade_type_info.icon or "a_tjsj_zhiye_1green", "hero_ui", "tips_new_img")
            local tips_new_text2 = self:setTextColor("tips_new_text2", upgrade_type_info.color)
            UIUtil.setOutlineExEffectColor(tips_new_text2.transform,nil, upgrade_type_info.outLineColor,2)
        end
    else
        self:setObjectVisible("img_attack_des", true)
        self:setObjectVisible("img_tips_text2", false)
    end
end

--设置天命化星星辰描述和大侠标识
function M:setFatesInfo(index)
    local star_des = false
    local star_name = false
    --if index == 6 then --天命状态
        --判断是否天命化星状态
        local hero_Data = self.m_model:getSelectHeroData()
        local star_id,is_fate = self.m_model:getFatesInfo(hero_Data.oid)
        local star_info = self.m_model:getFateByStarId(star_id)
        if is_fate then --开启了天命化星
            star_name = true
        else
            star_info = self.m_model:getFatesByHeroId(hero_Data.id)
        end
        star_des = true
        local star_des = Language:getTextByKey(star_info.star_des)
        local  star_des_text = string.gsub(star_des,"/n","，")
        self:setTextByLanKey("tips_new_text4",star_des_text)
    --end
    self:setObjectVisible("xia_img", not star_name)
    self:setObjectVisible("tianming_xia_img", star_name)
    --self:setObjectVisible("UI_Destiny_005", star_name) --天命特效（废弃）
    self:setObjectVisible("main_stars", not star_name)
    self:setObjectVisible("ordinary_des_img1", not star_name)
    self:setObjectVisible("ordinary_des_img2", not star_name)
    self:setObjectVisible("tianming_img_tips_text1", star_name)
    self:setObjectVisible("tianming_img_tips_text2", star_name)
end


function M:destroy()
    if self.lv_lizi_time then
        self.m_control:removeTimer(self.lv_lizi_time)
        self.lv_lizi_time = nil
    end
    if self.add_combat_sequence then
        self.add_combat_sequence:Kill()
        self.add_combat_sequence = nil
    end

    if self.m_num_change_sequence then
        self.m_num_change_sequence:Kill()
        self.m_num_change_sequence = nil
    end

    if self.m_slider_sequence then
        self.m_slider_sequence:Kill()
        self.m_slider_sequence = nil
    end
    
    if self.m_sequence then
        self.m_sequence:Kill()
        self.m_sequence = nil
    end
    for k,v in pairs(self.hongxin_tab) do
        
    end
    if self.combat_time then
        self.m_control:removeTimer(self.combat_time)
        self.combat_time = nil
    end
    M.super.destroy(self)
end
----------------------------------------------------------符篆
function M:updateCurrentView(type)
    self:setObjectVisible("zhuangbei_other_view",type==1)
    self:setObjectVisible("zhuangbei_view",true)
    self:setObjectVisible("fuzhuan_view",true)
    local imageName = type == 1 and "a_fz_zjm_fuzhuandi" or "a_fz_zjm_zhuangbeidi"
    self:setImg(imageName,"mystic_ui","togger_out_btn")
    local obj = self:findGameObject("zhuangbei_view")
    local fuzhuanobj = self:findGameObject("fuzhuan_view")
    local zhuangbei_luabehaviour = UIUtil.findLuaBehaviour(obj)
    local fuzhuan_luabehaviour = UIUtil.findLuaBehaviour(fuzhuanobj)
    if zhuangbei_luabehaviour then
        if type == 1 then
            fuzhuan_luabehaviour:RunAnim("zhuangbei_fuzhuan_exit",handler(self, self.endCallFunc), 1)
            zhuangbei_luabehaviour:RunAnim("zhuangbei_enter",handler(self, self.endCallFunc), 1)
        elseif type==2 then
            zhuangbei_luabehaviour:RunAnim("zhuangbei_exit",handler(self, self.endCallFunc), 1)
            fuzhuan_luabehaviour:RunAnim("zhuangbei_fuzhuan_enter",handler(self, self.endCallFunc), 1)
        end
    else
        self:setObjectVisible("zhuangbei_view ",type == 1)
        self:setObjectVisible("fuzhuan_view",type == 2)
    end
    --self:setObjectVisible("zhuangbei_view ",type == 1)
    --self:setObjectVisible("img_attack_des",type == 1)
    --self:setObjectVisible("img_tips_text2",type == 1)
    --self:setObjectVisible("fuzhuan_view",type == 2)
    if type == 1 then
        self:setObjectVisible("togger_out_red_point_img",self.m_model.is_talins_red)
    else
        self:setObjectVisible("togger_out_red_point_img",false)
    end
    local talis_data = self.m_model:getTalisData()
    if self.m_model.m_mode==3 or #talis_data<=0 then
        self:setObjectVisible("togger_out_red_point_img",false)
    end
end



function M:endCallFunc(animName)
    if  tostring(animName) == "zhuangbel_enter" then
        self:setObjectVisible("zhuangbei_view",true)
        self:setObjectVisible("fuzhuan_view",false)
    elseif tostring(animName) == "fuzhuan_enter" then
        self:setObjectVisible("zhuangbei_view",false)
        self:setObjectVisible("fuzhuan_view",true)
    end
end
--更新符篆信息
function M:updateTalinsManInfo()
    --self:refreshRedPoint()
    --self:checkCombatChange()
    --根据赛季判断是否开启
    local activeData = ConfigManager:getCfgByName("open_condition") or {}
    local active_data_item = activeData[390]
    local cur_season = UserDataManager:getCurSeason() -- 获取赛季
    local cur_stage = UserDataManager:getCurStage()
    local condition_fail = false
    if active_data_item == nil then
        condition_fail = true
    else
        local unlock3 = active_data_item.unlock_condition_param3 or 0
        if cur_season < active_data_item.season_unlock and (unlock3 <= 0 or unlock3 > cur_stage) then --赛季未解锁，并且，超前开启条件未设置或者设置了但不满足
            condition_fail = true
        end
    end
    if condition_fail == true then
        self:setObjectVisible("fuzhuan_view",false)
        self:setObjectVisible("zhuangbei_view",true)
        self:setObjectVisible("togger_out_btn",false)
        self:setObjectVisible("togger_out_red_point_img",false)
        return
    end
    self:setObjectVisible("togger_out_btn",true) --默认设置一下 怕有问题
    local eqp_data = self.m_model:getHeroTalinsManList()
    local selecData = self.m_model:getSelectHeroData()
    --local data, cfg = UserDataManager.hero_data:getHeroDataById(selecData.oid)
    local data = selecData
    self:setObjectVisible("togger_out_btn",true)
    if data and data.evo <19 then --彩色品阶
        --self:updateCurrentView(1)
        self:setObjectVisible("togger_out_btn",false)
       
    end
    if data and data.evo <19 and self.m_model.is_open_type == 2  then --彩色品阶
        self.m_model.is_open_type = 1
        self:updateCurrentView(1)
        self:setObjectVisible("togger_out_btn",false)
        self:setObjectVisible("togger_out_red_point_img",false)
        return
    end
    --设置全部特效
    local currnum = self.m_model:getHeroTalinsEfeectNum(1) --默认第一个
    if currnum >=4 then
        local back_effect = self:findGameObject("fuzhuan_view_effect")
        UIUtil.destroyAllChild(back_effect.transform)
        self:setObjectVisible("fuzhuan_view_effect",true)
        local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Talins_003",self:findGameObject("fuzhuan_view"))
        eqp_effect2.transform:SetParent(back_effect.transform, false)
        eqp_effect2.transform.localPosition = Vector3(0,0,0)
    else
        self:setObjectVisible("fuzhuan_view_effect",false)
    end
    for k = 1, 4 do
        local data = eqp_data[tostring(k)]
        local luaBehaviour = UIUtil.findLuaBehaviour(self.m_talins[k])
        if luaBehaviour then
            --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", false)
            --LuaBehaviourUtil.setImg(luaBehaviour, "bg", "a_ui_currency_dj_kong", "equip_icon")
            --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", true)
            --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "eqp_zz", true)
            if data then
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "eqp_zz", false)
                --local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.EQUIPS, data.id, data.race, data.oid})
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroInfo_ZhuangBei_001", self.m_model:getRace() == data.race)
                --GameUtil:creatEffectForEquip(self.m_eqps[k],itemData)
                --local eqpDatra = GlobalConfig.QUALITY_COMMON_SETTING[itemData.quality]
                --if eqpDatra then
                --    LuaBehaviourUtil.setImg(luaBehaviour, "bg", eqpDatra.frame_name, "equip_icon")
                --end
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", false)
                --if eqpDatra.t_corner_mark and eqpDatra.t_corner_mark > 0 then
                --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equip_t_corner_mark", false)
                --else
                --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equip_t_corner_mark", false)
                --end
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img", false)
                --LuaBehaviourUtil.setImg(luaBehaviour, "equ_img", itemData.icon_name, itemData.atlas_name)
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equ_img", true)
                --for i = 1, 5 do
                --    local star = luaBehaviour:FindGameObject("inten_lv" .. i)
                --    if itemData.quality >= 12 then
                --        UIUtil.setImg(star.transform, "a_ui_currency_ws_xingji", "equip_icon")
                --    else
                --        UIUtil.setImg(star.transform, "a_ui_currency_dj_xinji", "equip_icon")
                --    end
                --    if star then
                --        star:SetActive(i <= data.lv)
                --    end
                --end
                ---- 字段拼接 zbjb_0+装备类型+_0+装备种族属性
                --local race = data.race
                --if race == 0 then
                --    race = 0
                --end
                --local equ_lv = GameUtil:getEquipLevel(itemData.quality)
                --local eqp_jb_str = "zbjb_0"..race.."_0"..equ_lv
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", true)
                --if race == 0 and itemData.quality <= 8 then
                --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
                --end
                ---- if itemData.quality >= 12 then
                ----     LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
                ---- end
                --LuaBehaviourUtil.setImg(luaBehaviour, "race_img", eqp_jb_str, ResourceUtil:getLanAtlas())
                --if itemData.item_cfg.type > 0 then
                --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", true)
                --else
                --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)
                --end
                --LuaBehaviourUtil.setImg(luaBehaviour, "type_img", "zbjb_leixing_0"..itemData.item_cfg.type, ResourceUtil:getLanAtlas())
                local cfgData = self.m_model:getTalisSuitConfigByCid(data.id)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_eqp_zz", false) --加号 背景
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_add_img", false) --加号
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_bg_img", true) --符篆
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_img", true) --品质框
                LuaBehaviourUtil.setImg(luaBehaviour, "fuzhuan_bg_img", cfgData.main_icon, "maze_stage_ui")
                local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[cfgData.quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
                local frame_name = quality_item.hero_item_frame
                LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"quality_img",false)
                --特效
                local back_effect = luaBehaviour:FindGameObject("fuzhuan_back_effect")
                UIUtil.destroyAllChild(back_effect.transform)
                local currnum = self.m_model:getHeroTalinsEfeectNum(k)
                if currnum >= 2  and currnum < 4 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_back_effect", true)
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Talins_002", self.m_talins[k])
                    eqp_effect2.transform:SetParent(back_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                elseif currnum >=4 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_back_effect", true)
                    local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Talins_002", self.m_talins[k])
                    eqp_effect2.transform:SetParent(back_effect.transform, false)
                    eqp_effect2.transform.localPosition = Vector3(0,0,0)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_back_effect", false) --品质框
                end
                UIUtil.setScale(back_effect.transform,1, 1)
                --其他玩家
                local redFlag = self.m_model:IsTalinsRedPoint(data)
                self.m_model.is_talins_red = redFlag
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_red_point_img", redFlag)
                if self.m_model.m_mode == 3 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_eqp_zz", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_add_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_red_point_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "togger_out_red_point_img", false)
                end
            else
                --for i = 1, 5 do
                --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "inten_lv" .. i, false)
                --end
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_jiao_img", false)
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_HeroInfo_ZhuangBei_001", false)
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_img", false)
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "type_img", false)
                --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "equip_t_corner_mark", false)
                --local back_effect = luaBehaviour:FindGameObject("back_effect")
                --local front_effect = luaBehaviour:FindGameObject("front_effect")
                --UIUtil.destroyAllChild(back_effect.transform)       
                --UIUtil.destroyAllChild(front_effect.transform)
                --临时修改
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_eqp_zz", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_add_img", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_bg_img", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "quality_img", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_back_effect", false) --特效框
                --local back_effect = luaBehaviour:FindGameObject("fuzhuan_back_effect")
                --local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Glow_002", self.m_talins[k])
                --eqp_effect2.transform:SetParent(back_effect.transform, false)
                --eqp_effect2.transform.localPosition = Vector3(0,0,0)
                
                --刷新红点
                local oid = self.m_model.m_selected_id
                local team_mult = UserDataManager.hero_data:getMultTeamByKey("mult_team_stage")
                local is_inteam = false
                for k,v in pairs(team_mult) do
                    is_inteam = table.keyof(v, oid)
                    if is_inteam then 
                        break
                    end
                end
                local talis_data = self.m_model:getTalisData()
                if not is_inteam then
                    local team = UserDataManager.hero_data:getTeamByKey("stage")
                    is_inteam = table.keyof(team, oid)
                end
                if is_inteam and #talis_data>0 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_red_point_img", true)
                    self.m_model.is_talins_red = true
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_red_point_img", false)
                    self.m_model.is_talins_red = false
                end
                --其他玩家
                if self.m_model.m_mode == 3 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_eqp_zz", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_add_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fuzhuan_red_point_img", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "togger_out_red_point_img", false)
                end
            end
        end
    end
    --self:playGetEqpEffect()
    --self.m_model:detectionEqps()
    --刷新主界面符篆红点
    self:setObjectVisible("togger_out_red_point_img",self.m_model.is_talins_red)
    local talis_data = self.m_model:getTalisData()
    if self.m_model.is_open_type == 2 or #talis_data<=0 then
        self:setObjectVisible("togger_out_red_point_img",false)
    end
end

return M
