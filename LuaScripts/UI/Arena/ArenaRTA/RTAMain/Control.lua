---@class RTAMainControl OOControlBase
---@field m_model RTAMainModel
---@field m_view RTAMainView
local M = class("RTAMainControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
    self.m_guide_file_name = "UI.Arena.ArenaRTA.RTAMain.Guide"

    --EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC, {self, self.syncInfo})
    --如果是自动晋级需要显示下晋级效果
    if self.m_model.m_promote_flag==1 or (self.m_model.m_promote_flag==4 and self.m_model.m_cur_tier<5)
    or (self.m_model.m_promote_flag==2 and self.m_model.m_cur_tier<5)then
        local param={
            --自动晋级rise_id是晋级后的值，手动晋级时是晋级前的值
            match_type=self.m_model.m_cur_tier,
            callback=nil,
            promote_flag=self.m_model.m_promote_flag
        }
        self:openView("Arena.ArenaRTA.RTAAdvancePop",param)
    end
end


function M:syncInfo(event,data)

    if data.event_type == "rta.sync" then
        if self.m_model.m_cur_step==14 then
            return
        end
        --local callback=function(_data, tag, status_code)
        --    --根据结算是否为空判断是否提前结束了
        --    if _data.settle then
        --        --Logger.logWarning("===================sync_data.settle")
        --        if table.nums(_data.settle)>0 then
        --            self:completeEarly(_data.settle)
        --            return
        --        end
        --    end
        --    --self:startHeart()
        --    self.m_model:update_Sync_data(_data)
        --    if not self.m_model.inited then
        --        self:closeSubView()
        --        self.m_model:set_cur_match_id(_data.match_id)
        --        self.m_model:init_isatker()
        --        self.m_view:enterSelectNode()
        --        self.m_model.inited=true
        --    end
        --    self:executeStep(_data)
        --end
        --self.m_model:getNetData("rta_sync",nil,callback)
        self:requestSync()
    end
end

function M:requestSync()
    local callback=function(_data, tag, status_code)
        --长链接时服务器通知请求时要重置心跳
        ChatUtil:resetRTAHeart()
        --根据结算是否为空判断是否提前结束了
        if _data.settle then
            --Logger.logWarning("===================sync_data.settle")
            if table.nums(_data.settle)>0 then
                self:completeEarly(_data.settle)
                return
            end
        end
        --self:startHeart()
        self.m_model:update_Sync_data(_data)
        if _data.atker~=nil and _data.step==1 then
            if not self.m_model.inited then
                self:closeSubView()
                self.m_model:set_cur_match_id(_data.match_id)
                self.m_model:init_isatker()
                self.m_view:enterSelectNode()
                self.m_model.inited=true
            end
        end
        self:executeStep(_data)
    end
    self.m_model:getNetData("rta_sync",nil,callback)
end


function M:closeSubView()
    static_rootControl:closeView("Pops.CommonHelpPop")
    GameUtil:destroyLookInfoTips()
end


--function M:startHeart()
--    self:resetHeart()
--    self.heartStarted=true
--    if self.m_heart_timer == nil then
--        local function heart_tick(_, dt)
--            -- Logger.log(self.m_heart_cd,"-------- heart tick --------")
--            if self.heartStarted then
--                self.m_heart_cd = self.m_heart_cd - dt
--
--                if self.m_heart_cd <= 0 then
--                    self:resetHeart()
--                    --local callfunc=function()
--                    --    Logger.log("heart tick --------")
--                    --end
--                    --self.m_model:getNetData("user_heartbeat", nil, callfunc, 0)
--                    self:requestSync()
--                end
--            end
--        end
--        self.m_heart_timer = self:setTimer(1, heart_tick)
--    end
--end
--
--function M:resetHeart()
--    self.m_heart_cd = 5
--end
--
--function M:cancelHeart()
--    self.heartStarted=false
--end


function M:lockSelectHero()
    self.m_model:lockSelectHero()
end

function M:unlockSelectHero()
    self.m_model:unlockSelectHero()
end


function M:executeStep(sync_data)
    if sync_data==nil then
        sync_data=self.m_model.m_sync_data
    end

    local step=sync_data.step
    --if step==self.m_model.m_cur_step then
    --    Logger.logWarning("same steppp========="..step)
    --end

    if step==1 or step==4 or  step==5 or step==8 or  step==9 or step==12 then
        --if step~=0 then
        --    self.m_view:update_selectNode_leftPart_Heros()
        --end
        self.m_view:initPreBanHeros()
        self.m_view:update_selectNode_leftPart_Heros()
        if step~=self.m_model.m_cur_step then
            --Logger.logWarning("m_cur_step========="..step)
            self.m_model.m_cur_step=step
            self:setOnceTimer(1,function ()
                self.m_view:startTurn(sync_data.end_ts,self.m_model:isOwnTurn(sync_data.atker.uid))
            end)
        end
    elseif step==2 or  step==3 or step==6 or  step==7 or step==10 or  step==11 then
        self.m_view:update_selectNode_leftPart_Heros()
        if step~=self.m_model.m_cur_step then
            --Logger.logWarning("m_cur_step========="..step)
            self.m_model.m_cur_step=step
            self:setOnceTimer(1,function ()
                self.m_view:startTurn(sync_data.end_ts,self.m_model:isOwnTurn(sync_data.defer.uid))
            end)
        end
    elseif step==13  then--ban
        if not self.m_model.is_inBanState then
            self.m_view:update_selectNode_leftPart_Heros()
        end

        if step~=self.m_model.m_cur_step  then
            --Logger.logWarning("m_cur_step========="..step)
            self.m_view:resetTurn()

            self.m_model.m_cur_step=step
            self:setOnceTimer(2,function()
                --初始化显示预ban
                self.m_model.pre_ban_heros=self.m_model.m_sync_data.pre_ban_heros
                self.m_view:initPreBanHeros()
                self.m_view:enterBanUI(sync_data.end_ts)

            end)
        end
    elseif step==14 then
        self.m_view:update_selectNode_leftPart_Heros()
        if step~=self.m_model.m_cur_step  then
            self.m_model.m_cur_step=step
            local param={
                mode = GlobalConfig.BATTLE_MODE.RTA_ARENA,
                match_id=self.m_model.m_match_id,
                rta_team=self:getTeam(),
                rta_end_ts=self.m_model.m_sync_data.end_ts,
                cur_tier=self.m_model.m_cur_tier
            }
            self:setOnceTimer(2,function()
                self.heartStarted=false
                self:removeTimer(self.m_heart_timer)
                self:openView("Formation",param)
                self.m_view:UnRegisterEvent()
                --self:setOnceTimer(5,function()
                --    self:closeView()
                --end)
            end)
        end
    end
end

function M:getTeam()
    --local battleData=self.m_model:getFormationBattleData()
    local team={}
    local own=self.m_model:getUserInfoBySort(1)
    local ownHeros=own.heros
    for i, hero in pairs(ownHeros) do
        if hero.ban==0 then
            team[#team+1]=hero.oid
        end
    end

    return team
end

--中止处理
function M:completeEarly(settle)
    local self_uid=UserDataManager.user_data:getUid()
    local winer_isSelf=self_uid==settle.winer

    local tip_str=nil
    if winer_isSelf then
        tip_str=Language:getTextByKey("arena_rta_str_0022")
    else
        tip_str=Language:getTextByKey("arena_rta_str_0021")
    end

    local params =
    {
        on_ok_call = function(msg)
            ChatUtil:cancelRTAHeart()
            self.m_model:resetState()
            self.m_view:back2MainReset()
            self:rtaIndex()
        end,
        no_close_btn = true,
        text =tip_str
    }
    static_rootControl:openView("Pops.CommonPop", params)
end


function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(47, 3)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.inMatching then
            return
        end
        self:updateMsg("common_refresh", nil, "parent")
        --self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()

    elseif msg == "ArenaAdvance" then
        local param={
            match_type=self.m_model.m_rise_id,
            callback=nil,
            promote_flag=self.m_model.m_data.promote_flag
        }
        self:openView("Arena.ArenaRTA.RTAAdvancePop",param)


    elseif msg == "battle_end_refresh_ui" then
        --关闭列表
        --self:closeView("Arena.ArenaRace.ArenaRaceChallenge")
        self:rtaIndex()
        if data and data.data and data.data.reward then
            RewardUtil:rewardTipsByData(data.data.reward)
        end

    elseif msg == "refresh_ui" then
        self.m_model:resetState()
        self.m_view:back2MainReset()
        self:rtaIndex()
    elseif msg == "refresh_ui2" then
        self:rtaIndex()
    elseif msg == "shop_btn" then
        if self.m_model.inMatching then
            return
        end
        self:openView("Shop", {shop_type = 38})

    elseif msg == "rank_btn" then
        if self.m_model.inMatching then
            return
        end
        local param={
            rank=self.m_model.m_data.rank,
            score=self.m_model.m_data.score,
            tier=self.m_model.m_cur_tier
        }
        self:openView("Arena.ArenaRTA.RTAAllRank",param)
    elseif msg == "explain_btn" then --说明
        local params = {}
        params.title = "tid#OpenConditionName_474"
        params.content = "tid#OpenConditionDes_474"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint()
    elseif msg=="select_hero" then
        self.m_model.cur_seclect_hero_oid=data.oid

    elseif msg=="select_btn" then
        if self.m_model.m_select_islock then
            return
        end
        local params={
            match_id=self.m_model.m_match_id,
            hero=self.m_model.cur_seclect_hero_oid
        }

        if self.m_model.cur_seclect_hero_oid==nil then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("arena_rta_str_0032"), delay_close = 2})
            return
        end

        local callback=function(data, tag, status_code)
            --self.m_view:resetTurn()
            self.m_view:set_select_btn_visible(false)
            self.m_model.cur_seclect_hero_oid=nil

            self.m_model:update_Sync_data(data)
            self:executeStep(data)
        end
        self.m_model:getNetData("rta_choose_hero",params,callback)

        --self:closeView()
    elseif msg=="selectBan" then
        self.m_model.cur_seclect_ban_oid=data.oid
    elseif msg=="back_btn" then
        if self.m_model.inMatching then
            return
        end
        self:closeView()

    elseif msg == "tab_btn" then --英雄类型
        self.m_model:switchHeroList(data)
        self.m_view:updateHerosScroll(false)


    elseif msg=="addPreBan_btn" then
        if self.m_model.inMatching then
            return
        end
        local ban_data={}
        if self.m_model.m_data.self_ban_hero==0 or self.m_model.m_data.self_ban_hero==nil then

        else
            ban_data[1]=self.m_model.m_data.self_ban_hero
        end
        self:openView("Arena.ArenaRTA.PreBanHero",
                {lock_hero_data=ban_data,
                 ban_num=1,
                 is_rta=true
                })
    elseif msg=="updatePreBanHero" then
        self.m_model.m_data.self_ban_hero=data
        self.m_view:refreshPreBanHeros()

    elseif msg=="cancel_btn" then
        local callback=function(data, tag, status_code)
            ChatUtil:cancelRTAHeart()
            self.m_model:cancelMatch()
            self.m_view:cancelMatch()
            self.m_model.inMatching=false
        end
        self.m_model:getNetData("rta_cancel",nil,callback)
    elseif msg=="start_btn" then
        local callback=function(data, tag, status_code)
            self.m_view:startMatch()
            --self:startHeart()
            ChatUtil:startRTAHeart()
            self.m_model.inMatching=true
        end
        self.m_model:getNetData("rta_apply",nil,callback)

        --匹配成功跳转至选人界面
    elseif msg=="matched" then

        self.m_view:enterSelectNode()

    elseif msg=="ban_select_btn" then
        if self.m_model.is_inBanState then
            local callback=function(data, tag, status_code)
                self.m_model:update_Sync_data(data)
                self.m_view:setBanState(false)
                self:executeStep(data)
            end
            self.m_model:getNetData("rta_ban_rival_hero",{match_id=self.m_model.m_match_id
            ,hero=self.m_model.cur_seclect_ban_oid},callback)
        end

    elseif msg=="update_preban_hero" then
        local callback=function(data)
            self.m_model.m_data.self_ban_hero=data.hero
            self.m_view:refreshPreBanHeros()
        end
        self.m_model:getNetData("rta_pre_ban_hero",{
            hero=data[1]
        },callback)
    elseif msg=="limit_icon" then
        if self.m_model.m_limit_cfg then
            local param={
                click_transform = self.m_view.limit_icon_trans,
                title=Language:getTextByKey(self.m_model.m_limit_cfg.rule_name),
                msg=Language:getTextByKey(self.m_model.m_limit_cfg.rule_desc)
            }
            GameUtil:lookInfoTips(self.m_control, param)
        end

    elseif msg=="record_btn" then
        if self.m_model.inMatching then
            return
        end
        self:openView("Arena.ArenaRTA.ArenaRTALog")
    elseif msg=="battleReport_btn" then
        if self.m_model.inMatching then
            return
        end
        self:openView("Arena.ArenaRTA.RTAServerAllLog")
    end
end

-- 主界面刷新
function M:rtaIndex()
    local function receivetCallback(response)
        if self.m_view then
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
    end
    local params = {}
    self.m_model:getNetData("rta_index", params, receivetCallback)
end


function M:destroy()
    --EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.RTA_SYNC, {self, self.syncInfo })
    M.super.destroy(self)
end

return M;
