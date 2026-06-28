local M = class("RacconItemManager")

function M:init(control)
    self.m_control = control
    self.m_view = control.m_view
    self.m_model = control.m_model
    self.m_game_cfg = self.m_model:getGameCfg()
    self.m_item_cfg = self.m_model:getItemCfg()
    self.m_item_parent = self.m_view:getItemParentObj()
    self.item_cls = CustomRequire("UI.Raccon.RacconGame.RacconItem")
    
    self.total_time = 0
    self.item_count = 0
    self.ready_list = {}
    self.in_use_list = {}
    self.check_interval = 0.1
    self.item_generate_cds = {-1, -1, -1, -1, -1}
    self.times_since_last_item = {999, 999, 999, 999, 999}
    self.is_first_item_in_group = {true, true, true, true, true}
end

-- 道具生成开关
function M:startGenerateItem()
    self:generateItem()
    self.m_time_update_timer_id = self.m_control:setTimer(self.check_interval, handler(self, self.updateTime))
    self.m_generate_item_timer_id = self.m_control:setTimer(self.check_interval, handler(self, self.generateItem))
end

function M:stopGenerateItem()
    self.m_control:removeTimer(self.m_time_update_timer_id)
    self.m_control:removeTimer(self.m_generate_item_timer_id)
end

-- 更新道具相关时间
function M:updateTime()
    self.total_time = self.total_time + self.check_interval
    for group_num = 1, 5 do
        self.times_since_last_item[group_num] = self.times_since_last_item[group_num] + self.check_interval
    end
end

-- 生成道具
function M:generateItem()
    for group_num = 1, 5 do
        self:generateItemForGroup(group_num)
    end
end

function M:generateItemForGroup(group_num)
    local group_id = 1000 + group_num
    local start_time_key = "group"..group_num .. "_time"
    local start_time = self.m_game_cfg[start_time_key]
    if self.total_time < start_time then
        return
    end

    if self.is_first_item_in_group[group_num] or self.times_since_last_item[group_num] >= self.item_generate_cds[group_num] then
        local total_probability = 0
        for item_num = 1, 7 do
            local item_id = 1000 + item_num
            local item = self.m_item_cfg[group_id][item_id]
            local item_probability = item["weight"]
            total_probability = total_probability + item_probability
        end
        local result_probability = math.random(1, total_probability)

        local accumulated_probability = 0
        for item_num = 1, 7 do
            local item_id = 1000 + item_num
            local item = self.m_item_cfg[group_id][item_id]
            local item_probability = item["weight"]
            accumulated_probability = accumulated_probability + item_probability

            if accumulated_probability >= result_probability then
                local result_item = table.copy(item)
                result_item.id = item_id
                result_item.item_manager = self
                result_item.desk_top = self.m_view:getDeskTop()
                result_item.bowl_left_up = self.m_view:getBowlLeftUp()
                result_item.bowl_right_down = self.m_view:getBowlRightDown()
                result_item.spawn_position = self.m_view:getItemSpawnPosition(group_id)
                
                if #self.ready_list > 0 then
                    local new_item = table.remove(self.ready_list)
                    new_item:initItem(result_item)
                    self.in_use_list[new_item.count_id] = new_item
                else
                    self.item_count = self.item_count + 1
                    result_item.count_id = self.item_count
                    local new_item = self.item_cls.new(self.m_control, {parent = self.m_item_parent, item_data = result_item})
                    self.in_use_list[self.item_count] = new_item
                end

                self:resetCDForGroup(group_num)
                self.times_since_last_item[group_num] = 0
                self.is_first_item_in_group[group_num] = false
                break
            end
        end
    end
end

-- 计算道具生产随机 CD
function M:resetCDForGroup(group_num)
    local cd_key = "group" .. group_num .. "_cd"
    local cd_range = self.m_game_cfg[cd_key]
    local cd = math.random(cd_range[1] * 100, cd_range[2] * 100) / 100
    self.item_generate_cds[group_num] = cd
end

-- 道具碰撞后放入待生成列表
function M:onItemCollided(item)
    table.insert(self.ready_list, item)
    self.in_use_list[item.count_id] = nil
end

return M
