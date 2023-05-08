function p = bootstrap_ttest(z)
            
            config = yaml.loadFile ('./config.yaml');
            k = config.bootstrap.k;
            N = config.bootstrap.N;
     
            n = numel(z);

            parfor i = 1 : N
                g = z(randi(n,1,k));
                [~, p(i)] = ttest(g);
            end
            
            p = nanmean(p);
        end