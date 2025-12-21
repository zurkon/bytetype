shader_type canvas_item;

uniform vec2 resolution = vec2(600.0, 400.0);
uniform vec3 bg_color: source_color = vec3(0.04, 0.09, 0.16);
uniform vec3 line_color: source_color = vec3(0.2, 0.3, 0.5);
uniform float scroll_speed: hint_range(0.0, 4.0, 0.1) = 1.0;
uniform float zoom: hint_range(1.0, 50.0, 0.1) = 20.0;
uniform float thickness: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float brightness: hint_range(0.1, 4.0, 0.1) = 2.0;

float draw_grid(vec2 uv) {
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	
	// compute time-based offset (wrap to keep tiling seamless)
	vec2 dir = normalize(vec2(1.0, 1.0));
	float t = TIME * scroll_speed;
	// Scale offset by zoom so scrolling matches grid density
	vec2 offs = dir * t / zoom;
	// Apply offset in UV space
	vec2 uv_off = (uv + offs) * zoom;
	//vec2 uv_off = uv * zoom + vec2(offs.x, offs.y * (resolution.y / resolution.x));
	
	float line_thickness = zoom * thickness / resolution.y;
	float mask = smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv_off));
	vec3 grid_col = line_color * brightness;
	vec3 final = mix(bg_color, grid_col, mask * 1.0); // 1.0 is opacity
	
	COLOR = vec4(final, 1.0);
}
