import CoreML

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class ASLModelInput : MLFeatureProvider {
    var poses: MLMultiArray
    
    var featureNames: Set<String> { ["poses"] }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "poses" {
            return MLFeatureValue(multiArray: poses)
        }
        return nil
    }
    
    init(poses: MLMultiArray) {
        self.poses = poses
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    convenience init(poses: MLShapedArray<Float>) {
        self.init(poses: MLMultiArray(poses))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class ASLModelOutput : MLFeatureProvider {
    private let provider : MLFeatureProvider
    
    var labelProbabilities: [String : Double] {
        provider.featureValue(for: "labelProbabilities")!.dictionaryValue as! [String : Double]
    }
    
    var label: String {
        provider.featureValue(for: "label")!.stringValue
    }
    
    var featureNames: Set<String> {
        provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }
    
    init(labelProbabilities: [String : Double], label: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: [
            "labelProbabilities" : MLFeatureValue(dictionary: labelProbabilities as [AnyHashable : NSNumber]),
            "label" : MLFeatureValue(string: label)
        ])
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class ASLModel {
    let model: MLModel
    
    class var urlOfModelInThisBundle : URL {
        let resPath = Bundle(for: self).url(forResource: "ASLModel", withExtension:"mlmodel")!
        return try! MLModel.compileModel(at: resPath)
    }
    
    init(model: MLModel) {
        self.model = model
    }
    
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }
    
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }
    
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<ASLModel, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> ASLModel {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }
    
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<ASLModel, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(ASLModel(model: model)))
            }
        }
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> ASLModel {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return ASLModel(model: model)
    }
    
    func prediction(input: ASLModelInput) throws -> ASLModelOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }
    
    func prediction(input: ASLModelInput, options: MLPredictionOptions) throws -> ASLModelOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return ASLModelOutput(features: outFeatures)
    }
    
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: ASLModelInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> ASLModelOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return ASLModelOutput(features: outFeatures)
    }
    
    func prediction(poses: MLMultiArray) throws -> ASLModelOutput {
        let input_ = ASLModelInput(poses: poses)
        return try prediction(input: input_)
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func prediction(poses: MLShapedArray<Float>) throws -> ASLModelOutput {
        let input_ = ASLModelInput(poses: poses)
        return try prediction(input: input_)
    }
    
    func predictions(inputs: [ASLModelInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [ASLModelOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [ASLModelOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  ASLModelOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
