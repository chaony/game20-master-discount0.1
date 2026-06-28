local M = class("SkinExchangePopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/SkinExchangePop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0931")
    self.m_gray_image = self:findImage("gray_image")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model:getShowData()
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 4,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHeroData(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, cell_data = cell_data})
            end,
            ui_name = self.m_uiName,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, self.m_control.keep_offset)
        self.m_control.keep_offset = nil
    end
end

function M:updateHeroData(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cell_data.cfg.hero)
    GameUtil:updateHeroContentByData(cell_object, {skin = cell_data.id, showSkinQuality = true}, hero_cfg)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lv_text", false)
    local exist_flag = UserDataManager:existHeroSkin(cell_data.id)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "exchange_btn_text", exist_flag and "new_str_0841" or "new_str_0907")
    local exchange_btn_img = luaBehaviour:FindImage("exchange_btn")
    if exist_flag then
        exchange_btn_img.material = self.m_gray_image.material
    else
        exchange_btn_img.material = nil
    end
    local exchange_btn = luaBehaviour:FindButton("exchange_btn")
    exchange_btn.enabled = not exist_flag
    local convert = cell_data.cfg.convert or {}
    local cost_num_text = nil
    local text_color = nil
    if #convert > 0 then
        local cost_data = RewardUtil:getProcessRewardData(convert[1])
        cost_num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cost_num_text", "new_str_0053", cost_data.user_num, cost_data.data_num)
        text_color = cost_data.user_num >= cost_data.data_num and GlobalConfig.COMMON_COLLOR.COMMON_1 or GlobalConfig.COMMON_COLLOR.COMMON_11
        LuaBehaviourUtil.setImg(luaBehaviour, "cost_img", cost_data.icon_name, "item_icon")
    else
        cost_num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cost_num_text", "0/0")
        text_color = GlobalConfig.COMMON_COLLOR.COMMON_11
    end
    cost_num_text.color = text_color
end

return M