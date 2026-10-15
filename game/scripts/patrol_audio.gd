extends RefCounted
static func shutter() -> AudioStreamWAV:
	var rate:=22050
	var samples:=PackedByteArray()
	var rng:=RandomNumberGenerator.new();rng.seed=27191
	for index in range(int(rate*.16)):
		var t:=float(index)/rate
		var hit:=exp(-t*95.0)
		var release:=exp(-maxf(t-.055,0)*140.0) if t>=.055 else 0.0
		var signal_value:=rng.randf_range(-1,1)*(.38*hit+.24*release)+sin(t*TAU*1600)*hit*.13
		var value:=int(clampf(signal_value,-1,1)*32767)
		samples.append(value & 255);samples.append((value>>8)&255)
	var stream:=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=rate
	stream.data=samples
	return stream
static func play_shutter(parent:Node) -> void:
	var player:=AudioStreamPlayer.new()
	player.stream=shutter()
	player.volume_db=-10
	parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
