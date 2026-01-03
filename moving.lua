Moving = Object:extend()

function Moving:new(x, y, width, height, type, speed, BSG)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    if speed then
        self.speed = speed
    end
    self.collider = world:newBSGRectangleCollider(x, y, width, height, BSG or 0)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass(type)
    self.collider:setObject(self)
end

function Moving:updCollider()
    self.x = self.collider:getX()
    self.y = self.collider:getY()
end

-- for rectangles only (currently)
function Moving:draw(ratio)
    if ratio then
        love.graphics.draw(self.image, self.x - self.width * 0.5, self.y - self.height * 0.5, nil, ratio)
    else
        -- change color for fun (0~0)
        -- love.graphics.setColor(1,1,0)
        love.graphics.rectangle("fill", self.x - self.width * 0.5, self.y - self.height * 0.5, self.width, self.height)
        -- love.graphics.setColor(1,0,1)
    end
end
