# Timelog

-   Restaurant App
-   Scott Brown
-   2305539B
-   Mireilla Bikanga Ada

## Guidance

-   This file contains the time log for your project. It will be submitted along with your final dissertation.
-   **YOU MUST KEEP THIS UP TO DATE AND UNDER VERSION CONTROL.**
-   This timelog should be filled out honestly, regularly (daily) and accurately. It is for _your_ benefit.
-   Follow the structure provided, grouping time by weeks. Quantise time to the half hour.

## Week 3

### 6 Oct 2020

-   _0.5 hours_ Meeting with supervisor
-   _2 hours_ reading MyChecking Dissertation

### 7 Oct 2020

-   _2 hours_ Game-Based Learning: Puzzle Prog

### 11 Oct 2020

-   _4 hours_ Reading google scholar articles for literacy review

## Week 4

### 13 Oct 2020

-   _3 hours_ Conducted existing app research

### 14 Oct 2020

-   _1 hours_ Continued existing app research
-   _1 hours_ Started compiling list of requirements

### 18 Oct 2020

-   _1.5 hours_ Started drafting wireframes

## Week 5

### 20 Oct 2020

-   _3 hours_ Created survey on Google Forms after trying survey monkey

### 21 Oct 2020

-   _2 hours_ Created python script to analyse results of survey for requirement prioritisation

### 23 Oct 2020

-   _3 hours_ Refined requirements and started wireframes

### 24 Oct 2020

-   _1 hours_ Finished wireframes

## Week 6

### 27 Oct 2020

-   _3 hours_ Create system architecture diagram and identified key backend services

### 28 Oct 2020

-   _4 hours_ Finished system architecture diagram as well as the ER diagram and use case diagram

## Week 7

### 3 Nov 2020

-   _3 hours_ Used feedback from weekly meeting to improve diagrams before starting implementation

## Week 8

### 11 Nov 2020

-   _5 hours_ Created project in Xcode and started the implementation with creating the tab view structure of the application as well as integration with Firebase.

## Week 9

### 17 Nov 2020

-   _5 hours_ Implemented the RestaurantSelectView to allow users to select which restaurant they're at, restaurants are retrieved from Firebase with their name and splash image displayed to the user

## Week 10

### 23 Nov 2020

-   _5 hours_ Started implementation of MenuSelectView which would display menu's and their items to users although difficulties were encountered when trying to retrieve menu information and that of their items from Firebase in one view.

## Week 11

## Week 12

### 7 Dec 2020

-   _5 hours_ Created MenuView to display items from the menu selected in MenuSelectView

### 8 Dec 2020

-   _3 hours_ Continued working on MenuView and implemented sheet views to allow users to customise items with a button to add that item to their order.

## Week 13

### 14 Dec 2020

-   _2 hours_ Researching how orders could be constructed within the app and data shared between distant sibling views

### 16 Dec 2020

-   _4 hours_ Implemented the data structure for storing orders with the order being displayed on the OrderView

### 18 Dec 2020

-   _5 hours_ Attempted implementation of payment processing however ran into difficulties due to a lack of documentation of implementing Stripe with SwiftUI

## Week 15

### 29 Dec 2020

-   _4 hours_ Continued trying to implement payment processing by interfacing SwiftUI with UIKit which Stripe has examples for although this was unsuccessful.

### 3 Jan 2021

-   _7 hours_ Set aside payment processing and began to implement authentication for restaurant admins and customers including views for signing in with email and password as well as creating an account via a separate sign up view.

## Week 16

### 4 Jan 2021

-   _5 hours_ Created views for users and restaurant admins to view their account details and in the case of restaurant admins their restaurants details, these will later be updated to allow for changes to be made and saved.
-   _3 hours_ Began implementation of menu creation tools for restaurant admins, the original plan was for the restaurant tab to be replaced with this when signed into a restaurant admin account however it proved difficult to change a view when the view is not active so a button was created in the UserView to allow for the menu creation views to be accessed.

### 5 Jan 2021

-   _5 hours_ Menu creation tools are now working although image uploads still need to be implemented as well as start and end times for menus, restaurant admins can now create menus, add items and add extras to those items.
