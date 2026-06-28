local M = class("SignInFundPopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/SignInFundPop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
    local cfg = self.m_model:get_sign_cfg()
    self:setTextByLanKey("common_title_text", cfg.card_name)
    if self.m_scroll_view == nil and self.m_day then 
        self.m_scroll_view:moveToCellIndex(self.m_day)
    end
end

function M:refreshUI()
    self.sign_fund_data = self.m_model.m_sign_data
    self.m_day = GameUtil:formatNum(self.m_model:getDayDiff(self.sign_fund_data.start_ts)) 
	self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getCfgTab(self.sign_fund_data.vsn, self.sign_fund_data.days)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            one_line_count = 6, -- 行或列的数量
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
                    self:updateMsg("get_sign_fund", {day = index, high = self.m_model.m_high, version = self.sign_fund_data.incr_vsn})
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
        UIUtil.destroyAllChild(parent.transform)
        local item_Node = GameUtil:createItemElement(cfg.reward[1], true, can_click, function ()
            if self.sign_fund_data.opened == 0 then
                return
            end
            local get_reward = self:getReceived(index)
            if self.m_day >= index  and get_reward == false then --可领
                self:updateMsg("get_sign_fund", {day = index, high = self.m_model.m_high, version = self.sign_fund_data.incr_vsn})
            end
        end)
        item_Node.transform:SetParent(parent.transform, false)
        GameUtil:creatChargeEffect(item_Node, cfg.reward[1])
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



return M