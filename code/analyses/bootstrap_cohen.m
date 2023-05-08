function d = bootstrap_cohen (z, g)

    z0 = +z(g==0);
    z1 = +z(g==1);
    d = meanEffectSize(z0,z1,"Effect","robustcohen");
    d = d.Effect;

end