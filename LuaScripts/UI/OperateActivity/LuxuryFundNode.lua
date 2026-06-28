local M = class("LuxuryFundNode",LikeOO.OOUIbase)
--豪华基金
M.m_uiName = "OperateActivity/LuxuryFundNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self:setTextByLanKey("quick_btn_text", "mail_str_0017")
    self:setTextByLanKey("goumaitext", "gf_str_0080")
    self:setTextByLanKey("goumaitext5", "gf_str_0088")
end

function M:switchInit(url, data, id, callback)
    self.c_fund_id = data or 0
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
        if self.m_scroll_view ~= nil then
            self.m_scroll_view:moveToCellIndex(self.m_day or 1)
        end
    end
    self.m_model:initData(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
    if self.m_scroll_view ~= nil then
        self.m_scroll_view:moveToCellIndex(self.m_day or 1)
    end
end

function M:refreshUI()
    if self.m_model.m_sign_data == nil then
        return
    end
    self.sign_fund_data = self.m_model.m_sign_data.high_sign_fund
    self.m_end_ts = self.sign_fund_data.end_ts
    self.m_control:updateTime()
    self.m_day = self.m_model:getDayDiff(self.sign_fund_data.start_ts)
    local fund_cfg = self.m_model:get_sign_cfg(2)
    local get_item = RewardUtil:getProcessRewardData(fund_cfg.first_reward[1])
    local all_item = RewardUtil:getProcessRewardData(fund_cfg.reward_show[1])
    self:setImg(get_item.icon_name, get_item.atlas_name, "get_img")
    self:setImg(all_item.icon_name, all_item.atlas_name, "all_img")
    self:setTextByLanKey("com_num1", get_item.data_num)
    self:setTextByLanKey("com_num3", all_item.data_num)
    self:setTextByLanKey("buy_btn_text", GameUtil:getMoneyTypeNum(fund_cfg.price))
    self:createLoopScroll()
    self:setObjectVisible("quick_btn", self.sign_fund_data.opened == 1)
    self:setObjectVisible("buy_btn", self.sign_fund_data.opened == 0)
    self:setObjectVisible("show_all_img", true)
    self:setObjectVisible("time_down_text", true)
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_high_fund_cfg(self.sign_fund_data.vsn, self.sign_fund_data.days)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            one_line_count = 5, -- 行或列的数量
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.sign_fund_data.opened == 0 then
                    return
                end
                local get_reward = self:getReceived(index)
                if self.m_day >= index  and get_reward == false then --可领
                    self:updateMsg("get_sign_fund", {day = index, high = 1, version = self.sign_fund_data.incr_vsn})
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:updateCell(index, obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local count_text  = luaBehaviour:FindText("count_text")
        local parent = luaBehaviour:FindGameObject("bg")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn", false)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_text", index)
        local get_reward = self:getReceived(index)
        local can_click = true
        if self.m_day >= index  then --可领
            if get_reward == true then --已领
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", false)
                can_click = true
            else
                if self.sign_fund_data.opened == 0 then
                    can_click = true
                else
                    can_click = false
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", true)
            end
        else
            can_click = true
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", false)
        end
        local item_Node = GameUtil:createItemElement(cfg.reward[1], true, can_click)
        item_Node.transform:SetParent(parent.transform, false)
        UIUtil.setScale(item_Node.transform, 0.8)
        local Item_luaBehaviour = UIUtil.findLuaBehaviour(item_Node)
        if Item_luaBehaviour then
            LuaBehaviourUtil.setObjectVisible(Item_luaBehaviour,"duigoudi_img", get_reward == true)
        end
    end
end

function M:getReceived(day)
    for i,v in pairs(self.sign_fund_data.received) do
        if day == v then
            return true
        end
    end
    return false
end

function M:onButtonClick(obj, name)
    if name == "buy_btn" then
        local fund_cfg = self.m_model:get_sign_cfg(2)
        self:updateMsg("buy", fund_cfg.charge_id)
    elseif name == "quick_btn" then
        self:updateMsg("quick_sign_fund", {high = 1, version = self.sign_fund_data.incr_vsn})
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M