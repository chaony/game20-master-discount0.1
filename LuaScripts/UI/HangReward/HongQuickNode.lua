--- 快速挂机
local M = class("HongQuickNode",LikeOO.OOUIbase)

M.m_uiName = "HangReward/HongQuickNode"
M.m_iphoneXAdapter = true

local xh = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND, 0, 0}

function M:onEnter()
    self:setTextByLanKey("time_desc_text", "qh_str_0002")
    self:setTextByLanKey("num_desc_text","qh_str_0004")
    self:setTextByLanKey("no_pop_text","hang_str_0003")
    self:setTextByLanKey("cancle_text", "new_str_0998")
    self:setTextByLanKey("title_text2", "hongquick_get_tips2")
    self.m_gray_img = self:findImage("gray_img")
    self:setTime()
    self:refreshUI()    
    self:setGetImg()
end

function M:refreshUI()
    self:setTextByLanKey("num_text", self.m_model.m_quick_idle_times)
    self:updateRewardLoopScroll()
    local cfg = self.m_model:getCost()
    local q_item = self.m_model:getQuickItem()
    local itemData = RewardUtil:getProcessRewardData(cfg)
    if self.m_model:quickFree() == true then
        local ok_text = self:setTextByLanKey("get_quick_btn_text", "qh_str_0010")
		UIUtil.setLocalPosition(ok_text.transform, 0)
		self:setObjectVisible("money_img", false)
        self:setObjectVisible("cost_item", false)
        self:setObjectVisible("num_desc_text", false)
    elseif q_item.user_num > 0 then
        self:setImg(q_item.icon_name, q_item.atlas_name ,"money_img")
        self:setImg(q_item.icon_name, q_item.atlas_name ,"cost_item_img")
        local ok_text = self:setTextByLanKey("get_quick_btn_text", "qh_str_0011", q_item.data_num)
        self:setTextByLanKey("cost_item_num", q_item.user_num)
        UIUtil.setLocalPosition(ok_text.transform, 20)
        self:setObjectVisible("cost_item", true)
        self:setObjectVisible("num_desc_text", false)
        self:setObjectVisible("money_img", true)
    else
        self:setImg(itemData.icon_name, itemData.atlas_name ,"money_img")
		local ok_text = self:setTextByLanKey("get_quick_btn_text", "qh_str_0011", itemData.data_num)
		UIUtil.setLocalPosition(ok_text.transform, 20)
		self:setObjectVisible("money_img", true)
        self:setObjectVisible("cost_item", false)
        self:setObjectVisible("num_desc_text", true)
    end
    local get_quick_btn = self:findImage("get_quick_btn")
    if self.m_model.m_quick_idle_times == 0 then
        get_quick_btn.material = self.m_gray_img.material
    else
        get_quick_btn.material = nil
    end
    if  UserDataManager:hasHangRewardSubscribe() then
        self:setTextByLanKey("privilege_btn_text", "new_str_0821")
        self:findImage("privilege_btn").material = nil
    else
        self:setTextByLanKey("privilege_btn_text", "bounty_str_0018")
        self:findImage("privilege_btn").material =  self.m_gray_img.material
    end

end

--[[
    掉落列表
]]
function M:updateRewardLoopScroll()
    local tab_show_get = {
        {RewardUtil.REWARD_TYPE_KEYS.DUST, 0, 0},
        {RewardUtil.REWARD_TYPE_KEYS.COIN, 0, 0},
        {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0},
        {RewardUtil.REWARD_TYPE_KEYS.EXP, 0, 0},
    }
    local equip_exp = self.m_model:getIdleEquipExp()
    if equip_exp > 0 then
        table.insert( tab_show_get, {RewardUtil.REWARD_TYPE_KEYS.EQUIP_EXP, 0, 0})
    end
    local rewards = self.m_model:getQuickShowReward()
    for i = 1, #rewards do
        table.insert(tab_show_get, rewards[i])
    end
    self.m_reward_cell_tab = {}   
    if self.m_reward_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
			show_data = tab_show_get,
			one_line_count = 6,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                if cell_data[3] == 0 then
                    cell_data[3] = self.m_model:getNumByType(cell_data[1])
                end
                local itemData = RewardUtil:getProcessRewardData(cell_data)
                GameUtil:updateItemElement(cell_obj, cell_data, true, true)
            end,
        }
        self.m_reward_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_scroll_view:reloadData(tab_show_get)
    end 
end

function M:setGetImg()
    self:setObjectVisible("get_img", self.m_model.m_no_get_pop == 1)
end

function M:setTime()
    self:setTextByLanKey("downTime_text", "qh_str_0003", self.m_model:getDownEndTime())
end


return M