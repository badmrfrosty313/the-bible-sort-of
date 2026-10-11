extends RefCounted
class_name RuntimeTexture
## Imported textures are preferred; source decoding also survives a broken local cache.

static func image_is_visible(image: Image) -> bool:
	return image != null and not image.is_empty() and image.get_width() > 0 and image.get_height() > 0 and image.get_used_rect().has_area()

static func load_texture(path: String, expected_size := Vector2i.ZERO) -> Texture2D:
	var texture: Texture2D
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	if texture != null:
		var image := texture.get_image()
		if image_is_visible(image) and (expected_size == Vector2i.ZERO or image.get_size() == expected_size):
			return texture
	# No static image preload: missing imports must not prevent a scene/script loading.
	var source := Image.new()
	if source.load(path) == OK and image_is_visible(source) and (expected_size == Vector2i.ZERO or source.get_size() == expected_size):
		push_warning("Imported texture unavailable; decoded source directly: " + path)
		return ImageTexture.create_from_image(source)
	push_warning("REQUIRED ART UNAVAILABLE: " + path + " — visible fallback enabled")
	return null
