#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE games, teams")"
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # if not header
  if [[ $YEAR != year ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # if winner has no record in teams yet
    if [[ -z $WINNER_ID ]]
    then
        INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        if [[ $INSERT_WINNER == 'INSERT 0 1' ]]
        then
          WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
        fi
    fi

    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # if opponent has no record in teams yet
    if [[ -z $OPPONENT_ID ]]
    then
        INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        if [[ $INSERT_OPPONENT == 'INSERT 0 1' ]]
        then
          OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
        fi
    fi
    
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, opponent_id, winner_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $OPPONENT_ID, $WINNER_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAMES == 'INSERT 0 1' ]]
    then 
      echo "Added record for $YEAR $ROUND round: $OPPONENT vs $WINNER"
    fi
  fi
done