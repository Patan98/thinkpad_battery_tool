#!/bin/bash

#############################################################################################################################################################################
#███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████
#██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██
#█████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████
#██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██
#██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████
#############################################################################################################################################################################
HELP() #MOSTRA IL MESSAGGIO DI AIUTO
{
    echo "This script stores the health status of the batteries inserted in the PC in a database"
    echo
    echo "Options:"
    echo "-h --help            Show this help message"
    echo ""
    echo "-m --monitor         Turn on monitor mode"
    echo ""
    echo "-g --gui             Start the battery manager"
    echo ""
}

MONITOR_INSERT()
{
    #IF A BATTERY IS INSERTED
    if [ -d /sys/class/power_supply/BAT* ];
    then
        #FOR EACH BATTERY INSERTED
        for ((n=0; n<"$(ls -d /sys/class/power_supply/BAT* | wc -l)"; n++));
        do
            #CREATE THE LIST OF BATTERIES (INSERTED AT STARTUP)
            if [ -f /sys/class/power_supply/BAT$n/serial_number ];
            then
                declare BAT$n="$(cat /sys/class/power_supply/BAT$n/serial_number)"
            fi
        done

        while true
        do
            #FOR EACH BATTERY INSERTED
            for ((n=0; n<"$(ls -d /sys/class/power_supply/BAT* | wc -l)"; n++));
            do
                FOUNT=0
                #FOR EVERY BATTERY IN THE LIST
                for SERIALS in ${!BAT*}
                do
                    declare -n REGISTERED=$SERIALS

                    #IF THE INSERTED BATTERY IS ALREADY IN THE LIST, THE FLAG AS FOUND IS INDICATED
                    if [ "$(cat /sys/class/power_supply/BAT$n/serial_number)" == "$REGISTERED"  ];
                    then
                        FOUNT=1
                    fi
                done

                #IF THE BATTERY IS NOT IN THE LIST, THEN IT HAS JUST BEEN INSERTED
                if [ "$FOUNT" == "0"  ];
                then
                    zenity --info --text="BATTERY INSERTED"
                    #RECREATE THE LIST OF BATTERIES (INSERTED AT STARTUP)
                    for ((n=0; n<"$(ls -d /sys/class/power_supply/BAT* | wc -l)"; n++));
                    do
                        if [ -f /sys/class/power_supply/BAT$n/serial_number ];
                        then
                            declare BAT$n="$(cat /sys/class/power_supply/BAT$n/serial_number)"
                        fi
                    done
                fi
            done

            sleep 1
        done
    fi
}

MONITOR_DATABASE()
{
    #IF A BATTERY IS INSERTED
    if [ -d /sys/class/power_supply/BAT* ];
    then
        while true
        do
            #FOR EACH BATTERY INSERTED
            for PLUGGED in /sys/class/power_supply/BAT*;
            do
                SERIAL="$(cat "$PLUGGED/serial_number")"
                MODEL="$(cat "$PLUGGED/model_name")"
                ENERGY_FULL="$(bc <<< "scale=1; $(cat $PLUGGED/energy_full)/1000000")"
                ENERGY_FULL_DESIGN="$(bc <<< "scale=1; $(cat $PLUGGED/energy_full_design)/1000000")"
                HEALTH="$(bc <<< "scale=2; ($ENERGY_FULL/$ENERGY_FULL_DESIGN)*100")"
                HEALTH=${HEALTH%.*}

                RECORD=1 #COUNTER OF THE NUMBER OF ROWS IN THE DATABASE
                FOUND=0 #FLAG INDICATING IF THE BATTERY HAS BEEN FOUND IN THE DATABASE
                #READS ALL THE ROWS OF THE DATABASE
                while IFS=',' read -ra row;
                do
                    #IF THE CONNECTED BATTERY IS FOUND IN THE DATABASE, UPDATE THE DATA
                    if [ "${row[0]}" == "$SERIAL" ];
                    then
                        ENERGY_FULL="$(bc <<< "scale=1; $(cat $PLUGGED/energy_full)/1000000")"
                        HEALTH="$(bc <<< "scale=2; ($ENERGY_FULL/$ENERGY_FULL_DESIGN)*100")"
                        HEALTH=${HEALTH%.*}

                        sed -Ei "$RECORD s/[^,]*/"$ENERGY_FULL"/3" ~/code_data/Bash/battery.csv #UPDATE THE VALUE IN THE DATABASE TO THE ROW REACHED BY THE COUNTER IN COLUMN 3
                        sed -Ei "$RECORD s/[^,]*/"$HEALTH"/5" ~/code_data/Bash/battery.csv #UPDATE THE VALUE IN THE DATABASE TO THE ROW REACHED BY THE COUNTER IN COLUMN 5

                        FOUND=1
                    fi

                    ((RECORD++)) #INCREASE THE COUNTER
                done < ~/code_data/Bash/battery.csv

                #IF THE BATTERY IS NOT FOUND IN THE DATABASE AFTER YOU HAVE READ IT ALL, ADD THE BATTERY
                if [ "$FOUND" == "0" ]
                then
                    DATE="$(date +%Y_%m_%d)"

                    NAME="$(zenity --entry --text="NEW BATTERY DETECTED\nGive the battery a name")"
                    if [ -z "$NAME" ]
                    then
                        NAME="$(zenity --entry --text="Give the battery a name")"
                    fi
                    NAME=$(echo "$NAME" | tr " " _)

                    #IF SET AS MAIN IT WILL BE PLACED AT THE TOP OF THE LIST
                    if zenity --question --text="Set as primary?";
                    then
                        echo "$SERIAL,$MODEL,$ENERGY_FULL,$ENERGY_FULL_DESIGN,$HEALTH,$DATE, $NAME" > ~/code_data/Bash/temp.csv
                        cat ~/code_data/Bash/battery.csv >> ~/code_data/Bash/temp.csv
                        rm ~/code_data/Bash/battery.csv
                        mv ~/code_data/Bash/temp.csv ~/code_data/Bash/battery.csv

                    #IF NOT SET AS MAIN IT WILL BE PLACED AT THE BOTTOM OF THE LIST
                    else
                        echo "$SERIAL,$MODEL,$ENERGY_FULL,$ENERGY_FULL_DESIGN,$HEALTH,$DATE, $NAME" >> ~/code_data/Bash/battery.csv
                    fi

                    zenity --info --text="Battery added"
                fi

                sleep 1
            done
        done
    fi
}

GUI()
{
    LIST=$(while IFS=',' read -r field1 field2 field3 field4 field5 field6 field7; do echo "$field1"; echo "$field2"; echo "$field3"; echo "$field4"; echo "$field5"; echo "$field6"; echo "$field7"; done < ~/code_data/Bash/battery.csv)
    LIST_OPT=$(while IFS=',' read -r field1 field2 field3 field4 field5 field6 field7; do echo "FALSE"; echo "$field1"; echo "$field2"; echo "$field3"; echo "$field4"; echo "$field5"; echo "$field6"; echo "$field7"; done < ~/code_data/Bash/battery.csv)
    OPT=$(zenity --title="BATTERY MANAGER" --width=800 --height=300 --text="Batteries listed:" --list --column "Serial" --column "Model" --column "Energy full" --column "Energy full design" --column "Health" --column "Date added" --column "Name"   $LIST Edit " " " " " " " " " " " " Remove)
    if [ "$OPT" == "Edit" ]
    then
        EDIT=`zenity --title="BATTERY MANAGER" --width=800 --height=300 --text="<big><b>Choose the battery to rename:</b></big>" --list --column " " --column "Serial" --column "Model" --column "Energy full" --column "Energy full design" --column "Health" --column "Date added" --column "Name"   $LIST_OPT --radiolist 2>/dev/null`
        if [ ! -z "$EDIT" ];
        then
            NEW="$(zenity --entry --text="Choose the new battery name")"
            if [ -z "$NEW" ]
            then
            NEW="$(zenity --entry --text="Give the battery a name")"
            fi
            NEW=$(echo "$NEW" | tr " " _)

            RECORD=1 #COUNTER OF THE NUMBER OF ROWS IN THE DATABASE
            #READS ALL THE ROWS OF THE DATABASE
            while IFS=',' read -ra row;
            do
                #IF THE BATTERY IS FOUND IN THE DATABASE
                if [ "${row[0]}" == "$EDIT" ];
                then
                    sed -Ei "$RECORD s/[^,]*/"$NEW"/7" ~/code_data/Bash/battery.csv #UPDATE THE VALUE IN THE DATABASE TO THE ROW REACHED BY THE COUNTER IN COLUMN 3

                #OTHERWISE DO NOTHING
                else
                    :
                fi

                ((RECORD++)) #INCREASE THE COUNTER

            done < ~/code_data/Bash/battery.csv

        fi
        GUI

    elif [ "$OPT" == "Remove" ]
    then
        REMOVE=`zenity --title="BATTERY MANAGER" --width=800 --height=300 --text="<big><b>Choose battery to remove:</b></big>" --list --column " " --column "Serial" --column "Model" --column "Energy full" --column "Energy full design" --column "Health" --column "Date added" --column "Name"   $LIST_OPT --radiolist 2>/dev/null`
        if [ ! -z "$REMOVE" ];
        then
          grep -v "^$REMOVE" ~/code_data/Bash/battery.csv > ~/code_data/Bash/tmp.csv
          mv ~/code_data/Bash/tmp.csv ~/code_data/Bash/battery.csv
        fi
        GUI
    fi
}
#############################################################################################################################################################################
#███    ███  █████  ██ ███    ██
#████  ████ ██   ██ ██ ████   ██
#██ ████ ██ ███████ ██ ██ ██  ██
#██  ██  ██ ██   ██ ██ ██  ██ ██
#██      ██ ██   ██ ██ ██   ████
#############################################################################################################################################################################
if [ -d $(dirname ~/"$whoami"code_data/Bash/.) ];
then
    :
else
    echo "Directory "$(dirname ~/"$whoami"code_data/Bash/.)" does not exist"
    echo "Creating working directory"
    mkdir -p "$(dirname ~/"$whoami"code_data/Bash/.)"
fi

if [ ! -z "$1" ] && [ -z "$2" ];
then
    case $1 in

    -h|--help)
        HELP
        ;;

    -m|--monitor)
        MONITOR_INSERT &
        MONITOR_DATABASE &
        ;;

    -g|--gui)
        GUI
        ;;

    *)
        echo "Use -h or --help to get the list of valid options and know what the program does"
        ;;
    esac

elif [ -z "$1" ]
then
    echo "Use -h or --help to get the list of valid options and know what the program does"
fi
#############################################################################################################################################################################
