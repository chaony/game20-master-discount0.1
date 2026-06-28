local M = class("GeneraGiftBagNode", LikeOO.OOUIbase)
--通用礼包
M.m_uiName = "OperateActivity/GeneraGiftBagNode"

function M:onEnter()
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
    self.m_type = data
    self.m_model:initData(url, callFunc, {type = data})
    self:setSpine()
end

function M:switchUI(data)
    self:setObjectVisible("title_img_node", true)
    self.m_type = data
    self:setSpine()
    self:refreshUI()
end

function M:initUi()
    self:setObjectVisible("title_img_node", false)
end

function M:refreshUI()
    if self.m_model.m_supervalu_data == nil then
        return
    end
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = {}
    for i = 1,3 do
        self:setObjectVisible("texture_"..i, i == self.m_type)
    end
    if self.m_type == 1 then
      data = self.m_model:get_gift_daily_cfg()
      self:setTextByLanKey("title_text", "gf_str_0008")
    elseif self.m_type == 2 then
      data = self.m_model:get_gift_week_cfg()
      self:setTextByLanKey("title_text", "gf_str_0009")
    elseif self.m_type == 3 then
      data = self.m_model:get_gift_month_cfg()
      self:setTextByLanKey("title_text", "gf_str_0010")
    end
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateCell(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data.charge_id == 0 then
                    self:updateMsg("get_free", {reward_id = cell_data.id, type = self.m_type, incr_vsn = self.m_model.m_supervalu_data.incr_vsn or 1})
                else
                    self:updateMsg("buy", cell_data.charge_id)
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
        local name_text = luaBehaviour:FindText("cell_title_text")
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        local return_per_text = luaBehaviour:FindText("return_per_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        name_text.text = Language:getTextByKey(cfg.gift_name) 
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true)
        local data = self.m_model:getBagComData(cfg.id) or 0
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278")
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        
        local all_time = self.m_model.vip_gift_times + cfg.time_limit
        if cfg.time_limit > 0 and data and data >= all_time then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", true)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", false) 
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", (all_time-data))
        end
    end
end

function M:setSpine()
    local cfg = nil
    if self.m_type == 1 then
        cfg = UserDataManager.hero_data:getHeroConfigByCid(206)
    elseif self.m_type == 2 then
        cfg = UserDataManager.hero_data:getHeroConfigByCid(281)
    elseif self.m_type == 3 then
        cfg = UserDataManager.hero_data:getHeroConfigByCid(208)
    end
   
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
