﻿Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float4 inputVertex: TEXCOORD2;
                    float3 norm : TEXCOORD1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.norm = input.vertex.xyz;
                    output.inputVertex = input.vertex;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float2 uv = getSphericalUV(input.inputVertex);
                    fixed4 albedo = tex2D(_AlbedoMap, uv);    
                    fixed4 specularity = tex2D(_SpecularMap, uv);
                    float3 v = normalize(_WorldSpaceCameraPos.xyz);
                    float3 l = normalize(_WorldSpaceLightPos0.xyz);
                    float3 n = normalize(input.norm);

                    bumpMapData bmd;
                    bmd.normal = n;
                    bmd.tangent = normalize(n * float3(0,1,0));
                    bmd.uv = uv;
                    bmd.heightMap = _HeightMap;
                    bmd.du = _HeightMap_TexelSize[0];
                    bmd.dv = _HeightMap_TexelSize[1];
                    bmd.bumpScale = _BumpScale / 10000.0;

                    float3 bumpMappedNormal = normalize(getBumpMappedNormal(bmd));
                    float3 finalNormal = normalize( (1-specularity)*bumpMappedNormal + specularity * n ) ;
                    fixed3 bf = blinnPhong(finalNormal, v, l, _Shininess, albedo, specularity, _Ambient);

                    float lambert = max(0,dot(n,l));
                    float3 atmosphere = (1-max(0,dot(n,v)))*sqrt(lambert) * _AtmosphereColor;
                    float3 clouds = tex2D(_CloudMap, uv) * (sqrt(lambert) + _Ambient);

                    float3 outColor = bf + atmosphere + clouds;

                    return fixed4(outColor,1);
                }

            ENDCG
        }
    }
}
