local function single_char_first_filter(input)
  local l = {}
  for cand in input:iter() do
    if (utf8.len(cand.text) == 1) then
      yield(cand)
    else
      table.insert(l, cand)
    end
  end
  for i, cand in ipairs(l) do
    yield(cand)
  end
end

local function Unicode_Tips()
  return "U\\x+\\X+\\x+ ...\tUnicode\r/uc\\x+\\X+\\x+ ...\tUnicode"
end

local function Daxie_Tips()
  return "/dx\\d+(.\\d\\d)?\t大写金额"
end

local function Date_Tips()
  local res = "/date\t日期\r"
  res = res .. "/time\t时间\r"
  res = res .. "/[1-7]x\t下周x\r"
  res = res .. "/[1-7]s\t上周x\r"
  res = res .. "/[1-7]z\t这周x\r"
  res = res .. "/\\d+h\tx天后\r"
  res = res .. "/\\d+q\tx天前\r"
  res = res .. "/20220906\t2022年9月6日的日期\r"
  res = res .. "/20220906n\t二零二二年九月初六的反查\r"
  res = res .. "/20200406nr\t二零二零年闰四月初六的反查\r"
  res = res .. "/20220909g\t2022年9月9日到今天的间隔\r"
  res = res .. "/20220906h\\d+[^0-9]\t2022年9月6日后x天\r"
  res = res .. "/20220906q\\d+[^0-9]\t2022年9月6日前x天"
  return res
end

local emoji_tips = require("emoji").emoji_tips()
-- global lua help tips
local function Lua_Tips(input,seg, env)
  if input:match("^/$") then 
    local segment = env.engine.context.composition:back()
    segment.prompt = "~? [获得输入帮助]"
    return
  end
  if input:match("^/%?$") then
    local segment = env.engine.context.composition:back()
    segment.prompt = "Lua快捷输入帮助"
    local daxie_tips = Daxie_Tips()
    local unicode_tips = Unicode_Tips()
    local date_tips = Date_Tips()
    yield(Candidate("tips", seg._start, seg._end, emoji_tips, ""))
    yield(Candidate("tips", seg._start, seg._end, date_tips, ""))
    yield(Candidate("tips", seg._start, seg._end, unicode_tips, ""))
    yield(Candidate("tips", seg._start, seg._end, daxie_tips, ""))
  end
end
-- 在词典里面候选支持\r, \r\n, \n, <br>分割分行
-- &nbsp 表示空格
-- 方案patch中要添加以下两行
--  engine/filters/+:
--  - lua_filter@Multiline_filter
local function Multiline_filter(input)
  for cand in input:iter() do
    local nt = cand.text
    if nt:match("\\r\\n") or nt:match("\\r") or nt:match("\\n") or nt:match("<br>") or nt:match("&nbsp") then
      nt = nt:gsub("&nbsp", " ")
      nt = nt:gsub("\\r\\n", "\r")
      nt = nt:gsub("\\r", "\r")
      nt = nt:gsub("\\n", "\r")
      nt = nt:gsub("<br>", "\r")
      local cnd = Candidate("", cand.start, cand._end, nt, cand.comment)
      yield(cnd)
    else
      yield(cand)
    end
  end
end

local function Tip_Filter(input, env, cands)
  for cand in input:iter() do
    if cand.type:match("^tip") then
      cand.comment = cand.text
      cand.text = ""
    end
    yield(cand)
  end
end

local function disable_soft_cursor(key, env)
  local engine = env.engine
  local context = engine.context
  local soft_cursor = context:get_option("soft_cursor")
  if soft_cursor == nil or soft_cursor == true then
    context:set_option("soft_cursor", false)
  end
  return 2
end

return {Multiline_filter = Multiline_filter,
Tip_Filter = Tip_Filter,
Lua_Tips = Lua_Tips,
Disable_Soft_Cursor = disable_soft_cursor,
}
