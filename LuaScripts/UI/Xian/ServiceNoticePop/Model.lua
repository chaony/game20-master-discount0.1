local M = class("ServiceNoticePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "up_to_down"
	self:getData()
end

function M:onEnter()
	self.m_notices_list_data = self.m_params or {}
	self:sortNotices(self.m_notices_list_data)
	self.m_notice_index = 1
end

function M:sortNotices(list)
    local function sortFunc(id_one, id_two)
        local status_1 = id_one.status
        local status_2 = id_two.status
        local nid_1 = id_one.nid
        local nid_2 = id_two.nid
        if status_1 == status_2 then
			return nid_1 > nid_2
        else
            return status_1 < status_2
        end
    end
    table.sort(list, sortFunc)
end

function M:changeNum(num)
    if num > #self.m_notices_list_data then
        self.m_notice_index =  #self.m_notices_list_data
        return
    elseif num == 0 then 
        self.m_notice_index = 1
        return
    else
        self.m_notice_index = num
    end
end

function M:getNoticeData(index)
	return self.m_notices_list_data[index]
end

function M:showPageNum()
    if #self.m_notices_list_data == 0 then
        return "0/0"
    end
    return  tostring(self.m_notice_index).."/"..tostring(#self.m_notices_list_data) 
end


return M
