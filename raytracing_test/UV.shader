shader_type spatial;
render_mode unshaded,depth_draw_alpha_prepass;//,blend_mix,world_vertex_coords;

uniform sampler2D view;
void fragment(){
	//ALBEDO = vec3(0.0,1.0,0.0);
	//ALBEDO = vec3(SCREEN_UV,0.0);
	vec4 albedo_tex = texture(view, UV);
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;

}