function p = bootstrap_ttest2(z, flag)
            
            config = yaml.loadFile ('./config.yaml');
            k = config.bootstrap.k;
            N = config.bootstrap.N;

            z0 = z(flag==0);
            z1 = z(flag==1);
            
            n0 = numel(z0);
            n1 = numel(z1);
            
            
            parfor i = 1 : N
                g0 = z0(randi(n0,1,k));
                g1 = z1(randi(n1,1,k)); 
                [~, p(i)] = ttest2(g0, g1);
            end
            
            p = nanmean(p);
        end