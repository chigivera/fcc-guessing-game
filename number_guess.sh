#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
echo $USER_ID
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "insert into users (username, best_game) values ('$USERNAME', 9999)")
  USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
  BEST_GAME=$($PSQL "select best_game from users where user_id = $USER_ID")
else
  GAMES_PLAYED=$($PSQL "select games_played from users where user_id = $USER_ID")
  BEST_GAME=$($PSQL "select best_game from users where user_id = $USER_ID")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
TO_GUESS=$(($RANDOM % 1000 + 1))
read GUESS

TRIES=1
while [[ $GUESS -ne $TO_GUESS ]]
do
  if [[ $GUESS =~ ^[0-9]*$ ]]
  then
    TRIES=$(($TRIES + 1))
    if [[ $GUESS -lt $TO_GUESS ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
    else
      if [[ $GUESS -gt $TO_GUESS ]]
      then
        echo "It's lower than that, guess again:"
        read GUESS
      fi
    fi
    else
      echo "That is not an integer, guess again:"
      read GUESS
  fi
done
  INSERT_USER=$($PSQL "update users set games_played = games_played + 1 where user_id = $USER_ID")
  
if [[ $BEST_GAME -gt $TRIES ]]
then
  INSERT_USER=$($PSQL "update users set best_game = $TRIES where user_id = $USER_ID")
fi

echo "You guessed it in $TRIES tries. The secret number was $TO_GUESS. Nice job!"
exit 0