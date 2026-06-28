local M = {

    chat = [[
        syntax = "proto3";

        package chat;
        

        // common
        message ChatResult {
            int32 code = 1;
            string msg = 2;
        }

        message Empty {}


        // request
        message ChatRequestPack {
            ChatResult result = 1;
            ChatLoginRequest req1 = 100;
            ChatMessageRequest req2 = 101;
            ChatJoinChannelRequest req3 = 102;
            ChatQuitChannelRequest req4 = 103;
            ChatHeartbeatRequest req5 = 104;
            GetChatRecodeRequest req7 = 107;
            SetReadTsRequest req8 = 108;
        }

        // response
        message ChatResponsePack {
            ChatResult result = 1;
            ChatLoginResponse res1 = 100;
            ChatMessageResponse res2 = 101;
            ChatJoinChannelResponse res3 = 102;
            ChatQuitChannelResponse res4 = 103;
            Empty req5 = 104;
            ChatDeleteResponse res6 = 106;
            GetChatRecodeResponse res7 = 107;
            SetReadTsResponse res8 = 108;
            EventMessageNotify res9 = 109;
        }


        // 登录请求
        message ChatLoginRequest {
            int64 uid = 1;
            int64 sid = 2;
            int64 platform = 3;     // 平台 0: android 1: ios 废弃
            string device_id = 4;   // IMEI on android 废弃
            string mac = 5;         // mac地址 废弃
            string model = 6;       // 机型 废弃
            string language = 7;    // 语言 废弃
            string server_id = 8;   // 游戏服务器ID 废弃
            string guild_id = 9;    // 公会id 废弃
            string new_sid = 10;    // 登录标识
        }


        // 登录响应
        message ChatLoginResponse {
            string sid = 1;
            repeated ChatMessageResponse msgs = 2;
            repeated ChatCDLimit cd_limits = 3;          // cd限制
	        repeated ChatTimesLimit times_limits = 4;    // 次数限制
	        repeated ChatTimestampResponse tss = 5;
        }


        // 消息请求
        message ChatMessageRequest {
            int64 uid = 1;          // 用户id 废弃
            string name = 2;        // 用户名 废弃
            string avatar = 3;      // 用户头像 废弃
            string frame = 4;       // 用户头像框 废弃
            string msg = 5;         // 消息
            string channel_type = 6;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 7;      // 频道id 1-本地 2-世界 3-工会 4-私聊
            string target_name = 8;      // 目标名字
            int64 title = 9; // 称号
            int64 event = 10; //事件类型 1.游园活动 2.风云擂台
            string event_ext = 11; //事件参数
        }


        // 消息响应
        message ChatMessageResponse {
            int64 uid = 1;          // 用户id
            string name = 2;        // 用户名
            string avatar = 3;      // 用户头像
            string frame = 4;       // 用户头像框
            string msg = 5;         // 消息
            string channel_type = 6;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 7;      // 频道id 私聊id
            string time = 8;        // 时间搓
            string msg_id = 9;      // 消息id
            string target_name = 10;      // 目标名字
            //    int64 cd = 11;      // cd时间 废弃
            //    int64 times = 12;      // 已经聊天次数 废弃
            ChatCDLimit cd_limit = 13;          // cd限制
            ChatTimesLimit times_limit = 14;    // 次数限制
            int64 title = 15;      // 称号
            repeated Medal medals = 16;  // 勋章
            int64 event = 17;           // 事件类型
            string event_ext = 18;      // 事件参数
        }


        // 时间戳
        message ChatTimestampResponse {
            string channel_id = 1;      // 频道id 私聊id
            string ts = 2;        // 时间戳
        }
        
        
        // 消息请求 - 102
        message ChatJoinChannelRequest {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }


        // 消息响应 - 102
        message ChatJoinChannelResponse {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }


        // 消息请求 - 103
        message ChatQuitChannelRequest {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }


        // 消息响应
        message ChatQuitChannelResponse {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string channel_id = 2;      // 频道id
        }


        // 心跳消息请求 - 0
        message ChatHeartbeatRequest {
            int64 uid = 1;
        }

        // 删除聊天消息响应
        message ChatDeleteResponse {
            int64 uid = 1;          // 用户id
        }

        // 聊天cd限制
        message ChatCDLimit {
            string cd_type = 1;          // cd类型  1-本服和世界 3-公会 4-私聊
            int32 cd = 2;                // cd时间搓 0 无限制 >0 最后聊天时间搓
        }

        // 聊天次数限制
        message ChatTimesLimit {
            string channel_type = 1;        // 频道类型 1-本地 2-世界 3-工会 4-私聊
            int32 times = 2;                // 已经聊天次数
        }
        // 勋章
        message Medal {
            int64 medal_id = 1;             // 勋章id
            int64 expire_time = 2;         // 勋章过期时间
        }
        
        // 获取聊天记录请求
        message GetChatRecodeRequest {
            int64 uid = 1;
            string channel_type = 2;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
        }
        
        // 获取聊天记录响应
        message GetChatRecodeResponse {
           repeated ChatMessageResponse msgs = 2;
        }
        
        
        // 设置已读时间请求
        message SetReadTsRequest {
            string channel_type = 1;    // 频道类型 1-本地 2-世界 3-工会 4-私聊
            string target_uid = 2;    // 目标uid，只有私聊时传入
            string ts = 3;    // 时间戳
        }
        
        // 获取已读时间响应
        message SetReadTsResponse {
           string msg = 1;    // 结果
        }

        //游戏中活动更新通知
        message EventMessageNotify {
            string event_type = 1; // 事件类型
            string json_data = 2; // json字符串
        }
    ]]
}
return M