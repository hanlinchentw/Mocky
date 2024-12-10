
![截圖 2024-12-10 下午4 01 16](https://github.com/user-attachments/assets/06622d9b-8f71-4960-8459-5fcd2ad3be31)

### Table of Contents

### [Mock API Response](#mock-api-response)
- Add a new test case with launchArguments `.taLocalMock(port: localServerPort)`.
- Place the new JSON file with the response acquired from other sources, like Proxyman, under DriveUITests/Data/ or create a folder under it if you prefer.
- Use the newly added JSON file for mocking, for example:
```swift
mockResponse(using: "mock_file.json", forService: .webAPI(.entry, api: "SYNO.SynologyDrive.Files", method: "list"))
```
- Now, the mock_file.json will be used as a response for the given API path.
- Note: If you need mocks before app launch, place them before app.launch().

### [Implement](#implement-ui-test)

- Create a UI test file and a class inherited from UITestCase.
- Override launchArguments if you need any extra setup, e.g, loggedIn(.useInitiallyLoggedInUser(.hct)).
- <a href="#pageobject">Prepared the testing pageCreate your test page</a>
- In your test functions, call app.launch(), and it will launch the app. You can start your assertions by creating testPage (e.g., HomeScreen(app: app).assertExists(.yourComponent)).

#### Example
```swift
final class HomeUITest: UITestCase {
    private lazy var homeScreen = HomeScreen()

    override var launchArguments: [LaunchArgument] {
        super.launchArguments +
        [.taLocalMock(port: localServerPort), .useInitiallyLoggedInUser(.hct)]
    }

    func testHomeScreen() {
        mockResponse(using: "mock_file.json", for: ".../endpoint"))
        homeScreen.assertExists(.tableView)
    }
}
```

_____________________


## [Mock server Architecture](#mock-server-architecture)

Components
- <a href="#requestinterceptor">RequestInterceptor</a>: A class conforming to URLProtocol, using method swizzling to replace the underlying URLSession in order to intercept network requests.

- <a href="#localserver">LocalServer</a>：A class based on NWListener, used to receive request-response pairs set by XCTestCase and listen for connections on a specified port on localhost via NWConnection.

- <a href="#clientconnection">ClientConnection</a>：A class based on NWConnection, used to send messages to a specified port on localhost and wait for a response.

Example flow：
![image](https://github.com/user-attachments/assets/9723989b-0311-4af0-babe-7f873dcedb19)

1. XCTestCase setup: Start Local server on localhost, do initial mock.
2. XCTestCase launch app: Send LaunchArguments.
3. App launch: Login, set up the database, etc.
4. App enters Home screen.
5. App fires Syno.SynologyDrive.Files::recent.
6. RequestInterceptor intercepts the network request.
7. RequestInterceptor requests ClientConnection.
8. ClientConnection connects to LocalServer.
9. LocalServer responds to ClientConnection, and ClientConnection passes it to RequestInterceptor.
10. Home screen receives mock data and displays it.
11. XCTestCase assertion process.

## [RequestInterceptor](#requestinterceptor)
### Mockable Domains
The RequestInterceptor allows specifying mockable domains. By default, it is configured to mock requests to specific domains like **api.bee.synology.com** and **\*.direct.quickconnect.to**. However, this can be customized by modifying the mockableDomains set.

### URLSession Configuration
The RequestInterceptor swizzles the **default** and **ephemeral** session configurations to insert itself as the first protocol class. This ensures that all URLSession requests are intercepted by the RequestInterceptor.

### startLoading()

This method is automatically invoked when a URLSession request is intercepted by the `RequestInterceptor`. It is responsible for providing the mock response data to the client for further processing.

#### Functionality

1. Extracts the URL from the intercepted request.
2. Retrieves the mock response data from the `ClientConnectionSender`.
3. Constructs an `HTTPURLResponse` object with a status code of 200 and the headers specified in the mock response.
4. Calls the `client?.urlProtocol(_:didReceive:cacheStoragePolicy:)` method to pass the constructed response to the client.

## [LocalServer](#localserver)

The `LocalServer` class manages the lifecycle of a NWListener, including starting the server, receiving requests, and sending responses.

### Starting the Server

The server is started using the `start()` method. Upon invocation, the method sets up a new connection handler and initiates the listener queue to begin listening for incoming connections.

### Receiving Requests

Incoming requests are received asynchronously using the `receive(connection:)` method. This method is called whenever a new connection is established with a client. It receives messages from clients and processes them accordingly.

### Sending Responses

After receiving a request, the server processes it and generates a response. The response is sent back to the client using the connection's `send(content:completion:)` method. This method takes the response data as input and sends it back to the client. 

### Usage

1. Initialize an instance of `LocalServer` with the desired port number.
2. Start the server using the `start()` method.
3. Implement the logic for receiving requests and generating responses inside the `receive(connection:)` method.
4. Send responses back to clients using the connection's `send(content:completion:)` method.

## [ClientConnection](#clientconnection)

The `ClientConnection` class manages the communication between a client and a server over UDP, including establishing the connection, sending requests, and receiving responses.

### Establishing the Connection

The connection is established when an instance of `ClientConnection` is initialized. The `init(port:identifier:)` method sets up the network connection using NWConnection and starts receiving messages asynchronously.

### Sending Requests

Requests are sent using the `enqueue(request:completionHandler:)` method. This method adds the request to the `itemsToSend` array and initiates sending the next message in the queue by invoking the `sendNext()` method.

### Receiving Responses

Responses are received asynchronously using the `receive(connection:)` method. This method is called whenever a new message is received from the server. It processes the received data and handles any errors that occur during message reception.

### Usage

1. Initialize an instance of `ClientConnection` with the desired port number and identifier.
2. Enqueue requests using the `enqueue(request:completionHandler:)` method.
3. Implement logic to process incoming responses inside the `receive(connection:)` method.
4. Handle successful or failed response processing as needed.
