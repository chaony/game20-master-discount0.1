local M = class("XianView",LikeOO.OOPopBase)

M.m_uiName = "Xian/Service"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:setObjectVisible("nineActive_rebate_btn",false)
    if SDKUtil.is_gmsdk then
        self:setObjectVisible("player_community_btn", false)
        self:setObjectVisible("recharge_rebate_btn", false)
        local start_time,end_time = self.m_model:getRechargeRebateTime()
        if SDKUtil.sdk_params.app ~= 2 then --ios不开启充值返利活动
            if UserDataManager:getServerTime() >= GameUtil:stringToTimesTamp(start_time) and UserDataManager:getServerTime() <= GameUtil:stringToTimesTamp(end_time) then
                self:setObjectVisible("recharge_rebate_btn", true)
            end
        end
        local application_Id = SDKUtil.sdk_params.applicationId
        if application_Id == "com.hermes.wl" then
            self:setObjectVisible("player_community_btn", true)
        end
        self:setNineActive()
    end
    self:hideTalk()
    self.GameObject3D = self:findGameObject("GameObject3D")
    self:setTextByLanKey("mail_text", "xian_str_0001")
    self:setTextByLanKey("xian_name","xian_str_0015")
    self:setTextByLanKey("bulim_book_text_text","xian_str_0016")
    self:setTextByLanKey("notice_text","xian_str_0017")
    self:setTextByLanKey("player_community_text","xian_str_0018")
    self:setTextByLanKey("haogan_text","xian_str_0019")
    self:setTextByLanKey("vip_btn_text","xian_str_0020")
    self:setTextByLanKey("send_all_gift_text","xian_str_0021")
    self:setTextByLanKey("world_progress_text_text", "tid#OpenConditionName_155")
    self:setTextByLanKey("recharge_rebate_text", "tid#OpenConditionName_195")
    self:setTextByLanKey("common_no_have_text","xian_str_0004")
    self.role_parent = self:findGameObject("role_3d")
    self:setTextByLanKey("close_title_text","new_str_0478")
    self.m_player_talk = self:findGameObject("player_talk")
    self.m_player_talk_anim = self.m_player_talk:GetComponent(typeof(CS.DG.Tweening.DOTweenAnimation));
    self.m_player_talk_isShow = false
    --if self.m_bg_scale ~= 1 then
        -- local bg_node = self:findGameObject("content_node")
        -- UIUtil.setScale(bg_node.transform, self.m_bg_scale)
        --local bg_node = self:findGameObject("Panel")
        --UIUtil.setScale(bg_node.transform, self.m_bg_scale)
    --end
    self:setObjectVisible("player_img", false)
    self:setObjectVisible("add_qq_btn", SDKUtil.is_tencent)
    self:refreshUI()
    self.gift_status_changing = false
    self:updateSendGift(self.m_model.send_gift_status, true)
    --local game_center = U3DUtil:GameObject_Find("GameCenter")
    self.GameObject3D.transform:SetParent(self.m_rootView.transform, false)
    UIUtil.setScale(self.GameObject3D.transform,1,1,1)
    self.action_cache = {}

    --self:creatRole3D()
    self:setSpine(self.m_model.m_skin_id)
end

function M:refreshUI()
    for i = 1 , 7 do
        local reward_icon = self:setObjectVisible("reward_"..i, false)
        local LuaBehaviour = UIUtil.findLuaBehaviour(reward_icon)
        if LuaBehaviour then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "reward_node", false)
        end
    end
    for i,v in ipairs(self.m_model.m_welf_table) do
        if i <= 3 then
            local reward_icon = self:setObjectVisible("reward_"..i, true)
            local LuaBehaviour = UIUtil.findLuaBehaviour(reward_icon)
            if LuaBehaviour then
                local item_data = self.m_model.m_welf_table[i]
                local gifts = item_data.data.gifts
                local creat_ts = os.date("%m月%d日 %H:%M", item_data.data.create_ts) 
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "reward_tim_text", creat_ts)
                if table.nums(gifts) > 0 then
                    LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "reward_node", true)
                    local r_data = RewardUtil:getProcessRewardData(gifts[1])
                    LuaBehaviourUtil.setImg(LuaBehaviour, "reward_img", r_data.icon_name, r_data.atlas_name)
                    LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "reward_num", GameUtil:formatValueToString(r_data.data_num))
                end
            end
        end
    end
    self:resetRedPoint()
    self:updateVipUI()
    self:createLoopScroll()
end

function M:resetRedPoint()
    self:setObjectVisible("notice_point", self.m_model:checkNoticeRedPoint() == true)
    self:setObjectVisible("mail_point", self.m_model:checkMailRedPoint() == true)
    self:setObjectVisible("vip_red_point", RedPointUtil:hasRedPointById(10005) == true)
    self:setObjectVisible("bulim_book_red_point", self.m_model:checkShouceRedPoint() == true)
    local data = self.m_model:getItems()
    self:setObjectVisible("gift_red_point", RedPointUtil:hasRedPointById(10004) == true)
    local curStage = UserDataManager:getCurStage()
    local startStage = self.m_model:getStartStage()
    if curStage >= startStage then
        self:setObjectVisible("world_progress_red_point", RedPointUtil:isFuncRedPointById(155) == true)
    else
        self:setObjectVisible("world_progress_red_point", false)
    end
end

function M:updateVipUI()
    if self.m_model.m_vip >= 10 then
        self:setObjectVisible("xian_lv_num", false)
        self:setObjectVisible("xian_lv_num_1", true)
        self:setObjectVisible("xian_lv_num_2", true)
        local tens = math.floor(self.m_model.m_vip/10) 
        local unit = self.m_model.m_vip - (tens*10)
        self:setImg(tens, "active_ui", "xian_lv_num_1")
        self:setImg(unit, "active_ui", "xian_lv_num_2")
    else
        self:setObjectVisible("xian_lv_num", true)
        self:setObjectVisible("xian_lv_num_1", false)
        self:setObjectVisible("xian_lv_num_2", false)
        self:setImg(self.m_model.m_vip, "active_ui", "xian_lv_num")    
    end
   
    local c_num, next_num = self.m_model:getVipProgress()
    local slider_exp = self:findSlider("slider_img")
    slider_exp.value = c_num/next_num
    if slider_exp.value < 0.15 then
        slider_exp.value = 0.15
    end
    self:setTextByLanKey("exp_num", c_num.."/"..next_num)
end


function M:creatRole3D()
    ResourceUtil:LoadRole3dAsync("A_Xian/A_Xian", self.role_parent, function(obj)
        self.anim = obj:GetComponent("Animator")
        self.xian_con = obj:GetComponent(typeof(CS.XianControll))
        obj.transform:SetParent(self.role_parent.transform, false)	
        obj.transform.localPosition = Vector3(0,0,0)
        obj.transform.localRotation = Quaternion.Euler(0,0,0);
        obj.transform.localScale = Vector3(1, 1, 1)
        if self.action_cache[1] ~= nil then
            self:setAnim(self.action_cache[1])
            self.action_cache[1] = nil
        end
	end, true)
end

function M:createLoopScroll()
    local data = self.m_model:getItems()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local item_data = UserDataManager.item_data:getItemDataById(cell_data)
                local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, cell_data, item_data.num})
                GameUtil:updateItemElementByData(cell_obj, data, true, false, function ()
                    self:updateMsg("send_reward", cell_data)
                end)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
    self:setObjectVisible("no_list", #data <= 0)
end

function M:setAnim(name)
    if self.xian_con then
        self.xian_con:CrossFadeInFixedTime(name,0.1)
    else
        self.action_cache[1] = name
    end
end

function M:showTalk()
    if self.m_player_talk_isShow == false then
        self.m_player_talk_isShow = true
        self.m_player_talk_anim.duration = 0.5
        self.m_player_talk_anim.endValueFloat = 1
        self.m_player_talk_anim.easeType = CS.DG.Tweening.Ease.OutBack
        self.m_player_talk_anim:CreateTween()
        self.m_player_talk_anim.tween:Play()
    end
end

function M:updateWelfares( data )
    if data.guide ~= nil and data.guide > 0 then
        local cfg = self.m_model:getDiaById(data.guide)
        if cfg ~= nil then
            self:talkView(cfg)
        end
    else
        local cfg = 
        {
            ["words"]= data.dialogue,
            ["bank"]="",
            ["vo"]="",
            ["sort"]=0,
            ["stage"]=0,
            ["action"]="",
        }
        self:talkView(cfg)
    end
end

function M:talkView(cfg, reward_talk)
    if self.m_model.m_curShowTime <= 0 then
        self.m_model.m_curShowTime = self.m_model.m_showTime;
        if cfg.words ~= "" then
            self:showTalk();
            self:setObjectVisible("talk_mask_btn", reward_talk and reward_talk == true)
            self:setTextByLanKey("talk_text", cfg.words)
        end

        if cfg.bank ~= "" and cfg.vo ~= "" then
            --播放声音
            self.bank = cfg.bank
            ResourceUtil:LoadRoleSound(cfg.bank)
            audio:StopPlayingID(self.cur_cv)
            self.cur_cv = audio:SendEvtUI(cfg.vo)
        end
        
        if cfg.action ~= "" then
            self:setAnim(cfg.action)
        end
    end
end

function M:hideTalk()
    if self.m_player_talk_isShow == true then
        self.m_player_talk_isShow = false
        self.m_player_talk_anim.duration = 0.5
        self.m_player_talk_anim.endValueFloat = 0
        self.m_player_talk_anim.easeType = CS.DG.Tweening.Ease.InBack
        self.m_player_talk_anim:CreateTween()
        self.m_player_talk_anim.tween:Play()
    end
end

function M:updateSendGift(bl, first)
    if self.gift_status_changing == false then
        self.gift_status_changing = true
        local left_bottom = self:findGameObject("left_bottom")
        local send_gift = self:findGameObject("send_gift")
        if first and first == true then
            self:setObjectVisible("send_gift", false)
            self:setObjectVisible("songli_btn", true)
            self:setObjectVisible("send_mask", false)
            UIUtil.setLocalPosition(left_bottom.transform, 0,-260.2,0)
            UIUtil.setLocalPosition(send_gift.transform, 0,-412,0)
        end
        if bl == true then
            self:setObjectVisible("send_mask", true)
            self:setObjectVisible("songli_btn", false)
            self:setObjectVisible("send_gift", true)
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(left_bottom.transform:DOLocalMoveY(-135, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:Insert(0, send_gift.transform:DOLocalMoveY(-298.5, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:OnComplete(function ()
                self.gift_status_changing = false
            end)
            sequence:SetAutoKill(true)
        else
            local sequence = Tweening.DOTween.Sequence()
            sequence:Append(left_bottom.transform:DOLocalMoveY(-260.2, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:Insert(0, send_gift.transform:DOLocalMoveY(-412, 0.3):SetEase(Tweening.Ease.OutSine))
            sequence:OnComplete(function ()
                self:setObjectVisible("send_gift", false)
                self:setObjectVisible("songli_btn", true)
                self:setObjectVisible("send_mask", false)
                self.gift_status_changing = false
            end)
            sequence:SetAutoKill(true)
        end
    end
end

--添加刷新玩家社区红点
function M:setActiveRedPoint(active_show)
    self:setObjectVisible("player_community_red_point",active_show)
end

--设置九尾活动
function M:setNineActive()
    SDKUtil:openFaceVerify(function(params)
        if params ~= nil and params.data ~= nil then
            NineActiveUtil.icon_click_data = params.data
            NineActiveUtil.active_id = "4001"
            if self.m_model then
                self.m_model.nine_active_data = NineActiveUtil:isHasIconData("4001")
                if self.m_model.nine_active_data then
                    self:setObjectVisible("nineActive_rebate_btn",true)
                    self:setTextByLanKey("nineActive_rebate_text", "tid#JiuWei_01")
                    self:setNineActiveRedPoint()
                end
            end
        end
    end,"icon_click")
end

--设置九尾活动红点
function M:setNineActiveRedPoint()
    if SDKUtil.is_gmsdk and self.m_model.nine_active_data then
        SDKUtil:queryActivityNotifyDataById(function(params)
            if params ~= nil and params.data ~= nil then
                for i, v in ipairs(params.data) do
                    if v.type == 0 then
                        UserDataManager.local_data:setLocalDataByKey("nine_active_4001", 0)
                        self:setObjectVisible("nineActive_rebate_red_point", false)
                    else
                        if v.count > 0 then
                            UserDataManager.local_data:setLocalDataByKey("nine_active_4001", 1)
                            self:setObjectVisible("nineActive_rebate_red_point", true)
                        end
                    end
                end
            end
        end,self.m_model.nine_active_data.activityId)
    end
end

function M:setSpine(skin_id)
    local fenghua_record_skin = ConfigManager:getCfgByName("fenghua_record_skin")
    local select_skin_cfg = fenghua_record_skin[skin_id]
    if select_skin_cfg == nil then
        self:setObjectVisible("hero_spine", false)
        return
    end
    self:setObjectVisible("hero_spine", true)
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(skin_id)
    --spine
    local spine_name = select_skin_cfg.spine or "hero_0001_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --info
    local class_str = Language:getTextByKey(hero_cfg.class)
    local name_str = Language:getTextByKey(hero_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    local race = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
    --local frame_data = GlobalConfig.QUALITY_FRAME[hero_cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(hero_cfg.Ex_hero, hero_cfg.max_evo), "common_ui","hero_evo")
end

function M:destroy()
    local a_xian_ab = "role3d_a_xian"
    ResourceUtil:UnLoadBundle(a_xian_ab, false)
    M.super.destroy(self)
    -- if not IsNull(self.GameObject3D)  then
    --     U3DUtil:Destroy(self.GameObject3D)
    -- end
end

return M