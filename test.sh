#!/bin/bash
if [ "$1" == "req" ]; then
   cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/requirements
elif [ "$1" == "Makefile" ]; then
   cp ~kmammen-grader/evaluations/F17/357/${PWD##*/}/Makefile .
   echo "Copied Makefile!"
elif [ "$1" == "core" ]; then
   printf "Displaying core test descriptions: \n\n"
   cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/core/testList | while read line
   do
      printf "$line Description:\n"
      cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/core/$line/description
      printf "\n"
   done
elif [ "$1" == "feature" ]; then
   printf "Displaying feature test descriptions: \n\n"
   cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/feature/testList | while read line
   do
      printf "$line Description:\n"
      cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/feature/$line/description
      VALUE=$( cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/feature/$line/value )
      printf "VALUE: $VALUE\n\n"
   done
elif [ "$1" == "cpu" ]; then
   cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/cpu/testList | while read line
   do
      printf "$line Description:\n"
      cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/cpu/$line/description
      VALUE=$( cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/cpu/$line/value )
      printf "VALUE: $VALUE\n\n"
   done
elif [ "$1" == "heap" ]; then
   cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/heap/testList | while read line
   do
      printf "$line Description:\n"
      cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/heap/$line/description
      VALUE=$( cat ~kmammen-grader/evaluations/F17/357/${PWD##*/}/tests/heap/$line/value )
      printf "VALUE: $VALUE\n\n"
   done
elif [ "$1" == "style" ]; then
   ~kmammen-grader/bin/styleCheckC *.c
elif [ "$1" == "complex" ] || [ "$1" == "complexity" ]; then
   TOTAL=0
   COUNT=0
   MAX=0
   QUARTILE=0
   ARRAY=()
   complexity -t0 -s1 *.c > result
   cat result |
   {
      while read line
      do
         echo "$line"
         #attempt to parse the line as an integer
         VALUE="`expr "$line" : '\([0-9]*\)'`"
         #if parsing was successful, then process the complexity score
         if [ "$VALUE" != "" ]; then
            ((TOTAL+=$VALUE))
            #the complexity scores are in order; but as a precaution, checking anyway...
            if [ $VALUE -gt $MAX ]; then
               MAX=$VALUE
            fi
            ARRAY=(${ARRAY[@]} $VALUE)
            ((COUNT++))
         fi
      done
      #identify how many items are in the quartile
      RATIOS=$((COUNT / 4))
      i=$COUNT
      #add the quartile scores from the array
      while [ $i -gt $(($COUNT-$RATIOS)) ]
      do
         ((i--))
         ((QUARTILE+=${ARRAY[$i]}))
      done

      #print results
      printf "\n\n===== CALCULATED RESULTS =====\n"
      echo " Total complexity:    $TOTAL"
      echo " Max complexity:      $MAX"
      AVERAGE=$(bc <<< "scale=2;$TOTAL/$COUNT")
      echo " Average complexity:  $AVERAGE"
      AVERAGE=$(bc <<< "scale=4;$QUARTILE/$TOTAL")
      echo " Top quartile ratio:  $AVERAGE"
      printf "==============================\n"
      printf "\n\nNote that these numbers may be rounded by the instructor,\nand thus may not exactly reflect your submission results.\n"
   }
   rm -f result

elif [ "$1" == "zip" ]; then
   if [ -f "${PWD##*/}.zip" ]; then
      rm ${PWD##*/}.zip
   fi
   ~kmammen-grader/bin/styleCheckC *.c
   if [ $? == 0 ]; then
      ls *.c &> /dev/null
      if [ $? == 0 ]; then
         zip ${PWD##*/}.zip *.c
      fi
      ls *.h &> /dev/null
      if [ $? == 0 ]; then
         zip ${PWD##*/}.zip *.h
      fi
   fi

elif [ "$1" == "run" ]; then
   ~kmammen/357/${PWD##*/}/$2

elif [ "$1" == "test" ]; then
   for testInput in *.in; do
      # Strip off the file extension, i.e., the ".in"
      name=/tests/${testInput%.in}

      # Run the test
      ./a.out < ./tests/${testInput} > ./output/${name.out}
      echo $name
     ~kmammen/357/${PWD##*/}/$2 < ./tests/${testInput} > ./output/${name.expect}

      diff ./output/${name.out} ./output/${name.expect}
      echo "==============================================================="
   done
elif [ "$1" == "hproj" ]; then
      handin kmammen-grader ${PWD##*/} ${PWD##*/}.zip

elif [ "$1" == "hlab" ]; then
   handin kmammen-grader ${PWD##*/}-Section27 ${PWD##*/}.zip

else
   me=`basename "$0"`
   printf "Usage: $me [option] \n"
   printf "\nAvailable options:\n"
   printf "   req - displays requirements for the exercise\n"
   printf "   Makefile - copies the makefile for this exercise to the directory\n"
   printf "   core - displays the core test descriptions\n"
   printf "   feature - displays the feature tests\n"
   printf "   cpu - displays the cpu tests requirements\n"
   printf "   heap - displays the memory test/requirements\n"
   printf "   style - checks all the source file (*.c) with the styleChecker\n"
   printf "   zip - creates a zip file with all the source and header files. Zip is called after the current working directory.\n"
   printf "   test [reference solution] - uses *.in and diffs your project versus the reference solution\n"
   printf " \n"
   printf "\n\n  NOTE: To use the script, ensure that the current project directory is the same name as the current exercise/project\n"
   printf "  as it will use the name of the directory to determine the name to use.\n  e.g.: using the script when in the 'Exercise3' folder will retrieve all the information from Exercise3.\n"
fi
