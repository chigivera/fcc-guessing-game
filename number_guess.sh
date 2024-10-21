#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Fetch user ID
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME' AND MIN(best_game)")

if [[ -n $USER_INFO ]]
then
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # Insert new user with initialized games_played and best_game
    INSERT_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, 9999)")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    BEST_GAME=9999
fi

echo "Guess the secret number between 1 and 1000:"
TO_GUESS=$(($RANDOM % 1000 + 1))

TRIES=0
while true; do
    read GUESS

    # Validate input
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    TRIES=$(($TRIES + 1))

    if [[ $GUESS -lt $TO_GUESS ]]; then
        echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $TO_GUESS ]]; then
        echo "It's lower than that, guess again:"
    else
        break
    fi
done

# Update games played and possibly best game
INSERT_USER=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")

if [[ $BEST_GAME -gt $TRIES ]]; then
    INSERT_USER=$($PSQL "UPDATE users SET best_game = $TRIES WHERE user_id = $USER_ID")
fi

echo "You guessed it in $TRIES tries. The secret number was $TO_GUESS. Nice job!"
exit 0