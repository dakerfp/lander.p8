pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- lander
-- version 0.1
-- author @dakerfp

ship={}
planet={}

function has(l,o)
	for e in all(l) do
		if (e == o) return true
	end
	return false
end

function _init()
	ship = {x=32,y=0,
									vx=0,vy=0,
									hthrust=0.2,
									vthrust=0.2,
									fuel=90,
									fuelcons=0.2,
									landed=false,
									state="idle"}
	planet = {floory=120,g=0.05,crashvel=1}
end

function _update()
	if has({"landed","crashed"},
		ship.state) then
		if btn(❎) then
			_init()
		end
		return
	end

	-- momentum update
	if btn(⬅️) and ship.fuel > 0 then
		ship.vx -= ship.hthrust
		ship.fuel -= ship.fuelcons
		ship.state = "thrust"
	else
		ship.state = "idle"
	end
	if btn(➡️) and ship.fuel > 0 then
		ship.vx += ship.hthrust
		ship.fuel -= ship.fuelcons
		ship.state = "thrust"
	else
		ship.state = "idle"
	end
	if btn(⬆️) and ship.fuel > 0 then
		ship.vy -= ship.vthrust
		ship.fuel -= ship.fuelcons
		ship.state = "thrust"
	else
		ship.state = "idle"
	end

	ship.vy += planet.g
	-- inertial update
	ship.x += ship.vx
	ship.y += ship.vy
	-- collision check
	if ship.y + 8 > planet.floory then -- 8 is sprite width
		if ship.vy > planet.crashvel then
			ship.state="crashed"
		else
			ship.state="landed"
		end
	end
end

function _draw()
	cls()
	-- landscape and hud	
	line(0,0,ship.fuel,0)
	line(0,planet.floory,128,planet.floory)
	-- ship
	if ship.state == "crashed" then
		print("game over", 48, 64)
		spr(0,ship.x,ship.y)
	else
		if ship.state == "landed" then
			print("landed!", 52, 64)
			spr(3,ship.x,ship.y-7)
		end
		spr(1,ship.x,ship.y)
		if ship.state == "thrust" then
			spr(2,ship.x,ship.y+7)
		end
	end
end

__gfx__
000000000000070000988900c7c78008000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000777700098888907c7c7887007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000070070000999900c7c78778007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007007000000000068887887007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070000700000000006778778070000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070080070770700000000006880880070770700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07667760077777700000000006000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
68867677770000770000000000600000770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
