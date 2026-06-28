local M = class("NewComerGiftNode",LikeOO.OOUIbase)
--新手礼包
M.m_uiName = "OperateActivity/NewComerGiftNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
    self:setTextByLanKey("des_text", "castingSword_str_0028")
    self:setObjectVisible("des_text", true)
    self:setObjectVisible("time_down", true)
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] then
            return
        end
        self.m_end_ts = self.m_model:getActiveEndTime(data.actives)
        local active_cfg = self.m_model:getActiveCfg(data.actives)
        self.m_version = 1
        if active_cfg then
            self.m_version = active_cfg.version
        end
		self:refreshUI()
    end
    self.m_model:initData(url, callFunc)
end

function M:initUi()
    self:createLoopScroll(true)
end

function M:switchUI(data, id)
    if self.m_model.m_net_actives == nil then
        return
    end
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_net_actives)
    local active_cfg = self.m_model:getActiveCfg(self.m_model.m_net_actives, id)
    if active_cfg then
        self.m_version = active_cfg.version
    else
        self.m_version = 1
    end
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_gift_new_data == nil or self.m_version == nil then
        return
    end
    self.m_control:updateTime()
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll(is_init)
    self.m_gift_tab = {}
    local data = {}
    if not(is_init) then
        data = self.m_model:get_gift_new_cfg(self.m_version)
    end
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_end_ts > 0 and self.m_model:checkActiveIsEnd(self.m_end_ts) == false then
                    self:updateMsg("buy_sdk_update")
                    return
                end
                self:updateMsg("buy", cell_data.charge_id)
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data, true)
    end 
end

function M:updateCell(obj, cfg)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data = self.m_model:getNewComerData(cfg.id)
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("cell_title_text")
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        local return_per_text = luaBehaviour:FindText("return_per_text")
        local parent = luaBehaviour:FindGameObject("itemParent")
        name_text.text = Language:getTextByKey(cfg.gift_name) 
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil)
        buy_btn_text.text = Language:getTextByKey("gf_str_0029", cfg.price)
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0056") 
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end
        return_per_text.text = GameUtil:formatNum(cfg.return_per * 100).."%"
        if  cfg.time_limit > 0 and data >= cfg.time_limit then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", false)  
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", (cfg.time_limit-data))
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M