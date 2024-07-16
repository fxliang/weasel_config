local script_cpath = rime_api.get_user_data_dir() .. '/lua/?.dll'
package.cpath = package.cpath .. ';' .. script_cpath
-------------------------------------------------------------------------------
local clip = require("clip")
local function ClipBoard_Translator(input, seg)
	if (input == "/zt") then
    local txt = clip.get()
    if txt and utf8.len(txt) > 0 then
      yield(Candidate("clipboard", seg.start, seg._end, txt, "剪贴板"))
    end
  end
end

return { func =  ClipBoard_Translator }
