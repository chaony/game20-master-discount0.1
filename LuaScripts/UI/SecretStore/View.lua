local M = class("SecretStoreView", LikeOO.OOPopBase)

M.m_uiName = "SecretStore/SecretStorePop"
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()
    self:refreshUI()
    self:setObjectVisible("off_all_text",false)
    --self:setTextByLanKey("off_all_text","secret_store_text1")
    self:setTextByLanKey("rlue_text","secret_store_text2")
    self:setTextByLanKey("day_refund_text","secret_store_text3")
    self:setTextByLanKey("attendance_bonus_text","secret_store_text4")
    self:setTextByLanKey("des_text","secret_store_text8")
    self:setTextByLanKey("close_title_text",ConfigManager:getCfgByName("open_condition")[363].name)
    self:setTextByLanKey("state_text","secret_store_text11")
    local name_text_str = GameUtil:getMoneyTypeNum( self.m_model.m_pack_data.price) .. Language:getTextByKey("secret_store_text1") 
    self:setTextByLanKey("name_text",name_text_str)
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})
end

--拼接倒计时
function M:updateTime()
    --local tabletime = self.m_model.timetable
    --local time = {22 -tabletime.hour,60 -tabletime.min,60 -tabletime.sec}
    --local symbol = ":"
    --local final_text = ""
    --
    --for i = 1,#time - 1 do
    --    final_text = final_text .. time[i] .. symbol
    --end
    --
    --if tonumber(time[#time]) < 10 then
    --    time[#time] = "0" .. time[#time] 
    --end
    --final_text = final_text .. time[#time]
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 3600 then
        local text = GameUtil:formatTimeBySecond(down_time, 2)
        self:setTextByLanKey("time_text","secret_store_text7",text)
    else
        GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        self:updateMsg(99999,nil,"SecretStore.AttendanceBonusPop")
        self:updateMsg(99999)
    end
    
    self:setObjectVisible("discount_img",self.m_model.m_discount ~= 1)
end

function M:refreshUI()
    self:createLoopScroll()
    self:setTextByLanKey("refund_nums_text","secret_store_text12",self.m_model.m_rebate)
    self:setTextByLanKey("signin_nums_text","secret_store_text9",self.m_model.m_record_total_days)
    self:setObjectVisible("off_all_btn",self.m_model.m_once_pay)
    local integer, decimals= math.modf(self.m_model.m_discount * 10)
    self:setTextByLanKey("discount_text","secret_store_text6",integer)
    self:updateRed()
end

function M:updateRed()
    self:setObjectVisible("red_img",self.m_model.m_discount == 1)
    self:setObjectVisible("red_point",self.m_model:getState())
end

function M:createLoopScroll()
    local data = self.m_model.giftbag_data
    
    local temp_data = {}
    local buy_data = {}
    for k,v in ipairs(data) do
        if self.m_model:getGiftBagState(v.charge_id) then
            table.insert(buy_data,v)
        else
            table.insert(temp_data,v)
        end
    end
    
    for k,v in ipairs(buy_data) do
        table.insert(temp_data,v)
    end
    
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = temp_data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateCell(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data.charge_id == 0 then
                    self:updateMsg("get_gift_off", {current_week = self.m_model.timetable.wday , gift_id = 1})
                else
                    self:updateMsg("buy", cell_data.charge_id)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(temp_data)
    end
end

function M:updateCell(obj, index, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local title_text = luaBehaviour:FindText("cell_title_text")
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        local return_per_text = luaBehaviour:FindText("return_per_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        title_text.text = Language:getTextByKey("secret_store_text10")
        return_per_text.text = tostring(GameUtil:formatNum(tonumber(cfg.return_per)* 100)) .. "%"
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_btn_text", "gf_str_0048")
        
        UIUtil.destroyAllChild(parent.transform)
        local get = self.m_model:getGiftBagState(cfg.charge_id)
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278")
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end
        
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", get)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", not get)
        
        local items = GameUtil:createRewards(parent.transform, cfg.reward, true, true, nil)
        for i, v in ipairs(items) do
            local item_luaBehaviour = UIUtil.findLuaBehaviour(v)
            if item_luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "duigoudi_img", get)
            end
        end
        
    end
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M