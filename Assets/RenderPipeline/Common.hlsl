#ifdef _CUSTOM_BRDF_FUNCTION
#define _CUSTOM_BRDF_FUNCTION

half3 BRDF_F(half3 F0,half LdotH)
{
    half3 F1 = F0 + (1-F0) * pow(1-LdotH,5);
                
    return F1;
}
half BRDF_D_GGX(half roughness,half NdotH)
{
    half roughness2 = roughness * roughness;
    half DGGX = roughness2 / (PI * pow(pow(NdotH,2) * (pow(roughness2,2) - 1) +1,2));
    return DGGX;
}
half BRDF_G(half roughness,half NdotV,half NdotL)
{
    half k = pow(1+ roughness,2) / 8 ;
    half G1 = NdotV / lerp(NdotV ,1, k);
    half G2 = NdotL / lerp(NdotL ,1, k);
                
    return G1 * G2;
}

#endif

