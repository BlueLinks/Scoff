# User manual

## How to run Scoff

To run Scoff, open the project in Xcode using the _Scoff.xcworkspace_ file created by Cocoapods. Then click the play button (▶) in the navigation bar or use the key command `command` + `r` (`⌘` + `r`). This will open Scoff on a simulated device.

## Create an account

To create a user account, navigate to the rightmost tab at the bottom of the screen. Presented will be options to sign in or create an account. Select _Sign Up_ to be brought to the sign up page, fill out this form and select the _Sign Up_ button at the bottom of the page to create an account.

## Edit account details

Once signed into a customer account. Select the _User Details_ option found on the User tab. Once a detail has been changed, the _Save_ button at the top right can be used to save these changes. The email and password for the account can also be changed however the user will need to reauthenticate.

## Select a restaurant

Navigating to the leftmost _Restaurant_ tab and tapping the _Find a restaurant_ button will present a list of restaurants available. This list can be searched using the search bar however only the prefix of a restaurant names can be searched for. A _Get More_ button at the bottom of the page can be selected to fetch more restaurants. Tap a restaurant to select it. A map icon in the top right of the screen can be tapped to display all currently fetched restaurants on a map, each pin can be tapped and the _i_ icon displayed tapped to select the restaurant. Currently only _Testaurant_ has menus and items.

## Check in Scotland

Once a restaurant has been selected, a prompt will allow a user to fill out a check in Scotland form for track and trace. This form is only for demonstrating that a form can be presented so the _Done_ button in the top left can be tapped to dismiss this.

## Construct an order

Once _Testaurant_ has been selected, various menus can be accessed containing items, these menus can be navigated between by selecting and using the back button in the top left. Click on an item to select it, a view will be presented allowing any extras to be added, a quantity to be set, any extra notes to be left for the chef and a button to add the item to the order. Once an item has been added, an indicator will appear on the icon for the middle tab at the bottom of the screen to indicate how many items are in the current order. If the user navigates away from the current restaurant, they will be warned that if they continue, their order will be cleared.

## Place an order

Navigate to the middle tab to see the current items in the order. The button in the top right can be used to toggle edit mode, allowing items to be deleted from the order. These items can also be swiped upon to be deleted (Swipe to the left). The table number can also be specified here. Once the checkout button is tapped a warning for the user to check their table number is presented, if the user is sure then a form for card details will be presented. As payment processing was not implemented, the _Pay £X now_ button can be tapped without filling out the form to place an order. An alert will show that the order has been placed.

## View a past order

Navigate to the _User_ tab and select _Receipts View_ option. Here will be a list of all past receipts, if a recently placed order is now displayed, tap the _Get more_ button.

## Sign out of an account

Select the _Sign out button_ on the _User_ tab to sign out, a warning will be presented to make sure a user wishes to sign out.

## Sign into a restaurant admin account

Select the _Sign In_ option on the _User_ tab and use email `testaurant@email.com` and password `password1` to tap the sign in button to sign into the account for Testaurant.

## Create and edit a menu

Select the _Edit Menus_ option on the _User_ tab while signed into a restaurant admin account. The first view will show all the current menus, a form will be presented to add new menus by tapping the _Add menu_ button at the bottom of the list. These menus can be deleted in a similar fashion to that of items in an order. Tapping on a menu will open a view containing the menus details and list of items. The _Edit Menu_ button can be used to change menu details with a _Save_ button in the top right. This sheet can be dismissed once opened by swiping down. Items can be added to this menu by tapping the _Add item_ button and deleted in a similar fashion to adding and deleting a menu. Tapping on an item will open a view containing the item details and list of extras. This UI is almost the same as that of the menu edit view and allows for item details to be modified and the items extras to be managed in a similar fashion to that of the items.

## View incoming orders

Incoming orders can be viewed by tapping the _Incoming Orders_ button on the _User_ tab. New orders will be shown when they are placed.
