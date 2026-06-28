
---@class XiakedaoView:OOPopBase
---@field m_model XiakedaoModel
local M=class("XiakedaoView",LikeOO.OOPopBase)

M.m_uiName="Xiakedao/Xiakedao"
M.m_size_type=1
M.m_iphoneXAdapter=true

function M:onEnter()

    self:setTextByLanKey("xiakedao_title_text", "world_str_020")
    self:setTextByLanKey("close_title_text", "new_str_0478")
    self:setTextByLanKey("benqifangke_text", "new_str_1116")
    self:setTextByLanKey("huodong01_text", "new_str_1117")
    self:setTextByLanKey("zongbang_text", "new_str_1118")
    self:setTextByLanKey("kuizeng_text", "new_str_1120")
    self:setTextByLanKey("canwu_text", "new_str_1121")
    self:setTextByLanKey("daozhutequan_text", "new_str_1114")
    self:setTextByLanKey("taixuanjing_text", "new_str_1119")

    self:setTextByLanKey("countdown_text","new_str_1115")
    self.m_end_ts=self.m_model.m_data.end_ts
    self.data=self.m_model.m_data

    if GameVersionConfig.CLIENT_VERSION == UserDataManager.server_data.review_vsn then
        self:setObjectVisible("huodong02", false)
    end

    self.parent=self:findRectTransform("relicChoiceNodeParent")
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self:refreshUI()
end

function M:refreshUI()
    self:refreshTop3Node()
    self:refreshLosenum()
    self:refreshSP()
    self:refreshRedPoint()

    self:checkDrop_heirlooms()
end

function M:checkDrop_heirlooms()
    if table.nums(self.m_model.m_data.drop_heirlooms)>0 then
        local relicChoiceNode=CustomRequire("UI.Xiakedao.Relic.RelicChoiceNode")
        relicChoiceNode.new(self.m_control,{parent=self.parent})
    end

end
function M:dataUpdateEvent(event, data)
    if data.event == "remove_red_dot" or data.event == "red_dot_update" then
        self:refreshRedPoint()
    end
end

function M:refreshRedPoint()
    self:refreshRedPoint_Canwu()
    self:refreshRedPoint_Kuizeng()
end

function M:refreshRedPoint_Canwu()
    local red_flag=UserDataManager:getRedDotByKey("hero_isle")
    self:setObjectVisible("canwu_red_point_img",red_flag==1)
end

function M:refreshRedPoint_Kuizeng()
    if self.m_model==nil then
        return
    end
    local red_flag=0
    local quest_data = UserDataManager:getChapterQuestSpecialData(self.m_model.hero_isle_visitor_cfg_item.target_type)
    for i, v in pairs(quest_data) do
        ---存在未领取的
        if v.status==2 then
            red_flag =1
            break
        end
    end
    self:setObjectVisible("kuizeng_red_point_img",red_flag==1)
end


function M:updateTime()
    if self.m_end_ts ~= nil then
        local time_end = self.m_end_ts - UserDataManager:getServerTime()
        self:setTextByLanKey("countdown","new_str_1126",GameUtil:formatTimeBySecond(time_end))
        --self:setText("countdown", GameUtil:formatTimeBySecond(time_end))
        if time_end <= 0 then
            self:updateMsg(99999)
        end
    end
end

function M:refreshLosenum()
    local lose_num=self.m_model.m_data.lose_num
    if lose_num<0 then
        lose_num=0
    end
    self:setTextByLanKey("lose_num_text","new_str_1125",lose_num)
    self:setTextByLanKey("layer_num_text","new_str_1132",self.m_model.m_data.layer-1)
end

function M:refreshSP()
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.data.visitor)
    self:setTextByLanKey("class_name",cfg.class)
    self:setTextByLanKey("hero_name",cfg.name)

    local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon --英雄种族icon
    self:setImg(race, ResourceUtil:getLanAtlas(), "hero_race")

    --local FRAME_QUA = GlobalConfig.QUALITY_FRAME[cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui", "hero_evo")

    local icon=cfg.hero_spine
    --icon="hero_0309_SkeletonData"
    local play_img = self:findGameObject("hero_sk")
    if self.m_hero_spine == nil then
        self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. icon, "idle", 0, true)
    end
end


function M:refreshTop3Node()
    local top3_rank_data = self.m_model:getCurTop3RankData()
    for i = 1, 3 do
        --local player_name_text = self:findGameObject("player_name_text" .. i)
        --local server_name_text = self:findGameObject("server_name_text" .. i)
        --local star_num_text = self:findGameObject("star_num_text" .. i)
        --local like_num_text = self:findGameObject("like_num_text" .. i)
        --local head_node = self:findGameObject("HeadNode" .. i)
        local rank_data = top3_rank_data[i] and top3_rank_data[i] or nil
        self:setObjectVisible("player_name_text" .. i, rank_data and true or false)
        self:setObjectVisible("server_name_text" .. i, rank_data and true or false)
        self:setObjectVisible("star_num_text" .. i, rank_data and true or false)
        self:setObjectVisible("like_num_text" .. i, rank_data and true or false)
        self:setObjectVisible("rank_img" .. i, rank_data and true or false)
        self:setObjectVisible("star_img" .. i, (rank_data ~= nil) and (not self.m_model.m_isShowRank))
        self:setObjectVisible("like_bg_img" .. i, rank_data  and true or false)
        self:setObjectVisible("star_bg_img" .. i, rank_data and true or false)
        self:setObjectVisible("like_img" .. i, rank_data and true or false)
        self:setObjectVisible("icon_image" .. i, false)
        local head_node = self:setObjectVisible("HeadNode" .. i,  false)
        self:setObjectVisible("no_people_text" .. i, true)

        if rank_data then
            self:setObjectVisible("no_people_text" .. i, false)
            local server_name = UserDataManager.server_data:getServerNameById(rank_data.user.server)
            self:setText("player_name_text" .. i, rank_data.user.name)
            self:setText("server_name_text" .. i, server_name)
            --self:setText("star_num_text" .. i, GameUtil:formatValueToString(rank_data.score) )
            --self:setText("like_num_text" .. i, rank_data.like and GameUtil:formatValueToString(rank_data.like) or "0")

            self:setText("star_num_text" .. i, rank_data.score)
            self:setText("like_num_text" .. i, rank_data.lose_num and rank_data.lose_num or "0")

            if self.m_model.m_cur_rank_sort == 1 then
                local flag_cfg = ConfigManager:getCfgByName("guild_flag")[rank_data.user.flag]
                if flag_cfg then
                    local union_icon_img = self:findImage("icon_image" .. i)
                    GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
                end
                self:setObjectVisible("icon_image" .. i,  true)
                self:setObjectVisible("HeadNode" .. i,  false)
            else
                self:setObjectVisible("HeadNode" .. i,  true)
            end
            GameUtil:setUserAvatar(head_node, rank_data.user, false,nil,{show_flag = true, scale = 1})
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M