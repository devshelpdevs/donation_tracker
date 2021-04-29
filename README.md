This is the repository for the DevsHelpDevs Donation Tracker Flutter Web app https://helpdevs-tracker.netlify.app
# donation_tracker

Because I get regularly requests for help for repairs or updates and I don't want to wait to have the DevsHelpDevs platform finished, Jimmy and I developed this flutter web app to allow me to track and show all donations usages and waiting people.
Besides that it helps me to keep better track of and outgoing money, it will also act as a proof of concept for the whole platform.

As it turned out that I will need to use this app more than originally thought and to be able to make it possible that other developers can easily contribute, the app can be configured when building or running a passing and a environment variable to define the used database server end up in secrets.

## Possible configurations

To allow adding editing features in a safe way I set up a separate staging backend on Nhost which can be used by everyone for developing.
To keep things simple, we won't add full user management. To allow write access to the database the app will get past in the admin secret is environment variable during build. If no admin secret is provided the app won't have write access and won't display any editing features. The admin secret of the production database won't be included in the github repository but I can build a local desktop versions for myself using the correct key. The admin secret for the staging environment will be included in the debug configuration.

Environment variables that can be passed in:

```
--dart-define SERVER=63b34375.nhost.app
--dart-define HASURA_SECRET=4bd0efc0d8ba8636fd63b3ab25f35c56
--dart-define USER_ID=e79ea538-7b5d-4854-8acd-a284c1923209
--dart-define AUTH_PASSWORD=uZKFT5QU5eaEmk
```

only if you pass in the last three you will be able to modify the data content.

For VS code I included 2 different run configurations to switch between read only production database and write access staging server.
If you don't provide any environment variable the app defaults to read only production server.
If you are using android studio you will have to find out how to class in built environment variables yourself

The `NHostService` class has a property `hasWriteAccess` that can be used by the app to switch between readonly and editing mode.
