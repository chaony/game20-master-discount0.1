local M = class("BountyMissionsHelpPopView",LikeOO.OOPopBase)

M.m_uiName = "BountyMissions/BountyMissionsHelpPop"
M.m_size_type = 2

local pro_type = {
    {key = 1, icon = "a_ui_all", text = "全", isOn = true ,race = 0},
    {key = 2, icon = "a_ui_qinglong", text = "", isOn = false ,race = 1 },
    {key = 3, icon = "a_ui_xuanwu", text = "", isOn = false ,race = 3 },
    {key = 4, icon = "a_ui_baihu", text = "", isOn = false ,race = 4 },
    {key = 5, icon = "a_ui_zhuque", text = "", isOn = false ,race = 2 },
    {key = 7, icon = "a_ui_heian", text = "", isOn = false ,race = 6 },
    {key = 6, icon = "a_ui_guangming", text = "", isOn = false ,race = 5 },
}


function M:onEnter()	
    self:setTextByLanKey("common_title_text", "选择英雄")
	self:updateProLoopScroll()
end

function M:refreshUI()
    self:updateLoopScroll()
end

--[[
    职业类型页签列表
]]

function M:updateProLoopScroll()
    self.m_pro_cell_tab = {}
    local tog = self:findGameObject("pro_toggle")   
    self.pro_toggle = UIUtil.findComponent(tog.transform, typeof(U3DUtil:Get_ToggleGroup()))
    if self.m_pro_scroll_view == nil then
        local loopscroll = self:findGameObject("pro_loopscroll")
        local params ={
            show_data = pro_type,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self.m_pro_cell_tab[index] = { obj = cell_obj, data = cell_data}
                local cell_tog = UIUtil.findComponent(cell_obj.transform,typeof(U3DUtil:Get_Toggle()))
                cell_tog.group = self.pro_toggle
                GameUtil:updateProCell(cell_obj, cell_data, function(is_on) 
                    self:switchTabByProCell(is_on, cell_data.race)
                    audio:SendEvtUI("Play_UI_Tab")
                end, self.m_uiName)
            end,
            ui_name = self.m_uiName,
        }
        self.m_pro_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_pro_scroll_view:reloadData(pro_type)
    end 

    for k,v in pairs(self.m_pro_cell_tab) do
        if v.data.isOn == true then
            local cell_tog = UIUtil.findComponent(v.obj.transform,typeof(U3DUtil:Get_Toggle()))
            cell_tog.isOn = true
        end
    end
end

function M:switchTabByProCell(is_on, update_key)
    if is_on then
        self.m_race = update_key
        self:updateLoopScroll()
	end
end

--[[
	创建英雄列表
]]
function M:updateLoopScroll()
	self.m_model:getHeroByRace(self.m_race)
	local data = self.m_model.Filtrate_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_hero", cell_data)
			end,
            ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end


--刷新英雄数据
function M:updateHeroContent(obj, heroOid)
	if obj == nil then 
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return 
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local hero_data,hero_cfg = self.m_model:getHero(heroOid)
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
    --GameUtil:updateHeroLvByData(obj, itemData)
    self:alterData(obj, itemData)
    if #self.m_model.m_select_oid > 0 and heroOid == self.m_model.m_select_oid then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", true)

    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigou_img", false)
    end
end


function M:alterData(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local farm = GlobalConfig.QUALITY_FRAME[data.quality]
    --local farm_data = GlobalConfig.QUALITY_FRAME[data.evo] --big_frame_add_name
    local icon_quality_img = luaBehaviour:FindImage("hero_bg")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local stars = luaBehaviour:FindGameObject("stars")
    local star_bg = luaBehaviour:FindGameObject("star_bg_img")
    GameUtil:updateResourcesImg(icon_quality_img, "Texture/HeroIcon/"..farm.card_frame_name)
    local hero_img = luaBehaviour:FindImage("hero_img")
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local icon_name = "h_"..data.icon_name.."_l"
    GameUtil:updateResourcesImg(hero_img, "Texture/HeroIcon/"..icon_name)
    stars:SetActive(false)
    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(data.oid)
    local hero_lv = 0
    local show_lv = ""
    local quality_item = nil
    if hero_data then
        evo =  hero_data.evo
        if hero_data.clv and hero_data.clv > 0 then
            hero_lv = hero_data.clv
        else
            hero_lv = hero_data.lv
        end
    end
    local hero_upgrade = ConfigManager:getCfgByName("hero_upgrade")
    local upgrade_cfg = hero_upgrade[tonumber(hero_lv)]
    show_lv = upgrade_cfg.display_level..Language:getTextByKey("new_str_0428")

   
    local lv_text = LuaBehaviourUtil.setText(luaBehaviour,"lv_text", show_lv)
    
    quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
    frame_name = quality_item.hero_item_frame
    --quality_img = LuaBehaviourUtil.setImg(luaBehaviour, "quality_img", frame_name, "hero_head_ui")
    quality_up_img:SetActive(data.quality > 2)
    --if quality_item.is_add then
        LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", quality_item.add_img, "hero_head_ui")
    --end
    camp_img:SetActive(true)
    local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour, "camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
    end
    -- 显示升级等级
    GameUtil:updateHeroInfo(obj, data)

    --self.icon_quality_img.sprite = ResourceUtil:GetSprite(farm.card_frame_name, "hero_head_ui")
    -- local item = luaBehaviour:FindGameObject("item_img")--任务名字
    -- local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    -- local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    -- item:SetActive(true)
    -- local camp_img = luaBehaviour:FindGameObject("camp_img")
    -- local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
    -- quality_up_img:SetActive(frame.is_add == true)
    -- if frame.is_add == true then
    --     LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", frame.add_img, "hero_head_ui")
    -- end
    -- LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.hero_item_frame, "hero_head_ui")
    -- local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
    -- local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
    -- if race_data then
    --     LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon, "common_ui")
    -- end
end

return M