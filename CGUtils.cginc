#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point
    float3 tangent;      // Mesh surface tangent at the point
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    // Your implementation
    return 0;
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    float3 h = normalize(v + l);
    fixed3 ambient = ambientIntensity * albedo;
    fixed3 diffuse = max(0, dot(n, l)) * albedo;
    fixed3 specular = pow(max(0, dot(n, h)), shininess) * specularity;
    
    return ambient + diffuse + specular;
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    float3 b = i.tangent * i.normal;
    float u_derivative = ((tex2D(i.heightMap, float2 (i.uv[0] + i.du, i.uv[1])) - tex2D(i.heightMap, i.uv)) / i.du)[0];
    float v_derivative = ((tex2D(i.heightMap, float2 (i.uv[0], i.uv[1] + i.dv)) - tex2D(i.heightMap, i.uv)) / i.dv)[0];
    float3 nh = normalize(float3 (-u_derivative * i.bumpScale, -v_derivative * i.bumpScale, 1));
    return normalize((i.tangent * nh.x + b * nh.y + i.normal * nh.z));
}


#endif // CG_UTILS_INCLUDED
