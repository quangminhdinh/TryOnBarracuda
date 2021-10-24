Shader "Diamonds/GemRingForDof"
{
		Properties{
			[Header(DOF Mode(On mobile phones instead of skybox uses ReflectionCube inside the diamond))]
		[Space(10)]
					
			_Color("Color", Color) = (1,1,1,1)
			[NoScaleOffset] _Texture("Texture", 2D) = "white" {}
			
			//Saturation2("Saturation2",Range(0,1)) = 1




	[Space(30)]
			 [Toggle(_XColorToggle)] _XColorToggle("whether to prohibit passing through the diamond specified color?", Float) = 0
	XColor("Forbidden Color", Color) = (1,0.650,0.1,1)
				 Saturation("Disaturation",Range(0,1)) = 1
			_Range("RangeColorDisaturation",Range(5,0)) = 1

			[Space(20)]
			_ReflectionStrength("Reflection Strength", Range(0.0,5.0)) = 1.0
			_ReflectionMultiply("Reflection Multiply", Range(0.0,1.0)) = 1.0
			_ReflectionMultiplyFront("Reflection Multiply Front", Range(0.0,3.0)) = 1.0
			_EnvironmentLight("Environment Light", Range(0.0,2.0)) = 1.0
			OffsetPower("OffsetPower", Float) = 2.5
			_BackFrontOpasity("BackFrontOpasity", Range(0.0,5.0)) = 1.0
			_Dispersion("Dispersion",Range(0,3)) = 1
			_DispersionPower("DispersionPower",Float) = 1
			_Brightness("Brightness", Range(0,2.0)) = 1.0
			_PowerFresnel("PowerFresbel",Range(-1,5)) = 1
			Contrast("Contrast",Range(0,3)) = 1
			OnBackReflection("OnBackReflection",Range(0,2)) = 1
				


			[MaterialToggle] _RefractCubeMap("RefractCubeMap", Float) = 0
			[MaterialToggle] UseBitangent("UseBitangent?", Float) = 1
			[NoScaleOffset] _RefractTex("Refraction Texture", Cube) = "" {}
			[NoScaleOffset] ReflectionCube("ReflectionCube", Cube) = "" {}


		}
			SubShader{




				Pass {
								Tags {
							   "Queue" = "Geometry"

							   //	"RenderType" = "Transparent"

							   }
					Cull Front
					ZWrite On
				Blend SrcAlpha OneMinusSrcAlpha
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
				#include "Diamonds.cginc"



								struct appdata
					{
						float4 v : POSITION;
						float3 n : NORMAL;
						//	float4 color : COLOR;
						float4 uv0_ : TEXCOORD0;
							UNITY_VERTEX_INPUT_INSTANCE_ID

						};

						struct v2f {
							float4 pos : SV_POSITION;
							float3 uv : TEXCOORD0;
							float4 uv2 : TEXCOORD1;
							float3 normals : TEXCOORD2;
						};

						v2f vert(appdata j)
						{
							v2f o;
							o.pos = UnityObjectToClipPos(j.v);


							float3 viewDir = normalize(ObjSpaceViewDir(j.v));
							o.uv = -reflect(viewDir, j.n);
							o.uv2 = j.uv0_;
							o.uv = mul(unity_ObjectToWorld, float4(o.uv,0));
							o.normals = j.n;
							return o;
						}

						sampler2D _GrabTexture1;
						sampler2D _Texture;
						float _RefractCubeMap;


						half4 frag(v2f i) : SV_Target
						{





								half3 refraction = tex2Dproj(_GrabTexture1, float4(i.uv,1)).rgb * lerp(tex2D(_Texture,i.uv2) * _Color.rgb,1,tex2Dproj(_GrabTexture1, float4(i.uv,1)).r * tex2Dproj(_GrabTexture1, float4(i.uv,1)).g * tex2Dproj(_GrabTexture1, float4(i.uv,1)).b * _Color.a);

							
								
							half3 refractionCube = texCUBE(_RefractTex, i.uv).rgb * lerp(tex2D(_Texture, i.uv2) * _Color.rgb, 1, texCUBE(_RefractTex, i.uv).r * texCUBE(_RefractTex, i.uv).g * texCUBE(_RefractTex, i.uv).b * _Color.a);

							refraction = lerp(refraction, refractionCube, _RefractCubeMap);

							half4 reflection = texCUBE(ReflectionCube, i.uv);

							_Dispersion = pow(_Dispersion,2);

							half4 reflection1_ = texCUBE(ReflectionCube, i.uv + i.normals.x * 0.2 * _Dispersion);
							half4 reflection2_ = texCUBE(ReflectionCube, i.uv + i.normals.y * 0.05 * _Dispersion);
							half4 reflection3_ = texCUBE(ReflectionCube, i.uv + i.normals.z * 0.5 * _Dispersion);


							refraction = lerp(refraction, refractionCube, _RefractCubeMap);


							reflection.x = reflection.x + reflection1_.x * pow(reflection1_.x, 1.33 * _DispersionPower);
							reflection.y = reflection.y + reflection2_.y * pow(reflection2_.y, 1.4 * _DispersionPower);
							reflection.z = reflection.z + reflection3_.z * pow(reflection3_.z, 1.5 * _DispersionPower);
							half3 multiplier = reflection.rgb * _EnvironmentLight;
							return half4(refraction.rgb * multiplier.rgb, 1);

						}
							ENDCG
				}
			/**/
			Tags{
				"Queue" = "Geometry+1"
			}

				GrabPass
					{}

						Pass{


						Cull Back
							ZWrite On
							//	Blend One One

								CGPROGRAM
								#pragma vertex vert
								#pragma fragment frag
								#include "UnityCG.cginc"
								#include "Diamonds.cginc"
						 #pragma shader_feature _XColorToggle

									struct appdata
						{
				float4 Tang : TANGENT;
							float4 v : POSITION;
							float3 n : NORMAL;
							//	float3 t : TANGENT;
								//	float4 color : COLOR;
								float4 uv0_ : TEXCOORD0;
								//	float4 pos : SV_POSITION;
										UNITY_VERTEX_INPUT_INSTANCE_ID

									};


										struct v2f {
										float4 pos : SV_POSITION;
										float3 uv : TEXCOORD0;
										half fresnel : TEXCOORD1;
										float4 uv2 : TEXCOORD2;
										float3 normals : NORMAL;
										float4 grabPos : TEXCOORD4;
										float4 grabPos2 : TEXCOORD5;
										float4 grabPos0 : TEXCOORD6;
										float4 Tang : TANGENT;
									};


									float OffsetPower;
									float _PowerFresnel;
									float UseBitangent;
									float	OnBackReflection;



									v2f vert(appdata j)
									{


										v2f o;
										o.pos = UnityObjectToClipPos(j.v);




										float3 _worldNormal = UnityObjectToWorldNormal(j.n);
										float3 _worldTangent = UnityObjectToWorldDir(j.Tang);
										float _vertexTangentSign = j.Tang.w * unity_WorldTransformParams.w;
										float3 _worldBitangent = normalize(cross(_worldNormal, _worldTangent) * _vertexTangentSign);

										// TexGen CubeReflect:
										// reflect view direction along the normal, in view space.
										float3 viewDir = normalize(ObjSpaceViewDir(j.v));
										o.uv2 = j.uv0_;
										float3 WorldNormal = j.n;
										WorldNormal = _worldBitangent;
										//float3 WorldNormal = normalize(UnityObjectToWorldNormal(j.n));

										o.uv = -reflect(viewDir, UnityObjectToWorldNormal(j.n));
										o.uv = mul(unity_ObjectToWorld, float4(o.uv,0));
										o.fresnel = pow(1.0 - saturate(dot(UnityObjectToWorldNormal(j.n),viewDir)), _PowerFresnel);
										o.normals = j.n;
										o.Tang = j.Tang;
										//o.tang = j.t;
										//o.grabPos =  ComputeGrabScreenPos(o.pos) + float4(reflect(viewDir, j.n),0) * OffsetPower;
										o.grabPos0 = ComputeGrabScreenPos(o.pos);
										//o.grabPos = ComputeGrabScreenPos(o.pos) + float4(viewDir, 0) * float4(UnityObjectToWorldNormal(normals),0) * OffsetPower;


										o.grabPos = ComputeGrabScreenPos(UnityObjectToClipPos(j.v)) + float4(reflect(viewDir, j.n), 0) * float4(lerp(j.n,WorldNormal, UseBitangent), 0) * OffsetPower;
										o.grabPos2 = ComputeGrabScreenPos(UnityObjectToClipPos(j.v)) + float4(reflect(viewDir, j.n), 0) * float4(lerp(j.n, WorldNormal, UseBitangent), 0) * OffsetPower * -1;

										//o.grabPos = float4(normalize(ObjSpaceViewDir(j.v)),0);
									//o.grabPos = float4(normals,1);
									return o;
								}


								half4 frag(v2f i) : SV_Target
								{
									half4 bgcolor0 = 1;
									half4 bgcolor = tex2Dproj(_GrabTexture, i.grabPos);
									half4 bgcolor2 = tex2Dproj(_GrabTexture, i.grabPos2);
									//bgcolor2 = clamp(bgcolor2, 0, 1);
									half4 bgcolor3 = tex2Dproj(_GrabTexture, float4(i.grabPos.x - 0.45 * OffsetPower, i.grabPos.y, i.grabPos.z, i.grabPos.w));
									half4 bgcolor4 = tex2Dproj(_GrabTexture, float4(i.grabPos2.x, i.grabPos2.y - 0.68 * OffsetPower, i.grabPos2.z, i.grabPos2.w));

									half4 CubZ = texCUBE(ReflectionCube, i.uv);


									bgcolor = lerp(CubZ, bgcolor, clamp(bgcolor.a , 0, 1));
									bgcolor2 = lerp(CubZ, bgcolor2, clamp(bgcolor2.a, 0, 1));
									bgcolor3 = lerp(CubZ, bgcolor3, clamp(bgcolor3.a , 0, 1));
									bgcolor4 = lerp(CubZ, bgcolor4, clamp(bgcolor4.a , 0, 1));

									half4 bgcolorResult;


									float blend_0 = 1;
									
				#if defined(UNITY_COLORSPACE_GAMMA)
									blend_0 = 10;
				#endif



									for (int ii = 0;ii < 3;ii++) {



										 bgcolor = Overlay(bgcolor, lerp(CubZ, tex2Dproj(_GrabTexture, i.grabPos * OffsetPower + ii * 0.1), clamp(tex2Dproj(_GrabTexture, i.grabPos * OffsetPower + ii * 0.1).a, 0, 1)), 0.02 * blend_0);
										 bgcolor2 = Overlay(bgcolor2, lerp(CubZ, tex2Dproj(_GrabTexture, i.grabPos2 * OffsetPower + ii * 0.1), clamp(tex2Dproj(_GrabTexture, i.grabPos2 * OffsetPower + ii * 0.1).a, 0, 1)), 0.02 * blend_0);
										 bgcolor3 = Overlay(bgcolor3, lerp(CubZ, tex2Dproj(_GrabTexture, float4(i.grabPos.x, i.grabPos.y - 0.68 * OffsetPower + ii * 0.1, i.grabPos.z, i.grabPos.w)), clamp(tex2Dproj(_GrabTexture, float4(i.grabPos.x, i.grabPos.y - 0.68 * OffsetPower + ii * 0.1, i.grabPos.z, i.grabPos.w)).a, 0, 1)), 0.02 * blend_0);
										 bgcolor4 = Overlay(bgcolor4, lerp(CubZ, tex2Dproj(_GrabTexture, float4(i.grabPos2.x - 0.45 * OffsetPower + ii * 0.1, i.grabPos2.y, i.grabPos2.z, i.grabPos2.w)), clamp(tex2Dproj(_GrabTexture, float4(i.grabPos2.x - 0.45 * OffsetPower + ii * 0.1, i.grabPos2.y, i.grabPos2.z, i.grabPos2.w)).a, 0, 1)), 0.02 * blend_0);


									}




									bgcolor2 = clamp(bgcolor2, 0, 1);

											bgcolorResult = (bgcolor + bgcolor2 + bgcolor3 + bgcolor4) / 2;



#ifdef _XColorToggle
											bgcolorResult = DisaturateColor(bgcolorResult, XColor, Saturation, _Range);
#endif


									half3 refraction = texCUBE(_RefractTex, i.uv).rgb;
									half4 reflection = texCUBE(ReflectionCube, i.uv);

									_Dispersion = pow(_Dispersion, 2);
									half4 reflection1_ = texCUBE(ReflectionCube, i.uv + i.normals.x * (0.09 * _Dispersion));
									half4 reflection2_ = texCUBE(ReflectionCube, i.uv + i.normals.y * (0.04 * _Dispersion));
									half4 reflection3_ = texCUBE(ReflectionCube, i.uv + i.normals.z * (0.12 * _Dispersion));



									reflection.x = reflection.x + reflection1_.x * pow(reflection1_.x, _DispersionPower);
									reflection.y = reflection.y + reflection2_.y * pow(reflection2_.y, _DispersionPower);
									reflection.z = reflection.z + reflection3_.z * pow(reflection3_.z, _DispersionPower);


									float fresnel = i.fresnel;


								//	reflection.rgb = DecodeHDR(reflection, unity_SpecCube0_HDR);
									half4 reflection2 = clamp(reflection * _ReflectionStrength * fresnel,0,1);
									reflection2 = dot(reflection2, float4(0.299, 0.587, 0.114, 1));
									half3 multiplier = reflection.rgb * _EnvironmentLight * (_ReflectionMultiplyFront * fresnel);

										float4 Fin = lerp(clamp(fixed4(bgcolorResult * _BackFrontOpasity + refraction.rgb * multiplier * clamp(lerp(1,1, (_ReflectionMultiplyFront * fresnel)),0,1), 1.0f) * _Brightness + reflection2,0,1.7), bgcolorResult, _ReflectionMultiply);
										
										//	Fin = lerp(Fin, tex2Dproj(_GrabTexture, i.grabPos0), 0.2);

									//	Fin = lerp(Fin, max(Fin,tex2Dproj(_GrabTexture, i.grabPos0)), 1);

										Fin = lerp(Fin, max(Fin,  tex2Dproj(_GrabTexture, i.grabPos0) * _Brightness), OnBackReflection);

								//			Fin = lerp(Fin, pow(Fin, reflection),1);
									//	Fin = pow(Fin, Remap(reflection,0,1,1.5, 1));
								//		Fin = lerp(Fin, Fin * 1.1, reflection);
										Fin = max(Fin, (reflection / (_ReflectionMultiply * 4)));

										Fin = clamp(pow(Fin, Contrast) * _Brightness, 0, 1);
										//		return  lerp(dot(clamp(Fin, 0, 1), float4(0.299, 0.587, 0.114, 1)), Fin, Saturation2);
									//	return	reflection;

										//return i.Tang;
										//return float4(i.normals,1);
										return Fin;


												//	return tex2Dproj(_GrabTexture, i.grabPos);
										//		return bgcolor.aaaa;

											}
											ENDCG
												}





								UsePass "VertexLit/SHADOWCASTER"
		}
	}
