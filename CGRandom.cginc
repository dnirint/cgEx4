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
    float3 u = t * t * t * (6.0 * t * t - 15.0 * t + 10.0); // todo fix this
    /*
          pa-----------pb
         /|            /|
        pc-----------pd |
        | |           | |
        | |           | |
        | pe-----------pf
        |/            |/
        pg-----------ph
    */
    // front face
    float x1 = lerp(v[0], v[1], u.x); // pg-ph
    float x2 = lerp(v[2], v[3], u.x); // pc-pd
    // rear face
    float x3 = lerp(v[4], v[5], u.x); // pe-pf
    float x4 = lerp(v[6], v[7], u.x); // pa-pb

    float y1 = lerp(x1, x2, u.y);
    float y2 = lerp(x3, x4, u.y);

    return lerp(y1, y2, u.z);
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float floor_x = floor(c.x);
    float floor_y = floor(c.y);
    float ceil_x = floor_x + 1;
    float ceil_y = floor_y + 1;

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

/*
        y
        |   z
          / 
            -x

        xyz

          pa-----------pb
         /|            /|
        pc-----------pd |
        | |           | |
        | |           | |
        | pe-----------pf
        |/            |/
        pg-----------ph

*/
// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{                    
    // x y z
    float xf = floor(c.x);
    float yf = floor(c.y);
    float zf = floor(c.z);
    float xc = xf + 1;
    float yc = yf + 1;
    float zc = zf + 1;

    float3 pa = (float3(xf, yc, zc));
    float3 pb = (float3(xc, yc, zc));
    float3 pc = (float3(xf, yc, zf));
    float3 pd = (float3(xc, yc, zf));
    float3 pe = (float3(xf, yf, zc));
    float3 pf = (float3(xc, yf, zc));
    float3 pg = (float3(xf, yf, zf));
    float3 ph = (float3(xc, yf, zf));

    float3 pa_grad = random3(pa);
    float3 pb_grad = random3(pb);
    float3 pc_grad = random3(pc);
    float3 pd_grad = random3(pd);
    float3 pe_grad = random3(pe);
    float3 pf_grad = random3(pf);
    float3 pg_grad = random3(pg);
    float3 ph_grad = random3(ph);
    
    float3 pa_dist = pa - c;
    float3 pb_dist = pb - c;
    float3 pc_dist = pc - c;
    float3 pd_dist = pd - c;
    float3 pe_dist = pe - c;
    float3 pf_dist = pf - c;
    float3 pg_dist = pg - c;
    float3 ph_dist = ph - c;

    float3 pa_inf = dot(pa_grad, pa_dist);
    float3 pb_inf = dot(pb_grad, pb_dist);
    float3 pc_inf = dot(pc_grad, pc_dist);
    float3 pd_inf = dot(pd_grad, pd_dist);
    float3 pe_inf = dot(pe_grad, pe_dist);
    float3 pf_inf = dot(pf_grad, pf_dist);
    float3 pg_inf = dot(pg_grad, pg_dist);
    float3 ph_inf = dot(ph_grad, ph_dist);
    /*
          pa-----------pb
         /|            /|
        pc-----------pd |
        | |           | |
        | |           | |
        | pe-----------pf
        |/            |/
        pg-----------ph
    */

    float3 influence_values[8] = {pg_inf, ph_inf, pc_inf, pd_inf, pe_inf, pf_inf, pa_inf, pb_inf };

    return triquinticInterpolation(influence_values, frac(c));

}


#endif // CG_RANDOM_INCLUDED

