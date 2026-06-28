---@class WindAndCloudRedEnvelopeView: OOPopBase
local M = class("WindAndCloudRedEnvelopeView", LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudRedEnvelope"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    --self:updateActivityTimer()
    --self.avtive_data = self.m_model:getActiveCfg()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 13})
    RedPointUtil:saveLocalRedPointFreshTime("WindAndCloudRedEnvelope")
    self:refreshUI()
end

function M:refreshUI()
    self:bindUI()
    self:updateLoopScroll() --奖励预览
    self:refreshList() --排行榜
    self:updateOpenTimes()-- 开启次数刷新
    self:refreshOwnItem()
    --self:updateRedPoint()--刷新红点

    self:updateMsg("refresh_red_point", nil, "WindAndCloud.WindAndCloudRedEnvelope")
    --self:refreshRightNode()
end



function M:bindUI()
    local active = ConfigManager:getCfgByName("active")
    local title = "wind_clouds_text_0005"
    for k,v in pairs(active) do
        if v.open_id == self.m_model.open_id and v.version ==self.m_model.m_version then
            title = v.name
        end
    end
    self:setTextByLanKey("close_title_text", title)
    self:setTextByLanKey("peak_game_btn_text", "wind_clouds_text_0008")
    self:setTextByLanKey("red_big_txt", "wind_clouds_text_00010")
    self:setTextByLanKey("scroll_title_text1", "wind_clouds_text_00011")
    self:setTextByLanKey("scroll_title_text2", "wind_clouds_text_00012")
    self:setTextByLanKey("scroll_title_text3", "wind_clouds_text_00013")
    self:setTextByLanKey("reward_preview_btn_text", "wind_clouds_text_00014")
end

------------
--[[
	奖励显示
]]
function M:updateLoopScroll()
    self.m_click_cell_object = nil
    local data = self.m_model:getGachaShipRewards(1)
    --self:setObjectVisible("CommonTipsNode", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("reward_preview_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            one_line_count = 2, -- 行或列的数量
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local status = cell_data.status
                if status ~= -1 then
                    self:updateMsg(status == 2 and "main_reward" or "goto_btn", cell_data)
                    self.m_click_cell_object = cell_object
                end
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
    if cell_data.sort == 1 then
        --大奖
        local lua_behaviour = cell_object:GetComponent("LuaBehaviour")
        if lua_behaviour ~= nil then
            LuaBehaviourUtil.setObjectVisible(lua_behaviour,"UI_Reward_LingQu_003",true)
        end
    end
    GameUtil:updateItemElement(cell_object, cell_data.reward[1], true, true)
end

--刷新排行榜list
function M:refreshList()
    local data = self.m_model:showFourListData()
    if self.m_roleScroll_view == nil then
        local loopscroll = self:findGameObject("top_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshItem(cell_obj, cell_data, index)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            pull_refresh = function() -- 下拉刷新
                --self.last_offsety1 = self.m_loop_scroll_view1.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view1.m_scroll_rect.content.rect.height
                self:updateMsg("load_rank")
            end,
        }
        self.m_roleScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_roleScroll_view:reloadData(data, true)
    end
end

--刷新活动数据显示
function M:refreshItem(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        LuaBehaviourUtil.setText(luaBehaviour, "index_text", cell_data.rank )
        local userInfo = cell_data.user
        LuaBehaviourUtil.setText(luaBehaviour, "guild_text", userInfo.name )
        LuaBehaviourUtil.setText(luaBehaviour, "score_text", cell_data.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        GameUtil:setUserAvatar(head_node, userInfo,false,false,false)
    end
end

function M:refreshOwnItem()
    local cell_data = self.m_model:getOwnItem()
    local cell_obj = self:findGameObject("myInfoNode")
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        LuaBehaviourUtil.setText(luaBehaviour, "index_text", cell_data.rank >0 and cell_data.rank or Language:getTextByKey("wind_clouds_red_packet_text_00014")   )
        local userInfo = cell_data.user
        LuaBehaviourUtil.setText(luaBehaviour, "guild_text", userInfo.name )
        LuaBehaviourUtil.setText(luaBehaviour, "score_text", cell_data.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        GameUtil:setUserAvatar(head_node, userInfo,false,false,false)
    end
end


--刷新开启次数
function M:updateOpenTimes()
    local text = Language:getTextByKey("wind_clouds_text_00015")
    local numText =  Language:getTextByKey("wind_clouds_text_00016")
    local num1,num2 = self.m_model:getOpenTimes()
    --num1 = num1 ==0 and 0 or (num1%num2 == 0 and num2 or num1%num2)
    local realText = text..string.format(numText,num1,num2)
    self:setTextByLanKey("open_text",realText)
    self:setTextByLanKey("title_times_txt",num2)
    local cfg = ConfigManager:getCfgByName("redbag_draw")
    local name = cfg and cfg[self.m_model.open_id][self.m_model.m_version].must or "wind_clouds_red_packet_text_00012"
    self:setTextByLanKey("title_name_txt",name)
end

--刷新红点
function M:updateRedPoint()
    local red_flag = UserDataManager:getRedDotByKey("redbag") 
    self:setObjectVisible("red_big_point_img",red_flag ==1)
end

function M:updateActivityTimer(status)
    self:setObjectVisible("red_big_point_img",status ==1)
end

function M:destroy()
    M.super.destroy(self)
    if  self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
end

return M
