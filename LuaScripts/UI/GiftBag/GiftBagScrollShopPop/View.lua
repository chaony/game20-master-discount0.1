local M = class("GiftBagScrollShopPopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/GiftBagScrollShopPop"
M.m_size_type = 2

function M:onEnter()
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
	if next(self.m_model.bag_list) ~= nil then
		local first_data = self.m_model.bag_list[1]
		self:setTextByLanKey("common_title_text", first_data.gift_name)
	end
end

function M:refreshUI()
	self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
	local data = self.m_model.bag_list
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data, 
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateTimItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "buy_btn" then
					local log_num = self.m_model:getActivityGiftData(cell_data.id)
					local num = cell_data.time_limit - log_num
					if cell_data.time_limit == 0 or (cell_data.time_limit - log_num > 0) then
						self:updateMsg("buy", cell_data.charge_id)
					else
						GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0116"), delay_close = 2}) 	
					end
				end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateTimItem(index, obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.gift_name)
		local log_num = self.m_model:getActivityGiftData(cell_data.id)
		local num = cell_data.time_limit - log_num
		if num < 0 then
			num = 0
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "limit_times_text", "gf_str_0050", num)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_btn_text", GameUtil:getMoneyTypeNum(cell_data.price))
		local btn_img = luaBehaviour:FindImage("buy_btn")
		if cell_data.time_limit == 0 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "limit_times_text", false)
		end
		local get = false
		if cell_data.time_limit > 0 and num == 0 then
			btn_img.material = self.m_gray_img.material
			get = true
		else
			btn_img.material = nil
		end
		local drop = cell_data.reward or {}
		local reward_node = luaBehaviour:FindRectTransform("reward_node")
		self:createTaskRewards(reward_node, drop, get)
	end
end

function M:createTaskRewards(reward_node,rewards, get)
    local rewards = rewards or {}
    local items = {}
    UIUtil.destroyAllChild(reward_node)
    for k,v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, true, true)   
        item.transform:SetParent(reward_node, false)
        table.insert( items, item)
		local itemLuaBehaviour = UIUtil.findLuaBehaviour(item)
		if itemLuaBehaviour then
			LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", get == true)
		end
    end
    return items
end

function M:destroy()
    M.super.destroy(self)
end

return M