# Readme

The code for Scoff is written mainly in Swift with the source code contained within the _Scoff_ folder. The main point of entry for the code is _ScoffApp.swift_ and _AppView.swift_ which defines the tabular structure of the app. Inside the Scoff folder there is:

-   The _RestaurantViews_ folder containing all the views relating to selecting a restaurant and constructing an order.
-   The _UserViews_ folder containing all views relating to account management.
-   The _RestaurantAdminViews_ folder containing the views allowing a restarauant admin to manage their menus, view incoming orders and change restaurant details.
-   Inside the _Scoff_ folder there its also _OrderView.swift_ which is the view used to checkout and place an order as well as _VuewExtensions.swift_ which defines a few commonly used buttons.

### Requirements

-   macOS 10.15.4 or later
-   Xcode 12.4
    -   Can be downloaded from the Mac App Store
-   CocoaPods dependency manager
    -   Can be installed with terminal command `sudo gem install cocoa pods`
-   Dependencies listed in _Podfile_
    -   Can be installed after installing Cocapods by running command `pod install` while in folder containing the _Podfile_

## Build instructions

### Build steps

-   Install all necessary requirements.
-   After `pod install` has been ran, use the _Scoff.xcworkspace_ file created to open the project.
-   Xcode will now open with the project and begin to set up the environment (this may take some time).
-   The navigation bar at the top of the Xcode window can be used to set a device for the simulator
-   Scoff can be built and ran by clicking the play button (▶) in the navigation bar or using key command `command` + `r` (`⌘` + `r`).

### Test steps

Scoff can then be tested by navigating the UI.
New customer accounts can be created, alertnativly test accounts can be accessed.

-   Customer Account
    -   email `test@email.com`
    -   password `password1`
-   Restaurant Admin Account
    -   email `testaurant@email.com`
    -   password `password1`
