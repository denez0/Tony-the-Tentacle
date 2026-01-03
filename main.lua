-- the game is about a robopocalypse where robots behave strangely!
hasCompletedTutorial = false
creditsShown = false
song = love.audio.newSource('audio/song.ogg', 'stream')
song:setLooping(true)
song:play()
winsong = love.audio.newSource('audio/winsong.mp3', 'stream')

function love.load()
    -- libraries, images, entities, sounds
    Object = require "libraries/classic"
    require "moving"

    camera = require 'libraries/camera'
    cam = camera()
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 1000)
    world:addCollisionClass('Player')
    world:addCollisionClass('Tentacle', {ignores = {'Player'}})
    world:addCollisionClass('Enemy1', {ignores = {'Player', 'Tentacle'}})
    world:addCollisionClass('Enemy2')

    love.graphics.setDefaultFilter("nearest", "nearest")
    backgrounds = {}
    setTable('/images', 'forest', backgrounds)
    background = backgrounds[love.math.random(#backgrounds)]
    bgRatio = (h + 12.5)/ background:getHeight()
    mapW = background:getWidth() * bgRatio
    mapH = background:getHeight() * bgRatio
    ground = world:newRectangleCollider(0, 525, mapW, 5)
    ground:setType('static')

    robot1 = love.graphics.newImage('images/robot1.png')
    robot2 = love.graphics.newImage('images/robot2.png')
    enemies = {}
    enemy = {
        -- Optimus Subprime 0_o
        ratio = 0.125,
        speed = 4,
        lastSpawn = os.time(),
        delta = 2,
        GIF_change_time = 2,
        killed = 0
    }

    player = Moving(w/2, 400, 50, 120, 'Player', 5, 10)
    player.lastx = player.x
    player.moved = false -- uses tentacle
    player.tentacle = Moving(player.x, player.y + 3/8 * player.height, 100, 5, 'Tentacle', 9999)

    sfx = {}
    setTable('/audio', 'mixkit', sfx)

    if not hasCompletedTutorial then
        displayTutorial = true
        song:pause()
        enemy.delta = 200
    end

end


function love.update(dt)
    if not hasCompletedTutorial then
        if not creditsShown then
            if os.time() - enemy.lastSpawn > 4 then
                creditsShown = true
            else return 
            end
        elseif displayTutorial then
            if love.keyboard.isDown('y') then
                displayTutorial = false
            elseif love.keyboard.isDown('n') then
                displayTutorial = false
                enemy.delta = 2
                song:play()
                hasCompletedTutorial = true
            end
            return
        end
    end

    local px, py = player.collider:getLinearVelocity()
    local delta = player.x - player.lastx
    player.lastx = player.x

    --every ... secs new enemy
    if os.time() - enemy.lastSpawn > enemy.delta then
        createEnemy()
        enemy.lastSpawn = os.time()
        enemy.delta = love.math.random(2, 6)
    end

    if (love.keyboard.isDown('d') or love.keyboard.isDown('right')) and px < 300 then
        player.collider:applyForce(5000 * player.speed, 0)
    end
    if (love.keyboard.isDown('a') or love.keyboard.isDown('left')) and px > -300 then
        player.collider:applyForce(-5000 * player.speed, 0)
    end

    function love.keypressed(key)
        if (key == 'up' or key == 'w') and player.y > 450 then
            player.collider:applyLinearImpulse(0, -6000)
        end
        if key == 'down' or key == 's' then
            player.tentacle.collider:applyForce(player.tentacle.speed, 0)
            player.moved = true
        end
        if key == 'escape' then
            love.event.quit()
        end
        if key == 'q' and win() then
            love.event.quit('restart')
        end
        if key == 'p' then
            if song:isPlaying() then song:pause() else song:play() end
        end
    end
    
    -- map borders
    if player.collider:getX() < 0 then
        player.collider:setPosition(0, player.collider:getY())
    elseif player.collider:getX() > mapW then
        player.collider:setPosition(mapW, player.collider:getY())
    end

    -- tentacle go back and stop
    if (player.tentacle.x - player.x) + player.width * 0.5 > player.tentacle.width then
        player.tentacle.collider:applyForce(-player.tentacle.speed, 0)
    elseif (player.tentacle.x - player.x) - player.width * 0.5 < 0 then
        player.moved = false
        player.tentacle.collider:setLinearVelocity(0, 0)
    end

    world:update(dt)
    player:updCollider()
    -- set tentacle in the right position
    if not player.moved then
        player.tentacle.collider:setPosition(player.x + player.width * 0.5, player.y - player.height / 8)
    else
        player.tentacle.collider:setPosition(player.tentacle.collider:getX() + delta, player.y - player.height / 8)
    end
    player.tentacle:updCollider()

    cam:lookAt(player.x, player.y - 64)
    if cam.x < w/2 then
        cam.x = w/2
    end
    if cam.y < h/2 then
        cam.y = h/2
    end
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end
    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end

    for i,v in ipairs(enemies) do
        -- move towards player
        local dist = v.x - player.x
        if math.abs(dist) < w then
            if dist > player.width then
                v.collider:setPosition(v.collider:getX() - enemy.speed, v.collider:getY())
            elseif dist < player.width then
                 v.collider:setPosition(v.collider:getX() + enemy.speed, v.collider:getY())
            end
        end
        v:updCollider()

        -- if an enemy outside/killed (by) you
        if player.tentacle.collider:enter('Enemy2') then
            local collision_data = player.tentacle.collider:getEnterCollisionData('Enemy2')
            local robot = collision_data.collider:getObject()
            if index(robot) then
                enemies[index(robot)].killed = true
                sfx[love.math.random(#sfx)]:play()
            end
        elseif player.collider:enter('Enemy2') then
                love.run()
                print('You died')
        end
        
        if (v.x + v.width < 0 or v.x > mapW) or v.killed  then
            v.collider:destroy()
            table.remove(enemies, i)
            if v.killed then
                print('-Enemy')
                enemy.killed = enemy.killed + 1
            end
        end

        -- animate
        if os.time() - v.lastChange > enemy.GIF_change_time then
            if v.image == robot2 then
                v.image = robot1
                v.collider:setCollisionClass('Enemy1')
            elseif not win() then v.image = robot2
                v.collider:setCollisionClass('Enemy2')
            end
            v.lastChange = os.time()
        end
        if v.y > 500 then
            v.collider:applyLinearImpulse(0, -1250)
        end
    end
end


function love.draw()
    if not hasCompletedTutorial then
        if not creditsShown then
            love.graphics.print('Tony the Tentacle', 50, 10, 0, 6)
            love.graphics.print('by Denis Yakovliev', 10, 130, 0, 4)
            love.graphics.print('Pictures by upklyak, Freepik', 10, 270, 0, 4)
            love.graphics.print('Audio by Bill Wurtz + mixkit', 10, 410, 0, 4)
            love.graphics.print('\'I just did a bad thing\'', 10, 490, 0, 4)
        elseif displayTutorial then
            love.graphics.print('Do you need instructions?', 10, 40, 0, 4)
            love.graphics.print('Press Y/N', 10, 160, 0, 4)
        else 
            love.graphics.print('Use arrows or WASD', 10, 40, 0, 4)
            love.graphics.print('\'P\' is to pause music', 10, 100, 0, 4)
            love.graphics.print('\'Esc\' is to exit', 10, 160, 0, 4)
            love.graphics.print('Press \'P\' to start', 10, 280, 0, 4)
            if love.keyboard.isDown('p') then
                displayTutorial = false
                enemy.delta = 2
                hasCompletedTutorial = true
            end
        end
        return
    end

    cam:attach()
        world:draw()
        love.graphics.draw(background, 0, 0, nil, bgRatio)
        player.tentacle:draw()
        player:draw()
        for i,v in ipairs(enemies) do v:draw(enemy.ratio) end
    cam:detach()
    love.graphics.print('Score: ' .. enemy.killed, 10, 10)
    if win() then 
        love.graphics.setColor(0,0,0)
        love.graphics.print('You won!', 160, 80, 0, 10)
        love.graphics.print('press \'q\' to restart', 160, 200, 0, 5) 
        love.graphics.setColor(1,1,1)
    end 
end


function createEnemy()
    if #enemies > 4 and not win() then return end
    local newEnemy = {}
    while true do
        local x = love.math.random(0, mapW)
        if math.abs(x - player.x) > 150 then
            newEnemy = Moving(x, 400, robot2:getWidth() * enemy.ratio, robot2:getHeight() * enemy.ratio, 'Enemy2', 0, 18)
            break
        end
    end

    newEnemy.image = robot2
    newEnemy.lastChange = os.time()
    newEnemy.killed = false
    table.insert(enemies, newEnemy)
end


function index(indexed)
    for i,v in ipairs(enemies) do
        if indexed == v then return i end
    end
end


function setTable(dir, substring, _table)
    files = love.filesystem.getDirectoryItems(dir)
    for i=1,#files do
        if string.sub(files[i],1,string.len(substring))==substring then
            if dir == '/audio' then
                table.insert(_table, love.audio.newSource(dir..'/'..files[i], 'static'))
            elseif dir == '/images' then
                table.insert(_table, love.graphics.newImage(dir..'/'..files[i]))
            end
        end
    end
end


function win()
    if enemy.killed > 9 then
        song:stop()
        winsong:play()
        --real optimus :D
        enemy.ratio = 0.5
        return true
    end
end
-- by Denis Yakovliev
-- Peace!