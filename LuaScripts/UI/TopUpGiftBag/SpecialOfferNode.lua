local M = class("SpecialOfferNode",LikeOO.OOUIbase)
--特惠礼包
M.m_uiName = "OperateActivity/SpecialOfferNode"


function M:onEnter()
    self.m_end_ts = -1
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        self.m_end_ts = self.m_model:getActiveEndTime(data.actives, self.id)
        self:refreshUI()
    end
    self.id = id or 0
    self.m_model:initData(url, callFunc)
end

function M:switchUI(data, id)
    if self.m_model.m_gift_off_data == nil then
        return
    end
    self.id = id or 0
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_gift_off_actives, self.id)
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_gift_off_data  == nil or self.id == nil then
        return
    end
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    self.m_version = active_tab[self.id].version
    self.m_gift_data = self.m_model.m_gift_off_data[tostring(self.m_version or 1)]
    if self.m_gift_data == nil then
        return
    end
    self:createLoopScroll()
    self:setTextByLanKey("day_text", "gf_str_0016", 6)
    if self.m_gift_data.once_pay > 0 or #self.m_gift_data.pays > 0 then
        self:setObjectVisible("off_all_btn", false)
    else
        self:setObjectVisible("off_all_btn", true) 
    end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local cfg = self.m_model:get_gift_off_cfg(self.id)
    local data = {}
    self.pack_cfg = nil
    local original_price = 0
    for k,v in pairs(cfg) do
        if v.type == 1 then
            data[k] = v
            original_price = v.price + original_price
        elseif v.type == 2 then
            self.pack_cfg = v  
        end
    end
    if self.pack_cfg then
        if self.m_gift_data.once_pay > 0 or #self.m_gift_data.pays > 0 then
            self:setTextByLanKey("pack_price_text", "gf_str_0048")
            self:setObjectVisible("zhekou_img", false)
        else
            self:setTextByLanKey("pack_price_text", "gf_str_0047", GameUtil:getMoneyTypeNum(self.pack_cfg.price))
            self:setObjectVisible("zhekou_img", true)
            self:setTextByLanKey("all_price_text", "new_str_1142")
        end
    end
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                    self:updateMsg("buy_sdk_update")
                    return
                end
                if cell_data.charge_id == 0 then
                    self:updateMsg("get_gift_off", {vsn = self.m_version, id = cell_data.id})
                else
                    self:updateMsg("buy", cell_data.charge_id)
                end
        
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:updateCell(obj, index, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local title_text = luaBehaviour:FindText("cell_title_text")
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        title_text.text = Language:getTextByKey(cfg.gift_name) 
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_btn_text", "gf_str_0048")
        UIUtil.destroyAllChild(parent.transform)
        local get = false --是否已购买
        local gift_cfg = self.m_model:getGiftOffData(self.m_version, cfg.id)
        local pay_cfg = self.m_model:getBuyGiftOffData(self.m_version, cfg.id)
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278") 
            if gift_cfg == true then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", 0)
                get = true
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", false)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", 1)
            end
        else
            if pay_cfg == true or self.m_gift_data.once_pay > 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", 0)
                get = true
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", false)
                if pay_cfg == true then
                    buy_btn_text.text = Language:getTextByKey("new_str_0056") 
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", 0)
                    get = true
                else
                    buy_btn_text.text =  GameUtil:getMoneyTypeNum(cfg.price)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", 1)
                end
            end
        end
        local items = self:createRewards(parent.transform, cfg.reward, true, true, nil, 1)
        for i,v in ipairs(items) do
            local item_luaBehaviour = UIUtil.findLuaBehaviour(v)  
            if item_luaBehaviour then
                if get == true then
                    LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "duigoudi_img", true)
                else
                   LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "duigoudi_img", false)     
                end
            end
        end
    end
end

function M:onButtonClick(obj, name)
    if name == "off_all_btn" then
        if self.pack_cfg then
            if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                self:updateMsg("buy_sdk_update")
                return
            end
            self:updateMsg("buy", self.pack_cfg.charge_id)
        end
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:createRewards(reward_node, rewards, is_show_num, is_show_detail, callback, scale, frame_effect)
    local rewards = rewards or {}
    UIUtil.destroyAllChild(reward_node)
    local items = {}
    scale = scale or 1
    UIUtil.destroyAllChild(reward_node)
    for k,v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, is_show_num, is_show_detail, callback, frame_effect)   
        item.transform:SetParent(reward_node, false)
        table.insert( items, item)
        UIUtil.setScale(item.transform, scale)
    end
    return items
end

function M:destroy()
    M.super.destroy(self)
end


return M