--- 委托
local M = class("TaskRewardMissionNode", LikeOO.OOUIbase)

M.m_uiName = "WorldMapNew/WorldMapTaskReward/TaskRewardMissionNode"
M.m_iphoneXAdapter = true

function M:onEnter()
	self.mission_loopscroll = self:findGameObject("mission_loopscroll")
    self:updateEventLoopScroll()
end

function M:updateEventLoopScroll()
    local data = self.m_model:getMissionData()
    self:findGameObject("mission_loopscroll")
    self.mission_loopscroll:SetActive(#data > 0)
    if #data > 0 then
        if self.m_loop_scroll_view == nil then
            local params = {
                show_data = data,
                loop_scroll_object = self.mission_loopscroll,
                update_cell = function(index, cell_object, cell_data)
                    self:updateScrollViewCell(index, cell_object, cell_data)
                end,
                click_func = function(index, cell_object, cell_data, click_object, click_name)

                end
            }
            self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
        else
            self.m_loop_scroll_view:reloadData(data)
        end
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local cfg = cell_data.cfg

    --0是物品，1是人物
    if cfg.type == 1 then
        LuaBehaviourUtil.setImg(luaBehaviour, "item_img", cfg.icon, "hero_head_ui")
    elseif cfg.type == 0 then
        LuaBehaviourUtil.setImg(luaBehaviour, "item_img", cfg.icon, "item_icon")
    elseif cfg.type == 2 then
        LuaBehaviourUtil.setImg(luaBehaviour, "item_img", cfg.icon, "equip_icon")
    end

    --local show_data = RewardUtil:getProcessRewardData(dataTable)
    --local icon_node = luaBehaviour:FindGameObject("icon_node")
    --GameUtil:createItemElementByData(show_data, false, false, nil, icon_node.transform)

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "mission_name_text", cfg.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "mission_info_text", cfg.Delegation_description)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "done", cell_data.done)
end

return M
