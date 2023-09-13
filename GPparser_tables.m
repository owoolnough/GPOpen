clear
load('GP_graph.mat')
%%
num_graph = sum(cellfun(@length,graphemes));
allfreq = NaN(1,num_graph);
WF = NaN(size(words));

%% Output Modifiers
lim = 5;
% Split frequency equally for heteronyms
for ii = 1:length(words)
    ind = strcmp(words{ii},words);
    WF(ii) = stats(ii) ./ sum(ind);
end
WF = log10(WF+1);

allgraph = string(cat(2,graphemes{:}));
allphon = string(cat(2,phonemes{:}));

N = 0;
for ii = 1:length(graphemes)
    ind = strcmp(words{ii},words);
    allfreq((1:length(phonemes{ii}))+N) = stats(ii) ./ sum(ind);
    N = N + length(phonemes{ii});
end

graphlist = unique(allgraph);
phonlist = unique(allphon);
%%
problist = zeros(length(graphlist),length(phonlist));
freqlist = zeros(length(graphlist),length(phonlist));

for ii = 1:length(allgraph)
    jj = strcmp(allgraph(ii),graphlist);
    kk = strcmp(allphon(ii),phonlist);
    problist(jj,kk) = problist(jj,kk) + 1;
    freqlist(jj,kk) = freqlist(jj,kk) + allfreq(ii);
end
%%
GPprob = problist ./ repmat(sum(problist,2),1,size(problist,2));
PGprob = problist ./ repmat(sum(problist,1),size(problist,1),1);

GPfreq = freqlist ./ repmat(sum(freqlist,2),1,size(freqlist,2));
PGfreq = freqlist ./ repmat(sum(freqlist,1),size(freqlist,1),1);

Gfreq = sum(problist,2) ./ sum(problist(:));
Pfreq = sum(problist,1) ./ sum(problist(:));

save('data_out/GP_prob.mat','graphlist','phonlist','GPprob','PGprob','GPfreq','PGfreq','Gfreq','Pfreq');

%%
GPtable = cell(length(graphlist),5);
Gvowels = {'A' 'E' 'I' 'O' 'U' 'Y' 'HE' 'HI' 'HO'};
inst = [];
N = 1;
for ii = 1:length(graphlist)
    graphphon = find(GPprob(ii,:)>0);
    indG = cellfun(@strcmp,graphemes,repmat(graphlist(ii),size(graphemes)),'UniformOutput',false);
    for jj = 1:length(graphphon)
        GPtable{N,1} = graphlist{ii};
        GPtable{N,2} = Gfreq(ii);
        GPtable{N,3} = phonlist{graphphon(jj)};
        GPtable{N,4} = GPprob(ii,graphphon(jj));
        
        indP = cellfun(@strcmp,phonemes,repmat(phonlist(graphphon(jj)),size(phonemes)),'UniformOutput',false);
        ind = find(cellfun(@any,cellfun(@and,indG,indP,'UniformOutput',false)));
        GPtable{N,5} = words{ind(stats(ind) == max(stats(ind)))};
        
        inst(N) = problist(ii,graphphon(jj));
        N = N+1;
    end
end

GPtable = sortrows(GPtable,[1 4],{'ascend' 'descend'});
writetable(cell2table(GPtable,'VariableNames',{'Grapheme' 'Probability' 'Phoneme' 'Conditional Probability' 'Example'}),'data_out/GPtable.csv');

GPtable = GPtable(inst>=lim,:);

tmp1 = strtrim(string(num2str(cell2mat(GPtable(:,2)),2)));
tmp2 = strtrim(string(num2str(cell2mat(GPtable(:,4)),2)));
GPtable1 = string(GPtable);
GPtable1(:,2) = tmp1;
GPtable1(:,4) = tmp2;

GPtable_v = GPtable1(startsWith(GPtable(:,1),Gvowels),:); % Table 1
GPtable_c = GPtable1(~startsWith(GPtable(:,1),Gvowels),:); % Table 2

%%
PGtable = cell(length(graphlist),5);
Pvowels = {'AA' 'AE' 'AH' 'AO' 'AW' 'AX' 'AXR' 'AY' 'EH' 'ER' 'EY' 'IH' 'IX' 'IY' 'OW' 'OY' 'UH' 'UW' 'UX'};
inst = [];
N = 1;
for ii = 1:length(phonlist)
    graphphon = find(GPprob(:,ii)>0);
    indG = cellfun(@strcmp,phonemes,repmat(phonlist(ii),size(phonemes)),'UniformOutput',false);
    for jj = 1:length(graphphon)
        PGtable{N,1} = phonlist{ii};
        PGtable{N,2} = Pfreq(ii);
        PGtable{N,3} = graphlist{graphphon(jj)};
        PGtable{N,4} = PGprob(graphphon(jj),ii);
        
        indP = cellfun(@strcmp,graphemes,repmat(graphlist(graphphon(jj)),size(graphemes)),'UniformOutput',false);
        ind = find(cellfun(@any,cellfun(@and,indG,indP,'UniformOutput',false)));
        PGtable{N,5} = words{ind(stats(ind) == max(stats(ind)))};
        
        inst(N) = problist(graphphon(jj),ii);
        N = N+1;
    end
end


PGtable = sortrows(PGtable,[1 4],{'ascend' 'descend'});
writetable(cell2table(PGtable,'VariableNames',{'Phoneme' 'Probability' 'Grapheme' 'Conditional Probability' 'Example'}),'data_out/PGtable.csv');

PGtable = PGtable(inst>=lim,:);

tmp1 = strtrim(string(num2str(cell2mat(PGtable(:,2)),2)));
tmp2 = strtrim(string(num2str(cell2mat(PGtable(:,4)),2)));
PGtable1 = string(PGtable);
PGtable1(:,2) = tmp1;
PGtable1(:,4) = tmp2;

PGtable_v = PGtable1(ismember(PGtable(:,1),Pvowels),:); % Table 3
PGtable_c = PGtable1(~ismember(PGtable(:,1),Pvowels),:); % Table 4

%% Table 5
dubgraphlist = graphlist(strlength(graphlist)>1 & ~contains(graphlist,'_E'));
dubgraphlist = dubgraphlist(ismember(dubgraphlist,GPtable(:,1)));
GGprob = NaN(size(dubgraphlist));
GGprobS = NaN(size(dubgraphlist));
GGfreq = NaN(size(dubgraphlist));
GGfreqS = NaN(size(dubgraphlist));
for ii = 1:length(dubgraphlist)
    ind = contains(words,dubgraphlist{ii});
    
    ind0 = cellfun(@any,cellfun(@contains,graphemes,repmat(dubgraphlist(ii),length(graphemes),1),'UniformOutput',false));
    indE = cellfun(@any,cellfun(@strcmp,graphemes,repmat(dubgraphlist(ii),length(graphemes),1),'UniformOutput',false));
    
    GGprob(ii) = sum(ind0)./sum(ind);
    GGprobS(ii) = sum(indE)./sum(ind);
    
    GGfreq(ii) = sum(ind0.*WF)./sum(ind.*WF);
    GGfreqS(ii) = sum(indE.*WF)./sum(ind.*WF);
end

GGtable = cat(2,cellstr(dubgraphlist'),num2cell(GGprobS'),num2cell(GGprob'));
writetable(cell2table(GGtable,'VariableNames',{'Grapheme' 'Specific Probability' 'Generic Probability'}),'data_out/GGtable.csv');

GGtable = [dubgraphlist' strtrim(string(num2str(GGprobS',3))) strtrim(string(num2str(GGprob',3)))];

save('data_out/GG_prob.mat','dubgraphlist','GGprobS','GGprob','GGfreqS','GGprob');

%% Figure 1
figure
set(gcf,'Color','w')
% Grapheme-Phoneme Entropy
subplot(2,2,1)
gpentropy = GPentropy(num2cell(graphlist));
histogram(gpentropy(:),0:0.3:3)
xlabel('Entropy (bits)','FontWeight','bold')
ylabel('# Graphemes','FontWeight','bold')
set(gca,'Layer','top','FontSize',12,'LineWidth',2)
box off

% Phoneme-Grapheme Entropy
subplot(2,2,2)
pgentropy = PGentropy(num2cell(phonlist));
histogram(pgentropy(:),0:0.3:3)
xlabel('Entropy (bits)','FontWeight','bold')
ylabel('# Phonemes','FontWeight','bold')
set(gca,'Layer','top','FontSize',12,'LineWidth',2)
box off

% Grapheme-Phoneme Surprisal
subplot(2,2,3)
gps = -log2(GPprob(GPprob>0));
histogram(gps(:),0:2:24)
xlabel('Surprisal (bits)','FontWeight','bold')
ylabel('# Grapheme-Phoneme Pairs','FontWeight','bold')
set(gca,'Layer','top','FontSize',12,'LineWidth',2)
box off

% Phoneme-Grapheme Surprisal
subplot(2,2,4)
pgs = -log2(PGprob(PGprob>0));
histogram(pgs(:),0:2:24)
xlabel('Surprisal (bits)','FontWeight','bold')
ylabel('# Phoneme-Grapheme Pairs','FontWeight','bold')
set(gca,'Layer','top','FontSize',12,'LineWidth',2)
box off
colororder([0.6 0.6 0.6])
export_fig('figures/entropy_surprisal_distribution','-pdf','-painters')