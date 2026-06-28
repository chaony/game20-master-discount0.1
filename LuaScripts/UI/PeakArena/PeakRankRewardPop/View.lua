local M = class("PeakRankRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakRankRewardPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "peak_str_0020")	
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:createRewardLoopScroll()
end

--[[
    创建奖励列表
]]
function M:createRewardLoopScroll()
    local data = self.m_model.ranks_rewards
    if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view2:reloadData(data)
    end
end

function M:updateRewardItem(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3) 
        if index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "rank_img", "a_phb_icon_"..index, "common_ui")
        else
            local rank_str = data.id
            if data.id > 3 then
                if index == #self.m_model.ranks_rewards then
                    rank_str = data.rank[1]..Language:getTextByKey("world_boss_str_0031")
                else
                    rank_str = data.rank[1] .."-"..data.rank[2]
                end
            end
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", rank_str)
        end
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        GameUtil:createRewards(reward_node.transform, data.reward, true, true)
    end    
end


return M