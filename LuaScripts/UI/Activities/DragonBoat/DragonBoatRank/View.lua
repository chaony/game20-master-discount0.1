---@class DeliciousFeastRankView: OOPopBase
---@field m_model DeliciousFeastRankModel
local M = class("DragonBoatRankView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DragonBoat/DragonBoatRank"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:bindUI()
    self:refreshTopThreeNode()
    self:refreshOthersNode()
    self:updateActivityTimer()
end

function M:updateActivityTimer()
    local data = self.m_model:getActivityData()
    if data then
        local left_time = data.end_ts - UserDataManager:getServerTime()
        if left_time > 0 and data.open_status == 1 then
            local text = GameUtil:formatTimeBySecond(left_time)
            text = Language:getTextByKey("new_str_0919") .. text
            self:setTextByLanKey("text_timer", text)
        elseif data.open_status == 2 then
            self:setTextByLanKey("text_timer", "new_str_0558")
            if left_time <= 0 then
                self:updateMsg("time_over")
            end
        end
    end
end

function M:refreshRankList()
    local data = self.m_model:getRankListData()
    if self.m_roleScroll_view == nil then
        local loopscroll = self:findGameObject("role_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshRankItem(cell_obj, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "btn_itemRole" then
                    local curId = UserDataManager.user_data:getUserStatusDataByKey("uid")
                    if curId ~= cell_data.user.uid then
                        self.m_control:openView("Pops.PlayerInfo", { uid = cell_data.user.uid })
                    end
                end
            end
        }
        self.m_roleScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_roleScroll_view:reloadData(data, true)
    end
end

function M:refreshRankItem(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        LuaBehaviourUtil.setText(luaBehaviour, "text_rank", cell_data.rank)
        local userInfo = cell_data.user
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", userInfo.name)
        LuaBehaviourUtil.setText(luaBehaviour, "text_flowerCount", cell_data.score)
        local head_node = luaBehaviour:FindGameObject("head_node")
        GameUtil:setUserAvatar(head_node, userInfo, false, false, false)
        local titleId = userInfo.title
        if titleId and titleId  ~= 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
            local title_obj = luaBehaviour:FindGameObject("head_title_img1")
            local title_img = luaBehaviour:FindImage("head_title_img1")
            local title_cfg = UserDataManager.title_data:getTitleConfigById(titleId )
            if title_cfg and title_img and title_obj then
                title_img.enabled = true
                GameUtil:setTextureLoadTitleLanImgText(title_img, title_cfg.icon)
                title_img:SetNativeSize()
                UIUtil.setScale(title_obj.transform, 0.6)
            end
            UIUtil.destroyAllChild(title_img.gameObject.transform)
            if title_cfg.title_effect and title_cfg.title_effect ~= "" then
                title_img.enabled = false
                ResourceUtil:GetUIEffectItem("Headtitle/" .. title_cfg.title_effect, title_img.gameObject)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
        end
        local item_icon_id = self.m_model:getItemId()
        local itemData = RewardUtil:getProcessRewardData({103,item_icon_id,1})
        LuaBehaviourUtil.setImg(luaBehaviour, "img_flowerLogo", itemData.icon_name, itemData.atlas_name)
    end
end

function M:refreshOthersNode()
    local isShowRank = self.m_model:getRankCount() > 3
    self:setObjectVisible("role_loopscroll", isShowRank)
    if isShowRank then
        self:refreshRankList()
    end
    self:refreshMyInfoNode()
end

function M:refreshMyInfoNode()
    local cell_obj = self:findGameObject("myInfoNode")
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local myRankInfoData = self.m_model:getMyRankInfo()
        local rankIndex = myRankInfoData.rank > 0 and myRankInfoData.rank or "-"
        LuaBehaviourUtil.setText(luaBehaviour, "text_rank", rankIndex)
        local name = UserDataManager.user_data:getUserStatusDataByKey("name")
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", name)
        LuaBehaviourUtil.setText(luaBehaviour, "text_flowerCount", myRankInfoData.score)
        local head_node = luaBehaviour:FindGameObject("head_node")
        local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
        local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
        GameUtil:setUserAvatar(head_node, { avatar = avatar, frame = frame }, false)
        local titleId = UserDataManager.user_data:getUserStatusDataByKey("title")
        if titleId and titleId ~= 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
            local title_obj = luaBehaviour:FindGameObject("head_title_img1")
            local title_img = luaBehaviour:FindImage("head_title_img1")
            local title_cfg = UserDataManager.title_data:getTitleConfigById(titleId)
            if title_cfg and title_img and title_obj then
                title_img.enabled = true
                GameUtil:setTextureLoadTitleLanImgText(title_img, title_cfg.icon)
                title_img:SetNativeSize()
                UIUtil.setScale(title_obj.transform, 0.6)
            end
            UIUtil.destroyAllChild(title_img.gameObject.transform)
            if title_cfg.title_effect and title_cfg.title_effect ~= "" then
                title_img.enabled = false
                ResourceUtil:GetUIEffectItem("Headtitle/" .. title_cfg.title_effect, title_img.gameObject)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
        end
        local item_icon_id = self.m_model:getItemId()
        local itemData = RewardUtil:getProcessRewardData({103,item_icon_id,1})
        LuaBehaviourUtil.setImg(luaBehaviour, "img_flowerLogo", itemData.icon_name, itemData.atlas_name)
    end
end

function M:refreshTopThreeNode()
    local topThreeData = self.m_model:getTopThreeListData()
    for index = 1, 3 do
        local itemData = topThreeData[index]
        local roleNode = self:findGameObject("roleNode" .. index)
        local isEmpty = itemData == nil
        roleNode:SetActive(not isEmpty)
        if not isEmpty then
            local luaBehaviour = UIUtil.findLuaBehaviour(roleNode)
            if luaBehaviour then
                local userInfo = itemData.user
                LuaBehaviourUtil.setText(luaBehaviour, "text_name", userInfo.name)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "text_flowerCount", itemData.score)
                --spine动画
                local hero = luaBehaviour:FindGameObject("own_hero_spine")
                local picture_cfg = ConfigManager:getPlayerPictureCfg(userInfo.avatar)
                GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. tostring(picture_cfg.hero_spine), "idle", 0, true)
                --称号
                local title_id = userInfo.title
                if title_id and title_id ~= 0 then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", true)
                    local title_obj = luaBehaviour:FindGameObject("head_title_img1")
                    local title_img = luaBehaviour:FindImage("head_title_img1")
                    local title_cfg = UserDataManager.title_data:getTitleConfigById(title_id)
                    if title_cfg and title_img and title_obj then
                        title_img.enabled = true
                        GameUtil:setTextureLoadTitleLanImgText(title_img, title_cfg.icon)
                        title_img:SetNativeSize()
                        UIUtil.setScale(title_obj.transform, 0.6)
                    end
                    UIUtil.destroyAllChild(title_obj.transform)
                    if title_cfg.title_effect and title_cfg.title_effect ~= "" then
                        title_img.enabled = false
                        ResourceUtil:GetUIEffectItem("Headtitle/" .. title_cfg.title_effect, title_img.gameObject)
                    end
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_title_img1", false)
                end
                --道具
                local item_icon_id = self.m_model:getItemId()
                local itemData = RewardUtil:getProcessRewardData({103,item_icon_id,1})
                LuaBehaviourUtil.setImg(luaBehaviour, "item_flowerLogo", itemData.icon_name, itemData.atlas_name)
            end
        end
    end
end

function M:bindUI()
    self:setTextByLanKey("close_title_text", self.m_model.active_data.name)
    self:setTextByLanKey("text_title1", "flower_text_0009")
    self:setTextByLanKey("rank_reward_btn_text", "flower_text_0053")
    self:setTextByLanKey("text_myTitle", "flower_text_0068")
    self:setTextByLanKey("text_myTeamTitle", "flower_text_0069")
end

function M:destroy()
    M.super.destroy(self)
end

return M
