local M = class("ThreeHeroesFiveGallantsMainView", LikeOO.OOPopBase)

M.m_uiName = "ThreeHeroesFiveGallants/ThreeHeroesFiveGallantsMain"
M.m_iphoneXAdapter = true



function M:onEnter()
    self:setLanuage() --设置本地化文本
    self:setState() --设置显示状态
    self:refreshRedPoint() --刷新红点
end

--刷新ui
function M:refreshUI()
    self:setState() --设置显示状态
end

--设置本地化文本
function M:setLanuage()
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    self:setTextByLanKey("choose_text", "three_heroes_five_gallants_text_0001")
    self:setTextByLanKey("cat_name_text", "three_heroes_five_gallants_text_0002")
    self:setTextByLanKey("mouse_name_text", "three_heroes_five_gallants_text_0003")
    self:setTextByLanKey("btn_cat_text", "three_heroes_five_gallants_text_0004")
    self:setTextByLanKey("btn_mouse_text", "three_heroes_five_gallants_text_0005")
    self:setTextByLanKey("btn_rank_text", "three_heroes_five_gallants_text_0006")
    self.active_tab = self.m_model:getActiveTab()
    for i, v in ipairs(self.active_tab) do
        local btn_name = "btn"..i.."_text"
        self:setTextByLanKey(btn_name,Language:getTextByKey(v.btn_name))
    end
end

--设置显示状态
function M:setState()
    --0:未选择   1:御猫   2:锦毛鼠
    self.choose_force = self.m_model.m_data.cur_camp or 0
    self:setObjectVisible("choose_camp",self.choose_force == 0)
    self:setObjectVisible("bg_1",self.choose_force == 0)
    self:setObjectVisible("timerImg_lan",self.choose_force == 0)
    self:setObjectVisible("active_camp",self.choose_force ~= 0)
    self:setObjectVisible("bg_2",self.choose_force ~= 0)
    self:setObjectVisible("timerImg_huang",self.choose_force ~= 0)
    --刷新回合显示
    self.round = self.m_model.m_data.period or 1
    local numStr = GameUtil:numberToChineseString(self.round) -- 数字转大写
    self:setTextByLanKey("text_timer","three_heroes_five_gallants_text_0012",numStr)
end

--更新时间
function M:updateTime()
    local cur_tim = UserDataManager:getServerTime() --服务器时间
    local surplus_time = 0
    --self.m_model.m_data.end_time = 1660306469 
    if self.m_model.m_data.end_ts ~= nil then
        surplus_time = self.m_model.m_data.end_ts - cur_tim
    end
    if surplus_time <= 0 then
        self:updateMsg("refresh_data")
    else
        local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
        local show_time = ""
        if remain_day > 0 then
            show_time = Language:getTextByKey("three_heroes_five_gallants_text_0013",remain_day,remain_hour,remain_min)
        else
            show_time = Language:getTextByKey("three_heroes_five_gallants_text_0014",remain_hour,remain_min,remain_sec)
        end
        self:setTextByLanKey("end_text_timer", show_time) --重置剩余时间
    end
end

--刷新红点
function M:refreshRedPoint()
    local items = self.m_model:getAllActiveTab()
    for k, v in pairs(items) do
        local isShowRedPoint = RedPointUtil:hasRedPointById(v.open_id) or false
        if v.open_id ==386  then
            isShowRedPoint = self.m_model:getStoreReward()
        end
        self:setObjectVisible("btn_red_point_img"..v.id, isShowRedPoint)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
