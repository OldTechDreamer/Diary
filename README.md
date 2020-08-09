# Diary Bash script

This script makes it easy to write a diary in the Terminal and view / edit past entried.
This includes quick links to Last Week, Last Month and Last Year.
All saves in text files in your home or other specified place.

## Example:

```
njw@NJW-SRV01:~ $ diary
Select action:
        q       Exit
        n       New entry
        v       View entry
        e       Edit entry

        w       View this day last week
        m       View this day last month
        y       View this day last year
> n
Entry date (2020-08-09_16-30-36):

	[An editor window opens (NANO) for you to enter your days thoughts]

Diary entry written!
```

## Install

1. Download the diary.sh script
⋅⋅1. git clone https://github.com/OldTechDreamer/Diary
⋅⋅1. cd Diary
2. Make the script executable
⋅⋅* chmod +x diary.sh
3. Copy it to bin
⋅⋅* sudo cp diary.sh /usr/bin/diary

You should now be able to run `diary` anywhere.

**Please note:** The default location for diary entries are in: **/home/[Your User]/Diary/

## Command line options

diary [options]

	Options:
			-h | --help             Display help and exit.
			-p | --path     [PATH]  Specify the location of the Diary Directory. The directory will be created if it doesn't exist. Default: "/home/pi/Diary"
			-e | --editor   [PATH]  Specify the binary of the editor to use. Default: "/bin/nano"

	Examples:
			diary
			diary -p /usr/local/diary -e /usr/bin/vi