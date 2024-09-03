local function init(env)
	local engine = env.engine
	local context = engine.context
  --if context:get_option("soft_cursor") then
    log.info("setting")
    context:set_option("soft_cursor", false)
  --end
end
local function func(env)
  return 2
end


return {init = init, func = func}
