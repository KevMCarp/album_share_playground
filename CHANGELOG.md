
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 20/09/2024

### Added

- Changelog
- Added album title to AssetViewerScreen

### Changed

- Use same colour on material navigation bars and material app bar.
- Updated default preferences.

### Fixed
- Tapping on desktop app bar causes it to hide.
- AssetViewerPage popping when image zoomed.
Now, when the user attempts to navigate back, the image scale is first reset then the page popped if the user attempts to navigate back a second time
-  If the user attempts to navigate backwards after logging in, the user is taken to the login page again but remains logged in.
- Pop called twice when asset swiped down.


[0.2.1]: https://github.com/ConcenTech/album_share/compare/main...0.2.1
