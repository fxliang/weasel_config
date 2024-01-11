
local function ClipBoard_Translator(input, seg)
	if (input == "/zt") then
        local txt = WinClipboard.get_last_clipboard_text()
        if txt and utf8.len(txt) > 0 then
            yield(Candidate("clipboard", seg.start, seg._end, txt, "剪贴板"))
        end
    end
end

return { func =  ClipBoard_Translator }
