#!/bin/bash
#
# Author: Nicholas Wright (OldTechDreamer on GitHub)
#
# About:
#	A simple Bash script to make a Diary.
#

# Binaries

LS="/bin/ls"
CAL="/usr/bin/cal"
DATE="/bin/date"
MORE="/bin/more"
LESS="/bin/less"
SORT="/usr/bin/sort"
GREP="/bin/grep"
MKDIR="/bin/mkdir"
WHOAMI="/usr/bin/whoami"

# Variables

DIR="/home/$($WHOAMI)/Diary"	# This is the path to the Diary directory
EDITOR="/bin/nano"				# The editor the user will use to create and edit diary entries

#### Functions to keep things tidy (Look below these for the code that runs first) ####

display_help_text()
{
	echo "Usage:"
	echo -e "\tdiary [options]"
	echo ""
	echo -e "\tOptions:"
	echo -e "\t\t-h | --help\t\tDisplay help and exit."
	echo -e "\t\t-p | --path\t[PATH]\tSpecify the location of the Diary Directory. The directory will be created if it doesn't exist. Default: \"$DIR\""
	echo -e "\t\t-e | --editor\t[PATH]\tSpecify the binary of the editor to use. Default: \"$EDITOR\""
	echo ""
	echo -e "\tExamples:"
	echo -e "\t\tdiary"
	echo -e "\t\tdiary -p /usr/local/diary -e /usr/bin/vi"
}

display_menu()
{
	echo "Select action:"
	echo -e "\tq\tExit"
	echo -e "\tn\tNew entry"
	echo -e "\tv\tView entry"
	echo -e "\te\tEdit entry"
	echo ""
	echo -e "\tw\tView this day last week"
	echo -e "\tm\tView this day last month"
	echo -e "\ty\tView this day last year"
}

new_entry()
{
	# Create and edit today's entry

	ENTRY_DATE="$($DATE +%Y-%m-%d_%H-%M-%S)"

	echo -n "Entry date ($ENTRY_DATE): "
	read NEW_DATE

	if [ -n "$NEW_DATE" ]	# Change the date if the user gives one
	then
		ENTRY_DATE="$NEW_DATE"
	fi

	# Create the year directory if it does not exist
	$MKDIR -p "$DIR$($DATE +%Y)"
	
	if [ $? -ne 0 ]
	then
		echo "Failed to create directory \"$DIR$($DATE +%Y)\""
		exit 1
	fi

	FILE_PATH="$DIR$($DATE +%Y)/$ENTRY_DATE.txt"

	# Create and edit the entry
	$EDITOR "$FILE_PATH"
	
	# Check the file was created and display messages accordingly
	if [ -r "$FILE_PATH" ]
	then
		echo -e "\e[32mDiary entry written!\e[0m"
	else
		echo -e "\e[31mDiary entry not written!\e[0m"
	fi
}

view_edit_entry()
{
	# View or Edit an entry

	# Get the year
	echo "Enter Year:"
	
	for Y in $($LS $DIR | $SORT)
	do
		echo -e "\t$Y"
	done

	echo -n "> "
	read YEAR

	if [ "$($LS $DIR | $GREP $YEAR)" != "$YEAR" ]
	then
		echo "Unknown year '$YEAR'"
		return 1
	fi

	# Get the month
	echo -e "Enter Month:\n\t01\tJanuary\n\t02\tFebuary\n\t03\tMarch\n\t04\tApril\n\t05\tMay\n\t06\tJune\n\t07\tJuly\n\t08\tAugust\n\t09\tSeptember\n\t10\tOctober\n\t11\tNovember\n\t12\tDecember\n"
	echo -n "Month: "

	read MONTH

	# Add a zero to the front of MONTH if needed
	if [[ $MONTH != 0* ]]
	then
		MONTH="0$MONTH"
	fi

	# Get the day
	echo "Enter Day:"
	$CAL -d "$YEAR-$MONTH"

	echo -ne "\nDay: "
	read DAY

	# Add a zero to the front of DAY if needed
	if [[ $DAY != 0* ]]
	then
		DAY="0$DAY"
	fi

	# Check there is an entry, if not, return
	if [ "$(ls $DIR$YEAR/$YEAR-$MONTH-$DAY* &2>/dev/null)" == "" ]
	then
		echo -e "\e[31mNo entry found for $YEAR-$MONTH-$DAY\e[0m"
		return
	fi

	# View or Edit the entry
	if [ "$1" == "view" ]
	then
		$LESS $DIR$YEAR/$YEAR-$MONTH-$DAY*		# View
	else
		$EDITOR $DIR$YEAR/$YEAR-$MONTH-$DAY*	# Edit
	fi
	
}

view_last_week()
{
	YEAR="$($DATE +%Y -d '- 7 days')"
	LAST_WEEK="$($DATE +%Y-%m-%d_ -d '- 7 days')"
	
	if [ "$(ls $DIR$YEAR/$LAST_WEEK*)" ]
	then
		$LESS $DIR$YEAR/$LAST_WEEK*
		
	else
		echo -e "\e[31mNo entry found for: \"$LAST_WEEK\"\e[0m"
	fi
}

view_last_month()
{
	YEAR="$($DATE +%Y -d '- 1 month')"
	LAST_MONTH="$($DATE +%Y-%m-%d_ -d '- 1 month')"
	
	if [ "$(ls $DIR$YEAR/$LAST_MONTH*)" ]
	then
		$LESS $DIR$YEAR/$LAST_MONTH*
		
	else
		echo -e "\e[31mNo entry found for: \"$LAST_MONTH\"\e[0m"
	fi
}

view_last_year()
{
	# Get last year
	LAST_YEAR="$(($($DATE +%Y) - 1))"
	MONTH="$($DATE +%m)"
	DAY="$($DATE +%d)"


	if [ "$(ls $DIR/$LAST_YEAR/$LAST_YEAR-$MONTH-$DAY*)" ]
	then
		$LESS $DIR/$LAST_YEAR/$LAST_YEAR-$MONTH-$DAY*
		
	else
		echo -e "[31mNo entry found for: \"$LAST_YEAR/$MONTH/$DAY\"[0m"
	fi
}

#### Process input arguments ####

while [ "$1" != "" ]; do						# Loop through the input agreements (shift turns $1 into $2)
    case $1 in
        -h | --help )
			display_help_text
			exit 0
			;;
		
		-p | --path )
			shift
			DIR="$1"
			shift
			;;
		
		-e | --editor )
			shift
			EDITOR="$1"
			shift
			;;

        * )
			echo "Unknown option \"$1\""
			exit 1
			;;
    esac
done

#### Setup ####

# Check the directory exists and create one if not

if [ ! -d "$DIR" ]
then
	echo "Creating new Diary Directory \"$DIR\""
	
	$MKDIR "$DIR"	# Create the directory
	
	if [ $? -ne 0 ]
	then
		echo "Failed to create directory \"$DIR\""
		exit 1
	fi
fi

# Check that $DIR has a forward slash at the end

IF_ENDED="$(echo $DIR | $GREP '/$')"

if [ "$IF_ENDED" == "" ]	# Add a forward slash to the end
then
	DIR="$DIR/"
fi 

echo "$DIR"

#### Main Program ####

while [ 1 -eq 1 ]	# Loop forever until exit
do
	display_menu	# Show the menu

	echo -en "> "	## Print the prompt
	read -n 1 KEY	# Wait for a key press from the user
	echo ""			# New line
	
	case "$KEY" in
		"q")
			echo "Good bye."
			exit 0
			;;

		"n")
			new_entry
			;;

		"v")
			view_edit_entry view
			;;
			
		"e")
			view_edit_entry edit
			;;

		"w")
			view_last_week
			;;
			
		"m")
			view_last_month
			;;
			
		"y")
			view_last_year
			;;

		*)
			echo -e "\e[31mError! Unknown key: \"$KEY\". Type \"q\" to quit.\e[0m"
			;;
	esac
	
	echo ""	# New line
done