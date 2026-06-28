local M = class("LimitNode",LikeOO.OOUIbase)
--限时礼包
M.m_uiName = "OperateActivity/LimitNode"

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self.time_down = self:findText("time_down")
    self.m_end_ts = 0
    self:setSpine()
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] then
            return
        end
        self:refreshUI()
    end
    self.id = id
    self.m_model:initData(url, callFunc, {active_id = data})
end

function M:initUi()
    self:createLoopScroll()
end

function M:switchUI(data, id)
    self.id = id or 0
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_limit_data == nil then
        return
    end
    local data = self.m_model.tag_table[self.m_model.m_sel_tab_index]
    if data.id ~= self.id then
        self.id = data.id
    end
    local active_tab = ConfigManager:getCfgByName("active_recharge")
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_limit_data.actives, self.id) 
    self.m_control:updateTime()
    local active_data = active_tab[self.id]
    self.version = active_data.version
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_limit_cfg(self.version)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
			    self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                    self:updateMsg("buy_sdk_update")
                    return
                end
                local data = self.m_model:getLimitData(self.version,cell_data.id)
                if cell_data.time_limit == 0 then
                    self:updateMsg("buy", cell_data.charge_id)
                elseif cell_data.time_limit - data > 0 then
                    self:updateMsg("buy", cell_data.charge_id)
                else
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0116"), delay_close = 2})    
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
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        local return_per_text = luaBehaviour:FindText("return_per_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        local buy_btn = luaBehaviour:FindImage("buy_btn")
        UIUtil.destroyAllChild(parent.transform)
        local data = self.m_model:getLimitData(self.version, cfg.id)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cfg.gift_name)
        for k,v in pairs(cfg.server_reward) do
            local itemNode = GameUtil:createItemElement(v, true, true, nil, 1)
            itemNode.transform:SetParent(parent.transform, false)
            GameUtil:creatChargeEffect(itemNode, v)
            local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
			if itemLuaBehaviour then
                if cfg.time_limit > 0 and (cfg.time_limit - data) <= 0 then
                    LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", true)
                else
                    LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", false)  
                end
			end
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "count_text", "new_str_0729")
            buy_btn.material = nil
        else
            if cfg.time_limit - data <= 0 then
                buy_btn.material =self.m_gray_image.material
            else
                buy_btn.material = nil
            end   
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "count_text", "gf_str_0050", cfg.time_limit - data)
        end
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278") 
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100).."%"
        end
    end
end

function M:setSpine()
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(410)
    if cfg then
        local icon = cfg.hero_spine
        if self.cacheSpineName == icon then
            return
        else
            self.cacheSpineName = icon
        end
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M