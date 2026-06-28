local M = class("HeroFetterNode", LikeOO.OOUIbase)

M.m_uiName = "HeroBag/HeroFetterNode"

function M:onEnter()
    self.title_index = {}
    self.base_obj = self:findGameObject("base_obj")
    self.m_gray_image = self:findImage("a_gray_img")
    self.base_obj_fitter = self.base_obj:GetComponent("ContentImmediate")
    self:setTextByLanKey("content_text", "hero_ui_str_0015")
    self:refreshUI()
end

function M:refreshUI()
    local fetter_tab = self.m_model:getFetterNode()
    self.title_index = {}
    self:updateScroll(fetter_tab)
end


function M:updateScroll(data)
    local all_cell_size = {}
    for i = 1, #data do
        if self.title_index[i] == 3 then
            all_cell_size[i] = Vector2(373.7, 270)
        elseif self.title_index[i] == 2 then
            all_cell_size[i] = Vector2(373.7, 240) 
        else
            all_cell_size[i] = Vector2(373.7, 188)
        end
    end
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("scroll_list")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
            loop_scroll_object = list_scroll,
            all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateItem(index, cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "jiantou_btn" then
                    self:cell_click2(index,cell_data.level)
                    audio:SendEvtUI('Ui_NormalClick')
                    self:updateMsg("guide_fetter")
                end 
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true, all_cell_size)
	end
end

function M:cellItem()
    local item = ResourceUtil:LoadUIGameObject("HeroBag/hero_cell", Vector3.zero, nil)
    item.transform:SetParent(self.base_obj.transform, false)
    return item
end

function M:updateItem(index ,obj, data)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour	then
        data.open = false
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_name", data.name)
        local lv = self.m_model:checkFetterLv(data.id)
		self:updateStar(obj, lv, data.level)
		local hero_node = LuaBehaviour:FindGameObject("hero_node")
		UIUtil.destroyAllChild(hero_node.transform)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "level_fetter", false)
        local pro_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "pro_text", self.m_model:getFeeterProByLv(data.id, lv))
        if lv > 0 then
            pro_text.color =  Color( 155/255, 173/255, 213/255)
        else
            pro_text.color =  Color( 143/255, 147/255, 156/255)
        end
		for i=1, table.nums(data.sub_hero) do
			local c_id = data.sub_hero[i]
			local itemData = {RewardUtil.REWARD_TYPE_KEYS.HEROS, c_id, 1}
            local temp_obj = CommonUIUtil:createHeroElement(itemData)
            self:updateHeroStatus(temp_obj, c_id)
			-- UIUtil.setScale(temp_obj.transform, 0.5)
			temp_obj.transform:SetParent(hero_node.transform, false)
            UIUtil.setObjectVisible(temp_obj.transform,false,"stars")
        end
        local fetter_tab = self.m_model:getFetterTab(data)
        for i = 1, 5 do
            if fetter_tab[i] then
                local count_data = fetter_tab[i]
                local level_obj = LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "fetter_level_"..i, true)
                local pro_num_text = nil 
                local des_count = nil
                local des_count2 = nil
                if count_data.des then
                    des_count = UIUtil.setTextByLanKey(level_obj.transform, "des_count", count_data.des)
                elseif count_data.des_lv then
                    local cur_quality = GlobalConfig.HERO_QUALITY_COMMON_SETTING[count_data.des_lv] or  GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
                    local str = Language:getTextByKey("hero_ui_str_0018")..Language:getTextByKey(cur_quality.base_name)
                    des_count = UIUtil.setTextByLanKey(level_obj.transform, "des_count", str)
                    des_count2 = UIUtil.setTextByLanKey(level_obj.transform, "des_count2", "shareLv_str_0023")   
                    UIUtil.setImg(level_obj.transform, cur_quality.add_img, "hero_head_ui", "lv_img")
                end
                if lv >= i then
                    pro_num_text = UIUtil.setTextByLanKey(level_obj.transform, "pro_num", count_data.act_num)
                    pro_num_text.color = Color( 155/255, 173/255, 213/255)
                    des_count.color =  Color( 155/255, 173/255, 213/255)
                    if des_count2 then
                        des_count2.color =  Color( 155/255, 173/255, 213/255)
                    end
                else
                    pro_num_text = UIUtil.setTextByLanKey(level_obj.transform, "pro_num", count_data.num)
                    pro_num_text.color = Color( 143/255, 147/255, 156/255)
                    des_count.color = Color( 143/255, 147/255, 156/255)
                    if des_count2 then
                        des_count2.color =  Color( 143/255, 147/255, 156/255)
                    end
                end
            else
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "fetter_level_"..i, false)
            end
        end
        local jiantou_pos = -80
        local jiantou_img = LuaBehaviour:FindGameObject("jiantou_img")
        if self.title_index[index] and self.title_index[index] > 0 then
            local cell_obj = LuaBehaviour:FindGameObject("cell_bg")
            local m_rt = cell_obj:GetComponent("RectTransform")
            local rect_width, rect_height = m_rt.rect.width, m_rt.rect.height
            if self.title_index[index] == 3 then
                rect_height = 270
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "pro_text", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "level_fetter", true)
                jiantou_pos = -118
                if not IsNull(jiantou_img) then
                    jiantou_img.transform.localRotation = Quaternion.Euler(0,0,180);
                end
            elseif self.title_index[index] == 2 then
                rect_height = 240
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "pro_text", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "level_fetter", true)
                jiantou_pos = -102
                if not IsNull(jiantou_img) then
                    jiantou_img.transform.localRotation = Quaternion.Euler(0,0,180);
                end
            else
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "pro_text", true)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "level_fetter", false)
                rect_height = 188
                jiantou_pos = -80
                if not IsNull(jiantou_img) then
                    jiantou_img.transform.localRotation = Quaternion.Euler(0,0,0);
                end
            end
            m_rt.sizeDelta = Vector2(rect_width, rect_height) 
            if not IsNull(jiantou_img) then
                jiantou_img.transform.localPosition = Vector3(163, jiantou_pos, 0)
            end
        else
            local cell_obj = LuaBehaviour:FindGameObject("cell_bg")
            local m_rt = cell_obj:GetComponent("RectTransform")
            local rect_width, rect_height = m_rt.rect.width, m_rt.rect.height
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "pro_text", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "level_fetter", false)
            rect_height = 188
            m_rt.sizeDelta = Vector2(rect_width, rect_height) 
            if not IsNull(jiantou_img) then
                jiantou_img.transform.localPosition = Vector3(163, -80, 0)
                jiantou_img.transform.localRotation = Quaternion.Euler(0,0,0);
            end
        end
	end
end

function M:updateHeroStatus(obj, h_id)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local hero_data =  UserDataManager:getHeroMaxEvo(h_id)
    local quality_img = LuaBehaviour:FindImage("quality_img")
    local item_img = LuaBehaviour:FindImage("item_img")
    local camp_img = LuaBehaviour:FindImage("camp_img")
    local quality_up_img = LuaBehaviour:FindImage("quality_up_img")
    if hero_data and hero_data.max_evo  > 0 then
        local quality_item = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_data.max_evo] or GlobalConfig.HERO_QUALITY_COMMON_SETTING[1]
        local frame_name = quality_item.hero_item_frame
        local add_img = quality_item.add_img
        if hero_data.max_evo > 11 then
            GameUtil:updateHeroStarsByQuality(obj, hero_data.max_evo-11)
        elseif quality_item.is_add == true then
            GameUtil:updateHeroStarsByQuality(obj, 1)
        end
        LuaBehaviourUtil.setImg(LuaBehaviour, "quality_img", frame_name, "hero_head_ui")
        LuaBehaviourUtil.setImg(LuaBehaviour, "quality_up_img", add_img, "hero_head_ui")
        quality_img.material = nil
        item_img.material = nil
        camp_img.material = nil
        quality_up_img.material = nil
    else    
        quality_img.material =self.m_gray_image.material
        item_img.material =self.m_gray_image.material
        camp_img.material =self.m_gray_image.material
        quality_up_img.material =self.m_gray_image.material
    end
end

function M:clickHero()
    
end

function M:cell_click2(index, lv)
    if self.title_index[index] and self.title_index[index] == lv then
        self.title_index[index] = 0
    else
        self.title_index[index] = lv    
    end
    local fetter_tab = self.m_model:getFetterNode()
    self:updateScroll(fetter_tab)
    self.m_list_scroll:moveToCellIndex(index)
end

function M:updateStar(obj, star_num, max_star)
	local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
	if LuaBehaviour	then
		for i = 1, 5 do
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "xing_"..i, star_num>= i)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "xing_bg_"..i, max_star>= i)
		end
	end
end

function M:onButtonClick(obj, name)
    if name == "pro_1" then
        self:clickProTips1(name)
    elseif name == "pro_2" then
        self:clickProTips2(name)
    elseif name == "pro_3" then
        self:clickProTips3(name)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:clickProTips1(str)
    local temp_cfg = self.m_model:getCurHeroCfg()
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[temp_cfg.type]
    local cur_cfg = self.m_model:getCurHeroCfg()
    local data_desc = type_data.des
    local btns = self:findGameObject(str)
    if btns then
        GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc)})
    end
end

function M:clickProTips2(str)
    local temp_cfg = self.m_model:getCurHeroCfg()
    local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[temp_cfg.locate1 or 1]
    local cur_cfg = self.m_model:getCurHeroCfg()
    local data_desc = locate1_data.des
    local btns = self:findGameObject(str)
    if btns then
        GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc)})
    end
end

function M:clickProTips3(str)
    local temp_cfg = self.m_model:getCurHeroCfg()
    local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[temp_cfg.locate2 or 1]
    local cur_cfg = self.m_model:getCurHeroCfg()
    local data_desc = locate2_data.des
    local btns = self:findGameObject(str)
    if btns then
        GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc)})
    end
end

return M
