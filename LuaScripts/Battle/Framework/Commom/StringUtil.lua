--------------------------------
-- @module string StringUtil


string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

-- start --

--------------------------------
-- 将特殊字符转为 HTML 转义符
-- @function [parent=#string] htmlspecialchars
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将特殊字符转为 HTML 转义符

~~~ lua

print(string.htmlspecialchars("<ABC>"))
-- 输出 &lt;ABC&gt;

~~~

]]

-- end --

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

-- start --

--------------------------------
-- 将 HTML 转义符还原为特殊字符，功能与 string.htmlspecialchars() 正好相反
-- @function [parent=#string] restorehtmlspecialchars
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将 HTML 转义符还原为特殊字符，功能与 string.htmlspecialchars() 正好相反

~~~ lua

print(string.restorehtmlspecialchars("&lt;ABC&gt;"))
-- 输出 <ABC>

~~~

]]

-- end --

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

-- start --

--------------------------------
-- 将字符串中的 \n 换行符转换为 HTML 标记
-- @function [parent=#string] nl2br
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将字符串中的 \n 换行符转换为 HTML 标记

~~~ lua

print(string.nl2br("Hello\nWorld"))
-- 输出
-- Hello<br />World

~~~

]]

-- end --

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

-- start --

--------------------------------
-- 将字符串中的特殊字符和 \n 换行符转换为 HTML 转移符和标记
-- @function [parent=#string] text2html
-- @param string input 输入字符串
-- @return string#string  转换结果

--[[--

将字符串中的特殊字符和 \n 换行符转换为 HTML 转移符和标记

~~~ lua

print(string.text2html("<Hello>\nWorld"))
-- 输出
-- &lt;Hello&gt;<br />World

~~~

]]

-- end --

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

-- start --

--------------------------------
-- 用指定字符或字符串分割输入字符串，返回包含分割结果的数组
-- @function [parent=#string] split
-- @param string input 输入字符串
-- @param string delimiter 分割标记字符或字符串
-- @return array#array  包含分割结果的数组

--[[--

用指定字符或字符串分割输入字符串，返回包含分割结果的数组

~~~ lua

local input = "Hello,World"
local res = string.split(input, ",")
-- res = {"Hello", "World"}

local input = "Hello-+-World-+-Quick"
local res = string.split(input, "-+-")
-- res = {"Hello", "World", "Quick"}

~~~

]]

-- end --

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

-- start --

--------------------------------
-- 去除输入字符串头部的空白字符，返回结果
-- @function [parent=#string] ltrim
-- @param string input 输入字符串
-- @return string#string  结果
-- @see string.rtrim, string.trim

--[[--

去除输入字符串头部的空白字符，返回结果

~~~ lua

local input = "  ABC"
print(string.ltrim(input))
-- 输出 ABC，输入字符串前面的两个空格被去掉了

~~~

空白字符包括：

-   空格
-   制表符 \t
-   换行符 \n
-   回到行首符 \r

]]

-- end --

function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

-- start --

--------------------------------
-- 去除输入字符串尾部的空白字符，返回结果
-- @function [parent=#string] rtrim
-- @param string input 输入字符串
-- @return string#string  结果
-- @see string.ltrim, string.trim

--[[--

去除输入字符串尾部的空白字符，返回结果

~~~ lua

local input = "ABC  "
print(string.rtrim(input))
-- 输出 ABC，输入字符串最后的两个空格被去掉了

~~~

]]

-- end --

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

-- start --

--------------------------------
-- 去掉字符串首尾的空白字符，返回结果
-- @function [parent=#string] trim
-- @param string input 输入字符串
-- @return string#string  结果
-- @see string.ltrim, string.rtrim

--[[--

去掉字符串首尾的空白字符，返回结果

]]

-- end --

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

-- start --

--------------------------------
-- 将字符串的第一个字符转为大写，返回结果
-- @function [parent=#string] ucfirst
-- @param string input 输入字符串
-- @return string#string  结果

--[[--

将字符串的第一个字符转为大写，返回结果

~~~ lua

local input = "hello"
print(string.ucfirst(input))
-- 输出 Hello

~~~

]] 

-- end --

function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

-- start --

--------------------------------
-- 将字符串转换为符合 URL 传递要求的格式，并返回转换结果
-- @function [parent=#string] urlencode
-- @param string input 输入字符串
-- @return string#string  转换后的结果
-- @see string.urldecode

--[[--

将字符串转换为符合 URL 传递要求的格式，并返回转换结果

~~~ lua

local input = "hello world"
print(string.urlencode(input))
-- 输出
-- hello%20world

~~~

]]

-- end --

function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

-- start --

--------------------------------
-- 将 URL 中的特殊字符还原，并返回结果
-- @function [parent=#string] urldecode
-- @param string input 输入字符串
-- @return string#string  转换后的结果
-- @see string.urlencode

--[[--

将 URL 中的特殊字符还原，并返回结果

~~~ lua

local input = "hello%20world"
print(string.urldecode(input))
-- 输出
-- hello world

~~~

]]

-- end --

function string.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

-- start --

--------------------------------
-- 计算 UTF8 字符串的长度，每一个中文算一个字符
-- @function [parent=#string] utf8len
-- @param string input 输入字符串
-- @return integer#integer  长度

--[[--

计算 UTF8 字符串的长度，每一个中文算一个字符

~~~ lua

local input = "你好World"
print(string.utf8len(input))
-- 输出 7

~~~

]]

-- end --

function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

-- start --

--------------------------------
-- 将数值格式化为包含千分位分隔符的字符串
-- @function [parent=#string] formatnumberthousands
-- @param number num 数值
-- @return string#string  格式化结果

--[[--

将数值格式化为包含千分位分隔符的字符串

~~~ lua

print(string.formatnumberthousands(1924235))
-- 输出 1,924,235

~~~

]]

-- end --

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- 字符串连接
function string.join(join_table, joiner)
    if #join_table == 0 then
        return ""
    end
    local fmt = "%s"
    for i = 2, #join_table do
        fmt = fmt .. joiner .. "%s"
    end
    return string.format(fmt, unpack(join_table))
end

-- 拆成单个文字
function string.cutText(text)
    text = text or ""
    local len  = string.len(text)
    local left = 1
    local t_word = {}
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left <= len do
        local tmp = string.byte(text, left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left + i
                break
            end
            i = i - 1
        end
        local char = string.sub(text, left - i, left - 1)
        table.insert(t_word, char)
    end
    return t_word
end

function string.cutTextForString(text)
    local t_word = string.cutText(text)
    return table.concat(t_word,"\n")
end

-- 判断字符串是否为纯数字字符串
function string.judgeNumString(str)
    if string.match(str, "%d+") == str then
        return true
    elseif string.match(str, "^%-%d+$") == str then
        return true
    end
    return false
end

--获取一个字节中，从最高位开始连续的1的个数
function string.get_continuous_1_count_of_byte(num)
    if nil == num then
        return -1
    end

    local count = 0
    while (num & 0x80 ~= 0) do
        count = count + 1
        num = num << 1
    end
    return count
end

-- 过滤特殊字符
-- return (返回过滤后的str), 是否和原str相同
function string.filterInvalidChars(raw_string)
    if nil == raw_string or string.len(raw_string) == 0 then
        return raw_string, true 
    end
    local new_string = {}
    local index_of_raw_string = 1
    while index_of_raw_string <= string.len(raw_string) do
        local count_1_of_byte = string.get_continuous_1_count_of_byte(string.byte(raw_string, index_of_raw_string))

        if count_1_of_byte < 0 then
            return raw_string, true
        end

        if 0 == count_1_of_byte then
            count_1_of_byte = 1
        end
        if count_1_of_byte <= 3 and count_1_of_byte ~= 2 then
            for i = 0, count_1_of_byte - 1 do
                table.insert(new_string, string.char(string.byte(raw_string, index_of_raw_string + i)))
            end
        end

        index_of_raw_string = index_of_raw_string + count_1_of_byte
    end
    local newName = table.concat(new_string)
    return newName, (newName == raw_string)
    
    -- 上方会过滤的特殊的特殊字符，例如：😂😂😂
    --- 下边是另一种过滤方法，会把常规的特殊字符也过滤掉，例如：#￥……（.
    --local result = '';
    --local curIndex = 1;
    ---- 逐字检查, 符合要求则放入result
    --repeat
    --    local curByte = string.byte(str, curIndex)
    --    if curByte > 0 and curByte <= 127 then
    --        result = result..string.sub(str, curIndex, curIndex)
    --        curIndex = curIndex + 1
    --    elseif curByte >= 192 and curByte <= 223 then
    --        curIndex = curIndex + 2
    --    elseif curByte >= 224 and curByte <= 239 then
    --        -- 此处判断一些中文特殊字符
    --        local b1 = curByte
    --        local b2 = string.byte(str, curIndex + 1)
    --        local b3 = string.byte(str, curIndex + 2)
    --        local unic = (b1 % 0xe0) * 2 ^ 12 + (b2 % 0x80) * 2 ^ 6 + (b3 % 0x80)
    --        if unic >= 0x4e00 and unic <= 0x9FA5 then
    --            result = result..string.sub(str, curIndex, curIndex + 2)
    --        end
    --        curIndex = curIndex + 3
    --    elseif curByte >= 240 and curByte <= 247 then
    --        curIndex = curIndex + 4
    --    else
    --        return str, true
    --    end
    --until(curIndex >= #str);
    --local newName = string.gsub(result, '[\\\\/:*?\"<>|%s+ ]', '')
    --return newName, (str == newName);
end