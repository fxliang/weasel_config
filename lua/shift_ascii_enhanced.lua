local function init(env)
  env.toogle_expired_ = 0
  env.shift_key_pressed_ = false
  env.XK_Shift_L, env.XK_Shift_R = 0xffe1, 0xffe2
  env.kRejected, env.kAccepted, env.kNoop = 0, 1, 2
end

local function processor(key, env)
	local context = env.engine.context
  local is_shift = key.keycode == env.XK_Shift_L or key.keycode == env.XK_Shift_R
  if is_shift then                                       -- shift key processing
    if key:release() then -- shift released
      if env.shift_key_pressed_ then
        env.shift_key_pressed_ = false
        if os.clock() < env.toogle_expired_ then
          local ascii_mode = context:get_option("ascii_mode")
          if key.keycode == env.XK_Shift_L then                       -- Shift_L
            if ascii_mode == true then context:set_option("ascii_mode", false) end
          elseif ascii_mode == false then                             -- Shift_R
            context:set_option("ascii_mode", true)
            context:clear()    -- modify this line if you want to commit code or something else
          end
        end
      end
    -- shift key is pressed down for the first time
    elseif not env.shift_key_pressed_ then
      env.shift_key_pressed_ = true
      env.toogle_expired_ = os.clock() + 0.3    -- shift hold threshold 0.3 sec
    end
    -- shift key always accepted, don't pass it to ascii_composer
    return env.kAccepted
  end
  -- not shift key, clear shift_key_pressed_ and ignore this key
  -- and pass it to next processor
  env.shift_key_pressed_ = false
  return env.kNoop
end

return {init = init, func = processor}
