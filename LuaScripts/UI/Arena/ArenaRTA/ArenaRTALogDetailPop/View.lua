---@class ArenaRTALogDetailView:OOPopBase
---@field m_model ArenaRTALogDetailModel
local M=class("ArenaRTALogDetailView",LikeOO.OOPopBase)


M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "Arena/ArenaRTA/ArenaRTALogDetailPop"

function M:onEnter()
    self:setTextByLanKey("common_title_text","new_str_0510")
    self:setTextByLanKey("playback_text","arena_rta_str_0017")
    self:setTextByLanKey("success_ban_text","arena_rta_str_0018")
    self:setTextByLanKey("fail_ban_text","arena_rta_str_0018")

    local tm=TimeUtil.gmTime(self.m_model.battle_time)
    local time_str = string.format("%d/%02d/%02d %02d:%02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec)
    --local timerFormat = Language:getTextByKey("doubleFestival_text_0019", battle_time.year, battle_time.month, battle_time.day,
    --        battle_time.year, endT.month, endT.day)
    self:setText("battle_time_text",time_str)

    local winer=self.m_model.winer
    self:setText("success_name_text",winer.name)
    self:setText("success_score_text",winer.cur_score)

    local loser=self.m_model.loser
    self:setText("fail_name_text",loser.name)
    self:setText("fail_score_text",loser.cur_score)

    self:setObjectVisible("success_heros",self.m_model.winer.heros~=nil)
    self:setObjectVisible("fail_heros",self.m_model.loser.heros~=nil)
    self:setBanState(self.m_model.winer.heros,"success_hero_")
    self:setBanState(self.m_model.loser.heros,"fail_hero_")

    self.grade_icon={
        "rta_dan_badge_qingtong",
        "rta_dan_badge_baiyin",
        "rta_dan_badge_gold",
        "rta_dan_badge_zuanshi",
        "rta_dan_badge_dashi",
    }

    local icon=self.grade_icon[winer.tier]
    self:setImg(icon,"arena_ui","success_competitionLv_img")

    icon=self.grade_icon[loser.tier]
    self:setImg(icon,"arena_ui","fail_competitionLv_img")

    local winer_ban_hero_cfg=UserDataManager.hero_data:getHeroConfigByCid(winer.hero_ban)
    local ban_winer_hero_head_trans=self:findGameObject("ban_winer_hero_head").transform
    if winer_ban_hero_cfg then
        UIUtil.setImg(ban_winer_hero_head_trans, winer_ban_hero_cfg.icon, "hero_head_ui","head_mask/hero_head")
    end



    ban_winer_hero_head_trans=self:findGameObject("ban_loser_hero_head").transform
    local loser_ban_hero_cfg=UserDataManager.hero_data:getHeroConfigByCid(loser.hero_ban)
    if loser_ban_hero_cfg then
        UIUtil.setImg(ban_winer_hero_head_trans, loser_ban_hero_cfg.icon, "hero_head_ui","head_mask/hero_head")
    end
    --self:setImg(icon_str.badge_icon,"arena_ui","main_badge_icon")

    local success_head=self:findGameObject("success_head")
    GameUtil:setUserAvatar(success_head, {avatar =winer.avatar, frame =winer.frame,level=winer.level}, true)

    local fail_head=self:findGameObject("fail_head")
    GameUtil:setUserAvatar(fail_head,{avatar =loser.avatar, frame =loser.frame,level=loser.level}, true)

    self:setObjectVisible("playback_btn",self.m_model.battle_id~=0)
end

function M:setBanState(heros, prefixstr)
    local hero_trans =nil
    local luabehaviour=nil
    if heros~=nil then
        for i = 1, 6 do
            hero_trans =self:findGameObject(prefixstr..i).transform
            local hero_data=heros[i]
            if hero_data then
                local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.tid, quality = hero_data.evo})
                GameUtil:updateItemElementByData(hero_trans.transform, itemData,nil,nil,nil,nil,false)
                luabehaviour=UIUtil.findLuaBehaviour(hero_trans)
                LuaBehaviourUtil.setObjectVisible(luabehaviour,"banned_img",hero_data.ban==1)
            else
                hero_trans.gameObject:SetActive(false)
            end
        end
    end
end


function M:refreshUI()

end

return M