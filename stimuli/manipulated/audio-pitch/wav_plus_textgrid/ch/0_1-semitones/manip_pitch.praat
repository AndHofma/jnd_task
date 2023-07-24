######################
## Description data ##
######################

# textgrid has 5 interval tiers / 1 point tier #
# tier1: word (interval)#
# tier2: syll  (interval)#
# tier3: seg (interval)#
# tier4: glott (interval)#
# tier6: comments (interval)#
# tier5: f0 (point)#

################
## Setup data ##
################

## directories ##
# specify the directory from which you want to access the wav and textgrid files
d$ = "C:\Users\Andrea Hofmann\OneDrive\PhD\phd_perception_production_link\dissertation\procedure_all\exp_jnd\stimuli_to-be-manipulated\pitch\cut_name2\ch\"
# directory for saving the manipulated files
dir$ = "C:\Users\Andrea Hofmann\OneDrive\PhD\phd_perception_production_link\dissertation\procedure_all\exp_jnd\stimuli_manipulated\audio-pitch\wav_plus_textgrid\ch\"

# opens the wav-files from a file
Create Strings as file list... list 'd$'*.wav

# query number of objects in the stringslist and store in variable n
n = Get number of strings
printline number of strings: 'n'

# for-loop, goes through each object in the list
for i from 1 to n
	select Strings list
	filename$ = Get string... 'i'
	Read from file... 'd$''filename$'
	# store basename in variable name
	name$ = selected$ ("Sound")
	Read from file... 'd$''name$'.TextGrid

#############################################
## Read out information from original file ##
#############################################

    ## f0 ##
    select Sound 'name$'
    To Pitch: 0, 75, 600

    select TextGrid 'name$'

    tier5 = Get number of points: 5
    for j from 1 to tier5
        select TextGrid 'name$'
        p$ = Get label of point: 5, j
        t = Get time of point: 5, j
        if p$ == "L2"
            l2t = t
            select Pitch 'name$'
            l2 = Get value at time: l2t, "Hertz", "Linear"
        elsif p$ == "H2"
            h2t = t
            select Pitch 'name$'
            h2 = Get value at time: h2t, "Hertz", "Linear"
        endif
    endfor

    ## duration s8 (tier3) ##
    select TextGrid 'name$'
    tier3 = Get number of intervals... 3

    for k from 1 to tier3
        select TextGrid 'name$'
        label3$ = Get label of interval: 3, k

        if label3$ == "s8"
            starts8 = Get start time of interval: 3, k
            ends8 = Get end time of interval: 3, k
            s8 = 'ends8' - 'starts8'
        elsif label3$ =="s7"
            # this is the boundary between 1st and 2nd syll used later in new TextGrids
            tsyll = Get starting point: 3, k
        endif
    endfor

    ############################################
    ## Calculate values to setup manipulation ##
    ############################################

    ## f0 rise max to flat ##
    # calculate rise for original file - origRise (in semitones)
    origRise = 12*log2(h2/l2)

    # amount of 0.1 semitone steps to get from origRise to flat: rise = btw (-1) and (+1)
    # round to integer - get rid of decimal places
    stepsFlatten = round((origRise) / 0.1)

    ################
    ## Data Table ##
    ################
    Create Table with column names: "table", stepsFlatten+1, "stepID filename nameNew riseOrig l2Orig h2Orig riseNew h2New diffRise"

    ##################
    ## Manipulation ##
    ##################

    ## f0 rise flatten continuum ##
    for x from 1 to stepsFlatten+1
        select Sound 'name$'
        To Manipulation: 0.01, 75, 600
        Edit
        editor Manipulation 'name$'

        # delete all pitchpoints in name2 to the right of L2
        # put a new pitch point with the new value for H2 at 80% of the final vowel (aka s8)
        l2tpp = 'l2t' + 0.005
        # variable for positioning H2
        nh = s8/10*2
        posh2new = ends8 - nh
        # variable for deleting pitch points next to L2
        Select: 'l2tpp', 'ends8'
        Remove pitch point(s)

        # get new h2Max value for each step
        h2Max = 2^((origRise-((x-1)*0.1))/12) * l2
        # flatten variable to put in filename of new file
        # this value will be relevant to find correct stimulus later in JND script
        currRise$ = fixed$ ((12*log2(h2Max/l2)), 1)
        # newRise same as currRise but as numeric for table output
        newRise = 12*log2(h2Max/l2)
        # diffRise numeric for table output
        diffRise = origRise - newRise

        Add pitch point at: 'posh2new', 'h2Max'

        Publish resynthesis
        Close

        name_new$ = name$ + "_rise_" + currRise$
        Rename: "'name_new$'"
        Save as WAV file... 'dir$''name_new$'.wav

        select Table table
        Set numeric value: x, "stepID", 'stepsFlatten:1'
        Set string value: x, "filename", name$
        Set string value: x, "nameNew", name_new$
        Set numeric value: x, "riseOrig", 'origRise:4'
        Set numeric value: x, "l2Orig", 'l2:4'
        Set numeric value: x, "h2Orig", 'h2:4'
        Set numeric value: x, "riseNew", 'newRise:4'
        Set numeric value: x, "h2New", 'h2Max:4'
        Set numeric value: x, "diffRise", 'diffRise:4'
    endfor

    select Table table
    table_name$ = "manipulation_pitch_" + name$
    Save as tab-separated file... 'dir$' 'table_name$'.csv

endfor

#########################################
## Generate TextGrid for each wav file ##
#########################################

# opens the wav-files from a file
Create Strings as file list... list 'd$'*.wav

# query number of objects in the stringslist and store in variable n
n = Get number of strings
printline number of strings: 'n'

# for-loop, goes through each object in the list
for i from 1 to n
	select Strings list
	filename$ = Get string... 'i'
	Read from file... 'd$''filename$'
	# store basename in variable name
	name$ = selected$ ("Sound")
	Read from file... 'd$''name$'.TextGrid

#############################################
## Read out information from original file ##
#############################################

    ## duration s8 (tier3) ##
    select TextGrid 'name$'
    tier3 = Get number of intervals... 3

    for k from 1 to tier3
        select TextGrid 'name$'
        label3$ = Get label of interval: 3, k

        if label3$ =="s7"
            # this is the boundary between 1st and 2nd syll used later in new TextGrids
            tsyll = Get starting point: 3, k
        endif
    endfor

    # opens the wav-files from a file
    Create Strings as file list... list 'dir$'*.wav
    # Anzahl der Objekte in der Stringliste erfragen und in Variable q speichern
    q = Get number of strings

    # for-Schleife, die durch jedes Objekt in der Liste geht
    for i from 1 to q
        select Strings list
        filename$ = Get string... 'i'
        Read from file... 'dir$''filename$'
        # store basename in Variable name
        name$ = selected$ ("Sound")
        # query information on condition
        select Sound 'name$'
        # subtract last four elements (.wav)
        length = length (name$)
        partName$ = left$(name$,length)
        # create a TextGrid
        # name all tiers in the first quotation marks
        # repeat those tiers that should be point tiers in the second quotation marks
        # To TextGrid... "Word Syllable", ""
        To TextGrid: "Word Syllable", ""

        Insert boundary: 2, 'tsyll'

        Set interval text: 1, 1, "name2_'partName$'"
        Set interval text: 2, 1, "n2sy1_'partName$'"
        Set interval text: 2, 2, "n2sy2_'partName$'"

        select TextGrid 'name$'
        # Save TextGrid as text file... 'dir$''name$'.TextGrid
        Save as text file... 'dir$''name$'.TextGrid

        select all
        minus Strings list
        Remove
    endfor

endfor

select all
Remove