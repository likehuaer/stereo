Texture2D Textures[2];

SamplerState Sampler;

cbuffer ConstantParametersBuffer
{
	const float alpha;
	const float Tc;
	const float Tg;
	const float dx;
};

cbuffer TextureProjectionConstantBuffer
{
	float2 disparity;
};

struct PixelShaderInput
{
	float4 pos : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(PixelShaderInput input) : SV_TARGET
{
	float4 px0_left = Textures[0].Sample(Sampler, input.tex - float2(dx, 0.0f));
	float4 px1_left = Textures[0].Sample(Sampler, input.tex);
	float4 px2_left = Textures[0].Sample(Sampler, input.tex + float2(dx, 0.0f));

	float2 dispTex = input.tex - disparity;
	float4 px0_right = Textures[1].Sample(Sampler, dispTex - float2(dx, 0.0f));
	float4 px1_right = Textures[1].Sample(Sampler, dispTex);
	float4 px2_right = Textures[1].Sample(Sampler, dispTex + float2(dx, 0.0f));

	float G = abs(
					0.149468010646888f * (px2_left[0] - px0_left[0] - px2_right[0] + px0_right[0]) + 
					0.293521537225561f * (px2_left[1] - px0_left[1] - px2_right[1] + px0_right[1]) + 
					0.057010452127552f * (px2_left[2] - px0_left[2] - px2_right[2] + px0_right[2])
			     );

	float M = abs(
					px1_left[0] + px1_left[1] + px1_left[2] - px1_right[0] - px1_right[1] - px1_right[2]
				 );

	float C = alpha * min(Tc, M) + (1 - alpha) * min(Tg, G);
	
	if (C < 0.02f)
		C = 1.0f;

    return float4(C, C, C, 1.0f);
}