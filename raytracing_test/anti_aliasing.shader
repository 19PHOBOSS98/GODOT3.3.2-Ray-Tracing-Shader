shader_type canvas_item;
render_mode unshaded;
uniform float Sample;
uniform sampler2D view;
void fragment(){

	    COLOR = vec4(texture(view, -UV).rgb, 1.0f / (Sample + 1.0f));

}