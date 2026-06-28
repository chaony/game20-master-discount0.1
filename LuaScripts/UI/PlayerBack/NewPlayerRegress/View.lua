local M = class("NewPlayerRegressView",LikeOO.OOPopBase)

M.m_uiName = "PlayerBack/NewPlayerRegress"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self.selected_index = 3
    self:refreshUI()
    self:lockTouch()
    self.m_control:setOnceTimer(1.2, function ()
        self:unlockTouch()
    end)
end

function M:refreshUI()
    self.selected_index = self.m_model:getCurrentDay()
    self:updateLoopScroll()
end

function M:updateLoopScroll()
    local data = self.m_model:getRewardData()
    local all_cell_size = {}
    for k,v in pairs(data) do
        if self.selected_index == k then
            all_cell_size[k]= Vector2(218, 556)
        else
            all_cell_size[k]= Vector2(128, 556)
        end
    end
    if self.bk_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
            show_data = data,
            all_cell_size = all_cell_size,
			loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateLoopScrollCell(index, cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "little_bg" then
                    self:clickLittleCell(index)
                elseif click_name == "get_btn" then
                    self:updateMsg("get_btn", {day = index})
                end
			end
		}
		self.bk_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.bk_list_scroll:reloadData(data, true, all_cell_size)
	end
end

function M:updateLoopScrollCell(index, cell_object, cell_data)
    local reward_status = self.m_model:getRewardStatus(index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local canvas = cell_object:GetComponent("Canvas")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_bg", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "right_shadow", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_white_mask", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_white_mask", false)
    --选中
    if index == self.selected_index then
        canvas.sortingOrder = 291
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_bg", true)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_display_text", self.m_model:getDayWordContent(index))
        GameUtil:updateItemElement(luaBehaviour:FindGameObject("ItemNode_big"), cell_data[1], true, true, nil, nil, false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn",  reward_status == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_white_mask", reward_status == 2)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "big_complete_flag_img", reward_status == 2)
    else
        local little_bg_obj = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_complete_flag_img", false)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"content_text", self.m_model:getDayWordContent(index))
        GameUtil:updateItemElement(luaBehaviour:FindGameObject("ItemNode_little"), cell_data[1], true, true, nil, nil, false)
        local item_node_little = luaBehaviour:FindGameObject("ItemNode_little")
        local content_text = luaBehaviour:FindGameObject("content_text")
        --左边
         if index < self.selected_index then
             canvas.sortingOrder = 291 + index
             GameUtil:updateResourcesImg(little_bg_obj, "Texture/active/a_dl_weilingquchendi")
             LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg_left", true)
             LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg_right", false)
            --左边已领取
             if reward_status == 2 then
                 LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_white_mask", true)
                 LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_complete_flag_img", true)
                 LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"content_text", "oldPlayer_text_0011")
            --左边未领取
             else
                 
             end
        --右边
         elseif index > self.selected_index then
             LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg_left", false)
             LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg_right", true)
             canvas.sortingOrder = 291 + index
             GameUtil:updateResourcesImg(little_bg_obj, "Texture/active/a_dl_diqitianchendi")
         end
    end
end

function M:clickLittleCell(index)
    self.selected_index = index
    self:updateLoopScroll()
end

return M