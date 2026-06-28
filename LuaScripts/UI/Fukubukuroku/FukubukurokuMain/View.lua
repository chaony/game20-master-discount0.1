---@class FukubukurokuMainView: OOPopBase
local M = class("FukubukurokuMainView", LikeOO.OOPopBase)

M.m_uiName = "Fukubukuroku/FukubukurokuMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.grade_img = self:findImage("grade_img_slider")
    local active_tab = ConfigManager:getCfgByName("active")
    local title = nil
    for k,v in pairs(active_tab) do
        if v.open_id == self.m_model.open_id and v.version ==self.m_model.version then
            title = v.name
        end
    end
    self:setTextByLanKey("close_title_text", title or "fukubukuroku_text_0001")
    self:bindUI()
    self:refreshUI()
end

function M:refreshUI(flag)
   -- self:updateLoopScroll()
    self:createLoopScroll(flag)
    self:setObjectVisible("share_btn",self.m_model.can_share>0)
    self:setObjectVisible("peak_game_btn_bg",self.m_model.daily==1)
    self:setObjectVisible("peak_game_btn_text",self.m_model.daily==0)
    self:setTextByLanKey("current_day_times","fukubukuroku_text_0005",self.m_model.total_login_days)
    self:setTextByLanKey("reward_node_text","fukubukuroku_text_0009")
    --预览奖励
    local reward_node = self:findGameObject("reward_node")
    GameUtil:createRewards(reward_node.transform, self.m_model.every_data.bag_content, true, true, nil, 1)
    --self:setObjectVisible("reward_node", self.m_model.daily == 0)
    --self:setObjectVisible("reward_node_text", self.m_model.daily == 0)
end




--设置本地化
function M:bindUI()
    self:setTextByLanKey("peak_game_btn_text", "fukubukuroku_text_0002")
    self:setTextByLanKey("share_btn_text", "fukubukuroku_text_0003")
    self:setTextByLanKey("title_txt", "fukubukuroku_text_0004")
end


--[[
    创建礼包列表
]]
function M:createLoopScroll(flag)
    self.m_gift_tab = {}
    local data = self.m_model:getRewardData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll_reward")
        local params = {
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                --self.m_gift_tab[index] = cell_obj
                self:updateItemNode(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("click_btn", {cell_data = cell_data,cell_object = cell_object })
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data,flag or false)
    end
    --self:creatSliderReward()
end

local TextColor = {
    [0] = Color( 98/255, 56/255, 15/255),
    [1] = Color( 199/255, 69/255, 1/255),
    [2] = Color( 165/255, 115/255, 66/255),
}
function M:updateItemNode(index, obj, data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local item_node = LuaBehaviour:FindGameObject("ItemNode")
        local ui_element = GameUtil:updateItemElement(item_node, data.reward[1], true, true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"show_bg",data.status==2)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"bg_get_img",data.status==1)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour,"day_text",data.quest_name)
        LuaBehaviourUtil.setTextColor(LuaBehaviour,"day_text",TextColor[data.status])
    end
end

--[[
	奖励显示
]]
function M:updateLoopScroll()
    self.m_click_cell_object = nil
    local data = self.m_model:getGachaShipRewards(1)
    --self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("reward_preview_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            one_line_count = 2, -- 行或列的数量
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local status = cell_data.status
                if status ~= -1 then
                    self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
                    self.m_click_cell_object = cell_object
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    if cell_data.sort == 1 then
        --大奖
        local lua_behaviour = cell_object:GetComponent("LuaBehaviour")
        if lua_behaviour ~= nil then
            LuaBehaviourUtil.setObjectVisible(lua_behaviour,"UI_Reward_LingQu_003",true)
        end
    end
    GameUtil:updateItemElement(cell_object, cell_data.reward[1], true, true)
end

function M:destroy()
    M.super.destroy(self)
end

return M
