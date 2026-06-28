local M = class("SuperFundNode",LikeOO.OOUIbase)
--签到基金
M.m_uiName = "OperateActivity/SuperFundNode"

function M:onEnter()
    self.m_end_ts = 0
    self.m_gray_img = self:findImage("gray_img")
    self.time_down = self:findText("time_down")
    self:setObjectVisible("buy_fund_btn", false)
    self:setObjectVisible("loopscroll", false)
    self:setTextByLanKey("time_down_text", "castingSword_str_0028")
    self:setTextByLanKey("fl_num", "gf_str_0500", 30)
    self:setTextByLanKey("fl_text", "gf_str_0501")
    self:setTextByLanKey("title_name_1", "gf_str_0502")
    self:setTextByLanKey("title_name_2", "gf_str_0503")
    self:setTextByLanKey("title_name_3", "gf_str_0504")
    self:setTextByLanKey("title_name_5", "gf_str_0505")
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
            local index = self:getIndex()
            self.m_scroll_view:moveToCellIndex(index)
        end
    end
    self.m_model:initData(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
    if self.m_scroll_view ~= nil then
        local index = self:getIndex()
        self.m_scroll_view:moveToCellIndex(index)
    end
end

function M:refreshUI()
    if self.m_model.m_fund_data == nil or next(self.m_model.m_fund_data) == nil then
        return
    end
    self:setObjectVisible("loopscroll", true)
    self:setObjectVisible("buy_fund_btn", true)
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    self.sign_fund_data = self.m_model.m_fund_data.sign_fund
    self.m_end_ts = self.sign_fund_data.end_ts
    self.m_control:updateTime()
    self.m_day = self.m_model:getDayDiff(self.sign_fund_data.start_ts)
    local fund_cfg = nil
    self.can_get_high = false
    self:setObjectVisible("show_money_obj", true)
    if self.sign_fund_data.opened_lv == 0 then
        fund_cfg = self.m_model:get_sign_cfg(1)
    elseif self.sign_fund_data.opened_lv == 1 then
        fund_cfg = self.m_model:get_sign_cfg(2) 
        local stage_id = ConfigManager:getCommonValueById(464, 412)
        local c_stage_id = UserDataManager:getCurStage()
        if c_stage_id < stage_id then
            self:setObjectVisible("show_money_obj", false)
        else
            if self.m_model:getAddRechargeNumByOpenId(144) <= UserDataManager.charge_sum then
                self.can_get_high = true  
                --金额达到开启条件
            else
                --金额未达到开启条件
                self:setObjectVisible("show_money_obj", false)    
            end
        end
    elseif self.sign_fund_data.opened_lv == 2 then
        fund_cfg = self.m_model:get_sign_cfg(2)
        self:setObjectVisible("show_money_obj", false)
        self.can_get_high = true
    end
    self:setTextByLanKey("buy_fund_text", GameUtil:getMoneyTypeNum(fund_cfg.price))
    self:createLoopScroll()
    self:setObjectVisible("sign_high_bg", self.sign_fund_data.opened_lv >= 1 and self.can_get_high == true)
    self:setObjectVisible("title_name_4", self.sign_fund_data.opened_lv >= 1 and self.can_get_high == true)
    local charge_cfg = self.m_model:getChargeById(fund_cfg.charge_id)
    local diamond_num = 1280
    local diamond_allnum = 3800
    if charge_cfg and next(charge_cfg.diamond) ~= nil then
        diamond_num = charge_cfg.diamond[1][3] or 1280
    end
    if charge_cfg and next(charge_cfg.diamond) ~= nil then
        diamond_allnum = fund_cfg.reward_show[1][3] or 3800
    end
    self:setTextByLanKey("all_reward_num", "gf_str_0110", diamond_allnum)
    self:setTextByLanKey("first_reward_num", "gf_str_0111", diamond_num)
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_sign_fund_cfg(self.sign_fund_data.vsn, self.sign_fund_data.days)
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
                if self.m_day >= index then
                    local free_get, pry_get, high_get = self:getReceived(index)
                    if free_get == false then
                        self:updateMsg("get_sign_fund", {day = index, version = self.sign_fund_data.incr_vsn})
                        return
                    elseif pry_get == false and self.sign_fund_data.opened_lv > 0 then
                        self:updateMsg("get_sign_fund", {day = index, version = self.sign_fund_data.incr_vsn})
                        return
                    elseif high_get == false and self.sign_fund_data.opened_lv > 1 then
                        self:updateMsg("get_sign_fund", {day = index, version = self.sign_fund_data.incr_vsn})
                        return
                    end
                    if self.sign_fund_data.opened_lv == 0 and pry_get == false then
                        local params = {
                            text = Language:getTextByKey("gf_str_0113"),
                            tow_close_btn = true,
                            on_ok_call = function ()
                                local fund_cfg = nil
                                if self.sign_fund_data.opened_lv == 0 then
                                    fund_cfg = self.m_model:get_sign_cfg(1)
                                elseif self.sign_fund_data.opened_lv == 1 then
                                    fund_cfg = self.m_model:get_sign_cfg(2) 
                                elseif self.sign_fund_data.opened_lv == 2 then
                                    fund_cfg = self.m_model:get_sign_cfg(2)
                                end
                                self:updateMsg("buy", fund_cfg.charge_id)
                            end
                        }
                        self:openView("Pops.CommonPop", params)
                    elseif self.sign_fund_data.opened_lv == 1 and   high_get == false then
                        local params = {
                            text = Language:getTextByKey("gf_str_0113"),
                            tow_close_btn = true,
                            on_ok_call = function ()
                                local fund_cfg = nil
                                if self.sign_fund_data.opened_lv == 0 then
                                    fund_cfg = self.m_model:get_sign_cfg(1)
                                elseif self.sign_fund_data.opened_lv == 1 then
                                    fund_cfg = self.m_model:get_sign_cfg(2) 
                                elseif self.sign_fund_data.opened_lv == 2 then
                                    fund_cfg = self.m_model:get_sign_cfg(2)
                                end
                                self:updateMsg("buy", fund_cfg.charge_id)
                            end
                        }
                        local stage_id = ConfigManager:getCommonValueById(464, 412)
                        local c_stage_id = UserDataManager:getCurStage()
                        if c_stage_id < stage_id then
                            return
                        end
                        self:openView("Pops.CommonPop", params)
                    end
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data, true)
    end 
end

function M:updateCell(index, obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title", "gf_str_0028", index)
        local free_itemParent = luaBehaviour:FindGameObject("free_itemParent")
        local pay_itemParent = luaBehaviour:FindGameObject("pay_itemParent")
        local high_itemParent = luaBehaviour:FindGameObject("high_itemParent")
        local free_obj = self:creatOneReward(free_itemParent, cfg.reward_free[1])
        local pay_obj = self:creatOneReward(pay_itemParent, cfg.reward_normal[1])
        local high_obj = nil
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "area_4", self.sign_fund_data.opened_lv >= 1 and self.can_get_high == true)
        if self.sign_fund_data.opened_lv >= 1 then
            high_obj = self:creatOneReward(high_itemParent, cfg.reward_high[1])
        end
        local num_str = ""
        if self.m_day >= index then
            num_str = "<Color=#3D740D>("..index.."/"..index..")</Color>"
        else
            num_str = "<Color=#3A485E>(</Color><Color=#F33535>"..self.m_day.."</Color><Color=#78310E>/"..index..")</Color>"
        end
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", num_str)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "dl_text", "sdk_txt_007")
        
        local free_get, pry_get, high_get = self:getReceived(index)
        self:setLock(free_itemParent, false)
        self:setLock(pay_itemParent, false)
        self:setLock(high_itemParent, false)
        local buy_img = luaBehaviour:FindImage("buy_btn")
        local buy_text = luaBehaviour:FindText("buy_btn_text")
        buy_text.text = Language:getTextByKey("new_str_0056") 
        local free_reward_data = RewardUtil:getProcessRewardData(cfg.reward_free[1])
        local normal_reward_data = RewardUtil:getProcessRewardData(cfg.reward_normal[1])
        local high_reward_data = RewardUtil:getProcessRewardData(cfg.reward_high[1])
        if free_reward_data.quality > 5 or free_reward_data.data_type == 101 then
            if free_reward_data.data_type ~= 107 then
                GameUtil:creatCommonActiveEffect(free_obj)
            end
        end
        if normal_reward_data.quality > 5 or normal_reward_data.data_type == 101 then
            if normal_reward_data.data_type ~= 107 then
                GameUtil:creatCommonActiveEffect(pay_obj)
            end
        end
        if high_reward_data.quality > 5 or high_reward_data.data_type == 101 then
            if high_reward_data.data_type ~= 107 then
                GameUtil:creatCommonActiveEffect(high_obj)
            end
        end
        if self.m_day < index then
            self:setLock(free_obj, true)
            self:setLock(pay_obj, true)
            self:setLock(high_obj, true)
            buy_img.material = self.m_gray_img.material
        else
            buy_img.material = nil
            if free_get == true then
                self:getDuiGou(free_obj, true)
            else
                self:getDuiGou(free_obj, false)
                GameUtil:creatCommonItemEffect(free_obj, free_reward_data.quality)
            end
            if pry_get == true then
                self:getDuiGou(pay_obj, true)
            else
                self:getDuiGou(pay_obj, false)
                if self.sign_fund_data.opened_lv == 0 then
                    self:setLock(pay_obj, true)
                else
                    self:setLock(pay_obj, false)
                    GameUtil:creatCommonItemEffect(pay_obj, normal_reward_data.quality)
                end
                if free_get == true then
                    buy_text.text = Language:getTextByKey("hang_str_0004")
                end
            end
            if self.sign_fund_data.opened_lv >= 1 then
                if high_get == true then
                    self:getDuiGou(high_obj, true)
                else
                    self:getDuiGou(high_obj, false)
                    if self.sign_fund_data.opened_lv == 1 then
                        self:setLock(high_obj, true)
                    else
                        self:setLock(high_obj, false)
                        GameUtil:creatCommonItemEffect(high_obj, high_reward_data.quality)
                    end
                    if free_get == true and pry_get == true then
                        if self.can_get_high == true then
                            buy_text.text = Language:getTextByKey("hang_str_0004")
                        else
                            buy_text.text = Language:getTextByKey("new_str_0056") 
                            buy_img.material = self.m_gray_img.material
                        end
                    end
                end
            end
            if free_get == true and pry_get == true and high_get == true then
                buy_text.text = Language:getTextByKey("new_str_0080")
                buy_img.material = self.m_gray_img.material
            end
        end
    end
end

function M:creatOneReward(patent, itemData)
    UIUtil.destroyAllChild(patent.transform)
    local item = GameUtil:createItemElement(itemData, true, true, nil)
    UIUtil.setScale(item.transform, 0.8)
    item.transform:SetParent(patent.transform, false)
    return item
end


function M:getReceived(day)
    local free_reward = self.sign_fund_data.received["0"] or {}
    local pry_reward = self.sign_fund_data.received["1"] or {}
    local high_reward = self.sign_fund_data.received["2"] or {}
    local free_get = false
    local pry_get = false
    local high_get = false
    for i,v in pairs(free_reward) do
        if day == v then
            free_get = true
            break
        end
    end
    for i,v in pairs(pry_reward) do
        if day == v then
            pry_get = true
            break
        end
    end
    for i,v in pairs(high_reward) do
        if day == v then
            high_get = true
            break
        end
    end
    return free_get, pry_get, high_get
end

function M:setLock(obj, bl)
    if IsNull(obj) then
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_image", bl == true)
    end
end

function M:getDuiGou(obj, bl)
    if IsNull(obj) then
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", bl == true)
    end
end

function M:getIndex()
    local data = self.m_model:get_sign_fund_cfg(self.sign_fund_data.vsn, self.sign_fund_data.days)
    for i = 1, #data do
        if self.m_day >= i then
            local free_get, pry_get, high_get = self:getReceived(i)
            if free_get == false then
                return i
            end
            if self.sign_fund_data.opened_lv >= 1 and pry_get == false then
                return i
            end
            if self.sign_fund_data.opened_lv >= 2 and high_get == false then
                return i
            end
        end
    end
    if self.m_day + 1 >= #data then
        return #data
    end
    return self.m_day + 1
end


function M:onButtonClick(obj, name)
    if name == "buy_fund_btn" then
        local fund_cfg = nil
        if self.sign_fund_data.opened_lv == 0 then
            fund_cfg = self.m_model:get_sign_cfg(1)
        elseif self.sign_fund_data.opened_lv == 1 then
            fund_cfg = self.m_model:get_sign_cfg(2) 
        elseif self.sign_fund_data.opened_lv == 2 then
            fund_cfg = self.m_model:get_sign_cfg(2)
        end
        self:updateMsg("buy", fund_cfg.charge_id)
    elseif name == "quick_btn" then
        self:updateMsg("quick_sign_fund", {high = 0, version = self.sign_fund_data.incr_vsn})
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M