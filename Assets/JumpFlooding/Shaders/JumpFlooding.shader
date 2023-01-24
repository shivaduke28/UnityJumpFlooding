Shader "JFA/JumpFlooding"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "Initial Pass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _StepLength;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float3 nearest = float3(0, 0, 0); // (u, v, distance)
                bool isEmpty = true;

                for (int x = -1; x <= 1; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        float2 neighborUV = uv + float2(x, y) * _MainTex_TexelSize.xy * _StepLength;
                        if (any(neighborUV < 0 || neighborUV > 1))
                        {
                            continue;
                        }
                        float4 neighborColor = tex2Dlod(_MainTex, float4(neighborUV, 0, 0));

                        // 1stパスは(0,0,0)を無効とする
                        bool isNeighborEmpty = all(neighborColor.xyz == 0);
                        if (!isNeighborEmpty)
                        {
                            // この近傍が一番近い
                            float d = distance(uv, neighborUV);
                            if (isEmpty || d < nearest.z)
                            {
                                nearest.xy = neighborUV;
                                nearest.z = d;
                                isEmpty = false;
                            }
                        }
                    }
                }

                return float4(nearest, 1);
            }
            ENDCG
        }

        Pass
        {
            Name "Second Pass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _StepLength;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float3 nearest = float3(0, 0, 0); // (u, v, distance)
                bool isEmpty = true;

                for (int x = -1; x <= 1; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        float2 neighborUV = uv + float2(x, y) * _MainTex_TexelSize.xy * _StepLength;
                        if (any(neighborUV < 0 || neighborUV > 1))
                        {
                            continue;
                        }
                        float4 neighborColor = tex2Dlod(_MainTex, float4(neighborUV, 0, 0));

                        // 2パス目以降はxyが0の場合は無効にする
                        bool isNeighborEmpty = all(neighborColor.xy == 0);
                        if (!isNeighborEmpty)
                        {
                            // この近傍が一番近い
                            float d = distance(uv, neighborColor.xy);
                            if (isEmpty || d < nearest.z)
                            {
                                nearest.xy = neighborColor.xy;
                                nearest.z = d;
                                isEmpty = false;
                            }
                        }
                    }
                }

                // nearestのUVとdが入っている
                return float4(nearest, 1);
            }
            ENDCG
        }

        Pass
        {
            Name "Third Pass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _InputTex;
            float4 _MainTex_TexelSize;
            float _StepLength;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 pos = tex2Dlod(_MainTex, float4(uv, 0, 0)).xy;
                float3 col = tex2Dlod(_InputTex, float4(pos, 0, 0)).rgb;
                return float4(col, 1);
            }
            ENDCG
        }
    }
}