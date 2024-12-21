local inputs = { throttle = 0, yaw = 0, pitch = 0, roll = 0 }

local camera = { X = 0, Y = 10, Z = 0, RX = 0, RY = 0, RZ = 0 }

local objs = {
  { X = 0, Y = -101, Z = 0, R = 100},
  { X = 0, Y = 10, Z = 20, R = 5}
}

local lights = { { X = 0, Y = 10, Z = 10, P = 100000000000} }

fovx = 0.5
fovy = 0.5

local function init()
end

local function drawBig(x, y, v)
  local points = { {X=0,Y=0},{X=0,Y=0},{X=0,Y=0},{X=0,Y=0},{X=0,Y=0} }
  local addedpoints = 0

  for i = 1, math.floor(v * 5) do
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

local function intersectsDisc(originX, originY, originZ, directionX, directionY, directionZ, x, y, z, r)
  local sminoX = originX - x
  local sminoY = originY - y
  local sminoZ = originZ - z

  local a = directionX * directionX + directionY * directionY + directionZ * directionZ
  local b = 2 * (directionX * sminoX + directionY * sminoY + directionZ * sminoZ)
  local c = sminoX * sminoX + sminoY * sminoY + sminoZ * sminoZ - r * r

  local discriminant = b * b - 4 * a * c

  if discriminant < 0 then
    return -1
  else
    return (-b - math.sqrt(discriminant)) / 2 * a
  end
end

local function clamp(val, low, high)
  if val > high then
    return high
  end

  if val < low then
    return low
  end

  return val
end

local function trace(originX, originY, originZ, directionX, directionY, directionZ)
  local foundObj = false
  local lowest = math.huge

  for i = 1, #objs do
    local distance = intersectsDisc(originX, originY, originZ, directionX, directionY, directionZ, objs[i].X, objs[i].Y, objs[i].Z, objs[i].R)

    if distance < lowest and distance > 0 then
      lowest = distance
      foundObj = true
    end
  end

  if foundObj then
    local posX = originX + directionX * lowest
    local posY = originY + directionY * lowest
    local posZ = originZ + directionZ * lowest

    local illumination = 0

    for i = 1, #lights do
      local dispX = (posX - lights[i].X)
      local dispY = (posY - lights[i].Y)
      local dispZ = (posZ - lights[i].Z)
      local distance = math.sqrt(dispX * dispX + dispY * dispY + dispZ * dispZ)

      illumination = illumination + lights[i].P / (distance * distance)
    end

    return illumination
  end

  return 0
end

local function rotateX(x, y, z, theta)
  local sin = math.sin(theta)
  local cos = math.cos(theta)

  return {
    X = x,
    Y = cos * y - sin * z,
    Z = sin * y + cos * z
  }
end

local function rotateY(x, y, z, theta)
  local sin = math.sin(theta)
  local cos = math.cos(theta)

  return {
    X = cos * x + sin * z,
    Y = y,
    Z = -sin * x + cos * z
  }
end

local function rotateZ(x, y, z, theta)
  local sin = math.sin(theta)
  local cos = math.cos(theta)

  return {
    X = cos * x - sin * y,
    Y = sin * x + cos * y,
    Z = z
  }
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

  camera.Y = inputs.throttle * 100

  local rotX = inputs.pitch
  local rotY = inputs.yaw
  local rotZ = -inputs.roll

  for x = 0, LCD_W / 2 - 1 do
    for y = 0, LCD_H / 2 - 1 do
      local baseDirectionX = (x - LCD_W / 4) * fovx
      local baseDirectionY = (LCD_H / 4 - y) * fovy
      local baseDirectionZ = 10

      local direction = rotateX(baseDirectionX, baseDirectionY, baseDirectionZ, rotX)
      direction = rotateY(direction.X, direction.Y, direction.Z, rotY)
      direction = rotateZ(direction.X, direction.Y, direction.Z, rotZ)

      local val = trace(camera.X, camera.Y, camera.Z, direction.X, direction.Y, direction.Z)

      drawBig(x, y, clamp(val, 0, 1))
    end
  end

  return 0
end

return { run=run, init=init }