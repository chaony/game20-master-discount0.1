local M = class("GiftBagView",LikeOO.OOUIbase)
--成长基金
M.m_uiName = "OperateActivity/GifBagGrowUpFundNode"

function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    self.end_ts_tab = {}
    self:setObjectVisible("loopscroll", false)
    --local str = Language:getTextByKey("gf_str_0500", 40) .. Language:getTextByKey("gf_str_0501")
    --self:setTextByLanKey("title_text", str)
    self:setTextByLanKey("title_name_1", "gf_str_0502")
    self:setTextByLanKey("title_name_2", "gf_str_0503")
    self:setTextByLanKey("title_name_3", "gf_str_0093")
    self:setTextByLanKey("title_name_4", "gf_str_0505")
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.c_fund_id = data or 0
    self.m_model:initData(url, callFunc, {fund_id = data})
end

function M:switchUI()
    --for k, v in pairs(self.m_model.m_fund_data.actives or {}) do
    --    if v.open_id and v.open_id == 85 then
    --        self.m_end_ts = v.remain_ts + UserDataManager:getServerTime()
    --    end
    --end
    --if self.m_end_ts ~= nil then
    --    self:setObjectVisible("time_bg", true)
    --end
    
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_fund_data == nil then
        return
    end
    self:setObjectVisible("loopscroll", true)
    self.chapter_num = self.m_model:getChapterNum()
    --local fund_cfg = self.m_model:get_growth_fund(85)
    local fund_cfg = self.m_model:get_growth_fund(85)
    self:setText("des_text", fund_cfg.fund_des1)
    self:setText("title_text", fund_cfg.fund_info)
    self:setText("get_text", fund_cfg.fund_des2)
    --self:setTextByLanKey("des_text", "gf_str_0108", self:getAllMoney())
    self:setTextByLanKey("buy_fund_text", GameUtil:getMoneyTypeNum(fund_cfg.price))
    self:createLoopScroll()
    self:setObjectVisible("buy_fund_btn", self.m_model.m_fund_data.fund_status_new[tostring(85)] == nil)
    self:setObjectVisible("get_img", self.m_model.m_fund_data.fund_status_new[tostring(85)] == nil)
    if self.m_scroll_view ~= nil then
        local index = self:getIndex()
        self.m_scroll_view:moveToCellIndex(index)
    end
    --[[
    local charge_cfg = self.m_model:getChargeById(fund_cfg.charge_id)
    local diamond_num = 1280
    if next(charge_cfg.diamond) ~= nil then
        diamond_num = charge_cfg.diamond[1][3] or 1280
    end
    self:setTextByLanKey("get_text", "gf_str_0109", diamond_num)
    ]]--
end

function M:getAllMoney()
    local sub_num = 0
    local data = self.m_model:get_linshi_fund(85)
    for k,v in pairs(data) do
        local reward_num = v.reward[1][3]
        sub_num = sub_num + reward_num
    end
    return sub_num
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_linshi_fund(85)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local data = self.m_model:getFundData(cell_data.id)
                local can_get = tonumber(GameUtil:BitAnd(data.status,1)) or 0  --可领
                if can_get > 0 then
                    local free_get = tonumber(GameUtil:BitAnd(data.status,2)) or 0  --已领（免费）
                    local pay_get = tonumber(GameUtil:BitAnd(data.status,4)) or 0 --已领（付费）
                    if free_get > 0 and pay_get > 0 then
                        return
                    end
                    if free_get > 0 and pay_get == 0 and self.m_model.m_fund_data.fund_status_new[tostring(85)] == nil then
                        local params = {
                            text = Language:getTextByKey("gf_str_0113"),
                            tow_close_btn = true,
                            on_ok_call = function ()
                                local fund_cfg = self.m_model:get_growth_fund(85)
                                self:updateMsg("buy", fund_cfg.charge_id)
                            end
                        }
                        self:openView("Pops.CommonPop", params)
                        return
                    end
                    self:updateMsg("get_fund", {reward_id = cell_data.id, open_id = 85} )
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
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title", "gf_str_0114", (cfg.target_value-1))
        local free_itemParent = luaBehaviour:FindGameObject("free_itemParent")
        local pay_itemParent = luaBehaviour:FindGameObject("pay_itemParent")
        local free_obj = self:creatOneReward(free_itemParent, cfg.reward_free[1])
        local pay_obj = self:creatOneReward(pay_itemParent, cfg.reward[1])
        local data = self.m_model:getFundData(cfg.id)
        local can_get = tonumber(GameUtil:BitAnd(data.status,1)) or 0  --可领
        local free_get = tonumber(GameUtil:BitAnd(data.status,2)) or 0  --已领（免费）
        local pay_get = tonumber(GameUtil:BitAnd(data.status,4)) or 0 --已领（付费）
        local buy_img = luaBehaviour:FindImage("buy_btn")
        local buy_text = luaBehaviour:FindText("buy_btn_text")
        local num_str = ""
        if self.chapter_num >= cfg.target_value then
            num_str = "<Color=#3D740D>("..cfg.target_value.."/"..cfg.target_value..")</Color>"
        else
            num_str = "<Color=#3A485E>(</Color><Color=#F33535>"..self.chapter_num.."</Color><Color=#3A485E>/"..cfg.target_value..")</Color>"
        end
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", num_str)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_text", false)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title2", "gf_str_0506")
        if can_get > 0 then
            buy_img.material = nil
            if free_get == 0 then
                buy_text.text = Language:getTextByKey("new_str_0056") 
            else
                if pay_get == 0 then
                    buy_text.text = Language:getTextByKey("hang_str_0004")
                    self:getDuiGou(free_obj, true)
                else
                    buy_img.material = self.m_gray_img.material
                    buy_text.text = Language:getTextByKey("new_str_0058")
                    self:getDuiGou(free_obj, true)
                    self:getDuiGou(pay_obj, true)
                end
            end
            if free_get == 0 then
                local free_reward_data = RewardUtil:getProcessRewardData(cfg.reward_free[1])
                GameUtil:creatCommonItemEffect(free_obj, free_reward_data.quality)
            end
            if self.m_model.m_fund_data.fund_status_new[tostring(85)] ~= nil and pay_get == 0 then
                local pay_reward_data = RewardUtil:getProcessRewardData(cfg.reward[1])
                GameUtil:creatCommonItemEffect(pay_obj, pay_reward_data.quality)
            end
            self:setLock(free_obj, false )
            self:setLock(pay_obj, self.m_model.m_fund_data.fund_status_new[tostring(85)] == nil)
        else
            buy_img.material = self.m_gray_img.material
            buy_text.text = Language:getTextByKey("new_str_0056")
            self:setLock(free_obj, true)
            self:setLock(pay_obj, true)
        end
    end
end

function M:setLock(obj, bl, item_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_image", bl == true)
    end
end

function M:getDuiGou(obj, bl)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", bl == true)
    end
end

function M:creatOneReward(patent, itemData)
    UIUtil.destroyAllChild(patent.transform)
    local item = GameUtil:createItemElement(itemData, true, true, nil)
    UIUtil.setScale(item.transform, 0.8)
    item.transform:SetParent(patent.transform, false)
    return item
end

function M:getIndex()
    local fund_table = self.m_model:get_linshi_fund(85)
    for i = 1, #fund_table do
        local cell_data = fund_table[i]
        local data = self.m_model:getFundData(cell_data.id)
        if data then
            local can_get = tonumber(GameUtil:BitAnd(data.status,1)) or 0  --可领
            local free_get = tonumber(GameUtil:BitAnd(data.status,2)) or 0  --已领（免费）
            local pay_get = tonumber(GameUtil:BitAnd(data.status,4)) or 0 --已领（付费
            if can_get > 0 then
                if self.m_model.m_fund_data.fund_status_new[tostring(85)] == nil then
                    if free_get == 0 then
                        return i
                    end
                else
                    if free_get == 0 or pay_get == 0 then
                        return i
                    end
                end
            end
        end
    end
    for i = 1, #fund_table do
        local cell_data = fund_table[i]
        local data = self.m_model:getFundData(cell_data.id)
        if data then
            local can_get = tonumber(GameUtil:BitAnd(data.status,1)) or 0  --可领
            local free_get = tonumber(GameUtil:BitAnd(data.status,2)) or 0  --已领（免费）
            local pay_get = tonumber(GameUtil:BitAnd(data.status,4)) or 0 --已领（付费
            if can_get == 0 then
                return i
            end    
        end
    end
    return 1
end

function M:onButtonClick(obj, name)
    if name == "buy_fund_btn" then
        local fund_cfg = self.m_model:get_growth_fund(85)
        self:updateMsg("buy", fund_cfg.charge_id)
    else
        M.super.onButtonClick(self, obj, name)
    end
end

--function M:updateTime()
--    if self.m_end_ts ~= nil then
--        local time_end = self.m_end_ts - UserDataManager:getServerTime()
--        self:setTextByLanKey("time_down", GameUtil:formatTimeBySecond(time_end))
--        if time_end <= 0 then
--            self:updateMsg(99999)
--        end
--    end
--end

function M:destroy()
    M.super.destroy(self)
end


return M