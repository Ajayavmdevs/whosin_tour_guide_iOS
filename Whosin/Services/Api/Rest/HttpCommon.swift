import Foundation

/// --------------------------------------
/// - name: HTTP Methods
/// --------------------------------------

let httpRequestMethodGet: String = "GET"
let httpRequestMethodHead: String = "HEAD"
let httpRequestMethodDelete: String = "DELETE"
let httpRequestMethodPost: String = "POST"
let httpRequestMethodPut: String = "PUT"
let httpRequestMethodPatch: String = "PATCH"

/// --------------------------------------
/// - name: HTTP Headers
/// --------------------------------------

let httpRequestContentAll: String = "*/*"
let httpRequestContentApplicationOctetStream: String = "application/octet-stream"
let httpRequestContentBinaryOctetStream: String = "binary/octet-stream"
let httpRequestContentEncodingGzip: String = "application/gzip"
let httpRequestContentFormUrlEncoded: String = "application/x-www-form-urlencoded"
let httpRequestContentImage: String = "image/*"
let httpRequestContentJson: String = "application/json; charset=utf-8"
let httpRequestContentKeepAlive: String = "Keep-Alive"
let httpRequestContentMultipartFormData: String = "multipart/form-data"
let httpRequestContentTextPlain: String = "text/plain"
let httpRequestContentVimeoJson: String = "application/vnd.vimeo.*+json;version=3.4"
let httpRequestContentXml: String = "application/xml; charset=utf-8"
let httpRequestHeaderApplicationType: String = "application-type"
let httpRequestHeaderAuthorization: String = "Authorization"
let httpRequestHeaderConnection: String = "Connection"
let httpRequestHeaderNameAccept: String = "Accept"
let httpRequestHeaderNameContentEncoding: String = "Content-Encoding"
let httpRequestHeaderNameContentLength: String = "Content-Length"
let httpRequestHeaderNameContentType: String = "Content-Type"
let httpRequestHeaderNameAcceptEncoding: String = "Accept-Encoding"
let httpRequestHeaderNameAcceptLanguage: String = "Accept-Language"

/// --------------------------------------
/// - name: HTTP Status Codes
/// --------------------------------------

let httpStatusCodeOk: Int = 200
let httpStatusCodeCreated: Int = 201
let httpStatusCodeAccepted: Int = 202
let httpStatusCodeNoContent: Int = 204
let httpStatusCodeMultipleChoices: Int = 300
let httpStatusCodeUnauthorized: Int = 401
let httpStatusCodeForbidden: Int = 403
let httpStatusCodeNotFound: Int = 404
let httpStatusCodeMethodNotAllowed: Int = 405
let httpStatusCodeConflict: Int = 409
let httpStatusCodeInternalError: Int = 500

/// --------------------------------------
/// - name: Mime Types
/// --------------------------------------

let httpMimeTypeTextPlain: String = "text/plain"
let httpMimeTypeTextHtml: String = "text/html"
let httpMimeTypeImageJpeg: String = "image/jpeg"
let httpMimeTypeImagePng: String = "image/png"
let httpMimeTypeAudioMpeg: String = "audio/mpeg"
let httpMimeTypeAudioOgg: String = "audio/ogg"

/// --------------------------------------
/// - name: Scheme
/// --------------------------------------

let httpScheme: String = "http"
let httpSslScheme: String = "https"
