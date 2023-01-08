shader_type canvas_item;
uniform vec4 outline_color;

void fragment() {
	vec2 p = UV / TEXTURE_PIXEL_SIZE;
	vec4 col = texture(TEXTURE, UV);
	if (col.a < 0.9)
	for (float x = p.x - 2.0; x <= p.x + 2.0; x += 1.0) {
		for (float y = p.y - 2.0; y <= p.y + 2.0; y += 1.0) {
			if (texture(TEXTURE, vec2(x,y) * TEXTURE_PIXEL_SIZE).a > 0.5) {
				col = outline_color;
			}
		}
	}
	COLOR = col;
}