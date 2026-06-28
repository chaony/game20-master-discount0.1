---@class LoyaltyRankView: OOPopBase
local M = class("LoyaltyRankView", LikeOO.OOPopBase)

M.m_uiName = "Loyalty/LoyaltyRank"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    RedPointUtil:saveLocalRedPointFreshTime("HaveGoodLuckRedDot")
    self:refreshUI()
end

function M:refreshUI()
    self:bindUI()
    self:refreshRightNode()
    self:refreshActivityTimer()
end

function M:refreshActivityTimer()
    local activityData = UserDataManager:getActivesDataByOpenId(self.m_model.open_id)
    local startTimer = activityData.start_ts
    local endTimer = activityData.end_ts
    local starT = TimeUtil.gmTime(startTimer)
    local endT = TimeUtil.gmTime(endTimer)
    local timerFormat = Language:getTextByKey("castingSword_str_0012", starT.year, starT.month, starT.day,
            endT.year, endT.month, endT.day)
    self:setTextByLanKey("text_timer", "flower_text_0052",timerFormat)
end

function M:refreshTeamList()
    local data = self.m_model.teamRankData
    if self.m_teamScroll_view == nil then
        local loopscroll = self:findGameObject("team_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshTeamItem(cell_obj, cell_data, index)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            pull_refresh = function() -- 下拉刷新
                self.last_offsety = self.m_teamScroll_view.m_scroll_rect.viewport.rect.height - self.m_teamScroll_view.m_scroll_rect.content.rect.height
                self:updateMsg("load_rank",2)
            end,
        }
        self.m_teamScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_teamScroll_view:reloadData(data, true)
    end
end

function M:refreshTeamItem(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        LuaBehaviourUtil.setText(luaBehaviour, "text_rank", cell_data.rank )
        local userInfo = cell_data.user
        local head_node = luaBehaviour:FindGameObject("head_node")
        GameUtil:setUserAvatar(head_node, userInfo,false,false,false)
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", userInfo.name )
        LuaBehaviourUtil.setText(luaBehaviour, "text_flowerCount", cell_data.score )
        local flag_cfg = ConfigManager:getCfgByName("guild_flag")[userInfo.flag]
        if flag_cfg then
            local emblem_img = luaBehaviour:FindImage("emblem_img")
            GameUtil:updateResourcesImg(emblem_img, "Texture/union_emblem/" .. flag_cfg.icon)
        end
    end
end

function M:refreshPersonList()
    local data = self.m_model.roleRankData
    if self.m_roleScroll_view == nil then
        local loopscroll = self:findGameObject("role_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshPersonItem(cell_obj, cell_data, index)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end,
            pull_refresh = function() -- 下拉刷新
                self:updateMsg("load_rank",1)
            end
        }
        self.m_roleScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_roleScroll_view:reloadData(data, true)
    end
end

function M:refreshPersonItem(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        LuaBehaviourUtil.setText(luaBehaviour, "text_rank", cell_data.rank )
        local userInfo = cell_data.user
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", userInfo.name )
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name", userInfo.server_name)
        LuaBehaviourUtil.setText(luaBehaviour, "text_flowerCount", cell_data.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        GameUtil:setUserAvatar(head_node, userInfo,false,false,false)
        local title_id = userInfo.title
        if title_id and title_id ~= 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
            local title_obj = luaBehaviour:FindGameObject("head_title_img1")
            local name_img = luaBehaviour:FindImage("head_title_img1")
            local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
            if cfg and name_img and title_obj then
                name_img.enabled = true
                GameUtil:setTextureLoadTitleLanImgText(name_img, cfg.icon) -- 设置称号图片
                name_img:SetNativeSize()
                UIUtil.setScale(title_obj.transform, 0.5)
            end
            UIUtil.destroyAllChild(name_img.gameObject.transform)
            if cfg.title_effect and cfg.title_effect ~= "" then
                name_img.enabled = false
                ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
        end
    end
end

function M:refreshRightNode()
    local isShowRoleRank = self.m_model.roleRankCount > 0
    self:setObjectVisible("role_loopscroll", isShowRoleRank)
    if isShowRoleRank then
        self:refreshPersonList()
    end
    local isShowTeamRank = self.m_model.teamRankCount > 0
    self:setObjectVisible("team_loopscroll", isShowTeamRank)
    if isShowTeamRank then
        self:refreshTeamList()
    end
    if self.m_model.m_selectTabIndex == 1 then
        self:refreshMyInfoNode()
    else
        self:refreshMyTeamNode()
    end
    self:switchTabView()
end

function M:switchTabView()
    local isShowMyTeamNode = self.m_model.m_selectTabIndex == 2
    self:setObjectVisible("myRankInfoNode", (not isShowMyTeamNode))
    self:setObjectVisible("myTeamInfoNode", isShowMyTeamNode)
    self:setObjectVisible("img_myShowTab", (not isShowMyTeamNode))
    self:setObjectVisible("img_myTeamShowTab", isShowMyTeamNode)
    self:refreshLeftNode()
end

--个人排行榜本人信息
function M:refreshMyInfoNode()
    local cell_obj = self:findGameObject("myInfoNode")
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local myInfoData = self.m_model.myInfoData
        local rankIndex = myInfoData.rank > 0 and myInfoData.rank or "-"
        LuaBehaviourUtil.setText(luaBehaviour, "text_rank", rankIndex )
        local name = UserDataManager.user_data:getUserStatusDataByKey("name")
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", name )
        local server_name = UserDataManager.server_data:getServerName()
        LuaBehaviourUtil.setText(luaBehaviour, "server_name", server_name )
        LuaBehaviourUtil.setText(luaBehaviour, "text_flowerCount", myInfoData.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
        local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
        GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = frame}, false)
        local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
        if title_id and title_id ~= 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
            local title_obj = luaBehaviour:FindGameObject("head_title_img1")
            local name_img = luaBehaviour:FindImage("head_title_img1")
            local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
            if cfg and name_img and title_obj then
                name_img.enabled = true
                GameUtil:setTextureLoadTitleLanImgText(name_img, cfg.icon) -- 设置称号图片
                name_img:SetNativeSize()
                UIUtil.setScale(title_obj.transform, 0.5)
            end
            UIUtil.destroyAllChild(name_img.gameObject.transform)
            if cfg.title_effect and cfg.title_effect ~= "" then
                name_img.enabled = false
                ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
        end
    end
end

--帮会排行榜本帮会信息
function M:refreshMyTeamNode()
    local cell_obj = self:findGameObject("myTeamNode")
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local myTeamData = self.m_model.myTeamData
        local rankIndex = myTeamData.rank > 0 and myTeamData.rank or "-"
        LuaBehaviourUtil.setText(luaBehaviour, "text_rank", rankIndex )
        local name = UserDataManager.user_data.user_status
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", name.guild_name)
        LuaBehaviourUtil.setText(luaBehaviour, "text_flowerCount", myTeamData.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
        local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
        GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = frame}, false)
        local title_id = UserDataManager.user_data:getUserStatusDataByKey("title")
        local gender = myTeamData.flag or 0
        local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
        if flag_cfg then
            local union_icon_img = luaBehaviour:FindImage("emblem_img")
            GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
        end
        --if title_id and title_id ~= 0 then
            --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
            --local title_obj = luaBehaviour:FindGameObject("head_title_img1")
            --local name_img = luaBehaviour:FindImage("head_title_img1")
            --local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
            --if cfg and name_img and title_obj then
            --    name_img.enabled = true
            --    GameUtil:setTextureLoadTitleLanImgText(name_img, cfg.icon) -- 设置称号图片
            --    name_img:SetNativeSize()
            --    UIUtil.setScale(title_obj.transform, 0.6)
            --end
            --UIUtil.destroyAllChild(name_img.gameObject.transform)
            --if cfg.title_effect and cfg.title_effect ~= "" then
            --    name_img.enabled = false
            --    ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
            --end
        --else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
        --end
    end
end

--左边前3名信息
function M:refreshLeftNode()
    local allRoleData = self.m_model.roleRankData
    if self.m_model.m_selectTabIndex == 2 then
        allRoleData = self.m_model.teamRankData
    end
    for index = 1, 3 do
        local itemData = allRoleData[index]
        local roleNode = self:findGameObject("roleNode"..index)
        local isExistRole = itemData ~= nil
        roleNode:SetActive(true)
        if isExistRole then
            local luaBehaviour = UIUtil.findLuaBehaviour(roleNode)
            if luaBehaviour then
                local userInfo = itemData.user
                --local server_name = UserDataManager.server_data:getServerName()
                --if index ~= 0 then
                --    server_name = UserDataManager.server_data:getServerNameById(userInfo.server) or ""
                --end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"text_name",true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"server_name",true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_flowerLogo",true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"text_flowerCount",true)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"head_title_img1",true)
                LuaBehaviourUtil.setText(luaBehaviour, "text_name",  userInfo.name) -- "["..server_name.."]" ..
                if self.m_model.m_selectTabIndex == 1 then
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name", userInfo.server_name)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"emblem_img",false)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tx_mask",true)
                else
                    local gender = userInfo.flag or 0
                    local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
                    if flag_cfg then
                        local union_icon_img = luaBehaviour:FindImage("emblem_img")
                        GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
                    end
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"emblem_img",true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tx_mask",false)
                end
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_flowerCount", itemData.score)
                --加载spine动画
                local hero = luaBehaviour:FindGameObject("own_hero_spine")
                local cfg = ConfigManager:getPlayerPictureCfg(userInfo.avatar)
                GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. tostring(cfg.hero_spine), "idle", 0, true)
                -- 称号
                local title_id = userInfo.title
                if title_id and title_id ~= 0 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
                    local title_obj = luaBehaviour:FindGameObject("head_title_img1")
                    local name_img = luaBehaviour:FindImage("head_title_img1")
                    local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
                    if cfg and name_img and title_obj then
                        name_img.enabled = true
                        GameUtil:setTextureLoadTitleLanImgText(name_img, cfg.icon)
                        name_img:SetNativeSize()
                        UIUtil.setScale(title_obj.transform, 0.5)
                    end
                    UIUtil.destroyAllChild(name_img.gameObject.transform)
                    if cfg.title_effect and cfg.title_effect ~= "" then
                        name_img.enabled = false
                        ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
                    end
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
                end
            end
        else
            local luaBehaviour = UIUtil.findLuaBehaviour(roleNode)
            if luaBehaviour then
                if self.m_model.m_selectTabIndex == 1 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"emblem_img",false)
                end
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"tx_mask",false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"text_name",false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"server_name",false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"item_flowerLogo",false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"text_flowerCount",false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour,"head_title_img1",false)
            end
        end
    end
end

function M:bindUI()
    self:setTextByLanKey("text_title1", "flower_text_0009")
    self:setTextByLanKey("text_title2", "flower_text_0010")
    self:setTextByLanKey("rank_reward_btn_text", "flower_text_0053")
    self:setTextByLanKey("text_myTitle", "flower_text_0068")
    self:setTextByLanKey("text_myTeamTitle", "red_packet_text_007")
    self:setTextByLanKey("text_myTab", "flower_text_0009")
    self:setTextByLanKey("text_myTeamTab", "flower_text_0010")
end

function M:destroy()
    M.super.destroy(self)
end

return M
