This is the repository for the DevsHelpDevs Donation Tracker Flutter Web app https://helpdevs-tracker.netlify.app
# donation_tracker

Because I get regularly requests for help for repairs or updates and I don't want to wait to have the DevsHelpDevs platform finished, Jimmy and I developed this flutter web app to allow me to track and show all donations usages and waiting people.
Besides that it helps me to keep better track of and outgoing money, it will also act as a proof of concept for the whole platform.

As it turned out that I will need to use this app more than originally thought and to be able to make it possible that other developers can easily contribute, the app can be configured when building or running a passing and a environment variable to define the used database server end up in secrets.

## Possible configurations

To allow adding editing features in a safe way I set up a separate staging backend on Nhost which can be used by everyone for developing.

To select the staging backend you have to pass in the server it should use:

```
--dart-define SERVER=63b34375.nhost.app
```

To be able to make mutation to data you have to log-in:

```dart
    await server.loginUser('mail@devshelpdevs.org', 'staging');
```

For VS code I included 2 different run configurations to switch between read only production database and write access staging server.
If you don't provide any environment variable the app defaults to read only production server.
If you are using android studio you will have to find out how to class in built environment variables yourself

The `NHostService` class has a property `hasWriteAccess` that can be used by the app to switch between readonly and editing mode.
