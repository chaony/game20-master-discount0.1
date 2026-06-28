local M = class("MercenaryHandlePopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/MercenaryHandlePop"
M.m_size_type = 2

local __TAB_BTN_NODE = { "apply_toggle","out_toggle", }
local __TAB_BTN_TEXT = { "apply_toggle_text","out_toggle_text", }
function M:onEnter()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data)
                self:setTextColor(__TAB_BTN_TEXT[data], GlobalConfig.COMMON_COLLOR.COMMON_25)
			else
                self:setTextColor(__TAB_BTN_TEXT[data], GlobalConfig.COMMON_COLLOR.COMMON_24)
			end 
		end, i, self.m_uiName)
	end

    self.apply_btn_panel = self:findGameObject("apply_btn_panel")
	self.applay_scroll = self:findGameObject("applay_scroll")
	self.out_scroll = self:findGameObject("out_scroll")
    self.no_panel = self:findGameObject("no_panel")
    self:setTextByLanKey("no_text", "friend_str_0032")
    self:setTextByLanKey("apply_toggle_text", string.cutTextForString(Language:getTextByKey("friend_str_0012")))
    self:setTextByLanKey("out_toggle_text", string.cutTextForString(Language:getTextByKey("friend_str_0036")))
    self:setTextByLanKey("all_ignore_btn_text", "union_str_0048")
    self:setTextByLanKey("all_agree_btn_text", "yijian_jiechu_text")
	self:refreshUI()
end

function M:refreshUI()
    self.apply_btn_panel:SetActive(self.m_model.m_tab_index == 1)
	self.applay_scroll:SetActive(self.m_model.m_tab_index == 1)
	self.out_scroll:SetActive(self.m_model.m_tab_index == 2)
	if self.m_model.m_tab_index == 1 then
        self:setTextByLanKey("common_title_text", "friend_str_0012")
        self.no_panel:SetActive(#self.m_model.m_applay_list == 0)
		self:updateApplayScroll()
	else
        self:setTextByLanKey("common_title_text", "friend_str_0036")
        self.no_panel:SetActive(#self.m_model.m_out_list == 0)
		self:updateOutScroll()
	end
end

function M:updateApplayScroll()
    local data = self.m_model.m_applay_list
    if self.m_applay_scroll == nil then
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = self.applay_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setApplayCellHander(cell_object, data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, cell_data)
            end
        }
        self.m_applay_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_applay_scroll:reloadData(data)
    end
end

function M:setApplayCellHander(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    GameUtil:setUserAvatar(HeadNode, data.user, true,nil,{show_flag = true, scale = 1})
    local name_text = luaBehaviour:FindText("name_text")
    if data.user.name == "" then
        name_text.text = Language:getTextByKey("new_str_0141")
    else
        name_text.text = data.user.name
    end
    
    local applay_text = luaBehaviour:FindText("applay_text")
    applay_text.text = Language:getTextByKey("friend_str_0030")
    
    local ItemNode = luaBehaviour:FindGameObject("ItemNode")
    local function itemCall()
        self:updateMsg("hero_click", data.hero_oid)
    end
    local heroData, heroCfg = UserDataManager.hero_data:getHeroDataById(data.hero_oid)
    local item = GameUtil:updateItemElement(ItemNode, {RewardUtil.REWARD_TYPE_KEYS.HEROS, heroData.id, 1, heroData.oid}, false, false, itemCall)
    LuaBehaviourUtil.setImg(item.luaBehaviour,"fate_icon_img", "a_tmhx_jiaobiao","language_zh_cn")
    local power_text = luaBehaviour:FindText("power_text")
    power_text.text = heroData.combat
end

function M:updateOutScroll()
    local data = self.m_model.m_out_list
    if self.m_out_scroll == nil then
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = self.out_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setOutCellHander(cell_object, data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, cell_data)
            end
        }
        self.m_out_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_out_scroll:reloadData(data)
    end
end

function M:setOutCellHander(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local name_text = luaBehaviour:FindText("name_text")
    local user_name = data.user.name
    if data.user.name == "" then
        user_name = Language:getTextByKey("new_str_0141")
    end
    name_text.text = user_name
    local applay_text = luaBehaviour:FindText("applay_text")
    applay_text.text = Language:getTextByKey("friend_str_0031")
    local mission_text = luaBehaviour:FindText("mission_text")
    Logger.log()
    mission_text.text = string.format(Language:getTextByKey("friend_str_0027"), user_name)
    
    local ItemNode = luaBehaviour:FindGameObject("ItemNode")
    local function itemCall()
        self:updateMsg("hero_click", data.hero_oid)
    end
    local heroData, heroCfg = UserDataManager.hero_data:getHeroDataById(data.hero_oid)
    local item = GameUtil:updateItemElement(ItemNode, {RewardUtil.REWARD_TYPE_KEYS.HEROS, heroData.id, 1, heroData.oid}, false, false, itemCall)
    LuaBehaviourUtil.setImg(item.luaBehaviour,"fate_icon_img", "a_tmhx_jiaobiao","language_zh_cn")
    local power_text = luaBehaviour:FindText("power_text")
    power_text.text = heroData.combat
end

return M