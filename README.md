# cloud_storage_issue

Demonstration repo to show the base64 encoding issue when using the Cloud
Storage emulator with the [googleapis] to upload media.

The issue is that when using the Cloud Storage emulator and uploading via the
[googleapis] package, the content is being stored as base64 preceeded by a
newline character.  For example, uploading this text:
```
Hello World!
```

Results in this being stored in Cloud Storage's emulator:
```

SGVsbG8gV29ybGQh
```

**Usage**

To run the example:
1. Install the [Firebase CLI](https://firebase.google.com/docs/cli)
1. Open a terminal window in the root and run: `firebase emulators:start`
1. Download a GCP service account JSON file and place it in the root named `service_account.json`.
    * Alternative: the contents can be placed on the environment variable: `FIREBASE_SERVICE_ACCOUNT`
1. Execute: `dart test`

The tests will...
1. Upload all the files located in `data` to Cloud Storage.
1. Download all the files from Cloud Storage and place them in `output`.
1. Verify the contents are the same.
1. Verify the contents are not base64 encoded.

If the tests pass, all is well.  If not, the Cloud Storage issue persists.

**Advanced**

The repo is set to show the issue with the Cloud Storage emulator when using
[googleapis], but it can also be used to show the same issue is not present when
using the live Cloud Storage APIs.

To test against a live Cloud Storage API, set the following environment
variables:

Name                       | Value
---------------------------|-------
`FIREBASE_SERVICE_ACCOUNT` | &lt;service account json>
`STORAGE_BUCKET`           | &lt;storage bucket name>
`STORAGE_URL`              | https://storage.googleapis.com/

Then just re-run the tests.

<!-- Links -->
[googleapis]: https://pub.dev/packages/googleapis
