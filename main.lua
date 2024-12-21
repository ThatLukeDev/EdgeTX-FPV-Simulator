local inputs = { throttle = 0, yaw = 0, pitch = 0, roll = 0 }

local function init()
end

local function drawBig(x, y, v)
  local points = { {X=0,Y=0},{X=0,Y=0},{X=0,Y=0},{X=0,Y=0},{X=0,Y=0} }
  local addedpoints = 0

  for i = 1, math.floor(v * 4) do
    local point = nil
    local inpoints = true

    local retries = 100

    math.randomseed((x * 56453432 + y * 13264534) % 13532 + 5364532)
    while inpoints and retries > 0 do
      inpoints = false
      point = { X = x * 2 + math.random(0, 1), Y = y * 2 + math.random(0, 1) }

      for i = 1, addedpoints do
        local v = points[i]
        if v.X == point.X and v.Y == point.Y then
          inpoints = true
        end
      end

      if not inpoints then
        lcd.drawPoint(point.X, point.Y)
        addedpoints = addedpoints + 1
        points[addedpoints].X = point.X
        points[addedpoints].Y = point.Y
      end

      retries = retries - 1
    end
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

  for x = 4, LCD_W / 2 - 1 do
    for y = 0, LCD_H / 2 - 1 do
      drawBig(x, y, x / LCD_W * 2.5)
    end
  end

  lcd.drawText(0, 00, inputs.throttle)
  lcd.drawText(0, 10, inputs.yaw)
  lcd.drawText(0, 20, inputs.pitch)
  lcd.drawText(0, 30, inputs.roll)

  return 0
end

return { run=run, init=init }