function [graphemes,phonemes,fix] = GPparser(words,phonlist)
%% Grapheme-Phoneme Parser
% Author: Oscar Woolnough (owoolnough.github.io)
% Version 1.0 (28 July 2023)
%
% Inputs: words - nx1 string array of words (e.g. "DICTIONARY")
%        phonlist - nx1 string array of ARPABET phonemes with . delimiters (e.g. "D.IH.K.SH.AH.N.EH.R.IY")
%
% Outputs: graphemes - nx1 cell array of graphemes
%          phonemes - nx1 cell array of grapheme-associated phonemes/biphonemes
%          fix - nx1 logical array indicating words for which the parser has failed
%
% Required files: GraphemePhoneme.csv

%% Check inputs
assert(isstring(words) && isstring(phonlist),'Inputs must be string arrays')
assert(length(words) == length(phonlist),'Number of words and phoneme strings does not match')

%% Load Grapheme-Phoneme Correspondence Table
GP = table2cell(readtable('GraphemePhoneme.csv','ReadVariableNames',false));
GPphon = string(GP(:,1));
GPmap = cell(length(GPphon),1);
for ii = 1:length(GPphon)
    GPmap{ii} = split(GP{ii,2},'.')';
end

%%
words = upper(words);
phonlist = upper(phonlist);
phonlist = erase(phonlist,{'0' '1' '2' '(' ')' '''' '-'});

graphemes = cell(length(words),1);
phonemes = cell(length(words),1);
fix = false(length(words),1);

%% Group Y.UH and K.W Biphonemes
for ii = 1:length(phonemes)
    phonemes{ii} = split(phonlist(ii),'.')';
    tmp = intersect(find(strcmp(phonemes{ii},'Y'))+1,find(strcmp(phonemes{ii},'UH')));
    if tmp
        phonemes{ii}(tmp) = [];
        phonemes{ii}(tmp-1) = 'Y.UH';
    end
    if contains(words{ii},'QU')
        tmp = intersect(find(strcmp(phonemes{ii},'K'))+1,find(strcmp(phonemes{ii},'W')));
        if tmp
            phonemes{ii}(tmp) = [];
            phonemes{ii}(tmp-1) = 'K.W';
        end
    end
end

%% Parse Graphemes
for ii = 1:length(phonemes)
    word = words{ii};
    for jj = 1:length(phonemes{ii})
        if jj>length(phonemes{ii}); continue; end
        
        if strcmp(word,'ES') && (jj == length(phonemes{ii})) && any(strcmp(phonemes{ii}(jj),{'S' 'Z'})) && jj>2
            graphemes{ii}(1,jj) = {'S'};
            if startsWith(phonemes{ii}(jj-2),{'A' 'E' 'I' 'O' 'U' 'Y'})
                graphemes{ii}(1,jj-2) = strcat(graphemes{ii}(1,jj-2),'_E');
            elseif startsWith(phonemes{ii}(jj-3),{'A' 'E' 'I' 'O' 'U' 'Y'})
                graphemes{ii}(1,jj-3) = strcat(graphemes{ii}(1,jj-3),'__E');
            else
                graphemes{ii}(1,jj-1) = strcat(graphemes{ii}(1,jj-1),'E');
            end
            word = '';
        elseif startsWith(word,'U') && strcmp(phonemes{ii}(jj),'Y') && any(strcmp(phonemes{ii}(jj+1),{'UW' 'AH'}))% && ~startsWith(word,'UA')
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            if startsWith(word,'UE')
                if startsWith(word,'UEUE')
                    graphemes{ii}(1,jj) = {'UEUE'};
                    word(1:4) = [];
                elseif jj>=length(phonemes{ii})
                    graphemes{ii}(1,jj) = {'UE'};
                    word(1:2) = [];
                elseif any(strcmp(phonemes{ii}(jj+1),{'AH' 'EH'}))
                    graphemes{ii}(1,jj) = {'U'};
                    word(1) = [];
                else
                    graphemes{ii}(1,jj) = {'UE'};
                    word(1:2) = [];
                end
            elseif startsWith(word,'UU')
                graphemes{ii}(1,jj) = {'UU'};
                word(1:2) = [];
            elseif strcmp(word,'UT')
                graphemes{ii}(1,jj) = {'UT'};
                word(1:2) = [];
            elseif startsWith(word,'UA') && ~any(strcmp(phonemes{ii}(jj+1),{'AH' 'EY' 'W'}))
                graphemes{ii}(1,jj) = {'UA'};
                word(1:2) = [];
            elseif startsWith(word,'UA')
                graphemes{ii}(1,jj) = {'U'};
                word(1) = [];
            else
                graphemes{ii}(1,jj) = {'U'};
                word(1) = [];
            end
        elseif startsWith(word,'A') && any(strcmp(phonemes{ii}(jj),{'W' 'Y'})) && any(strcmp(phonemes{ii}(jj+1),{'AH' 'EY' 'AE' 'EH'}))
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'A'};
            word(1) = [];
        elseif startsWith(word,'EAU') && any(strcmp(phonemes{ii}(jj),{'Y'})) && any(strcmp(phonemes{ii}(jj+1),{'UW'}))
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'EAU'};
            word(1:3) = [];
        elseif startsWith(word,'RU') && strcmp(phonemes{ii}(jj),'AH') && any(strcmp(phonemes{ii}(jj+1),{'W'}))
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'RU'};
            word(1) = [];
        elseif startsWith(word,'EW') && strcmp(phonemes{ii}(jj),'Y') && strcmp(phonemes{ii}(jj+1),{'UW'})
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'EW'};
            word(1:2) = [];
        elseif startsWith(word,'EU') && strcmp(phonemes{ii}(jj),'Y') && strcmp(phonemes{ii}(jj+1),{'UW'})
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'EU'};
            word(1:2) = [];
        elseif startsWith(word,'M') && strcmp(phonemes{ii}(jj),'AH') && strcmp(phonemes{ii}(jj+1),{'M'})
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'M'};
            word(1) = [];
        elseif startsWith(word,'ZZ') && strcmp(phonemes{ii}(jj),'T') && strcmp(phonemes{ii}(jj+1),{'S'})
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'ZZ'};
            word(1:2) = [];
        elseif startsWith(word,'O') && strcmp(phonemes{ii}(jj),'W') && strcmp(phonemes{ii}(jj+1),{'AH'})
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            if startsWith(word,'OU')
                graphemes{ii}(1,jj) = {'OU'};
                word(1:2) = [];
            else
                graphemes{ii}(1,jj) = {'O'};
                word(1) = [];
            end
        elseif startsWith(word,'I') && strcmp(phonemes{ii}(jj),'W') && strcmp(phonemes{ii}(jj+1),{'AH'})
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'I'};
            word(1) = [];
        elseif startsWith(word,'X')
            if length(phonemes{ii})>jj
                if any(strcmp(phonemes{ii}(jj),{'G' 'K'})) && any(strcmp(phonemes{ii}(jj+1),{'Z' 'S' 'SH' 'ZH'}))
                    phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
                    phonemes{ii}(jj+1) = [];
                end
            end
            graphemes{ii}(1,jj) = {'X'};
            word(1) = [];
            if startsWith(word,'C') && ~any(strcmp(phonemes{ii}(jj+1),{'C' 'S' 'SH' 'K' 'CH'}))
                graphemes{ii}(1,jj) = {'XC'};
                word(1) = [];
            elseif startsWith(word,'I') && (~any(strcmp(phonemes{ii}(jj+1),{'IH' 'IY' 'AY' 'AH'})) || any(contains(words{ii},{'XIOU'}))) && ~any(contains(words{ii},{'MEXI' 'XINS' 'AXIS' 'XIB'}))
                graphemes{ii}(1,jj) = {'XI'};
                word(1) = [];
            elseif startsWith(word,'H') && ~any(strcmp(phonemes{ii}(jj+1),{'HH'}))
                graphemes{ii}(1,jj) = {'XH'};
                word(1) = [];
            end
        elseif strcmp(word,'LES')
            if length(phonemes{ii})>jj && ~any(strcmp(phonemes{ii}(jj+1),{'S' 'Z' 'IY' 'EH'}))
                phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
                phonemes{ii}(jj+1) = [];
            end
            if ~any(strcmp(phonemes{ii}(jj+1),{'IY' 'EH'}))
                graphemes{ii}(1,jj) = {'LE'};
                word(1:2) = [];
            else
                graphemes{ii}(1,jj) = {'L'};
                word(1) = [];
            end
            if jj>1; if size(graphemes{ii},2)>=(jj-1); if strcmp(graphemes{ii}{1,jj}(end),'E') && contains(graphemes{ii}{1,jj-1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-1) = strcat(graphemes{ii}(1,jj-1),'_E'); graphemes{ii}(1,jj) = {'L'}; end; end; end
        elseif strcmp(word,'GUE') && strcmp(phonemes{ii}(jj),'G') && length(phonemes{ii})==jj
            graphemes{ii}(1,jj) = {'GUE'};
            word = '';
        elseif startsWith(word,'LE')
            if length(phonemes{ii})>jj
                if ~any(strcmp(phonemes{ii}(jj+1),{'IY' 'ER' 'IH' 'UW' 'D' 'Z' 'S' 'EH' 'EY' 'HH' 'Y' 'AH' 'AY' 'M'})) && jj>1
                    phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
                    phonemes{ii}(jj+1) = [];
                    graphemes{ii}(1,jj) = {'LE'};
                    word(1:2) = [];
                elseif any(strcmp(phonemes{ii}(jj+1),{'Z' 'S' 'HH' 'M'}))
                    graphemes{ii}(1,jj) = {'LE'};
                    word(1:2) = [];
                    if jj>1; if size(graphemes{ii},2)>=(jj-1); if strcmp(graphemes{ii}{1,jj}(end),'E') && contains(graphemes{ii}{1,jj-1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-1) = strcat(graphemes{ii}(1,jj-1),'_E'); graphemes{ii}(1,jj) = {'L'}; end; end; end
                    if jj>2; if size(graphemes{ii},2)>=(jj-2); if strcmp(graphemes{ii}{1,jj}(end),'E') && contains(graphemes{ii}{1,jj-2}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-2) = strcat(graphemes{ii}(1,jj-2),'__E'); graphemes{ii}(1,jj) = {'L'}; end; end; end
                else
                    graphemes{ii}(1,jj) = {'L'};
                    word(1) = [];
                end
            else
                graphemes{ii}(1,jj) = {'LE'};
                word(1:2) = [];
                if jj>1; if size(graphemes{ii},2)>=(jj-1); if strcmp(graphemes{ii}{1,jj}(end),'E') && contains(graphemes{ii}{1,jj-1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-1) = strcat(graphemes{ii}(1,jj-1),'_E'); graphemes{ii}(1,jj) = {'L'}; end; end; end
                if jj>2; if size(graphemes{ii},2)>=(jj-2); if strcmp(graphemes{ii}{1,jj}(end),'E') && contains(graphemes{ii}{1,jj-2}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-2) = strcat(graphemes{ii}(1,jj-2),'__E'); graphemes{ii}(1,jj) = {'L'}; end; end; end
            end
        elseif startsWith(word,'L') && strcmp(phonemes{ii}(jj),'AH') && any(strcmp(phonemes{ii}(jj+1),{'L'}))
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'L'};
            word(1) = [];
        elseif startsWith(word,'OI') && strcmp(phonemes{ii}(jj),'W') && any(strcmp(phonemes{ii}(jj+1),{'AA'}))
            phonemes{ii}(jj) = strcat(phonemes{ii}(jj),'.',phonemes{ii}(jj+1));
            phonemes{ii}(jj+1) = [];
            graphemes{ii}(1,jj) = {'OI'};
            word(1:2) = [];
        else
            ind = strcmp(phonemes{ii}(jj),GPphon);
            if ~any(ind)
                fix(ii) = true;
                continue;
            end
            A = false(1,length(GPmap{ind}));
            for kk = 1:length(GPmap{ind})
                A(kk) = startsWith(word,GPmap{ind}(kk));
            end
            len = strlength(GPmap{ind});
            if ~any(A)
                fix(ii) = true;
                continue;
            end
            indL = (len == max(len(A)));
            
            if jj<length(phonemes{ii})
                switch GPmap{ind}{indL & A}
                    case 'MB'
                        if strcmp(phonemes{ii}(jj+1),'B'); A(strcmp('MB',GPmap{ind})) = false; end
                    case 'CC'
                        if strcmp(phonemes{ii}(jj+1),'S'); A(strcmp('CC',GPmap{ind})) = false; end
                    case 'EA'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'AE' 'EY' 'AA' 'ER'})); A(strcmp('EA',GPmap{ind})) = false; end
                    case 'OA'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'EY' 'AE' 'AA'})); A(strcmp('OA',GPmap{ind})) = false; end
                    case 'SCI'
                        if any(strcmp(phonemes{ii}(jj+1),{'IY' 'AH' 'IH'})); A(strcmp('SCI',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'SCIOUS'})); A(strcmp('SCI',GPmap{ind})) = true; end
                        if strcmp(phonemes{ii}(jj+1),'K'); A(strcmp('SC',GPmap{ind})) = false; end
                    case 'SCH'
                        if any(strcmp(phonemes{ii}(jj+1),{'K' 'CH'})); A(strcmp('SCH',GPmap{ind})) = false; end
                        if any(strcmp(phonemes{ii}(jj+1),{'K' 'CH'})); A(strcmp('SC',GPmap{ind})) = false; end
                    case 'SC'
                        if strcmp(phonemes{ii}(jj+1),'K'); A(strcmp('SC',GPmap{ind})) = false; end
                    case 'GE'
                        if any(strcmp(phonemes{ii}(jj+1),{'IH' 'AH' 'EH' 'D' 'AO' 'IY' 'ER' 'AA'})); A(strcmp('GE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'GEOUS' 'GEON'})); A(strcmp('GE',GPmap{ind})) = true; end
                    case 'ZE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'IH' 'EH' 'IY'})); A(strcmp('ZE',GPmap{ind})) = false; end
                    case 'KE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'IY' 'ER' 'AE' 'T' 'AH' 'Y' 'IH'})); A(strcmp('KE',GPmap{ind})) = false; end
                    case 'EO'
                        if any(strcmp(phonemes{ii}(jj+1),{'OW' 'AA' 'AH' 'AO'})); A(strcmp('EO',GPmap{ind})) = false; end
                    case 'IE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'EY' 'EH' 'IH'})); A(strcmp('IE',GPmap{ind})) = false; end
                    case 'MN'
                        if strcmp(phonemes{ii}(jj+1),'N'); A(strcmp('MN',GPmap{ind})) = false; end
                    case 'IS'
                        if any(strcmp(phonemes{ii}(jj+1),{'Z' 'S'})); A(strcmp('IS',GPmap{ind})) = false; end
                    case 'NG'
                        if any(strcmp(phonemes{ii}(jj+1),{'G' 'K'})); A(strcmp('NG',GPmap{ind})) = false; end
                    case 'SE'
                        if any(strcmp(phonemes{ii}(jj+1),{'IY' 'AH' 'EH' 'IH' 'OW' 'UW' 'T' 'ER' 'AA' 'AY' 'EY'})); A(strcmp('SE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'USET' 'USEO'})); A(strcmp('SE',GPmap{ind})) = true; end
                    case 'BE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'EH' 'IH' 'IY' 'Y' 'EY' 'ER'})); A(strcmp('BE',GPmap{ind})) = false; end
                    case 'EAR'
                        if strcmp(phonemes{ii}(jj+1),'R'); A(strcmp('EAR',GPmap{ind})) = false; end
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'AE' 'EY'})); A(strcmp('EA',GPmap{ind})) = false; end
                    case 'ME'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'IY' 'AH' 'IH' 'D' 'ER' 'EY'})); A(strcmp('ME',GPmap{ind})) = false; end
                    case 'RE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'EH' 'IH' 'IY' 'OW' 'UW' 'EY' 'D'})); A(strcmp('RE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'MOREOVER'})); A(strcmp('RE',GPmap{ind})) = true; end
                    case 'EI'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'IH' 'AY'})); A(strcmp('EI',GPmap{ind})) = false; end
                    case 'QU'
                        if strcmp(phonemes{ii}(jj+1),'Y'); A(strcmp('QU',GPmap{ind})) = false; end
                    case 'DGE'
                        if any(strcmp(phonemes{ii}(jj+1),{'IH' 'AH' 'ER'})); A(strcmp('DGE',GPmap{ind})) = false; end
                    case 'AG'
                        if any(strcmp(phonemes{ii}(jj+1),{'G' 'JH'})); A(strcmp('AG',GPmap{ind})) = false; end
                    case 'CE'
                        if any(strcmp(phonemes{ii}(jj+1),{'IY' 'ER' 'AE' 'EH' 'IH' 'AH' 'T' 'EY'})); A(strcmp('CE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'CEOUS' 'PEACETIME' 'RACETRACK'})); A(strcmp('CE',GPmap{ind})) = true; end
                    case 'VE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'EY' 'AH' 'IH' 'ER' 'D' 'S' 'Z' 'IY'})); A(strcmp('VE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'EAVES' 'GRAVESTO' 'LIVESTOCK'})); A(strcmp('VE',GPmap{ind})) = true; end
                    case 'NE'
                        if any(strcmp(phonemes{ii}(jj+1),{'UW' 'AH' 'IY' 'EY' 'EH' 'IH' 'D' 'ER' 'AY' 'UH' 'Y'})); A(strcmp('NE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'VINEYARD'})); A(strcmp('NE',GPmap{ind})) = true; end
                    case 'TI'
                        if strcmp(phonemes{ii}(jj+1),'IY'); A(strcmp('TI',GPmap{ind})) = false; end
                    case 'CK'
                        if strcmp(phonemes{ii}(jj+1),{'N'}); A(strcmp('CK',GPmap{ind})) = false; end
                    case 'GUE'
                        if any(strcmp(phonemes{ii}(jj+1),{'Y' 'EH' 'IH'})); A(strcmp('GUE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'LEAGUE'})); A(strcmp('GUE',GPmap{ind})) = true; end
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'AH' 'Y'})); A(strcmp('GU',GPmap{ind})) = false; end
                    case 'GU'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'AH' 'Y' 'IH' 'AA' 'AY' 'W' 'UW' 'Y.UH' 'ER'})); A(strcmp('GU',GPmap{ind})) = false; end
                    case 'SI'
                        if any(strcmp(phonemes{ii}(jj+1),{'IH' 'AY' 'AH' 'IY'})); A(strcmp('SI',GPmap{ind})) = false; end
                        if contains(words{ii},'SION'); A(strcmp('SI',GPmap{ind})) = true; end
                    case 'TU'
                        if strcmp(phonemes{ii}(jj+1),{'UW'}); A(strcmp('TU',GPmap{ind})) = false; end
                    case 'UI'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'IH'})); A(strcmp('UI',GPmap{ind})) = false; end
                    case 'OO'
                        if any(strcmp(phonemes{ii}(jj+1),{'AO' 'AA'})); A(strcmp('OO',GPmap{ind})) = false; end
                    case 'TW'
                        if strcmp(phonemes{ii}(jj+1),{'W'}); A(strcmp('TW',GPmap{ind})) = false; end
                    case 'SW'
                        if strcmp(phonemes{ii}(jj+1),{'W'}); A(strcmp('SW',GPmap{ind})) = false; end
                    case 'ST'
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'CH' 'TH'})); A(strcmp('ST',GPmap{ind})) = false; end
                    case 'TE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'AH' 'IY' 'IH' 'ER' 'R' 'EY' 'S' 'UW' 'AY'})); A(strcmp('TE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'TASTES' 'UTESY' 'STATES'})); A(strcmp('TE',GPmap{ind})) = true; end
                    case 'CI'
                        if any(strcmp(phonemes{ii}(jj+1),{'IY' 'Y' 'IH'})); A(strcmp('CI',GPmap{ind})) = false; end
                    case 'PE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'IY' 'IH' 'T' 'AH' 'ER' 'R' 'Y'})); A(strcmp('PE',GPmap{ind})) = false; end
                        if any(strcmp(words{ii},{'OPERA' 'TYPEWRITER' 'TYPEWRITTEN'})); A(strcmp('PE',GPmap{ind})) = true; end
                    case 'OE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'EH' 'IH'})); A(strcmp('OE',GPmap{ind})) = false; end
                    case 'IA'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'AE' 'IH' 'EH' 'EY' 'ER'})); A(strcmp('IA',GPmap{ind})) = false; end
                    case 'SHI'
                        if any(strcmp(phonemes{ii}(jj+1),{'IH' 'AY' 'AH' 'ER'})); A(strcmp('SHI',GPmap{ind})) = false; end
                    case 'ND'
                        if any(strcmp(phonemes{ii}(jj+1),{'D' 'JH'})); A(strcmp('ND',GPmap{ind})) = false; end
                    case 'GG'
                        if any(strcmp(phonemes{ii}(jj+1),{'JH'})); A(strcmp('GG',GPmap{ind})) = false; end
                    case 'NGU'
                        if any(strcmp(phonemes{ii}(jj+1),{'G' 'AH'})); A(strcmp('NGU',GPmap{ind})) = false; end
                        if strcmp(phonemes{ii}(jj+1),'G'); A(strcmp('NG',GPmap{ind})) = false; end
                    case 'UE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'EH' 'IH'})); A(strcmp('UE',GPmap{ind})) = false; end
                    case 'GI'
                        if any(strcmp(phonemes{ii}(jj+1),{'AY' 'IH' 'AH' 'IY'})); A(strcmp('GI',GPmap{ind})) = false; end
                        if contains(words{ii},'GIOU'); A(strcmp('GI',GPmap{ind})) = true; end
                    case 'FE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'IY' 'Y' 'IH' 'AH' 'ER' 'R' 'EY' 'T' 'AY'})); A(strcmp('FE',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'SAFET' 'LIFETIME'})); A(strcmp('FE',GPmap{ind})) = true; end
                    case 'TH'
                        if any(strcmp(phonemes{ii}(jj+1),{'HH' 'TH'})); A(strcmp('TH',GPmap{ind})) = false; end
                        if contains(words{ii},'THH'); A(strcmp('TH',GPmap{ind})) = true; end
                    case 'OWE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH'})); A(strcmp('OWE',GPmap{ind})) = false; end
                        if strcmp(phonemes{ii}(jj+1),{'W'}); A(strcmp('OW',GPmap{ind})) = false; end
                    case 'OW'
                        if strcmp(phonemes{ii}(jj+1),{'W'}); A(strcmp('OW',GPmap{ind})) = false; end
                    case 'RPS'
                        if strcmp(phonemes{ii}(jj+1),{'P'}); A(strcmp('RPS',GPmap{ind})) = false; end
                    case 'CO'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'OW' 'AO' 'AA' 'AW' 'ER' 'W' 'OY' 'UW' 'UH'})); A(strcmp('CO',GPmap{ind})) = false; end
                    case 'OUGH'
                        if any(strcmp(phonemes{ii}(jj+1),{'F'})); A(strcmp('OUGH',GPmap{ind})) = false; end
                        if any(contains(words{ii},{'THOROUGHFARE'})); A(strcmp('OUGH',GPmap{ind})) = true; end
                    case 'GH'
                        if any(strcmp(phonemes{ii}(jj+1),{'HH'})); A(strcmp('GH',GPmap{ind})) = false; end
                    case 'RH'
                        if any(strcmp(phonemes{ii}(jj+1),{'HH'})); A(strcmp('RH',GPmap{ind})) = false; end
                    case 'DE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EH' 'IY' 'IH' 'T' 'AH' 'ER' 'R' 'EY' 'UW'})); A(strcmp('DE',GPmap{ind})) = false; end
                        if contains(words{ii},'SIDET'); A(strcmp('DE',GPmap{ind})) = true; end
                    case 'OUP'
                        if any(strcmp(phonemes{ii}(jj+1),{'P'})); A(strcmp('OUP',GPmap{ind})) = false; end
                    case 'ET'
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'TH'})); A(strcmp('ET',GPmap{ind})) = false; end
                    case 'YE'
                        if any(strcmp(phonemes{ii}(jj+1),{'IY' 'IH'})); A(strcmp('YE',GPmap{ind})) = false; end
                    case 'URE'
                        if any(strcmp(phonemes{ii}(jj+1),{'EY' 'AH'})); A(strcmp('URE',GPmap{ind})) = false; end
                    case 'OT'
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'TH' 'DH' 'SH'})); A(strcmp('OT',GPmap{ind})) = false; end
                    case 'UO'
                        if any(strcmp(phonemes{ii}(jj+1),{'OW' 'AA'})); A(strcmp('UO',GPmap{ind})) = false; end
                    case 'AI'
                        if any(strcmp(phonemes{ii}(jj+1),{'IH' 'IY'})); A(strcmp('AI',GPmap{ind})) = false; end
                    case 'ARR'
                        if any(strcmp(phonemes{ii}(jj+1),{'R'})); A(strcmp('ARR',GPmap{ind})) = false; end
                    case 'ERR'
                        if any(strcmp(phonemes{ii}(jj+1),{'R'})); A(strcmp('ERR',GPmap{ind})) = false; end
                    case 'RR'
                        if any(strcmp(phonemes{ii}(jj+1),{'R'})); A(strcmp('RR',GPmap{ind})) = false; end
                    case 'AH'
                        if any(strcmp(phonemes{ii}(jj+1),{'HH'})); A(strcmp('AH',GPmap{ind})) = false; end
                    case 'TT'
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'TH'})); A(strcmp('TT',GPmap{ind})) = false; end
                    case 'KH'
                        if any(strcmp(phonemes{ii}(jj+1),{'HH'})); A(strcmp('KH',GPmap{ind})) = false; end
                    case 'NN'
                        if any(strcmp(phonemes{ii}(jj+1),{'N'})); A(strcmp('NN',GPmap{ind})) = false; end
                    case 'ERE'
                        if any(strcmp(phonemes{ii}(jj+1),{'AH' 'IY' 'EH' 'IH'})); A(strcmp('ERE',GPmap{ind})) = false; end
                    case 'EE'
                        if any(strcmp(phonemes{ii}(jj+1),{'IH' 'EH'})); A(strcmp('EE',GPmap{ind})) = false; end
                    case 'SS'
                        if any(strcmp(phonemes{ii}(jj+1),{'S' 'SH'})); A(strcmp('SS',GPmap{ind})) = false; end
                    case 'FTH'
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'TH'})); A(strcmp('FTH',GPmap{ind})) = false; end
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'TH'})); A(strcmp('FT',GPmap{ind})) = false; end
                    case 'FT'
                        if any(strcmp(phonemes{ii}(jj+1),{'T' 'TH'})); A(strcmp('FT',GPmap{ind})) = false; end
                    case 'DD'
                        if any(strcmp(phonemes{ii}(jj+1),{'D'})); A(strcmp('DD',GPmap{ind})) = false; end
                    case 'LL'
                        if any(strcmp(phonemes{ii}(jj+1),{'L'})); A(strcmp('LL',GPmap{ind})) = false; end
                    case 'PP'
                        if any(strcmp(phonemes{ii}(jj+1),{'P'})); A(strcmp('PP',GPmap{ind})) = false; end
                    case 'MM'
                        if any(strcmp(phonemes{ii}(jj+1),{'M'})); A(strcmp('MM',GPmap{ind})) = false; end
                    case 'ER'
                        if any(strcmp(phonemes{ii}(jj+1),{'R'})); A(strcmp('ER',GPmap{ind})) = false; end
                end
            end
            
                        if ~any(A)
                fix(ii) = true;
                continue;
            end
            
            if jj==length(phonemes{ii}); if length(GPmap{ind}{indL & A})>1 && strcmp(GPmap{ind}{indL & A}(end),'E') && ~contains(GPmap{ind}{indL & A}(1),{'A' 'E' 'I' 'O' 'U'}); A(strcmp(GPmap{ind}{indL & A},GPmap{ind})) = false; end; end
            
            indL = (len == max(len(A)));
            word(1:max(len(A))) = [];
            grph = GPmap{ind}(indL & A);
            if jj>1; if size(graphemes{ii},2)>=(jj-1); if ~any(strcmp(grph{1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})) && strcmp(grph{1}(end),'E') && contains(graphemes{ii}{1,jj-1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}) && ~strcmp(grph{1},'GUE'); graphemes{ii}(1,jj-1) = strcat(graphemes{ii}(1,jj-1),'_E'); grph{1}(end) = []; end; end; end
            if jj>2; if size(graphemes{ii},2)>=(jj-2); if ~any(strcmp(grph{1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})) && strcmp(grph{1}(end),'E') && contains(graphemes{ii}{1,jj-2}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}) && ~strcmp(grph{1},'GUE'); graphemes{ii}(1,jj-2) = strcat(graphemes{ii}(1,jj-2),'__E'); grph{1}(end) = []; end; end; end
            if jj>3; if size(graphemes{ii},2)>=(jj-3); if ~any(strcmp(grph{1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})) && strcmp(grph{1}(end),'E') && contains(graphemes{ii}{1,jj-3}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}) && ~strcmp(grph{1},'GUE'); graphemes{ii}(1,jj-3) = strcat(graphemes{ii}(1,jj-3),'___E'); grph{1}(end) = []; end; end; end
            
            if jj>1; if size(graphemes{ii},2)>=(jj-1); if any(strcmp(grph{1},{'ED' 'EN' 'EL'})) && contains(graphemes{ii}{1,jj-1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-1) = strcat(graphemes{ii}(1,jj-1),'E'); grph{1}(1) = []; end; end; end
            if jj>2; if size(graphemes{ii},2)>=(jj-2); if any(strcmp(grph{1},{'ED' 'EN' 'EL'})) && contains(graphemes{ii}{1,jj-2}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-2) = strcat(graphemes{ii}(1,jj-2),'_E'); grph{1}(1) = []; end; end; end
            if jj>3; if size(graphemes{ii},2)>=(jj-3); if any(strcmp(grph{1},{'ED' 'EN' 'EL'})) && contains(graphemes{ii}{1,jj-3}(1),{'A' 'E' 'I' 'O' 'U' 'Y'}); graphemes{ii}(1,jj-3) = strcat(graphemes{ii}(1,jj-3),'__E'); grph{1}(1) = []; end; end; end
            
            graphemes{ii}(1,jj) = grph;
        end
        
        if any(cellfun(@isempty,graphemes{ii}))
            fix(ii) = true;
            break;
        end
    end
    
    if any(isempty(graphemes{ii}))
        fix(ii) = true;
        continue;
    end
    
    if ~isempty(word)
        if strcmp(word,'E')
            if length(graphemes{ii}) == 1
                graphemes{ii}(1,end) = strcat(graphemes{ii}(1,end),'E');
            elseif isempty(graphemes{ii}{1,end-1})
                fix(ii) = true;
            elseif contains(graphemes{ii}{1,end-1}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})
                graphemes{ii}(1,end-1) = strcat(graphemes{ii}(1,end-1),'_E');
            elseif length(graphemes{ii}) > 3
                if contains(graphemes{ii}{1,end-2}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})
                    graphemes{ii}(1,end-2) = strcat(graphemes{ii}(1,end-2),'__E');
                elseif contains(graphemes{ii}{1,end-3}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})
                    graphemes{ii}(1,end-3) = strcat(graphemes{ii}(1,end-3),'___E');
                else
                    graphemes{ii}(1,end) = strcat(graphemes{ii}(1,end),'E');
                end
            elseif length(graphemes{ii}) > 2
                if contains(graphemes{ii}{1,end-2}(1),{'A' 'E' 'I' 'O' 'U' 'Y'})
                    graphemes{ii}(1,end-2) = strcat(graphemes{ii}(1,end-2),'__E');
                else
                    graphemes{ii}(1,end) = strcat(graphemes{ii}(1,end),'E');
                end
            else
                graphemes{ii}(1,end) = strcat(graphemes{ii}(1,end),'E');
            end
        elseif strcmp(word,'H')
            graphemes{ii}(1,end) = strcat(graphemes{ii}(1,end),'H');
        else
            fix(ii) = true;
        end
    end
    
    if any(strcmp(graphemes{ii},'ALL'))
        ind = find(strcmp(graphemes{ii},'ALL'));
        graphemes{ii} = [graphemes{ii}(1:ind-1) {'A'} {'LL'} graphemes{ii}(ind+1:end)];
        phonemes{ii} = [phonemes{ii}(1:ind-1) {'AH'} {'L'} phonemes{ii}(ind+1:end)];
    end
    
    if any(strcmp(graphemes{ii},'AIE')); graphemes{ii} = strrep(graphemes{ii},'AIE','AI_E'); end
    
end

end
