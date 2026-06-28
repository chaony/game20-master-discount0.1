local M = class("TotalChargeNode", LikeOO.OOUIbase)
--累计充值
M.m_uiName = "OperateActivity/TotalChargeNode"

function M:onEnter()
    self.m_end_ts = 0
    self.time_down = self:findText("time_down")
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        self.m_cmlt_data = self.m_model.m_cmlt_recharge_data
        self:refreshUI()
    end
    self.node_data = data
    self.m_model:initData(url, callFunc)
end

function M:refreshUI()
    if self.m_cmlt_data == nil then
        return
    end
    self.m_cmlt_data = self.m_model.m_cmlt_recharge_data
    self.m_end_ts = self.m_model:getActiveEndTime(self.m_model.m_cmlt_actives)
    self.m_control:updateTime()
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    local data = self.m_model:get_recharge_cfg(self.m_cmlt_data.version)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
                self:update_Gift(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "get_reward_btn" then
                    local get_bl = self.m_model:getCmltReceived(cell_data.id)
                    if get_bl == false then
                        self:updateMsg("get_cmlt_reward", cell_data.id)
                    else
                        --self:updateMsg("go_to", cell_data.id)
                    end
              
                end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:update_Gift(cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local rewardNode = luaBehaviour:FindGameObject("rewardNode")
        local c_num = self.m_cmlt_data.value > cell_data.price and cell_data.price or self.m_cmlt_data.value
        local show_num = GameUtil:formatNum(c_num)
        local show_max =  GameUtil:switchMoneyType(cell_data.price)
        local get_bl = self.m_model:getCmltReceived(cell_data.id)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_num",  show_num.."/"..show_max)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", cell_data.name)
        GameUtil:createRewards(rewardNode.transform, cell_data.server_reward, true, true)
        if show_num >= show_max then
            LuaBehaviourUtil.setImg(luaBehaviour, "get_reward_btn", "a_ljczshl_btn_lingqu", "active_ui")
            local btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "new_str_0056")
            btn_text.color = Color(105/255, 65/255, 57/255)
        else
            LuaBehaviourUtil.setImg(luaBehaviour, "get_reward_btn", "a_ljczshl_btn_qianwang", "active_ui")    
            local btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "new_str_0029")
            btn_text.color = Color(1, 1, 1)
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_img", get_bl == true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_mask", get_bl == true)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", get_bl == false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_num", get_bl == false)
    end
end

function M:getRewardConfig(id)
    return self.m_cmlt_data.reward_config[tostring(id)]
end


function M:onButtonClick(obj, name)
    if name == "reward_1" then
       
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:setSpine()
    local reward_data = RewardUtil:getProcessRewardData({101, 282, 1})
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
            local play_img = self:findGameObject("hero_spine")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M
