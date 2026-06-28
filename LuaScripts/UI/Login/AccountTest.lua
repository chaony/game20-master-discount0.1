local M = {}

-- 用于下载带sdk环境的配置或登录带sdk的玩家

-- 游戏后台的账号，玩家在哪个服就填写对用的__server_id
-- gsdk_6992846911845899038   YlQJCt   少林官服  1001
-- gsdk_6985038146350095107   bukGiX   预发布  901
-- gsdk_6988755106615515940   bvBtY9   测试服  1
-- gsdk_7026640815267273479   y56b8y   提审服  101
-- 游戏服地址，需要测试账号对应的服务器入口

--local __EVN = "wl_channel" -- wl、wl_pre、wl_test、wl_audit
local __EVN = "wl_test" -- wl、wl_pre、wl_test、wl_audit
local __server_id = nil
local __domain = nil

if __EVN == "wl_pre" then  -- 预发布
    __server_id = 901
    __domain = "https://wl-pre-outer.dailygn.com/wl/s" .. __server_id
elseif __EVN == "wl_test" then  -- 测试服
    __server_id = 1
    __domain = "https://wl-dev-1.dailygn.com/wl/s" .. __server_id .. ";https://wl-dev-1.dailygn.com/wl/s" .. __server_id
elseif __EVN == "wl_audit" then -- 提审服
    __server_id = 101
    __domain = "https://wl-review-outer.dailygn.com/wl/" .. __server_id
elseif __EVN == "wl_channel" then --渠道
    __server_id = 10006
    __domain = "https://wl-prod-channel-outer.dailygn.com/wl/s" .. __server_id
else  --少林
    __server_id = 10006
    __domain = "https://wl-prod-outer.dailygn.com/wl/s" .. __server_id .. ";https://wl-prod-outer.bgip.dailygn.com/wl/s" .. __server_id
end

local all_zones = {
    {
        ["flag"] = "Idle",
        ["domain"] = __domain,
        ["ChannelID"] = "bsdk",
        ["extra_info"] = "{'android_rv':'t1.0.999','ios_rv':'t1.0.999'}",
        ["open_time"] = 1628093624,
        ["chat_addr"] =
        {
            ["2"] = 9050,
            ["1"] = "49.233.43.174",
        },
        ["server"] = __server_id,
        ["ZoneID"] = 2,
        ["ZoneName"] = __EVN,
        ["server_name"] = __EVN .. "-" .. __server_id,
        ["close_time"] = "0",
        ["fserver"] = " ",
        ["is_open"] = "Online",
    }
}

local all_roles = {
    [1] = {
        ["last_active_time"] = " ",
        ["name"] = "player_name",
        ["login_time"] = 1631503478000,
        ["frame"] = " ",
        ["server_name"] = __EVN .. "-" ..  __server_id,
        ["avatar"] = "",
        ["server_id"] = __server_id,
        ["uid"] = "1049632880",
        ["level"] = "84",
    }
}

function M:init()
    UserDataManager.server_data:setAllServerData(all_zones)
    UserDataManager.server_data:setAllRoleData(all_roles)
    local server, role = UserDataManager.server_data:getFirstServer()
    if server then
        UserDataManager.server_data:setServerData(server)
        UserDataManager.client_data.is_new_user = role.uid == ""
    end
end

return M