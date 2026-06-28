local M = class("RoomHeroNode",LikeOO.OOUIbase)

M.m_uiName = "Hotel/RoomHeroNode"
M.m_size_type = 1

function M:onCreate()
end

function M:onEnter()
    self:setTextByLanKey("hint_text", "hotel_text_030")
    self:setTextByLanKey("list_hint_text", "hotel_text_029")
	self:refreshUI()
end

function M:refreshUI()
    self:refreshHeroList()
end

--侠客列表
function M:refreshHeroList()
    local data = self.m_model:getHeroes()
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("hero_list")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 2,
            loop_scroll_object = list_scroll,
            init_cell = function(index, cell_object)
                local cell_data = data[index]
                self:listItemHandle(cell_object, index, cell_data)
            end,
            update_cell = function(index, cell_object, cell_data)
                self:listItemHandle(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "check_flag" then
                    self:updateMsg("check_flag", {oid = cell_data})
                else
                    self:updateMsg("up_hero", {oid = cell_data})
                end
                if index ~= self.m_model.m_select_index then
                    self.m_model.m_select_index = index
                end
            end,
            ui_name = self.m_uiName,
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

--初始化时调用
function M:listItemHandle(obj, index, cell_data)
    if cell_data == nil or cell_data == "" then
        return
    end
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local oid = cell_data
    local heroNode = luaBehaviour:FindGameObject("hero_node")
    GameUtil:updateHeroContent(heroNode, oid)
    --name & attrs
    local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", cfg.name)
    local attrs = self.m_model:getHeroAttrs(oid)
    for i = 1, #attrs do
        LuaBehaviourUtil.setSliderValue(luaBehaviour, "attr_" .. i, attrs[i] / 100)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"attr_text_" .. i, self.m_model:getRoomAttrName(i) .. "  " .. attrs[i])
    end
    --room
    local room = self.m_model:heroInRoom(oid)--是否已经在房间中
    if room == nil then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_flag",false)
        LuaBehaviourUtil.setText(luaBehaviour, "room_text", "")
    else
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_flag",true)
        LuaBehaviourUtil.setText(luaBehaviour, "room_text", room.name)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M