
# Test_app_drpx

## Project Description
`Test_app_drpx` is an iOS test application developed to provide users with the ability to view and manage their media files in a shared project folder on Dropbox. The application incorporates functionalities like authentication via the Dropbox API, viewing a list of media files with detailed information on each, and features such as caching and pagination.

### Features
1. **Authentication via Dropbox API**: Users can easily log in using their Dropbox accounts.
2. **Media Files Listing**: The application provides a list of all photos and videos available in the shared project folder on Dropbox.
3. **Detailed Media File View**: Upon clicking on a specific media file, a detailed view opens up, providing additional information.
4. **Caching and Pagination**: The application implements caching for quick loading and pagination for convenient navigation.

## Technology Stack
- **Architecture**: MVVM - a modern approach to code structuring, ensuring a clean and modular structure.
- **Dependency Injection**: Swinject - a library for implementing dependency injection, simplifying dependency management and enhancing testability.
- **Reactive Programming**: Combine - a framework for handling asynchronous events and reactive programming.
- **UI**: UIKit (supplemented with navigation management tools like NavigationNode).
- **Unit Testing**: CombineExpectations and some unit tests to ensure code stability and reliability.
- **API Integration**: SwiftyDropbox - integration with the Dropbox API for implementing authentication and file management functionalities.
- **Package Manager**: Swift Package Manager - a tool for managing dependencies and packages in Swift projects.

## Installation and Launch
To install and launch the project, follow these steps:
1. Clone the repository in your local system.
2. Open the project through Xcode.
3. Run the project by clicking the "Run" button.
4. After launching, press the "login" button and follow the Dropbox instructions for authentication and file viewing.

## Architecture and Navigation
In this section, you can describe in more detail the architectural decisions made in the project, as well as navigation features (you can include diagrams or charts if available).

## Collaboration
If you want to contribute to the project, adhere to the current architectural structure and coding standards. Additionally, you can provide instructions for creating branches, submitting pull requests, etc.

## License
This project is distributed under the MIT license. Detailed information can be found in the LICENSE file (if it will be added to the project).
