function st = bootstrap_std(z)
              
            config = yaml.loadFile ('./config.yaml');
            k = config.bootstrap.k;
            N = config.bootstrap.N;
          
            n = numel(z);
             
            parfor i = 1 : N
                smp = randi(n,1,k);
                g = z(smp);
                s(i) = std(g);
            end
            
            st = mean(s/sqrt(k));
        end