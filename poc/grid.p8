pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

local es={}
local p=nil
local msg=""
local dbg={{a=true,b=false},{a=nil,b=true}}

function _init()
 p=new_e(1,1,0.77)
 add(es, new_e(10,1,0.57))
end

function _update()
  add(dbg, {a=nil,b=nil}, 1)
  if #dbg >= 15 then
   deli(dbg,15)
  end
 p.cx=0
 p.cy=0
 if btn(⬅️) then p.cx=-1 end
 if btn(➡️) then p.cx=1 end
 if btn(⬆️) then p.cy=-1 end
	if btn(⬇️) then p.cy=1 end

	update_e(p)
 for e in all(es) do
		ai(e)
		update_e(e)
		e.cx=0
		e.cy=0
	end
end

function ai(e)
 e.cx=flr(rnd(3)-1)
 e.cy=flr(rnd(3)-1)
 if e.cx!=0 and e.cy!=0 then
 //	e.cx=0
 end
end

function ok_move(x,y)
  return mget(x,y)==0
end

function _draw()
 cls()
 map(0,0)
 for e in all(es) do
  draw_e(e)
 end
 draw_e(p)
 if #es>0 and p.tx==es[1].tx then
 	rect(p.tx*8,p.ty*8,p.tx*8+8,p.ty*8+8,10)
 end
 msg=(p.dx==0and"0"or"1")..":"..p.dy..":"..p.cx..":"..p.cy
 print(msg,1,1,1)
 draw_dbg(p)
end

function draw_dbg(p)
  local x=p.tx*8+p.xo
  local y=p.ty*8+p.yo
  for i=1,#dbg do
    local d=dbg[i]
    local j=0
    for k,v in pairs(d) do
      if v~=nil then
        rect(x+j,y-i,x+j,y-i,v and 10 or 3)
      end
      j+=1
    end
  end
end
-->8
-- entity

function new_e(tx,ty,spd)
	local e={}
	e.tx=tx
	e.ty=ty
	e.xo=0
	e.yo=0
	e.dx=0
	e.dy=0
  e.dxo=0
  e.dyo=0
	e.cx=0
	e.cy=0

	e.spd=spd
	e.fr=1
	return e
end

function draw_e(e)
 //rect(e.tx*8,e.ty*8,e.tx*8+7,e.ty*8+7,2)
	spr(e.fr,e.tx*8+e.xo,e.ty*8+e.yo)
end

function update_e(e)
  local can_steer=e.dx==0 and e.dy==0
  local want_steer=e.cx!=0 or e.cy!=0
<<<<<<< HEAD
 if e==p then dbg[1].a=can_steer end

 if can_steer then
  if not want_steer then
   e.xo=0
   e.yo=0
=======
  if e==p then dbg[1].a=can_steer end

  -- todo: when change directions, should xo=0/yo=0

 if can_steer then
  if not want_steer then
   --e.xo=0
   --e.yo=0
>>>>>>> mo change
  else
    local want_both=e.cx!=0 and e.cy!=0
   if want_both then
    -- who wins?
<<<<<<< HEAD
    if e.dxo!=0 then
=======
     if e.dxo!=0 then
       if ok_move(e.tx,e.ty+sgn(e.cy)) then
                    e.cx=0
       end
>>>>>>> mo change
      -- was going horiz...
      -- can it now go down?
      -- if so, stop horiz.
      -- otherwise... keep trucking.
    end
    if e.dyo!=0 then
<<<<<<< HEAD
       -- was going vert
=======
      -- was going vert
      if ok_move(e.tx+sgn(e.cy),e.ty) then
        e.cy=0
      end
>>>>>>> mo change
    end
    --e.cy=0
   end
   local xo=0
   local yo=0

   -- check horizontal
<<<<<<< HEAD
   if mget(e.tx+e.cx,e.ty)==0 then
    xo=e.cx
   end
   -- check vertical
   if mget(e.tx+xo,e.ty+e.cy)==0 then
=======
   if ok_move(e.tx+e.cx,e.ty) then
    xo=e.cx
   end
   -- check vertical
   if ok_move(e.tx+xo,e.ty+e.cy) then
>>>>>>> mo change
    yo=e.cy
   end
   -- can move?
   local can_move=not (xo==0 and yo==0)
   if e==p then dbg[1].b=can_move end
   if not can_move then
<<<<<<< HEAD
=======
     -- stop requests for move
>>>>>>> mo change
    e.cx=0
    e.cy=0
    e.xo=0
    e.yo=0
   end

   e.dx=e.spd*xo
   e.dy=e.spd*yo

  end
	end

 -- move x
 if e.dx!=0 then
   e.xo+=e.dx
   e.yo=0
   if abs(e.xo)>=8 then
     e.tx+=1*sgn(e.dx)
     e.xo+=-8*sgn(e.dx)
     e.dxo=e.dx
     e.dx=0
     -- fix "bounce" pixel
     if not ok_move(e.tx+sgn(e.xo), e.ty) then
       e.xo=0
     end

   end

 end
 -- move y
 if e.dy!=0 then
   e.yo+=e.dy
   e.xo=0
   if abs(e.yo)>=8 then
     e.ty+=1*sgn(e.dy)
     e.yo+=-8*sgn(e.dy)
     e.dyo=e.dy
     e.dy=0
     -- fix "bounce" pixel
     if not ok_move(e.tx, e.ty+sgn(e.yo)) then
       e.yo=0
     end
   end
 end

end


__gfx__
00000000000000002222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000656004444244400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000555004444244400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000565002222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000055555552444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700055555552444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555504222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000505004442444200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020202020202000202020202000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000002000000000000020000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020002000202020200020002000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020002000000000000000002000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000002020202000202020202000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
