import GCDWebServers

public class SiteServer {
    private lazy var server = GCDWebServer()!
    let directoryPath: String
    let indexFilename: String
    
    public init(directoryPath: String, indexFilename: String = "index.html") {
        self.directoryPath = directoryPath
        self.indexFilename = indexFilename
        
        // log only warnings, errors and exceptions
        GCDWebServer.setLogLevel(3)
        
        server.addGETHandler(forBasePath: "/", directoryPath: directoryPath, indexFilename: indexFilename , cacheAge: 0, allowRangeRequests: true)
    }
    
    deinit {
        server.stop()
    }
    
    open func run() throws {
        try server.run(options: [:])
    }
    
    open func start() throws -> (URL, UInt) {
        try server.start(options: [:])
        return (server.serverURL!, server.port)
    }
}
