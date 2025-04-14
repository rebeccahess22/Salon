#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_SERVICES() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi 

  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_OF_SERVICES" | while read  SERVICE_ID BAR NAME
  do 
    #cleaning the strings 
    SERVICE_ID=$( echo $SERVICE_ID | sed 's/ //g' )
    NAME=$( echo $NAME | sed 's/ //g')

    echo "$SERVICE_ID) $NAME"
  done 

  echo -e "\nSelect a service:"
  read SERVICE_ID_SELECTED 
  SERVICE_ID_SELECTED=$( echo $SERVICE_ID_SELECTED | sed 's/ //g' )
  
  #check to see that the service is one that we offer 
  NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed "s/ //g" )
  if [[ -z $NAME ]]
  then 
    GET_SERVICES "You have selected an invalid response."
  else 
    echo  -e "\nYou have selected $NAME"
  fi 

  #collect customer information 
  #get phone number 
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE 
  echo "You entered $CUSTOMER_PHONE"

  #check if we have that customer 
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/ //g' )
  if [[ -z $CUSTOMER_NAME ]]
  then 
    #if we dont add them to the customers table 
    echo -e "\nWe didn't find you in our records. What's your name?"
    read CUSTOMER_NAME 

   INSERT_CUSTOMER_RESULT=$( $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" )
   if [[ ! -z $INSERT_CUSTOMER_RESULT ]]
   then
    echo -e "\nYou have been successfully added to our records." 
   fi 
  fi 

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #ask for a time 
  echo -e "\nWhat time works for you?"
  read TIME
  echo -e "\nYou have selected $TIME."

  #add appointment to the appointment table
  APT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$TIME')")
  if [[ $APT_RESULT = 'INSERT 0 1' ]]
  then 
    echo -e "\nI have put you down for a $NAME at $TIME, $CUSTOMER_NAME."
  fi 



}

GET_SERVICES
