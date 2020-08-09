#!/bin/bash
#
# Author: Nicholas Wright (OldTechDreamer on GitHub)
#
# About:
#	A simple Bash script to make a Diary.
#


DIR="/home/pi/Diary"

CAL="/usr/bin/cal"
DATE="/bin/date"
MORE="/bin/more"
LESS="/bin/less"
MKDIR="/bin/mkdir"
EDITOR="/bin/nano"

# set the DIR path if argv given
if [ -n "$1" ]
then
	DIR="$1"
fi

# Create the diary folder if not already created
$MKDIR -p "$DIR/$($DATE +%Y)" || (echo -e "\e[31mError! Could not create diary folder at $DIR/$($DATE +%Y)!\e[39m" && exit 1)	# Creates $DIR/Year

# Functions
function MainMenu {
	echo "Select action:"
	echo -e "\t0\tExit"
	echo -e "\t1\tNew entry"
	echo -e "\t2\tView entry"
	echo -e "\t3\tEdit entry"
	echo ""
	echo -e "\t4\tThis day last week"
	echo -e "\t5\tThis day last month"
	echo -e "\t6\tThis day last year"

	echo -en "> "
	read -n 1 KEY
	echo ""

	case "$KEY" in
		0)
			echo "Good bye."
			exit 0
			;;

		1)
			NewEntry
			;;

		2)
			ViewEntry
			;;


		6)
			LastYear
			;;

		*)
			echo -e "\e[31mError! Unknowen key: $KEY\e[39m"
			;;
	esac
}

function NewEntry {
	# Create and edit todays entry

	ENTRY_DATE="$($DATE +%Y-%m-%d_%H-%M-%S)"

	echo -n "Entry date ($ENTRY_DATE): "
	read NEW_DATE

	if [ -n "$NEW_DATE" ]	# Change the date if the user gives one
	then
		ENTRY_DATE="$NEW_DATE"
	fi

	$EDITOR "$DIR/$($DATE +%Y)/$ENTRY_DATE.txt"
}

function ViewEntry {
	# View an entry

	# Get the year
	echo -n "Enter Year ("
	echo -n "$(ls $DIR | sort | head -n 1) - "
	echo -n "$(ls $DIR | sort | tail -n 1)): "

	read YEAR

	if [ "$(ls $DIR | grep $YEAR)" != "$YEAR" ]
	then
		echo "Unknowen year '$YEAR'"
		return 1
	fi

	# Get the month
	echo -e "Enter month:\n\t01\tJanuary\n\t02\tFebuary\n\t03\tMarch\n\t04\tApril\n\t05\tMay\n\t06\tJune\n\t07\tJuly\n\t08\tAugust\n\t09\tSeptember\n\t10\tOctober\n\t11\tNovember\n\t12\tDecember\n"
	echo -n "Month: "

	read MONTH

	if [ "${#MONTH}" == "0" ]
	then
		MONTH="0$MONTH"
	fi

	# Get the day
	$CAL -d "$YEAR-$MONTH"

	echo -n "Day: "
	read DAY

	if [ "${#DAY}" == "0" ]
	then
		DAY="0$DAY"
	fi

	if [ "$(ls $DIR/$YEAR/$YEAR-$MONTH-$DAY* &2>/dev/null)" == "" ]
	then
		echo "No entry found for $YEAR-$MONTH-$DAY"
		return 1
	fi

	# View the entry
	$MORE $DIR/$YEAR/$YEAR-$MONTH-$DAY*
}

function LastYear {
	# Get last year
	LAST_YEAR="$(($($DATE +%Y) - 1))"
	MONTH="$($DATE +%m)"
	DAY="$($DATE +%d)"


	if [ "$(ls $DIR/$LAST_YEAR/$LAST_YEAR-$MONTH-$DAY*)" ]
	then
		$LESS $DIR/$LAST_YEAR/$LAST_YEAR-$MONTH-$DAY*
	else
		echo "No entry found for: $LAST_YEAR/$MONTH/$DAY"
	fi
}

MainMenu

while [ 1 -eq 1 ]
do
	MainMenu
done
