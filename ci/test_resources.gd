extends SceneTree

const REQUIRED := {
	"res://art/title/gods_beach_day_adams_tumble.png": Vector2i(1672, 941),
	"res://art/characters/adam/adam_leaves_walk.png": Vector2i(256, 256),
	"res://art/characters/eve/eve_leaves_walk.png": Vector2i(256, 256),
	"res://art/characters/god/god_walk.png": Vector2i(256, 256),
}

func _initialize() -> void:
	var failures := 0
	for path in REQUIRED:
		var texture: Texture2D
		if ResourceLoader.exists(path):
			texture = load(path) as Texture2D
		var image := texture.get_image() if texture != null else null
		if not RuntimeTexture.image_is_visible(image) or image.get_size() != REQUIRED[path]:
			printerr("FAIL: Imported required image: ", path)
			failures += 1
		else:
			print("PASS: Imported visible image ", path, " ", image.get_size())
			if path.contains("characters"):
				for row in 4:
					for column in 4:
						if not image.get_region(Rect2i(column * 64, row * 64, 64, 64)).get_used_rect().has_area():
							printerr("FAIL: Empty actor frame ", path, " ", row, ",", column)
							failures += 1
	quit(0 if failures == 0 else 1)
