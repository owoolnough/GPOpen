function graphemes = NGparser(words,weighting)
%% Naive Grapheme Parser
% Author: Oscar Woolnough (owoolnough.github.io)
% Version 1.0 (28 July 2023)
%
% Inputs: words - nx1 string array of words (e.g. "DICTIONARY")
%         weighting - GP weighting to use {'none' (default) 'freq'} (optional)
%
% Outputs: graphemes - nx1 cell array of graphemes
%
% Required files: GG_prob.mat

%% Check inputs
assert(isstring(words),'Inputs must be string arrays')

%% Load Grapheme-Phoneme Correspondence Table
if ~exist('weighting','var')
    weighting = 'none';
end

switch weighting
    case 'none'
        load('GG_prob.mat','dubgraphlist','GGprobS');
        GG = GGprobS;
    case 'freq'
        load('GG_prob.mat','dubgraphlist','GGfreqS');
        GG = GGfreqS;
end

ind = GG<0.5;
dubgraphlist(ind) = [];
GG(ind) = [];

[~,I] = sortrows([strlength(dubgraphlist); GG]','descend');
dubgraphlist = dubgraphlist(I);

%%
graphemes = cell(length(words),1);
for ii = 1:length(words)
    word = upper(words{ii});
    while ~isempty(word)
        ind = false(length(dubgraphlist),1);
        for jj = 1:length(dubgraphlist)
            ind(jj) = startsWith(word,dubgraphlist{jj});
        end
        
        if any(ind)
            if ~(sum(ind) == 1)
                ind = find(ind,1,'first');
            end
            graphemes{ii}{end+1} = dubgraphlist{ind};
            word(1:length(dubgraphlist{ind}))=[];
        else
            graphemes{ii}{end+1} = word(1);
            word(1)=[];
        end
    end
end
