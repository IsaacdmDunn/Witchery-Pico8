pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--witchery
--by isaac dunn

function _init()
	player_init()
	init_inv()
	init_ent()
	init_bat()
	init_slime()
	init_target()
	init_moth()
	init_summoner()
	init_sorceress()
	init_enemy_bullet()
	--init_plant()
	frame_count=0
	mx=0
	my=0
	cx=0
	cy=0
	lx=0
	ly=0
	boss_id=1
	area_music=5
	music(area_music)
	
	--5==overworld music
	--0==dungeon music
	--2==boss_music
	--7==final_boss
end

function _update()
	if inv_open==false and pl.alive==true then
		player_move()
		update_mag()
		hurt_player()
		update_target()
		update_ent()
		
		update_bat()
		update_slime()
		update_target()
		update_moth()
		update_summoner()
		update_sorceress()
		update_enemy_bullet()
	else
		use_potion()
	end
	
	update_inv()
	open_inv()
	
end

function _draw()
	cls(0)
	move_camera()
	
	map(mx,my)
	
	if(frame_count==30) then
		frame_count=1
	end
	
	player_draw()
	draw_bat()
	draw_slime()
	draw_mag()
	draw_hearts()
	draw_target()
	draw_moth()
	draw_summoner()
	draw_sorceress()
	draw_enemy_bullet()
	--draw_plant()
	
	frame_count+=1
	if pl.alive==false then
		despawn_entities()
		print("game over",cx*8+48,cy*8+16)
		print("ctrl+r to restart",cx*8+32,cy*8+48)
	end
	draw_inv()
	print(boss_id,pl.x,pl.y)
end

function move_camera()
	if inv_open==true then
		camera(112*8,0)
	elseif inv_open==false then
		if pl.x/8>cx+16 then
			cx+=16
			spawn_entities(cx,cy)
		elseif pl.x/8<cx then
			cx-=16
			spawn_entities(cx,cy)
		elseif pl.y/8>cy+16 then
			cy+=16
			spawn_entities(cx,cy)
		elseif pl.y/8<cy then
			cy-=16
			spawn_entities(cx,cy)
		end
		camera(cx*8,cy*8)
	end
end

function spawn_entities(x,y)
	despawn_entities()
	if x==0 and y==0 then
		create_switch(8,1,1,0)
	elseif x==0 and y==16 then
		create_slime(8,8)
		create_ent(8,30*8,1)
		area_music=5
	elseif x==16 and y==16 then
		create_bat(26,28)
		create_bat(26,22)
		create_ent(30*8,30*8,15)
		area_music=5
	elseif x==16 and y==0 then
		create_bat(28,4)
		create_bat(28,12)
		create_slime(20,4)
		create_ent(30*8,1*8,16)
		area_music=5
	elseif x==32 and y==0 then
		create_slime(44,3)
		create_slime(44,13)
		create_bat(35,13)
		create_switch(33,14,2,0)
		create_ent(33*8,1*8,2)
		create_ent(46*8,1*8,3)
		create_ent(35*8,5*8,6)
		area_music=0
	elseif x==48 and y==0 then
		create_ent(49*8,1*8,4)
		create_ent(62*8,1*8,5)
		create_ent(58*8,6*8,7)
		create_switch(61,14,3,0)
		create_bat(58,1)
		create_bat(58,4)
		create_bat(61,13)
		create_slime(55,13)
		area_music=0
	elseif x==64 and y==0 then
		area_music=0	
		mset(77,14,98)
		if boss_id==1 then
			create_moth(72,3)
			create_ent(78*8,14*8,8)
			mset(77,14,72)
			--area_music=7
		elseif boss_id==2 then
			create_summoner(72,3)
			create_ent(78*8,14*8,9)
			mset(77,14,72)
			area_music=7
		elseif boss_id==3 then	
			create_sorceress(72,3)
			create_ent(78*8,14*8,21)
			mset(77,14,72)
			area_music=7
		end
		
	elseif x==80 and y==0 then
		create_ent(81*8,1*8,9)
		create_ent(81*8,3*8,10)
		create_ent(94*8,1*8,11)
		create_ent(94*8,11*8,12)
		create_slime(84,13)
		create_slime(84,11)
		create_red_slime(84,7)
		create_red_slime(93,7)
		create_bat(93,1)
		create_switch(108,1,4,0)
		create_switch(110,14,5,0)
		area_music=7
	elseif x==96 and y==0 then
		create_ent(97*8,1*8,13)
		create_ent(97*8,11*8,14)
		create_red_slime(109,12)
		create_red_slime(99,12)
		create_slime(109,7)
		create_slime(99,7)
		create_bat(99,14)
		create_bat(109,14)
		create_switch(108,1,4,0)
		create_switch(110,14,5,0)
		area_music=0
	elseif x==48 and y==16 then
		create_ent(49*8,17*8,17)
		create_ent(59*8,30*8,20)
		area_music=0
	elseif x==64 and y==16 then
		area_music=0
	elseif x==80 and y==16 then
		create_ent(94*8,17*8,18)
		create_ent(94*8,20*8,19)
		area_music=0
	end
end

function despawn_entities()
	despawn_bats()
	despawn_slimes()
	despawn_switches()
	despawn_moth()
	despawn_summoner()
	
	music(area_music)
end



-->8
--player
function player_move()
	pl.ox=pl.x
	pl.oy=pl.y
	isrun=false
		if btn(0) then
			pl.x-=2
			playerdir=0
			isright=false
			isrun=true
		elseif btn(1) then
			pl.x+=2
			playerdir=1
			isright=true
			isrun=true
		end
		if btn(2) then
			pl.y-=2
			playerdir=2
			isrun=true
		elseif btn(3) then
			pl.y+=2
			playerdir=3
			isrun=true
		end
	if map_collide(pl.x,pl.y,
	pl.w,pl.h,0) or map_collide(pl.x,pl.y,
	pl.w,pl.h,3) then
	pl.x=pl.ox
	pl.y=pl.oy
	end
end

function player_init()
	pl={}
	pl.x=60
	pl.y=60
	pl.w=7
	pl.h=7
	pl.ox=0
	pl.oy=0
	pl.alive=true
	pl.lives=2
	pl.maxlives=7
	
	isright=false
	playerdir=0
	isrun=false
	mag_fire=false
	last=0
	ishurt=false
end

function player_draw()
	if(frame_count%4==0 and isrun) then
		spr(1,pl.x,pl.y,1,1,isright)
	elseif(frame_count%4==1 and isrun) then
		spr(2,pl.x,pl.y+1,1,1,isright)
	else
		spr(1,pl.x,pl.y,1,1,isright)
	end
end

function update_mag()
	if btnp(4) and mag_fire == false then
		sfx(0)
		lx=pl.x
		ly=pl.y
		mag_fire=true
	end
	if	map_collide(lx,ly,
	pl.w,pl.h,0)==false then
		if playerdir==0 and mag_fire==true then
			lx-=3
		elseif playerdir==1 and mag_fire==true then
			lx+=3
		elseif playerdir==2 and mag_fire==true then
			ly-=3
		elseif playerdir==3 and mag_fire==true then
			ly+=3
		end
	else
		sfx(3)
		ly=512
		lx=512
		mag_fire=false
	end
end

function draw_mag()
	if mag_fire==true then
		if playerdir==0 or playerdir==1 then
			spr(7,lx,ly,1,1)
		elseif playerdir==2 or playerdir==3 then
		 spr(6,lx,ly,1,1)
		end
	end
end

function hurt_player()
	
		for s in all(slime) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,s.x,s.y,s.w,s.h,2)==true then
				
				check_enemy_collision()
				end
		end
		for s in all(red_slime) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,s.x,s.y,s.w,s.h,2)==true then
				
				check_enemy_collision()
				end
		end
		for s in all(green_slime) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,s.x,s.y,s.w,s.h,2)==true then
				
				check_enemy_collision()
				end
		end
		for b in all(bat) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,b.x,b.y,b.w,b.h,2)==true then
				check_enemy_collision()
				end
		end
		for b in all(red_bat) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,b.x,b.y,b.w,b.h,2)==true then
				check_enemy_collision()
				end
		end
		for b in all(brown_bat) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,b.x,b.y,b.w,b.h,2)==true then
				check_enemy_collision()
			end
		end
		for m in all(moth) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,m.x,m.y,m.w,m.h,2)==true then
				check_enemy_collision()
			end
		end
		for m in all(enemy_bullet) do
			if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,m.x,m.y,m.w,m.h,2)==true then
				check_enemy_collision()
			end
		end
end

function draw_hearts()
	for n=0,pl.lives do 
		n+=1
		spr(55,(cx*8)+(n*10),(cy*8),1,1)
	end
end

function check_enemy_collision()
	if (time() - last) > 1 then
		pl.lives-=1
		sfx(2)
		print("time's up!", 16, 16, 7)
		last=0
		ishurt=false
	elseif pl.lives<0 then
		--cx=112*8
		--cy=48*8
		--pl.x=cx+64
		--pl.y=cy+64
		pl.alive=false
		sfx(1)
		music(-1)
	end
	if ishurt == false then
		last=time()
		ishurt=true
	end
end


-->8
--collisions
function map_collide(x,y,
																				w,h,flag)																
	s1=mget(x/8,y/8)
	s2=mget((x+w)/8,y/8)
	s3=mget(x/8,(y+h)/8)
	s3=mget((x+w)/8,(y+h)/8)
	
	if fget(s1,flag) then
		return true
	elseif fget(s2,flag) then
		return true
	elseif fget(s3,flag) then
		return true
	elseif fget(s4,flag) then
		return true
	else
		return false
	end
end

function spr_collide(x1,y1,
w1,h1,x2,y2,w2,h2,flag)
	if x1<x2+w2 and	x1+w1>x2 and
				y1<y2+h2 and y1+h1>y2 then
		return true
	else
		return false
	end
end

function ai_collide(x1,y1,x2,y2,ai)
	if x1 > (x2-ai) and
	x1 < (x2+ai) and
	y1 > (y2-ai) and
	y1 < (y2+ai) then
		return true
	else
		return false
	end
end
-->8
--enemies
function init_slime()
	slime={}
	red_slime={}
	green_slime={}
end

function update_slime()
	for s in all(red_slime) do
		if ai_collide(pl.x,pl.y,
		s.x,s.y,s.airange)==true then
			s.x,s.y = move_slime(s.x,s.y,0.5)
		end
		kill_slime()
	end
	for s in all(green_slime) do
		if ai_collide(pl.x,pl.y,
		s.x,s.y,s.airange)==true then
			s.x,s.y = move_slime(s.x,s.y,1.5)
		end
		kill_slime()
	end
	for s in all(slime) do
		if ai_collide(pl.x,pl.y,
		s.x,s.y,s.airange)==true then
			s.x,s.y = move_slime(s.x,s.y,1)
		end
		kill_slime()
	end
end

function draw_slime()
	for s in all(slime) do
		if(frame_count>25) then
			spr(9,s.x,s.y,1,1)
		else
			spr(8,s.x,s.y,1,1)
		end
	end
	for s in all(red_slime) do
		if(frame_count>25) then
			spr(25,s.x,s.y,1,1)
		else
			spr(24,s.x,s.y,1,1)
		end
	end
	for s in all(green_slime) do
		if(frame_count>25) then
			spr(41,s.x,s.y,1,1)
		else
			spr(40,s.x,s.y,1,1)
		end
	end
end

function move_slime(x,y,speed)
	if frame_count > 25 then
		if x<pl.x then
			x+=4*speed
		elseif x>pl.x then
			x-=4*speed
		end
		if y<pl.y then
			y+=4*speed
		elseif y>pl.y then
			y-=4*speed
		end
	end
	return x,y
end

function kill_slime()
	for s in all(slime) do
		if	spr_collide(s.x,s.y,
		s.w,s.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			s.lives-=1
			if	s.lives<0 then
				del(slime, s)
			end
		end
	end
	for s in all(green_slime) do
		if	spr_collide(s.x,s.y,
		s.w,s.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			s.lives-=1
			if	s.lives<0 then
				del(green_slime, s)
			end
		end
	end
	for s in all(red_slime) do
		if	spr_collide(s.x,s.y,
		s.w,s.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			s.lives-=1
			if	s.lives<0 then
				del(red_slime, s)
			end
		end
	end
end

function create_slime(spawnx,spawny)
	add(slime,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=64,lives=2})
end
function create_red_slime(spawnx,spawny)
	add(red_slime,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=64,lives=8})
end
function create_green_slime(spawnx,spawny)
	add(green_slime,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=128,lives=5})
end

function despawn_slimes()
	for s in all(slime) do
		del(slime, s)
	end
	for s in all(red_slime) do
		del(red_slime, s)
	end
	for s in all(green_slime) do
		del(green_slime, s)
	end
end

//bats
function init_bat()
	bat={}
	red_bat={}
	brown_bat={}
end

function update_bat()
	for s in all(bat) do
		if ai_collide(pl.x,pl.y,
		s.x,s.y,s.airange)==true then
			s.x,s.y = move_bat(s.x,s.y,1)
		end
		kill_bat()
	end
	for s in all(red_bat) do
		if ai_collide(pl.x,pl.y,
		s.x,s.y,s.airange)==true then
			s.x,s.y = move_bat(s.x,s.y,3)
		end
		kill_bat()
	end
	for s in all(brown_bat) do
		if ai_collide(pl.x,pl.y,
		s.x,s.y,s.airange)==true then
			s.x,s.y = move_bat(s.x,s.y,1)
		end
		kill_bat()
	end
end

function draw_bat()
	for s in all(bat) do
		if(frame_count>15) then
			spr(12,s.x,s.y,1,1)
		else
			spr(13,s.x,s.y,1,1)
		end
	end
	for s in all(red_bat) do
		if(frame_count>15) then
			spr(28,s.x,s.y,1,1)
		else
			spr(29,s.x,s.y,1,1)
		end
	end
	for s in all(brown_bat) do
		if(frame_count>15) then
			spr(44,s.x,s.y,1,1)
		else
			spr(45,s.x,s.y,1,1)
		end
	end
end

function move_bat(x,y,speed)
	if x<pl.x  then
		x+=0.5*speed
	elseif x>pl.x then
		x-=0.5*speed
	end
	if y<pl.y then
		y+=0.5*speed
	elseif y>pl.y then
		y-=0.5*speed
	end
	return x,y
end

function kill_bat()
	for s in all(bat) do
		if	spr_collide(s.x,s.y,
		s.w,s.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			s.lives-=1
			if	s.lives<0 then
				del(bat, s)
			end
		end
	end
	for s in all(red_bat) do
		if	spr_collide(s.x,s.y,
		s.w,s.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			s.lives-=1
			if	s.lives<0 then
				del(red_bat, s)
			end
		end
	end
	for s in all(brown_bat) do
		if	spr_collide(s.x,s.y,
		s.w,s.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			s.lives-=1
			if	s.lives<0 then
				del(brown_bat, s)
			end
		end
	end
end

function create_bat(spawnx,spawny)
	add(bat,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=64,lives=0})
end
function create_red_bat(spawnx,spawny)
	add(red_bat,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=128,lives=0})
end
function create_brown_bat(spawnx,spawny)
	add(brown_bat,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=128,lives=1})
end

function despawn_bats()
	for s in all(bat) do
		del(bat, s)
	end
	for s in all(red_bat) do
		del(red_bat, s)
	end
	for s in all(brown_bat) do
		del(brown_bat, s)
	end
end


-->8
--enterence
function init_ent()
	ent={}
	exitcx=0
	exitcy=0
	exitx=0
	exity=0
end

function update_ent()
	for e in all(ent) do
		if	spr_collide(pl.x,pl.y,
			pl.w,pl.h,e.x,e.y,8,8,4)==true then
			if e.id==1 then
				exitcx=256
				exitcy=0
				exitx=8
				exity=16
				boss_id=1
			elseif e.id==2 then
				exitcx=0
				exitcy=128
				exitx=8
				exity=16
			elseif e.id==3 then
				exitcx=384
				exitcy=0
				exitx=8
				exity=16
			elseif e.id==4 then
				exitcx=384
				exitcy=0
				exitx=16
				exity=8
			elseif e.id==5 then
				exitcx=256
				exitcy=0
				exitx=32
				exity=40
			elseif e.id==6 then
				exitcx=384
				exitcy=0
				exitx=13*8
				exity=8
			elseif e.id==7 then
				exitcx=512
				exitcy=0
				exitx=7*8
				exity=13*8
			elseif e.id==8 then
				exitcx=0
				exitcy=128
				exitx=2*8
				exity=14*8
				boss_id=2
			elseif e.id==9 then
				exitcx=128
				exitcy=128
				exitx=29*8
				exity=30*8
			elseif e.id==10 then
				exitcx=64*8
				exitcy=0
				exitx=8*8
				exity=10*8
			elseif e.id==11 then
				exitcx=96*8
				exitcy=0
				exitx=2*8
				exity=1*8
			elseif e.id==12 then
				exitcx=96*8
				exitcy=0
				exitx=2*8
				exity=11*8
			elseif e.id==13 then
				exitcx=80*8
				exitcy=0
				exitx=13*8
				exity=1*8
			elseif e.id==14 then
				exitcx=80*8
				exitcy=0
				exitx=13*8
				exity=11*8
			elseif e.id==15 then
				exitcx=96*8
				exitcy=0*8
				exitx=2*8
				exity=1*8
			elseif e.id==16 then
				exitcx=48*8
				exitcy=16*8
				exitx=2*8
				exity=1*8
				boss_id=3
			elseif e.id==17 then
				exitcx=16*8
				exitcy=0
				exitx=13*8
				exity=1*8
			elseif e.id==18 then
				exitcx=80*8
				exitcy=16*8
				exitx=13*8
				exity=4*8
			elseif e.id==19 then
				exitcx=80*8
				exitcy=16*8
				exitx=14*8
				exity=1*8
			elseif e.id==20 then
				exitcx=64*8
				exitcy=0
				exitx=7*8
				exity=7*8
			elseif e.id==21 then
				exitcx=32*8
				exitcy=16*8
				exitx=7*8
				exity=7*8
			end
			cx=exitcx
			cy=exitcy
			pl.x=cx+exitx
			pl.y=cy+exity
			sfx(5)
		end
	end
end

function generate_dungeon()
	for x=0,15 do
		for y=0,15 do
			if x==0 and y==0 then mset(x,y,66)
			elseif x==15 and y==0 then mset(x,y,65)
			elseif x==0 and y==15 then mset(x,y,82)
			elseif x==15 and y==15 then mset(x,y,81)
			elseif x==0 then mset(x,y,96)
			elseif x==15 then mset(x,y,80)
			elseif y==0 then mset(x,y,64)
			elseif y==15 then mset(x,y,97)
			else mset(x,y,98) end
		end
	end
end

function create_ent(spawnx,spawny,spawnid)
	add(ent,{x=spawnx,y=spawny,
			id=spawnid})
end

-->8
--switches
function init_target()
	target={}
	create_switch(8,1,1,1)
end

function update_target()
	for t in all(target) do
		if	spr_collide(t.x,t.y,
		t.w,t.h,lx,ly,pl.w,pl.h,1)==true then
			t.state=switch_effect(t.id,t.state)
		end
	end
end

function draw_target()
	for t in all(target) do
		if(t.state==true) then
			spr(112,t.x,t.y,1,1)
		else
			spr(113,t.x,t.y,1,1)
		end
	end
end

function create_switch(spawnx,spawny
,spawnid,spawn_face)
	add(target,{x=spawnx*8,y=spawny*8,
				h=8,w=8,state=spawn_face,id=spawnid,face=spawn_face})
end

function despawn_switches()
	for t in all(target) do
		del(target, t)
	end
end

function switch_effect(id)
	if id==1 then
		if state==true then
			state=false
			mset(7,15,72)
			mset(8,15,72)
		else
			state=true
			mset(7,15,98)
			mset(8,15,98)
		end
	elseif id==2 then
		if state==true then
			state=false
			mset(34,3,98)
		else
			state=true
			mset(34,3,72)
		end
	elseif id==3 then
		if state==true then
			state=false
			mset(59,1,72)
		else
			state=true
			mset(59,1,98)
		end
		elseif id==4 then
			if state==true then
				state=false
				mset(107,8,72)
				mset(99,2,98)
			else
				state=true
				mset(107,8,98)
				mset(99,2,72)
			end
		elseif id==5 then
			if state==true then
				state=false
				mset(82,14,98)
			else
				state=true
				mset(82,14,72)
			end
	end
	ly=512
	lx=512
	mag_fire=false
	sfx(4)
	return state
end
-->8
--inventory
function init_inv()
	inv={}
	for i=1,18 do
		add(inv,1,i)
	end
	cursorx=0
	cursory=0
	inv_open=false
	potion_ing1=0
	potion_ing2=0
end

function update_inv()
	if inv_open==true then
		if btnp(0) and cursorx>0 then
			cursorx-=1
			mset(117+cursorx+1,7+(cursory*2),56)
		elseif btnp(1) and cursorx<5 then
			cursorx+=1
			mset(117+cursorx-1,7+(cursory*2),56)
		elseif btnp(2) and cursory>0 then
			cursory-=1
			mset(117+cursorx,7+(cursory*2)+2,56)
		elseif btnp(3) and cursory<2 then
			cursory+=1
			mset(117+cursorx,7+(cursory*2)-2,56)
		end
		mset(117+cursorx,7+(cursory*2),57)
	end
	potion_craft()
end

function draw_inv()
		for n=1,18 do
			if n<7 then
				spr(47+n,(116+n)*8,7*8,1,1)
				print(inv[n],(116+n)*8,8*8,7)
			elseif n<13 then
				spr(51+n,(116+n-6)*8,9*8,1,1)
				print(inv[n],(116+n-6)*8,10*8,7)
			elseif n==13 then
				spr(69,(116+n-12)*8,11*8,1,1)
				print(inv[n],(116+n-12)*8,12*8,7)
			elseif n==14 then
				spr(70,(116+n-12)*8,11*8,1,1)
				print(inv[n],(116+n-12)*8,12*8,7)
			elseif n==15 then
				spr(71,(116+n-12)*8,11*8,1,1)
				print(inv[n],(116+n-12)*8,12*8,7)
			elseif n==16 then
				spr(85,(116+n-12)*8,11*8,1,1)
				print(inv[n],(116+n-12)*8,12*8,7)
			elseif n==17 then
				spr(86,(116+n-12)*8,11*8,1,1)
				print(inv[n],(116+n-12)*8,12*8,7)
			elseif n==18 then
				spr(105,(116+n-12)*8,11*8,1,1)
				print(inv[n],(116+n-12)*8,12*8,7)
			end
			n+=1
		end
	if cursorx==0 and cursory==0 then
		print("health potion",(117)*8,4*8,7)
	elseif cursorx==1 and cursory==0 then
		print("speed potion",(117)*8,4*8,7)
	elseif cursorx==2 and cursory==0 then
		print("ghost potion",(117)*8,4*8,7)
	elseif cursorx==3 and cursory==0 then
		print("fire potion",(117)*8,4*8,7)
	elseif cursorx==4 and cursory==0 then
		print("thorn potion",(117)*8,4*8,7)
	elseif cursorx==5 and cursory==0 then
		print("max potion",(117)*8,4*8,7)
	
	elseif cursorx==0 and cursory==1 then
		print("blue slimeball",(117)*8,4*8,7)
	elseif cursorx==1 and cursory==1 then
		print("red slimeball",(117)*8,4*8,7)
	elseif cursorx==2 and cursory==1 then
		print("green slimeball",(117)*8,4*8,7)
	elseif cursorx==3 and cursory==1 then
		print("bat wing",(117)*8,4*8,7)
	elseif cursorx==4 and cursory==1 then
		print("brown bat wing",(117)*8,4*8,7)
	elseif cursorx==5 and cursory==1 then
		print("red bat wing",(117)*8,4*8,7)
	
	
	elseif cursorx==0 and cursory==2 then
		print("bluebell",(117)*8,4*8,7)
	elseif cursorx==1 and cursory==2 then
		print("rose",(117)*8,4*8,7)
	elseif cursorx==2 and cursory==2 then
		print("pumpkin",(117)*8,4*8,7)
	elseif cursorx==3 and cursory==2 then
		print("buttercup",(117)*8,4*8,7)
	elseif cursorx==4 and cursory==2 then
		print("dandelion",(117)*8,4*8,7)
	elseif cursorx==5 and cursory==2 then
		print("berry",(117)*8,4*8,7)
	end
end

function open_inv()
	if btnp(5) and inv_open==true then
		inv_open=false
	elseif btnp(5) then
		inv_open=true
	end
end

function use_potion()
	if btnp(4) then
		if inv[1]>0 and cursorx==0 and cursory==0 then
			if pl.lives < pl.maxlives then
				pl.lives+=1
				inv[1]-=1
				sfx(4)
			end
		elseif inv[2]>0 and cursorx==1 and cursory==0 then
			inv[2]-=1
			sfx(4)
		elseif inv[3]>0 and cursorx==2 and cursory==0 then
			inv[3]-=1
			sfx(4)
		elseif inv[4]>0 and cursorx==3 and cursory==0 then
			inv[4]-=1
			sfx(4)
		elseif inv[5]>0 and cursorx==4 and cursory==0 then
			inv[5]-=1
			sfx(4)
		elseif inv[6]>0 and cursorx==5 and cursory==0 then
			pl.lives=pl.maxlives
			inv[6]-=1
			sfx(4)
		
		elseif inv[7]>0 and cursorx==0 and cursory==1 then
			potion_ing1=1
			sfx(4)
		elseif inv[8]>0 and cursorx==1 and cursory==1 then
			potion_ing1=2
			sfx(4)
		elseif inv[9]>0 and cursorx==2 and cursory==1 then
			potion_ing1=3
			sfx(4)
		elseif inv[10]>0 and cursorx==3 and cursory==1 then
			potion_ing1=4
			sfx(4)
		elseif inv[11]>0 and cursorx==4 and cursory==1 then
			potion_ing1=5
			sfx(4)
		elseif inv[12]>0 and cursorx==5 and cursory==1 then
			potion_ing1=6
			sfx(4)
			
		elseif inv[13]>0 and cursorx==0 and cursory==2 then
			potion_ing2=1
			sfx(4)
		elseif inv[14]>0 and cursorx==1 and cursory==2 then
			potion_ing2=2
			sfx(4)
		elseif inv[15]>0 and cursorx==2 and cursory==2 then
			potion_ing2=3
			sfx(4)
		elseif inv[16]>0 and cursorx==3 and cursory==2 then
			potion_ing2=4
			sfx(4)
		elseif inv[17]>0 and cursorx==4 and cursory==2 then
			potion_ing2=5
			sfx(4)
		elseif inv[18]>0 and cursorx==5 and cursory==2 then
			potion_ing2=6
			sfx(4)
		end
	end
end

function potion_craft()
	if potion_ing1==1 and potion_ing2==1 then
		potion_ing1=0
		potion_ing2=0
		inv[7]-=1
		inv[13]-=1
		inv[1]+=1
	elseif potion_ing1==2 and potion_ing2==2 then
		potion_ing1=0
		potion_ing2=0
		inv[8]-=1
		inv[14]-=1
		inv[2]+=1
	elseif potion_ing1==3 and potion_ing2==3 then
		potion_ing1=0
		potion_ing2=0
		inv[9]-=1
		inv[15]-=1
		inv[3]+=1
	elseif potion_ing1==4 and potion_ing2==4 then
		potion_ing1=0
		potion_ing2=0
		inv[10]-=1
		inv[16]-=1
		inv[4]+=1
	elseif potion_ing1==5 and potion_ing2==5 then
		potion_ing1=0
		potion_ing2=0
		inv[11]-=1
		inv[17]-=1
		inv[5]+=1
	elseif potion_ing1==6 and potion_ing2==6 then
		potion_ing1=0
		potion_ing2=0
		inv[12]-=1
		inv[18]-=1
		inv[6]+=1
	end
end
-->8
--plant
function init_plant()
	pu={}
	add(pu,{s=71,x=11,y=11})
	add(pu,{s=102,x=7,y=11})
end

function draw_plant()
	for p in all(pu) do
		spr(p.s, p.x*8, p.y*8)
	end
end

-->8
--bosses
function init_moth()
	moth={}
	state=true
	
end

function update_moth()
	for m in all(moth) do
		m.x,m.y=move_moth
		(m.x,m.y)
		kill_moth()
	end
end

function draw_moth()
	for m in all(moth) do
		if(frame_count>15) then
			spr(16,m.x,m.y,1,1)
			spr(17,m.x+8,m.y,1,1)
			spr(32,m.x,m.y+8,1,1)
			spr(33,m.x+8,m.y+8,1,1)
		else
			spr(18,m.x,m.y,1,1)
			spr(19,m.x+8,m.y,1,1)
			spr(34,m.x,m.y+8,1,1)
			spr(35,m.x+8,m.y+8,1,1)
		end
	end
end

function move_moth(x,y)
	if x<64*8 then
		direction=2
	elseif x>78*8 then
		direction=3
	elseif y<0 then
		direction=1
	elseif y>14*8 then
		direction=0
	elseif x>80*8 or x<62*8 or
								y>20*8 or y<-16 then
		x=71*8
		y=6*8
	end	
	
	if state==false then
		if direction==0 then
			y+=2
		elseif direction==1 then
			y-=2
		elseif direction==2 then
			x+=2
		elseif direction==3 then
			x-=2
		else
			direction=3
		end
	elseif state==true then
		if direction==0 then
			x+=2
			y-=2
		elseif direction==1 then
			x-=2
			y+=2
		elseif direction==2 then
			x+=2
			y+=2
		elseif direction==3 then
			x-=2
			y-=2
		else
			direction=3
		end
	end
	return x,y,s
end

function kill_moth()
	for m in all(moth) do
		if	spr_collide(m.x,m.y,
		m.w,m.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			m.lives-=1
			if	m.lives<0 then
				del(moth, m)
				mset(77,14,98)
				mset(15,27,84)
				mset(15,28,84)
			end
			if state==false then
				state=true
			elseif state==true then
				state=false
			end
		end
	end
end

function create_moth(spawnx,spawny)
	add(moth,{x=spawnx*8,y=spawny*8,
				h=16,w=16,airange=128,
				lives=10,direction==0})
end

function despawn_moth()
	for m in all(moth) do
		del(moth, m)
	end
end

function init_summoner()
	summoner={}
	teleport_count=0
	teleport_timer=0
end

function update_summoner()
	for m in all(summoner) do
		m.x,m.y=move_summoner
		(m.x,m.y)
		kill_summoner()
	end
end

function draw_summoner()
	for m in all(summoner) do
		if(frame_count>15) then
			spr(26,m.x,m.y,1,1)
		else
			spr(27,m.x,m.y,1,1)
		end
	end
end

function move_summoner(x,y)
	if (time()-teleport_timer)>2 then
		teleport_timer=time()
		if teleport_count<5 then
			teleport_count+=1
			x = (flr(rnd(14))+65)*8--x+=65
			y = (flr(rnd(14))+1)*8
		else
		create_enemy_bullet(x,y)
			teleport_count=0
			smn_type=flr(rnd(3))
			if smn_type==0 then
				create_slime(77,3)
				create_slime(67,13)
			elseif smn_type==1 then
				create_bat(77,3)
				create_bat(67,13)
				create_bat(67,3)
				create_bat(77,13)
			elseif smn_type==2 then
				create_red_slime(77,3)
				create_red_slime(67,13)
			end
			
		end
	end
	return x,y,s
end

function kill_summoner()
	for m in all(summoner) do
		if	spr_collide(m.x,m.y,
		m.w,m.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			m.lives-=1
			if	m.lives<0 then
				del(summoner, m)
				mset(77,14,98)
				mset(22,16,84)
			end
			if state==false then
				state=true
			elseif state==true then
				state=false
			end
		end
	end
end

function create_summoner(spawnx,spawny)
	add(summoner,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=128,
				lives=15,direction==0})
	teleport_timer=time()
end

function despawn_summoner()
	for m in all(summoner) do
		del(summoner, m)
	end
end

function init_sorceress()
	sorceress={}
end

function update_sorceress()
	for s in all(sorceress) do
		s.x,s.y=move_sorceress
		(s.x,s.y)
		kill_sorceress()
	end
end

function draw_sorceress()
	for s in all(sorceress) do
		if(frame_count>15) then
			spr(14,s.x,s.y,1,1)
		else
			spr(15,s.x,s.y,1,1)
		end
	end
end

function move_sorceress(x,y)
	x,y=move_summoner(x,y)
	return x,y
end

function create_sorceress(spawnx,spawny)
	add(sorceress,{x=spawnx*8,y=spawny*8,
				h=8,w=8,airange=128,
				lives=25})
end

function despawn_sorceress()
	for s in all(sorceress) do
		del(sorceress, s)
	end
end

function kill_sorceress()
	for m in all(sorceress) do
		if	spr_collide(m.x,m.y,
		m.w,m.h,lx,ly,pl.w,pl.h,1)==true then
			ly=512
			lx=512
			sfx(3)
			mag_fire=false
			m.lives-=1
			create_enemy_bullet(m.x,m.y)
			if	m.lives<0 then
				del(sorceress, m)
				mset(77,14,98)
				mset(22,16,84)
			end
			if state==false then
				state=true
			elseif state==true then
				state=false
			end
		end
	end
end

function init_enemy_bullet()
	enemy_bullet={}
end

function update_enemy_bullet()
	for m in all(enemy_bullet) do
		if m.direction==1 then
	 	m.x+=1 m.y+=1
	 elseif m.direction==2 then
	 	m.x-=1 m.y+=1
	 elseif m.direction==3 then
	 	m.x+=1 m.y-=1
	 elseif m.direction==4 then
	 	m.x-=1 m.y-=1
	 elseif m.direction==5 then
	 	m.x+=1.41
	 elseif m.direction==6 then
	 	m.x-=1.41
	 elseif m.direction==7 then
	 	m.y+=1.41
	 elseif m.direction==8 then
	 	m.y-=1.41
	 end
	 if	map_collide(m.x,m.y,
			4,4,0)==true then
			m.bounces-=1
			if m.bounces>0 then
				if m.direction==1 then
					m.direction=4
				elseif m.direction==2 then
					m.direction=3
		 	elseif m.direction==3 then
		 		m.direction=2
		 	elseif m.direction==4 then
		 		m.direction=1
		 	elseif m.direction==5 then
		 		m.direction=6
		 	elseif m.direction==6 then
		 		m.direction=5
		 	elseif m.direction==7 then
		 		m.direction=8
			 elseif m.direction==8 then
			 	m.direction=7
			 end
	 	end
	 	if m.bounces==0 then
				del(enemy_bullet, m)
			end
		end
	end
end

function draw_enemy_bullet()
	for m in all(enemy_bullet) do
		spr(31,m.x,m.y,1,1)
	end
end

function destroy_enemy_bullet()
	for m in all(enemy_bullet) do
	 
	end
end

function create_enemy_bullet(spawnx,spawny)
	for i=1,8 do
		
		add(enemy_bullet,{x=spawnx,y=spawny,
				h=4,w=4,direction=i,bounces=2})
				i+=1
		end
end


__gfx__
0000000000452555004525550555555000000800000000000000000000000000000000000066660000000000000000000000000000000000000aa000000aa000
000000000444522004445200566666650000808000008080009a0000000000000000000006cccc60000cbb0000000000500000050000000000aaaa0000aaaa00
007007004fff45004fff45205555555580000800080000000009a000000a000a006666006c7c7cc600bbbb00000cbb0055000055558558550afffaa00afffaa0
0007700005f5f45005f5f45055555555000000008080008000009a0000a9a0a906cccc606cccccc6000ddd0000bbbb000585585050555505002f2fa0002f2fa0
000770000ffff4000ffff4005555555500080000080000000009a0000a909a906c7c7cc66cccccc666bdddb0600ddd00005555000060060000ffffa000ffffa0
0070070000d2d4000fd2df00555555550080800000000000009a0000090009006cccccc66cccccc6000ddd00060ddd0000600600000000000008f8a000f8f8f0
000000000fd2df0000d2d0000555555000080080000008000009a000000000006cccccc6066666600020002000bdddb0000000000000000000f828f000082800
00000000005050000500050050555505000000008000808000009a00000000000666666000555500000000000002020000555500000550000008288000082880
00000000000000000000000000000000000022220000000022222222000022220000000000eeee0000ffff0000ffff00000000000000000000ffff0000000000
000000000000000000000000000000000002eeee00022000e2eeeeee0002eeee000000000e8888e0845f5f00845f5f004000000400000000845f5f00000ee000
00006000000600000000600000060000002ee8ee002ee2002eeeeeee002eeeee00eeee00e878788e44ffff0044ffff00440000444494494444ffff0000e88e00
0550060000600550000006000060000002ee88ee02eeee202eeeeeee02eeeeee0e8888e0e888888e0fd2ddf00f42dd0004944940404444040fd2ddf00e8828e0
5555060000605555000006000060000002eeeeee2eee8ee22eeeeeee02eeeeeee868688ee888888e04d2dd0000d4dd00004444000060060004d2dd000e8288e0
05555055550555500000005555000000002eeeee2eee88e22eeeeeee002eeeeee888888ee888888e04d2ddd000d24f00006006000000000004d2ddd000e88e00
005555855855550000005585585500000002eeee2eeeeee2e2eeeeee0002eeeee888888e0eeeeee004d2ddd000d2d4d0000000000000000004d2ddd0000ee000
00005555555500000055555555555500000022222eeeeee222222222000022220eeeeee00055550004d2dddd00d2dd4d005555000005500004d2dddd00000000
000005555550000005550555555055502eeeeee2222200002eeeeee2000000000000000000bbbb00000091100000911000000000000000000000000000000000
000005555550000005500555555005502eeeeee2eeee20002eeeeee200022000000000000b3333b0000119000001190080000008000000000000000000000000
000000555500000000000055550000002e88eee2eeeee2002eeeeee2002ee20000bbbb00b373733b00fff11000fff1108800008888e88e880000000000000000
000005000050000000000500005000002ee8eee2eeeeee202eeeeee202eeee200b3333b0b333333b008f8f00008f8f0008e88e80808888080000000000000000
0000000000000000000000000000000002eeee20ee88ee202eeeeee22eeeeee2b373733bb333333b40ffff0000ffff0000888800006006000000000000000000
00000000000000000000000000000000002ee200ee8ee2002eeeeee22eeeeee2b333333bb333333b040121000001210000600600000000000000000000000000
0000000000000000000000000000000000022000eeee200022eeee222eeeeee2b333333b0bbbbbb000f121f044f121f000000000000000000000000000000000
0000000000000000000000000000000000000000222200002e2222e22eeeeee20bbbbbb000555500000505000005050000555500000550000000000000000000
00044000000440000004400000044000000440000004400000044000005006005555555577777777000000000000000000000000000000000000000000000000
0054450000544500005445000054450000544500005445000054450005256e6050000005700000070066000000ee000000bb0000000000000000000000000000
00566500005665000056650000566500005665000056650000566500528888e6505005057070070706cc66000e88ee000b33bb00000555000004440000088800
056666500566665005666650056666500566665005666650056666505288e8e650055005700770076ccccc60e88888e0b33333b0005550000044400000888000
56666665566666655666666556666665566666655666666556666665528888e650055005700770076cccc600e8888e00b3333b00055500000444000008880000
588888855cccccc5577777755aaaaaa553333335522222255999999505288e60505005057070070706c660000e8ee0000b3bb000055000000440000008800000
0588885005cccc500577775005aaaa500533335005222250059999500052e60050000005700000070060000000e0000000b00000000000000000000000000000
00555500005555000055550000555500005555000055550000555500000660005555555577777777000000000000000000000000000000000000000000000000
dddddddddddddddddddddddd333333333a3333330000000000000000000000005444444411111111d11111110000000000000000000000005500000000000000
111111d1111111dddd111111b33333b3a3a333b3000ccc00000888000000b0005444444410111101501111010000000000000000000000055500000000000000
111111d111111d1dd1d111113b333b333a33333b000ccc0000088800009b90006555555511011011d10110110000000000000000000000555000000000000000
111111d11111d11dd11d111133333333333333330000c00000008000099999005444444611111111511111110000000000000000000005555000000000000000
dddddddddddd111dd111dddd33333333333338330000b0000000b000099999005444444611111111d1111111000000000000000000555ddd0000000000000000
111d111111dd111dd111dd113333b33333b383830000b0000000b000099999006555555511011011510110110000000000000000000555555000000000000000
111d11111d1d111dd111d1d1333b33333b333833000b0000000b0000009990005444444410111101d01111010000000000000000000fff455550000000000000
ddddddddd11d111dd111d11d3333333333333333000b0000000b00000000000054444444d5d5d5d5511111110000000000000000000cfcf44444040000000000
d11d111dd11d111dd111d11d3c333333333333330000000000000000b33b333b33bbb3335d5d5d5d1111111500000000000000000000ffff4444040000000000
d11d111d1d1d111dd111d1d1c3c33b3333333b33000aaa00000777003b33b3b33b3b3b33101111011011110d000000000000000000000ff44444444000000000
d11d111d11dd111dd111dd113c3333b3333333b3000aaa0000077700333333333bb3b3b311011011110110150000000000000000000000dd4444444000000000
dddd111ddddd111dd111dddd33333333333333330000a00000007000333333bb3b3b3bb3111111111111111d000000000000000000000d2dd444444000000000
d11d111d1111d11dd11d11113333333333b333330000b0000000b000bb33333333bbbb331111111111111115000000000000000000000ddddd04400000000000
d11d111d11111d1dd1d11111b33333b33b3333330000b0000000b0003333333333334333110110111101101d00000000000000000000dd2dddd0440000000000
d11ddddd111111dddd1111113b333b3333333b33000b0000000b00003b33b3b33334433310111101101111050000000000000000000ddddddddd000000000000
d11d111ddddddddddddddddd33333333333333b3000b0000000b0000b333b33b33343333111111111111111d000000000000000000dd002d0dddd00000000000
d111d11ddddddddd111111113333333333333333333333333333333333bbb33398a59898003003000000000000000000000000000ddd00ddd0dddd0000000000
d111d11d1d11111110111101333b3b3b333b3b3b333b3b3b333b3b3b3bbbbbb3a989985a08833880000000000000000000000000ddd0002dd0ddddd000000000
d111d11d1d11111111011011b3bbbbb3b3bbbbb3b3bbbbb3b3bbbbb3b3b3bbbb895a89aa0888888000000000000000000044400ddfdd00dddd0ddddd00000000
d111dddddddddddd1111111138bbbb8b3cbbbbcb37bbbb7b32bbbb2bbb3bb3b39a9995a8088888800000000000000000000044444ff000252200ddddd0000000
d111d11d1111d111111111113bb8bbbb3bbcbbbb3bb7bbbb3bb2bbbbbbbbbb3b98959899008888000000000000000000000000000ff4445a5240dff000000000
d111d11d1111d11111011011bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bb3b3bbba889a8a80088880000000000000000000000000000000dd5ddd44ff000000000
ddddd11d1111d111101111013bbb8bbb3bbbcbbb3bbb7bbb3bbb2bbbbbb3bbbb8aa8a8890008800000000000000000000000000000000ddddddddf4400000000
d111d11ddddddddd11111111333333333333333333333333333333333bbbbbb3998599580000000000000000000000000000000000000d2ddd2ddd0444666555
00555500005555000066600000666000b33333b311111111111111111111111133333333000000000000000000000000000000000000ddd2ddd2dd0000555566
06cccc600688886006ccc600068886003b35553b1d1111111111111d1444444134444443000000000000000000000000000000000000ddd2dddd2ddd00556555
6cccccc6688888865ccccc6058888860b35555331d1d111111111d1d14545441345454430000000000000000000000000000000000000ddd2ddd2ddddd005655
6cccc7c668888e865cccccc658888886355555531d1d1d11111d1d1d14454541344545430000000000000000000000000000000000000dddd2ddd2ddd0000560
6ccc7cc66888e8865ccc7cc65888e8863554455b1d1d1d1d1d1d1d1d144444413444444300000000000000000000000000000000000000dddd2ddd2d00000000
06cccc60068888605cc7cc60588e8860554004531d1d1d1d1d1d1d1d111411113334333300000000000000000000000000000000000000dddd2dddd250000000
006cc6000068860006ccc60006888600554004551d1d1d1d1d1d1d1d1114111133343333000000000000000000000000000000000000000dddd2dd0550000000
00066000000660000066600000666000554004551d1d1d1d1d1d1d1d11141111333433330000000000000000000000000000000000000000dddd500000000000
24040404040404040404040404040414040404040404040404040404040404142404040404040404040404040404041400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06670526262626262626262626052684262626262626262626262684262667050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262616161616160626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
062684262626262626262626260526052626262626262626262626a4262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
062605262626262626262626260526052626262626262626262626a4262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06940526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06950526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262626260500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626842605262626262626262626262606262626050626262626262626262626262604040500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06260526262626262626262626052605262626262626262626262606262626050626262626262626262626262684670500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
25161616161616161616161616161615161616161616161616161616161616152516161616161616161616161616161500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000055500000000000000000000000000000000000000000000000000000000000000000000000000240404040404040404040404040404140000
00000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005555000000000000000000000000000000000000000000000000000000000000000000000000000062626262626262626262626262626050000
0000000000555ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000555555000000000000000000000000000000000000000000000000000000000000000000000000000062626262626262626262626262626050000
00000000000fff455550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cfcf4444404000000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e2e2e2e2e2e2e2e2e2e2050000
000000000000ffff4444040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ff4444444400000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e2e2e2e2e2e2e2e2e2e2050000
00000000000000dd4444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000d2dd44444400000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e2e2e2e2e2e2e2e2e2e2050000
0000000000000ddddd04400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000dd2dddd044000000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e20c1c2c3ce2e2e2e2e2050000
00000000000ddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dd002d0dddd0000000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e20d1d2d3de2e2e2e2e2050000
000000000ddd00ddd0dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddd0002dd0ddddd00000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e20e1e2e3ee2e2e2e2e2050000
0044400ddfdd00dddd0ddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000044444ff000252200ddddd000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e20f1f2f3fe2e2e2e2e2050000
000000000ff4445a5240dff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dd5ddd44ff00000000000000000000000000000000000000000000000000000000000000000000006e2e2e2e2e2e2e2e2e2e2e2e2e2e2050000
0000000000000ddddddddf4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000d2ddd2ddd044466655500000000000000000000000000000000000000000000000000000000000006e2e2e2e2e2e2e2e2e2e2e2e2e2e2050000
000000000000ddd2ddd2dd0000555566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ddd2dddd2ddd00556555000000000000000000000000000000000000000000000000000000000000062626262626262626262626262626050000
0000000000000ddd2ddd2ddddd005655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000dddd2ddd2ddd0000560000000000000000000000000000000000000000000000000000000000000062626262626262626262626262626050000
00000000000000dddd2ddd2d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000dddd2dddd250000000000000000000000000000000000000000000000000000000000000000000062626262626262626262626262626050000
000000000000000dddd2dd0550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000dddd500000000000000000000000000000000000000000000000000000000000000000000000251616161616161616161616161616150000
__label__
d111d11d33bbb33333bbb33333bbb33333bbb33333bbb33333bbb333333333333333333333bbb33333bbb33333bbb33333bbb33333bbb33333bbb33333bbb333
d111d11d3bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb3b33333b3b33333b33bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb3
d111d11db3b3bbbbb3b3bbbbb3b3bbbbb3b3bbbbb3b3bbbbb3b3bbbb3b333b333b333b33b3b3bbbbb3b3bbbbb3b3bbbbb3b3bbbbb36666bbb3b3bbbbb3b3bbbb
d111ddddbb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b33333333333333333bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3b6cccc63bb3bb3b3bb3bb3b3
d111d11dbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3b3333333333333333bbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3b6c7c7cc6bbbbbb3bbbbbbb3b
d111d11dbb3b3bbbbb3b3bbbbb3b3bbbbb3b3bbbbb3b3bbbbb3b3bbb3333b3333333b333bb3b3bbbbb3b3bbbbb3b3bbbbb3b3bbb6cccccc6bb3b3bbbbb3b3bbb
ddddd11dbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbb333b3333333b3333bbb3bbbbbbb3bbbbbbb3bbbbbbb3bbbb6cccccc6bbb3bbbbbbb3bbbb
d111d11d3bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb33bbbbbb333333333333333333bbbbbb33bbbbbb33bbbbbb33bbbbbb3366666633bbbbbb33bbbbbb3
d111d11d333353363333335336333333533633333333333333bbb333333333333333333333bbb333333333333333333333333333333333333333333333bbb333
d111d11d3335256e633335256e633b35256e63b3b33333b33bbbbbb333333b3333333b333bbbbbb3b33333b3b33333b3b33333b3b33333b3b33333b33bbbbbb3
d111d11d33528888e633528888e633528888e6333b333b33b3b3bbbb333333b3333333b3b3b3bbbb3b333b333b333b333b333b333b333b333b333b33b3b3bbbb
d111dddd335288e8e6335288e8e6335288e8e63333333333bb3bb3b33333333333333333bb3bb3b33333333333333333333333333333333333333333bb3bb3b3
d111d11d33528888e633528888e633528888e63333333333bbbbbb3b33b3333333b33333bbbbbb3b3333333333333333333333333333333333333333bbbbbb3b
d111d11d3b35288e6333b5288e6333b5288e63333333b333bb3b3bbb3b3333333b333333bb3b3bbb3333b3333333b3333333b3333333b3333333b333bb3b3bbb
ddddd11d333352e6333b3352e6333b3352e63333333b3333bbb3bbbb33333b3333333b33bbb3bbbb333b3333333b3333333b3333333b3333333b3333bbb3bbbb
d111d11d33333663333333366333333336633333333333333bbbbbb3333333b3333333b33bbbbbb333333333333333333333333333333333333333333bbbbbb3
d111d11d333333333333333333333333333333333333333333bbb333333333333333333333bbb333333333333333333333333333333333333333333333bbb333
d111d11d33333b3333333b3333333b3333333b3333333b333bbbbbb333333b3333333b333bbbbbb333333b3333333b3333333b3333333b3333333b333bbbbbb3
d111d11d333333b3333333b3333333b3333333b3333333b3b3b3bbbb333333b3333333b3b3b3bbbb333333b3333333b3333333b3333333b3333333b3b3b3bbbb
d111dddd3333333333333333333333333333333333333333bb3bb3b33333333333333333bb3bb3b33333333333333333333333333333333333333333bb3bb3b3
d111d11d33b3333333b3333333b3333333b3333333b33333bbbbbb3b33b3333333b33333bbbbbb3b33b3333333b3333333b3333333b3333333b33333bbbbbb3b
d111d11d3b3333333b3333333b3333333b3333333b333333bb3b3bbb3b3333333b333333bb3b3bbb3b3333333b3333333b3333333b3333333b333333bb3b3bbb
ddddd11d33333b3333333b3333333b3333333b3333333b33bbb3bbbb33333b3333333b33bbb3bbbb33333b3333333b3333333b3333333b3333333b33bbb3bbbb
d111d11d333333b3333333b3333333b3333333b3333333b33bbbbbb3333333b3333333b33bbbbbb3333333b3333333b3333333b3333333b3333333b33bbbbbb3
d111d11d333333333333333333333333333333333333333333bbb333333333333333333333bbb333333333333333333333333333333333333333333333bbb333
d111d11db33333b3b33333b3b33333b3b33333b3b33333b33bbbbbb3b33333b3b33333b33bbbbbb3b33333b3b33333b333333b3333333b3333333b333bbbbbb3
d111d11d3b333b333b333b333b333b333b333b333b333b33b3b3bbbb3b333b333b333b33b3b3bbbb3b333b333b333b33333333b3333333b3333333b3b3b3bbbb
d111dddd3333333333333333333333333333333333333333bb3bb3b33333333333333333bb3bb3b33333333333333333333333333333333333333333bb3bb3b3
d111d11d3333333333333333333333333333333333333333bbbbbb3b3333334525553333bbbbbb3b333333333333333333b3333333b3333333b33333bbbbbb3b
d111d11d3333b3333333b3333333b3333333b3333333b333bb3b3bbb3333b4445223b333bb3b3bbb3333b3333333b3333b3333333b3333333b333333bb3b3bbb
ddddd11d333b3333333b3333333b3333333b3333333b3333bbb3bbbb333b4fff453b3333bbb3bbbb333b3333333b333333333b3333333b3333333b33bbb3bbbb
d111d11d33333333333333333333333333333333333333333bbbbbb3333335f5f45333333bbbbbb33333333333333333333333b3333333b3333333b33bbbbbb3
d111d11d33333333333333333a33333333333333333333333333333333333ffff433333333333333333333333333333333333333333333333333333333bbb333
d111d11db33333b3b33333b3a3a333b3b33333b3b33333b3b33333b3b33333d2d43333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b33bbbbbb3
d111d11d3b333b333b333b333a33333b3b333b333b333b333b333b333b333fd2df333b333b333b333b333b333b333b333b333b333b333b333b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333335353333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d3333333333333333333338333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbb3b
d111d11d3333b3333333b33333b383833333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b333bb3b3bbb
ddddd11d333b3333333b33333b333833333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333bbb3bbbb
d111d11d33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbb3
d111d11d333333333c3333333333333333333333333333333333333333333333333333333333333333333333333333333a333333333333333333333333bbb333
d111d11db33333b3c3c33b33b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3a3a333b3b33333b3b33333b33bbbbbb3
d111d11d3b333b333c3333b33b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333a33333b3b333b333b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333338333333333333333333bbbbbb3b
d111d11d3333b333b33333b33333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b33333b383833333b3333333b333bb3b3bbb
ddddd11d333b33333b333b33333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b33333b333833333b3333333b3333bbb3bbbb
d111d11d33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbb3
d111d11d333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbb333
d111d11db33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b33bbbbbb3
d111d11d3b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbb3b
d111d11d3333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b333bb3b3bbb
ddddd11d333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333bbb3bbbb
d111d11d33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbb3
d111d11d33333333333333333c3333333333333333333333333333333a333333333333333333333333333333333333333c333333333333333333333333bbb333
d111d11db33333b3b33333b3c3c33b33b33333b3b33333b3b33333b3a3a333b3b33333b3b33333b3b33333b3b33333b3c3c33b33b33333b3b33333b33bbbbbb3
d111d11d3b333b333b333b333c3333b33b333b333b333b333b333b333a33333b3b333b333b333b333b333b333b333b333c3333b33beeee333b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333e8888e333333333bb3bb3b3
d111d11d333333333333333333333333333333333333333333333333333338333333333333333333333333333333333333333333e868688e33333333bbbbbb3b
d111d11d3333b3333333b333b33333b33333b3333333b3333333b33333b383833333b3333333b3333333b3333333b333b33333b3e888888e3333b333bb3b3bbb
ddddd11d333b3333333b33333b333b33333b3333333b3333333b33333b333833333b3333333b3333333b3333333b33333b333b33e888888e333b3333bbb3bbbb
d111d11d3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333eeeeee3333333333bbbbbb3
d111d11d333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbb333
d111d11db33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b333333b3333333b33b33333b33bbbbbb3
d111d11d3b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b33333333b3333333b33b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333b3333333b3333333333333bbbbbb3b
d111d11d3333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333b3333333b3333333333b333bb3b3bbb
ddddd11d333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b333333333b3333333b33333b3333bbb3bbbb
d111d11d3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333b3333333b3333333333bbbbbb3
d111d11d333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbb333
d111d11d33333b3333333b33b33333b333333b3333333b3333333b33b33333b3b33333b3b33333b3b33333b333333b3333333b3333333b33b33333b33bbbbbb3
d111d11d333333b3333333b33b333b33333333b3333333b3333333b33b333b333b333b333b333b333b333b33333333b3333333b3333333b33b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d33b3333333b333333333333333b3333333b3333333b333333333333333333333333333333333333333b3333333b3333333b3333333333333bbbbbb3b
d111d11d3b3333333b3333333333b3333b3333333b3333333b3333333333b3333333b3333333b3333333b3333b3333333b3333333b3333333333b333bb3b3bbb
ddddd11d33333b3333333b33333b333333333b3333333b3333333b33333b3333333b3333333b3333333b333333333b3333333b3333333b33333b3333bbb3bbbb
d111d11d333333b3333333b333333333333333b3333333b3333333b333333333333333333333333333333333333333b3333333b3333333b3333333333bbbbbb3
d111d11d33333333333333333a333333333333333333333333333333333333333333333333333333333333333333333333333333333333333a33333333bbb333
d111d11db33333b333333b33a3a333b333333b3333333b3333333b33b33333b3b33333b3b33333b333333b3333333b3333333b3333333b33a3a333b33bbbbbb3
d111d11d3b333b33333333b33a33333b333333b3333333b3333333b33b333b333b333b333b333b33333333b3333333b3333333b3333333b33a33333bb3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d3333333333b333333333383333b3333333b3333333b3333333333333333333333333333333b3333333b3333333b3333333b3333333333833bbbbbb3b
d111d11d3333b3333b33333333b383833b3333333b3333333b3333333333b3333333b3333333b3333b3333333b3333333b3333333b33333333b38383bb3b3bbb
ddddd11d333b333333333b333b33383333333b3333333b3333333b33333b3333333b3333333b333333333b3333333b3333333b3333333b333b333833bbb3bbbb
d111d11d33333333333333b333333333333333b3333333b3333333b3333333333333333333333333333333b3333333b3333333b3333333b3333333333bbbbbb3
d111d11d3333333333333333333333333333333333333333333333333c3333333333333333333333333333333333333333333333333333333a3333333a333333
d111d11db33333b333333b3333333b33b33333b333333b33b33333b3c3c33b3333333b33b33333b333333b33b33333b333333b3333333b33a3a333b3a3a333b3
d111d11d3b333b33333333b3333333b33b333b33333333b33b333b333c3333b3333333b33b333b33333333b33b333b33333333b333bbbbb33a33333b3a33333b
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333b3333b33333333333333333
d111d11d3333333333b3333333b333333333333333b33333333333333333333333b333333333333333b333333333333333b33333b373733b3333383333333833
d111d11d3333b3333b3333333b3333333333b3333b3333333333b333b33333b33b3333333333b3333b3333333333b3333b333333b333333b33b3838333b38383
ddddd11d333b333333333b3333333b33333b333333333b33333b33333b333b3333333b33333b333333333b33333b333333333b33b333333b3b3338333b333833
d111d11d33333333333333b3333333b333333333333333b33333333333333333333333b333333333333333b333333333333333b33bbbbbb33333333333333333
d111d11d33333333333333333c3333333333333333333333333333333333333333333333333333333a3333333c3333333a3333333a3333333a3333333a333333
d111d11db33333b3b33333b3c3c33b3333333b33b33333b3b33333b333333b3333333b3333333b33a3a333b3c3c33b33a3a333b3a3a333b3a3a333b3a3a333b3
d111d11d3b333b333b333b333c3333b3333333b33b333b333b333b33333333b3333333b3333333b33a33333b3c3333b33a33333b3a33333b3a33333b3a33333b
d111dddd333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
d111d11d33333333333333333333333333b33333333333333333333333b3333333b3333333b33333333338333333333333333833333338333333383333333833
d111d11d3333b3333333b333b33333b33b3333333333b3333333b3333b3333333b3333333b33333333b38383b33333b333b3838333b3838333b3838333b38383
ddddd11d333b3333333b33333b333b3333333b33333b3333333b333333333b3333333b3333333b333b3338333b333b333b3338333b3338333b3338333b333833
d111d11d333333333333333333333333333333b33333333333333333333333b3333333b3333333b3333333333333333333333333333333333333333333333333
d111d11d33333333333333333a3333333333333333333333333333333a3333333333333333333333333333333333333333333333333333333333333333bbb333
d111d11d33333b33b33333b3a3a333b3b33333b3b33333b333333b33a3a333b333333b3333333b33b33333b3b33333b3b33333b3b33333b3b33333b33bbbbbb3
d111d11d333333b33b333b333a33333b3b333b333b333b33333333b33a33333b333333b3333333b33b333b333b333b333b333b333b333b333b333b33b3b3bbbb
d111dddd3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d33b333333333333333333833333333333333333333b333333333383333b3333333b333333333333333333333333333333333333333333333bbbbbb3b
d111d11d3b3333333333b33333b383833333b3333333b3333b33333333b383833b3333333b3333333333b3333333b3333333b3333333b3333333b333bb3b3bbb
ddddd11d33333b33333b33333b333833333b3333333b333333333b333b33383333333b3333333b33333b3333333b3333333b3333333b3333333b3333bbb3bbbb
d111d11d333333b333333333333333333333333333333333333333b333333333333333b3333333b333333333333333333333333333333333333333333bbbbbb3
d111d11db33333b3333333333333333333333333333333333333333333333333333333333333333333333333333333333a3333333a3333333a33333333bbb333
d111d11d3b35553bb33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b3b33333b333333b3333333b33a3a333b3a3a333b3a3a333b33bbbbbb3
d111d11db35555333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b33333333b3333333b33a33333b3a33333b3a33333bb3b3bbbb
d111dddd3555555333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bb3bb3b3
d111d11d3554455b333333333333333333333333333333333333333333333333333333333333333333b3333333b33333333338333333383333333833bbbbbb3b
d111d11d554004533333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b3333b3333333b33333333b3838333b3838333b38383bb3b3bbb
ddddd11d55400455333b3333333b3333333b3333333b3333333b3333333b3333333b3333333b333333333b3333333b333b3338333b3338333b333833bbb3bbbb
d111d11d554004553333333333333333333333333333333333333333333333333333333333333333333333b3333333b33333333333333333333333333bbbbbb3
d111d11ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d111d1d11d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d111111
d111dd111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d111111
d111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d11d11111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d111
d1d111111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d111
dd1111111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d1111111d111
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__gff__
0004040000000202040404040404040400000000000000000404000004040004000000000000000004040404040400000000000000000000000000000000000001010100000000000108080404000000010101000000000001080800000000000101000000000001000000000000000000000000101010000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4240404040404040404040404040404140404040404040404040404040404041424040404040404040404040404040414240404040404040404040404040404142404040404040404040404040404041424040404040404040404040404040414240404040404040404040404040404142404040404040404040404040404041
60626262626262626262626262626250644343434343434354434343434374506076506262626262626262626262755060766262626262626262624862627550606262626262626262626262626262506075626262626262626262626262765060756262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250674343434354544354434343434343506062506262626262626262626262625060626262626262626262626161616161606262626262626262626262626262506061616161616161616161616161615060404048404040404040404040494950604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250674353434343544354434343434343506062486262626262626262626262625060626262626262626262624a62626250606262626262626262626262626262506076506262626262626262626262625060626262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250674343434343434354434343434343506062426161616161616161616161615060626262626262626262624a62626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250675443434344434354434343434343506062607662626262626262626262625060404040404040404040404162626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250674343434343534354544343434354506059606262626262626262626262625060626262626262626262766062626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250674343545443434354544343434343506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f3938383838384f4f4f4f50
60626262626262626262626262626250674354544343434354544343435343506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262626262506062506262626262626262626262625060616161616161616161616261616150604f4f4f4b4c4c4c4c4c4c4f4f4f4f50
60626262626262626262626262626250674343434343434354544343434343506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f3838383838384f4f4f4f50
60626262626262626262626262626250674344444343544354434343434343506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f4c4c4c4c4c4c4f4f4f4f50
60626262626262626262626262626250674343434443434354444343434343506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262626262506062506262626262626262626262765060756262626262626262626262626250604f4f4f4f3838383838384f4f4f4f50
60626262626262626262626262626250674354434344434354434343434343506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262626262506062506262626262626262626262625060626262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250675443434353434354434343434343506062606262626262626262626262626262626262626262626262626062626250606262626262626262626262624040506062506262626262626262626262625060616161616161616161616161616150604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
60626262626262626262626262626250674354434343434354434343434353506062606262626262626262626262625060626262626262626262626062626250606262626262626262626262624876506062486262626262626262626262624a5a626262626262626262626262626250604f4f4f4f4f4f4f4f4f4f4f4f4f4f50
5261616161616148486161616161615167444343435443434354434343434350526161616161616161616161616161515261616161616161616161616161615152616161616161616161616161616151526161616161616161616161616161616161616161616161616161616161615152616161616161616161616161616151
606767676767674343676767676767676767676767672e676767676767676750424040404040404040404040404040414240404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040414240404040404040404040404040404142404040404040404040404040404041
6054435343436754546743434343436767544343544353435454544343434350606a6a6a6a6a6a6a6a6a6a6a6a6a6a506075626262626268686868686868626262626262626262626262626262626262626268686868686868626262626276506062625a626262625a625a6262626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6054545454546754546754545454546767434354434343545454544343435450606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060626262626262626262626262626262626262686868686868686862626262626262626262626262626262626262625060626262626262625a625a625a626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6043434343436743436743435454546767435843434343435843434343545450606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161615060626262625a62625a625a625a626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6043434443434343434343434343436767434367674343434343546767434350606a6a6a6a6a6a6a6a6a6a6a6a6a6a50606262626262626262625a626262625060686868686868686868686868686250606262626262626262606868626276506062625a625a62625a625a625a626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6043534343434343434343434443436767434367674344444343436767434350606a6a6a6a6a6a6a6a6a6a6a6a6a6a506062624240404040404041626262625060686868686868686868686868686250606262626262626262606868626262506062625a625a62625a6262625a626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6043434343434343434343434343436767434343584343434343434343434350606a6a6a6a6a6a6a6a6a6a6a6a6a6a506062626062626262626250626262625060686868686868686868686868686250606262626262626262606868626262506062625a625a62625a5a62625a626250602e2e2e2e2ec0c1c2c32e2e2e2e2e50
6043435343434344434343435343436767435343434343676743434343434350606a6a6a6a6a6a6a6a6a6a6a6a6a6a506062626062626262626250626262625060686868686868686868686868686250604949404040404040606868626262506062625a625a6262625a626262626250602e2e2e2e2ed0d1d2d32e2e2e2e2e50
6043434343434343434343435454436767544343434344676743534343434350606a6a6a6a6a6a6a6a6a6a6a6a6a6a506062626040404041626250626262625060686868686868686868686868686250606262626262626262606868626262506062625a62626262625a626262626250602e2e2e2e2ee0e1e2e32e2e2e2e2e50
6054544354545443434343545454436767435454545454434343535443444350606a6a6a6a6a6a6a6a6a6a6a6a6a6a506062626062626250626250626262626262626262626262626262626262626250606262626262626262606868626262506062625a62626262625a6262625a6250602e2e2e2e2ef0f1f2f32e2e2e2e2e50
6043544454545443434354545454446767544343434354545454535354544450606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060626260626262506262506262626250606868686868686868686868686862506062626262626262626068686262625060626262625a62625a5a625a625a6250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6043545443544353544354435454442e43434367675454544444446767535350606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060626260626262506262506262626250606868686868686868686868686862506062626262626262626068686262625060626262625a62625a62625a625a6262602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6043435354434354545444534444444843545467674444545454446767444450606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060626252616161516262506262626250606868686868686868686868686862506062626262626262626068686262625060494949625a62625a62625a625a6250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6054434443435444545443434343436767544354444354544353444343545350606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060626262626262626262504040402e5060686868686868686868686868686250606262626262626262626868626262506062625a625a62625a62625a62626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
6074434343434343434354544444446767444444444444444444444444447450606a6a6a6a6a6a6a6a6a6a6a6a6a6a5060626262626262626262507562626250606868686868686868686868686862622e6262626262626262626868626262506076625a626262625a62625a62626250602e2e2e2e2e2e2e2e2e2e2e2e2e2e50
5261616161616161616161616161616161616161616161616161616161616151526161616161616161616161616161515261616161616161616161616161615152616161616161616161616161616161616161616161616161616161616161515261616161616161616161616161615152616161616161616161616161616151
__sfx__
0101000000750007500175002750027500375004750057500675006750097500b7500d7500f7501275015750197501d7501a7501d7501f7502175025750277502a7502d750307503475035750397503b7503d750
001400002d05025050210501905018050110500f0500d0500305003050030500305004050040500305003050030500305002050020500105001050010500105001050020500e5000f500105000e5000c50008500
0002000028050240502605022050200501c0501805014050120500f0500e0500e0500e0500e050000502950000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000143001235015350173501c3002050019600000001c60007600017001f600226000170024600276002b6002c600000000000000700000000070009600007000a6000b6000070000000000000000000000
00030000133501e3502c350363501c6001a1001a1001a1001b100000001d100000001f10022100286002b60000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000037600316302e6302a6302a600376003760025650226501d6501e6001e6003260016650126500e6501660013600126000f6000000000000000002f6002f6002f6002f6002f6002f600000000000000000
011000000c0430c0432460024615246001b3133f2003f2150c0430c0433f2001b313246150c0003f2150c04324615246151b3133f2000c0430c0433f2153f2003f2153f2001b3131b313246000c043246153f200
011000200c0430420004200042000c04304200042000420010043043000430004300100430430004300043000e0430440004400044000e0430440004400044001104310100045000450011043045000450004500
01100020021400e020021100e040021200e010021400e020051101104005120110100514011010051401101004120100100414010020041101004004120100100714013020071101304007140130100714013010
01100020046000c7400c7430c744000000e7400e7430e74400000117401174311744000000c7400c7430c74400000137401374313744000000e7400e7430e74400000107401074310744000000d7400d7430d744
012000000c043041200e01002140110230711010040041200e01302140100200511011043001200e01002140110230511011040021200c0130214010020051100504313120050101014011123101100e1400c120
011000001001513025170151304510025130151704513025100151304517025130151004513025170151304510025170151304510025170151304510025170151304510025180151504511025180151504511025
011000001074513723177431372310745137231774313723107451372317743137231074513723177431372310745177231374310723177451372310743177431372510743187231574311725187431572311743
001000001053410534135341353411534115340e5340e534105341053415534155340e5340e5340c5340c534105341053417534175341553415534115341153410534105340e5340e53413534135341053410534
__music__
01 07084944
02 07084944
01 070b4344
01 070b080c
00 41424344
01 0a074344
02 0a074344
01 0b0c4344
03 0b0c0d44

