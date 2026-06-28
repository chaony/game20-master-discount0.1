local M = class("GuJianQiTanMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self:UpdateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.UpdateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
    elseif msg == "update_activity_show_done_flag" then
        self.m_model:updateShowDoneFlag()
    --刷新红点
    elseif msg == "refresh_red_point_gift" then --礼包
        self.m_view:refreshRedPoint()
    else
        local function netDataCallBack(response)
            self.m_model:updateMainData(response)
            self:tryOpenActive(msg)
        end
        self.m_model:getNetData("ancient_sword_and_wonderland_index", nil, netDataCallBack)
    end
end

function M:tryOpenActive(active_btn_name)
    if self.m_model:activeDateCheck() == false then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_016"), delay_close = 2})
        return
    end

    if active_btn_name == "draw_btn" then --煞剑出鞘
        self:openView("GuJianQiTan.GuJianQiTanDraw", {main_data = self.m_model:getMainData()})
    elseif active_btn_name == "show_btn" then --古剑现世
        self:openView("GuJianQiTan.GuJianQiTanShow", {main_data = self.m_model:getMainData()})
    elseif active_btn_name == "maze_btn" then --剑魔地宫
        local e_tim = self.m_model:getMazeOpenTime()
        local d_time = e_tim - UserDataManager:getServerTime()
        if d_time > 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_042", GameUtil:formatTimeBySecond2(d_time, 999)), delay_close = 2})
            return
        end

        if self.m_model:isActivityShowDone() == false then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_050", GameUtil:formatTimeBySecond2(d_time, 999)), delay_close = 2})
            return
        end
        
        local function netDataCallBack(response)
            if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
                self:openView("GuJianQiTan.GuJianQiTanMaze",{data = response})
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_060"), delay_close = 2})
            end
        end
        self.m_model:getNetData("ancient_sword_and_wonderland_akuma_index", nil, netDataCallBack)
        
    elseif active_btn_name == "shop_btn" then --商店
        if self.m_model:activeDateCheck() == true then
            local params = {}
            params.version = self.m_model:getVersion()
            self:openView("GuJianQiTan.GuJianQiTanGift", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_016"), delay_close = 2})
        end
    elseif active_btn_name == "date_btn" then --日历
        self:openView("GuJianQiTan.GuJianQiTanDate", {main_data = self.m_model:getMainData()})
    elseif active_btn_name == "h5_btn" then --h5入口
        local url = self.m_model:getActiveURL()
        CS.UnityEngine.Application.OpenURL(url)
    end
end

--计时器
function M:UpdateTime(_, dt)
    dt = dt or 0
    self.m_view:updateTime()
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M
