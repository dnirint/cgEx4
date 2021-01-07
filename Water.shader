// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;


                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv       : TEXCOORD0;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float4 worldVertex        : TEXCOORD1;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    float p1 = perlin3d(float3(0.5*uv[0], 0.5*uv[1], 0.5*t));
                    float p2 = 0.5 * perlin3d(float3(uv[0], uv[1], t));
                    float p3 = 0.2 * perlin3d(float3(2*uv[0], 2*uv[1], 3*t));
                    return p1+p2+p3;
                    return perlin2d(uv);
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)                {                    /*                    float3 b = i.tangent * i.normal;
                    float u_derivative = ((tex2D(i.heightMap, float2 (i.uv[0] + i.du, i.uv[1])) - tex2D(i.heightMap, i.uv)) / i.du)[0];
                    float v_derivative = ((tex2D(i.heightMap, float2 (i.uv[0], i.uv[1] + i.dv)) - tex2D(i.heightMap, i.uv)) / i.dv)[0];
                    float3 nh = normalize(float3 (-u_derivative * i.bumpScale, -v_derivative * i.bumpScale, 1));
                    return normalize((i.tangent * nh.x + b * nh.y + i.normal * nh.z));                    */                    float3 b = i.tangent * i.normal;                    i.uv = i.uv * _NoiseScale;                    float u_deriv = waterNoise(float2 (i.uv[0] + i.du, i.uv[1]), t) - waterNoise(i.uv, t);                    float u_derivative = ((u_deriv) / i.du);                    float v_deriv = waterNoise(float2 (i.uv[0], i.uv[1] + i.dv), t) - waterNoise(i.uv, t);                    float v_derivative = ((v_deriv) / i.dv);                    float3 nh = normalize(float3 (-u_derivative * i.bumpScale, -v_derivative * i.bumpScale, 1));                    return normalize((i.tangent * nh.x + b * nh.y + i.normal * nh.z));                }



                v2f vert (appdata input)
                {
                    v2f output;

                    float water_noise = waterNoise(input.uv * _NoiseScale , 0);
                    float z_displacement = water_noise * _BumpScale;
                    //output.tangent = mul(unity_ObjectToWorld,input.tangent);
                    output.tangent = input.tangent;
                    output.pos = UnityObjectToClipPos(input.vertex + float4(0, z_displacement, 0, 0));
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.normal = mul(unity_ObjectToWorld, input.normal);
                    output.worldVertex = mul(unity_ObjectToWorld,input.vertex);

                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 n = normalize(input.normal);
                    

                    float3 v = normalize(_WorldSpaceCameraPos - input.worldVertex);

                    //n = normalize(mul(unity_ObjectToWorld, n));
                    bumpMapData bmd;                    bmd.normal = n;                    bmd.tangent = input.tangent;                    bmd.uv = input.uv;                    bmd.du = DELTA;                    bmd.dv = DELTA;                    bmd.bumpScale = _BumpScale;                    n = getWaterBumpMappedNormal(bmd, 0);


                    float3 r = r = (2 * dot(v, n) * n) - v;
                    float3 ReflectedColor = texCUBE(_CubeMap, r);
                    
                    
                    
                    float3 color = (1 - max(dot(n, v), 0) + 0.2) * ReflectedColor;
                    return fixed4(color, 1);
                    //return fixed4(n, 1);

                    



               //     float water_noise = waterNoise(input.uv * _NoiseScale , 0);
               //     float3 gs = (water_noise * 0.5 + 0.5);
              //      color = color + gs;

               //     return fixed4(color, 1);
                }



            ENDCG
        }
    }
}
