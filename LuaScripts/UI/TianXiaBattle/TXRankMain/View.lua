local M = class("TXRankMainPopView",LikeOO.OOPopBase)

M.m_uiName = "TianXiaZhengBa/TXRankMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

--[[
local ___rank_ui_data = {
    guild_war = {rank_text_key = "total_world_rank_1", rank_head_bg_img = "a_txzbphb_bhzfwanjiabg", rank_bg_img = "a_txzbphb_bhzfbg", rank_name_img = "a_txzbphb_bhzfbiaotibg"},
    hunt_treasure = {rank_text_key = "total_world_rank_2", rank_head_bg_img = "a_txzbphb_mjmbwanjiabg", rank_bg_img = "a_txzbphb_mjmbbg", rank_name_img = "a_txzbphb_mjmbbiaotibg"},
    high_arena = {rank_text_key = "total_world_rank_3", rank_head_bg_img = "a_txzbphb_txywwanjiabg", rank_bg_img = "a_txzbphb_txywbg", rank_name_img = "a_txzbphb_txywbiaotibg"},
    mystic = {rank_text_key = "total_world_rank_4", rank_head_bg_img = "a_txzbphb_mjwanjiabg", rank_bg_img = "a_txzbphb_mjbg", rank_name_img = "a_txzbphb_mjbiaotibg"},
    equip = {rank_text_key = "total_world_rank_5", rank_head_bg_img = "a_txzbphb_zbwanjiabg", rank_bg_img = "a_txzbphb_zbbg", rank_name_img = "a_txzbphb_zbbiaotibg"},
    magic_weapon = {rank_text_key = "total_world_rank_6", rank_head_bg_img = "a_txzbphb_fbwanjiabg", rank_bg_img = "a_txzbphb_fbbg", rank_name_img = "a_txzbphb_fbbiaotibg"},
    yinyang = {rank_text_key = "total_world_rank_6", rank_head_bg_img = "a_txzbphb_fbwanjiabg", rank_bg_img = "a_txzbphb_fbbg", rank_name_img = "a_txzbphb_fbbiaotibg"},
    dianfeng = {rank_text_key = "total_world_rank_10", rank_head_bg_img = "a_txzbphb_dfzlbg", rank_bg_img = "a_txzbphb_dfzlbg", rank_name_img = "a_txzbphb_dfzlbg"},
}
]]--

--local __horizontal_rank_name = {"guild_war", "hunt_treasure", "high_arena", "mystic", "equip", "magic_weapon", "yinyang"}
--local __vertical_rank_name = {}

function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "total_world_rank_text_02")
    self:setTextByLanKey("local_server_text", "total_world_rank_title_8")
    self:setTextByLanKey("cross_server_text", "total_world_rank_title_9")
    local isOpenCrossServer = self.m_model.m_isOpenCrossServer
    self:setObjectVisible("cross_server_text", isOpenCrossServer)
    self:setObjectVisible("cross_server_btn", isOpenCrossServer)
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    local total_data = self.m_model:getCurLeftRankData()
    self:setObjectVisible("icon_image1", false)
    for i = 1, #total_data do
    --for i = 1, self.m_model.m_cur_rank_nums do
        local data = total_data[i]
        local sort = data.sort
        local is_open = data and data.user
        local HeadNode = self:setObjectVisible("HeadNode".. sort, is_open)
        local btn = self:findGameObject("rank_bg_btn" .. sort)
        local function clickCallback()
            if is_open then
            --if data and next(data) then
                local rank_sort = sort
                audio:SendEvtUI("UI_BHZFeng")
                self:updateMsg("open_rank", rank_sort)
            else
                GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("total_world_rank_text_01"), delay_close = 2})
            end
        end
        UIUtil.setButtonClick(btn,clickCallback,sort)
        self:setObjectVisible("star_img".. sort, false)
        self:setObjectVisible("star_bg_img".. sort, false)
        --self:setObjectVisible("rank_name_text".. sort, data and data.user)
        --self:setObjectVisible("lock_img".. sort, not(data and data.user))
        self:setTextByLanKey("star_num_text" .. sort, "")
        local rank_bg = self:findImage("rank_bg_btn" .. sort)
        --self:setTextByLanKey("rank_name_text", ui_data.rank_text_key)
        if is_open then
            rank_bg.material = nil
            GameUtil:setUserAvatar(HeadNode,data.user, false,nil,{show_flag = true, scale = 0.8})
            local title_id = data.user.title
            local posY = {-53,-63,-32,-51,-22,-67,-33,-63}
            if title_id and title_id ~= 0 then
                HeadNode.transform.anchoredPosition = Vector3.New(HeadNode.transform.anchoredPosition.x,posY[i] + 22,0)
            else
                HeadNode.transform.anchoredPosition = Vector3.New(HeadNode.transform.anchoredPosition.x,posY[i],0)
            end
            local server_name = UserDataManager.server_data:getServerNameById(data.user.server) or ""
            --local socre = data.score or "0"
            self:setTextByLanKey("player_name_text" .. sort, data.user.name)
            self:setTextByLanKey("server_name_text" .. sort, server_name)
            if i == 1  then
                local flag_cfg = ConfigManager:getCfgByName("guild_flag")[data.user.flag]
                if flag_cfg then
                    local union_icon_img = self:findImage("icon_image1")
                    GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
                end
                self:setObjectVisible("HeadNode" .. sort, false)
                self:setObjectVisible("icon_image1", true)
            else
                self:setObjectVisible("HeadNode" .. sort, true)
            end
            self:setObjectVisible("rank_name_text".. sort, true)
            self:setObjectVisible("lock_img".. sort, false)
        else
            rank_bg.material = self.m_gray_image.material
            GameUtil:setUserAvatar(HeadNode, {},false)
            self:setTextByLanKey("player_name_text" .. sort, "")
            self:setTextByLanKey("server_name_text" .. sort, "")
            self:setObjectVisible("rank_name_text".. sort, false)
            self:setObjectVisible("lock_img".. sort, true)
        end
    end
    self:refreshCrossBtn()
    --快速导航
    self:setObjectVisible("guide_btn", true)
    local guide_btn_obj = self:findGameObject("guide_btn")
    if guide_btn_obj then
        guide_btn_obj.transform.localPosition = Vector3(273, -22.9, 0)
    end
end

function M:refreshCrossBtn()
    self:setObjectVisible("local_check_img", self.m_model.m_is_cross == 0)
    self:setObjectVisible("server_check_img", self.m_model.m_is_cross == 1)
end

--[[
	创建列表
]]
--[[
function M:updateLeftLoopScroll()
    local data = self.m_model:getCurLeftRankData()
    if self.m_left_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("left_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItemInfo(cell_object, cell_data, index, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data and next(cell_data) then
                    local rank_sort = index
                    self:updateMsg("open_rank", rank_sort)
                else
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("total_world_rank_text_01"), delay_close = 2})
                end
            end
        }
        self.m_left_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_left_loop_scroll_view:reloadData(data, true)
       
    end
end

function M:updateRightLoopScroll()
    local data = self.m_model:getCurLeftRankData()
    if self.m_right_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("right_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateItemInfo(cell_object, cell_data, index, false)
            end,

            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data and next(cell_data) then
                    local rank_sort = index
                    self:updateMsg("open_rank", rank_sort + 3)
                else
                    GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("total_world_rank_text_01"), delay_close = 2})
                end
            end
        }
        self.m_right_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_right_loop_scroll_view:reloadData(data, true)
    end
end
]]--

--[[
function M:updateItemInfo(obj, data, i,  is_left )
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local ui_data = ___rank_ui_data[__horizontal_rank_name[i]]
--[[
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    local rank_bg_img = luaBehaviour:FindImage("rank_bg_img")
    GameUtil:updateResourcesImg(rank_bg_img, "Texture/" .. ui_data.rank_bg_img)

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_name_text", ui_data.rank_text_key)
    LuaBehaviourUtil.setImg(luaBehaviour, "rank_name_img", ui_data.rank_name_img, "mystic_ui")
    LuaBehaviourUtil.setImg(luaBehaviour, "rank_head_bg_img", ui_data.rank_head_bg_img, "mystic_ui")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_rank_text", "new_str_0835")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_rank_text", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "HeadNode", data and next(data))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_img", data and next(data))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "star_bg_img", data and next(data))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_name_text", data and next(data))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_head_bg_img", data and next(data))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_name_img", data and next(data))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", not(data and next(data)))
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_image1", false)
    if data and next(data) then
        GameUtil:setUserAvatar(HeadNode,data.user, false,nil,{show_flag = true, scale = 0.8})
        local title_id = data.user.title
        local posY = {-32,-63,-32,-51,-22,-67,-33}
        if title_id and title_id ~= 0 then
            HeadNode.transform.anchoredPosition.y = posY[i]+20
        else
            HeadNode.transform.anchoredPosition.y = posY[i]
        end
        local server_name = UserDataManager.server_data:getServerNameById(data.user.server) or ""
        local socre = data.score or "0"
        LuaBehaviourUtil.setText(luaBehaviour, "player_name_text", data.user.name)
        LuaBehaviourUtil.setText(luaBehaviour, "star_num_text", GameUtil:formatValueToString(socre))
        LuaBehaviourUtil.setText(luaBehaviour, "server_name_text", server_name)
        if i == 1 and is_left then
            local flag_cfg = ConfigManager:getCfgByName("guild_flag")[data.user.flag]
            if flag_cfg then
                local union_icon_img = luaBehaviour:FindImage("icon_image1")
                GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
            end
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "HeadNode", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_image1", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "HeadNode", true)
        end
    else
        GameUtil:setUserAvatar(HeadNode, {},false)
        LuaBehaviourUtil.setText(luaBehaviour, "player_name_text", "")
        LuaBehaviourUtil.setText(luaBehaviour, "star_num_text", "")
        LuaBehaviourUtil.setText(luaBehaviour, "server_name_text", "")
    end
end
]]--

--function M:refreshRedPoint()
--end

return M