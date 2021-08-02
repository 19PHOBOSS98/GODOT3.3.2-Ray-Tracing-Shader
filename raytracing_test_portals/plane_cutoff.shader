shader_type spatial;
render_mode depth_draw_alpha_prepass,cull_disabled,world_vertex_coords;

uniform bool passing_thru = false;//set to true if passing thru a portal
uniform vec3 Portal_Global_Origin;
uniform vec3 Portal_Rotation;
uniform sampler2D texture_here;
varying float y_f;

void vertex() {
	if(passing_thru){
		//I only used matrix multiplication cause it's easy to read and it shortens the code
		//I'm not really sure if it speeds things up
		mat2 z_tensor = mat2(vec2(0,0) , vec2(-sin(radians(Portal_Rotation.z)),cos(radians(Portal_Rotation.z))));	//I used empty vec2s cause I don't need them in the calculation
		mat2 x_tensor = mat2(vec2(0,0) , vec2(sin(radians(Portal_Rotation.x)),cos(radians(Portal_Rotation.x))));	//it skips calculating sines and radians but I don't think it saves the gpu from doing matrix multiplication
		mat2 y_tensor = mat2(vec2(cos(radians(Portal_Rotation.y)),-sin(radians(Portal_Rotation.y))) , vec2(sin(radians(Portal_Rotation.y)),cos(radians(Portal_Rotation.y))));

//		vec3 world_position = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;	// transforms vertices from model space to world space
//		vec3 world_position = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;	// transforms vertices from view space to world space (for visual shader)
		vec3 world_position = VERTEX;	//must have "world_vertex_coords" enabled as render mode for this to work

		vec3 offset_origin = world_position - Portal_Global_Origin;
		vec2 theta_y = offset_origin.xz * y_tensor;

		vec2 theta_x_input = vec2(theta_y.y,offset_origin.y);//theta_y.y is theta_y's Z output
		vec2 theta_x = theta_x_input * x_tensor;
		vec2 theta_z_input = vec2(theta_y.x,theta_x.y);
		vec2 theta_z = theta_z_input * z_tensor;
		y_f = theta_z.y;

		y_f =  1.0 - y_f;// the ALPHA_SCISSOR is a bit wierd since it's threshold is 1.0 instead of 0.0 like ALPHA
		//and its values are inverted so I had to subtract y_f FROM 1

		}
	}


void fragment() {
	if(passing_thru){

		ALPHA_SCISSOR = y_f;
	}

	ALBEDO = texture(texture_here, UV).rgb;
	//the texture might be a little faded
	// you need to set it to use "color" instead of "data"
	//how? idk, look into "texture uniform"
	// happy coding!

	
}

