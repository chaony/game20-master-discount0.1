local M = class("ThreeHeroesFiveGallantsMainControl", LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, date)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "parent")
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()
        return
    elseif msg == "btn_cat" then --加入开封府  御猫
        self:joinForce(1)
    elseif msg == "btn_mouse" then --加入陷空岛 锦毛鼠
        self:joinForce(2)
    elseif msg == "btn_1" then --猫鼠活动
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsWhackGame", {open_id = 387,join_stage = self.m_model.m_data.cur_camp ,version = self.m_model:getActVsn(387)})
    elseif msg == "btn_2" then --前尘往事
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsStore",{version = self.m_model.m_data.version,
                                                                              cur_camp = self.m_model.m_data.cur_camp,
                                                                              score = self.m_model.m_data.self_score, 
                                                                              recv_chivalrous = self.m_model.m_data.recv_chivalrous, 
                                                                              tasks = self.m_model.m_data.tasks, 
                                                                              period = self.m_model.m_data.period or 1})
    elseif msg == "btn_3" then --江湖行侠
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsBattle",{cur_camp = self.m_model.m_data.cur_camp,version = self.m_model:getActVsn(388)})
    elseif msg == "btn_4" then --侠义献礼
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsGiftBridge",{is_token = self.m_model.m_is_token,version = self.m_model:getActVsn(389)}) 
    elseif msg == "btn_5" then --花落谁家
        local active_version = self.m_model:getActVsn(346)
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsLuckDraw",{version = active_version})
    elseif msg == "btn_rank" then -- 侠义排名
        self:openView("ThreeHeroesFiveGallants.ThreeHeroesFiveGallantsChivalrousPop",{version = self.m_model.m_data.version,
                                                                                      camp = self.m_model.m_data.cur_camp,
                                                                                      period = self.m_model.m_data.period or 1})
    elseif msg == "help_btn" then --帮助
        local params = {}
        params.title = self.m_view.avtive_data.name
        params.content = "tid#chivalrous_period_tips"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refresh_data" then  --刷新数据
        self:refreshData()
    elseif msg == "refreshRedPoint" then --刷新红点
        self.m_view:refreshRedPoint()
    end
end

--加入势力
function M:joinForce(force_id)
    --self.m_model.m_data.cur_camp = force_id
    --self.m_view:refreshUI()
    local function netCallback(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("chivalrous_choose", {camp = force_id}, netCallback)
end

--刷新数据
function M:refreshData()
    local function netCallback(response)
        self.m_view:refreshUI()
        self.m_view:refreshRedPoint()
    end
    self.m_model:getNetData("chivalrous_index", {}, netCallback)
end

--更新时间
function M:updateTime()
    self.m_view:updateTime()
end

return M
