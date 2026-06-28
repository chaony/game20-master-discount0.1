local M = class("ServiceMailPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "up_to_down"
    self:getData()
end

function M:onEnter()
    self.m_code_list_data = {}
    local code_data = self.m_params or {}
    for i, v in pairs(code_data) do
        table.insert(self.m_code_list_data, {id = i, data = v})
    end
    self.m_select_index = 1
    self:sortMails(self.m_code_list_data)
end

function M:sortMails(list)
    local function sortFunc(id_one, id_two)
        local status_1 = id_one.data.status
        local status_2 = id_two.data.status
        local ts_1 = id_one.data.create_ts
        local ts_2 = id_two.data.create_ts
        local nid_1 = tonumber(id_one.id) 
        local nid_2 = tonumber(id_two.id)
        if status_1 == status_2 then
            if ts_1 == ts_2 then
                return nid_1 > nid_2
            else
                return ts_1 > ts_2
            end
        else
            return status_1 < status_2
        end
    end
    table.sort(list, sortFunc)
end

function M:updateOnMail(data)
    for i, v in pairs(self.m_code_list_data) do
        if data.id == v.id then
            v.data = data.data
        end
    end
end

function M:updateMail(data)
    for i,v in pairs(self.m_code_list_data) do
        if tonumber(v.id) == data.code_id then
            table.remove(self.m_code_list_data, i)
            break
        end
    end
end

function M:get_Codeid()
    local cur_data = self:getMailData(self.m_select_index)
    return tonumber(cur_data.id) 
end

function M:getMailData(id)
    return self.m_code_list_data[id]
end

function M:getCurCDK()
    local cur_data = self:getMailData(self.m_select_index)
    return cur_data.data.code
end

return M
