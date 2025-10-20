;; Knowledge Market - Decentralized Marketplace for Verified Knowledge & Expertise
;; A production-ready smart contract for trading knowledge with reputation-based pricing

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u400))
(define-constant err-not-found (err u401))
(define-constant err-unauthorized (err u402))
(define-constant err-invalid-amount (err u403))
(define-constant err-already-exists (err u404))
(define-constant err-already-purchased (err u405))
(define-constant err-invalid-rating (err u406))
(define-constant err-already-rated (err u407))
(define-constant err-not-purchased (err u408))
(define-constant err-invalid-price (err u409))
(define-constant err-expert-limit (err u410))
(define-constant err-listing-limit (err u411))

;; Platform fee (5% = 500 basis points)
(define-constant platform-fee-bp u500)
(define-constant basis-points u10000)

;; Limits
(define-constant max-listings-per-expert u50)
(define-constant min-price u1000000)

;; Data Variables
(define-data-var listing-nonce uint u0)
(define-data-var total-listings uint u0)
(define-data-var total-sales uint u0)
(define-data-var total-volume uint u0)
(define-data-var platform-revenue uint u0)

;; Expert Profile
(define-map experts
    principal
    {
        display-name: (string-utf8 50),
        bio: (string-utf8 500),
        expertise-areas: (string-utf8 200),
        total-listings: uint,
        total-sales: uint,
        total-earned: uint,
        average-rating: uint,
        rating-count: uint,
        joined-at: uint,
        is-verified: bool
    }
)

;; Knowledge Listing
(define-map listings
    uint
    {
        expert: principal,
        title: (string-utf8 100),
        description: (string-utf8 500),
        category: (string-ascii 30),
        price: uint,
        total-purchases: uint,
        total-revenue: uint,
        average-rating: uint,
        rating-count: uint,
        created-at: uint,
        is-active: bool,
        delivery-type: (string-ascii 20)
    }
)

;; Purchase Records
(define-map purchases
    { listing-id: uint, buyer: principal }
    {
        purchase-price: uint,
        purchased-at: uint,
        is-rated: bool,
        rating: (optional uint),
        review: (optional (string-utf8 300))
    }
)

;; Expert Statistics (optimized for queries)
(define-map expert-stats
    principal
    {
        total-revenue: uint,
        completed-sales: uint,
        active-listings: uint,
        five-star-count: uint,
        four-star-count: uint,
        three-star-count: uint,
        two-star-count: uint,
        one-star-count: uint
    }
)

;; Listing ownership tracking
(define-map expert-listing-index
    { expert: principal, index: uint }
    uint
)

;; Buyer purchase history
(define-map buyer-purchase-index
    { buyer: principal, index: uint }
    uint
)

(define-map buyer-purchase-count
    principal
    uint
)

;; Read-Only Functions

(define-read-only (get-expert (expert principal))
    (ok (map-get? experts expert))
)

(define-read-only (get-listing (listing-id uint))
    (ok (map-get? listings listing-id))
)

(define-read-only (get-purchase (listing-id uint) (buyer principal))
    (ok (map-get? purchases { listing-id: listing-id, buyer: buyer }))
)

(define-read-only (get-expert-stats (expert principal))
    (ok (map-get? expert-stats expert))
)

(define-read-only (get-platform-stats)
    (ok {
        total-listings: (var-get total-listings),
        total-sales: (var-get total-sales),
        total-volume: (var-get total-volume),
        platform-revenue: (var-get platform-revenue)
    })
)

(define-read-only (has-purchased (listing-id uint) (buyer principal))
    (ok (is-some (map-get? purchases { listing-id: listing-id, buyer: buyer })))
)

(define-read-only (calculate-dynamic-price (listing-id uint))
    (let (
        (listing (unwrap! (map-get? listings listing-id) err-not-found))
        (base-price (get price listing))
        (rating (get average-rating listing))
        (purchase-count (get total-purchases listing))
    )
        ;; Dynamic pricing: base price + reputation bonus + demand bonus
        (ok (+
            base-price
            (/ (* base-price rating) u100)
            (/ (* base-price purchase-count) u200)
        ))
    )
)

(define-read-only (get-expert-listing-id (expert principal) (index uint))
    (ok (map-get? expert-listing-index { expert: expert, index: index }))
)

(define-read-only (get-buyer-purchase-id (buyer principal) (index uint))
    (ok (map-get? buyer-purchase-index { buyer: buyer, index: index }))
)

;; Private helper functions

(define-private (add-listing-to-expert-index (expert principal) (listing-id uint))
    (let (
        (expert-profile (unwrap! (map-get? experts expert) false))
        (current-count (get total-listings expert-profile))
    )
        (map-set expert-listing-index
            { expert: expert, index: current-count }
            listing-id
        )
        true
    )
)

(define-private (add-purchase-to-buyer-index (buyer principal) (listing-id uint))
    (let (
        (current-count (default-to u0 (map-get? buyer-purchase-count buyer)))
    )
        (map-set buyer-purchase-index
            { buyer: buyer, index: current-count }
            listing-id
        )
        (map-set buyer-purchase-count buyer (+ current-count u1))
        true
    )
)

(define-private (update-expert-rating (expert principal) (new-rating uint))
    (let (
        (expert-profile (unwrap! (map-get? experts expert) false))
        (current-avg (get average-rating expert-profile))
        (current-count (get rating-count expert-profile))
        (total-points (+ (* current-avg current-count) new-rating))
        (new-count (+ current-count u1))
        (new-avg (/ total-points new-count))
    )
        (map-set experts expert
            (merge expert-profile {
                average-rating: new-avg,
                rating-count: new-count
            })
        )
        true
    )
)

(define-private (update-listing-rating (listing-id uint) (new-rating uint))
    (let (
        (listing (unwrap! (map-get? listings listing-id) false))
        (current-avg (get average-rating listing))
        (current-count (get rating-count listing))
        (total-points (+ (* current-avg current-count) new-rating))
        (new-count (+ current-count u1))
        (new-avg (/ total-points new-count))
    )
        (map-set listings listing-id
            (merge listing {
                average-rating: new-avg,
                rating-count: new-count
            })
        )
        true
    )
)

;; Public Functions

;; Register as an expert
(define-public (register-expert
    (display-name (string-utf8 50))
    (bio (string-utf8 500))
    (expertise-areas (string-utf8 200)))
    (let (
        (existing-expert (map-get? experts tx-sender))
    )
        (asserts! (is-none existing-expert) err-already-exists)
        (asserts! (> (len display-name) u0) err-invalid-amount)
        
        (map-set experts tx-sender {
            display-name: display-name,
            bio: bio,
            expertise-areas: expertise-areas,
            total-listings: u0,
            total-sales: u0,
            total-earned: u0,
            average-rating: u0,
            rating-count: u0,
            joined-at: stacks-block-height,
            is-verified: false
        })
        
        (map-set expert-stats tx-sender {
            total-revenue: u0,
            completed-sales: u0,
            active-listings: u0,
            five-star-count: u0,
            four-star-count: u0,
            three-star-count: u0,
            two-star-count: u0,
            one-star-count: u0
        })
        
        (ok true)
    )
)

;; Create a knowledge listing
(define-public (create-listing
    (title (string-utf8 100))
    (description (string-utf8 500))
    (category (string-ascii 30))
    (price uint)
    (delivery-type (string-ascii 20)))
    (let (
        (listing-id (+ (var-get listing-nonce) u1))
        (expert-profile (unwrap! (map-get? experts tx-sender) err-not-found))
        (expert-stat (unwrap! (map-get? expert-stats tx-sender) err-not-found))
    )
        (asserts! (>= price min-price) err-invalid-price)
        (asserts! (> (len title) u0) err-invalid-amount)
        (asserts! (< (get total-listings expert-profile) max-listings-per-expert) err-listing-limit)
        
        (map-set listings listing-id {
            expert: tx-sender,
            title: title,
            description: description,
            category: category,
            price: price,
            total-purchases: u0,
            total-revenue: u0,
            average-rating: u0,
            rating-count: u0,
            created-at: stacks-block-height,
            is-active: true,
            delivery-type: delivery-type
        })
        
        ;; Update expert profile
        (map-set experts tx-sender
            (merge expert-profile {
                total-listings: (+ (get total-listings expert-profile) u1)
            })
        )
        
        ;; Update expert stats
        (map-set expert-stats tx-sender
            (merge expert-stat {
                active-listings: (+ (get active-listings expert-stat) u1)
            })
        )
        
        ;; Add to expert's listing index
        (add-listing-to-expert-index tx-sender listing-id)
        
        ;; Update global state
        (var-set listing-nonce listing-id)
        (var-set total-listings (+ (var-get total-listings) u1))
        
        (ok listing-id)
    )
)

;; Purchase knowledge listing
(define-public (purchase-listing (listing-id uint))
    (let (
        (listing (unwrap! (map-get? listings listing-id) err-not-found))
        (expert (get expert listing))
        (price (get price listing))
        (platform-fee (/ (* price platform-fee-bp) basis-points))
        (expert-payment (- price platform-fee))
        (existing-purchase (map-get? purchases { listing-id: listing-id, buyer: tx-sender }))
        (expert-profile (unwrap! (map-get? experts expert) err-not-found))
        (expert-stat (unwrap! (map-get? expert-stats expert) err-not-found))
    )
        (asserts! (is-none existing-purchase) err-already-purchased)
        (asserts! (get is-active listing) err-not-found)
        (asserts! (not (is-eq tx-sender expert)) err-unauthorized)
        
        ;; Transfer payment to expert
        (try! (stx-transfer? expert-payment tx-sender expert))
        
        ;; Transfer platform fee
        (try! (stx-transfer? platform-fee tx-sender contract-owner))
        
        ;; Record purchase
        (map-set purchases
            { listing-id: listing-id, buyer: tx-sender }
            {
                purchase-price: price,
                purchased-at: stacks-block-height,
                is-rated: false,
                rating: none,
                review: none
            }
        )
        
        ;; Update listing stats
        (map-set listings listing-id
            (merge listing {
                total-purchases: (+ (get total-purchases listing) u1),
                total-revenue: (+ (get total-revenue listing) price)
            })
        )
        
        ;; Update expert profile
        (map-set experts expert
            (merge expert-profile {
                total-sales: (+ (get total-sales expert-profile) u1),
                total-earned: (+ (get total-earned expert-profile) expert-payment)
            })
        )
        
        ;; Update expert stats
        (map-set expert-stats expert
            (merge expert-stat {
                total-revenue: (+ (get total-revenue expert-stat) expert-payment),
                completed-sales: (+ (get completed-sales expert-stat) u1)
            })
        )
        
        ;; Add to buyer's purchase index
        (add-purchase-to-buyer-index tx-sender listing-id)
        
        ;; Update global stats
        (var-set total-sales (+ (var-get total-sales) u1))
        (var-set total-volume (+ (var-get total-volume) price))
        (var-set platform-revenue (+ (var-get platform-revenue) platform-fee))
        
        (ok true)
    )
)

;; Rate and review a purchased listing
(define-public (rate-listing
    (listing-id uint)
    (rating uint)
    (review (string-utf8 300)))
    (let (
        (listing (unwrap! (map-get? listings listing-id) err-not-found))
        (purchase (unwrap! (map-get? purchases { listing-id: listing-id, buyer: tx-sender }) err-not-purchased))
        (expert (get expert listing))
        (expert-stat (unwrap! (map-get? expert-stats expert) err-not-found))
    )
        (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-rating)
        (asserts! (not (get is-rated purchase)) err-already-rated)
        
        ;; Update purchase record
        (map-set purchases
            { listing-id: listing-id, buyer: tx-sender }
            (merge purchase {
                is-rated: true,
                rating: (some rating),
                review: (some review)
            })
        )
        
        ;; Update listing rating
        (update-listing-rating listing-id rating)
        
        ;; Update expert rating
        (update-expert-rating expert rating)
        
        ;; Update expert stats with rating distribution
        (map-set expert-stats expert
            (merge expert-stat {
                five-star-count: (if (is-eq rating u5) (+ (get five-star-count expert-stat) u1) (get five-star-count expert-stat)),
                four-star-count: (if (is-eq rating u4) (+ (get four-star-count expert-stat) u1) (get four-star-count expert-stat)),
                three-star-count: (if (is-eq rating u3) (+ (get three-star-count expert-stat) u1) (get three-star-count expert-stat)),
                two-star-count: (if (is-eq rating u2) (+ (get two-star-count expert-stat) u1) (get two-star-count expert-stat)),
                one-star-count: (if (is-eq rating u1) (+ (get one-star-count expert-stat) u1) (get one-star-count expert-stat))
            })
        )
        
        (ok true)
    )
)

;; Update listing price (expert only)
(define-public (update-listing-price (listing-id uint) (new-price uint))
    (let (
        (listing (unwrap! (map-get? listings listing-id) err-not-found))
    )
        (asserts! (is-eq tx-sender (get expert listing)) err-unauthorized)
        (asserts! (>= new-price min-price) err-invalid-price)
        
        (map-set listings listing-id
            (merge listing { price: new-price })
        )
        
        (ok true)
    )
)

;; Deactivate listing (expert only)
(define-public (deactivate-listing (listing-id uint))
    (let (
        (listing (unwrap! (map-get? listings listing-id) err-not-found))
        (expert (get expert listing))
        (expert-stat (unwrap! (map-get? expert-stats expert) err-not-found))
    )
        (asserts! (is-eq tx-sender expert) err-unauthorized)
        (asserts! (get is-active listing) err-not-found)
        
        (map-set listings listing-id
            (merge listing { is-active: false })
        )
        
        (map-set expert-stats expert
            (merge expert-stat {
                active-listings: (if (> (get active-listings expert-stat) u0)
                    (- (get active-listings expert-stat) u1)
                    u0)
            })
        )
        
        (ok true)
    )
)

;; Reactivate listing (expert only)
(define-public (reactivate-listing (listing-id uint))
    (let (
        (listing (unwrap! (map-get? listings listing-id) err-not-found))
        (expert (get expert listing))
        (expert-stat (unwrap! (map-get? expert-stats expert) err-not-found))
    )
        (asserts! (is-eq tx-sender expert) err-unauthorized)
        (asserts! (not (get is-active listing)) err-not-found)
        
        (map-set listings listing-id
            (merge listing { is-active: true })
        )
        
        (map-set expert-stats expert
            (merge expert-stat {
                active-listings: (+ (get active-listings expert-stat) u1)
            })
        )
        
        (ok true)
    )
)

;; Update expert profile
(define-public (update-expert-profile
    (display-name (string-utf8 50))
    (bio (string-utf8 500))
    (expertise-areas (string-utf8 200)))
    (let (
        (expert-profile (unwrap! (map-get? experts tx-sender) err-not-found))
    )
        (asserts! (> (len display-name) u0) err-invalid-amount)
        
        (map-set experts tx-sender
            (merge expert-profile {
                display-name: display-name,
                bio: bio,
                expertise-areas: expertise-areas
            })
        )
        
        (ok true)
    )
)

;; Verify expert (admin only)
(define-public (verify-expert (expert principal))
    (let (
        (expert-profile (unwrap! (map-get? experts expert) err-not-found))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        
        (map-set experts expert
            (merge expert-profile { is-verified: true })
        )
        
        (ok true)
    )
)

;; Withdraw platform revenue (admin only)
(define-public (withdraw-platform-revenue (amount uint))
    (let (
        (revenue (var-get platform-revenue))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= amount revenue) err-invalid-amount)
        (asserts! (> amount u0) err-invalid-amount)
        
        (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
        (var-set platform-revenue (- revenue amount))
        
        (ok true)
    )
)