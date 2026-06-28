local M = class("NoticePopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	--self:requestNotice()
    local params =
    {
        account = UserDataManager.client_data.user_account,
        package_name = SDKUtil.sdk_params.applicationId,
    }
	self:getData( "notice", params, nil, nil, {forceBack = true})
end

function M:requestNotice(callBack)
	local function responseMethod(response)
		if response then
			local data = Json.decode(response)
			self:callBack({notices = data})
		else
			self:requestNotice()
		end
	end
	local url = UserDataManager.server_data:getNoticeUrl()
	if url ~= nil then
		NetWork:httpRequest(responseMethod ,url ,GlobalConfig.GET ,{} ,"notice" ,1,true ,2 ,true)
	else
		self:getData()
	end
end

function M:onEnter()
self.m_select_index = 1

    local notice = {}

    local welfare_notice = ConfigManager:getCfgByName("welfare_notice")
    local function sortFunc(d1,d2)
        local order1 = d1.order or 0
        local order2 = d2.order or 0
        return order1 < order2
    end

    local date_pattern = "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)"
    local cur_time = TimeUtil.getTime()
    --Logger.log(os.date("%Y-%m-%d %H:%M:%S", cur_time))

    if self.m_data and self.m_data.notices then
        for i,v in pairs(self.m_data.notices) do
            --local cfg = welfare_notice[v]
            --notice[i] = cfg
            local conf = welfare_notice[v]

            table.insert(notice, conf)


            -- local start_time = v.start_time or "1971-01-01 1:00:00"
            -- local end_time = v.end_time or '1971-01-01 23:59:59'
            -- local _, _, s_y, s_m, s_d, s_hour, s_min, s_sec = string.find(start_time, date_pattern)
            -- local _, _, e_y, e_m, e_d, e_hour, e_min, e_sec = string.find(end_time, date_pattern)
            -- -- 当前所处时区的时间戳
            -- local s_timestamp = os.time({year=s_y, month = s_m, day = s_d, hour = s_hour, min = s_min, sec = s_sec})
            -- local e_timestamp = os.time({year=e_y, month = e_m, day = e_d, hour = e_hour, min = e_min, sec = e_sec})
            -- if cur_time >= s_timestamp and cur_time <= e_timestamp then
            -- end
        end
    end
    table.sort(notice, sortFunc)
    local sdk_notice = UserDataManager:getNotice()
    table.sort(sdk_notice, sortFunc)
    for i,v in ipairs(sdk_notice) do
        local data = {}
        data.name = v.name
        data.title = v.title
        data.des = v.des
        data.url = v.url or ""
        data.mark = 0
        notice[#notice + 1] = data
    end


    self.m_notice = notice
end

function M:setSelectIndex(index)
	self.m_select_index = index;
end

function M:getNoticeByIndex(index)
	return self.m_notice[index]
end

return M
