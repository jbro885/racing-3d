precision mediump float;
precision highp int;

varying vec3 fragColor;
varying vec3 worldPosition;
varying vec3 outNormal;
varying vec3 vecToLight;

uniform vec3 ambient;
uniform vec3 lightPos;
uniform vec3 lightColor;

uniform mat4 worldMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform vec3 camPos;

const float gamma = 2.2;
const float shininess = 80.0;

//const float lightAttenuation = 0.0001; when light 100
const float lightAttenuation = 0.00001;

uniform float material_kd;
uniform float material_ks;

varying vec2 fragTexCoord;
uniform sampler2D sampler;

struct LightInfo {
    vec3 left;
    vec3 right;
    vec3 front;
    vec3 position;
    vec3 color;
    vec3 ambient;
    float attenuation;
};

uniform LightInfo reflectorLights[100];
uniform int lightCount;

void main()
{
   float diffuse = max(dot(vecToLight,outNormal), 0.0);
   float specular = 0.0;

   if(diffuse > 0.0) {
       vec3 viewDir = normalize(camPos-worldPosition);
       vec3 reflectDir = -normalize(reflect(vecToLight, outNormal));
       float specAngle = max(dot(reflectDir, viewDir), 0.0);
       specular = pow(specAngle, shininess/4.0);
   }
   vec3 textureColor = texture2D(sampler, fragTexCoord).xyz;

   float distanceToLight = length(lightPos-worldPosition);
   float attenuation = 1.0/(1.0 + lightAttenuation * pow(distanceToLight, 2.0));

   diffuse = attenuation*material_kd*diffuse;
   specular = attenuation*material_ks*specular;

   //diffuse = 0.0;
   //specular = 0.0;

   for (int i=0;i<100;i++){

       if (reflectorLights[i].color[0]==0.0) continue;

       vec3 front = reflectorLights[i].front;
       vec3 left = reflectorLights[i].left;
       vec3 right = reflectorLights[i].right;

       vec3 dir = normalize(worldPosition-reflectorLights[i].position);

       if (dot(dir,front)<0.0) continue;
       if (dot(dir,left)<0.0) continue;
       if (dot(dir,right)<0.0) continue;
       //if (dot(front,worldPosition)<0) continue;

       vec3 ldir = normalize(reflectorLights[i].position-worldPosition);

       float ldiffuse = max(dot(ldir,outNormal), 0.0);
       float lspecular = 0.0;

       if(ldiffuse > 0.0) {
           vec3 viewDir = normalize(camPos-worldPosition);
           vec3 reflectDir = -normalize(reflect(ldir, outNormal));
           float specAngle = max(dot(reflectDir, viewDir), 0.0);
           lspecular = pow(specAngle, shininess/4.0);
       }

       float distanceToLight = length(reflectorLights[i].position-worldPosition);
       float attenuation = 1.0/(1.0 + reflectorLights[i].attenuation * pow(distanceToLight, 2.0));
       //float attenuation = 1.0;

       ldiffuse = attenuation*material_kd*ldiffuse;
       lspecular = attenuation*material_ks*lspecular;

       diffuse += ldiffuse;
       specular += lspecular;
   }

    //vec3 color = diffuse*(reflectorLights[0].front*textureColor.xyz)+specular*lightColor.xyz;
   vec3 color = diffuse*(lightColor.xyz*textureColor.xyz)+specular*lightColor.xyz;

   gl_FragColor = vec4(color,1.0);
}