function [rho, p] = bootstrap_spearman(z0, z1)
              
            config = yaml.loadFile ('./config.yaml');
            k = config.bootstrap.k;
            N = config.bootstrap.N;

            n = numel(z0);
                        
            parfor i = 1 : N
                smp = randi(n,1,k);
                g0 = z0(smp);
                g1 = z1(smp); 
                [rho(i), p(i)] = corr(g0(:), g1(:),'Type', 'Spearman');
            end
            
            rho(isnan(rho)) = [];
            p(isnan(p)) = [];
            rho = median(rho);
            p = median(p);
        end