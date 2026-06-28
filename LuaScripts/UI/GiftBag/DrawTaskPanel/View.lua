local M = class("DrawTaskPanelView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/DrawTaskPanel"
M.m_size_type = 2

function M:onEnter()
    self.rewards = {}
    RedPointUtil:setDrawTaskShopRedPoint(self.m_model.m_select_index)
    self.m_gray_img = self:findImage("gray_img")
    self:refreshUI()
    self.m_control:setOnceTimer(0.5, function ()
        self:setObjectVisible("all_get_btn", true)
    end)
    self:setTextByLanKey("all_get_btn_text", "mail_str_0017")
end

function M:refreshUI()
    self:createTagLoopScroll()
    self:createLoopScroll()
end

--[[
    创建日期页签列表
]]
function M:createTagLoopScroll()
    local data = {}
    for i = 1, 7 do
        table.insert(data, {})
    end
    self.m_tag_tab = {}
    if self.m_tab_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_tag_tab[index] = {data = cell_data, obj = cell_obj}
                self:update_tag(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if click_name == "tab_obg" then
                    self:updateMsg("select_tag", index)
                elseif click_name == "mask_btn" then
                    GameUtil:lookInfoTips(self.m_control, {msg = "new_str_0535", delay_close = 2})
                end
            end
        }
        self.m_tab_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_tab_scroll_view:reloadData(data, true)
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_btn", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", index == self.m_model.m_select_index)
        local red_point_bl = self.m_model:checkRedPointByDay(index)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", red_point_bl == true)
        local day_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_name_text", "gf_str_0028", index)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_btn", index > self.m_model.m_day)
        if index == self.m_model.m_select_index then
            day_text.color = Color.New(73 / 255, 48 / 255, 44 / 255)
        else
            day_text.color = Color.New(255 / 255, 255 / 255, 255 / 255)--GlobalConfig.COMMON_COLLOR.COMMON_2
        end
    end
end

function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_recruit_tab()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateTaskItem(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "ok_btn" then
					if cell_data.shop_type == true then
                        if cell_data.log_type == true then
                            if self.m_model:checkLogin() == false then
                                self:updateMsg("get_login")
                            end
                        else
                            local buy_num = self.m_model:checkBuy()
                            if (cell_data.cfg.time - buy_num) > 0 then
                                self:updateMsg("get_buy")
                            end
                        end
					else
						local data = self.m_model:getTaskDataById(cell_data.id)
						if data.status == 1 then
							self:updateMsg("get_reward", cell_data.id)
						elseif data.status == 0 then
							self:updateMsg("go_to", cell_data.cfg.go_type)
						end
					end
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateTaskItem(obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
    if luaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", cell_data.cfg.name)
        local rate_text = luaBehaviour:FindText("rate_text")
        local btn_text = luaBehaviour:FindText("btn_text")
        local itemParent = luaBehaviour:FindGameObject("itemParent")
        UIUtil.destroyAllChild(itemParent.transform)
        local btn_img = luaBehaviour:FindImage("ok_btn")
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rate_text", true)
        if cell_data.shop_type == true then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rate_text", false)
			if cell_data.log_type and cell_data.log_type == true then
				if self.m_model:checkLogin() == true then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "gf_str_0040")	
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = self.m_gray_img.material
				else
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "gf_str_0039")
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = nil
				end
			else
				local buy_num = self.m_model:checkBuy()
				local price_data = RewardUtil:getProcessRewardData(cell_data.cfg.price[1])
				LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", price_data.icon_name, price_data.atlas_name)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", price_data.data_num)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", (cell_data.cfg.time - buy_num))
				if (cell_data.cfg.time - buy_num) > 0 then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "new_str_0037")
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = nil
				else
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "gf_str_0048")	
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = self.m_gray_img.material
				end
			end	
        else
            local data = self.m_model:getTaskDataById(cell_data.id)
            local show_num = ""
            if data.value >= cell_data.cfg.target_value then
                local qian_num = data.value > cell_data.cfg.target_value and cell_data.cfg.target_value or data.value
                show_num = qian_num .. "/" .. cell_data.cfg.target_value
            else
                show_num = "<color=#F33535>" .. data.value .. "</color>/" .. cell_data.cfg.target_value
            end
            rate_text.text = show_num
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rate_text", data.status ~= 2)
			if data.status == 2 then
				LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
				btn_img.material = self.m_gray_img.material
				btn_text.text = Language:getTextByKey("new_str_0080")
			elseif data.status == 1 then
				btn_img.material = nil
				LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
				btn_text.text = Language:getTextByKey("new_str_0056")
			else
				btn_img.material = nil
				LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_3", "common_ui")
				btn_text.text = Language:getTextByKey("new_str_0029")
			end
        end
        for k, v in pairs(cell_data.cfg.reward) do
            local itemNode = GameUtil:createItemElement(v, true, true)
            itemNode.transform:SetParent(itemParent.transform, false)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
