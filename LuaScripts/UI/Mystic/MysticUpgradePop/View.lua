local M = class("MysticUpgradePopView",LikeOO.OOPopBase)

M.m_uiName = "Mystic/MysticUpgradePop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "mystic_str_0008")
	self:setTextByLanKey("cost_title_text", "mystic_str_0009")
	self:setTextByLanKey("yes_btn_text", "mystic_str_0002")
	self:setTextByLanKey("cancel_btn_text", "new_str_0007")
	self.new_icon = self:findGameObject("new_icon")
	self.suiji_img = self:findGameObject("suiji_img")
	self:refreshUI()	
end

function M:refreshUI()
	local oid = self.m_model.m_params[1]
	local data, cfg = UserDataManager.mystic_data:getMysticDataById(oid)
    self:setImg(GlobalConfig.QUALITY_MYSTIC_SETTING[data.evo + 1].icon, "common_ui", "evo_img")
	if self.m_model.up_type == 1 then
		self:setTextByLanKey("get_tips_text", "mystic_str_0012")
		self.suiji_img:SetActive(false)
        GameUtil:updateItemElement(self.new_icon, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC, data.id, data.evo + 1}, false, false)
        local show_cfg = cfg[data.evo + 1]
        if show_cfg then
            local attr = show_cfg.attr[1]
            self:setTextByLanKey("attr_name", GameUtil:getAttrsName(GameUtil:getAttrsKey(attr[1])))
            self:setTextByLanKey("attr_num", "+"..GameUtil:formatNum(attr[2]))
        end
        if show_cfg.hero_type and show_cfg.hero_type > 0 then
            self:setObjectVisible("hero_type_obj", true)
            self:setTextByLanKey("hero_type", "new_str_0491")
            local type_cfg = GlobalConfig.TYPE_HERO_PROPERTY[show_cfg.hero_type]
            self:setImg(type_cfg.pro_icon, "hero_ui", "type_img")
            self:setObjectVisible("attrs_obj", true)
        else
            self:setObjectVisible("hero_type_obj", false)
        end
	else
		self:setTextByLanKey("get_tips_text", "mystic_str_0013")
		GameUtil:updateItemElementNoData(self.new_icon, RewardUtil.REWARD_TYPE_KEYS.MYSTIC)
		local luaBehaviour = self.new_icon:GetComponent("LuaBehaviour")
        local quality_item = GlobalConfig.QUALITY_MYSTIC_SETTING[data.evo + 1] or GlobalConfig.QUALITY_MYSTIC_SETTING[1]
        LuaBehaviourUtil.setImg(luaBehaviour,"no_quality_img", quality_item.frame_name, "equip_icon")
        local no_quality_up_img = luaBehaviour:FindGameObject("no_quality_up_img")
        local add_img = luaBehaviour:FindGameObject('add_img')
        no_quality_up_img:SetActive(false)
        add_img:SetActive(false)
        self.suiji_img:SetActive(true)
	end
	self:updateScroll()
end

function M:updateScroll()
    local data = self.m_model.m_params
    -- Logger.log(data,"data ====")
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:setCellHander(obj, data, id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local mystic_data, mystic_cfg = UserDataManager.mystic_data:getMysticDataById(data)
    GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.MYSTIC, mystic_data.id, mystic_data.evo, oid = data}, false, false)
end

return M