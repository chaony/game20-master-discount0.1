local M = class("StageRewardDetailsView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Map/StageRewardDetails"
M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = {
    {btn_key = "items_togglebtn", lua_name = "", drak_text = "items_drak_text", light_text = "items_light_text", text_key = "new_str_0041", open = true}, -- 道具
    {btn_key = "equips_togglebtn", lua_name = "", drak_text = "equips_drak_text", light_text = "equips_light_text", text_key = "new_str_0042", open = true }, -- 装备
}
--
function M:onEnter()
    self.m_toggle_btns = {}
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.drak_text, v.text_key)
        self:setTextByLanKey(v.light_text, v.text_key)
        local tog_btn = self:findToggle(v.btn_key)
        tog_btn.gameObject:SetActive(v.open)
        self.m_toggle_btns[k] = tog_btn
        UIUtil.addToggleListener(tog_btn, function(is_on)
			if is_on then
				self:updateMsg("tab_click", k)
			end
		end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
    end
    self:setTextByLanKey("cur_reward","qh_str_0006")
    local new_stage_name = self.m_model:getNextName()
	self:setTextByLanKey("next_reward","qh_str_0007")
	self:setTextByLanKey("common_title_text", "qh_str_0009")
	if new_stage_name ~= nil then
		self:setTextByLanKey("next_reward","qh_str_0008",new_stage_name)
	end
end

function M:switchTabNode(index)
	self.m_model.m_open_tab_index = index
    for k,v in pairs(__TAB_BTN_NODE) do
        if index == k then
            self:setObjectVisible(v.drak_text,false)
            self:setObjectVisible(v.light_text,true)
        else
            self:setObjectVisible(v.drak_text,true)
            self:setObjectVisible(v.light_text,false)
        end
	end
    self:updateLoopScroll()
    self:updateNextLoopScroll()
end

--[[
	创建掉落列表
]]
function M:updateLoopScroll()
    self.m_cell_tab = {}
	local data = self.m_model:getObtainable()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("cur_loopscroll")
		local params = {
            show_data = data,
            one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_cell_tab[index] = cell_object
                GameUtil:updateItemElement(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
     
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--[[
	创建即将掉落列表
]]
function M:updateNextLoopScroll()
    self.m_cell_tab = {}
	local data = self.m_model:getBeInLineFor()
	if #data > 0 then
		self:setText("next_text", "")
	else
		self:setText("next_text", Language:getTextByKey("qh_str_0005"))
	end
	if self.m_next_scroll_view == nil then
		local loopscroll = self:findGameObject("next_loopscroll")
		local params = {
            show_data = data,
            one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_cell_tab[index] = cell_object
                GameUtil:updateItemElement(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_next_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_next_scroll_view:reloadData(data)
	end
end

return M