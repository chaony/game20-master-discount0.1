local M = class("RacconTinShotRewardPreviewView", LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconTinShotRewardPreview"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0724")
	self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(1)
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    local data = self.m_model:getBigReward()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 6, 
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateData(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "ItemNode" then
                    
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateData(obj, data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local item = luaBehaviour:FindGameObject("ItemNode")
    data = data.cfg
	if #data.reward > 0 then
		local reward = RewardUtil:getProcessRewardData(data.reward[1])
		GameUtil:updateItemElementByData(item,reward, true, true)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text_bg_img",reward.data_num > 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text",reward.data_num > 1)
	end
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"probability_text",  data.show_weight.."%")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Predestined_Glow_001", data.show_effect == 1)
end

function M:destroy()
    M.super.destroy(self)
end

return M