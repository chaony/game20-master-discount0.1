---@class MainView : OOSceneBase
---@field m_model MainModel
local M = class("MainView", LikeOO.OOSceneBase)

M.m_uiName = "Main/Main"
M.m_iphoneXAdapter = true

local __TAB_BTN_NODE = {
    {
        btn_key = "battle_togglebtn",
        lua_name = "UI.Main.MainBattleNode",
        back_text = "battle_back_text",
        check_text = "battle_check_text",
        text_key = "new_str_0014",
        red_point_img = "battle_red_point_img",
        bgm_id = "play_hangup_bgm",
        is_Open = true
    }, -- 上阵
    {
        btn_key = "martial_togglebtn",
        lua_name = "UI.Main.MainCityNode",
        back_text = "martial_back_text",
        check_text = "martial_check_text",
        text_key = "new_str_0015",
        lock_img = "martial_lock_btn",
        red_point_img = "martial_red_point_img",
        btn_id = 39,
        bgm_id = "play_city_bgm",
        is_Open = true
    }, -- 事务
    {
        btn_key = "chivalry_togglebtn",
        lua_name = "UI.Main.MainChivalryNode",
        back_text = "chivalry_back_text",
        check_text = "chivalry_check_text",
        text_key = "new_str_0016",
        lock_img = "chivalry_lock_btn",
        red_point_img = "chivalry_red_point_img",
        btn_id = 40,
        bgm_id = "play_city_bgm",
        is_Open = true
    }, -- 侠义
    {
        btn_key = "grudge_togglebtn",
        lua_name = "UI.Main.MainGrudgeNode",
        back_text = "grudge_back_text",
        check_text = "grudge_check_text",
        text_key = "new_str_0017",
        lock_img = "grudge_lock_btn",
        red_point_img = "grudge_red_point_img",
        btn_id = 41,
        bgm_id = "play_city_bgm",
        is_Open = true
    }, -- 论剑
    {
        btn_key = "hero_togglebtn",
        lua_name = "UI.Main.MainHeroNode",
        back_text = "hero_back_text",
        check_text = "hero_check_text",
        text_key = "new_str_0018",
        red_point_img = "hero_red_point_img",
        btn_id = 42,
        bgm_id = "play_city_bgm",
        is_Open = true
    }, -- 武神
    {
        btn_key = "bag_togglebtn",
        lua_name = "UI.Main.MainBagNode",
        back_text = "bag_back_text",
        check_text = "bag_check_text",
        text_key = "new_str_0107",
        red_point_img = "bag_red_point_img",
        btn_id = 43,
        bgm_id = "play_city_bgm",
        is_Open = true
    } -- 背包
    --{btn_key = "big_world_togglebtn", lua_name = "UI.Main.MainBigWorldNode", back_text = "bag_back_text",  check_text = "bag_check_text", text_key = "new_str_0107", red_point_img = "bag_red_point_img", btn_id = 44 ,bgm_id = 'play_city_bgm', is_Open = true}, -- 大地图
}

local OPEN_BTN_TAB = {
    {btn_key = "hero_btn", text_key = "new_str_0018", open_id = 42, lock = true}, --侠客
    {btn_key = "sect_btn", text_key = "new_str_0015", open_id = 39, lock = true}, --研习-事务
    {btn_key = "task_btn", text_key = "new_str_0360", open_id = 65, lock = true}, --任务
    {btn_key = "bag_btn", text_key = "new_str_0359", open_id = 43, lock = true}, --行囊
    {btn_key = "shop_btn", text_key = "new_str_0024", lock = true}, --商店
    {btn_key = "hotel_btn", text_key = "hotel_text_001", open_id = 473, lock = true}, --酒楼
    --{btn_key = "recycle_btn", text_key = "predestined_str_001", lock = true}, --招募
    {btn_key = "jewel_btn", text_key = "jewel_text_001", open_id = 479, lock = true}, --秘宝
    {btn_key = "tavern_btn", text_key = "new_str_0022", lock = true}, --招募
    {btn_key = "mail_btn", open_id = 69, lock = true}, --邮件
    {btn_key = "friend_btn", open_id = 56, lock = true}, --好友
    {btn_key = "rank_btn", lock = true}, --风云榜
    {btn_key = "big_world_btn", text_key = "new_str_0016", open_id = 40, lock = true}, --江湖
    {btn_key = "total_arena_btn", text_key = "new_str_1027", open_id = 192, show_common_id = 521, lock = true}, --天下
    --{btn_key = "union_btn", open_id = 22, lock = true}, --帮会
    --{btn_key = "rune_scape_btn", text_key = "new_str_0509", open_id = 89, lock = true}, --趣事
    --{btn_key = "pet_btn", text_key = "pengLai_text_004", open_id = 350, lock = true}, --奇兽
    --{btn_key = "hotel_btn", text_key = "new_str_0017", open_id = 350, lock = true} -- 酒楼
}

local __CHAT_CHANNEL = {LOCAL = 1, WORLD = 2, GUILD = 3, PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6,}
local __TAB_CHAT_BTN_NODE = {
	{btn_key = "chat_channel_1", show_text = "new_str_0475", text_key = "chat_channel_text1", channel_tag = __CHAT_CHANNEL.LOCAL}, -- 本地
	{btn_key = "chat_channel_2", show_text = "new_str_0474", text_key = "chat_channel_text2", channel_tag = __CHAT_CHANNEL.WORLD}, -- 世界
	{btn_key = "chat_channel_3", show_text = "new_str_0476", text_key = "chat_channel_text3", channel_tag = __CHAT_CHANNEL.GUILD}, -- 公会
	{btn_key = "chat_channel_4", show_text = "new_str_0477", text_key = "chat_channel_text4", channel_tag = __CHAT_CHANNEL.PRIVATE}, -- 私聊
}

local STAGE_DATA = {
    {prefab = "stage_normal", size = 25},
    {prefab = "stage_boss", size = 45},
    {prefab = "stage_build", size = 115}
}

local CARSOURSEL_NUM = {
    {btn_key = "Image_ca_1", open_id = 39, lock = false,index = 1}, 
    {btn_key = "Image_ca_2", open_id = 40, lock = false,index = 2}, 
    {btn_key = "Image_ca_3", open_id = 22, lock = false,index = 3}, 
    {btn_key = "Image_ca_4", open_id = 42, lock = false,index = 4},
    {btn_key = "Image_ca_5", open_id = 43, lock = false,index = 5}, 
    {btn_key = "Image_ca_6", open_id = 56, lock = false,index = 6}, 
    {btn_key = "Image_ca_7", open_id = 65, lock = false,index = 7}, 
    {btn_key = "Image_ca_8", open_id = 89, lock = false,index = 8}, 
    {btn_key = "Image_ca_9", open_id = 192, lock = false,index = 9}, 
}

function M:onEnter()
    M.super.onEnter(self)
    self.active_gifts_item = {}
    local operating = self:findGameObject("operating")
    self.GridLayoutGroup = operating:GetComponent("GridLayoutGroup")
    --self.GridLayoutGroup.enabled = false
    --self.m_gray_image = self:findImage("gray_img")
    --self:setTextByLanKey("encounter_event_btn_text", "new_str_0556")
    --self:setTextByLanKey("task_btn_text", "new_str_0360")
    --self:setTextByLanKey("bag_btn_text", "new_str_0359")
    --self:setTextByLanKey("mail_btn_text", "mail_str_0016")
    --self:setTextByLanKey("total_arena_btn_text", "new_str_1027")
    --self:setTextByLanKey("hero_btn_text", "new_str_0018")
    --self:setTextByLanKey("rune_scape_btn_text", "world_str_007")
    --self:setTextByLanKey("big_world_btn_text", "new_str_0016")
    --self:setTextByLanKey("sect_btn_text", "new_str_0015")
    --self:setTextByLanKey("bazzar_btn_text", "pengLai_text_001")
    self.m_content_panel = self:findGameObject("content_panel")
    local tab_cls = CustomRequire("UI.Main.MainBattleNode")
    self.m_battle_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    --self.m_activity_panel = self:findGameObject("operating_activity") --
    --self.m_content_up_panel = self:findGameObject("content_up_panel")
    self.open_side_btn = self:findGameObject("open_side_btn")
    self.quest_special_btn_obj = self:findGameObject("quest_special_btn")
    --self.side_obj = self:findGameObject("side_obj")
    --self.rigth_menu_pos = self.side_obj.transform.localPosition
    --local tab_on_hook = CustomRequire("UI.Main.MainOnHookNode")
    self.m_toggle_btns = {}
    local PlayerAttrNode = CustomRequire("UI.Common.PlayerAttrNode")
    self.m_player_attr_node = PlayerAttrNode.new(self.m_control)
	self.isopen = false --右侧侧边栏开启状态
    --self.figer_sp = self:setObjectVisible("figer_sp", false)
	--self.figer_sp = self:setObjectVisible("sect_btn_finger_sp", false)
    self:setObjectVisible("figer_sp", false)
    self:setObjectVisible("sect_btn_finger_sp", false)
	self:packUp()
	self:refreshRedPoint()
	self.cur_bgm_id = 0
	--self:InitMsg()
	self:refreshTabNode()
	self:refreshNewStage()
	local cfg = BtnOpenUtil:getBtnCfg(74)
	self:setTextByLanKey("psq_btn_text", cfg.name)
	self.m_content_node = self:findGameObject("content_node")
	self.m_dotween_anim = self.m_content_node:GetComponent("DOTweenAnimation")
	--self:updateChapterTask()
	self:setFrameVisibleStatus()
	self:initChatToggleNode()
	self:showChatDetailNode()

	self:setTextByLanKey("renshe_text", "axian_name")
    
    self:refreshAxianTtimeTableVisible()
    local axiantimetable_cfg = BtnOpenUtil:getBtnCfg(361)
    if axiantimetable_cfg then
        self:setTextByLanKey("timetable_text", axiantimetable_cfg.name)    
    end

    if self.m_model:canGetDownloadReward() then
        local gift_data = ConfigManager:getCommonValueById(774, {})
        local data = RewardUtil:getProcessRewardData(gift_data[1]) or {}
        self:setTextByLanKey("download_play_tips", "download_play_09", data.data_num or 0, data.name or Language:getTextByKey("download_play_07"))
        
    end
    self:setTextByLanKey("download_play_btn_text", "download_play_01")
    self:setTextByLanKey("redpacket_btn_text", "wind_clouds_red_packet_text_00017")
    
    --轮播
    --self:updateAD()
    --UIUtil:registerDragEvent(self:findGameObject("carousel_loopscroll"), handler(self,self.fingerSliding))
    --self:updateCarouselView()
    --轮播 
    --Logger.logError(GameVersionConfig.Is_BIGGAMEAPP,"小游戏包标识~~~~~~~~~~~~~~~~~~~~~~")
    --打开狗头大侠
    if GameVersionConfig.Is_BIGGAMEAPP and UserDataManager:getGuide()["-100"] == nil then
        self:updateMsg("open_biggame",{id = 1})
    elseif GameVersionConfig.Is_BIGGAMEAPP and UserDataManager:getGuide()["-99"] == nil then
        self:updateMsg("helpdog_btn",{stage = "guide"})
    elseif GameVersionConfig.Is_BIGGAMEAPP and UserDataManager:getGuide()["-98"] == nil then
        self:updateMsg("open_biggame",{id = 2})
    elseif GameVersionConfig.Is_BIGGAMEAPP and UserDataManager:getGuide()["-95"] ~= nil and UserDataManager:getGuide()["-94"] == nil then
        self:updateMsg("open_biggame",{id = 3})
    elseif GameVersionConfig.Is_BIGGAMEAPP and UserDataManager:getGuide()["-94"] ~= nil and UserDataManager:getGuide()["-93"] == nil then
        self:updateMsg("helpdog_btn",{stage = "guide"})
    elseif GameVersionConfig.Is_BIGGAMEAPP and UserDataManager:getGuide()["-93"] ~= nil and UserDataManager:getGuide()["-92"] == nil then
        self:updateMsg("helpdog_btn",{stage = "guide"})
    end
    local open_new_spine_flag = ConfigManager:getCommonValueById(821,0)
    if open_new_spine_flag > 0 then
        local tab_cls = CustomRequire("UI.Main.MainNewYearSpineNode")
        self.m_new_year_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
    end
    self:setObjectVisible("new_year_spine1", open_new_spine_flag > 0)
    self:setObjectVisible("new_year_spine2", open_new_spine_flag > 0)

    --侠客
    --self.m_hero_spine = nil
    --self.heronode_animator = self:findGameObject("hero_node"):GetComponent("Animator")
    --self.isOnce = true
    --self.openL1 = false
    --self.openR1 = false
    self:refreshSpine()

    --背景
    self:refreshBackImg()

    --ad
    --self.m_ad_count = 0
    self.m_ad_index = 1
    self.m_ad_jump_id = 0
end

function M:initChatToggleNode()
	for i,v in ipairs(__TAB_CHAT_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn_key)
		local item = self:findGameObject(v.btn_key)
        self:setTextByLanKey(v.text_key, v.show_text)
		UIUtil.addToggleListener(tog_btn, function(is_on, data)
			if is_on then
				self:updateMsg("chat_tab_btn",v.channel_tag)
				self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_12)
			else
				self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_2)
			end
		end, i, self.m_uiName)
	end
end

function M:showChatDetailNode()
	self:setObjectVisible("chat_node", self.m_model.m_chat_show)
	self:setObjectVisible("chat_btn2", not(self.m_model.m_chat_show))
    self:refreshPrivateChatRedPoint()

    if self.m_model.m_chat_show then
		self:updateMsg("chat_tab_btn",self.m_model.m_cur_channel_id)
	end
end

local chat_cell_offsetY = 22
local chat_content_default_height = 110
function M:updateChatScroll(msgs)
	local data = msgs
	local content_height = 0
    local cell_height_tab = {}
	for i = 1, 5 do
		local chat_cell = self:findGameObject("chat_cell" .. i)
		local cell_data = data[i]
		chat_cell:SetActive(cell_data ~= nil )
		if cell_data then
            local chat_context = cell_data.msg
            local emoji_data = self.m_model:checkMsgIsEmojiGif(cell_data.msg)
            if emoji_data then
                chat_context = Language:getTextByKey(emoji_data.text)
            end
            if cell_data.event == 6 then --单独为红包做的处理
                local cfg = GameUtil:getRedPacketCfg(cell_data.msg)
                if cfg and next(cfg) then
                    chat_context = cfg.name or "红包"
                end
            end
			--"cell_data.msgcell_data.msgcell_data.msgcell_data.msgcell_data.msgcell_data.msgcell_data.msg"--cell_data.msg
			local sender_name = cell_data.name
			if tonumber(cell_data.channel_type)  == __CHAT_CHANNEL.PRIVATE then
				sender_name = cell_data.name
                if cell_data.uid == UserDataManager.user_data:getUserStatusDataByKey("uid") then
                    sender_name = cell_data.target_name
                    sender_name = Language:getTextByKey("new_str_0956", sender_name)
                else
                    sender_name = sender_name .. Language:getTextByKey("new_str_1048")
                end
			end
			local luaBehaviour = UIUtil.findLuaBehaviour(chat_cell)
            local cell_rect = chat_cell:GetComponent("RectTransform")
            local chat_name_text = LuaBehaviourUtil.setText(luaBehaviour, "chat_name_text", sender_name .. ": ")
            chat_name_text.transform:GetComponent('ContentSizeFitter'):SetLayoutHorizontal();
            local name_size = chat_name_text.transform:GetComponent('RectTransform').sizeDelta
            local new_content_width = cell_rect.rect.width - name_size.x
            local chat_context_text = luaBehaviour:FindGameObject("chat_context_text")
            local context_rectform = chat_context_text.transform:GetComponent('RectTransform')
            context_rectform.sizeDelta = Vector2(new_content_width, context_rectform.sizeDelta.y)
            LuaBehaviourUtil.setText(luaBehaviour, "chat_context_text", chat_context)
            chat_context_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
            local text_size = chat_context_text.transform:GetComponent('RectTransform').sizeDelta
            cell_rect.sizeDelta = Vector2(cell_rect.rect.width, text_size.y)
			content_height = content_height + text_size.y
            UIUtil.setLocalPosition( chat_context_text.transform, name_size.x + 3)
            cell_height_tab[i] = math.max(text_size.y, chat_cell_offsetY) 
		end
	end
    self:updateChatCellPos(content_height <= 90, cell_height_tab)
end

function M:updateChatCellPos(is_default_pos, cell_height_tab)
    if is_default_pos then
        local start_pos = chat_content_default_height
        for i = 1, 5 do
            local chat_cell = self:findGameObject("chat_cell" .. i)
            local offsetY = 0
            if i > 1 and cell_height_tab[i - 1] then
                offsetY = cell_height_tab[i - 1]
            end
            local pos_y = start_pos - offsetY
            chat_cell.transform.localPosition = Vector3(chat_cell.transform.localPosition.x, pos_y,0)
            start_pos = pos_y
        end
    else
        local start_pos = -91 + cell_height_tab[#cell_height_tab] - chat_cell_offsetY
        for i =#cell_height_tab, 1, -1 do
            local chat_cell = self:findGameObject("chat_cell" .. i)
            local offsetY = cell_height_tab[i] and cell_height_tab[i] or 0
            offsetY = i == #cell_height_tab and 0 or offsetY
            local pos_y = start_pos + offsetY + chat_content_default_height
            chat_cell.transform.localPosition = Vector3(chat_cell.transform.localPosition.x, pos_y,0)
            start_pos = start_pos +  offsetY
        end
    end
end

function M:refreshPrivateChatRedPoint()
	local is_red = ChatUtil.channel_red_points[4]
	self:setObjectVisible("chat_btn_point_img", is_red)
end

function M:refreshNewStage()
    if BtnOpenUtil:isBtnOpen(108) == false then
        return
    end

    local last_stage, cur_stage = self.m_model:checkNewStage()
    if last_stage ~= nil and last_stage ~= cur_stage then
        --if true then
        self.stage_table = ConfigManager:getCfgByName("stage")
        self.map_table = ConfigManager:getCfgByName("regional_map")

        local length = 500
        local front_length = length
        if self.stage_table[cur_stage].open_rivers ~= 0 then
            front_length = (front_length - STAGE_DATA[3].size) / 2
        elseif self.stage_table[cur_stage].type == 2 then
            front_length = (front_length - STAGE_DATA[2].size) / 2
        else
            front_length = (front_length - STAGE_DATA[1].size) / 2
        end
        local stage = cur_stage

        local next_building = stage
        while (self.stage_table[next_building].next_stage > 0) do
            if self.stage_table[next_building].open_rivers ~= 0 then
                break
            end
            next_building = self.stage_table[next_building].next_stage
        end

        --后面有有效关卡
        if self.stage_table[next_building].open_rivers ~= 0 then
            self.new_stage = ResourceUtil:GetUIItem("Main/MainNewStageNode", self.m_content_node, "ui_prefabs")
            self.all_stage_obj = {}
            local luaBehaviour = self.new_stage:GetComponent("LuaBehaviour")
            local rect = self.new_stage:GetComponent("RectTransform")
            rect.anchoredPosition3D = Vector3.New(0, 0, 0)
            local stage_content = luaBehaviour:FindRectTransform("stage_content")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_head", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_build", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stage_build_tip", false)
            for i = 1, 3 do
                if self.stage_table[stage].last_stage > 0 then
                    stage = self.stage_table[stage].last_stage
                end
            end

            --local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
            --local cfg = UserDataManager.hero_data:getHeroConfigByCid(checknumber(avatar))
            --if cfg then
            --	LuaBehaviourUtil.setImg(luaBehaviour, "head_icon_img", cfg.icon, "hero_head_ui")
            --else
            --	LuaBehaviourUtil.setImg(luaBehaviour, "head_icon_img", "item_icon_wenhao", "item_icon")
            --end
            local hero_node = luaBehaviour:FindRectTransform("HeadNode")
            local user_data = UserDataManager.user_data
            GameUtil:setUserAvatar(hero_node, user_data.user_status, false)

            self.m_player_attr_node:updatePlayerHead_Opt()

            self.m_control:setOnceTimer(
                0.4,
                function()
                    local temp_length = length
                    local count = 1
                    local is_add = true
                    local startStage = stage
                    local index = 0

                    local stages = {}
                    local hide_last_build = next_building == 0

                    for i = 1, 8 do
                        if hide_last_build == true or i ~= 8 then
                            local obj, hasBuilding =
                                self:refreshStage(startStage, stage_content, count, temp_length, index)
                            table.insert(stages, obj)
                            if hasBuilding == true then
                                hide_last_build = true
                            end
                            index = index + 1
                            if is_add then
                                count = count + 1
                            else
                                count = count - 1
                            end
                            if count == 3 then
                                is_add = false
                            elseif count == 0 then
                                is_add = true
                            end

                            if temp_length <= 0 then
                                break
                            else
                                startStage = self.stage_table[startStage].next_stage
                            end
                        end
                    end

                    local head = luaBehaviour:FindRectTransform("hero_head")
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_head", false)

                    local diff = self.stage_table[cur_stage].num - self.stage_table[last_stage].num

                    local start_index = Mathf.Max(0, 4 - diff)
                    if start_index == 0 then
                        head.anchoredPosition3D = stages[1].anchoredPosition3D + Vector3.left * 50
                    else
                        head.anchoredPosition3D = stages[start_index].anchoredPosition3D
                    end
                    head:SetAsLastSibling()
                    self.m_control:setOnceTimer(
                        0.2,
                        function()
                            local sequence = Tweening.DOTween.Sequence()
                            for i = start_index + 1, 4 do
                                sequence:Append(
                                    head:DOMove(stages[i].position, 0.4, false):SetEase(Tweening.Ease.Linear)
                                )
                            end
                            sequence:OnComplete(
                                function()
                                end
                            )
                            sequence:SetAutoKill(true)
                        end
                    )

                    if hide_last_build == false then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_build", true)
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stage_build_tip", true)
                        local map = self.map_table[self.stage_table[next_building].open_rivers]

                        if map ~= nil then
                            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "brand_text", map.name)
                            LuaBehaviourUtil.setTextByLanKey(
                                luaBehaviour,
                                "tip_text",
                                "new_str_0607",
                                map.name,
                                self.stage_table[next_building].num - self.stage_table[cur_stage].num
                            )
                        end
                    end
                end
            )

            self.m_control:setOnceTimer(
                4,
                function()
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "hero_head", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "last_build", false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stage_build_tip", false)
                    for k, v in ipairs(self.all_stage_obj) do
                        ResourceUtil:ReturnItem(v)
                    end
                    self.all_stage_obj = {}

                    local bg = luaBehaviour:FindRectTransform("bg")

                    local sequence = Tweening.DOTween.Sequence()
                    sequence:Append(bg:DOScaleX(0.03, 0.25))
                    local rune = self:findRectTransform("rune_scape_btn")
                    sequence:Append(bg:DOMove(rune.position, 0.15))
                    sequence:OnComplete(
                        function()
                            if self.new_stage ~= nil then
                                if self.all_stage_obj ~= nil then
                                    for k, v in ipairs(self.all_stage_obj) do
                                        ResourceUtil:ReturnItem(v)
                                    end
                                    self.all_stage_obj = {}
                                end
                                ResourceUtil:ReturnItem(self.new_stage)
                                self.new_stage = nil
                            end
                        end
                    )
                    sequence:SetAutoKill(true)
                end
            )
        end
    end
end

function M:refreshStage(stage, parent, count, length, index)
    local cur_stage = UserDataManager:getCurStage()
    local id = 0
    if self.stage_table[stage].open_rivers ~= 0 then
        id = 3
    elseif self.stage_table[stage].type == 2 then
        id = 2
    else
        id = 1
    end
    length = length - STAGE_DATA[id].size
    local hasBuilding = false

    local obj = ResourceUtil:GetUIItem("Main/" .. STAGE_DATA[id].prefab, parent.gameObject, "ui_prefabs")
    table.insert(self.all_stage_obj, obj)
    local stage_rect = obj:GetComponent("RectTransform")
    stage_rect.anchoredPosition3D = Vector3.New(-270 + index * 80, 0, 0)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    if id == 1 or id == 2 then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cur", cur_stage == stage)
        -- LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Main_QiZi_01", cur_stage == stage)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock", cur_stage < stage)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unlock", cur_stage > stage)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stage_img", cur_stage == stage)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "stage_text", self.stage_table[stage].map_point_name)
        --local content = luaBehaviour:FindRectTransform("move_content")
        --content.anchoredPosition3D = Vector3.New(0,-15 + count * 10,0)
        -- stage_rect.anchoredPosition3D =
        --     Vector3.New(stage_rect.anchoredPosition3D.x, stage_rect.anchoredPosition3D.y - 15 + count * 10, 0)
        stage_rect.anchoredPosition3D =
            Vector3.New(stage_rect.anchoredPosition3D.x, 0, 0)
    elseif id == 3 then
        local map = self.map_table[self.stage_table[stage].open_rivers]
        if map ~= nil then
            if map.map_icon ~= "" then
               -- if ResourceUtil:GetSprite(map.map_icon, "main_ui") then
                --     LuaBehaviourUtil.setImg(luaBehaviour, "build_img", "a_gj_guanqia_jinshuizhen", "main_ui2")
                --     -- LuaBehaviourUtil.setImg(luaBehaviour, "build_img", map.map_icon, "main_ui")
                -- else
                --     -- LuaBehaviourUtil.setImg(luaBehaviour, "build_img", map.map_icon, "main_ui2")
                --     LuaBehaviourUtil.setImg(luaBehaviour, "build_img", "a_gj_guanqia_jinshuizhen", "main_ui2")
                -- end
                LuaBehaviourUtil.setImg(luaBehaviour, "build_img", "a_gj_guanqia_jinshuizhen", "main_ui2")
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "brand_text", map.name)

            local gray = luaBehaviour:FindImage("gray")
            local tip_bg = luaBehaviour:FindImage("brand_img")
            if cur_stage < stage then
                tip_bg.material = gray.material
                --LuaBehaviourUtil.setTextColor(luaBehaviour, "brand_text", GlobalConfig.COMMON_COLLOR.COMMON_10)
                LuaBehaviourUtil.setTextColor(luaBehaviour, "brand_text", Color( 255/255, 248/255, 233/255))
                local tip_obj = ResourceUtil:GetUIItem("Main/stage_build_tip", parent.parent.gameObject, "ui_prefabs")
                table.insert(self.all_stage_obj, tip_obj)
                local tip_rect = tip_obj:GetComponent("RectTransform")
                tip_rect.anchoredPosition3D = stage_rect.anchoredPosition3D
                local tip_luaBehaviour = tip_obj:GetComponent("LuaBehaviour")
                LuaBehaviourUtil.setTextByLanKey(
                    tip_luaBehaviour,
                    "tip_text",
                    "new_str_0607",
                    map.name,
                    self.stage_table[stage].num - self.stage_table[cur_stage].num
                )
                LuaBehaviourUtil.setObjectVisible(tip_luaBehaviour, "tip_arrow", cur_stage < stage)
            else
                tip_bg.material = nil
                LuaBehaviourUtil.setTextColor(luaBehaviour, "brand_text", GlobalConfig.COMMON_COLLOR.COMMON_1)
            end
            hasBuilding = cur_stage <= stage
        end
    end

    return stage_rect, hasBuilding
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        if update_key == 1 then
            return
        end
        self:updateMsg(update_key)
    end
end

function M:switchTabByIndex(index)
    index = index or -1
    local btn = self.m_toggle_btns[index]
    if btn then
        btn.isOn = true
    end
end

function M:switchTabNode(index, first_enter)
    self.m_model.m_sel_tab_index = index
    for k, v in pairs(__TAB_BTN_NODE) do
        if k == index then
            self:setObjectVisible(v.check_text, true)
            self:setObjectVisible(v.back_text, false)
        else
            self:setObjectVisible(v.check_text, false)
            self:setObjectVisible(v.back_text, true)
        end
    end
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    local btn_tab = __TAB_BTN_NODE[index]
    if btn_tab.lua_name == "UI.Main.MainCityNode" then
        self.m_battle_node.m_rootView:SetActive(false)
    end
    if btn_tab.lua_name == "UI.Main.MainHeroNode" then
        self.m_model.m_race = 0
    end
    if btn_tab then
        local tab_cls = CustomRequire(btn_tab.lua_name)
        self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
        if btn_tab.bgm_id ~= self.cur_bgm_id then
            self.cur_bgm_id = btn_tab.bgm_id
        end
    end
    self:checkHangUpScene()
end

function M:closeNode()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    self.m_battle_node.m_rootView:SetActive(true)
    self.m_model.m_sel_tab_index = 1
    self:refreshRedPoint()
    self:switchTabByIndex(1)
end

function M:checkHangUpScene(force)
    if SceneManager.curScene then
        if force then
            SceneManager:setData("show_loading_content", false)
            SceneManager:changeScene(SceneManager.SceneID.HangUpScene, nil, force)
        else
            if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
                SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
            end
        end
        SceneManager:scenestart()
    end
end

function M:refreshTabNode()
    for k, v in pairs(OPEN_BTN_TAB) do
        local red_flag = true
        if v.open_id then
            red_flag = BtnOpenUtil:isBtnOpen(v.open_id)
        end
        local btn_obj = self:findGameObject(v.btn_key)
        local mask_obj = self:findGameObject(v.btn_key .. "_mask")
        local back = UIUtil.findImage(btn_obj.transform)
        --local img = UIUtil.findImage(btn_obj.transform, "img")
        if v.text_key then
            self:setTextByLanKey(v.btn_key .. "_text", v.text_key)
        end
        if mask_obj then
            mask_obj:SetActive(red_flag == false or v.lock == false)
        end
        --[[
        if v.show_common_id then
            local reg_day = GameUtil:playerRegisterDays()
            local show_days = ConfigManager:getCommonValueById(521, 0)
            self:setObjectVisible(v.btn_key, reg_day >= show_days)
        end
        if back then
            if red_flag == false or v.lock == false then
                back.color = Color.New(152 / 255, 152 / 255, 152 / 255)
                --img.color = Color.New(152 / 255, 152 / 255, 152 / 255)
            else
                back.color = Color.white
                --img.color = Color.white
            end
        end
        ]]--
    end
    if GameVersionConfig.CLIENT_VERSION == UserDataManager.server_data.review_vsn then
        self:setObjectVisible("total_arena_btn", false)
        self:setObjectVisible("hotel_btn", false)
    end
    local red_flag = BtnOpenUtil:isBtnOpen(102)
    self:refreshGachaTenGuide()
    self:setObjectVisible("renshe_btn", red_flag == true)

    local can_download_reward = self.m_model:canGetDownloadReward()
    self:setObjectVisible("download_play_btn", can_download_reward)
    if can_download_reward then
        local down_play_stage = UserDataManager:getDownloadWhilePlayStage()
        self:setObjectVisible("download_play_img", down_play_stage == 0)
        if down_play_stage ~= 1 then --非倒计时阶段
            self:setTextByLanKey("download_play_btn_text", "download_play_01")
        end
    end
    
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshUI()
    end
    self:refreshBattleNode()
    self:refreshRedPoint()
end

function M:refreshGachaTenGuide()
    local gacha_ten = self.m_model:gachaFingerCheck()
    if gacha_ten then
        if UserDataManager.guide_data.m_is_vaild and not UserDataManager.guide_data:isGuiding() then
            local id = ConfigManager:getCommonValueById(316)
            if UserDataManager.guide_data:setAnyTeamGuide(id) then
                self.m_control.m_guide:checkGuide()
            end
        end
    end
end

function M:refreshBattleNode()
    if self.m_battle_node then
        self.m_battle_node:refreshUI()
    end
end

--刷新创建运营活动
function M:refreshActiveUI()
    self.active_gifts_item = {}
    self.push_gifts_item = {}
    self.choice_gifts_item = {}
    local btn_count = 0
    local act_tab = self.m_model:getShowMainActive()
    local choice_tab = self.m_model:checkChoiceGifts()
    --UIUtil.destroyAllChild(self.m_activity_panel.transform)
    UIUtil.destroyAllChild(self.GridLayoutGroup.transform)
    for i = 1, #act_tab do
        local open_id = act_tab[i]
        local activity_data = BtnOpenUtil:getBtnCfg(open_id)
        if open_id == 414 then  --剑试天下  打破常规
            for k,v in pairs(self.m_model.m_data.actives) do
                if v.open_id == 414 then
                    local full_service_phase_cfg = ConfigManager:getCfgByName("full_service_phase")
                    local stage = v.phase_info.phase or 1
                    if next(full_service_phase_cfg) and stage ~= 0 then
                        activity_data.name = activity_data.name
                        activity_data.icon = full_service_phase_cfg[v.version][stage].icon
                    end
                end
            end
        end
        if activity_data then
            local open_flag = BtnOpenUtil:isBtnOpen(open_id)
			if open_id == 121 then
				if UserDataManager.active_121_end then
					GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
					open_flag = false
				end
            elseif open_id == 371 then --华服共赏，可能因为奖励全部领完而关闭，故此处检查
                if open_flag then
                    open_flag = UserDataManager:getActivesRechargeByOpenId(open_id)
                end    
			end

            local active_data = self.m_model:getOpenActiveData(open_id) or {}
            local red_flag = RedPointUtil:isFuncRedPointById(open_id, active_data.version)
            local sever_flag = self.m_model:checkActiveOpenInMain(open_id)
            if open_flag == true or open_id == 74 then
                btn_count = btn_count + 1
                local act_item = GameUtil:createPrefab("Main/add_activity_btn", self.GridLayoutGroup.transform)
                local red_point = UIUtil.setObjectVisible(act_item.transform, red_flag == true, "red_point")
                local LuaBehaviour = UIUtil.findLuaBehaviour(act_item)
                if open_id == 399 then --九尾活动中心
                    if NineActiveUtil.icon_click_data and NineActiveUtil.icon_click_data[1] ~= nil then
                        local data = NineActiveUtil.icon_click_data[1]
                        SDKUtil:queryActivityNotifyDataById(function(params)
                            --Logger.logError(params,"params~~~~~~~~~~~~~~九尾活动红点")
                            if params ~= nil and params.data ~= nil then
                                for i, v in ipairs(params.data) do
                                    if v.type == 0 then
                                        UIUtil.setObjectVisible(act_item.transform, false, "red_point")
                                    else
                                        if v.count > 0 then
                                            UIUtil.setObjectVisible(act_item.transform, true144 "red_point")
                                        end
                                    end
                                end
                            end
                        end,data.activityId)
                    end
                elseif open_id == 352 then --包饺子
                    local falg = RedPointUtil:hasRedPointById(352)
                    local red_point = UIUtil.setObjectVisible(act_item.transform, red_flag and falg, "red_point")
                elseif open_id == 403 then --风云际会 名扬四海
                    if red_flag == false then
                        local active_data = UserDataManager:getActivesDataByOpenId(407)
                        if active_data then
                            local function netCallback(response)
                                local states = response.status or 0
                                red_flag = states ==1
                                local red_point = UIUtil.setObjectVisible(act_item.transform, red_flag == true, "red_point")
                            end
                            local params = {}
                            params.open_id = active_data.open_id
                            params.vsn = active_data.version
                            self.m_model:getNetData("redbag_red_dot", params, netCallback)
                        else
                            red_flag = false
                            local red_point = UIUtil.setObjectVisible(act_item.transform, red_flag == true, "red_point")
                        end
                    end
                end
                if LuaBehaviour then
                    local function click(obj, name)
                        if open_id == 270 then
                            audio:SendEvtUI("UI_XYZYue")
                        end
                        local name_text = LuaBehaviour:FindText("active_text")
                        self:updateMsg("click_activity_btn", {open_id = open_id, activity_name = name_text.text})
                        --self:updateMsg("click_activity_btn", open_id)
                    end
                    local icon_img = activity_data.icon or "a_gj_hd_wenjuan"
                    local img = LuaBehaviourUtil.setImg(LuaBehaviour, "icon", icon_img, "main_ui2")
                    img:SetNativeSize()
                    if open_id == 87 then
                        local tim = self.m_model:getShowPushTime()
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", tim)
                        table.insert(self.push_gifts_item, {open_id = open_id, obj = act_item})
                    elseif open_id == 76 then
                        local e_tim = self.m_model:getOnlineTime()
                        if e_tim then
                            local d_time = e_tim - UserDataManager:getServerTime()
                            if d_time <= 0 then
                                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_0655")
                            else
                                LuaBehaviourUtil.setTextByLanKey(
                                    LuaBehaviour,
                                    "active_text",
                                    GameUtil:formatTimeBySecond(d_time, 999)
                                )
                            end
                        end
                        table.insert(self.push_gifts_item, {open_id = open_id, obj = act_item})
                    elseif open_id == 23 then
                        local fl_cfg = self.m_model:checkActiveDataByOpenId(23)
                        if fl_cfg then
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", fl_cfg.name)
                        else
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", activity_data.name)
                        end
                    elseif (open_id == 221) or (open_id == 226) or (open_id == 261) or (open_id == 270)then
                        local fl_cfg = self.m_model:checkActiveDataByOpenId(open_id)
                        if fl_cfg then
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", fl_cfg.name)
                        else
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", activity_data.name)
                        end
                    elseif open_id == 280 then
                        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "UI_Main_GuJianRuKou_001", true)
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", activity_data.name)
                    elseif open_id == 414 then
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", activity_data.name)
                    else
                        local fl_cfg = self.m_model:checkActiveDataByOpenId(open_id)
                        if fl_cfg and #fl_cfg.name > 0 then
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", fl_cfg.name)
                        else
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", activity_data.name)
                        end
                    end
                    LuaBehaviour:RegistButtonClick(click)
                    table.insert(self.active_gifts_item, {open_id = open_id, obj = act_item})
                end
            end
        end
    end
    for i = 1, #choice_tab do
        btn_count = btn_count + 1
        local act_item = GameUtil:createPrefab("Main/add_activity_btn", self.GridLayoutGroup.transform)
        local red_point = UIUtil.setObjectVisible(act_item.transform, false, "red_point")
        local LuaBehaviour = UIUtil.findLuaBehaviour(act_item)
        if LuaBehaviour then
            local act_data = choice_tab[i][1]
            local group_id = act_data.group_id
            local function click(obj, name)
                self:updateMsg("click_activity_btn", group_id + 100000)
            end
            local icon_img = act_data.icon or "a_gj_hd_wenjuan"
            local img = LuaBehaviourUtil.setImg(LuaBehaviour, "icon", icon_img, "main_ui2")
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", act_data.main_name)
            img:SetNativeSize()
            LuaBehaviour:RegistButtonClick(click)
            table.insert(self.choice_gifts_item, {open_id = group_id + 100000, obj = act_item, end_ts = act_data.end_ts, main_name =act_data.main_name})
            table.insert(self.active_gifts_item, {open_id = group_id + 100000, obj = act_item})
        end
    end
    
    local game_group_id = self.m_model.m_data.game_group_id or 0
    if game_group_id > 0 then
        btn_count = btn_count + 1
        local act_item = GameUtil:createPrefab("Main/add_activity_btn", self.GridLayoutGroup.transform)
        local luaBehaviour = UIUtil.findLuaBehaviour(act_item)
        if luaBehaviour then
            LuaBehaviourUtil.setImg(luaBehaviour, "icon", "a_gj_hd_changanjishi", "main_ui2")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "new_str_0921")
            local red_flag = RedPointUtil:hasRedPointById(1000001)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", red_flag == true)
            local function click(obj, name)
                self:updateMsg("little_games_btn")
            end
            luaBehaviour:RegistButtonClick(click)
        end
    end

    local open_flag = BtnOpenUtil:isBtnOpen(193)
    if open_flag == true and btn_count < 10 then -- 添加九州排行榜
        btn_count = btn_count + 1
        local act_item = GameUtil:createPrefab("Main/add_activity_btn", self.GridLayoutGroup.transform)
        local luaBehaviour = UIUtil.findLuaBehaviour(act_item)
        if luaBehaviour then
            LuaBehaviourUtil.setImg(luaBehaviour, "icon", "a_gj_hd_jzfyb", "main_ui2")
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "main_btn_text_0001")
            --local red_flag = RedPointUtil:hasRedPointById(1000001)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", false)
            local function click(obj, name)
                audio:SendEvtUI("UI_JZBang")
                self:updateMsg("tianxia_rank_btn")
            end
            luaBehaviour:RegistButtonClick(click)
        end
    end
    
    open_flag = BtnOpenUtil:isBtnOpen(241)
    if open_flag == true then -- 添加玩家回归
        local status, day = self.m_model:checkPlayerBack()
        if status == 1 or (status == 2 and day >= 1 and day <= 7) or (status == 4 and day >= 1 and day <= 7) then--触发了但未选择，或者选择了老服但在七天之内, 或者选择了新服但在七天内
            btn_count = btn_count + 1
            local act_item = GameUtil:createPrefab("Main/add_activity_btn", self.GridLayoutGroup.transform)
            local luaBehaviour = UIUtil.findLuaBehaviour(act_item)
            if luaBehaviour then
                LuaBehaviourUtil.setImg(luaBehaviour, "icon", "a_gj_hd_laowanjiahuigui2", "main_ui2")
                if status == 1 then
                    local day_left, hour_left, min_left, sec_left = self.m_model:getLeftTimeForPlayerBack()
                    if day_left > 0 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "new_str_1074", day_left, hour_left)
                    elseif hour_left > 0 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "new_str_1075", hour_left, min_left)
                    elseif min_left > 0 or sec_left > 0 then
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "new_str_1078", min_left, sec_left)
                    else
                        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "new_str_1076")
                        if self.m_model.m_player_back_status_request_count < 3 then
                            self.m_model.m_player_back_status_request_count = self.m_model.m_player_back_status_request_count + 1
                            self.m_control:updateMsg("common_refresh")
                        end
                    end
                else
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "active_text", "new_str_1076")
                end
                local red_flag = RedPointUtil:hasRedPointById(241)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", red_flag)
                local function click(obj, name)
                    audio:SendEvtUI("UI_JZBang")
                    self:updateMsg("player_back_btn")
                end
                luaBehaviour:RegistButtonClick(click)

                table.insert(self.push_gifts_item, {open_id = 241, obj = act_item})
            end
        end
    end
    
    self:initSideStatus()
    if #self.active_gifts_item > 0 then
        self:setObjectVisible("open_side_btn", true)
    else
        self:setObjectVisible("open_side_btn", false)
    end
end

function M:initSideStatus()
    local hide_show = self.m_model:hideActivesShow()
    if self.m_model.m_side_status == 0 then
        for i, v in pairs(self.active_gifts_item) do
            local index = self:isInTable(v.open_id, hide_show)
            if index ~= 0 then
                -- v.obj.transform.localPosition = pos
                -- local pos = self.m_model:getActivePosByIndex(index)
                v.obj:SetActive(true)
            else
                v.obj:SetActive(false)
            end
        end
        if self.open_side_btn then
            self.open_side_btn.transform.localRotation = Quaternion.Euler(0, 0, 135)
        end
    else
        for i, v in pairs(self.active_gifts_item) do
            v.obj:SetActive(true)
        end
        if self.open_side_btn then
            self.open_side_btn.transform.localRotation = Quaternion.Euler(0, 0, 180)
        end
    end
end

function M:updateSideStatus()
    local hide_show = self.m_model:hideActivesShow()
    if self.m_model.m_side_status == 0 then
        for i, v in pairs(self.active_gifts_item) do
            local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
            if luaBehaviour then
                local icon = luaBehaviour:FindImage("icon")
                local iconbg = UIUtil.findImage(v.obj.transform)
                local red_point = luaBehaviour:FindImage("red_point")
                local text = luaBehaviour:FindText("active_text")
                local num = (#self.active_gifts_item - i) + 1
                local pos = self.m_model:getActivePosByIndex(num)
            -- local sequence = Tweening.DOTween.Sequence()
            -- sequence:Append(v.obj.transform:DOLocalMove(pos,0.2))
            -- sequence:Insert(0, DOTweenModuleUI.DOFade(icon, 1, 0.2))
            -- sequence:Insert(0, DOTweenModuleUI.DOFade(iconbg, 1, 0.2))
            -- sequence:Insert(0, DOTweenModuleUI.DOFade(red_point, 1, 0.2))
            -- sequence:Insert(0, DOTweenModuleUI.DOFade(text, 1, 0.2))
            -- sequence:OnComplete(function()
            -- 	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Main_ShanGuang_002", true)
            -- end)
            end
            v.obj:SetActive(true)
        end
        self.m_model.m_side_status = 1
        if self.open_side_btn then
            self.open_side_btn.transform.localRotation = Quaternion.Euler(0, 0, 180)
        end
    else
        for i, v in pairs(self.active_gifts_item) do
            local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
            if luaBehaviour then
                local icon = luaBehaviour:FindImage("icon")
                local iconbg = UIUtil.findImage(v.obj.transform)
                local red_point = luaBehaviour:FindImage("red_point")
                local text = luaBehaviour:FindText("active_text")
                if self:isInTable(v.open_id, hide_show) ~= 0 then
                    -- local index = self:isInTable(v.open_id, hide_show)
                    -- local pos = self.m_model:getActivePosByIndex(index)
                    -- local sequence = Tweening.DOTween.Sequence()
                    -- sequence:Append(v.obj.transform:DOLocalMove(pos,0.2))
                else
                    -- local sequence = Tweening.DOTween.Sequence()
                    -- sequence:Append(v.obj.transform:DOLocalMove(Vector3(0, 42,0),0.2))
                    -- sequence:Insert(0, DOTweenModuleUI.DOFade(icon, 0, 0.2))
                    -- sequence:Insert(0, DOTweenModuleUI.DOFade(iconbg, 0, 0.2))
                    -- sequence:Insert(0, DOTweenModuleUI.DOFade(red_point, 0, 0.2))
                    -- sequence:Insert(0, DOTweenModuleUI.DOFade(text, 0, 0.2))
                    -- sequence:OnComplete(function()
                    -- 	v.obj:SetActive(false)
                    -- end)
                    -- LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Main_ShanGuang_002", false)
                    v.obj:SetActive(false)
                end
            end
        end
        self.m_model.m_side_status = 0
        if self.open_side_btn then
            self.open_side_btn.transform.localRotation = Quaternion.Euler(0, 0, 135)
        end
    end
    self:refreshAxianTtimeTableVisible()
end

function M:refreshAxianTtimeTableVisible()
    local open_flag = BtnOpenUtil:isBtnOpen(361)
    local real_open = open_flag and self.m_model.m_side_status == 0
    self:setObjectVisible("axian_timetable_btn",real_open)
end

function M:isInTable(a, tab)
    for k, v in pairs(tab) do
        if v == a then
            return k
        end
    end
    return 0
end

function M:refreshRedPoint()
    self:refreshActiveUI()
    for k, v in pairs(
        {
            {"hero_btn_point_img", 42},
            {"bag_btn_point_img", 43},
            {"sect_btn_point_img", 39},
            {"big_word_scape_btn_point_img", 40},
            {"total_arena_btn_point_img", 192},
            {"shop_btn_point_img", 44},
            {"tavern_btn_point_img", 13},
            {"hotel_btn_point_img", 473},
            {"jewel_btn_point_img", 479}
        }
    ) do
        local red_flag = RedPointUtil:isFuncRedPointById(v[2])
        self:setObjectVisible(v[1], red_flag == true)
    end
    for k, v in pairs(
        {
            {"task_red_point_img", 65},
            {"mail_red_point_img", 56},
            --{"rank_red_point_img", 56},
            {"activity_btn_red_point", 23},
            {"psq_btn_red_point", 74}
        }
    ) do
        local red_flag = RedPointUtil:isFuncRedPointById(v[2])
        self:setObjectVisible(v[1], red_flag == true)
    end
    local open_flag = BtnOpenUtil:isBtnOpen(89)
    local jianghu_red_point = RedPointUtil:jiangHuJieSuo()
    self:setObjectVisible("rune_scape_btn_point_img", jianghu_red_point == true and open_flag == true)
    local red_flag = RedPointUtil:hasRedPointById(4600)
    self:setObjectVisible("activity_btn_red_point", red_flag == true)
    local r3_red_flag = RedPointUtil:hasRedPointById(47)
    self:setObjectVisible("recharge_btn_red_point3", r3_red_flag == true)
    if self.m_cur_tab_node then
        self.m_cur_tab_node:refreshRedPoint()
    end
    local nine_active_4001 = UserDataManager.local_data:getLocalDataByKey("nine_active_4001", 0)
    local bl = RedPointUtil:hasRedPointById(10001)
    bl = bl or RedPointUtil:hasRedPointById(10002)
    bl = bl or RedPointUtil:hasRedPointById(10003)
    bl = bl or RedPointUtil:hasRedPointById(10004)
    bl = bl or RedPointUtil:hasRedPointById(10005)
    bl = bl or RedPointUtil:isFuncRedPointById(155)
    bl = bl or nine_active_4001 ~= 0
    self:setObjectVisible("renshe_red_point", bl == true)
    local mystic_inset = BtnOpenUtil:isBtnOpen(337)
    if mystic_inset then
        local show_finger = UserDataManager.local_data:getUserDataByKey("mystic_main_finger", 1)
        self:setObjectVisible("sect_btn_finger_sp", show_finger == 1)
    end
    --local bazaar_btn_red = RedPointUtil:hasRedPointById(350)
    --self:setObjectVisible("bazzar_btn_red_point", bazaar_btn_red)
    self:setObjectVisible("download_play_btn_red_point", false)
    --local red_flag = UserDataManager:getRedDotByKey("redbag")
    --self:setObjectVisible("redpacket_btn_red_point",red_flag ==1)
    local active_data = UserDataManager:getActivesDataByOpenId(407)
    if not active_data then
        self:setObjectVisible("redpacket_btn",false)
    else
        self:setObjectVisible("redpacket_btn",true)
    end
    self:updateMsg("refresh_red_big_point", nil, "parent") --通知主界面
end

function M:updateRedBagPoint(status)
    self:setObjectVisible("redpacket_btn_red_point",status ==1)
end

function M:updateRedBagView(falg)
    local common = ConfigManager:getCfgByName("common")
    local is_open = common[790] and common[790].value or 0 --活动默认关闭
    self:setObjectVisible("redpacket_btn",falg and is_open~=0)
end

--阿闲对话
function M:updateRensheUI()
    local renshe_des_tab = {}
    local bl = RedPointUtil:hasRedPointById(10001)
    local bl2 = RedPointUtil:hasRedPointById(10002)
    local have_goodfellItem = self.m_model:checkGoodFeelRewardsRedPoint()
    if bl == true then
        table.insert(renshe_des_tab, {type = 1, des = "new_str_0599"})
    end
    if bl2 == true then
        table.insert(renshe_des_tab, {type = 1, des = "new_str_0598"})
    end
    if have_goodfellItem == true then
        table.insert(renshe_des_tab, {type = 1, des = "xian_str_0005"})
    end
    local npc_guide_table = self.m_model:getNpcGuide()
    for k, v in pairs(npc_guide_table) do
        table.insert(renshe_des_tab, {type = 2, cfg = v})
    end
    if table.nums(renshe_des_tab) > 0 then
        local random = Mathf.Random(1, table.nums(renshe_des_tab))
        local reshe_data = renshe_des_tab[random]
        if reshe_data then
            if reshe_data.type == 1 then
                self:setObjectVisible("renshe_img", true)
                self:setObjectVisible("active_guide_obj", false)
                self:setTextByLanKey("renshe_tips", reshe_data.des)
            else
                self:setObjectVisible("active_guide_obj", true)
                self:setObjectVisible("renshe_img", false)
                if reshe_data.cfg.icon and #reshe_data.cfg.icon > 0 then
                    self:setImg(reshe_data.cfg.icon, "active_ui", "fun_icon")
                end
                self:setTextByLanKey("fun_name", reshe_data.cfg.name)
                self:setTextByLanKey("fun_count", reshe_data.cfg.dialogue1)
            end
        end
    else
        self:setObjectVisible("renshe_img", false)
        self:setObjectVisible("active_guide_obj", false)
    end
end

function M:hideRensheUI()
    self:setObjectVisible("renshe_img", false)
    self:setObjectVisible("active_guide_obj", false)
end

--任务背包等侧边栏
function M:setActivity(bl)
    self:setObjectVisible("side_obj", bl)
    self:setObjectVisible("left_obj", false)
    --self:setObjectVisible("left_obj",bl)
end

--开始战斗
function M:startGame()
    -- self:retainVisibleView()
    --开始启动AI
    --SceneManager.curScene.plyMgr:playerSpawn()
end

--恢复UI
function M:releaseUI()
    -- self:releaseVisibleView()
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "battle_togglebtn" then
        self.m_cur_tab_node:refreshUI()
    end
end

--英雄界面切换页签
function M:switchTabForHeroNode(data)
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "hero_togglebtn" then
        self.m_cur_tab_node:checkTog(data)
    end
end

--道具界面切换页签
function M:switchTabForBagNode(index)
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "bag_togglebtn" then
        self.m_model:refreshBagListData(index)
        self.m_cur_tab_node:switchTabNode(index)
    end
end

--恩怨界面切换页签
function M:switchTabForGrudge(data)
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "grudge_togglebtn" then
        self.m_cur_tab_node:switchTabNode(data)
    end
end

--更新英雄-编队
function M:updateHero_bd()
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "hero_togglebtn" then
        self.m_cur_tab_node:updateBdLoopScroll()
    end
end

function M:setBtnEnter(btn_name)
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "martial_togglebtn" then
        self.m_cur_tab_node:setBtnEnter(btn_name)
    end
end

function M:setBtnExit(btn_name)
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "martial_togglebtn" then
        self.m_cur_tab_node:setBtnExit(btn_name)
    end
end

--更新英雄-格子数量
function M:updateHero_gz()
    if self.m_model.m_sel_tab_index and __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "hero_togglebtn" then
        self.m_cur_tab_node:refreshHero_Grid()
    end
end

--侧边栏动画
function M:packUp()
    local jiantou = self:findImage("jiantou")
    if self.isopen == true then
        self.m_luaBehaviour:RunAnim("Main_Right2", handler(self, self.endCallFunc), 1)
        self:setImg("a_gj_btn_up", "main_ui2", "jiantou")
        self.isopen = false
    else
        self.m_luaBehaviour:RunAnim("Main_Right1", handler(self, self.endCallFunc), 1)
        self:setImg("a_gj_btn_down", "main_ui2", "jiantou")
        self.isopen = true
    end
end

function M:playGetRewardSpine()
    self.m_battle_node:playGetRewardSpine()
end

function M:endCallFunc()
end

function M:updateHook()
    if self.m_on_hook_node then
        self.m_on_hook_node:refreshUI()
    end
end

function M:releaseVisibleView()
    M.super.releaseVisibleView(self)
    if self.m_model.m_sel_tab_index then
        if __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "chivalry_togglebtn" or
                __TAB_BTN_NODE[self.m_model.m_sel_tab_index].btn_key == "grudge_togglebtn"
        then
            self.m_cur_tab_node:refreshUI()
        end
    end
end

-- 网络回来的刷新
function M:netRefreshEvent(event, data)
    Logger.log("=== netRefreshEvent ===")
end

function M:destroy()
    EventDispatcher:unRegisterEvent("main_encounter_event_btn_timer")
    if self.new_stage ~= nil then
        if self.all_stage_obj ~= nil then
            for k, v in ipairs(self.all_stage_obj) do
                ResourceUtil:ReturnItem(v)
            end
            self.all_stage_obj = {}
        end
        ResourceUtil:ReturnItem(self.new_stage)
        self.new_stage = nil
    end
    if self.m_player_attr_node then
        self.m_player_attr_node:destroy()
        self.m_player_attr_node = nil
    end
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
    if self.m_battle_node then
        self.m_battle_node:destroy()
        self.m_battle_node = nil
    end
    M.super.destroy(self)
end

function M:bagAction()
    if self.m_bag_action ~= true then
        self.m_bag_action = true
        local bag_togglebtn = self:findGameObject("bag_btn")
        local sequence = Tweening.DOTween.Sequence()
        sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.2, 0.05))
        sequence:Append(bag_togglebtn.transform:DOScale(1.0, 0.05))
        sequence:OnComplete(
            function()
                self.m_bag_action = false
            end
        )
        sequence:SetAutoKill(true)
    end
    if self.creat_bag_ef ~= true then
        self.creat_bag_ef = true
        local bao_ef = self:getEffectByReward()
        self.m_control:setOnceTimer(
            3,
            function()
                U3DUtil:Destroy(bao_ef)
                self.creat_bag_ef = false
            end
        )
    end
end

function M:getEffectByReward()
    local bag_togglebtn = self:findGameObject("bag_btn")
    local yanwu = ResourceUtil:GetUIEffectItem("Main/UI_Main_Bao_002", bag_togglebtn)
    return yanwu
end

--刷新主界面的聊天内容

function M:RefreshChatInfo()
    self:refreshChatRedPoint()
    if self.chat_sc_list_view == nil then
        return
    end
    local msgs = ChatUtil.msgs -- 聊天管理器中的聊天数据
    self.chat_sc_list_view:SetListItemCount(#msgs, false)
    self.chat_sc_list_view:MovePanelToItemIndex(#msgs - 1, 0)
end

function M:refreshChatRedPoint()
    local red_flag = RedPointUtil:isFuncRedPointById(103)
    self:setObjectVisible("chat_btn_point_img", red_flag == true)
end

function M:InitMsg()
    -- if self.chat_sc_list_view ~= nil then
    -- 	self:RefreshChatInfo()
    -- 	return
    -- end
    -- local msgs = ChatUtil.msgs -- 聊天管理器中的聊天数据
    -- self.chat_sc_list_view = self:findGameObject('chat_sc'):GetComponent('LoopListView2')
    -- self.chat_sc_list_view:InitListView(#msgs,function(list, index)
    -- 	local msgs = ChatUtil.msgs -- 聊天管理器中的聊天数据
    -- 	if index < 0 or index>#msgs then
    -- 		return nil
    -- 	end
    -- 	local msg_data = msgs[index+1]
    -- 	local item
    -- 	item = list:NewListViewItem('text')
    -- 	local luaBehaviour = item:GetComponent('LuaBehaviour')
    -- 	local other_rt = item:GetComponent('RectTransform')
    -- 	local other_text =item:GetComponent('Text')
    -- 	other_text.text = '<color=yellow>'..msg_data.name..':</color>'
    -- 	if msg_data.channel_type == "3" then
    -- 		LuaBehaviourUtil.setImg(luaBehaviour,"chat_channel_img","a_gj_pindao_shijie","main_ui")
    -- 		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text", "new_str_0476")
    -- 		other_text.text = other_text.text .. "<color=#66F470>" .. msg_data.msg .. "</color>"
    -- 	elseif msg_data.channel_type == "4" then
    -- 		LuaBehaviourUtil.setImg(luaBehaviour,"chat_channel_img","a_gj_pindao_xit","main_ui")
    -- 		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text","new_str_0477")
    -- 		other_text.text = other_text.text .. "<color=#82ADED>" .. msg_data.msg .. "</color>"
    -- 	else
    -- 		other_text.text = other_text.text .. msg_data.msg
    -- 		if msg_data.channel_type == "1" then
    -- 			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text","new_str_0475")
    -- 		else
    -- 			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"chat_channel_text","new_str_0474")
    -- 		end
    -- 	end
    -- 	other_text:GetComponent('ContentSizeFitter'):SetLayoutVertical();
    -- 	local y = other_text:GetComponent('RectTransform').sizeDelta.y ;
    -- 	other_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), y)
    -- 	if not item.IsInitHandlerCalled then
    -- 		item.IsInitHandlerCalled = true
    -- 	end
    -- 	return item
    -- end)
    -- self.chat_sc_list_view:MovePanelToItemIndex(#msgs-1, 0)
end

function M:playChallengeSpine()
    --self:lockTouch("challenge")
    --self.tongjiling_bg:SetActive(true)
    --local animation = self.tongjiling_spine:GetComponent("SkeletonGraphic")
    --animation.Skeleton:SetToSetupPose()
    --animation.AnimationState:ClearTracks()
    --animation.AnimationState:SetAnimation(0,"animation", false)
    --local function timeCall()
    --	self:updateMsg("challenge_btn_end")
    --end
    --self.m_control:setOnceTimer(0.7,timeCall)
end

function M:closeCallengeSpine()
    --self.tongjiling_bg:SetActive(false)
    --self:unlockTouch("challenge")
end

function M:playOutAnim()
    --if self.m_dotween_anim then
    --self.m_dotween_anim:DORestart()
    --self.m_player_attr_node:playOutAnim()
    --end
end

function M:playEnterAnim()
    --if self.m_dotween_anim then
    --self.m_dotween_anim:DOPlayBackwards()
    --self.m_player_attr_node:playEnterAnim()
    --end
end

function M:playTiaoZhan()
    if self.m_battle_node then
        self.m_battle_node:playTiaoZhan()
    end
end

function M:updateTime(dt, server_time)
    if self.push_gifts_item then
        for k, v in pairs(self.push_gifts_item) do
            if v.open_id == 76 then
                local e_tim = self.m_model:getOnlineTime()
                if e_tim then
                    local d_time = e_tim - server_time
                    local LuaBehaviour = UIUtil.findLuaBehaviour(v.obj)
                    if d_time <= 0 then
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_0655")
                    else
                        LuaBehaviourUtil.setTextByLanKey(
                            LuaBehaviour,
                            "active_text",
                            GameUtil:formatTimeBySecond(d_time, 999)
                        )
                    end
                end
            elseif v.open_id == 87 then
                local end_time = self.m_model:getShowPushTime()
                if end_time then
                    local LuaBehaviour = UIUtil.findLuaBehaviour(v.obj)
                    if LuaBehaviour then
                        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", end_time)
                    end
                end
            elseif v.open_id == 241 then
                local LuaBehaviour = UIUtil.findLuaBehaviour(v.obj)
                if LuaBehaviour then
                    if UserDataManager.comeback_status == 1 then
                        local day_left, hour_left, min_left, sec_left = self.m_model:getLeftTimeForPlayerBack()
                        if day_left > 0 then
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_1074", day_left, hour_left)
                        elseif hour_left > 0 then
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_1075", hour_left, min_left)
                        elseif min_left > 0 or sec_left > 0 then
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_1078", min_left, sec_left)
                        else
                            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_1076")
                            if self.m_model.m_player_back_status_request_count < 3 then
                                self.m_model.m_player_back_status_request_count = self.m_model.m_player_back_status_request_count + 1
                                self.m_control:updateMsg("common_refresh")
                            end
                        end
                    else
                        --LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "active_text", "new_str_1076")
                        --local red_flag = RedPointUtil:hasRedPointById(241)
                        --LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point", red_flag)
                    end
                end
            end
        end
    end
    if self.choice_gifts_item then
        for group_id, v in pairs(self.choice_gifts_item) do
            local end_time = v.end_ts
            if end_time then
                local d_time = end_time - server_time
                if d_time > 0 then
                    local time_str = GameUtil:formatTimeBySecond(d_time, 999)
                    local LuaBehaviour = UIUtil.findLuaBehaviour(v.obj)
                    if LuaBehaviour then
                        local act_name = Language:getTextByKey( v.main_name)
                        act_name = act_name .. "\n" .. time_str
                        LuaBehaviourUtil.setText(LuaBehaviour, "active_text", act_name)
                    end
                else
                    self.m_control:updateMsg("common_refresh")
                end
            end
        end
    end
    if self.m_battle_node and self.m_battle_node.switchBoxType then
        self.m_battle_node:switchBoxType(server_time)
    end
    
    if self.m_model:canGetDownloadReward() and UserDataManager:getDownloadWhilePlayStage() == 1 then
        local time_remain = UserDataManager:getDownloadWhilePlayRemainTime()
        local time_remain_str = GameUtil:formatTimeBySecond(time_remain, 999)
        self:setText("download_play_btn_text", time_remain_str)
        
        time_remain = time_remain - 1
        UserDataManager:setDownloadWhilePlayRemainTime(time_remain)
        if time_remain <= 0 then
            UserDataManager:setDownloadWhilePlayStage(2)
            self:setTextByLanKey("download_play_btn_text", "download_play_01")
        end
    end

    --self:updateAD()
end

function M:visibleEncounterEventBtn(show_flag)
    local open_flag = BtnOpenUtil:isBtnOpen(89)
    --show_flag = show_flag and open_flag
    show_flag = false
    self.m_model.m_encounter_event_btn_show_flag = show_flag
    self:setObjectVisible("encounter_event_btn", show_flag)
    local new_ongoing_teams_max_time = UserDataManager.new_ongoing_teams_max_time or 0
    if show_flag then
        EventDispatcher:registerTimeEvent(
            "main_encounter_event_btn_timer",
            function()
                self.m_model.m_encounter_event_btn_show_flag = false
                self:setObjectVisible("encounter_event_btn", false)
            end,
            new_ongoing_teams_max_time,
            new_ongoing_teams_max_time
        )
    end
end

function M:playEncounterEventSound()
    if self.m_model.m_encounter_event_btn_show_flag then
        audio:SendEvtUI("UI_QiYu")
    end
end

function M:updateChapterTask()
    if self.m_battle_node then
        self.m_battle_node:updateChapterTask()
    end
    --[[
    GameUtil:updateQuestSpecialNode(self, 1)
    local btn_show = BtnOpenUtil:isBtnOpen(134)
    btn_show = false
    if not IsNull(self.quest_special_btn_obj) then
        local rwdNode = self:findGameObject("quest_special_reward_node")
        rwdNode:SetActive(false)
        local rwdNodeTrans = rwdNode.transform
        local nodeTrans = nil --rwdNodeTrans:Find("ItemNode(Clone)")
        for i = 0, rwdNodeTrans.childCount - 1 do
            local testTran = rwdNodeTrans:GetChild(i)
            if testTran.gameObject.name == "ItemNode(Clone)" then
                nodeTrans = testTran
            end
        end

        -------------------
        local lightVal = 0
        local chapter_quest = UserDataManager:getChapterQuestSpecialData(1, nil)
        local chapter_quest_first = chapter_quest[1]
        if chapter_quest_first then
            if chapter_quest_first.status == 2 then -- 完成可领取
                lightVal = 1
            end
        end
        -------------------

        if nodeTrans then
            self.quest_special_btn_obj:SetActive(btn_show)
            local optObj = self:findGameObject("quest_special_reward_node_opt")
            if btn_show then
                -- self.m_control:setOnceTimer(0.0, function()
                local itemroot = nodeTrans.gameObject
                local item_lua = UIUtil.findLuaBehaviour(itemroot)
                local baseImg = item_lua:FindImage("quality_img")
                local iconImg = item_lua:FindImage("item_img")
                local mat = optObj.transform:GetComponent("MaterialInstance")
                mat:SetImg("_MainTex", baseImg)
                mat:SetImg("_ItemTex", iconImg)
                -- mat:SetVector_ImgScale("_ItemScale", iconImg, 84)
                local textRect = iconImg.sprite.textureRect
                local scaleX = textRect.width / 84
                local scaleY = textRect.height / 84
                if (scaleX > scaleY) then
                    if (scaleX > 1.) then
                        scaleY = scaleY / scaleX
                        scaleX = 1.0
                    end
                else
                    if scaleY > 1.0 then
                        scaleX = scaleX / scaleY
                        scaleY = 1.0
                    end
                end
                mat:SetVector("_ItemScale", scaleX, scaleY, 1, 1)
                -- set reward num text
                local newTxtObj = self:findGameObject("quest_special_num")
                local numOutTxt = newTxtObj.transform:GetComponent("Text")
                local numTxt = item_lua:FindText("count_text")
                numOutTxt.text = numTxt.text
                local selfActive = numTxt.gameObject.activeSelf
                newTxtObj:SetActive(selfActive)
                optObj:SetActive(true)
                mat:SetVector("_RewardColor", lightVal, 1, 1, 1)
            else
                optObj:SetActive(false)
            end
        end
    end
    ]]--
end

function M:showChapterVerse()
    if self.m_battle_node then
        self.m_battle_node:showChapterVerse()
    end
end

function M:setFrameVisibleStatus()
    self:setObjectVisible("frame_text", false)
    if GameMain.screen_effect then
        GameMain.screen_effect:setFrameVisibleStatus(false)
    end
end

function M:playCombatUpAnim()
    if self.m_player_attr_node then
        self.m_player_attr_node:refreshCombat()
    end
end

function M:updateMedal()
    if self.m_player_attr_node then
        self.m_player_attr_node:updateMedal()
    end
end

-- 添加轮播广告
function M:updateAD()
    local ads = self.m_model:getCarsourelActiveData()
    if ads == nil or #ads == 0 then
        --local ad_img = self:findImage("ad_img")
        --GameUtil:updateResourcesImg( ad_img, "Texture/carousel/banner1")
        --self:setObjectVisible("ad_img",false)
        for i = 1, 9 do
            self:setObjectVisible("ad_point_" .. i,false)
        end
        return
    end
    self.m_ad_index = self.m_ad_index + 1
    if self.m_ad_index > #ads then
        self.m_ad_index = 1
    end
    local ad = ads[self.m_ad_index]
    self.m_ad_jump_id = ad.jump_id
    self:setObjectVisible("ad_img",true)
    local ad_img = self:findImage("ad_img")
    --ad_img.setActive(true)
    GameUtil:updateResourcesImg( ad_img, "Texture/carousel/" .. ad.icon)
    --point
    for i = 1, 9 do
        if i > #ads then
            self:setObjectVisible("ad_point_" .. i,false)
        else
            self:setObjectVisible("ad_point_" .. i,true)
            self:setImg(self.m_ad_index == i and "a_dfbhz_lbt_jindian" or "a_dfbhz_lbt_heidian","maze_stage_ui", "ad_point_" .. i)
        end
    end
end

--[[
function M:updateCarouselView()
    self.m_model.m_current_carousel_num = 1
    self.m_model.m_all_carousel_num = #self.m_model:getCarsourelActiveData() or 0
    self:setObjectVisible("carousel_view",self.m_model.m_all_carousel_num>0)
    --特殊处理一个点点
    self:setObjectVisible("carousel_dian",self.m_model.m_all_carousel_num >1)
    if self.m_model.m_all_carousel_num<=0 then return end
    self:createCarouselLoopScroll()

    self:setObjectVisible("carousel_view",false)
end

--刷新商店scroll
function M:createCarouselLoopScroll()
    self.before_pos = Vector2.zero
    self.move_flag = false
    local data = self.m_model:getCarsourelActiveData()
    --local data = {{openId = 39,icon = "a_dfbhz_lbt_tupian"},{openId = 39,icon = "a_dfbhz_lbt_tupian - 1"},{openId = 39,icon = "a_dfbhz_lbt_tupian - 2"},{openId = 39,icon = "a_dfbhz_lbt_tupian - 3"}}
    self:InitCarsouelPoint(data)
    if self.m_loop_scroll_view == nil then
        self.m_gift_tab = {}
        local loopscroll = self:findGameObject("carousel_loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
            one_line_count = 1,
            init_cell = function(index, cell_obj)
                --self:InitObj(index,cell_obj)
            end,
            update_cell =function(index, cell_obj, cell_data)
                self:updateCell(index,cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("set_click_carsourel",cell_data)
            end,
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
        self.m_loop_scroll_view.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
        GameMain.addUpdate("MainCarsourel_update" , handler(self, self.posUpdate))
        self.offset_pos = self.m_loop_scroll_view:getContentOffset()
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end
function M:updateCell(index,cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local icon = luaBehaviour:FindGameObject("Img_main")
        GameUtil:updateResourcesImg(icon,"Texture/carousel/" .. cell_data.icon)
    end
end

function M:fingerSliding(locat)
    if locat then
        self:updateMsg("sliding_right")
    else
        self:updateMsg("sliding_left")
    end
end
function M:UpdateCurrentCarouselCell()
    --修改scrool 位置
    if self.m_loop_scroll_view ~= nil then
        self.m_loop_scroll_view:moveToCellIndex(self.m_model.m_current_carousel_num or 1)
    end
    --修改点点位置
    for k,v in ipairs(CARSOURSEL_NUM) do 
        if v.lock == true then 
            if self.m_model.m_current_carousel_num == v.index then
                self:setImg("a_dfbhz_lbt_jindian","maze_stage_ui",v.btn_key)
            else
                self:setImg("a_dfbhz_lbt_heidian","maze_stage_ui",v.btn_key)
            end
        end
    end
    self.offset_pos = self.m_loop_scroll_view:getContentOffset()
end

function M:onValueChanged(pos)
    if math.floor(self.before_pos.x*100) ~= math.floor(pos.x*100) then
        --self.move_flag = true
        self.before_pos.x = pos.x
        self.before_pos.y = pos.y
        --self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num + 1
        --self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num%self.m_model.m_all_carousel_num
        --self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num == 0 and self.m_model.m_all_carousel_num or self.m_model.m_current_carousel_num
        --self:UpdateCurrentCarouselCell()
        --self:updateCells()
    end
end
-- flag == true  右  falg ==false 左
function M:moveToIndex(flag)
    if flag == true then
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num + 1
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num%self.m_model.m_all_carousel_num
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num == 0 and self.m_model.m_all_carousel_num or self.m_model.m_current_carousel_num
    elseif flag == false then
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num -1 >=1 and self.m_model.m_current_carousel_num -1 or 1
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num%self.m_model.m_all_carousel_num
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num == 0 and self.m_model.m_all_carousel_num or self.m_model.m_current_carousel_num
    else
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num 
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num%self.m_model.m_all_carousel_num
        self.m_model.m_current_carousel_num = self.m_model.m_current_carousel_num == 0 and self.m_model.m_all_carousel_num or self.m_model.m_current_carousel_num
    end
    self:UpdateCurrentCarouselCell()
    self:updateMsg("set_timer",nil)
end

function M:posUpdate()
    if self.m_loop_scroll_view and not IsNull(self.m_loop_scroll_view.m_loop_scroll_view) and self.m_loop_scroll_view.m_loop_scroll_view.dragFlag == false then
        if self.move_flag then
            local offset_pos = self.m_loop_scroll_view:getContentOffset()
            if self.offset_pos.x - offset_pos.x > 0 then
                --特殊处理最右侧
                if self.m_model.m_current_carousel_num == self.m_model.m_all_carousel_num then
                    if math.abs(self.offset_pos.x - offset_pos.x) > 80/2 then
                        self.m_model.m_current_carousel_num = 1
                        self:moveToIndex()
                    else
                        self:moveToIndex()
                    end
                    return
                end
                if math.abs(self.offset_pos.x - offset_pos.x) < 420/2 then
                    self:moveToIndex()
                    self.move_flag = false
                else
                    self:moveToIndex(true)
                    self.move_flag = false
                end
            else
                if math.abs(self.offset_pos.x - offset_pos.x) < 420/2 then
                    self:moveToIndex()
                    self.move_flag = false
                else
                    self:moveToIndex(false)
                    self.move_flag = false
                end
            end
        end
    else
        self.move_flag = true
    end
end

function M:InitCarsouelPoint(data)
    self.m_point_data= {}
    for i= 1,#CARSOURSEL_NUM do
        if i<=#data then
            CARSOURSEL_NUM[i].lock = true
            self:setObjectVisible(CARSOURSEL_NUM[i].btn_key,true)
        else
            CARSOURSEL_NUM[i].lock = false
            self:setObjectVisible(CARSOURSEL_NUM[i].btn_key,false)
        end
    end
end
]]--

--侠客
--[[
    @desc: 英雄动画
]]
function M:refreshSpine(id)
    if id == nil then
        id = self.m_model.m_set_hero_id
    end
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(id)
    if cfg == nil then
        self:setObjectVisible("hero_spine", false)
        return
    end
    local skin_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = nil}, cfg)
    local spine_name = skin_cfg.hero_spine or "hero_0001_SkeletonData"
    --spine
    self:setObjectVisible("hero_spine", true)
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
    --evo
    --local frame_data = GlobalConfig.QUALITY_FRAME[cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui","hero_evo")
    --name
    local class_str = Language:getTextByKey(cfg.class)
    local name_str = Language:getTextByKey(skin_cfg.name)
    self:setTextByLanKey("hero_name", name_str)
    self:setTextByLanKey("hero_name2", class_str)
    --race
    local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon
    self:setImg(race,  ResourceUtil:getLanAtlas(), "hero_race")
end

function M:refreshBackImg(imgName)
    if imgName == nil then
        imgName = self.m_model.m_set_back_img
    end
    --self:setObjectVisible("back_img", true)
    self:setObjectVisible("back_spine", false)
    self:setObjectVisible("back_spine5", false)
    local back_image = self:findImage("back_img")
    GameUtil:updateResourcesImg( back_image, "Texture/".. imgName)
    if imgName == "main_bg1" then
        --self:setObjectVisible("back_img", false)
        self:setObjectVisible("back_spine", true)
        --local spine_img = self:findGameObject("back_spine")
        --GameUtil:updateSpineLoadSet(spine_img, "Spine/" .. imgName .. "_SkeletonData", "", 0, true)
        return
    end
    if imgName == "main_bg5" then
        self:setObjectVisible("back_spine5", true)
        return
    end
end

function M:showMainUI(isShow)
    self:setObjectVisible("TL", isShow)
    self:setObjectVisible("BL", isShow)
    self:setObjectVisible("R", isShow)
    self:setObjectVisible("BR", isShow)
    self:setObjectVisible("hero_name_con", isShow == false)
    self.m_battle_node.m_rootView:SetActive(isShow)
    self.m_player_attr_node.m_rootView:SetActive(isShow)
end

function M:refreshSceneTexture()
    --恢复挂机texture
    if self.m_battle_node then
        self.m_battle_node:refreshSceneTexture()
    end
end

return M