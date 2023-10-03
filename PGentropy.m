function [entropy,pprob,surprisal] = PGentropy(phonemes,graphemes)
%% Phoneme-to-grapheme Entropy, Probability and Surprisal
% Author: Oscar Woolnough (owoolnough.github.io)
% Version 1.0 (28 July 2023)
%
% Inputs: phonemes - nx1 cell array of phonemes
%         graphemes - nx1 cell array of graphemes (optional)
%         weighting - GP weighting to use {'none' (default) 'freq' 'pos' 'freqpos'} (optional)
%
% Outputs: entropy - nxm double array of phoneme-to-grapheme entropy
%          pprob - nxm double array of phoneme probabilities
%          surprisal - nxm double array of surprisal (if graphemes are
%          supplied)
%
% Required files: GP_prob.mat, GP_prob_position.mat

%% Check inputs
if ~exist('graphemes','var'); graphemes = {}; end
assert(iscell(graphemes) && iscell(phonemes),'Grapheme and phoneme inputs must be cell arrays')
if ~isempty(graphemes)
    assert(length(graphemes) == length(phonemes),'Grapheme and phoneme inputs must be the same length')
end

if ~exist('weighting','var')
    weighting = 'none';
end

switch weighting
    case 'none'
        load('GP_prob.mat','phonlist','PGprob','Pfreq');
        PG = PGprob;
    case 'freq'
        load('GP_prob.mat','phonlist','PGfreq','Pfreq');
        PG = PGfreq;
    case 'pos'
        load('GP_prob_position.mat','phonlist','PGprob','Pfreq');
        PG = PGprob;
    case 'freqpos'
        load('GP_prob_position.mat','phonlist','PGfreq','Pfreq');
        PG = PGfreq;
end

%%
full = strings(length(phonemes),max(cellfun(@length,phonemes)));
for ii = 1:length(phonemes)
    full(ii,1:length(phonemes{ii})) = phonemes{ii};
end
%%
entropy = zeros(size(full));
for ii = 1:size(full,1)
    for kk = 1:sum(~strcmp(full(ii,:),''))
        ind = strcmp(full(ii,kk),phonlist);
        if ~contains(weighting,'pos')
            prob = PG(ind,:);
        else
            if kk == 1
                prob = PG(ind,:,1);
            elseif kk == sum(~strcmp(full(ii,:),''))
                prob = PG(ind,:,3);
            else
                prob = PG(ind,:,2);
            end
        end
        for jj = 1:length(prob)
            if prob(jj) > 0
                entropy(ii,kk) = entropy(ii,kk) - prob(jj).*log2(prob(jj));
            end
        end
    end
end
entropy(strcmp(full,'')) = NaN;

pprob = NaN(size(full));
for ii = 1:size(full,1)
    for jj = 1:sum(~strcmp(full(ii,:),''))
        pprob(ii,jj) = Pfreq(strcmp(full(ii,jj),phonlist));
    end
end

if ~isempty(graphemes)
    if ~contains(weighting,'pos')
        load('GP_prob.mat','graphlist');
    else
        load('GP_prob_position.mat','graphlist');
    end
    
    fullg = strings(length(phonemes),max(cellfun(@length,phonemes)));
    for ii = 1:length(graphemes)
        fullg(ii,1:length(graphemes{ii})) = graphemes{ii};
    end
    
    surprisal = NaN(size(full));
    for ii = 1:size(full,1)
        for kk = 1:sum(~strcmp(full(ii,:),''))
            ind1 = strcmp(full(ii,kk),phonlist);
            ind2 = strcmp(fullg(ii,kk),graphlist);
            if ~contains(weighting,'pos')
                surprisal(ii,kk) = -log2(PG(ind2,ind1));
            else
                if kk == 1
                    surprisal(ii,kk) = -log2(PG(ind2,ind1,1));
                elseif kk == sum(~strcmp(full(ii,:),''))
                    surprisal(ii,kk) = -log2(PG(ind2,ind1,3));
                else
                    surprisal(ii,kk) = -log2(PG(ind2,ind1,2));
                end
            end
        end
    end
end
