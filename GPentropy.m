function [entropy,gprob,surprisal] = GPentropy(graphemes,phonemes,weighting)
%% Grapheme-to-phoneme Entropy, Probability and Surprisal
% Author: Oscar Woolnough (owoolnough.github.io)
% Version 1.0 (28 July 2023)
%
% Inputs: graphemes - nx1 cell array of graphemes
%         phonemes - nx1 cell array of phonemes (optional)
%         weighting - GP weighting to use {'none' (default) 'freq' 'pos' 'freqpos'} (optional)
%
% Outputs: entropy - nxm double array of grapheme-to-phoneme entropy
%          gprob - nxm double array of grapheme probabilities
%          surprisal - nxm double array of surprisal (if phonemes are supplied)
%
% Required files: GP_prob.mat. GP_prob_position.mat

%% Check inputs
if ~exist('phonemes','var'); phonemes = {}; end
assert(iscell(graphemes) && iscell(phonemes),'Grapheme and phoneme inputs must be cell arrays')
if ~isempty(phonemes)
    assert(length(graphemes) == length(phonemes),'Grapheme and phoneme inputs must be the same length')
end

if ~exist('weighting','var')
    weighting = 'none';
end

switch weighting
    case 'none'
        load('GP_prob.mat','graphlist','GPprob','Gfreq');
        GP = GPprob;
    case 'freq'
        load('GP_prob.mat','graphlist','GPfreq','Gfreq');
        GP = GPfreq;
    case 'pos'
        load('GP_prob_position.mat','graphlist','GPprob','Gfreq');
        GP = GPprob;
    case 'freqpos'
        load('GP_prob_position.mat','graphlist','GPfreq','Gfreq');
        GP = GPfreq;
end

%%
full = strings(length(graphemes),max(cellfun(@length,graphemes)));
for ii = 1:length(graphemes)
    full(ii,1:length(graphemes{ii})) = graphemes{ii};
end
%%
entropy = zeros(size(full));
for ii = 1:size(full,1)
    for kk = 1:sum(~strcmp(full(ii,:),''))
        ind = strcmp(full(ii,kk),graphlist);
        if ~contains(weighting,'pos')
            prob = GP(ind,:);
        else
            if kk == 1
                prob = GP(ind,:,1);
            elseif kk == sum(~strcmp(full(ii,:),''))
                prob = GP(ind,:,3);
            else
                prob = GP(ind,:,2);
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

gprob = NaN(size(full));
for ii = 1:size(full,1)
    for jj = 1:sum(~strcmp(full(ii,:),''))
        ind = strcmp(full(ii,jj),graphlist);
        if any(ind)
            gprob(ii,jj) = Gfreq(ind);
        end
    end
end

if ~isempty(phonemes)
    if ~contains(weighting,'pos')
        load('GP_prob.mat','phonlist');
    else
        load('GP_prob_position.mat','phonlist');
    end
    fullp = strings(length(graphemes),max(cellfun(@length,graphemes)));
    for ii = 1:length(graphemes)
        fullp(ii,1:length(phonemes{ii})) = phonemes{ii};
    end
    
    surprisal = NaN(size(full));
    for ii = 1:size(full,1)
        for kk = 1:sum(~strcmp(full(ii,:),''))
            ind1 = strcmp(full(ii,kk),graphlist);
            ind2 = strcmp(fullp(ii,kk),phonlist);
            if any(ind1) && any(ind2)
                if ~contains(weighting,'pos')
                    surprisal(ii,kk) = -log2(GP(ind1,ind2));
                else
                    if kk == 1
                        surprisal(ii,kk) = -log2(GP(ind1,ind2,1));
                    elseif kk == sum(~strcmp(full(ii,:),''))
                        surprisal(ii,kk) = -log2(GP(ind1,ind2,3));
                    else
                        surprisal(ii,kk) = -log2(GP(ind1,ind2,2));
                    end
                end
            end
        end
    end
end
