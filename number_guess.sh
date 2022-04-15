
#!/bin/bash

PSQL="psql -X -U freecodecamp -d number_guess --tuples-only -c"

MAIN(){
  SECRET_NUMBER=$(( $RANDOM%1000 ))

  echo "Enter your username:"; read USERNAME

  CHECK_USERNAME $(echo $USERNAME | sed -E 's/^ *| *$//g')

  GUESS_NUMBER
}

CHECK_USERNAME() {
  GET_USER_RESULT=$($PSQL "SELECT user_id FROM users WHERE username = '$1'")
  # if user not create
  if [[ -z $GET_USER_RESULT ]]
  then
    INSERT_USERNAME $1
  else
    PRINT_USER_INFO $1
  fi
}

INSERT_USERNAME(){
  echo "Welcome, $1! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$1');")
}

PRINT_USER_INFO(){
  GET_USER_RESULT=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$1'")
  
  if [[ $GET_USER_RESULT ]]
  then
    echo $GET_USER_RESULT | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  else
    echo "Current user $1 not found"
  fi
}

GUESS_NUMBER() {
  if [[ ! $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
    NUMBER_OF_GUESSES=$(( 0 ))
  else
    echo $1
  fi

  read PLAYER_NUMBER 
  
  CHECK_NUMBER $PLAYER_NUMBER

}

CHECK_NUMBER() {
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    if [[ $1 -gt $SECRET_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES += 1 ))
      GUESS_NUMBER "It's higher than that, guess again:"
    elif [[ $1 -lt $SECRET_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES += 1 ))
      GUESS_NUMBER "It's lower than that, guess again:"
    else
      (( NUMBER_OF_GUESSES += 1 ))
      GAMES_FINAL
    fi

  else 
    GUESS_NUMBER "That is not an integer, guess again:"
  fi
}

GAMES_FINAL(){
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1;")

  # check best game
  BEST_GAME_RESULT=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME_RESULT ]] || [[ $BEST_GAME_RESULT -eq 0 ]]
  then
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';")
  fi

}

MAIN
