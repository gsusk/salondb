#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
GET_SERVICES=$($PSQL "SELECT * FROM services")

echo -e "\n~~ Welcome to the Beauty Hall ~~\n"

SALON_SERVICES(){

  if [[ $1 ]]; then
    echo -e "\n$1\n"
  fi

  echo "$GET_SERVICES" | while IFS='|' read ID SERVICE
  do
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  GET_REQUESTED_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $GET_REQUESTED_ID ]]; then
    SALON_SERVICES "Such service doesnt exist"
  else
    echo -e "\nPlease enter your phone Number"
    read CUSTOMER_PHONE
    GET_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $GET_CUSTOMER_PHONE ]]; then
      echo -e "\nPlease enter your name"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_DATA=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    echo -e "\nEnter the Time"
    read SERVICE_TIME
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    GET_OUTPUT_DATA=$($PSQL "SELECT * FROM customers INNER JOIN appointments USING(customer_id) INNER JOIN services USING(service_id)")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $NAME."
  fi

}

SALON_SERVICES
