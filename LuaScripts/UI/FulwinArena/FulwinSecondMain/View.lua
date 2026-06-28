
local M = class("FulwinSecondMainView",LikeOO.OOPopBase)
-- 风云擂台晋级赛
M.m_uiName = "FulwinArena/FulwinSecondMain"  -- prefab name
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
    self:setTextByLanKey("close_title_text", "fylt_str_0021")
    self:setTextByLanKey("bailei_text", "options_str_0011")
    self:setTextByLanKey("chat_text", "fylt_str_0064")
    self:setTextByLanKey("start_text", "fylt_str_0066")
    self:setTextByLanKey("formation_text", "fylt_str_0065")
    self:setTextByLanKey("reday_btn_text", "fylt_str_0068")

    for i=1, 8 do
        local obj = self:findGameObject("cell_"..i)
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        local remove_btn = luaBehaviour:FindGameObject("remove_btn")
        local add_player = luaBehaviour:FindGameObject("add_player")
        local player_btn = luaBehaviour:FindGameObject("player_btn")
        
        UIUtil.setButtonClick(remove_btn.transform, function(obj, data)
            self:updateMsg("remove_player", data)
        end, i, nil, self.m_uiName)

        UIUtil.setButtonClick(add_player.transform, function()
            self:updateMsg("add_player")
        end, nil, nil, self.m_uiName)

        UIUtil.setButtonClick(player_btn.transform, function(obj,data)
            self:updateMsg("player_btn", data)
        end, i, nil, self.m_uiName)
    end
    self:refreshUI()  
end

function M:refreshUI()
    self:setTextByLanKey("house_num_text", Language:getTextByKey("fylt_str_0070") .. self.m_model.m_ring_id)
    local is_president = self.m_model:isPresident()
    local is_ready = self.m_model:selfIsReady()
    self:setObjectVisible("start_btn", is_president)
    self:setObjectVisible("bailei_btn", is_president)
    self:setObjectVisible("reday_btn", is_president == false and is_ready == false)
    for i = 1,8 do 
        self:updateCell(i, is_president)
    end

    local races = self.m_model:getDisableRace()
    local jobs = self.m_model:getDisableJob()
    if #races == 0 and #jobs == 0 then
        self:setObjectVisible("ban_text", false)
        self:setObjectVisible("ban_bg_img", false)
    else
        self:setObjectVisible("ban_text", true)
        self:setObjectVisible("ban_bg_img", true)
        for i=1, 4 do
            local race = self.m_model:getDisableRaceByIndex(i)
            if race then
                self:setObjectVisible("race_img_" .. i, true)
                local race_cfg = GlobalConfig.TYPE_HERO_RACE[race]
                if race_cfg then
                    self:setImg(race_cfg.race_icon, ResourceUtil:getLanAtlas(), "race_img_" .. i)
                else
                    self:setObjectVisible("race_img_" .. i, false)
                end
            else
                self:setObjectVisible("race_img_" .. i, false)
            end
            local job = self.m_model:getDisableJobByIndex(i)
            if job then
                self:setObjectVisible("job_img_" .. i, true)
                local job_cfg = GlobalConfig.CLASS_MERIDIAN[job]
                if job_cfg then
                    self:setImg(job_cfg.arena_icon, ResourceUtil:getLanAtlas(), "job_img_" .. i)
                else
                    self:setObjectVisible("job_img_" .. i, false)
                end
            else
                self:setObjectVisible("job_img_" .. i, false)
            end
        end
    end
    
    local format_red = self.m_model:teamFormationRed()
    self:setObjectVisible("formation_red_img", format_red)
end

function M:updateCell(index, president)
    local obj = self:findGameObject("cell_"..index)
    local data = self.m_model:getPlayerData(index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local is_landlord = index == 1 --擂主
    local landlord_img = luaBehaviour:FindGameObject("landlord_img") --擂主标识
    local remove_btn = luaBehaviour:FindGameObject("remove_btn") --踢人按钮
    local ready_text = luaBehaviour:FindGameObject("ready_text") --已准备文字
    local HeadNode = luaBehaviour:FindGameObject("HeadNode") --玩家头像组件
    local add_player = luaBehaviour:FindGameObject("add_player") --空玩家头像
    local name_bg = luaBehaviour:FindGameObject("name_bg") --名字底板
    local combat_img = luaBehaviour:FindGameObject("combat_img") --战力图片
    local combat_num_text = luaBehaviour:FindGameObject("combat_num_text") --战力文字
    local player_btn = luaBehaviour:FindGameObject("player_btn")

    landlord_img:SetActive(is_landlord == true)
    if data and next(data) ~= nil then
        add_player:SetActive(false)
        HeadNode:SetActive(true)
        GameUtil:setUserAvatar(HeadNode, data.user_info)
        remove_btn:SetActive(president and is_landlord == false)
        player_btn:SetActive(true)
        name_bg:SetActive(true)
        combat_img:SetActive(true)
        ready_text:SetActive(not is_landlord)
        combat_num_text:SetActive(true)
        LuaBehaviourUtil.setText(luaBehaviour,"combat_num_text", GameUtil:formatValueToString(data.user_info.full_combat))
        LuaBehaviourUtil.setText(luaBehaviour,"cell_name", data.user_info.name)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"ready_text", data.ready == 1 and "fylt_str_0091" or "fylt_str_0092")
    else
        HeadNode:SetActive(false)
        add_player:SetActive(true)
        remove_btn:SetActive(false)
        name_bg:SetActive(false)
        combat_img:SetActive(false)
        ready_text:SetActive(false)
        combat_num_text:SetActive(false)
        player_btn:SetActive(false)
    end

end
function M:destroy()
    M.super.destroy(self)
end

return M


