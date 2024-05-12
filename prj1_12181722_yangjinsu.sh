#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 teams.csv player.csv matches.csv"
    exit 1
fi

teams_file=$1
players_file=$2
matches_file=$3

show_first() {
    echo "********OSS1 -Project1********"
    echo "*   studentId : 12181722     *"
    echo "*   Name : Yang Jinsu        *"
    echo "******************************"
}

menu() {
    echo "[MENU]"
    echo "1. Get data of Heung-Min Son's Current Club, Appearnaves, Golas, Assists"
    echo "2. Get the team data to enter a league position"
    echo "3. Get the Top-3 Attendance matches"
    echo "4. Get the team's league position and team's top scorer"
    echo "5. Get the modified format of date_GMT"
    echo "6. Get the data of the winning team by the largest difference on home stadium"
    echo "7. Exit"
    echo "Enter your CHOICE (1~7) :"
}

hm7() {
    echo "Do you want to get the Heung-Min Son's data? (y/n) :"
    read answer
    if [ "$answer" = "y" ]; then
        awk -F',' '$1 == "Heung-Min Son" {print "Team: "$4", Appearances: "$6", Goals: "$7", Assists: "$8}' $players_file
    fi
}

team_position() {
    echo "What do you want to get the team data of league_position[1~20] : "
    read position

    awk -F',' -v pos="$position" '$6 == pos {
        team_name=$1
        wins=$2
        draws=$3
        losses=$4
        winning_rate=wins/(wins+draws+losses)
        printf "%d %s %.6f\n", pos, team_name, winning_rate
}' $teams_file
}

top3_attendance() {
    echo "Do you want to know Top-3 attendance data and average attendance? (y/n) : "
    read answer
    if [ "$answer" == "y" ]; then
        echo "***Top-3 Attendance Match***"

        awk -F',' 'NR > 1 {print $0}' "$matches_file" | sort -t',' -k2 -nr | head -3
    fi
}

position_and_scorer() {

    echo "Do you want to get each team's ranking and the highest-scoring player? (y/n) : "
    read answer
    if [ "$answer" == "y" ]; then
        touch sorted_teams

        awk -F',' 'NR > 1 {print $6 "," $1}' teams.csv | sort -n >sorted_teams

        while IFS=',' read -r league_position team_name; do
            echo "$league_position $team_name"
            top_scorer=$(awk -F',' -v team="$team_name" '
        BEGIN {max_goals = 0; player = "unknown"; goals = 0}
        $4 == team && $7 > max_goals {max_goals = $7; player = $1; goals = $7}
        END {print player " " goals;}
    ' players.csv)
            echo "$top_scorer"
            echo ""
        done <sorted_teams

        rm sorted_teams
    fi
}

modify_date_GMT() {
    echo "Do you want to modify the format of date? (y/n) : "
    read answer
    if [ "$answer" == "y" ]; then
        sed -r '
    1d;
  s/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g;
  s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g;
  s/Nov/11/g; s/Dec/12/g;
  s/^([^,]*)(,[^,]*){6}/\1/;
  s/([0-9]{2}) ([0-9]{2}) ([0-9]{4}) - ([0-9]{1,2}:[0-9]{2}(am|pm))/\3\/\1\/\2 \4/
' $matches_file | head -10
    fi
}

get_largest_home_win() {
    echo "1) Arsenal    11) Liverpool"
    echo "2) Tottenham Hotspur  12) Chelsea"
    echo "3) Manchester City     13) West Ham United"
    echo "4) Leicester City     14) Watford"
    echo "5) Crystal Palace     15) Newcastle United"
    echo "6) Everton    16) Cardiff City"
    echo "7) Burnley    17) Fulham"
    echo "8) Southampton 18) Brighton & Hove Albion"
    echo "9) AFC Bournemouth 19) Huddersfield Town"
    echo "10) Manchester United 20) Wolverhampton Wanderers"

    echo "Enter your CHOICE (1-20): "
    read team_number
    team_name=$(awk -F',' 'NR == ('$team_number' + 1) { print $1 }' teams.csv)

    awk -F',' -v team="$team_name" '
BEGIN {
    max_diff = 0;
}
$3 == team {
    goal_diff = $5 - $6;
    if (goal_diff > max_diff) {
        max_diff = goal_diff;
        delete results; 
    }
    if (goal_diff == max_diff) {
        results[$1] = $1 "\n" $3 " " $5 " vs " $4 " " $6 ;  
        }
}
END {
    for (date in results) {
        print results[date];  
    }
}' matches.csv
}

show_first
while true; do
    menu
    read choice
    case "$choice" in
    1) hm7 ;;
    2) team_position ;;
    3) top3_attendance ;;
    4) position_and_scorer ;;
    5) modify_date_GMT ;;
    6) get_largest_home_win ;;
    7)
        echo "Bye!"
        exit
        ;;
    *) echo "Invalid option. Please enter a number between 1 and 7." ;;
    esac
done
