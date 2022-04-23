import Foundation

struct RootClass : Decodable {
    
    let code : Int?
    let message : String?
    let object : Auth?
    let responseMsg : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case object = "object"
        case responseMsg = "response_msg"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        //data = try values.decodeIfPresent([AnyObject].self, forKey: .data)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        object = try values.decodeIfPresent(Auth.self, forKey: .object)
            //Auth(from: decoder)
        responseMsg = try values.decodeIfPresent(String.self, forKey: .responseMsg)
    }
    
}
