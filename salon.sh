#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n~~SALON SERVICES~~\nPlease choose service you like:"
MAIN_MENU(){
  #show services
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
  SALON_SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$SALON_SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
    
  done
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ && \
  $SERVICE_ID_SELECTED -le 3 && $SERVICE_ID_SELECTED -ge 1 ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services \
    WHERE service_id='$SERVICE_ID_SELECTED';")
    echo -e "\nEnter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers \
    WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nWe do not have your name yet.Enter your name please"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) \
      VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers \
      WHERE phone='$CUSTOMER_PHONE'")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers \
    WHERE phone='$CUSTOMER_PHONE';")
    echo -e "\nEnter time for your service to happen please"
    read SERVICE_TIME
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments\
    (customer_id, service_id, time) \
    VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    MAIN_MENU "MUST CHOOSE A VALID SERVICE NUMBER"
  fi
}
MAIN_MENU
