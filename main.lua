local inputs = { throttle = 0, yaw = 0, pitch = 0, roll = 0 }

local function init()
end

local function run(event, touchState)
  inputs.throttle = (tonumber(getValue('thr')) + 1024) / 2048
  inputs.yaw = tonumber(getValue('rud')) / 1024
  inputs.pitch = tonumber(getValue('ele')) / 1024
  inputs.roll = tonumber(getValue('ail')) / 1024

  lcd.clear()

  lcd.drawText(0, 00, inputs.throttle)
  lcd.drawText(0, 10, inputs.yaw)
  lcd.drawText(0, 20, inputs.pitch)
  lcd.drawText(0, 30, inputs.roll)

  return 0
end

return { run=run, init=init }