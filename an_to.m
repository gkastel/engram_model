defaults

close all
ninputs=100


nruns =5
all = {};
all_ff = {};
all_br = {};

all_brturn = {};
all_brnoturn = {};
%Conditions = {'TO_TEGN', 'TO_TELN', 'TO_TENGN', 'TO_TENLN'}; 
Conditions = {'REP1G', 'REP1L', 'REP1GN', 'REP1LN'}; 
Turnovers = {0,5,10,15,20};
npatterns=4

for NCOND=1:length(Conditions)
    CONDITION=Conditions{NCOND}
    
    for NBT=1:length(Turnovers)
        BT=Turnovers{NBT}
        
        
        spks = zeros(npatterns, npyrs, nruns);
        pops = zeros(npatterns, npyrs, nruns);
        corr_spk = zeros(npatterns, npatterns, nruns);
        corr_pop = zeros(npatterns, npatterns, nruns);
        
        branch_syns = zeros(npyrs*nbranches, nruns);
        br_hists = zeros(ninputs, 12, nruns);
        clustering = zeros(ninputs, nruns);
        brstrengths = zeros(ninputs, npyrs*nbranches);
        
        brweights = zeros(ninputs, npyrs*nbranches, nruns);
        nrnweights = zeros(ninputs, npyrs, nruns);
        brweightcors = zeros(ninputs, ninputs, nruns);
        brsyncors= zeros(ninputs, ninputs, nruns);
        nrnweightcors = zeros(ninputs, ninputs, nruns);
        
        brcommon = zeros(ninputs, ninputs, nruns);
        
        
        clust_all = {};
        clust_all = cell(9,1);
        
        ISI=120;
        
       bsyns_turn = zeros(npyrs*nbranches, nruns);
       bsyns_noturn = zeros(npyrs*nbranches, nruns);
       
        
        for run = 1:nruns
            
            fn = sprintf('./data/%s_%d_%d/spikesperpattern.dat', CONDITION, BT,run-1)
            spk = load( fn);
            
            recallspikes = spk(:, 1:npyrs)/(stimduration/1000);

            pop = recallspikes>CUTOFF; %Hz
            spks(:, :, run) = recallspikes;
            pops(:, :, run) = pop;
            
         
            ff = sprintf('./data/%s_%d_%d/synstate.dat', CONDITION, BT,run-1);
            ss = load(ff);
            
            for i=1:size(ss,1)
                bid=ss(i,2);
                nid=ss(i,3);
                srcid=ss(i,5);
                bstrength = ss(i,6);
                w=ss(i,7);
                if (srcid >= 0 && bid <= npyrs*nbranches)
                    brweights(srcid+1, bid+1, run) = brweights(srcid+1, bid+1, run) + w;
                    brstrengths(srcid+1, bid+1)=bstrength;
                    nrnweights(srcid+1, nid+1,run) = nrnweights(srcid+1, nid+1,run) + w;
                end
                if (srcid >= 0 && bid <= npyrs*nbranches &&  w > 0.7)
                    branch_syns( bid+1, run) = branch_syns( bid+1, run)+1;
                    
                    branchid = mod(bid, nbranches);
                    
                    if (branchid < BT)
                        bsyns_turn(bid+1, run) = bsyns_turn(bid+1, run)+1;
                    else
                        bsyns_noturn(bid+1, run) = bsyns_noturn(bid+1, run)+1;
                    end

                end
            end

        end
        
        all_brturn{NCOND, NBT} = bsyns_turn;
        all_brnoturn{NCOND, NBT} = bsyns_noturn;
        
        all_br{NCOND,NBT} = branch_syns;
        
        
        tp = sum(pops, 2)*100.0/npyrs;
        m_p = mean(tp, 3);
        s_p = std(tp, 0, 3);
        all_pops{NCOND,NBT} = m_p;
        all_pops_err{NCOND,NBT} = s_p;
        

        
        
        tp = sum(spks, 2)/npyrs;
        m_p = mean(tp, 3);
        s_p = std(tp, 0, 3);
        
        all_ff{NCOND,NBT} = m_p;
        all_ff_err{NCOND,NBT} = s_p;
        
        %figure()
        %bar(m_p);
        %hold on
        %h=errorbar(m_p', s_p')
        %set(h(1), 'color', 'red');set(h(1), 'LineStyle', 'None');
        %hold off;
        %title('Avg Firing rate of pyramidal neurons')
        
        
        
        
        kpost = [];
        kerr = [];
        for i=1:npatterns
            kp = [];
            for run=1:nruns
                kp = [kp trevrolls(pops(i,:,run))];
                %actPpre(i,find(actPpre(i,:)<5)) = 0;
                %actPpost(i,find(actPpost(i,:)<5)) = 0;
            end
            
            kpost(i) = mean(kp);
            kerr(i) = std(kp);
        end
        
        all_kp{NCOND,NBT} = kpost;
        all_kp_err{NCOND,NBT} = kpost;
        
        %     figure()
        %     bar(kpost)
        %     hold on;
        %     h=errorbar(kpost, kerr)
        %     hold off;
        %     title('Sparseness')
    end
    
    
end

% 
% figure()
% z = [];
% 
% for y=1:length(Turnovers)
%     
%     z(:,y) = all_ff{1, y};
% end
% mesh(z)
% tit='FF'
% title(tit);
% export_fig(sprintf('./figs/%s_mesh_%s.pdf',CONDITION, tit), '-transparent')


close all
for NCOND=1:length(Conditions)
    CONDITION=Conditions{NCOND}
    nm = [];
    nm_err = [];
    
    nturn = [];
    nturn_err = [];
    
    nnoturn = [];
    nnoturn_err = [];
    for NBT=1:length(Turnovers)
        BT=Turnovers{NBT}
        
        sb = sum(all_br{NCOND,NBT}>2) ./ sum(all_br{NCOND,NBT}>0);
        nm(NBT) = mean(sb);
        nm_err(NBT) = stderr(sb);
        
        sb = sum(all_brturn{NCOND,NBT}>2) ./ sum(all_brturn{NCOND,NBT}>0);
        nturn(NBT) = mean(sb);
        nturn_err(NBT) = stderr(sb);
        
        sb = sum(all_brnoturn{NCOND,NBT}>2) ./ sum(all_brnoturn{NCOND,NBT}>0);
        nnoturn(NBT) = mean(sb);
        nnoturn_err(NBT) = stderr(sb);


    end
    figure;
    hold on
    errorbar(nm, nm_err, 'b');
    errorbar(nturn, nturn_err, 'g');
    errorbar(nnoturn, nnoturn_err, 'r');
    ylim([.2, .7]);
    legend( 'All branches', 'with Turnover', 'Without T/over');

    set(gca, 'XTick', [1:5])
    set(gca, 'XTickLabel', [0:5:20])
    
    title(sprintf('%s', CONDITION));
    xlabel('# of branches with turnover per neuron');
    ylabel('Percentage of branches with > 2 synapses');
    
    export_fig(sprintf('./figs/%s_BRS.pdf',CONDITION), '-transparent')
end




% close all
% col=hsv(5);
% for NCOND=1:length(Conditions)
%     CONDITION=Conditions{NCOND}
%     figure
%     hold on
%     for NBT=1:length(Turnovers)
%         BT=Turnovers{NBT}
%         errorbar(all_pops{NCOND, NBT}, all_pops_err{NCOND, NBT}, 'color', col(NBT,:) )
%         
%     end
%     legend('0','5','10','15','20 Branches')
%     title(sprintf('%s', CONDITION));
%     xlabel('Pattern #');
%     ylabel('% Active Neurons');
%     
%     hold off
%     export_fig(sprintf('./figs/%s_POPS.pdf',CONDITION), '-transparent')
% end



