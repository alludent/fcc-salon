#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align -t -c"

MAIN_MENU() {
  # out services
  echo -e "\n~~ SALON SERVICES ~~"
  # COUNT=$($PSQL "SELECT COUNT(*) FROM services")
  echo "$($PSQL "SELECT * FROM services")" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # read input
  echo "Which service?"
  read SERVICE_ID_SELECTED
  if [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'") ]]
  then
    # doesnt exist
    echo "$SERVICE_ID_SELECTED is not a valid option. Try again."
    MAIN_MENU
  else
    # exists
    echo "Ok. What's your phone number?"
    read CUSTOMER_PHONE

    # check if phone number exists
    if [[ -z $($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'") ]]
    then
      # it doesnt exist
      echo "Looks like you're a new customer. What's your name?"
      read CUSTOMER_NAME 
      echo "OK, $CUSTOMER_NAME. What time would you like to reserve?"
      read SERVICE_TIME
      echo $($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo "I have put you down for a $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      # it exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo "Welcome back, $CUSTOMER_NAME. What time would you like to reserve?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      echo $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo "I have put you down for a $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi # end of service id selected
}


MAIN_MENU
