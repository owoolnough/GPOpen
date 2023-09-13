clear
%% Load Word Lists
iphod = readtable('IPhOD2_Words.txt');
exclude = readmatrix('GP_exclude.csv','OutputType','string');
heteronym = readmatrix('CMU_heteronym.csv','OutputType','string');
over = readmatrix('CMU_overwrite.csv','OutputType','string');
CMU = readmatrix('CMU_dict.txt','Delimiter','  ','OutputType','string');
CMU = erase(CMU,{'0' '1' '2' '(' ')' '''' '-'});
CMU = strrep(CMU,' ','.');

ind = find((log10(iphod.SFreq)>-1) & (strlength(iphod.Word)>=2) & ~ismember(upper(iphod.Word),exclude));
words = upper(string(iphod.Word(ind)));
phonlist = string(iphod.UnTrn(ind));
CMU = CMU(ismember(CMU(:,1),words),:);

words0 = unique(words);
for ii = length(words0):-1:1
    ind = find(strcmp(words0{ii},CMU(:,1)),1);
    wind = strcmp(words0{ii},words);
    if ~isempty(ind)
        if any(strcmp(words0{ii},heteronym))
            ind0 = strcmp(words0{ii},CMU(:,1));
            words(wind) = [];
            phonlist(wind) = [];
            words = [words; repmat(words0(ii),sum(ind0),1)];
            phonlist = [phonlist; CMU(ind0,2)];
        else
            phonlist(wind) = CMU(ind,2);
        end
    end
end

[words,I] = sort(words);
phonlist = phonlist(I);

phonlist = strrep(phonlist,'HH.W','W');
for ii = 1:size(over,1)
    phonlist(strcmpi(words,over{ii,1})) = over{ii,2};
end
[~,ind0] = unique(strcat(words,phonlist));
words = words(ind0);
phonlist = phonlist(ind0);

save('data_out/GP_testset.mat','words','phonlist');

%% Run GP Parser
[graphemes,phonemes,fix] = GPparser(words,phonlist);

%% List of Unique Graphemes
graphlist = [];
for ii = 1:length(graphemes)
    if ~fix(ii)
        graphlist = unique([graphlist string(graphemes{ii})]);
    end
end

%% Error Rate
error_rate = ((sum(fix)/length(fix))*100);
error_list = words(fix);

%% Exclude Failed Words
words = words(~fix);
graphemes = graphemes(~fix);
phonemes = phonemes(~fix);

%% Extract Word Frequencies
stats = NaN(length(words),1);
for s = 1:length(words)
    indF = find(strcmpi(words(s),iphod.Word),1);
    if ~isempty(indF)
        stats(s,1) = iphod.SFreq(indF);      %Log word frequency
    end
end

%% Save Output
save('data_out/GP_graph.mat','words','graphemes','phonemes','stats')