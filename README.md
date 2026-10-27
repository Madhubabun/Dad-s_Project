# Raithe Raju (రైతే రాజు)

A simple farming companion app for a paddy farmer in Masarakal village,
Devadurga taluk, Raichur district. Telugu first, English in settings.

## Where things are

| Folder | What it is |
|---|---|
| `app/` | The Flutter Android app |
| `.github/workflows/build-apk.yml` | Builds the APK and puts it on the Releases page |

## Getting the app onto Dad's phone

1. Open the [Releases page](../../releases/latest) and download the `.apk` file.
2. Send it to Dad on WhatsApp as a document.
3. On his phone, tap the file and allow "Install unknown apps" for WhatsApp when asked.

A new version installs over the old one and keeps his saved data, because
every build is signed with the same key (stored as GitHub secrets).

## Build plan

- **Phase 1 (done):** Fertilizer credit and interest calculator, offline, Telugu/English, with tests.
- **Phase 2:** Backend (GitHub Actions + `data.json`) for weather, paddy prices and dam level, and the dashboard.
- **Phase 3:** Background sync, home-screen widget, morning notification, battery check.
- **Phase 4:** Extras based on Dad's feedback.
