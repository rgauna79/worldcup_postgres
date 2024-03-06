#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

declare -A teams

# read data and insert into teams table
while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # store teams name in the array
    teams["$WINNER"]=1
    teams["$OPPONENT"]=1
  fi
done < games.csv

for team_name in "${!teams[@]}"
do
  # Check if team already exist
  TEAM_EXISTS=$($PSQL "SELECT EXISTS (SELECT 1 FROM teams WHERE name='$team_name')")
  # If team not exists
  if [[ $TEAM_EXISTS == "f" ]]
  then
    # Insert team name in the teams table
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$team_name')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams, $team_name"
    fi
  fi
done


# # read data and insert into games table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #Check if not is the header row
  if [[ $YEAR != "year" ]]
  then
    # Get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # Get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # Insert data in games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND','$WINNER_ID', '$OPPONENT_ID', $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $YEAR $ROUND $WINNER $OPPONENT"
    fi
  fi
done