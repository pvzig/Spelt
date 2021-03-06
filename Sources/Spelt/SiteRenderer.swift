public struct SiteRenderer {
    public let site: Site
    
    public init(site: Site) {
        self.site = site
    }
    
    public func render() throws {
        try BuildDateRenderer(site: site).render()
        try CollectionRenderer(site: site).render()
        try PermalinkRenderer(site: site).render()
        try PaginationRenderer(site: site).render()
        try ExcerptRenderer(site: site).render()
        try TemplateRenderer(site: site, type: .inPlace).render()
        
        try convert()
        
        try TemplateRenderer(site: site, type: .usingTemplate).render()
    }
    
    private func convert() throws {
        let converters: [Converter] = [MarkdownConverter(), SassConverter(site: site)]
        for case let file as FileWithMetadata in site.files {
            let matchingConverters = converters.filter({ $0.matches(file.path.pathExtension) })
            file.contents = try matchingConverters.reduce(file.contents) { contents, converter in
                return try converter.convert(contents)
            }
            
            if let outputPathExtension = matchingConverters.last?.outputPathExtension {
                file.destinationPath = file.destinationPath?.stringByReplacingPathExtension(withExtension: outputPathExtension)
            }
        }
    }
}

extension SiteRenderer {
    public struct RenderError: Error {
        public let filePath: String
        public let lineNumber: Int?
        public let underlyingError: Error
        
        init(filePath: String, lineNumber: Int? = nil, underlyingError: Error) {
            self.filePath = filePath
            self.lineNumber = lineNumber
            self.underlyingError = underlyingError
        }
    }
}

protocol Renderer {
    var site: Site { get }
    
    func render() throws
}

protocol Converter {
    var outputPathExtension: String { get }
    
    func matches(_ pathExtension: String) -> Bool
    func convert(_ content: String) throws -> String
}

