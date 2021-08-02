shader_type spatial;
render_mode unshaded,depth_draw_alpha_prepass,world_vertex_coords;


uniform bool active = true;
uniform float sky_energy  : hint_range(0, 1) = 0.048;
uniform mat3 camera_basis = mat3(1.0);
uniform vec3 camera_global_position;

uniform sampler2D texture_here;
/*
uniform vec3 camera_bend = vec3(1.0,0.0,0.0);
uniform vec3 camera_up = vec3(0.0,1.0,0.0);
uniform vec3 camera_direction = vec3(0.0,0.0,1.0);
*/
const float PI = 3.14159265f;
const int BOUNCE = 8;


/*
vec3 ro
vec3 rd
vec3 re
*/
void CreateRay(vec3 origin, vec3 direction, inout vec3 ray_origin,inout vec3 ray_direction,inout vec3 ray_energy)
{
    ray_origin = origin;
    ray_direction = direction;
    ray_energy = vec3(1.0, 1.0, 1.0);
}

void CreateCameraRay(vec2 vps, vec2 coord,inout vec3 ray_origin,inout vec3 ray_direction,inout vec3 ray_energy)
{
	/*
    vec2 uv = (coord * 2.0 - iResolution.xy) / iResolution.y;
	vec2 mo = iMouse.xy / iResolution.y * 3.5;
    if (mo == vec2(0)) mo = vec2(0,1.75);
	*/
	//vec2 uv = (coord * 2.0 - VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.y;
	
	vec2 uv = (coord * 2.0 - vps)/(vps.y);
	//uv = uv/1.60;
    vec3 ro = -camera_global_position;
/*
    vec3 z = camera_direction;//normalize(camera_direction);
	vec3 y = camera_up;
    vec3 x = camera_bend;//normalize(cross(y,z));
*/
	////vec3 z = camera_basis[2];
	////vec3 y = camera_basis[1];
    ////vec3 x = camera_basis[0];//normalize(cross(y,z));
	//vec3 x = camera_bend;
    //vec3 rd = mat3(x, cross(z, x), z) * vec3(uv.x,1.0-uv.y, 1.0);// uv=UV
	//vec3 rd = mat3(x, cross(z, x), z) * vec3(uv, -1.0);//uv=SCREEN_UV
	//vec3 rd = mat3(x, cross(z, x), z) * vec3(uv,1.0);//fragcoord
	
	//vec3 rd = mat3(x, y, z) * vec3(-uv.x,-uv.y,1.0);//fragcoord
	
	
	////vec3 rd = mat3(x, y, z) * vec3(-uv,1.0);//fragcoord
	vec3 rd = camera_basis * vec3(-uv,1.0);//fragcoord
	
	//vec3 rd = camera_basis * vec3(uv.x,uv.y,1.0);//fragcoord
	//vec3 rd = mat3(camera_transfrom[0],camera_transfrom[1],z) * vec3(uv,1.0);//fragcoord
	rd = normalize(rd);
    CreateRay(ro, rd,ray_origin, ray_direction, ray_energy);
}
/*
struct RayHit
{
    vec3 position;
    float distance;
    vec3 normal;
};
*/
void CreateRayHit(inout vec3 hit_position,inout float hit_distance,inout vec3 hit_normal)
{
    //RayHit hit;
    hit_position = vec3(0.0f, 0.0f, 0.0f);
    hit_distance = 9900.0;
    hit_normal = vec3(0.0f, 0.0f, 0.0f);
    //return hit;
}

void IntersectGroundPlane(vec3 ray_origin, vec3 ray_direction, inout vec3 bestHit_position,inout float bestHit_distance,inout vec3 bestHit_normal, vec3 pn, float pd)
{
    
    // Calculate distance along the ray where the ground plane is intersected
    float denominator = dot(ray_direction, pn);
    float t = -(dot(ray_origin, pn) + pd) / denominator;

    if (t > 0.0 && t < bestHit_distance)
    {
        bestHit_distance = t;
        bestHit_position = ray_origin + t * ray_direction;
        bestHit_normal = pn;
    }
}

void IntersectSphere(vec3 ray_origin, vec3 ray_direction, inout vec3 bestHit_position,inout float bestHit_distance,inout vec3 bestHit_normal, vec4 sphere)
{

    float t = -1.0;
    float a = dot(ray_direction, ray_direction);
    vec3 s0_r0 = ray_origin - sphere.xyz;
    float b = 2.0 * dot(ray_direction, s0_r0);
    float c = dot(s0_r0, s0_r0) - (sphere.a * sphere.a);
    if (!(b*b - 4.0*a*c < 0.0)) {
        t = (-b - sqrt((b*b) - 4.0*a*c))/(2.0*a);
    }

    if (t > 0.0 && t < bestHit_distance)
    {
        bestHit_distance = t;
        bestHit_position = ray_origin + t * ray_direction;
        bestHit_normal = normalize(bestHit_position - sphere.xyz);
    }
}
/*
const vec4 groundplane = vec4(0.0,-1.0,0.0,10.0);//normal vector.xyz,distance from origin
//const vec4 groundplane2 = vec4(0.58,0.99,0.0,7.0); //45° angle
//const vec4 groundplane2 = vec4(1.0,0.0,0.0,7.0); //90° angle
const vec4 sphere1 = vec4(0.0,0.0,0.0,1.0);//position.xyz, radius
const vec4 sphere2 = vec4(-7.0,0.0,0.0,5.0);
const vec4 sphere3 = vec4(5.0,4.0,-10.0,3.0);
*/

const vec4 groundplane = vec4(0.0,-1.0,0.0,10.0);//normal vector.xyz,distance from origin
const vec4 sphere1 = vec4(0.0,0.0,0.0,1.0);//position.xyz, radius
//const vec4 sphere2 = vec4(-sphere_o,5.0);
uniform vec3 sphere_o = vec3(0.0);
uniform vec3 sphere_o1 = vec3(0.0);
uniform vec3 sphere_o2 = vec3(0.0);
uniform vec3 sphere_o3 = vec3(0.0);
uniform vec3 sphere_o4 = vec3(0.0);

const vec4 sphere3 = vec4(5.0,4.0,-10.0,3.0);
void Trace(vec3 ray_origin,vec3 ray_direction,vec3 ray_energy,out vec3 bestHit_position,out float bestHit_distance,out vec3 bestHit_normal)
{
    CreateRayHit(bestHit_position, bestHit_distance, bestHit_normal);
	
	IntersectGroundPlane(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, groundplane.xyz, groundplane.a);
    //IntersectGroundPlane(ray, bestHit,groundplane.xyz,groundplane.a);
   
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, sphere1);
    //IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, sphere2);
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, vec4(-sphere_o.xyz,5.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, vec4(-sphere_o1.xyz,5.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, vec4(-sphere_o2.xyz,5.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, vec4(-sphere_o3.xyz,5.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, vec4(-sphere_o4.xyz,5.0));
	
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, sphere3);

	//IntersectGroundPlane(ray, bestHit,groundplane2.xyz,groundplane2.a);

}



vec3 Shade(inout vec3 ray_origin,inout vec3 ray_direction,inout vec3 ray_energy, vec3 hit_position,float hit_distance,vec3 hit_normal)
{
    if (hit_distance < 9900.0)
    {
        vec3 specular = vec3(1.0f, 0.78f, 0.34f);//shinny gold
        
        
        // Reflect the ray and multiply energy with specular reflection
        ray_origin = hit_position + hit_normal * 0.001f;
        ray_direction = reflect(ray_direction, hit_normal);
        ray_energy *= specular;
        
        //color
        return vec3(0.0, 0.0, 0.0);// Return nothing/ silver
        //return vec3(1.0f, 0.78f, 0.34f);//gold
        //return vec3(0.0, 0.0, 1.0);// blue

        // Return the normal/ rainbow
        //return hit_normal;
        //return hit_normal * 0.5f + 0.5f;

        
    }
    else
    {
        // Erase the ray's energy - the sky doesn't reflect anything
        ray_energy = vec3(sky_energy);
/*
        //For 2D texture only
        float theta = acos(ray.direction.y) / -PI;
        float phi = atan(ray.direction.x, -ray.direction.z) / -PI * 0.5f;
        return texture(iChannel0, vec2(phi, theta)).xyz;
*/
        //return texture(texture_here, ray_direction).xyz;//texture
        //return ray_direction* 0.5 + 0.5;//uv rainbow
		
		float theta = acos(ray_direction.y) / -PI;
		float phi = atan(ray_direction.x, ray_direction.z) / -PI * 0.5f;
		//ALBEDO = textureLod(texture_here,vec2(phi,theta),0).xyz;
		return textureLod(texture_here,vec2(phi,theta),0).xyz*0.50;//needs to be textureLod else wierd line appears in sample
    }
}






void vertex() {
COLOR = vec4(VERTEX,1.0);
}


void fragment() {
	if(active){
	vec3 ray_origin;
	vec3 ray_direction;
	vec3 ray_energy;
	vec3 hit_position;
	float hit_distance;
	vec3 hit_normal;
	//CreateCameraRay(SCREEN_UV,ray_origin,ray_direction,ray_energy);
	//CreateCameraRay(UV,ray_origin,ray_direction,ray_energy);
	CreateCameraRay(VIEWPORT_SIZE,FRAGCOORD.xy,ray_origin,ray_direction,ray_energy);
	

    
    vec3 result = vec3(0.0, 0.0, 0.0);
    
    for (int i = 0; i < BOUNCE; i++)
    {
		//vec3 hit_position;float hit_distance;vec3 hit_normal;
        Trace(ray_origin,ray_direction,ray_energy,hit_position,hit_distance,hit_normal);
        result += ray_energy * Shade(ray_origin,ray_direction,ray_energy, hit_position,hit_distance,hit_normal);
        if (!any(greaterThan(ray_energy,vec3(0.001)))) break;    
    }
	ALBEDO = result;
	ALPHA = 1.80;
}
	/*
    //ALBEDO = result;
	float theta = acos(ray_direction.y) / PI;
	float phi = atan(ray_direction.x, ray_direction.z) / PI * 0.5f;
	//ALBEDO = textureLod(texture_here,vec2(phi,theta),0).xyz;
	ALBEDO = textureLod(texture_here,vec2(phi,theta),0).xyz*10.0;//needs to be textureLod else wierd line appears in sample
	*/
	/*
	vec3 result = vec3(0.0, 0.0, 0.0);
	Trace(ray_origin,ray_direction,ray_energy,hit_position,hit_distance,hit_normal);
    result += ray_energy * Shade(ray_origin,ray_direction,ray_energy, hit_position,hit_distance,hit_normal);
	ALBEDO = result;
	*/
/*
float sprite_uv_h = sprite_h / screen_h;
vec2 flipped_screen_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - sprite_uv_h * (1.0 - 2.0 * UV.y));
ALBEDO = flipped_screen_uv;
	//ALBEDO = texture(results, UV).rgb;
*/

	
}

