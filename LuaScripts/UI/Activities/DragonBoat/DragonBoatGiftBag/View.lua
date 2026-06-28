---@class DeliciousFeastGiftBagView: OOPopBase
---@field m_model DragonBoatGiftBagModel
local M = class("DragonBoatGiftBagView",LikeOO.OOPopBase)

M.m_uiName = "Activities/DragonBoat/DragonBoatGiftBag"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    local activityXlsxData = self.m_model:getXlsxActivityByOpenId(self.m_model.m_open_id, true)
    self.m_model.active_name = activityXlsxData.name
    self:setTextByLanKey("close_title_text", activityXlsxData.name)
    self:setTextByLanKey("text_timer_title", "flower_text_0023")
    local isOfficial = self.m_model:checkIsOfficial()
    local spine_name = self.m_model:getSpineName()
    local spine_img
    --if isOfficial then
    --    spine_img = self:findGameObject("meituan_spine")
    --    GameUtil:updateSpineLoadSet(spine_img,"RoleSpine/" .. spine_name.meituan,"idle", 0,true)
    --else
        spine_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(spine_img,"RoleSpine/" .. spine_name.xian,"idle", 0,true)
    --end
    self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
    self:updateTime()
end


function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_ladderGiftData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local cfg = cell_data.xlsxData
                if cfg.price == 0 then
                    self:updateMsg("get_free_ladder_gift", { id = cfg.id} )
                else
                    self:updateMsg("buy", cell_data.xlsxData.charge_id)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.xlsxData
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("cell_title_text")
        name_text.text = Language:getTextByKey(cfg.gift_name)
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278")
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end
        local return_per_text = luaBehaviour:FindText("return_per_text")
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
        local parent = luaBehaviour:FindGameObject("itemParent")
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil)
        -- isCanBuy 展示上一礼包
        if not data.isCanBuy then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
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
            local residueCount = (cfg.time_limit-data.buyCount)
            residueCount = data.isCanBuy and residueCount or 0
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", residueCount)
        end
    end
end

function M:updateTime()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = GameUtil:formatTimeBySecond(down_time, 999)
        self:setTextByLanKey("text_timer", text)
    elseif down_time == 0 then
        self:updateMsg("refresh_data")
    end
end

function M:destroy()
    self.m_control:updateMsg("refreshRedPoint", nil, "Activities.DeliciousFeast.DeliciousFeastMain")
    M.super.destroy(self)
end

return M