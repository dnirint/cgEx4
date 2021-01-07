#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c
float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c 
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float2 values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float2 v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float2 values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float2 v[4], float2 t)
{
    float2 u = t * t * t * (10.0 - 15.0 * t + 6.0 * t * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float3 values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float3 v[8], float3 t)
{
    // Your implementation
    float2 a[4] = {v[0].xy, v[1].xy, v[2].xy, v[3].xy};
    float side_a = biquinticInterpolation(a, t.xy);
    float2 b[4] = {v[4].xy, v[5].xy, v[6].xy, v[7].xy};
    float side_b = biquinticInterpolation(b, t.xy);
    return lerp(side_a, side_b, t.z);

    return 0;
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float floor_x = floor(c.x);
    float floor_y = floor(c.y);
    float ceil_x = floor(c.x + 1);
    float ceil_y = floor(c.y + 1);

    float2 ff_color = random2(float2(floor_x, floor_y)).x;
    float2 cf_color = random2(float2(ceil_x, floor_y)).x;
    float2 fc_color = random2(float2(floor_x, ceil_y)).x;
    float2 cc_color = random2(float2(ceil_x, ceil_y)).x;

    float2 corners_colors[4] = {ff_color, cf_color, fc_color, cc_color};
    return bicubicInterpolation(corners_colors, frac(c));
}

// Returns the value of a 2D Perlin noise function at the given coordinates c
float perlin2d(float2 c)
{

    float floor_x = floor(c.x);
    float floor_y = floor(c.y);
    float ceil_x = floor(c.x + 1);
    float ceil_y = floor(c.y + 1);

    float2 ff_grad = random2(float2(floor_x, floor_y));
    float2 cf_grad = random2(float2(ceil_x, floor_y));
    float2 fc_grad = random2(float2(floor_x, ceil_y));
    float2 cc_grad = random2(float2(ceil_x, ceil_y));

    float2 ff_dist = float2(floor_x, floor_y) - c;
    float2 cf_dist = float2(ceil_x, floor_y) - c;
    float2 fc_dist = float2(floor_x, ceil_y) - c;
    float2 cc_dist = float2(ceil_x, ceil_y) - c;

    float2 inf_val0 = dot(ff_grad, ff_dist);
    float2 inf_val1 = dot(cf_grad, cf_dist);
    float2 inf_val2 = dot(fc_grad, fc_dist);
    float2 inf_val3 = dot(cc_grad, cc_dist);

    float2 influence_values[4] = {inf_val0, inf_val1, inf_val2, inf_val3};

    return biquinticInterpolation(influence_values, frac(c));
}

// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{                    
    // x y z
    float floor_x = floor(c.x);
    float floor_y = floor(c.y);
    float floor_z = floor(c.z);
    float ceil_x = floor(c.x + 1);
    float ceil_y = floor(c.y + 1);
    float ceil_z = floor(c.z + 1);

    float3 fff = (float3(floor_x, floor_y, floor_z));
    float3 ffc = (float3(floor_x, floor_y, ceil_z));
    float3 fcf = (float3(floor_x, ceil_y, floor_z));
    float3 fcc = (float3(floor_x, ceil_y, ceil_z));
    float3 cff = (float3(ceil_x, floor_y, floor_z));
    float3 cfc = (float3(ceil_x, floor_y, ceil_z));
    float3 ccf = (float3(ceil_x, ceil_y, floor_z));
    float3 ccc = (float3(ceil_x, ceil_y, ceil_z));

    float3 fff_grad = random3(fff);
    float3 ffc_grad = random3(ffc);
    float3 fcf_grad = random3(fcf);
    float3 fcc_grad = random3(fcc);
    float3 cff_grad = random3(cff);
    float3 cfc_grad = random3(cfc);
    float3 ccf_grad = random3(ccf);
    float3 ccc_grad = random3(ccc);

    float3 fff_dist = fff - c;
    float3 ffc_dist = ffc - c;
    float3 fcf_dist = fcf - c;
    float3 fcc_dist = fcc - c;
    float3 cff_dist = cff - c;
    float3 cfc_dist = cfc - c;
    float3 ccf_dist = ccf - c;
    float3 ccc_dist = ccc - c;

    float3 inf_val0 = dot(fff_grad, fff_dist);
    float3 inf_val1 = dot(ffc_grad, ffc_dist);
    float3 inf_val2 = dot(fcf_grad, fcf_dist);
    float3 inf_val3 = dot(fcc_grad, fcc_dist);
    float3 inf_val4 = dot(cff_grad, cff_dist);
    float3 inf_val5 = dot(cfc_grad, cfc_dist);
    float3 inf_val6 = dot(ccf_grad, ccf_dist);
    float3 inf_val7 = dot(ccc_grad, ccc_dist);

    float3 influence_values[8] = {inf_val0, inf_val1, inf_val2, inf_val3, inf_val4, inf_val5, inf_val6, inf_val7 };

    return triquinticInterpolation(influence_values, frac(c));

}


#endif // CG_RANDOM_INCLUDED

