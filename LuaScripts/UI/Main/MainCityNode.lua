--- 门派
---@class MainCityNode:OOUIbase
local M = class("MainCityNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainCityNode"
M.m_iphoneXAdapter = true

--key对应open_condition中的id
M.m_btn_lock_img = {
    [9] =  {font_size = 24, root_scale = 1.2, bnt_key = "level_up_btn",root_name = "level_up_root", face = {"Image_jinglitang"},floor={"floor_jinglitang"} ,lock_img_name = "level_up_btn_lock_img", red_point_img = "level_up_red_point_img", name_key = "level_up_text", name_text = "new_str_0021", open = true},--升阶
    --[36] = {font_size = 22, root_scale = 1.1, bnt_key = "recycle_btn",root_name = "recycle_root",face = {"Image_libiechuan"},floor={"floor_libiechuan"} , lock_img_name = "recycle_btn_lock_img", red_point_img = "recycle_red_point_img", name_key = "recycle_text", name_text = "predestined_str_001", open = false},--分解 现用做前缘桥
    --[13] = {font_size = 20, root_scale = 1, bnt_key = "tavern_btn",root_name = "tavern_root",face = {"Image_dashan"} ,floor={"floor_dashan"}, lock_img_name = "tavern_btn_lock_img", red_point_img = "tavern_red_point_img", name_key = "tavern_text", name_text = "new_str_0022", open = false},--酒馆
    --[44] = {font_size = 24, root_scale = 1.2, bnt_key = "shop_btn",root_name = "shop_root",face = {"Image_jishi"} ,floor={"floor_jishi"}, lock_img_name = "shop_btn_lock_img", red_point_img = "shop_red_point_img", name_key = "shop_text", name_text = "new_str_0024", open = false},--商店
    [29] = {font_size = 24, root_scale = 1.2, bnt_key = "common_lv_btn",root_name = "common_lv_root",face = {"Image_dongfangshen"} ,floor={"floor_dongfangshen"}, lock_img_name = "common_lv_btn_lock_img", red_point_img = "common_lv_red_point_img", name_key = "share_lv_text", name_text = "new_str_0155", open = true},--共享水晶
    --[30] = {font_size = 22, root_scale = 1.1, bnt_key = "rank_btn",root_name = "rank_root",face = {"Image_fengshenbang"} ,floor={"floor_fengshenbang"}, lock_img_name = "rank_btn_lock_img", red_point_img = "rank_red_point_img", name_key = "rank_text", name_text = "new_str_0020", open = false},--排行榜
    --[21] = {font_size = 20, root_scale = 1, bnt_key = "teahouse_btn",root_name = "teahouse_root",face = {"Image_jinglitang"},floor={"floor_jinglitang"} , lock_img_name = "teahouse_btn_lock_img", red_point_img = "teahouse_red_point_img", name_key = "teahouse_text", name_text = "new_str_0336", open = false},-- 归州茶馆
    --[22] = {font_size = 22, root_scale = 1.1, bnt_key = "union_btn",root_name = "union_root",face = {"Image_gonghui","Image_gonghui_hou"},floor={"floor_gonghui","floor_gonghui_hou"} , lock_img_name = "union_btn_lock_img", red_point_img = "union_red_point_img", name_key = "union_text", name_text = "new_str_0403", open = false},-- 帮会
    --[203] = {font_size = 20, root_scale = 1, bnt_key = "mystic_btn",root_name = "mystic_root",face = {"Image_cangjingge"}, floor={"floor_cangjingge"}, lock_img_name = "mystic_btn_lock_img", red_point_img = "mystic_red_point_img", name_key = "mystic_text", name_text = "new_str_0420", open = false},-- 藏经阁
    --[142] = {font_size = 20, root_scale = 1, bnt_key = "compass_btn",root_name = "compass_root",face = {"Image_compass"}, floor={"floor_compass"}, lock_img_name = "compass_btn_lock_img", red_point_img = "compass_red_point_img", name_key = "compass_text", name_text = "tid#roulette1", open = false},-- 轮盘

    [190] = {font_size = 20, root_scale = 1, bnt_key = "magic_weapon_btn",root_name = "magic_weapon_root",face = {"Image_fengshenbang"}, floor={"floor_fengshenbang"}, lock_img_name = "magic_weapon_btn_lock_img", red_point_img = "magic_weapon_red_point_img", name_key = "magic_weapon_text", name_text = "weapon_str_0002", open = true},-- 法宝 古物殿
    [220] = {font_size = 20, root_scale = 1, bnt_key = "equip_awaken_btn",root_name = "equip_awaken_root",face = {"Image_libiechuan"}, floor={"floor_libiechuan"}, lock_img_name = "equip_awaken_btn_lock_img", red_point_img = "equip_awaken_red_point_img", name_key = "equip_awaken_text", name_text = "art_str_004", open = true},-- 觉醒 神兵殿
    [148] = {font_size = 20, root_scale = 1, bnt_key = "mystic_btn",root_name = "mystic_root",face = {"Image_cangjingge"}, floor={"floor_cangjingge"}, lock_img_name = "mystic_btn_lock_img", red_point_img = "mystic_red_point_img", name_key = "mystic_text", name_text = "mystic_str_0001", open = true},-- 秘籍 琅嬛阁
    [256] = {font_size = 20, root_scale = 1, bnt_key = "destinyStar_btn",root_name = "destinyStar_root",face = {"Image_jishi"}, floor={"floor_jishi"}, lock_img_name = "destinyStar_btn_lock_img", red_point_img = "destinyStar_red_point_img", name_key = "destinyStar_text", name_text = "destinyStar_text_0001", open = true},-- 天命化星 观星楼

    [383] = {font_size = 20, root_scale = 1, bnt_key = "penglai4_btn",root_name = "penglai4_root",face = {"Image_compass"}, floor={"floor_compass"}, lock_img_name = "penglai4_btn_lock_img", red_point_img = "penglai4_red_point_img", name_key = "penglai4_text", name_text = "pengLai_text_026", open = true},--威望阁
    [417] = {font_size = 20, root_scale = 1, bnt_key = "penglai5_btn",root_name = "penglai5_root",face = {"Image_dashan"}, floor={"floor_dashan"}, lock_img_name = "penglai5_btn_lock_img", red_point_img = "penglai5_red_point_img", name_key = "penglai5_text", name_text = "awake_system_text_001", open = true},-- 登仙

    [338] = {font_size = 20, root_scale = 1, bnt_key = "heaven_earth_btn",root_name = "heaven_earth_root",face = {"Image_gonghui"}, floor={"floor_gonghui"}, lock_img_name = "heaven_earth_btn_lock_img", red_point_img = "heaven_earth_red_point_img", name_key = "heaven_earth_text", name_text = "heavenEarth_text_001", open = true},-- 天地阁
}

--M.N_COLOR = Color( 184/255, 186/255, 210/255)
--M.S_COLOR = Color( 239/255, 233/255, 240/255)
M.N_COLOR = Color( 255/255, 253/255, 242/255)
--M.N_COLOR = Color( 114/255, 66/255, 12/255)
M.S_COLOR = Color( 0/255, 0/255, 0/255, 180/255)

M.w_COLOR = Color( 255/255, 255/255, 255/255,255/255)
M.b_COLOR = Color( 255/255, 255/255, 255/255,190/255)

function M:onCreate()
    self.m_sliding = false
    self.m_gray_image = self:findImage("gray_image")
    local scroll_view = self:findGameObject("map_scroll")
    self.m_scroll_rect = scroll_view:GetComponent("ScrollRect")
    --self.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
    local bg_scale_w = self.m_control.m_view.m_view_width/GlobalConfig.BG_UI_DESIGN_WIDTH
    local bg_scale_h = 720/GlobalConfig.BG_UI_DESIGN_HEIGHT
    local new_rate = math.max(bg_scale_w , bg_scale_h)
    local m_1 = self:findGameObject("bg_img")
    UIUtil.setLocalScale(m_1.transform, new_rate, new_rate)
    local UI_MainCityNode = self:findGameObject("UI_MainCityNode")
    if UI_MainCityNode then
        UIUtil.setLocalScale(UI_MainCityNode.transform, new_rate, new_rate)
    end
    self:setParticleRenderOrder(self.m_rootView)
    audio:SendEvtUI("Amb_2D_wind_bird_water_frog")
    audio:SendEvtBGM("Set_State_ShiWu01")
    self:setObjectVisible("mystic_btn_finger_sp", false)
    SceneManager:pause()
    SceneManager:getCurSceneModel():setCameraShow(false)
end


function M:clickFunc( id )
    local id_data = UserDataManager.local_data:getUserDataByKey("saveClickFunc"..id)
    if id_data == nil then
        local btn = self.m_btn_lock_img[id]
        if btn ~= nil then
            --[[
            for k_floor,v_floor in ipairs(btn.floor) do
                local face = self:findGameObject(v_floor)
                face:SetActive(false)
            end
            ]]--
            UserDataManager.local_data:setUserDataByKey("saveClickFunc"..id,id)
        end
    end
end

function M:onEnter()
    for k,v in pairs(self.m_btn_lock_img) do
        self:setObjectVisible(v.bnt_key,v.open)
        self:setText(v.name_key,string.cutTextForString(Language:getTextByKey(v.name_text)))
        if v.open then
           -- self:addTriggerEnter(v.bnt_key) 
        end
       
    end
    --self.m_rootView.transform.localScale = Vector3(1,1,1)
    self:setTextByLanKey("close_title_text", "new_str_0015")
    self:refreshUI()
    audio:PauseSkillsBusVol()
    self:playBirdSpine()
    --local base_order = self:findGameObject("base_order")
    --local Image_zhongjingjianzhu = self:findGameObject("Image_zhongjingjianzhu")
    --local spine_shanzhuang = self:findGameObject("spine_shanzhuang")
    --local img_jinjinglou = self:findGameObject("img_jinjinglou")
    --local tips = self:findGameObject("tips")
    --if base_order then
    --    local canvas = base_order:GetComponent("Canvas")
    --    if not IsNull(canvas) then
	--		canvas.sortingOrder = self.m_sortOrder +1
	--	end
    --end
    --if Image_zhongjingjianzhu then
    --    local canvas = Image_zhongjingjianzhu:GetComponent("Canvas")
    --    if not IsNull(canvas) then
	--		canvas.sortingOrder = self.m_sortOrder +2
	--	end
    --end
    --if spine_shanzhuang then
    --    local canvas = spine_shanzhuang:GetComponent("Canvas")
    --    if not IsNull(canvas) then
	--		canvas.sortingOrder = self.m_sortOrder +3
	--	end
    --end
    --if img_jinjinglou then
    --    local canvas = img_jinjinglou:GetComponent("Canvas")
    --    if not IsNull(canvas) then
	--		canvas.sortingOrder = self.m_sortOrder +4
	--	end
    --end
    --if tips then
    --    local canvas = tips:GetComponent("Canvas")
    --    if not IsNull(canvas) then
	--		canvas.sortingOrder = self.m_sortOrder +5
	--	end
    --end
end

function M:setBtnEnter(btn_name)

end

function M:setBtnExit(btn_name)

end

function M:playEffect(data)
    local parent = self:findGameObject(data.root_name);
    local effect = ResourceUtil:GetUIEffectItem("MainCityNode/UI_MainCityNode_heibai_001", parent);
    effect.transform.localPosition = Vector3(0,0,0)
    effect.transform.localScale = Vector3(100,100,100)
    self.m_control:setOnceTimer(3,function()
        U3DUtil:GameObjectDestroy(effect);
    end)
end

function M:refreshUI()
    local OutlineEx = U3DUtil:Get_OutlineEx()
    for k, v in pairs(self.m_btn_lock_img) do
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(k)
        if k == 203 and open_flag == true then
            --珍宝阁 0,1，赛季默认为法宝
            open_flag = self.m_model:checkMagicWeaponOpen()
        elseif k == 190 then
            --古物殿
            open_flag = self.m_model:getShareLv()
        elseif k == 148 then
            --琅嬛阁
            open_flag = UserDataManager.hero_data:checkAnySlotOpen()
        end
        local btn_node = self:findGameObject(v.bnt_key)
        local c_text = self:findText(v.name_key)
        local icon = UIUtil.findImage(btn_node.transform, v.root_name)
        --local red_flag = RedPointUtil:isFuncRedPointById(k) --下面refreshRedPoint会处理
        --self:setObjectVisible(v.red_point_img, red_flag == true)
        --self:setObjectVisible(v.lock_img_name, open_flag == false)
        self:setObjectVisible(v.lock_img_name, false)
        local btn_text = UIUtil.findComponent(btn_node.transform, typeof(OutlineEx), c_text)
        if open_flag == true then
            local old_open_flag = UserDataManager.local_data:getUserDataByKey("MainCity"..k);
            if old_open_flag == false then
                self:playEffect(v)
                --for k_face,v_face in ipairs(v.face) do
                --    local face = self:findGameObject(v_face);
                --    local gray = face:GetComponent("GrayToColor");
                --    gray:StartAnimGray(1);
                --end
                UserDataManager.local_data:setUserDataByKey("MainCity"..k, true)
            else
                --for k_face,v_face in ipairs(v.face) do
                --    local face = self:findGameObject(v_face);
                --    local gray = face:GetComponent("GrayToColor");
                --    gray:SetGray(false);
                --end
            end
            --btn_text.OutlineWidth = 1

            UIUtil.setImg( icon, "a_xy_mingchenghui_BG", "mystic_ui")
            --UIUtil.setImg( icon, "a_zc_mingcheng_newbg", "mystic_ui")
            icon.material = nil
            if c_text then
                c_text.color = self.N_COLOR
            end
            --[[
            local id_data = UserDataManager.local_data:getUserDataByKey("saveClickFunc"..k)
            if id_data == nil then
                for k_floor,v_floor in ipairs(v.floor) do
                    local face = self:findGameObject(v_floor)
                    face:SetActive(true)
                end
            else
                for k_floor,v_floor in ipairs(v.floor) do
                    local face = self:findGameObject(v_floor)
                    face:SetActive(false)
                end
            end
            ]]--
        else
            --UIUtil.setImg(icon, "a_jw_mingchenghui_BG", "main_ui")--暂时保留 当前不用替换图 
           -- btn_text.OutlineWidth = 0
            UIUtil.setImg( icon, "a_xy_mingchenghui_BG", "mystic_ui")
            --UIUtil.setImg( icon, "a_zc_mingcheng_newbg2", "mystic_ui")
            icon.material = self.m_gray_image.material
            if c_text then
                c_text.color = self.S_COLOR
            end
            --icon.color = self.w_COLOR
            --[[
            for k_floor,v_floor in ipairs(v.floor) do
                local face = self:findGameObject(v_floor)
                face:SetActive(false)
            end
            ]]--
        end
        icon:SetNativeSize()
        --local root_scale = v.root_scale
        local font_size = v.font_size
        --UIUtil.setLocalScale(icon.transform, root_scale , root_scale)
        local c_text_gc = c_text:GetComponent("UIFontController")
        c_text_gc.fontSize = font_size
    end
    local chivalry_lock = BtnOpenUtil:isBtnOpen(40)
    -- self:setObjectVisible("change_next", chivalry_lock == true)
    self:setObjectVisible("change_next", false)
    local gacha_ten = self.m_model:gachaFingerCheck()
    --self:setObjectVisible("gacha_figer_sp", gacha_ten)

    --快速导航
    self:setObjectVisible("guide_btn", true)
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    for k, v in pairs(self.m_btn_lock_img) do
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(k)
        if open_flag == true then
            local red_flag = false
            if k == 383 then --蓬莱的威望阁
                local isWei1 = RedPointUtil:hasRedPointById(383, nil)
                local isWei2 = PrestigeUtil:hasNewBlock()
                self:setObjectVisible(v.red_point_img, isWei1 or isWei2)
            elseif k == 417 then --蓬莱的登仙阁
                local awaken_red = UserDataManager:getRedDotByKey("awaken")
                self:setObjectVisible(v.red_point_img, awaken_red > 0)
            else
                red_flag = RedPointUtil:isFuncRedPointById(k)
                self:setObjectVisible(v.red_point_img, red_flag == true)
            end
            --local red_flag = RedPointUtil:isFuncRedPointById(k)
            --self:setObjectVisible(v.red_point_img, red_flag == true)
        else
            self:setObjectVisible(v.red_point_img, false)
        end
    end

    --琅嬛阁 手指
    --local mystic_inset = BtnOpenUtil:isBtnOpen(148) --337
    --if mystic_inset then
    --    local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_city_finger", 1)
    --    self:setObjectVisible("mystic_btn_finger_sp", show_finger == 1)
    --end
end

function M:jumpBuild(open_id)
    --local build_cfg = self.m_btn_lock_img[open_id]
    --if build_cfg then
    --    local map_scroll = self:findGameObject("map_scroll")
    --    local scroll_rect = map_scroll:GetComponent("ScrollRect")
    --    local viewport = self:findGameObject("Viewport")
    --    local view_rect = viewport.transform.rect
    --    local build = self:findGameObject(build_cfg.bnt_key)
    --    local parent = build.transform.parent
    --    local rect = parent.rect
    --    local posx = build.transform.localPosition.x
    --    local value = 0.5 + posx/(rect.width-view_rect.width*0.5)
    --    scroll_rect.horizontalNormalizedPosition = value
    --end
end

function M:fingerSliding(locat)
    if not self.m_sliding then
        return
    end
    if self.m_control:checkHasChild() then
        return
    end
    if locat == true then
        --self:updateMsg("fingerSliding",2)
    elseif locat == false then  
        local chivalry_lock = BtnOpenUtil:isBtnOpen(40)
        if chivalry_lock == true then
            self:updateMsg("fingerSliding",3)
        end
    end
end


function M:playBirdSpine()
    --local rect = self.m_control.m_view.m_rt.rect
    --local rect_righ = (rect.width / 2) + 300
    --local bird_img = self:findGameObject("bird_spine")
    --local trans = bird_img.transform
    --local sequence = Tweening.DOTween.Sequence()
    --sequence:Append(trans:DOLocalMoveX(rect_righ, 25):SetEase(Tweening.Ease.OutSine))
    --sequence:AppendInterval(5)
    --sequence:SetLoops(-1)
end

function M:destroy()
    audio:ResumeSkillsBusVol()
    SceneManager:getCurSceneModel():setCameraShow(true)
    audio:SendEvtUI("Resume_Amb")
    SceneManager:getCurSceneView():setBGMusic()
    M.super.destroy(self)
    SceneManager:continue()
end

return M