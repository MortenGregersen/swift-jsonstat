import Foundation

public enum JSONStat: Codable {
    case v1(JSONStatV1)
    case v2(JSONStatV2)

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
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
            public var links: [String: Link]?
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
        public var categories: [String: Category]
        public var label: String
        public var responseClass: ResponseClass?
        public var href: URL?
        public var links: [String: Link]?
        public var notes: [String]?

        private enum CodingKeys: String, CodingKey {
            case categories = "category"
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

            private enum CodingKeys: String, CodingKey {
                case indices = "index"
                case labels = "label"
                case children = "child"
            }

            public struct Indices: Codable {
                private var indices: [String: Int]

                public init(from decoder: Decoder) throws {
                    var container = try decoder.unkeyedContainer()
                    if let valuesArray = try? container.decode([String].self) {
                        indices = valuesArray.enumerated().reduce(into: [String: Int]()) { partialResult, item in
                            partialResult[item.element] = item.offset
                        }
                    } else if let indicesDict = try? container.decode([String: Int].self) {
                        indices = indicesDict
                    } else {
                        throw DecodeError.unsupportedIndex
                    }
                }
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

    public struct DictionaryBasedValues<T>: Codable where T: Codable {
        private var onlyNonNilValues: [String: T]

        public init(from decoder: Decoder) throws {
            if var container = try? decoder.unkeyedContainer() {
                var onlyNonNilValues = [String: T]()
                var index = 0
                while container.isAtEnd == false {
                    onlyNonNilValues["\(index)"] = try container.decode(T.self)
                    index += 1
                }
                self.onlyNonNilValues = onlyNonNilValues
            } else if let container = try? decoder.singleValueContainer(),
                      let onlyNonNilValues = try? container.decode([String: T].self) {
                self.onlyNonNilValues = onlyNonNilValues
            } else {
                throw DecodeError.unsupportedValues
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(onlyNonNilValues)
        }

        subscript(index: Int) -> T? {
            get { onlyNonNilValues[String(index)] }
            set { onlyNonNilValues[String(index)] = newValue }
        }
    }

    public typealias Values = DictionaryBasedValues<Double>
    public typealias Status = DictionaryBasedValues<String>
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
        responseClass = try container.decode(JSONStat.ResponseClass.self, forKey: .class)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
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
