local inputs = { throttle = 0, yaw = 0, pitch = 0, roll = 0 }

local function init()
end

local function drawBig(x, y, v)
  for i = 1, math.floor(v * 4) do
    lcd.drawPoint(x * 2 + math.fmod(i, 2), y * 2 + math.floor(i / 2))
  end
end

local function run(event, touchState)
  inputs.throttle = (tonumber(getValue('thr')) + 1024) / 2048
  inputs.yaw = tonumber(getValue('rud')) / 1024
  inputs.pitch = tonumber(getValue('ele')) / 1024
  inputs.roll = tonumber(getValue('ail')) / 1024

  lcd.clear()
  for x = 0, LCD_W - 1 do
    for y = 0, LCD_H - 1 do
      lcd.drawPoint(x, y)
    end
  end

  lcd.drawText(0, 00, inputs.throttle)
  lcd.drawText(0, 10, inputs.yaw)
  lcd.drawText(0, 20, inputs.pitch)
  lcd.drawText(0, 30, inputs.roll)

  for x = 4, LCD_W / 2 - 1 do
    for y = 0, LCD_H / 2 - 1 do
      drawBig(x, y, x / LCD_W * 4)
    end
  end

  return 0
end

return { run=run, init=init }