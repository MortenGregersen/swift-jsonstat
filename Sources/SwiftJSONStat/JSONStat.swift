import Foundation

public enum JSONStat: Codable {
    case v1(JSONStatV1)
    case v2(JSONStatV2)

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let isoDateFormatter = ISO8601DateFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = isoDateFormatter.date(from: dateString) {
                return date
            } else if let date = dateFormatter.date(from: dateString) {
                return date
            }
            throw DecodeError.unupportedUpdatedFormat(dateString: dateString)
        }
        return decoder
    }()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONStatV2.CodingKeys.self)
        if let version = try container.decodeIfPresent(String.self, forKey: JSONStatV2.CodingKeys.version) {
            guard version.hasPrefix("2.") else { throw DecodeError.unsupportedVersion }
            self = try .v2(JSONStatV2(from: decoder))
        } else {
            self = try .v1(JSONStatV1(from: decoder))
        }
    }

    public enum DecodeError: Error {
        case unsupportedVersion
        case unsupportedClass
        case unupportedUpdatedFormat(dateString: String)
        case unsupportedValues
        case unsupportedIndex
    }

    public indirect enum ResponseClass: Codable {
        case dataset(Dataset)
        case dimension(JSONStat.Dimension)
        case collection([String: Link])

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: JSONStatV2.CodingKeys.self)
            let responseClass = try container.decode(String.self, forKey: .class)
            switch responseClass {
            case "dataset": self = try .dataset(Dataset(from: decoder))
            case "dimension": self = try .dimension(JSONStat.Dimension(from: decoder))
            // TODO: implement
            case "collection": self = try .collection(["TODO": Link(from: decoder)])
            default: throw JSONStat.DecodeError.unsupportedClass
            }
        }

        public struct Dataset: Codable {
            public var id: [String]
            public var size: [Int]
            public var roles: JSONStat.Roles?
            public var values: JSONStat.Values
            public var status: JSONStat.Status?
            public var dimensions: [String: JSONStat.Dimension]
            public var updated: Date?
            public var source: String?
            public var href: URL?
            public var links: [String: [Link]]?
            public var notes: [String]?

            private enum CodingKeys: String, CodingKey {
                case id
                case size
                case roles = "role"
                case values = "value"
                case status
                case dimensions = "dimension"
                case updated
                case source
                case href
                case links = "link"
                case notes = "note"
            }
        }
    }

    public struct Roles: Codable {
        var time: [String]?
        var geo: [String]?
        var metric: [String]?
    }

    public enum Link: Codable {
        case nonJSONStat(type: String, href: URL)
        case jsonStat(class: String, href: URL, label: String)
        case dataset(JSONStat.ResponseClass.Dataset)

        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                guard let responseClass = try container.decodeIfPresent(String.self, forKey: .class) else {
                    let type = try container.decode(String.self, forKey: .type)
                    let href = try container.decode(URL.self, forKey: .href)
                    self = .nonJSONStat(type: type, href: href)
                    return
                }
                guard responseClass == "dataset" else {
                    throw DecodingError.dataCorruptedError(forKey: .class, in: container, debugDescription: "Unknown class for link")
                }
                guard container.contains(.value) else {
                    let href = try container.decode(URL.self, forKey: .href)
                    let label = try container.decode(String.self, forKey: .label)
                    self = .jsonStat(class: responseClass, href: href, label: label)
                    return
                }
                self = try .dataset(.init(from: decoder))
            } catch {
                print(error)
                throw error
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .nonJSONStat(let type, let href):
                try container.encode(type, forKey: .type)
                try container.encode(href, forKey: .href)
            case .jsonStat(let responseClass, let href, let label):
                try container.encode(responseClass, forKey: .class)
                try container.encode(href, forKey: .href)
                try container.encode(label, forKey: .label)
            case .dataset(let dataset):
                try dataset.encode(to: encoder)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case `class`
            case type
            case href
            case label
            case value
        }
    }

    public struct Dimension: Codable {
        public var category: Dimension.Category
        public var label: String
        public var responseClass: ResponseClass?
        public var href: URL?
        public var links: [String: [Link]]?
        public var notes: [String]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            category = try container.decode(Dimension.Category.self, forKey: .category)
            label = try container.decode(String.self, forKey: .label)
            responseClass = try container.decodeIfPresent(JSONStat.ResponseClass.self, forKey: .responseClass)
            href = try container.decodeIfPresent(URL.self, forKey: .href)
            links = try container.decodeIfPresent([String: [Link]].self, forKey: .links)
            notes = try container.decodeIfPresent([String].self, forKey: .notes)
        }

        private enum CodingKeys: String, CodingKey {
            case category
            case label
            case responseClass = "class"
            case href
            case links = "link"
            case notes = "note"
        }

        public struct Category: Codable {
            public var indices: Indices?
            public var labels: [String: String]?
            public var children: [String: [String]]?
            public var coordinates: [String: [Double]]?
            public var units: [String: Unit]?
            public var notes: [String: [String]]?

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                indices = try container.decodeIfPresent(Indices.self, forKey: .indices)
                labels = try container.decodeIfPresent([String: String].self, forKey: .labels)
                children = try container.decodeIfPresent([String: [String]].self, forKey: .children)
                coordinates = try container.decodeIfPresent([String: [Double]].self, forKey: .coordinates)
                units = try container.decodeIfPresent([String: Unit].self, forKey: .units)
                notes = try container.decodeIfPresent([String: [String]].self, forKey: .notes)
            }

            private enum CodingKeys: String, CodingKey {
                case indices = "index"
                case labels = "label"
                case children = "child"
                case coordinates
                case units = "unit"
                case notes = "note"
            }

            public struct Unit: Codable {
                // Closed properties
                public var decimals: Int?
                public var label: String?
                public var symbol: String?
                public var position: String?
                // Open properties
                public var base: String?
                public var type: String?
                public var multiplier: Double?
                public var adjustment: String?
            }
        }
    }

    public enum DictionaryBasedValues<ArrayValue, DictValue>: Codable where ArrayValue: Codable, DictValue: Codable {
        case array([ArrayValue?])
        case dictionary([String: DictValue?])

        public init(from decoder: Decoder) throws {
            guard let container = try? decoder.singleValueContainer() else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Values must be an array or dictionary"))
            }
            if let values = try? container.decode([ArrayValue?].self) {
                self = .array(values)
            } else if let dictionary = try? container.decode([String: DictValue?].self) {
                self = .dictionary(dictionary)
            } else {
                throw DecodeError.unsupportedValues
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .array(let values):
                var container = encoder.unkeyedContainer()
                try container.encode(contentsOf: values)
            case .dictionary(let dictionary):
                var container = encoder.singleValueContainer()
                try container.encode(dictionary)
            }
        }
    }

    public typealias Values = DictionaryBasedValues<Double, Double>
    public typealias Indices = DictionaryBasedValues<String, Int>
    public typealias Status = DictionaryBasedValues<String, String>
}

public struct JSONStatV1: Codable {
    public var dataset: Dataset

    public struct Dataset: Codable {
        public var dimensionsInfo: DimensionsInfo
        public var values: JSONStat.Values
        public var status: JSONStat.Status?
        public var updated: Date?
        public var source: String?
        public var notes: [String]?

        private enum CodingKeys: String, CodingKey {
            case dimensionsInfo = "dimension"
            case values = "value"
            case status
            case updated
            case source
            case notes = "note"
        }

        public struct DimensionsInfo: Codable {
            public var id: [String]
            public var size: [Int]
            public var roles: JSONStat.Roles?
            public var dimensions: [String: JSONStat.Dimension]

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
                id = try container.decode([String].self, forKey: CodingKeys.id.dynamicKey)
                size = try container.decode([Int].self, forKey: CodingKeys.size.dynamicKey)
                roles = try container.decodeIfPresent(JSONStat.Roles.self, forKey: CodingKeys.roles.dynamicKey)
                dimensions = try container.allKeys
                    .filter { key in !CodingKeys.allCases.map(\.dynamicKey).contains(where: { $0 == key }) }
                    .reduce(into: [String: JSONStat.Dimension]()) { result, dimensionKey in
                        result[dimensionKey.stringValue] = try container.decode(JSONStat.Dimension.self, forKey: dimensionKey)
                    }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: DynamicCodingKeys.self)
                try container.encode(id, forKey: CodingKeys.id.dynamicKey)
                try container.encode(size, forKey: CodingKeys.size.dynamicKey)
                try container.encodeIfPresent(roles, forKey: CodingKeys.roles.dynamicKey)
                try dimensions.forEach { key, dimension in
                    try container.encode(dimension, forKey: .init(stringValue: key)!)
                }
            }

            private enum CodingKeys: String, CodingKey, CaseIterable {
                case id
                case size
                case roles = "role"

                var dynamicKey: DynamicCodingKeys {
                    .init(stringValue: rawValue)!
                }
            }
        }
    }
}

public struct JSONStatV2: Codable {
    var version: String
    var responseClass: JSONStat.ResponseClass?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        responseClass = try JSONStat.ResponseClass(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try responseClass?.encode(to: encoder)
    }

    fileprivate enum CodingKeys: CodingKey {
        case version
        case `class`
    }
}

private struct DynamicCodingKeys: CodingKey, Equatable {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        nil // We are not using this, so just return nil
    }
}
