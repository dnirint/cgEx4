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

                /*
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
                    float3 v        : TEXCOORD1;
                    float3 r        : TEXCOORD2;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    return perlin2d(uv);
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    // Your implementation
                    return 0;
                }


                v2f vert (appdata input)
                {
                    v2f output;

                    float water_noise = waterNoise(input.uv * _NoiseScale , 0);
                    float z_displacement = water_noise * _BumpScale;

                    output.pos = UnityObjectToClipPos(input.vertex + float4(0, z_displacement, 0, 0));
                    output.uv = input.uv;
                    output.normal = normalize(input.normal);

                    float4 worldVertex = mul(unity_ObjectToWorld,input.vertex);
                    output.v = normalize(worldVertex - _WorldSpaceCameraPos);
                    output.r = reflect(output.v, output.normal);



                    //output.r = normalize((2 * dot(output.v, output.normal) * output.normal) - output.v);
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 v = normalize(input.v);
                    float3 n = normalize(input.normal);
                    float3 r = normalize(input.r);
                    //r = float3(input.r.z,input.r.x,input.r.y);

                    float3 ReflectedColor = texCUBE(_CubeMap, r);
                    float3 color = (1 - max(dot(n, v), 0) + 0.2) * ReflectedColor;
                    //color = ReflectedColor;
                    return fixed4(color, 1);

               //     float water_noise = waterNoise(input.uv * _NoiseScale , 0);
               //     float3 gs = (water_noise * 0.5 + 0.5);
              //      color = color + gs;

               //     return fixed4(color, 1);
                }

                */

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
                    float4 worldVertex        : TEXCOORD1;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    return perlin2d(uv);
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    // Your implementation
                    return 0;
                }


                v2f vert (appdata input)
                {
                    v2f output;

                    float water_noise = waterNoise(input.uv * _NoiseScale , 0);
                    float z_displacement = water_noise * _BumpScale;

                    output.pos = UnityObjectToClipPos(input.vertex + float4(0, z_displacement, 0, 0));
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.worldVertex = mul(unity_ObjectToWorld,input.vertex);

                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 v = normalize(_WorldSpaceCameraPos - input.worldVertex);
                    float3 n = normalize(mul(unity_ObjectToWorld, input.normal));
                    float3 r = reflect(v, n);
                    r = (2 * dot(v, n) * n) - v;

                    float3 ReflectedColor = texCUBE(_CubeMap, r);
                    float3 color = (1 - max(dot(n, v), 0) + 0.2) * ReflectedColor;
                    return fixed4(color, 1);

               //     float water_noise = waterNoise(input.uv * _NoiseScale , 0);
               //     float3 gs = (water_noise * 0.5 + 0.5);
              //      color = color + gs;

               //     return fixed4(color, 1);
                }



            ENDCG
        }
    }
}
