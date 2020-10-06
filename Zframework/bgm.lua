local min=math.min
local rem=table.remove

local function fadeOut(id)
	local src=BGM.list[id]
	local v=src:getVolume()-.025*setting.bgm
	src:setVolume(v>0 and v or 0)
	if v<=0 then
		src:stop()
		return true
	end
end
local function fadeIn(id)
	local src=BGM.list[id]
	local v=setting.bgm
	v=min(v,src:getVolume()+.025*v)
	src:setVolume(v)
	if v>=setting.bgm then return true end
end

local BGM={
	--nowPlay=[str:playing ID]
	--suspend=[str:pausing ID]
	--playing=[src:playing SRC]
}
BGM.list={
	"blank",
	"race","push","way","reason",
	"newera","oxygen","infinite","down",
	"secret7th","secret8th",
	"waterfall","shining terminal","distortion","far",
	"rockblock","cruelty","final","8-bit happiness","end",
	"how feeling",
}
BGM.len=#BGM.list
function BGM.loadOne(N)
	N=BGM.list[N]
	local file="/BGM/"..N..".ogg"
	if love.filesystem.getInfo(file)then
		BGM.list[N]=love.audio.newSource(file,"stream")
		BGM.list[N]:setLooping(true)
		BGM.list[N]:setVolume(0)
	else
		LOG.print("No BGM file: "..N,"warn")
	end
end
function BGM.loadAll()
	for i=1,#BGM.list do
		BGM.loadOne(i)
	end
end
function BGM.play(s)
	if setting.bgm==0 then
		BGM.playing=BGM.list[s]
		BGM.suspend,BGM.nowPlay=s
		return
	elseif not(s and BGM.list[s])then
		return
	end
	if BGM.nowPlay~=s then
		if BGM.nowPlay then TASK.new(fadeOut,BGM.nowPlay)end
		TASK.changeCode(fadeIn,fadeOut)
		TASK.removeTask_data(s)

		BGM.nowPlay,BGM.suspend=s
		TASK.new(fadeIn,s)
		BGM.playing=BGM.list[s]
		BGM.playing:play()
	end
end
function BGM.freshVolume()
	if BGM.playing then
		local v=setting.bgm
		if v>0 then
			BGM.playing:setVolume(v)
			if BGM.suspend then
				BGM.playing:play()
				BGM.nowPlay,BGM.suspend=BGM.suspend
			end
		else
			if BGM.nowPlay then
				BGM.playing:pause()
				BGM.suspend,BGM.nowPlay=BGM.nowPlay
			end
		end
	end
end
function BGM.stop()
	if BGM.nowPlay then
		TASK.new(fadeOut,BGM.nowPlay)
	end
	TASK.changeCode(fadeIn,fadeOut)
	BGM.playing,BGM.nowPlay=nil
end
return BGM