Shader "CG/Bricks"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(-100, 100)) = 40
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
                uniform sampler2D _MainTex;
                                

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex: SV_POSITION;
                    float3 normal: NORMAL;
                    float4 tangent  : TANGENT;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.uv = input.uv;
                    output.vertex = UnityObjectToClipPos(input.vertex);
                    output.normal = input.normal;
                    output.tangent = normalize(input.tangent);
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 n = normalize(input.normal);
                    float3 v = normalize(_WorldSpaceCameraPos.xyz);
                    float3 l = normalize(_WorldSpaceLightPos0.xyz);

                    fixed4 albedo = tex2D(_AlbedoMap, input.uv);
                    fixed4 specularity = tex2D(_SpecularMap, input.uv);

                    bumpMapData bmd;
                    bmd.normal = n;
                    bmd.tangent = normalize(input.tangent);
                    bmd.uv = input.uv;
                    bmd.heightMap = _HeightMap;
                    bmd.du = _HeightMap_TexelSize[0];
                    bmd.dv = _HeightMap_TexelSize[1];
                    bmd.bumpScale = _BumpScale / 10000.0;
                    float3 bumpMappedNormal = getBumpMappedNormal(bmd);

                    fixed3 bf = blinnPhong(bumpMappedNormal, v, l, _Shininess, albedo, specularity, _Ambient);
                    return fixed4 (bf, 1);       
                }

            ENDCG
        }
    }
}
