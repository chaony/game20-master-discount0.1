local M = class("WindAndCloudRedPacketView", LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudRedPacket"
M.m_size_type = 2

local _get_clolor = Color( 255/255, 229/255, 181/255)
local _sent_clolor = Color( 255/255, 242/255, 211/255)

local __TAB_BTN_NODE = {
    {btn_key = "tog_1", btn_text = "tog_1_text", text_key = "wind_clouds_red_packet_text_0005", open = true, url_key = "high_arena_select_arena_rank"}, -- 赛季积分榜
    {btn_key = "tog_2", btn_text = "tog_2_text", text_key = "wind_clouds_red_packet_text_0004", open = true, url_key = "high_arena_select_arena_score_rank"}, -- 积分总榜
}

function M:onEnter()
    self.m_toggle_btns = {}
    self:setTextByLanKey("common_title_text", "wind_clouds_red_packet_text_0001")
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, Language:getTextByKey(v.text_key))
        local tog_btn = self:findToggle(v.btn_key)
        self.m_toggle_btns[k] = tog_btn
        if k == self.m_model.m_mode then
            tog_btn.isOn = true
        end
        UIUtil.addToggleListener(tog_btn, function(is_on)
            if is_on then
                self:updateMsg(k)
            end
        end,nil,self.m_uiName)
    end
	self:refreshUI()
end

function M:refreshUI(keep_offset)
    self:setTextByLanKey("can_get_text", "wind_clouds_red_packet_text_0006",self.m_model.m_left_rec,self.m_model.m_redpacket_nums)
    self:setTextByLanKey("can_sent_text", "wind_clouds_red_packet_text_0007",table.nums(self.m_model.m_send_redpacker_list))
    self:setTextByLanKey("have_sent_text", "wind_clouds_red_packet_text_0008",self.m_model.m_has_sent)
    self:setObjectVisible("can_get_text",self.m_model.m_mode == 2)
    self:setObjectVisible("can_sent_text",self.m_model.m_mode == 1)
    self:setObjectVisible("have_sent_text",self.m_model.m_mode == 1)
    if keep_offset == nil then
        keep_offset = false
    end
	self:createLoopScroll(keep_offset)
end

function M:createLoopScroll(keep_offset)
    local data = self.m_model:getRedPacketList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("redpacket_scroll")
        local params = {
            show_data = data,
            one_line_count = 4,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if luaBehaviour then
                    local select_mode = self.m_model.m_mode
                    local type_str = ""
                    local name_str = ""
                    if select_mode == 1 then
                        local cfg = self.m_model.cur_red_packer_cfg[tonumber(cell_data)]
                        local name = Language:getTextByKey(cfg.name) 
                        type_str = string.sub(name,1,12)  --和策划再三确认  配置的红包名字 由四个汉字和后面的数字组成
                        name_str = string.sub(name,13,string.len(name))
                    elseif select_mode == 2 then
                        type_str =  UserDataManager.server_data:getServerNameById(cell_data[4])
                        name_str = cell_data[2]
                    end 
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "type_text", type_str)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "receive_award_text", select_mode == 2 and "wind_clouds_red_packet_text_0003" or "wind_clouds_red_packet_text_0002")
                    local name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", name_str)
                    name_text.color =  select_mode == 2 and _get_clolor or _sent_clolor
                    name_text.fontSize = select_mode == 2 and 22 or 20
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name,cell_data)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data,keep_offset)
    end
end

return M
