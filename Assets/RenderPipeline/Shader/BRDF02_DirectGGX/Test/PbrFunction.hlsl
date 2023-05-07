#ifndef PBR_Function_INCLUDE
#define PBR_Function_INCLUDE
         //D项 法线微表面分布函数 
         float D_Function(float NdotH,float roughness)
         {
             float a2=roughness*roughness;
             float NdotH2=NdotH*NdotH;
             
             //直接根据公式来
             float nom=a2;//分子
             float denom=NdotH2*(a2-1)+1;//分母
             denom=denom*denom*PI;
             return nom/denom;
         }

         //G项子项
         float G_section(float dot,float k)
         {
             float nom=dot;
             float denom=lerp(dot,1,k);
             return nom/denom;
         }

         //G项
         float G_Function(float NdotL,float NdotV,float roughness)
         {
             float k=pow(1+roughness,2)/8;
             float Gnl=G_section(NdotL,k);
             float Gnv=G_section(NdotV,k);
             return Gnl*Gnv;
         }

         //F项 直接光
         half3 F_Function(float HdotL,float3 F0)
         {
             float Fre=exp2((-5.55473*HdotL-6.98316)*HdotL);
             return lerp(Fre,1,F0);
         }

#endif