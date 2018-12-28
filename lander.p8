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

function hmappair(hmap,x)
	last = hmap[1]
	for i=2,#hmap do
		p = hmap[i]
		if x < p.x then
			return last, p
		end
		last = p
	end
	-- will fail
end

function islanding(hmap, x)
	p0,p1=hmappair(hmap,x)
	return p0.landing
end

function heightmap(f,x)
	last, cur = hmappair(hmap,x)
	t = (x-last.x)/(cur.x-last.x)
	return last.y + t * (cur.y-last.y)
end

function genhmap(len,y0,vary)
	hmap = {}
	lpad=1+flr(rnd(len-1))
	for i=1,len+1 do
		landing = i==lpad
		p = {
			x=128 * (i-1) / len,
			y=y0,
			landing=landing
		}
		if not landing then
			-- do not slope on landing pad
			y0+=rnd(2*vary)-vary
			y0=mid(64,y0,127)
		end
		add(hmap,p)
	end
	return hmap
end

function _init()
	ship = {x=32,y=0,
									vx=0,vy=0,
									hthrust=0.1,
									vthrust=0.2,
									fuel=128,
									fuelcons=1,
									landed=false,
									state="idle"}
	hmap = genhmap(16,120,10)
	planet = {g=0.05,crashvel=1,hmap=hmap}
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
	if ship.x < 0
		or ship.x + 8 > 128 then
		ship.state="crashed"
		return
	end
	lx=ship.x+4
	if ship.y + 8 > heightmap(planet.hmap,lx) then -- 8 is sprite width
		if ship.vy < planet.crashvel
			and islanding(planet.hmap,lx) then
			ship.state="landed"
		else
			ship.state="crashed"
		end
	end
end

function _draw()
	cls()
	-- landscape and hud	
	line(0,0,ship.fuel,0,8) -- red
	last = planet.hmap[1]
	for p in all(planet.hmap) do
		c = 13 -- purple
		if (last.landing) c=10 -- yellow
		line(last.x,last.y,p.x,p.y,c)
		last = p
	end
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
