/*
PUT THIS ON A PLANE MESH
AND TAPE IT INFRONT OF YOUR PERSON'S CAMERA

or tape it onto somewhere else like a door frame or a picture...
just imagine having a lowrez game and then suddenly the game shows you this room with Ray Tracing XD 
just have an "RTX on" png overlay on the corner of the screen

otherwise you could try and convert this into a canvas 2D shader and stick it on the camera's viewport like that...
I wouldn't recommend you doing that actually
just wait for Godot 4 it would be way easier
*/




shader_type spatial;
render_mode unshaded,depth_draw_alpha_prepass,world_vertex_coords;

uniform bool active = true; // on/off switch for entire shader

uniform bool shadow = false; //enables shadows & directional lighting

uniform float d_light_energy : hint_range(0, 16) = 1.0; //directional light energy
uniform vec3 d_light_dir = vec3(0.0,0.0,1.0); //directional light vector (global_transform.basis.z)... you don't need an actual directional light object. I used a 3DPoint and it works just fine

uniform int mat:hint_range(0, 3) = 0;//for switching between albedo and specular material setup
//0 = dark grey for directional lighting demo
//1 = default chrome
//2 = gold
//3 = individual albedo and specular material

uniform float sky_energy  : hint_range(0, 16) = 1.0; //skybox brightness
uniform mat3 camera_basis = mat3(1.0); //connect real world camera global_transform.basis here
uniform vec3 camera_global_position; //connect real world camera global_transform.origin here

uniform sampler2D texture_here; //2D skybox image here


const float PI = 3.14159265f;
const int BOUNCE = 7; //light bounce count

const vec4 groundplane = vec4(0.0,-1.0,0.0,10.0); //vec4(normal_vector.xyz,distance from origin along normal_vector)
const vec4 sphere1 = vec4(0.0,0.0,0.0,1.0); //vec4(global_transform.origin.xyz, radius)
const vec4 sphere3 = vec4(5.0,5.50,-10.0,3.0);

// wouldn't need these if I had Writable GPU Data Buffers :(
uniform vec3 sphere_o = vec3(0.0);
uniform vec3 sphere_o1 = vec3(0.0);
uniform vec3 sphere_o2 = vec3(0.0);
uniform vec3 sphere_o3 = vec3(0.0);
uniform vec3 sphere_o4 = vec3(0.0);
uniform vec3 sphere_o5 = vec3(0.0);
uniform vec3 sphere_o7 = vec3(0.0);
uniform vec3 sphere_o8 = vec3(0.0);
uniform vec3 sphere_o9 = vec3(0.0);
uniform vec3 sphere_o10 = vec3(0.0);
uniform vec3 sphere_o11 = vec3(0.0);

uniform vec2 PixelOffset = vec2(0f);
/*

the tutorial used structures to create Rays.

struct Ray
{
    float3 origin;
    float3 direction;
};

Godot 3 doesn't "support" structures (see what I-)
so, as a painful substitute, I used "inout" qualifiers to pass on "structure" values instead
I mean it works but the code could have been a lot shorter:

Ray CreateRay(float3 origin, float3 direction)
{
    Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    return ray;
}

and that's just ONE of the reasons why I do NOT recommend what I'm doing
*/

void CreateRay(vec3 origin, vec3 direction, inout vec3 ray_origin, inout vec3 ray_direction, inout vec3 ray_energy)
{
    ray_origin = origin;
    ray_direction = direction;
    ray_energy = vec3(1.0, 1.0, 1.0);
}

//this creates a bunch of rays from your camera origin impaling your whole entire screen out to the virtual world
void CreateCameraRay(vec2 vps, vec2 coord,inout vec3 ray_origin,inout vec3 ray_direction,inout vec3 ray_energy)
{

	vec2 uv = (coord * 2.0 - vps)/(vps.y);
    vec3 ro = -camera_global_position;

	vec3 rd = camera_basis * vec3(-uv,1.0);
	

	rd = normalize(rd);
    CreateRay(ro, rd,ray_origin, ray_direction, ray_energy);
}
/*
initialises a "RayHit", basically 
where a ray hits (position), 
how far from the camera it hit something (distance), 
the surface normal ,
and the color (albedo) and shine(specular) of the surface it hit
*/
void CreateRayHit(inout vec3 hit_position,inout float hit_distance,inout vec3 hit_normal,inout vec3 hit_albedo,inout vec3 hit_specular)
{

    hit_position = vec3(0.0f, 0.0f, 0.0f);
    hit_distance = 9999.0;
    hit_normal = vec3(0.0f, 0.0f, 0.0f);
	hit_albedo = vec3(0.0f, 0.0f, 0.0f);
	hit_specular = vec3(0.0f, 0.0f, 0.0f);

}

//checks if a ray hits an infinite plane

void IntersectGroundPlane(vec3 ray_origin, vec3 ray_direction, inout vec3 bestHit_position,inout float bestHit_distance,inout vec3 bestHit_normal,inout vec3 bestHit_albedo, inout vec3 bestHit_specular, vec3 pn, float pd,vec3 plane_albedo,vec3 plane_specular)
{
    
    // Calculate distance along the ray where the ground plane is intersected
    float denominator = dot(ray_direction, pn);
    float t = -(dot(ray_origin, pn) + pd) / denominator;

    if (t > 0.0 && t < bestHit_distance)
    {
        bestHit_distance = t;
        bestHit_position = ray_origin + t * ray_direction;
        bestHit_normal = pn;
		bestHit_albedo = plane_albedo;
		bestHit_specular = plane_specular;
    }
}

//checks if a ray hits a sphere

void IntersectSphere(vec3 ray_origin, vec3 ray_direction, inout vec3 bestHit_position,inout float bestHit_distance,inout vec3 bestHit_normal,inout vec3 bestHit_albedo, inout vec3 bestHit_specular, vec4 sphere,vec3 sphere_albedo,vec3 sphere_specular)
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
		bestHit_albedo = sphere_albedo;
		bestHit_specular = sphere_specular;
    }
}


/*
Here's where I tried to make constant arrays for defining individual material properties
Returns ERROR: Expected initialization of constants

const vec3 sphere_albedo[]={vec3(0.0,1.0,0.0),vec3(1.0, 0.78, 0.34),sphere_o1,vec3(0.20, 1.1, 0.80),vec3(1.0, 0.3, 0.84),vec3(0.0, 0.0, 0.0)};
const vec3 sphere_specular[]={vec3(0.04,0.04,0.04),vec3(1.0, 0.78, 0.34),sphere_o1,vec3(0.20, 1.1, 0.50),vec3(1.0, 0.3, 0.84),vec3(0.7, 0.7, 0.7)};

*/

//Traces each ray through the environment checking if it hits something along the way and adjusting color, lighting etc. accordingly

void Trace(vec3 ray_origin,vec3 ray_direction,vec3 ray_energy,out vec3 bestHit_position,out float bestHit_distance,out vec3 bestHit_normal,out vec3 bestHit_albedo,out vec3 bestHit_specular)
{
/*	
	this would have been way better with a for loop 
	but seeing that GPU Data buffers are still coming soon 
	and arrays are under renovation 
	I think this is good enough for now
*/
	CreateRayHit(bestHit_position, bestHit_distance, bestHit_normal,bestHit_albedo, bestHit_specular);
	
	IntersectGroundPlane(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal,bestHit_albedo,bestHit_specular, groundplane.xyz, groundplane.a,vec3(0.80,0.80,0.80),vec3(0.4));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, sphere1,vec3(0.0),vec3(0.6));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, sphere3,sphere3.xyz,vec3(0.04));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o.xyz,5.0),vec3(0.0, 0.0, 0.0),vec3(1.0, 0.78, 0.34));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o1.xyz,3.0),vec3(0.0, 0.0, 0.0),vec3(0.0, 1.0, 0.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o2.xyz,5.0),vec3(0.20, 0.78, 0.84),vec3(0.20, 0.78, 0.84));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o3.xyz,5.0),vec3(0.80, 0.10, 0.0),vec3(0.80, 0.10, 0.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o4.xyz,5.0),vec3(0.01, 0.0, 1.0),vec3(0.01, 0.0, 1.0));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o8.xyz,7.0),vec3(1f, 0.0, 0.0),vec3(1f, 0f, 0f));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o9.xyz,10.0),vec3(0.0157, 0.3882,0.0275),vec3(0.0157, 0.3882,0.0275));
	IntersectSphere(ray_origin, ray_direction, bestHit_position, bestHit_distance, bestHit_normal, bestHit_albedo, bestHit_specular, vec4(-sphere_o10.xyz,10.0),vec3(0.3f, 0f, 1f),vec3(0.3f, 0f, 1.0));
}

// here's where everything on the screen is coloured in

vec3 Shade(inout vec3 ray_origin,inout vec3 ray_direction,inout vec3 ray_energy, vec3 hit_position,float hit_distance,vec3 hit_normal,vec3 hit_albedo,vec3 hit_specular)
{
	
    if (hit_distance < 9900.0)// basically when a ray hits something
    {
        // Reflect the ray and multiply energy with specular reflection
        vec3 specular;
		vec3 albedo;
		if(mat == 0){
			specular = vec3(0.04);//shaded
			//vec3 albedo = vec3(0.0,0.0,0.70);//blue
			albedo = vec3(0.80);//gray
		}
		else if(mat == 1){//default
			specular = vec3(0.6);
			albedo = vec3(1.0);
		}
		else if(mat == 2){
			specular = vec3(1.0f, 0.78f, 0.34f);//shinny gold
			albedo = vec3(1.0f, 0.78f, 0.34f);
		}
		else if(mat == 3){
			specular = hit_specular;
			albedo = hit_albedo;
		}


		ray_origin = hit_position + hit_normal * 0.001f; // have to offset the ray origin a little to stop the ray from getting caught behind the surface it's suppose to bounce off of
       	ray_direction = reflect(ray_direction, hit_normal);
       	ray_energy *= specular;
		
		if(shadow)// surprisingly shadows are their own rays but backwards
		{
			vec3 shadowRay_origin;
			vec3 shadowRay_direction;
			vec3 shadowRay_energy;
			
			CreateRay(ray_origin,-d_light_dir, shadowRay_origin, shadowRay_direction, shadowRay_energy);
			
			vec3 shadowHit_position;
			float shadowHit_distance;
			vec3 shadowHit_normal;
			vec3 shadowHit_albedo;
			vec3 shadowHit_specular;
			
			Trace(shadowRay_origin,shadowRay_direction,shadowRay_energy,shadowHit_position,shadowHit_distance,shadowHit_normal,shadowHit_albedo,shadowHit_specular);

			if (!(shadowHit_distance >= 9900.0))// if the shadow Ray hits something (ie the ray is blocked from reaching infinity) the passed on light ray energy is multiplied by 0.0
			{
				return vec3(0.0); // basically a shadow
			}    
			return clamp(dot(hit_normal, d_light_dir)*-1.0,0.0,1.0) * d_light_energy * albedo; //every other ray gets to be coloured in
		}
		else{ //else if shadows are disabled
			return vec3(0.0, 0.0, 0.0);// Return nothing/silver
/*
			 at the end of each trace if the ray hits anything, the pixel that the ray is attached to is initially coloured black
			 as the ray bounces around the scene it should eventually reach infinity(9900.0f), shooting off into the sky
			 only then is the pixel coloured with a sample from the sky texture on the next else statement
			 if the ray kept bouncing, exceeding the "BOUNCE" limit, 
			 it's left as is: a black spot on the screen (specifically on the reflective sphere/plane) where the light never escaped			 
*/	 
		}
        
    }
    else
    {
        // Erase the ray's energy - the sky doesn't reflect anything
        ray_energy = vec3(0.0);
	
// this samples the 2D texture as if it was a sphere	
		float theta = acos(ray_direction.y) / -PI;
		float phi = atan(ray_direction.x, ray_direction.z) / -PI * 0.5f;
		return textureLod(texture_here,vec2(phi,theta),0).xyz*sky_energy;//needs to be textureLod else a weird line appears in sample

/*//from ShaderToy Test
        //For 2D texture only
        float theta = acos(ray.direction.y) / -PI;
        float phi = atan(ray.direction.x, -ray.direction.z) / -PI * 0.5f;
        return texture(iChannel0, vec2(phi, theta)).xyz;
		//For Cubemaps
        //return texture(texture_here, ray_direction).xyz;//texture
        //return ray_direction* 0.5 + 0.5;//uv rainbow
*/
    }
}

void fragment() {
	if(active){
		vec3 ray_origin;
		vec3 ray_direction;
		vec3 ray_energy;
		
		vec3 hit_position;
		float hit_distance;
		vec3 hit_normal;
		vec3 hit_albedo;
		vec3 hit_specular;

		CreateCameraRay(VIEWPORT_SIZE,FRAGCOORD.xy,ray_origin,ray_direction,ray_energy);
    
	    vec3 result = vec3(0.0, 0.0, 0.0);
	    vec3 m_ray_energy;

	    for (int i = 0; i < BOUNCE; i++)
	    {
			m_ray_energy=ray_energy; 

	        Trace(ray_origin,ray_direction,ray_energy,hit_position,hit_distance,hit_normal,hit_albedo,hit_specular);

			result += m_ray_energy * Shade(ray_origin,ray_direction,ray_energy, hit_position,hit_distance,hit_normal,hit_albedo,hit_specular);
/*
			here's the original code snippet from the tutorial blog:
				result += ray.energy * Shade(ray, hit);

			I had to make it remember the last ray_energy value (hence: "m_ray_energy") since the "Shade" function kept changing it right before it gets multiplied
*/

	        if (!any(greaterThan(ray_energy, vec3(0.001)))) break; // this breaks out of the loop if the ray_energy drops too low
								// apparently GLSL's built in "any" function takes in binary vectors as inputs, different from HLSL's (Unity's Compute Shader)
								
	    }
		ALBEDO = result;
		ALPHA = 1.80;
	}
}

