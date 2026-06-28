---@class XiakedaoControl:OOControlBase
---@field m_view XiakedaoView
---@field m_model XiakedaoModel
local M=class("XiakedaoControl",LikeOO.OOControlBase)

function M:onEnter()

    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))

    self.hero_isle_base_cfg=ConfigManager:getCfgByName("hero_isle_base")

    self.layerScope=self.hero_isle_base_cfg["layer_team_nums"][2]
end

function M:onHandle(msg, data)
    if msg==99999 then
        self:updateMsg("common_refresh", nil, "parent")
        self:closeView()

    elseif msg=="help_btn" then
        self:openHelpPop()
    elseif msg=="daozhutequan_btn" then
        self:openView("Xiakedao.Privilege",{visitor=self.m_model.m_data.visitor,season=self.m_model.m_data.season,
                                            end_ts=self.m_model.m_data.end_ts, is_token = self.m_model.m_params.is_token})
    elseif msg=="taixuanjing_btn" then
        local mode,team_key=self:GetCurBattleModeAndTeamkey()
        local function netCallback(response)
            local heirlooms=response.own_heirlooms
            local own_heirlooms={}
            for i, v in pairs(heirlooms) do
                own_heirlooms[#own_heirlooms+1]=v.cid
            end
            self:openView("MazeStage.MazeStageRelicFormationShow",
                    {open_type = "yin_tower",data ={heirlooms =own_heirlooms},tips_text = "new_str_1127",common_title_text = "new_str_1119", team_key = team_key})
        end
        self.m_model:getNetData("hero_isle_index", nil, netCallback)

    elseif msg=="huodong01_btn" then

    elseif msg=="kuizeng_btn" then
        --local hero_isle_visitor_cfg=ConfigManager:getCfgByName("hero_isle_visitor")
        --local hero_isle_visitor_cfg_item=hero_isle_visitor_cfg[self.m_model.season_id]
        --if hero_isle_visitor_cfg_item==nil then
        --    hero_isle_visitor_cfg_item=hero_isle_visitor_cfg[-1]
        --end
        if self.m_model.hero_isle_visitor_cfg_item then
            self:openView("Task.TaskMainChapter", {quest_type = self.m_model.hero_isle_visitor_cfg_item.target_type,isle_flag=true,m_end_ts=self.m_model.m_data.end_ts})
        end
    elseif msg=="canwu_btn" then
        local hero_isle_privilege_cfg=ConfigManager:getCfgByName("hero_isle_privilege")
        local cfg=hero_isle_privilege_cfg[self.m_model.m_data.season]
        if cfg==nil then
            cfg=hero_isle_privilege_cfg[-1]
        end
        self:openView("Xiakedao.Canwu",{layer=self.m_model.m_data.layer-1,hero_isle_privilege_cfg=cfg})
    elseif msg=="zongbang_btn" then
        self:openView("Xiakedao.RankList",{season_id=self.m_model.m_data.season,lose_num=self.m_model.m_data.lose_num})
    elseif msg=="mijing_btn" then
        self:openFormation(data)
    elseif msg=="common_refresh" then
        local function netCallback(response)
            self.m_model.m_data.lose_num=response.lose_num
            self.m_model.m_data.layer=response.layer+1
            self.m_model:refreshCurTop3RankData(response)
            if self.m_view then
                self.m_view:refreshLosenum()
                self.m_view:refreshTop3Node()
                EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "red_dot_update"})
            end
        end
        self.m_model:getNetData("hero_isle_index", nil, netCallback)
    end
end

function M:openFormation(data)

    local function netCallback(response)
        local params={}
        self.m_model.m_data.layer=response.layer+1
        params.mode=self:GetCurBattleModeAndTeamkey()
        params.layer=response.layer+1
        params.lose_num=response.lose_num

        if self.m_model.m_data.layer>self.m_model.maxLayer then
            if data and data.func then
                data.func()
            else
                local params =
                {
                    no_close_btn = false,
                    text = Language:getTextByKey("new_str_1133")
                }
                self:openView("Pops.CommonPop", params)
            end
        else
            self:openView("Formation",params)
        end
    end
    self.m_model:getNetData("hero_isle_index", nil, netCallback)
end

function M:GetCurBattleModeAndTeamkey()
    local mode=nil
    local team_key=nil
    local data=self.m_model.m_data
    if data.layer>=self.layerScope then
        mode=GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
        team_key="hero_isle_mul"
    else
        --mode=GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI
        --team_key="hero_isle_mul"
        mode=GlobalConfig.BATTLE_MODE.XIAKEDAO
        team_key="hero_isle_sing"
    end
    return mode,team_key
end

function M:updateTime()

    self.m_view:updateTime()
end

--打开帮助页面
function M:openHelpPop()
    local desc=self.hero_isle_base_cfg["desc"]
    local params = {
        title = "world_str_020",
        content = desc
    }
    self:openView("Pops.CommonFiveLineHelpPop", params)
end

function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M