local script_cpath = rime_api.get_user_data_dir() .. '/lua/?.dll'
package.cpath = package.cpath .. ';' .. script_cpath
-------------------------------------------------------------------------------
local clip = require("clip")
local clipdata = {}

local function insert_and_trim(tbl, value)
  table.insert(tbl, 1, value)
  if #tbl > 20 then table.remove(tbl) end
end

local function ClipBoard_Translator(input, seg, env)
    if (input == "/zt") then
    local segment = env.engine.context.composition:back()
    segment.prompt = "~剪贴板数据"
    local txt = clip.get()
    if utf8.len(txt) > 0 and (#clipdata > 0 and txt ~= clipdata[1].text) or #clipdata == 0 then
      local cand = Candidate("clipboard", seg.start, seg._end, txt, "")
      insert_and_trim(clipdata, cand)
    end
    if #clipdata > 0 then
      for _, v in ipairs(clipdata) do yield(v) end
    end
  end
end

return { func =  ClipBoard_Translator }
