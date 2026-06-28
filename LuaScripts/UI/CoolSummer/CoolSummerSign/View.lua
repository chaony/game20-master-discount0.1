---@class CoolSummerSignView: OOPopBase
---@field m_model CoolSummerSignModel
local M = class("CoolSummerSignView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversarySign"
M.m_size_type = 2
M.m_iphoneXAdapter = true

M.btn_tab = {day_1 = 1, day_2 = 2, day_3 = 3, day_4 = 4, day_5 = 5, day_6 = 6, day_7 = 7}
function M:onEnter()
    RedPointUtil:saveLocalRedPointFreshTime("half_year_signIn_once")
    self.avtive_data = self.m_model:getActiveData()
    if self.avtive_data then
        self:setTextByLanKey("close_title_text", self.avtive_data.name )
    end
    --清凉夏日
    local image_name = self:findImage("bg1")
    GameUtil:updateResourcesImg( image_name, "Texture/map_plot/a_map_juqing_bg_155")
    
    self:refreshUI()
    self:setSpine()
end

function M:refreshUI()
    self:updateRewardNodes()
end

function M:hideUI()
    self:setObjectVisible("CommonCloseNode", false)
    self:setObjectVisible("Node_UI", false)
end

function M:showUI()
    self:setObjectVisible("CommonCloseNode", true)
    self:setObjectVisible("Node_UI", true)
end

function M:updateRewardNodes()
    for day = 1, 7 do
        local day_node = self:findGameObject("day_" .. day)
        local luaBehaviour = UIUtil.findLuaBehaviour(day_node)
        if luaBehaviour then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"tit_text","day_str_" .. day)
            local is_sign = self.m_model:isSignByDay(day)
            local sign_reward_data = self.m_model:getSignRewardByDay(day)
            local day_status = self.m_model:getStatusByDay(day)
            local bg_name = ""
            if day_status == 0 then
                bg_name = "a_hd_xnhd_xnjf_qddb2"
            elseif day_status == 1 then
                bg_name = "a_hd_xnhd_xnjf_qddb3"
            elseif day_status == 2 then
                bg_name = "a_hd_xnhd_xnjf_qddb1"
            end
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"light_img", self.m_model:isToday(day) and day_status == 1)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"get_img", day_status == 2)
            local image_name = luaBehaviour:FindImage("day_" .. day)
            GameUtil:updateResourcesImg( image_name, "Texture/" .. bg_name)
            image_name:SetNativeSize()
            if sign_reward_data then
                local reward_data = RewardUtil:getProcessRewardData(sign_reward_data)
                local item_node = luaBehaviour:FindGameObject("ItemNode")
                local ui_element = GameUtil:updateItemElementByData(item_node, reward_data, true, true)
                ui_element.red_point_img:SetActive(false)
                if day_status == 2 then
                    ui_element.duigoudi_img:SetActive(true)
                    LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour,"duigou_img",false)
                    LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour,"duigoudi_img",true)
                end
            end
        end
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = ""
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(down_time)
        format = format or 0
        if day > 0 then
            text = string.format(Language:getTextByKey("new_str_0415"), day)
        else
            if hour > 0 then
                text = string.format("%02d:%02d:%02d", hour, min, sec)
            else
                if format == 1 then
                    if min > 0 then
                        text = string.format("%02d:%02d", min, sec)
                    else
                        text = string.format("%d", sec)
                    end
                else
                    text = string.format("%02d:%02d", min, sec)
                end
            end
        end
        self:setTextByLanKey("time_text","new_str_1028", text)
    else
        self:updateMsg(99999)
    end
end


function M:setSpine()
    --local heroDatas = {130,41202,1}
    --local reward_data = RewardUtil:getProcessRewardData(heroDatas)
    --if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
    --    local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
    --    if cfg then
    --        local icon = cfg.hero_spine
    --        if self.cacheSpineName == icon then
    --            return
    --        else
    --            self.cacheSpineName = icon
    --        end
    --
    --    end
    --elseif reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
    --    local cur_skin_cfg = ConfigManager:getHeroSkinCfg(reward_data.data_id)
    --    local icon = cur_skin_cfg.hero_spine
    --    if self.cacheSpineName == icon then
    --        return
    --    else
    --        self.cacheSpineName = icon
    --    end
    --end
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/hero_0101_yongzhuang_SkeletonData", "idle", 0, true)
    self:setObjectVisible("hero_spine", true)
end

return M