--- 英雄
local M = class("MainHeroNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainHeroNode"
M.m_iphoneXAdapter = true

function M:onCreate()
    self.m_race = self.m_model.m_race --种族
    self.m_type = self.m_model.m_pro --属性类型
    self.m_transfer = "scale"
end

M.COMMON_COLLOR_1 =  Color( 252/255, 255/255, 242/255, 1)
M.COMMON_COLLOR_2 =  Color( 156/255, 214/255, 218/255, 1)

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "new_str_0364" , red_point_img = "battle_red_point_img"}, -- 武神
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "new_str_0150" , red_point_img = "battle_red_point_img"}, -- 图鉴
}

M.USE_TAB_ = {
    {"UI_Main_TiShi_Lan"}, --1
    {"UI_Main_TiShi_Lan"}, --2
    {"UI_Main_TiShi_Lan"}, --3
    {"UI_Main_TiShi_Lan"}, --4
    {"UI_Main_TiShi_Zi"}, --5 
    {"UI_Main_TiShi_Zi"}, --6
    {"UI_Main_TiShi_Huang"}, --7
    {"UI_Main_TiShi_Huang"}, --8
    {"UI_Main_TiShi_Hong"}, --9
    {"UI_Main_TiShi_Hong"}, --10
    {"UI_Main_TiShi_Cai"}, --11
    {"UI_Main_TiShi_Cai"}, --12
    {"UI_Main_TiShi_Cai"}, --13
    {"UI_Main_TiShi_Cai"}, --14
    {"UI_Main_TiShi_Cai"}, --15
    {"UI_Main_TiShi_Cai"}, --16
}

function M:onEnter() 
    self.m_model.m_hero_tab_index = 1
    for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_hero_tab_index then
			tog_btn.isOn = true
		end
	end
    self:switchTabUpdate(true, self.m_model.m_hero_tab_index)
    self:setTextByLanKey("tj_btn_text", "new_str_0438")
    audio:PauseSkillsBusVol()
end

function M:switchTabNode(index)
    self.m_model:setSortType(index)
    local name = self.m_model.sort_type == 1 and "hero_ui_str_0009" or "new_str_0436"
    self:setTextByLanKey("hero_filten_texy", name)
    self:refreshUI()
end

function M:switchTabUpdate(is_on, update_key)
    if is_on then
        self.m_model.m_hero_tab_index = update_key
        for k,v in pairs(__TAB_BTN_NODE) do
            if k == self.m_model.m_hero_tab_index then
                self:setTextColor(v.text_key, M.COMMON_COLLOR_1)
            else
                self:setTextColor(v.text_key, M.COMMON_COLLOR_2)
            end
        end
        if self.m_model.m_hero_tab_index == 1 then
            self:updateHero()
        else
            self:updateGuide()
        end
	end
end

function M:updateHero()
    self:switchTabNode(2) 
    self:setObjectVisible("open_hero_filter_btn", true)  
    self:setObjectVisible("hero_num", true)  
    self:setTextByLanKey("title_text", "new_str_0364")
end

function M:updateGuide()
    self:updateLoopScroll()
    self:setObjectVisible("open_hero_filter_btn", false)
    self:setObjectVisible("hero_num", false)  
    self:setTextByLanKey("title_text", "new_str_0150")
end

-------刷新--------------------------------------------------------------------------------------------------------------------------

function M:refreshUI()
    self:updateLoopScroll()
    self:refreshRedPoint()
    self:refreshHero_Grid()
    for i = 1, 2 do
        if self.m_model.sort_type == i then
            self:setObjectVisible("select_img"..i, true)
        else
            self:setObjectVisible("select_img"..i, false)    
        end
    end
end

--英雄格子数量
function M:refreshHero_Grid()
    local num_text =  #self.m_model.hero_list.."/"..self.m_model:getHeroGrideNum()
    self:setText("hero_num_text",num_text)
end

function M:filter_callback(index)
    self.m_race = index
    self:updateLoopScroll()
end

--[[
	创建英雄列表
]]
function M:updateLoopScroll()
    self.m_hero_cell_tab = {} --缓存英雄数据
    self.m_model:getHeroByRace(self.m_race,self.m_type)
    local data = {}
    if self.m_model.m_hero_tab_index == 1 then
        data = self.m_model.Filtrate_list
    else
        data = self.m_model:getHeroTj()
    end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("hero_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_hero_cell_tab[index] = cell_object
                if self.m_model.m_hero_tab_index == 1 then
                    self:updateHeroData(cell_object, cell_data)
                else
                    self:updateGuideData(cell_object, cell_data)
                end
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_model.m_hero_tab_index == 1 then
                    self:updateMsg("select_hero", cell_data)
                else
                    self:updateMsg("select_tj_hero", cell_data)
                end
      
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:switchTabByPro2(is_on, update_key)
	if is_on then
        self.m_type = update_key
        self:updateLoopScroll()
	end
end

function M:refreshRedPoint()
	for k, v in pairs({ { "tj_btn_red_point_img", 47 } }) do
		local red_flag = RedPointUtil:isFuncRedPointById(v[2])
		self:setObjectVisible(v[1], red_flag == true)
	end	
end

function M:updateHeroData(obj, o_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(o_id)
    local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
    end
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[hero_cfg.type]
    if type_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon,  "hero_ui")
    end
    local evo = hero_cfg.evo
    local lv = 0
    local show_lv = ""
    if hero_data then
        evo =  hero_data.evo
        if hero_data.clv and hero_data.clv > 0 then
            lv = hero_data.clv
        else
            lv = hero_data.lv
        end
    end
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[tonumber(lv)]
    show_lv = "Lv."..upgrade_cfg.display_level

    local icon_name = "h_"..hero_cfg.icon.."_l"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
    local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    local big_quality_data= GlobalConfig.QUALITY_FRAME[evo] or GlobalConfig.QUALITY_FRAME[1]
    local lv_text = LuaBehaviourUtil.setText(luaBehaviour,"lv_text", show_lv)
    local name = LuaBehaviourUtil.setText(luaBehaviour,"name_text", Language:getTextByKey(hero_cfg.name))
    --if evo and evo > 11 then --白色之后加星
    --    self:updateHeroInfo(obj, hero_data)
    --    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", true)
    --end
    GameUtil:updateHeroInfo(obj,hero_data)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang", quality_item.is_add)
    if quality_item.is_add and big_quality_data.big_frame_add_name then
        LuaBehaviourUtil.setImg(luaBehaviour, "kuang", big_quality_data.big_frame_add_name, "hero_head_ui")
     end

    local red_flag = RedPointUtil:checkHeroRedPointById(o_id)
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    if red_point_img then
        if red_flag == true then
            red_point_img:SetActive(true)
        else
            red_point_img:SetActive(false) 
        end
    end
end

function M:updateGuideData(obj, o_id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(o_id)
    local race_data = GlobalConfig.TYPE_HERO_RACE[hero_cfg.race]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon, "common_ui")
    end
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[hero_cfg.type]
    if type_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"type_img", type_data.pro_icon, "hero_ui")
    end
    local evo = hero_cfg.evo
    local lv = self.m_model:getMaxlv(o_id)
    local show_lv = ""
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[tonumber(lv)]
    show_lv = "Lv."..upgrade_cfg.display_level
    local icon_name = "h_"..hero_cfg.icon.."_l"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
    local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    local big_quality_data= GlobalConfig.QUALITY_FRAME[evo] or GlobalConfig.QUALITY_FRAME[1]
    local lv_text = LuaBehaviourUtil.setText(luaBehaviour,"lv_text", show_lv)
    local name = LuaBehaviourUtil.setText(luaBehaviour,"name_text", Language:getTextByKey(hero_cfg.name))
    -- LuaBehaviourUtil.setTexture(luaBehaviour, "hero_img", "HeroIcon/"..icon_name, "heroicon_"..icon_name)
    -- LuaBehaviourUtil.setTexture(luaBehaviour, "hero_bg", "HeroIcon/"..big_quality_data.card_frame_name, "heroicon_"..big_quality_data.card_frame_name)
    -- LuaBehaviourUtil.setObjectVisible(luaBehaviour, "kuang", quality_item.is_add)
    if quality_item.is_add and big_quality_data.big_frame_add_name then
        LuaBehaviourUtil.setImg(luaBehaviour, "kuang", big_quality_data.big_frame_add_name, "hero_head_ui")
    end
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    red_point_img:SetActive(false) 
end

--function M:updateHeroInfo(object, data)
--    if data then
--        local luaBehaviour = UIUtil.findLuaBehaviour(object)
--        local stars = luaBehaviour:FindGameObject("stars")
--        -- 显示升级等级
--        local lv = data.evo - 11 or 0
--        if lv > 0 then
--            stars:SetActive(true)
--            for i = 1, 5 do
--                local star = luaBehaviour:FindGameObject("star_" .. i)
--                if star then
--                    star:SetActive(i <= lv)
--                end
--            end
--        end
--    end
--end

function M:onButtonClick(obj, name)
    if name == "open_hero_filter_btn" then
        self:show_sort(true)
    elseif name == "sort_close" then    
        self:show_sort(false)
    elseif name == "sort_1" then  
        self:switchTabNode(1)  
        self:show_sort(false)
    elseif name == "sort_2" then
        self:switchTabNode(2)    
        self:show_sort(false)
    elseif name == "sort_3" then    
        self:show_sort(false)
    else
        self:updateMsg(name)
    end
    local full_btn_name = self.m_uiName .. "/" .. name
    GameUtil:playBtnSound(full_btn_name)
end

function M:show_sort(bl)
    self:setObjectVisible("sort_close", bl)
    self:setObjectVisible("sort_pop", bl)
end

function M:destroy()
	audio:ResumeSkillsBusVol()
    M.super.destroy(self)
end

return M