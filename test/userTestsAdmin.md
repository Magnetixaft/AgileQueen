# User tests

Elli_Admin has been extensively tested throughout its development in order combat bugs and unexpected behaviors. After each major commit made by a developer, the devloper in question is resposnbile to ensure that the Elli works as intended by following the below guidelines. Something that has been tested:
*Home*
1. Add and remove companies/offices/rooms shoud add and remove companies/offices/rooms in Firebase database.
2. The newly added companies/offices/rooms shoud should be visable/bookable from the Elli user app.
3. After selecting a company/offices/rooms on the drop down menus only company/offices/rooms selected should be shown.

*Analytics*
1. The admin should be able to navigate and see the collected data from all the diffrent companies/offices/rooms.
2. The data should be updated dynamiclly from the Firebase database.

*Config*
1. Adding another admin should give the new admin access to the app.

*Navigation bar*
1. All icons should take the user to the right location.
2. The logut button should log the user out from the application.

## Basic functionality

Elli_Admin's basic functionality is described here. Ensure that this functionality is sustained after every change to the codebase:

1. The user can log into Elli_Admin using Microsoft Azure.
2. The home page has three tabs on the leftside navigation bar: 
*Home*, where the admin can add new companies, offices and rooms and aslo configure them after their own liking; 
*Analytics*, for viewing information about all the bookings made by all the user of the Elli app summarized in a efficent way; and
*Config*, where the admin can add other admins and give them acces to the admin app as well as reading the about section of the app.

## Errors

Confirm the following:

1. Ensure that the application does not throw any errors during compilation or when the user interacts with the functionality you just implemented.

## Mockup

Confirm the following:

1. View the mockup by navigating to [Figma](https://www.figma.com/file/OH1IiUEHbN5u6XwuJrUJkZ/Admin-mockup?node-id=0%3A1).
2. Confirm that the steps of adding offices, rooms and workspaces in the admin app matches the intended process visualised in the mockup.
3. Confirm that the app's graphical interface uses Elli's predetermined visual identity. Again as in the user app, see the mockup.
