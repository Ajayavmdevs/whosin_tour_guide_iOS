import UIKit
import Alamofire
import StripePaymentSheet

// --------------------------------------
// MARK: Auth EndPoint
// --------------------------------------

private let kAppleSigninEndPoint = "user/login/apple"
private let kApproveLoginRequest = "user/approve/login/request"
private let kFacebookSigninEndPoint = "user/login/facebook"
private let kGuestLoginEndPoint = "user/login/guest"
private let kGetAuthPendingRequest = "user/auth/request"
private let kGetTokenEndPoint = "user/get-token"
private let kGoogleSigninEndPoint = "user/login/google"
private let kLinkedEmailPhoneEndPoint = "user/user/link/email-phone"
private let kLoginNewEndPoint = "user/tour-guide/signup"
private let kLogoutEndpoint = "user/logout"
private let kOtpSendEndPoint = "user/send/otp"
private let kPhoneSigninEndPoint = "user/login"
private let kRegisterFCMEndpoint = "user/fcm/token"
private let kUserAuthEmailRequest = "user/authenticate/email"
private let kUserByIdsEndPoint = "user/ids"
private let kUserDeleteAccountEndPoint = "user/delete/account"
private let kUserUpdateOtpEndPoint = "user/verify/otp/update"
private let kUserVerifyOtpEndPoint = "user/verify/otp"
private let kVerifyOtpEndPoint = "user/verify"

// --------------------------------------
// MARK: Activities EndPoint
// --------------------------------------

private let kActivityBannerListEndPoint = "activity/banner/list"
private let kActivityDateEndPoint = "activity/dates"
private let kActivityDetailEndPoint = "activity/detail"
private let kActivityListEndPoint = "activity/list"
private let kActivitySlotsEndPoint = "activity/slots"

// --------------------------------------
// MARK: BlockList EndPoint
// --------------------------------------

private let kUserUnBlockEndPoint = "user/block/remove"
private let kUsersBlockListEndPoint = "user/block/list"

// --------------------------------------
// MARK: Bucket EndPoint
// --------------------------------------

private let kAddImageinGalaryEndPoint = "bucket/gallery/add"
private let kBucketChangeOwnerEndPoint = "bucket/change/owner"
private let kBucketDealsEndPoint = "homeblock/deal/list/forBucket"
private let kBucketDetailEndPoint = "bucket/"
private let kBucketExitEndPoint = "bucket/exit"
private let kBucketListEndPoint = "bucket/list"
private let kCreateBucketEndPoint = "bucket/create"
private let kMyBucketListEndPoint = "bucket/my-bucket-list"
private let kRemoveImageFromGalaryEndPoint = "bucket/gallery/delete"
private let kRemoveShareBucketEndPoint = "bucket/share/remove"
private let kShareBucketAddEndPoint = "bucket/share/add"
private let kUpdateBucketEndPoint = "bucket/update"
private let kUpdateItemBucketEndPoint = "bucket/item/addRemove"
private let kUpdateShareBucketAddEndPoint = "bucket/share/update"

// --------------------------------------
// MARK: Category EndPoint
// --------------------------------------

public let kCategoryDetailEndPoint = "venue/category/detail"

// --------------------------------------
// MARK: Chat EndPoint
// --------------------------------------

private let kChatDeleteEndPoint = "chat/delete"
private let kChatEventEndPoint = "event/chat/list"
private let kChatFriendListEndPoint = "chat/friend/list"
private let kChatMessagesEndPoint = "chat/messages"
private let kChatUploadFileEndPoint = "chat/upload"
private let kCreateChatWithFriendEndPoint = "chat/friend/create"
private let kUnReceivedChatMessagesEndPoint = "chat/messages/unreceived"

// --------------------------------------
// MARK: Claim History EndPoint
// --------------------------------------

private let kBruunchBySpecialOffer = "venue/offer/brunch-by-special-offer"
private let kClaimBrunchListEndPoint = "venue/offer/brunch-list"
private let kClaimHistoryEndPoint = "venue/special-offer-claim/history"
private let kClaimOfferEndPoint = "venue/special-offer/claim"

// --------------------------------------
// MARK: Common Search EndPoint
// --------------------------------------

private let kSearchEndPoint = "comman/search"
private let kSearchFilterEndPoint = "venue/all-filters"

// --------------------------------------
// MARK: Complementary Profile EndPoint
// --------------------------------------

private let kCMConfirmedEventListEndPoint = "promoter/event/list-user/confirmed"
private let kCMEventHistoryEndPoint = "promoter/event/history-user"
private let kComplementaryChatListEndPoint = "chat/complimentary/contact/list"
private let kComplementaryEventDetailEndPoint = "promoter/event/detail-user"
private let kComplementaryEventListEndPoint = "promoter/event/list-user"
private let kComplementaryProfileEndPoint = "promoter/get-complimentary-profile"
private let kComplementryEventNotificationEndPoint = "promoter/complementary/event-notification"
private let kComplementryPublicEndPoint = "promoter/get-complimentary-profile/"
private let kComplementryUserNotificationEndPoint = "promoter/complementary/user-notification"

// --------------------------------------
// MARK: Contact EndPoint
// --------------------------------------

private let kContactUsEndPoint = "comman/contact-us/add-query"
public let kFollowerListEndPoint = "user/followers/list"
public let kFollowingListEndPoint = "user/following/list"
private let kInboxListEndPoint = "comman/contact-us/query-list"
private let kReplyContactUsEndPoint = "comman/contact-us/query-reply"
private let kUserBlockEndPoint = "user/block/add"
private let kUserFollowEndPoint = "user/follow/add"
private let kUserReportEndPoint = "user/report/add"
private let kWhoIsInGetContactsEndPoint = "user/contact-sync"

// --------------------------------------
// MARK: Deals EndPoint
// --------------------------------------

private let kDealsAndPackagesEndPoint = "homeblock/deal-package/list-user"
private let kDealsDetailEndPoint = "homeblock/deal-package/detail"

// --------------------------------------
// MARK: Event EndPoint
// --------------------------------------

private let kEventDetailEndPoint = "event/detail"
private let kEventGuestListEndPoint = "event/guest/list"
private let kEventHistoryEndPoint = "event/my-event-history"
private let kEventInviteEndPoint = "event/invite/guest"
private let kEventInviteStatusEndPoint = "event/invite/status"
private let kEventNearByEndPoint = "event/nearby"
private let kEventOrganizationEndPoint = "event/org/detail"
private let kEventOrganizationFollowEndPoint = "event/org/follow"
private let kEventUpcomingEndPoint = "event/my-upcoming-event"
private let kHighlightsEndPoint = "event/highlight/add"
private let kHighlightsListEndPoint = "event/highlight/list"
private let kNearByInviteCreateEndPoint = "nearby/invite/create"

// --------------------------------------
// MARK: Explore EndPoint
// --------------------------------------

private let kExploreEndPoint = "comman/explore"
private let kNewExploreEndpoint = "homeblock/explore-block/get-blocks"

// --------------------------------------
// MARK: Feed EndPoint
// --------------------------------------
private let kAddRecommendedEndPoint = "user/recommendation/add"
public let kFeedListEndPoint = "user/feed/my"
public let kFriendFeedListEndPoint = "user/feed/friend"

// --------------------------------------
// MARK: Home EndPoint
// --------------------------------------
private let kFavouriteAddRemoveEndPoint = "homeblock/favorite/add-update"
private let kHomeBlockEndPoint = "homeblock/get-blocks"
private let kRecommendationEndPoint = "user/recommendation/add"

// --------------------------------------
// MARK: Invitations EndPoint
// --------------------------------------

private let kOutingDetailEndPoint = "outing/"
private let kDeleteInvitaionEndPoint = "outing/delete-invite"
private let kInOutStatusEndPoint = "outing/update/invite-status"
private let kOutingEndPoint = "outing/create"
private let kOutingListEndPoint = "outing/my-outing-list"
private let kOutingOwnerChangeEndPoint = "outing/owner/change"
private let kOutingOwnerDeleteEndPoint = "outing/owner/delete"
private let kUpdateOutingEndPoint = "outing/update"


// --------------------------------------
// MARK: Location EndPoint
// --------------------------------------

private let kUserLocationEndPoint = "user/location/update"

// --------------------------------------
// MARK: Notifications and Promotions EndPoint
// --------------------------------------

private let kAdLogCreateEndPoint = "ad/log/create"
private let kAdsListEndPoint = "ad/list"
private let kInAppListEndPoint = "user/notification/in-app/list/user"
private let kInAppReadUpdateEndPoint = "user/notification/in-app/read"
private let kNoficationUnReadEndPoint = "user/notification/unread-count"
private let kNotificationDeleteEndPoint = "user/notification/user"
private let kNotificationListEndPoint = "user/notification/list"
private let kNotificationReadEndPoint = "user/notification/read"
private let kPromotionalBannerEndPoint = "homeblock/promotional-banner/list"

// --------------------------------------
// MARK: Profile EndPoint
// --------------------------------------

private let kAddMystoryEndPoint = "homeblock/story/create-by-user"
private let kFollowRequestList = "user/follow-request/list"
private let kGetPreferencesEndPoint = "user/preference/get"
private let kPasswordLogin = "auth/verify/password"
private let kPrefrencesEndPoint = "user/preference/update"
private let kProfileStatusEndPoint = "user/update-settings"
private let kReadContactUsEndPoint = "comman/contact-us/reply/mark-as-read"
private let kRequestAcceptRejectEndPoint = "user/follow-request/action"
private let kSuggestedUsersEndPoint = "user/suggested-users"
private let kUpdateProfile = "user/update"
private let kUploadProfileImageEndpoint = "comman/img/upload"
private let kUserProfileEndPoint = "user/profile"

// --------------------------------------
// MARK: Plus One EndPoint
// --------------------------------------

private let kEventListPlusOneEndPoint = "promoter/event/plus-one/list"
private let kEventPlusOneInviteEndPoint = "promoter/event/plus-one/invite"
private let kPaidPassByEventId = "promoter/paid-pass-by-eventId"
private let kPaidPassEndPoint = "promoter/paid-pass/list"
private let kPlusOneEventDetail = "promoter/event/detail/plus-one"
private let kPlusOneInOutEndPoint = "promoter/event/plus-one/invite-status"
private let kPlusOneInviteEndPoint = "promoter/plus-one/invite/user"
private let kPlusOneInviteSearchEndPoint = "user/search/all"
private let kPlusOneleaveEndPoint = "promoter/plus-one/group/leave"
private let kPlusOneMyGroupListEndPoint = "promoter/plus-one/my-group"
private let kPlusOneRequestAccept = "promoter/event/plus-one/invite-status-promoter"
private let kPlusOneUserListEndPount = "promoter/plus-one/group/list-user"
private let kRemovePlusOneMemberEndPoint = "promoter/plus-one/invite/user/remove"
private let kUpdatePlusOneStatusEndPoint = "promoter/plus-one/invite/user/update-status"

// --------------------------------------
// MARK: Promoter Profile EndPoint
// --------------------------------------

private let kAddCircleMemberEndPoint = "promoter/circle/add-member"
private let kAddToRingEndPoint = "promoter/add-to-ring"
private let kApplyPromoterEndPoint = "promoter/request/create"
private let kApplyRingPromoterEndPoint = "promoter/ring/request/create"
private let kCircleDetailEndPoint = "promoter/circle-detail"
private let kCirclesByUserIdEndPoint = "promoter/circles/by-userId"
private let kCreateCircleEndPoint = "promoter/create/circle"
private let kCreateEventEndPoint = "promoter/event/create"
private let kCustomCategoryEndPoint = "promoter/event/get-custom-category"
private let kDeleteCicleEndPoint = "promoter/delete/circle"
private let kEventHideShowEndPoint = "promoter/event/hide-show"
private let kGetMyRingMemberEndPoint = "promoter/my-ring-members"
private let kGetMyVeneusEndPoint = "promoter/get-my-venues"
private let kGetVenuesMediaEndPoint = "venue/get-venue-media-urls"
private let kInEventsListEndPoint = "promoter/user/in/events"
private let kInviteStatusRejectEndPoint = "promoter/update/invite-status-promoter"
private let kJoinMyRingRequestEndPoint = "promoter/join-my-ring"
private let kLeaveMyRingRequestEndPoint = "promoter/leave-ring/complimentary-user"
private let kMemberBanEndPoint = "promoter/member/ban"
private let kMyEventCancelEndPoint = "promoter/event/cancel"
private let kMyEventsEndPoints = "promoter/my-invitation-list"
private let kPromoterChatListEndPoint = "chat/promoter/contact/list"
private let kPromoterCloseEventSpotEndPoint = "promoter/event/close-spot"
private let kPromoterEditEventEndPoint = "promoter/event/update"
private let kPromoterEventCompleteEndPoint = "promoter/event/complete"
private let kPromoterEventDeleteEndPoint = "promoter/event/delete"
private let kPromoterEventDetailEndPoint = "promoter/event/detail"
private let kPromoterEventInviteListEndPoint = "promoter/event/invite/list"
private let kPromoterEventInviteListNewEndPoint = "promoter/event/invite/list-new"
private let kPromoterEventInviteUsersEndPoint = "promoter/event/invited-users"
private let kPromoterEventNotificationEndPoint = "promoter/event-notification"
private let kPromoterProfielEndPoint = "promoter/get-profile"
private let kPromoterUpdateProfileEndPoint = "promoter/update"
private let kPromoterUpdateRingEndPoint = "promoter/ring/update"
private let kPromoterUpdateStatusEndPoint = "promoter/ring/update-member-status"
private let kPromoterUserNotificationEndPoint = "promoter/user-notification"
private let kRemoveFromCircleEndPoint = "promoter/circle/remove-member"
private let kRemoveFromRingEndPoint = "promoter/ring/remove-member"
private let kToggleWishlistEndPoint = "promoter/toggle-wishlist"
private let kUpdateCircleEndPoint = "promoter/update/circle"
private let kUpdateInviteStatusEndPoint = "promoter/update/invite-status"
private let kUpdateRingUserStatusEndPoint = "promoter/ring/update-prmoter-status"
private let kUseraddInCirclesEndPoint = "promoter/add-member-to-circles"
private let kVenueRemoveEndPoint = "promoter/venue/remove"
private let kGetPromoterChatMessageEndPoint = "chat/promoter/contact/message"
private let kPromoterEventhistoryEndPoint = "promoter/my-event-history"
private let kMyEventEndPoint = "promoter/my-event-list"
private let kMyEventEndPointNew = "promoter/my-event-list-new"
private let kRingRequestByPromoter = "promoter/ring/request/list-by-promoterId"
private let kRingRequestVerify = "promoter/ring/request/verify"


// --------------------------------------
// MARK: Ratings and Reviews EndPoint
// --------------------------------------

private let kRatingListEndPoint = "review/list"
private let kRatingReviewDeleteEndPoint = "review/delete"
private let kRatingReviewReplyAddUpdateEndPoint = "review/reply/addUpdate"
private let kRatingReviewReplyDeleteEndPoint = "review/reply/delete"
private let kRatingReviewSummaryEndPoint = "review/summary"
private let kRatingSubmitEndPoint = "review/addUpdate"
private let kUserReviewListEndPoint = "review/my-review/list"

// --------------------------------------
// MARK: Report EndPoint
// --------------------------------------

private let KUserAddReportEndPoint = "user/report-add"
private let kUserRemoveReportEndPoint = "user/report-remove"
private let kUserReportDetailEndPoint = "user/report-detail"
private let kUserReportedUserListEndPoint = "user/report-list/user"

// --------------------------------------
// MARK: Search EndPoint
// --------------------------------------
private let kActivitySearchEndPoint = "activity/search"
private let kEventSearchEndPoint = "event/search"
private let kOfferSearchEndPoint = "venue/offer/search"
private let kRaynaSearchEndPoint = "rayna/search"
private let kSearchRecommendedEndPoint = "homeblock/search/get-blocks"
private let kUserSearchEndPoint = "user/search"
private let kVenueRecommendedEndPoint = "venue/recommended"
private let kVenueSearchEndPoint = "venue/search"
private let kSearchSuggestionEndPoint = "rayna/search/suggestions"

// --------------------------------------
// MARK: Setting EndPoint
// --------------------------------------

private let kGetSetting = "comman/setting/get"
private let kGetUpdatesEndPoint = "comman/updates/get"
private let kReadUpdatesEndPoint = "comman/updates/read"

// --------------------------------------
// MARK: Shoutout EndPoint
// --------------------------------------

private let kAddShoutoutEndPoint = "user/shoutout/add"
private let kShoutoutListEndPoint = "user/shoutout/list"
private let kVenueCheckInEndPoint = "venue/check-in"
private let kVisibilityEndPoint = "user/change/visibility"

// --------------------------------------
// MARK: SubAdmin EndPoint
// --------------------------------------

private let kSubAdminsList = "user/promoter/sub-admin/list"
private let kSubminUpdateStatus = "promoter/update/subadmin/status"

// --------------------------------------
// MARK: Subscription EndPoint
// --------------------------------------

private let kGiftsListEndPoint = "subscription/gift/list"
private let kMembershipDetail = "subscription/membership/package-detail"
private let kMembershipPurchase = "subscription/membership/purchase"
private let kOrderDeleteEndPoint = "subscription/order/"
private let kOrderListEndPoint = "subscription/order/list"
private let korderHistoryEndPoint = "subscription/order/history"
private let kOfferRedeemEndPoint = "subscription/package-redeem"
private let kSendGiftEndPoint = "subscription/send-gift"
private let kStripePaymentIntentEndPoint = "subscription/stripe/paymentIntent/create"
private let kSubscriptionCustomEndPoint = "subscription/custom/get"
private let kSubscriptionDetailEndPoint = "subscription/active"
private let kValidatePromoCodeEndPoint = "subscription/promocode/validate"

// --------------------------------------
// MARK: Tickets EndPoint
// --------------------------------------

// Rayna Tickets
private let kRaynaPolicyEndPoint = "rayna/tour-policy"
private let kRaynaTicketDetailEndPoint = "rayna/custom/detail-user"
private let kRaynaTicketListEndPoint = "rayna/custom-ticket/list-user"
private let kRaynaTimeAvailibilityEndPoint = "rayna/tour-availability"
private let kRaynaTimeSlotEndPoint = "rayna/tour-timeslot"
private let kRaynaTourBooking = "comman/booking"
private let kRaynaTourOptionDetailByIdEndPoint = "rayna/tour-option-detail-by-tour-id"
private let kRaynaTourOptionEndPoint = "rayna/tour-options"
private let kRaynaticketCancelEndPoint = "rayna/tour-booking-cancel"

// Whosin Tickets
private let kWhosinAvailabilityEndPoint = "rayna/whosin/availability"
private let kWhosinBookingRulesEndPoint = "rayna/whosin/booking-rules"
private let kWhosinBookingCancelEndPoint = "rayna/whosin/tour-booking-cancel"
private let kWhosinticketSlotEndPoint = "whosin-ticket/slots"
private let kWhosinticketRulsEndPoint = "whosin-ticket/booking-rules"
private let kWhosinticketAvailibilityEndPoint = "whosin-ticket/availability"
private let kWhosinticketCancelEndPoint = "whosin-ticket/tour-booking-cancel"
private let kWhosinAddOnAvailabilityEndPoint = "rayna/whosin/addon/availability"

// Juniper Tickets
private let kJuniperAvailabilityEndPoint = "juniper/availability"
private let kJuniperBookingRulesEndPoint = "juniper/booking-rules"
private let kJuniperCheckAvailabilityEndPoint = "juniper/check-availability"

// Featured Tickets
private let kFeaturedTicketEndPoint = "homeblock/cm-profile-tickets"

// Ticket Reviews
private let kCheckReviewRaynaEndPoint = "rayna/check-review"
private let kRaynaUpdateReviewEndPoint = "rayna/update/review-status"

// General Ticket Info
private let kMoreInfoEndPoint = "rayna/more-info"
private let kSessionEndPoint = "user/session-check"

// Whosin Tickets
private let kTravelDeskAvailibilityEndPoint = "traveldesk/tour-availability"
private let kTravelDeskPickupListEndPoint = "traveldesk/pickup-list"
private let kTravelCancellationEndPoint = "comman/booking/cancel"
private let kTravelPolicyEndPoint = "traveldesk/tour-policy"

// octo tikcets
private let kOctoTicketAvailibility = "octo/tour-availability"
private let kOctoTicketPolicy = "octo/tour-policy"

// JP HOTELS
private let kJPHotelAvailibility = "hotel/availability"
private let kJPHotelBookingRulsEndPoint = "hotel/booking-rules"

private let kSugestedTicketList = "rayna/get-ticket-suggestions"


// --------------------------------------
// MARK: Venue EndPoint
// --------------------------------------

private let kFollowEndPoint = "follow/add"
private let kOfferDetailByIdEndPoint = "venue/offer/detail"
private let kOfferListByIdsEndPoint = "venue/offer/list/ids"
private let kPromoCodeApplyEndPoint = "venue/promo-code/apply"
private let kRemoveSuggestedEndPoint = "user/remove-suggestion"
private let kSuggestedVenueEndPoint = "venue/suggested-venues"
private let kVenueDetailEndPoint = "venue/detail"
private let kVenueFollow = "venue/follow/toggle"
private let kVenueFrequencyEndPoint = "promoter/venue/set-frequency-for-cm-visit"
public let kVenueOffersEndPoint = "venue/offer/list"

// --------------------------------------
// MARK: Yacht EndPoint
// --------------------------------------
private let kYachOfferDetailEndPoint = "yacht/offer/detail"
private let kYachTimeSlotsEndPoint = "yacht/offer/package/available-slots"
private let kYachtClubDetailEndPoint = "yacht/club/detail"
private let kYachtDetailEndPoint = "yacht/detail"

// --------------------------------------
// MARK: Ticket Cart EndPoint
// --------------------------------------

private let kAddToCartEndPoint = "subscription/cart/add"
private let kRemoveFromCartEndPoint = "subscription/cart/remove"
private let kRemoveOptionFromCartEndPoint = "subscription/cart/remove-option"
private let kViewCartEndPoint = "subscription/cart/view"
private let kUpdateCartEndPoint = "subscription/cart/update"
private let kCheckoutCartEndPoint = "subscription/cart/checkout"
private let kPromoCodeRemoveEndPoint = "subscription/cart/remove-promo"

private let kApplwWalletEndPoint = "subscription/booking/apple/wallet"
private let kLanguageLocalizeEndPoint = "comman/language-file"


class WhosinServices: BaseApiService {
    
    // --------------------------------------
    // MARK: Overrides
    // --------------------------------------
    
    override class public var headers: [String: String] {
        var baseHeaders = super.headers
        baseHeaders[httpRequestHeaderAuthorization] = APPSESSION.token
        baseHeaders[httpRequestHeaderNameAcceptEncoding] = "gzip, deflate, br"
        baseHeaders[httpRequestHeaderNameAcceptLanguage] = LANGMANAGER.currentLanguage
        return baseHeaders
    }
    
    override class public var customHeaders: [String: String] {
        var baseHeaders = super.headers
        baseHeaders[httpRequestHeaderNameContentType] = httpRequestContentJson
        baseHeaders[httpRequestHeaderNameAccept] = httpRequestContentAll
        baseHeaders[httpRequestHeaderNameAcceptLanguage] = LANGMANAGER.currentLanguage
        baseHeaders[httpRequestHeaderAuthorization] = APPSESSION.token
        baseHeaders[httpRequestHeaderNameAcceptEncoding] = "gzip, deflate, br"
        
        return baseHeaders
    }
    
    override class public var customHeadersForUploadFile: [String: String] {
        var baseHeaders = super.headers
        baseHeaders[httpRequestHeaderNameContentType] = "multipart/form-data; boundary=\(Utils.generateBoundaryString())"
        baseHeaders[httpRequestHeaderAuthorization] = APPSESSION.token
        baseHeaders[httpRequestHeaderNameAcceptLanguage] = LanguageManager.shared.currentLanguage
        baseHeaders[httpRequestHeaderNameAcceptEncoding] = "gzip, deflate, br"
        return baseHeaders
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private class var _service: WhosinServices? {
        return WhosinServices()
    }
    
    // --------------------------------------
    // MARK: Authentication Service
    // --------------------------------------
        
    public class func loginGoogleAuth(params: [String: Any], callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kGoogleSigninEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func loginFacebookAuth(params: [String: Any], callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kFacebookSigninEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func loginGuestAuth(params: [String: Any], callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGuestLoginEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func loginAppleAuth(params: [String: Any], callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kAppleSigninEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func signinwithPhone(params: [String: Any], callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kPhoneSigninEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func userVerify(params: [String: Any] , callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kVerifyOtpEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func updateProfile(params: [String: Any] , callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUpdateProfile)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func registerFCM(token: String, callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRegisterFCMEndpoint)
        let params: [String: Any] = ["token": token, "deviceId" : Utils.getDeviceID(), "platform": "ios", "provider": "firebase"]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func registerPlayer(plyerId: String, callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kRegisterFCMEndpoint)
        let params: [String: Any] = ["token": "", "playerId": plyerId, "deviceId" : Utils.getDeviceID(), "platform": "ios", "provider": "onesignal"]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func uploadProfileImage(image: UIImage, callback: ObjectResult<ContainerModel<ImageModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUploadProfileImageEndpoint)
        let imageName = Utils.dateToString(Date(), format: kFormatDateImageName) + ".jpg"
        Utils.saveFileToLocal(image, fileName: imageName)
        let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(imageName)
        
        var params: [String: Any] = [:]
        params["image"] = fileUrl
        let request = POST_UPLOAD_FILE(url, parameters: params)
        _service?.multipartRequest(request, model: ContainerModel<ImageModel>.self, callback: callback)
    }
    
    public class func uploadProfileImageArray(image: [UIImage], callback: ObjectResult<ContainerModel<ImageModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUploadProfileImageEndpoint)
        var params: [String: Any] = [:]
        var fileUrls: [URL] = []
        var index: Int = 1
        image.forEach { image in
            let imageName = Utils.dateToString(Date(), format: kFormatDateImageName) + "-\(index).jpg"
            Utils.saveFileToLocal(image, fileName: imageName)
            let fileUrl = Utils.getDocumentsUrl().appendingPathComponent(imageName)
            fileUrls.append(fileUrl)
            params["image\(index)"] = fileUrl
            index += 1
        }
        let request = POST_UPLOAD_FILE(url, parameters: params)
        _service?.multipartRequest(request, model: ContainerModel<ImageModel>.self, callback: callback)
    }
    
    public class func getUserProfile(userId: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUserProfileEndPoint)
        let request = GET(url + "/\(userId)")
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }

    public class func userSendOtp(type: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["type" : type]
        let url = URLMANAGER.baseUrlV2(endPoint: kOtpSendEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func userVerifyOtp(type: String, otp: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let params: [String: Any] = ["type" : type, "otp": otp, "userId": APPSESSION.userDetail?.id ?? kEmptyString]
        let url = URLMANAGER.baseUrl(endPoint: kUserVerifyOtpEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func logout(callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let params: [String: Any] = ["deviceId": Utils.getDeviceID()]
        let url = URLMANAGER.baseUrlV2(endPoint: kLogoutEndpoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func linkEmailPhone(type: String,phone: String,email: String, UserId: String, countryCode: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        var params: [String: Any] = ["type":type, "userId": UserId]
        if Utils.stringIsNullOrEmpty(email) && type == "phone" {
            params["phone"] = phone
            params["country_code"] = countryCode
        } else {
            params["email"] = email
        }
        let url = URLMANAGER.baseUrlV2(endPoint: kLinkedEmailPhoneEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }


    public class func userUpdateOtp(type: String, otp: String,email: String, phone: String, countryCode: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let params: [String: Any] = ["otp": otp, "type": type,"email": email, "phone" : phone, "country_code": countryCode, "userId": APPSESSION.userDetail?.id ?? kEmptyString]
        let url = URLMANAGER.baseUrl(endPoint: kUserUpdateOtpEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func userDeleteAccount(type: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["type": type]
        let url = URLMANAGER.baseUrlV2(endPoint: kUserDeleteAccountEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func approveLoginRequest(status: String, reqId: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let params: [String: Any] = ["status": status, "reqId":reqId]
        let url = URLMANAGER.baseUrlV2(endPoint: kApproveLoginRequest)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func userEmailTwoFactorAuth(params: [String: Any] , callback: ObjectResult<ContainerModel<LoginApprovalModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUserAuthEmailRequest)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<LoginApprovalModel>.self, callback: callback)
    }
    
    public class func getLoginRequest(params: [String: Any] , callback: ObjectResult<ContainerModel<LoginApprovalModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetAuthPendingRequest)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<LoginApprovalModel>.self, callback: callback)
    }
    
    public class func getToken(callback: ObjectResult<ContainerStringModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetTokenEndPoint)
        let params: [String: Any] = ["deviceId" : Utils.getDeviceID()]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerStringModel.self, callback: callback)
    }
    
    public class func newLoginUser(params: [String: Any], callback: ObjectResult<ContainerModel<UserModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kLoginNewEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserModel>.self, callback: callback)
    }
    
    public class func sessionCheck(callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kSessionEndPoint)
        let request = POST(url,parameters: nil)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Promoter Profile Service
    // --------------------------------------
    
    public class func applyRingPromoter(params: [String: Any], callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kApplyRingPromoterEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func applyPromoter(params: [String: Any], callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kApplyPromoterEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func updatePromoter(params: [String: Any], callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromoterUpdateProfileEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func updateRingPromoter(params: [String: Any], callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromoterUpdateRingEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func createCircle(params: [String:Any],callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kCreateCircleEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func updateCircle(params: [String:Any],callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUpdateCircleEndPoint)
        let request = PUT(url, params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func getMyVenuesList(callback: ObjectResult<ContainerListModel<VenueDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetMyVeneusEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<VenueDetailModel>.self, callback: callback)
    }
            
    public class func getMyRingMemberList(callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetMyRingMemberEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func getCircleDetail(id: String,callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let param: [String: Any] = ["id" : id]
        let url = URLMANAGER.baseUrl(endPoint: kCircleDetailEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func createInvite(params: [String: Any],callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kCreateEventEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func _updateMyevent(params: [String: Any],callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromoterEditEventEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func addToRingUser(id: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["memberId" : id]
        let url = URLMANAGER.baseUrl(endPoint: kAddToRingEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func cancelMyEvent(id: String, deleteAll: Bool = false,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["eventId" : id, "deleteAllEvent": deleteAll]
        let url = URLMANAGER.baseUrl(endPoint: kMyEventCancelEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func removeVenue(id: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let param: [String: Any] = ["venueIds" : [id]]
        let url = URLMANAGER.baseUrl(endPoint: kVenueRemoveEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func removeFromRing(id: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["memberId" : id]
        let url = URLMANAGER.baseUrl(endPoint: kRemoveFromRingEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func removeFromCircle(id: String, memberIds:[String], callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let param: [String: Any] = ["memberIds" : memberIds, "id": id]
        let url = URLMANAGER.baseUrl(endPoint: kRemoveFromCircleEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func addToCircle(id: String, memberIds: [String], callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["memberIds" : memberIds, "id": id]
        let url = URLMANAGER.baseUrl(endPoint: kAddCircleMemberEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func deleteCircle(id: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let param: [String: Any] = ["id": id]
        let url = URLMANAGER.baseUrl(endPoint: kDeleteCicleEndPoint)
        let request = DELETE(url, param)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func promoterStatus(params: [String:Any], isPromoter: Bool = false,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: isPromoter ? kPromoterUpdateStatusEndPoint : kUpdateRingUserStatusEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    
    public class func promoterUserNotification(page: Int = 1, callback: ObjectResult<ContainerModel<NotificationListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromoterUserNotificationEndPoint)
        let request = POST(url, parameters: ["page": page, "limit": 20])
        _ = _service?.request(request, model: ContainerModel<NotificationListModel>.self, callback: callback)
    }
    
    public class func promoterEventNotification(page: Int = 1, callback: ObjectResult<ContainerModel<NotificationListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromoterEventNotificationEndPoint)
        let request = POST(url, parameters: ["page": page, "limit": 20])
        _ = _service?.request(request, model: ContainerModel<NotificationListModel>.self, callback: callback)
    }
    
    public class func joinMyRingRequest(id: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["promoterId" : id]
        let url = URLMANAGER.baseUrl(endPoint: kJoinMyRingRequestEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func leaveMyRingRequest(id: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["promoterId" : id]
        let url = URLMANAGER.baseUrl(endPoint: kLeaveMyRingRequestEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    
    public class func updateInviteStatus(inviteId: String,inviteStatus: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["inviteId" : inviteId, "inviteStatus" : inviteStatus]
        let url = URLMANAGER.baseUrl(endPoint: kUpdateInviteStatusEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func toggleWishlist(type: String,typeId: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["type" : type, "typeId":typeId]
        let url = URLMANAGER.baseUrl(endPoint: kToggleWishlistEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func memberBan(banId: String,type: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["banId" : banId, "type":type]
        let url = URLMANAGER.baseUrl(endPoint: kMemberBanEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func promoterEventInviteStatus(inviteId: String,inviteStatus: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["inviteId" : inviteId, "promoterStatus" : inviteStatus]
        let url = URLMANAGER.baseUrl(endPoint: kInviteStatusRejectEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func promoterEventDelete(id: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["id" : id]
        let url = URLMANAGER.baseUrl(endPoint: kPromoterEventDeleteEndPoint)
        let request = DELETE(url, param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func promoterEventComplete(id: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["eventId" : id]
        let url = URLMANAGER.baseUrl(endPoint: kPromoterEventCompleteEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
                
    // --------------------------------------
    // MARK: Sub-Admin EndPoint
    // --------------------------------------

    public class func requestRingByPromoter(id: String, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let param: [String: Any] = ["promoterId": id]
        let url = URLMANAGER.baseUrl(endPoint: kRingRequestByPromoter)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }

    public class func requestVerifyRingRequest(id: String,status: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["requestId" : id, "status" : status]
        let url = URLMANAGER.baseUrl(endPoint: kRingRequestVerify)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func mySubAdmins(callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kSubAdminsList)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func updateSubAdminStatus(id: String,status: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["requestId" : id, "status" : status]
        let url = URLMANAGER.baseUrl(endPoint: kSubminUpdateStatus)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Complimentary Profile Service
    // --------------------------------------
                
    public class func complementaryUserNotification(callback: ObjectResult<ContainerModel<NotificationListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kComplementryUserNotificationEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<NotificationListModel>.self, callback: callback)
    }
    
    public class func complementaryEventNotification(callback: ObjectResult<ContainerModel<NotificationListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kComplementryEventNotificationEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<NotificationListModel>.self, callback: callback)
    }
    
    
    // --------------------------------------
    // MARK: Home Service
    // --------------------------------------
    
    public class func getHome(shouldRefresh: Bool = false,callback: ObjectResult<ContainerModel<HomeModel>>? = nil) {
        let params: [String: Any] = ["Latitude":APPSETTING.latitude, "Longitude": APPSETTING.longitude]
        let url = URLMANAGER.baseUrlV2(endPoint: kHomeBlockEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<HomeModel>.self,shouldRefresh: shouldRefresh, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Search Service
    // --------------------------------------

    public class func venueSearch(search: String, page: Int, callback: ObjectResult<ContainerListModel<VenueDetailModel>>? = nil) {
        let params: [String: Any] = ["search" : search, "page": page, "limit": 20]
        let url = URLMANAGER.baseUrlV2(endPoint: kVenueSearchEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerListModel<VenueDetailModel>.self, callback: callback)
    }

    public class func userSearch(search: String, page: Int, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let params: [String: Any] = ["search" : search, "page": page, "limit": 20]
        let url = URLMANAGER.baseUrl(endPoint: kUserSearchEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func searchRecommended(callback: ObjectResult<ContainerModel<HomeModel>>? = nil) {
        let _: [String: Any] = ["Latitude":  APPSETTING.latitude,
                                     "Longitude": APPSETTING.longitude]
        let url = URLMANAGER.baseUrlV2(endPoint: kSearchRecommendedEndPoint)
        let request = POST(url,parameters: nil)
        _ = _service?.request(request, model: ContainerModel<HomeModel>.self, shouldRefresh: false, callback: callback)
    }

    
    // --------------------------------------
    // MARK: Venue Service
    // --------------------------------------
    
    public class func getVenueDetail(venueId: String, callback: ObjectResult<ContainerModel<VenueDetailModel>>? = nil) {
        let params: [String: Any] = ["venueId" : venueId,
                                     "lat":  APPSETTING.latitude,
                                     "long": APPSETTING.longitude]
        let url = URLMANAGER.baseUrlV2(endPoint: kVenueDetailEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<VenueDetailModel>.self, callback: callback)
    }
    

    public class func venueFollows(id: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["followId" : id]
        let url = URLMANAGER.baseUrlV2(endPoint: kVenueFollow)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }

    public class func venueCheckIn(venueId: String, user: UserDetailModel, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        
        let params: [String: Any] = ["venueId": venueId, "user": ["id": user.id, "first_name":user.firstName, "last_name":user.lastName, "image": user.image]]
        let url = URLMANAGER.baseUrlV2(endPoint: kVenueCheckInEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    
    public class func getSuggestedVenueDetail(venueId: String, callback: ObjectResult<ContainerListModel<VenueDetailModel>>? = nil) {
        var params: [String: Any] = ["lat":  APPSETTING.latitude,
                                     "long": APPSETTING.longitude]
        if !Utils.stringIsNullOrEmpty(venueId) {
            params["id"] = venueId
        }
        let url = URLMANAGER.baseUrlV2(endPoint: kSuggestedVenueEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerListModel<VenueDetailModel>.self, callback: callback)
    }
    
    public class func setFrequencyForCmVisit(venueId: String, days: Int, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["venueId": venueId, "days": days]
        let url = URLMANAGER.baseUrl(endPoint: kVenueFrequencyEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func applyPromoCode(promoCode: String, metadata: [[String: Any]], callback: ObjectResult<ContainerModel<PromoBaseModel>>? = nil) {
        let params: [String: Any] = ["promoCode": promoCode, "metadata": metadata]
        let url = URLMANAGER.baseUrlV2(endPoint: kPromoCodeApplyEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<PromoBaseModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Category Service
    // --------------------------------------

    public class func getCategoryDetail(categoryId: String, callback: ObjectResult<ContainerModel<CategoryDetailModel>>? = nil) {
        let params: [String: Any] = ["categoryId" : categoryId]
        let url = URLMANAGER.baseUrl(endPoint: kCategoryDetailEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<CategoryDetailModel>.self, shouldRefresh: false, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Event Organization Service
    // --------------------------------------
        
    public class func updateEventInviteStatus(eventId: String, inviteStatus: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String:Any] = ["eventId": eventId, "inviteStatus": inviteStatus]
        let url = URLMANAGER.baseUrl(endPoint: kEventInviteStatusEndPoint)
        let request = PUT(url, params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func deleteInviteStatus(inviteId: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String:Any] = ["inviteId": inviteId]
        let url = URLMANAGER.baseUrl(endPoint: kDeleteInvitaionEndPoint)
        let request = DELETE(url, params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func inviteEventUser(eventId: String, userIds: [String], extraGuest:Int, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["eventId" : eventId,"userIds": userIds,"extraGuest":extraGuest]
        let url = URLMANAGER.baseUrl(endPoint: kEventInviteEndPoint)
        let request = POST(url, parameters:params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
        
    public class func addEventHighlights(eventId: String, msg: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["eventId" : eventId, "msg": msg]
        let url = URLMANAGER.baseUrl(endPoint: kHighlightsEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: NearBy Service
    // --------------------------------------

    public class func createNearByInvite(venueId: String, userIds: [String], time: Int, title: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["venueId": venueId, "userIds": userIds, "time": time, "title": title]
        let url = URLMANAGER.baseUrl(endPoint: kNearByInviteCreateEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    // --------------------------------------
    // MARK: User Service
    // --------------------------------------
    
    public class func getUserByIds(userIds: [String], callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil){
        let params: [String: Any] = ["userIds": userIds, "type":"chat"]
        let url = URLMANAGER.baseUrlV2(endPoint: kUserByIdsEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func saveUserPrefrences(params: [String: Any], callback: ObjectResult<ContainerModel<PrefrencesModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPrefrencesEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<PrefrencesModel>.self, callback: callback)
    }
    
    public class func getUserPreferences(callback: ObjectResult<ContainerModel<PrefrencesModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetPreferencesEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerModel<PrefrencesModel>.self, callback: callback)
    }
    
    public class func subscriptionDetail(callback: ObjectResult<ContainerModel<MembershipPackageModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kSubscriptionDetailEndPoint)
        let request = POST(url,parameters: nil)
        _ = _service?.request(request, model: ContainerModel<MembershipPackageModel>.self, callback: callback)
    }
    
    public class func getSuggestedUserById(userId: String, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil){
        var params: [String: Any] = [:]
        if !Utils.stringIsNullOrEmpty(userId) {
            params["id"] = userId
        }
        let url = URLMANAGER.baseUrl(endPoint: kSuggestedUsersEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }

    public class func updateUserStatus(params: [String: Any], callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrl(endPoint: kProfileStatusEndPoint)
        let request = PUT(url, params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func followRequestList(callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrlV2(endPoint: kFollowRequestList)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }

    public class func acceptRejectReques(id: String, status: String, callback: ObjectResult<BaseModel>? = nil){
        let params: [String: Any] = ["id": id, "status": status]
        let url = URLMANAGER.baseUrlV2(endPoint: kRequestAcceptRejectEndPoint)
        let request = PUT(url, params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    
    // --------------------------------------
    // MARK: Payment & wallet Service
    // --------------------------------------

    public class func stripePaymentIntent(params: [String: Any], callback: ObjectResult<ContainerModel<PaymentCredentialModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kStripePaymentIntentEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<PaymentCredentialModel>.self, callback: callback)
    }
    
    public class func requestPurchaseMembership(params: [String: Any], callback: ObjectResult<ContainerModel<PaymentCredentialModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kMembershipPurchase)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<PaymentCredentialModel>.self, callback: callback)
    }
    
    public class func getPurchaseOrderList(callback: ObjectResult<ContainerListModel<VouchersListModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kOrderListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<VouchersListModel>.self, callback: callback)
    }
    
    public class func deleteOrder(ids: [String], callback: ObjectResult<ContainerListModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["ids": ids]
        let url = URLMANAGER.baseUrl(endPoint: kOrderDeleteEndPoint)
        let request = DELETE(url, params)
        _ = _service?.request(request, model: ContainerListModel<BaseModel>.self, callback: callback)
    }
    
    public class func giftsList(callback: ObjectResult<ContainerListModel<VouchersListModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kGiftsListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<VouchersListModel>.self, callback: callback)
    }
    
        
    public class func sendPackageGifts(type: String, friendId: String, packageId: String, dealId: String, activityId: String,eventId: String, date: String, time: String, qty: Int, giftMessage: String, callback: ObjectResult<BaseModel>? = nil){
        let url = URLMANAGER.baseUrlV2(endPoint: kSendGiftEndPoint)
        var params: [String: Any] = [:]
        if !Utils.stringIsNullOrEmpty(packageId) {
            params["friendId"] = friendId
            params["packageId"] = packageId
            params["type"] = type
            params["qty"] = qty
        } else if !Utils.stringIsNullOrEmpty(activityId) {
            params["friendId"] = friendId
            params["activityId"] = activityId
            params["type"] = type
            params["qty"] = qty
            params["date"] = date
            params["time"] = time
        } else if !Utils.stringIsNullOrEmpty(eventId) {
            params["type"] = friendId
            params["eventId"] = friendId
            params["packageId"] = friendId
            params["qty"] = friendId
            params["venueId"] = friendId
        } else {
            params["friendId"] = friendId
            params["dealId"] = dealId
            params["type"] = type
            params["qty"] = qty
        }
        params["giftMessage"] = giftMessage
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Followers & Following Service
    // --------------------------------------

    public class func getFollowersList(id: String, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrlV2(endPoint: kFollowerListEndPoint)
        let params: [String: Any] = ["id": id]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, shouldRefresh: false, callback: callback)
    }
    
    public class func getFollowingList(id: String, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrlV2(endPoint: kFollowingListEndPoint)
        let params: [String: Any] = ["id": id]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, shouldRefresh: false, callback: callback)
    }
    
    public class func userFollow(id: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrlV2(endPoint: kUserFollowEndPoint)
        let params: [String: Any] = ["followId": id]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func userBlock(id: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrlV2(endPoint: kUserBlockEndPoint)
        let params: [String: Any] = ["blockId": id]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func userReport(id: String, reason: String, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrl(endPoint: kUserReportEndPoint)
        let params: [String: Any] = ["userId": id, "reason": reason]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func removeShareBucket(bucketId: String, userId: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String:Any] = ["userId": userId, "bucketId": bucketId]
        let url = URLMANAGER.baseUrl(endPoint: kRemoveShareBucketEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
        
    public class func changeOwnerOfBucket(id: String, ownerId: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String:Any] = ["id": id, "ownerId": ownerId]
        let url = URLMANAGER.baseUrl(endPoint: kBucketChangeOwnerEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Activity Service
    // --------------------------------------
    
    public class func activityBannerList(callback: ObjectResult<ContainerListModel<BannerModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kActivityBannerListEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerListModel<BannerModel>.self, callback: callback)
    }
        
    // --------------------------------------
    // MARK: Rating Service
    // --------------------------------------
    
    public class func ratingSubmit(id: String, type: String, stars: String, review: String, status: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["itemId" : id, "type": type, "stars": stars, "review": review, "status": status]
        let url = URLMANAGER.baseUrl(endPoint: kRatingSubmitEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func getRatingList(id: String, type: String, page: Int, limit: Int, callback: ObjectResult<ContainerModel<RatingListModel>>? = nil) {
        let params: [String: Any] = ["itemId" : id, "type": type, "page": page, "limit": limit]
        let url = URLMANAGER.baseUrl(endPoint: kRatingListEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<RatingListModel>.self, callback: callback)
    }

    public class func ratingReviewSummary(id: String, callback: ObjectResult<ContainerModel<RatingSummaryModel>>? = nil) {
        let params: [String: Any] = ["itemId" : id]
        let url = URLMANAGER.baseUrl(endPoint: kRatingReviewSummaryEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<RatingSummaryModel>.self, callback: callback)
    }
    
    public class func ratingReviewReplyDelete( reviewId: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["reviewId": reviewId]
        let url = URLMANAGER.baseUrl(endPoint: kRatingReviewReplyDeleteEndPoint)
        let request = DELETE(url, params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func reviewReplyDelete( reviewId: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["id": reviewId]
        let url = URLMANAGER.baseUrl(endPoint: kRatingReviewDeleteEndPoint)
        let request = DELETE(url, params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func ratingReply(reviewId: String, reply:String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["reviewId" : reviewId, "reply":reply]
        let url = URLMANAGER.baseUrl(endPoint: kRatingReviewReplyAddUpdateEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Location Service
    // --------------------------------------

    public class func updateUserLocation(lat: Double, lng: Double, callback: ObjectResult<ContainerModel<UserDetailModel>>? = nil) {
        let params: [String:Any] = ["lat": lat, "lng": lng]
        let url = URLMANAGER.baseUrl(endPoint: kUserLocationEndPoint)
        let request = PUT(url, params)
        _ = _service?.request(request, model: ContainerModel<UserDetailModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Chat Service
    // --------------------------------------
    
    public class func getChatList(callback: ObjectResult<ContainerModel<ChatListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kChatFriendListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<ChatListModel>.self, callback: callback)
    }
    
    public class func chatMessages(chatId: String, page: Int, limit: Int, callback: ObjectResult<ContainerListModel<MessageModel>>? = nil) {
        let params: [String:Any] = ["chatId": chatId, "page": page, "limit": limit]
        let url = URLMANAGER.baseUrl(endPoint: kChatMessagesEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<MessageModel>.self, callback: callback)
    }
    
    public class func unreceivedMessages(_ lastDate: String,callback: ObjectResult<ContainerListModel<MessageModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUnReceivedChatMessagesEndPoint)
        var params: [String: Any] = [:]
        params["syncDate"] = lastDate
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<MessageModel>.self, callback: callback)
    }
    
    public class func createChatWithFriend(friendId: String, callback: ObjectResult<ContainerModel<ChatModel>>? = nil) {
        let params: [String:Any] = ["friendId": friendId]
        let url = URLMANAGER.baseUrl(endPoint: kCreateChatWithFriendEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<ChatModel>.self, callback: callback)
    }
        
    public class func uploadFile(fileUrl: URL, callback: ObjectResult<ContainerStringModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kChatUploadFileEndPoint)
        var params: [String: Any] = [:]
        params["fileData"] = fileUrl
        let request = POST_UPLOAD_FILE(url, parameters: params)
        _ = _service?.multipartRequest(request, model: ContainerStringModel.self, callback: callback)
    }
    
    public class func deleteChatById(chatId: String,callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kChatDeleteEndPoint)
        var params: [String: Any] = [:]
        params["chatId"] = chatId
        let request = POST(url, parameters: params)
        _ = _service?.multipartRequest(request, model: BaseModel.self, callback: callback)

    }
    
    // --------------------------------------
    // MARK: Shoutout Service
    // --------------------------------------
        
    public class func changeVisibility(isVisible: Bool, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["isVisible": isVisible]
        let url = URLMANAGER.baseUrlV2(endPoint: kVisibilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Ads Service
    // --------------------------------------

    public class func adList(callback: ObjectResult<ContainerListModel<AdListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kAdsListEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerListModel<AdListModel>.self, callback: callback)
    }
    
    public class func adVideoList(callback: ObjectResult<ContainerListModel<AdListModel>>? = nil) -> DataRequest? {
        let url = URLMANAGER.baseUrl(endPoint: kAdsListEndPoint)
        let request = POST(url, parameters: nil)
        return _service?.request(request, model: ContainerListModel<AdListModel>.self, callback: callback)
    }

    
    public class func adLogCreate(adsIds: [String], logType: String, callback: ObjectResult<BaseModel>? = nil){
        let url = URLMANAGER.baseUrl(endPoint: kAdLogCreateEndPoint)
        let params: [String: Any] = ["adsIds": adsIds, "device": "phone", "logType": logType]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Claim History Service
    // --------------------------------------
    
    public class func requestHistory(callback: ObjectResult<ContainerListModel<VouchersListModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: korderHistoryEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<VouchersListModel>.self, callback: callback)
    }


    // --------------------------------------
    // MARK: Comman Service
    // --------------------------------------
    
    public class func updateFollows(id: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["id" : id]
        let url = URLMANAGER.baseUrl(endPoint: kFollowEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }

    public class func getSettings(callback: ObjectResult<ContainerModel<SettingsModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetSetting)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerModel<SettingsModel>.self, callback: callback)
    }
    
    public class func search(_ query:String = kEmptyString, filters: [CommonSettingsModel] = [] , location: [String: Any] = [:], callback: ObjectResult<ContainerListModel<SearchResultModel>>? = nil) -> DataRequest? {
        let url = URLMANAGER.baseUrlV2(endPoint: kSearchEndPoint)
        var params: [String: Any] = [:]
        if !query.isEmpty {
            params["query"] = query
        }
        
        if !location.isEmpty {
            params["lat"] =  location["lat"] as! Double == 0.0 ? APPSETTING.latitude : location["lat"]
            params["long"] = location["long"] as! Double == 0.0 ? APPSETTING.longitude : location["long"]
        }
        
        if !filters.isEmpty {
            filters.forEach { model in
                if model.type == "maxDistance" {
                    params["maxDistance"] = model.price
                } else if model.type == "price" {
                    params["startingPrice"] = model.price
                    params["endingPrice"] = model.endPrice
                } else if params.keys.contains(model.type) {
                    var value = params[model.type] as? [String]
                    value?.append(model.id)
                    params[model.type] = value
                } else {
                    params[model.type] = [model.id]
                }
            }
        }
        

        let request = POST(url, parameters: params)
        return _service?.request(request, model: ContainerListModel<SearchResultModel>.self, callback: callback)
    }
        
    public class func newExplore(shouldRefresh: Bool = false ,callback: ObjectResult<ContainerModel<HomeModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kNewExploreEndpoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<HomeModel>.self, callback: callback)
    }
    
    public class func requestRecommendation(id: String, type: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String:Any] = ["id": id,"type": type]
        let url = URLMANAGER.baseUrl(endPoint: kRecommendationEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func requestAddRemoveFav(id: String, type: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String:Any] = ["typeId": id,"type": type]
        let url = URLMANAGER.baseUrl(endPoint: kFavouriteAddRemoveEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    public class func requestInOut(params: [String: Any], callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kInOutStatusEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func requestSearchFilter(callback: ObjectResult<ContainerModel<SettingsModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kSearchFilterEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerModel<SettingsModel>.self, callback: callback)
    }
    
    public class func requestSearchSuggestion(search: String, callback: ObjectResult<ContainerStringListModel>? = nil) -> DataRequest? {
        let url = URLMANAGER.baseUrl(endPoint: kSearchSuggestionEndPoint)
        let request = POST(url,parameters: ["search": search])
        return _service?.request(request, model: ContainerStringListModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Notification Service
    // --------------------------------------

    public class func notificationList(page: Int, limit: Int, callback: ObjectResult<ContainerModel<NotificationListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kNotificationListEndPoint)
        let params: [String: Any] = ["page": page, "limit": limit]
        
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<NotificationListModel>.self, callback: callback)
    }
    
    public class func notificationDelete(ids: [String],callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kNotificationDeleteEndPoint)
        let params: [String: Any] = ["ids": ids]
        
        let request = DELETE(url, params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func getUnreadCount(callback: ObjectResult<ContainerModel<NotificationListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kNoficationUnReadEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<NotificationListModel>.self, callback: callback)
    }
    
    public class func notificationRead(notificationId: String, callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kNotificationReadEndPoint)
        let params: [String: Any] = ["notificationId": notificationId]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }


    // --------------------------------------
    // MARK: Outing Service
    // --------------------------------------

    public class func requestCreateOuting(params: [String: Any], callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kOutingEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: WhoIsIn Contact
    // --------------------------------------
    
    public class func getContactList(emails: [String], phones: [String], callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil){
        let url = URLMANAGER.baseUrl(endPoint: kWhoIsInGetContactsEndPoint)
        let params: [String: Any] = ["email": emails, "phone": phones]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func contactUs(image: String,name: String, email: String, phone: String, subject: String, message: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kContactUsEndPoint)
        let params: [String: Any] = ["image":image,"name": name, "email": email,"phone": phone,"subject": subject,"message": message]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func inboxList(callback: ObjectResult<ContainerListModel<InboxListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kInboxListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<InboxListModel>.self, callback: callback)
    }
    
    public class func replyContactQuery(reply: String,conctactUsId: String, callback: ObjectResult<ContainerModel<RepliesModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kReplyContactUsEndPoint)
        let params: [String: Any] = ["reply":reply,"conctactUsId": conctactUsId]
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<RepliesModel>.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Add Story Contact
    // --------------------------------------

    public class func requestAddStory(params: [String: Any], callback: ObjectResult<ContainerModel<StoryModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kAddMystoryEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<StoryModel>.self, callback: callback)
    }
    
    public class func requestRedeemOffer(packageId: String, qty: Int, claimCode: String, type: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String:Any] = ["packageId": packageId,"qty": qty,"claimCode": claimCode, "type": type]
        let url = URLMANAGER.baseUrlV2(endPoint: kOfferRedeemEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Generate Dynamic Link
    // --------------------------------------
    
    public class func createDynamicLink(params: [String: Any], callback: ObjectResult<ContainerStringModel>? = nil) {
        let url = "https://api.whosin.me/link/create"
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerStringModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: BlockList User Service
    // --------------------------------------
    
    public class func getBlockList(callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kUsersBlockListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func getReviewList(callback: ObjectResult<ContainerListModel<RatingModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUserReviewListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<RatingModel>.self, callback: callback)
    }

    public class func unblockUser(blockId: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["blockId":blockId]
        let url = URLMANAGER.baseUrl(endPoint: kUserUnBlockEndPoint)
        let request = DELETE(url, params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: BlockList User Service
    // --------------------------------------
    
    public class func addReportUser(params: [String: Any], callback: ObjectResult<ContainerModel<ReportedUserListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: KUserAddReportEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<ReportedUserListModel>.self, callback: callback)
    }

    public class func reportedUserList(callback: ObjectResult<ContainerListModel<ReportedUserListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUserReportedUserListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<ReportedUserListModel>.self, callback: callback)
    }
    
    public class func removeReportedUser(id: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["id":id]
        let url = URLMANAGER.baseUrl(endPoint: kUserRemoveReportEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func reportDetail(id: String, callback: ObjectResult<ContainerModel<ReportedUserListModel>>? = nil) {
        let params: [String: Any] = ["id":id]
        let url = URLMANAGER.baseUrl(endPoint: kUserReportDetailEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<ReportedUserListModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Get/Read Service
    // --------------------------------------
    
    public class func getUpdates(callback: ObjectResult<ContainerModel<GetUpdatesModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kGetUpdatesEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerModel<GetUpdatesModel>.self, callback: callback)
    }

    public class func readUpdate(type: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["type":type]
        let url = URLMANAGER.baseUrl(endPoint: kReadUpdatesEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    public class func removeSuggested(type: String, typeId: String, callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["type":type, "typeId": typeId]
        let url = URLMANAGER.baseUrl(endPoint: kRemoveSuggestedEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func readContactUs(replyIds: [String], callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["replyIds": replyIds]
        let url = URLMANAGER.baseUrl(endPoint: kReadContactUsEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Membership Service
    // --------------------------------------
    
    public class func applyPromoCode(id: String, amount: String, promoCode: String, type: PromoType, apply: Bool, callback: ObjectResult<ContainerModel<PromoCodeModel>>? = nil) {
        let params: [String: Any] = ["typeId": id, "amount" : amount, "promoCode": promoCode, "type": type.rawValue, "apply": apply]
        let url = URLMANAGER.baseUrlV2(endPoint: kValidatePromoCodeEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<PromoCodeModel>.self, callback: callback)
    }
    
    public class func membershipDetail(id: String, callback: ObjectResult<ContainerModel<MembershipPackageModel>>? = nil) {
        let params: [String: Any] = ["packageId": id]
        let url = URLMANAGER.baseUrlV2(endPoint: kMembershipDetail)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<MembershipPackageModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Plus One Feature Service
    // --------------------------------------

    public class func myPlusOneList(callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneMyGroupListEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func myPlusOneUserList(callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneUserListEndPount)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func invitePlusOneMember(id: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["plusOneId": id]
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneInviteEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func removePlusOne(id: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["plusOneId": id]
        let url = URLMANAGER.baseUrl(endPoint: kRemovePlusOneMemberEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func leavePlusOne(id: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["id": id]
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneleaveEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func updatePlusOneStatus(id: String,status: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let params: [String: Any] = ["requstId": id, "status": status]
        let url = URLMANAGER.baseUrl(endPoint: kUpdatePlusOneStatusEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func eventInvitePlusOne(eventId: String,inviteIds: [String], callback: ObjectResult<BaseModel>? = nil) {
        let params: [String: Any] = ["eventId": eventId, "inviteIds": inviteIds]
        let url = URLMANAGER.baseUrl(endPoint: kEventPlusOneInviteEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
        
    public class func updatePlusOneInviteStatus(inviteId: String,inviteStatus: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["inviteId" : inviteId, "status" : inviteStatus]
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneInOutEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func plusOnePromoterRequest(inviteId: String,inviteStatus: String,callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["inviteId" : inviteId, "promoterStatus" : inviteStatus]
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneRequestAccept)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
        
    public class func getCustomCategory(callback: ObjectResult<ContainerStringListModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kCustomCategoryEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: ContainerStringListModel.self, callback: callback)

    }
    
    public class func addMemberToCircles(id: String, circleIds: [String], callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["circleIds" : circleIds, "memberId": id]
        let url = URLMANAGER.baseUrl(endPoint: kUseraddInCirclesEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func usersSearch(_ query:String = kEmptyString, page: Int = 1, limit: Int = 100, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) -> DataRequest? {
        let url = URLMANAGER.baseUrl(endPoint: kPlusOneInviteSearchEndPoint)
        let params: [String: Any] = ["search": query, "page": page, "limit": limit]
        let request = POST(url, parameters: params)
        return _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
    
    public class func getVenueMedia(id: String, callback: ObjectResult<ContainerStringListModel>? = nil) {
        let param: [String: Any] = ["venueId": id]
        let url = URLMANAGER.baseUrl(endPoint: kGetVenuesMediaEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerStringListModel.self, callback: callback)
    }
    
    public class func getCircleListByUserId(id: String, callback: ObjectResult<ContainerListModel<UserDetailModel>>? = nil) {
        let param: [String: Any] = ["otherUserId": id]
        let url = URLMANAGER.baseUrl(endPoint: kCirclesByUserIdEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerListModel<UserDetailModel>.self, callback: callback)
    }
                
    // --------------------------------------
    // MARK: Ads, banners and notification services
    // --------------------------------------
        
    public class func readInAppNotification(notificationId: String, callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let param: [String: Any] = ["notificationId": notificationId]
        let url = URLMANAGER.baseUrl(endPoint: kInAppReadUpdateEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }
    
    public class func inAppNotificationList(callback: ObjectResult<ContainerModel<IANListModel>>? = nil) {
        let param: [String: Any] = ["page": 1, "limit": 200]
        let url = URLMANAGER.baseUrl(endPoint: kInAppListEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<IANListModel>.self, callback: callback)
    }
    
    public class func promotionalBanner(callback: ObjectResult<ContainerModel<PromotionalBannerModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromotionalBannerEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<PromotionalBannerModel>.self,shouldRefresh: false, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Ticket common Service
    // --------------------------------------

    public class func moreInfo(customTicketId: String, callback: ObjectResult<ContainerListModel<MoreInfoModel>>? = nil) {
        let param: [String: Any] = ["customTicketId": customTicketId]
        let url = URLMANAGER.baseUrl(endPoint: kMoreInfoEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerListModel<MoreInfoModel>.self, callback: callback)
    }

    public class func featuredTickets(shouldRefresh: Bool = false ,callback: ObjectResult<ContainerModel<HomeModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kFeaturedTicketEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<HomeModel>.self, callback: callback)
    }
    
    public class func checkRaynaReview(callback: ObjectResult<ContainerModel<CheckRaynaReviewModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kCheckReviewRaynaEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<CheckRaynaReviewModel>.self, callback: callback)
    }
    
    public class func updateRaynaReviewStatus(customTicketId: String, status: String, callback: ObjectResult<ContainerModel<TicketBookingModel>>? = nil) {
        let param: [String: Any] = ["customTicketId": customTicketId, "status": status]
        let url = URLMANAGER.baseUrl(endPoint: kRaynaUpdateReviewEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<TicketBookingModel>.self, callback: callback)
    }
    
    public class func getTicketDetail(id: String, callback: ObjectResult<ContainerModel<TicketModel>>? = nil) {
        let param: [String: Any] = ["customTicketId": id]
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTicketDetailEndPoint)
        let request = POST(url, parameters: param)
        _ = _service?.request(request, model: ContainerModel<TicketModel>.self, callback: callback)
    }
    
    public class func raynaSearch(search: String, page: Int, type: String = "ticket", callback: ObjectResult<ContainerListModel<TicketModel>>? = nil)  -> DataRequest? {
        let param: [String: Any] = ["search": search, "page": page, "limit": 20, "type": type]
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaSearchEndPoint)
        let request = POST(url, parameters: param)
        return _service?.request(request, model: ContainerListModel<TicketModel>.self, callback: callback)
    }
    
    public class func raynaTicketList(search: String = kEmptyString, page: Int, cities: [String] = [], categories: [String] = [], callback: ObjectResult<ContainerListModel<TicketModel>>? = nil)  -> DataRequest? {
        let param: [String: Any] = ["search": search, "page": page, "limit": 10, "cityIds": cities, "categoryIds": categories]
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTicketListEndPoint)
        let request = POST(url, parameters: param)
        return _service?.request(request, model: ContainerListModel<TicketModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Rayna Ticket Service
    // --------------------------------------
    
    public class func raynaTourOptions(params: [String : Any], callback: ObjectResult<ContainerListModel<TourOptionsModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTourOptionEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourOptionsModel>.self, callback: callback)
    }
    
    public class func raynaTourOptionsDetailByTourId(params: [String : Any], callback: ObjectResult<ContainerListModel<TourDataModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTourOptionDetailByIdEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourDataModel>.self, callback: callback)
    }
    
    public class func raynaTourAvailability(params: [String : Any], callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTimeAvailibilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func raynaTourTimeSlots(params: [String : Any], callback: ObjectResult<ContainerListModel<TourTimeSlotModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTimeSlotEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourTimeSlotModel>.self, callback: callback)
    }

    public class func raynaTourPolicy(params: [String : Any], callback: ObjectResult<ContainerListModel<TourPolicyModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaPolicyEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourPolicyModel>.self, callback: callback)
    }

    public class func raynaTourBooking(params: [String: Any], callback: ObjectResult<ContainerModel<PaymentCredentialModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaTourBooking)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<PaymentCredentialModel>.self, callback: callback)
    }

    public class func raynaBookingCancel(id: String,bookingId: String, cancellationReason: String, callback: ObjectResult<BaseModel>? = nil) {
        let param: [String: Any] = ["cancellationReason": cancellationReason, "bookingId": bookingId, "_id": id]
        let url = URLMANAGER.baseUrlV2(endPoint: kRaynaticketCancelEndPoint)
        let request = POST(url,parameters: param)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    // --------------------------------------
    // MARK: Whosin Ticket Service
    // --------------------------------------
    
    public class func whosinAvailability(params: [String : Any], callback: ObjectResult<ContainerListModel<TourOptionsModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kWhosinAvailabilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourOptionsModel>.self, callback: callback)
    }
    
    public class func whsoinBookingRules(params: [String : Any], callback: ObjectResult<ContainerListModel<TourPolicyModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kWhosinBookingRulesEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourPolicyModel>.self, callback: callback)
    }

    public class func  whosinBookingCancel(id: String,bookingId: String, callback: ObjectResult<BaseModel>? = nil) {
        let param: [String: Any] = ["bookingId": bookingId, "_id": id]
        let url = URLMANAGER.baseUrlV2(endPoint: kWhosinBookingCancelEndPoint)
        let request = POST(url,parameters: param)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func  whosinTicketCancel(id: String,bookingId: String,reason: String, callback: ObjectResult<BaseModel>? = nil) {
        let param: [String: Any] = ["bookingId": bookingId, "_id": id, "cancellationReason": reason]
        let url = URLMANAGER.baseUrl(endPoint: kWhosinticketCancelEndPoint)
        let request = POST(url,parameters: param)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func whosinAddOnAvailability(params: [String : Any], callback: ObjectResult<ContainerListModel<TourOptionsModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kWhosinAddOnAvailabilityEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourOptionsModel>.self, callback: callback)
    }

    public class func whosinSlots(params: [String : Any], callback: ObjectResult<ContainerListModel<TourTimeSlotModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kWhosinticketSlotEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourTimeSlotModel>.self, callback: callback)
    }
    
    public class func whsoinTicketRules(params: [String : Any], callback: ObjectResult<ContainerListModel<TourPolicyModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kWhosinticketRulsEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourPolicyModel>.self, callback: callback)
    }
    
    public class func whsoinTicketAvailibility(params: [String : Any], callback: ObjectResult<ContainerModel<availibityWhosinTicket>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kWhosinticketAvailibilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<availibityWhosinTicket>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Juniper Ticket Service
    // --------------------------------------
    
    public class func juniperTicketAvailability(params: [String : Any], callback: ObjectResult<ContainerListModel<ServiceModel>>? = nil) {
        let url = URLMANAGER.baseUrlV2(endPoint: kJuniperAvailabilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<ServiceModel>.self, callback: callback)
    }
    
    public class func juniperCheckAvailability(code: String, callback: ObjectResult<ContainerListModel<ServiceModel>>? = nil) {
        let params: [String: Any] = ["ratePlanCode": code]
        let url = URLMANAGER.baseUrlV2(endPoint: kJuniperCheckAvailabilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<ServiceModel>.self, callback: callback)
    }
    
    public class func juniperBookingRules(code: String, callback: ObjectResult<ContainerListModel<TourPolicyModel>>? = nil) {
        let params: [String: Any] = ["ratePlanCode": code]
        let url = URLMANAGER.baseUrlV2(endPoint: kJuniperBookingRulesEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourPolicyModel>.self, callback: callback)
    }

    // --------------------------------------
    // MARK: TravelDesk Ticket Service
    // --------------------------------------

    public class func travelDeskAvailability(params: [String : Any], callback: ObjectResult<ContainerListModel<TravelDeskAvailibilityModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kTravelDeskAvailibilityEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TravelDeskAvailibilityModel>.self, callback: callback)
    }
    
    public class func travelDeskPickupList(params: [String : Any], callback: ObjectResult<ContainerListModel<PickupListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kTravelDeskPickupListEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<PickupListModel>.self, callback: callback)
    }
    
    public class func travelBookingCancel(id: String,bookingId: String, bookingType: String, reason: String = kEmptyString, callback: ObjectResult<BaseModel>? = nil) {
        var param: [String: Any] = ["bookingId": bookingId, "_id": id, "bookingType": bookingType]
        if !Utils.stringIsNullOrEmpty(reason) {
            param["cancellationReason"] = reason
        }
        let url = URLMANAGER.baseUrlV2(endPoint: kTravelCancellationEndPoint)
        let request = POST(url,parameters: param)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    public class func travelTourPolicy(params: [String : Any], callback: ObjectResult<ContainerListModel<TourPolicyModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kTravelPolicyEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TourPolicyModel>.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Octo Ticket Service
    // --------------------------------------
    
    public class func bigBusAvailability(params: [String : Any], callback: ObjectResult<ContainerListModel<OctoAvailibilityModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kOctoTicketAvailibility)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<OctoAvailibilityModel>.self, callback: callback)
    }
    
    public class func octoPolicy(params: [String : Any], callback: ObjectResult<ContainerStringModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kOctoTicketPolicy)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerStringModel.self, callback: callback)
    }
    
    public class func  octoBookingCancel(id: String,bookingId: String, reson: String, callback: ObjectResult<BaseModel>? = nil) {
        let param: [String: Any] = ["bookingId": bookingId, "_id": id, "cancellationReason": reson, "bookingType" : "octo"]
        let url = URLMANAGER.baseUrlV2(endPoint: kTravelCancellationEndPoint)
        let request = POST(url,parameters: param)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: Ticket Cart Service
    // --------------------------------------

    public class func AddToCart(params: [String : Any], callback: ObjectResult<ContainerModel<BookingModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kAddToCartEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BookingModel>.self, callback: callback)
    }

    public class func RemoveFromCart(params: [String : Any], callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kRemoveFromCartEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func RemoveOptionFromCart(params: [String : Any], callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kRemoveOptionFromCartEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }

    public class func viewCart(callback: ObjectResult<ContainerModel<TicketCartListModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kViewCartEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: ContainerModel<TicketCartListModel>.self, callback: callback)
    }
    
    public class func updateCart(params: [String: Any], callback: ObjectResult<ContainerModel<BaseModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kUpdateCartEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<BaseModel>.self, callback: callback)
    }

    public class func checkOutCart(params: [String: Any], callback: ObjectResult<ContainerModel<PaymentCredentialModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kCheckoutCartEndPoint)
        let request = POST(url,parameters: params)
        _ = _service?.request(request, model: ContainerModel<PaymentCredentialModel>.self, callback: callback)
    }

    public class func removePromoCode(callback: ObjectResult<BaseModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kPromoCodeRemoveEndPoint)
        let request = POST(url, parameters: nil)
        _ = _service?.request(request, model: BaseModel.self, callback: callback)
    }
    
    public class func requestPkPass(bookingId: String, callback: ObjectResult<ContainerStringListModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kApplwWalletEndPoint)
        let request = POST(url,parameters: ["bookingId": bookingId])
        _ = _service?.request(request, model: ContainerStringListModel.self, callback: callback)
    }
    
    public class func getLanguageFiles(callback: ObjectResult<LanguageFileModel>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kLanguageLocalizeEndPoint)
        let request = GET(url)
        _ = _service?.request(request, model: LanguageFileModel.self, callback: callback)
    }
    
    // --------------------------------------
    // MARK: JP HOTEL Service
    // --------------------------------------

    public class func jpHotelAvailability(params: [String : Any], callback: ObjectResult<ContainerModel<JPHotelAvailibilityModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kJPHotelAvailibility)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<JPHotelAvailibilityModel>.self, callback: callback)
    }
    
    public class func jpHotelBookingRuls(params: [String: Any], callback: ObjectResult<ContainerModel<JPBookingRulesData>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kJPHotelBookingRulsEndPoint)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerModel<JPBookingRulesData>.self, callback: callback)
    }
    
    public class func suggestedTicketList(params: [String: Any], callback: ObjectResult<ContainerListModel<TicketModel>>? = nil) {
        let url = URLMANAGER.baseUrl(endPoint: kSugestedTicketList)
        let request = POST(url, parameters: params)
        _ = _service?.request(request, model: ContainerListModel<TicketModel>.self, callback: callback)
    }
}
