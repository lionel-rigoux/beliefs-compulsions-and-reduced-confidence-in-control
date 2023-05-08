function p = bootstrap_wilkoxon(z, flag)

            config = yaml.loadFile ('./config.yaml');
            k = config.bootstrap.k;
            N = config.bootstrap.N;

            z0 = z(flag==0);
            z1 = z(flag==1);
            
            n0 = numel(z0);
            n1 = numel(z1);
            
            parfor i = 1 : N
                try
                g0 = z0(randi(n0,1,k));
                g1 = z1(randi(n1,1,k)); 
                p(i) = ranksum(g0, g1);
                catch
                    p(i) = nan;
                end
            end
            
            p = nanmedian(p);
        end