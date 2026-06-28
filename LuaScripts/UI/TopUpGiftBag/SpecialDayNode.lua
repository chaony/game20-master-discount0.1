local M = class("SpecialDayNode",LikeOO.OOUIbase)
--皮肤礼包
M.m_uiName = "OperateActivity/SpecialDayNode"

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self:setTextByLanKey("des_text", "castingSword_str_0028")
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self:showUI(false)
end

function M:switchInit(url,data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] then
            return
        end
        self.m_end_ts = self.m_model:getActiveEndTime(data.actives)
        self.m_control:updateTime()
        self:refreshUI()
    end
    self.m_model:initData(url, callFunc, {active_id = data})
end

function M:switchUI(data, id)
    if self.m_model.m_skin_gift_data == nil then
        return
    end
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_skin_gift_data.actives)
    self.m_control:updateTime()
    self:refreshUI()
end


function M:refreshUI()
    if self.m_model.m_skin_gift_data == nil then
        return
    end
    self:showUI(true)
    self:createLoopScroll()
    self:setSpine()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_skip_cfg()
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
                local data = self.m_model:getActivityGiftData(cell_data.id)
                if cell_data.time_limit > 0 and cell_data.time_limit - data <= 0 then
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0116"), delay_close = 2})  
                    return
                end
                self:updateMsg("buy", cell_data.charge_id)
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data,true)
    end 
end

function M:updateCell(index, obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("title_text")
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        local return_per_text = luaBehaviour:FindText("return_per_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        name_text.text = Language:getTextByKey(cfg.gift_name) 
        local data = self.m_model:getActivityGiftData(cfg.id)
        local buy_btn = luaBehaviour:FindImage("buy_btn")
        UIUtil.destroyAllChild(parent.transform)
        local items = self:creatRewards(parent.transform,cfg.reward)
        buy_btn_text.text = Language:getTextByKey("gf_str_0029", cfg.price)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_img", false)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cfg.gift_name)
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0056") 
        else
            buy_btn_text.text =  GameUtil:getMoneyTypeNum(cfg.price)
        end
        return_per_text.text = GameUtil:formatNum(cfg.return_per * 100).."%"
        local get = false
        if cfg.time_limit - data <= 0 then
            buy_btn.material =self.m_gray_image.material
            get = true
        else
            buy_btn.material = nil
        end  
        local num = cfg.time_limit - data
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", num)
        for k,v in pairs(items) do
            local itemLuaBehaviour = UIUtil.findLuaBehaviour(v)
			if itemLuaBehaviour then
                LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", get == true)
			end
        end
    end
end

function M:creatRewards(parent, rewards)
    UIUtil.destroyAllChild(parent)
    local items = {}
    for k, v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, true, true)
        local data = RewardUtil:getProcessRewardData(v)
        item.transform:SetParent(parent, false)
        items[k] = item
        if data.data_type == 130 then
            GameUtil:creatCommonActiveEffect(item)
        end
    end
    return items
end


function M:setSpine()
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(310)
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

function M:showUI(bl)
    self:setObjectVisible("des_text", bl)
    self:setObjectVisible("time_down", bl)
end

function M:destroy()
    M.super.destroy(self)
end


return M