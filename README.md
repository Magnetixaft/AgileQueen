# AgileQueen

Group: Queen
DAT257 Agile Software Project Management

## Repository file structure

* Docs - DartDocs for the entire app available [here](https://github.com/Magnetixaft/AgileQueen/tree/main/Docs)
* Source code is available directly in this repo. Classes are located in (lib)[https://github.com/Magnetixaft/AgileQueen/tree/main/lib]
* Deliverables - Weekly deliverables available [here](https://github.com/Magnetixaft/AgileQueen/tree/main/Deliverables)
* Test - Tests for the app available [here](https://github.com/Magnetixaft/AgileQueen/tree/main/test)
* Img - Images used in the ReadMe available [here](https://github.com/Magnetixaft/AgileQueen/tree/main/img)

## About Elli

Elli is a office space booking app created as part of the course DAT257 at Chalmers University of Technology. It consists of a smartphone application, available in this repository, and a web-based admin console available [here](https://github.com/Magnetixaft/elli_admin).

## Functionality

In this section, Elli's primary functionality is described.

### Login using Microsoft Azure

Elli only allow login using Microsoft Azure from select organisations. Simply press the login button and login using you Microsoft work-credentials:

<img src="https://github.com/Magnetixaft/AgileQueen/blob/main/img/azurelogin.gif" width="300" />

### Make a booking

To make a booking, simply navigate to the *Book* tab. Green signals an available timeslot, yellow a timeslot that has already been booked by you and a red timeslot is booked by another user.

<img src="https://github.com/Magnetixaft/AgileQueen/blob/main/img/book.gif" width="300" />

### View your bookings

To view, delete or add you bookings to your calendar, simply navigate to the *My Bookings* tab.

<img src="https://github.com/Magnetixaft/AgileQueen/blob/main/img/mybookings2.gif" width="300" />

## Compiling and running

In order to run Elli you must compile the source code yourself. Although Elli works great on iOS devices as well, installation instructions for Android devices are given here. To install, please follow the below instructions:

Requirements:
- Flutter SDK version 2.10.4
- A development environment with Android SDK version 32 or above
- An Android emulator or Android device

Run from source:
1. Clone the repository: `git clone https://github.com/Magnetixaft/AgileQueen`
2. Fetch Flutter packages: `flutter pub get`
3. Make sure your emulator or device is connected an run the app: `flutter run --release`
    1. If you wish to enable debug functions when running, use `flutter run --debug`

## Documentation

Elli's codebase is documented using [DartDoc](https://dart.dev/guides/language/effective-dart/documentation). To view the compiled docs, kindly download the files from [here](https://github.com/Magnetixaft/AgileQueen/tree/main/Docs) and open `index.html` using your favorite browser.




