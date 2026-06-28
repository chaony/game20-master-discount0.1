local M = class("OnTimePopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/OnTimePop"
M.m_size_type = 2

function M:onEnter()
    self.bg_down_time = self:findGameObject("bg_down_time")
    self:setTextByLanKey("get_reward_text", "new_str_0056")
	self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(self.m_model.m_online_reward.config or 1)
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_online_tab()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 6, 
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateTimItem(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
           
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateTimItem(index, obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data = cell_data.cfg
    if LuaBehaviour then
        local itemPrefabe = LuaBehaviour:FindGameObject("itemPrefabe")
        UIUtil.destroyAllChild(itemPrefabe.transform)
        local reward_node = data.reward[1]
        local item = GameUtil:createItemElement(reward_node, true, true)
        if index%6 == 0 then
            local itemdata = RewardUtil:getProcessRewardData(reward_node)
            GameUtil:creatCommonActiveEffect(item, itemdata.quality, 1)
        end
        item.transform:SetParent(itemPrefabe.transform, false)
        UIUtil.setScale(item.transform, 1.1)
        local Item_LuaBehaviour = UIUtil.findLuaBehaviour(item)
        if Item_LuaBehaviour then
            if self.m_model.m_online_reward.config == -1 or self.m_model.m_online_reward.config > cell_data.id then
                LuaBehaviourUtil.setObjectVisible(Item_LuaBehaviour, "duigoudi_img", true)
            else
                LuaBehaviourUtil.setObjectVisible(Item_LuaBehaviour, "duigoudi_img", false)
            end
        end
    end
end

function M:updateTime()
    local cur_cfg = self.m_model:getCurOnlineCfg()
    if cur_cfg then
        if cur_cfg <= 0 then
            self:setObjectVisible("get_reward_btn", true)
            self:setTextByLanKey("down_time_text", Language:getTextByKey("new_str_0655"))
        else
            self:setObjectVisible("get_reward_btn", false)
            self:setTextByLanKey("down_time_text", GameUtil:formatTimeBySecond(cur_cfg, 999))
        end
        self.bg_down_time.transform:SetParent(self.m_gift_tab[self.m_model.m_online_reward.config].transform, false)
        self.bg_down_time.transform.localPosition = Vector3(0,32,0)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M