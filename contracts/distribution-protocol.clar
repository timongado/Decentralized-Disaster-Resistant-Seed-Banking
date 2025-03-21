;; Distribution Protocol Contract
;; Manages seed sharing after disasters

(define-data-var last-request-id uint u0)
(define-data-var last-distribution-id uint u0)
(define-data-var disaster-mode bool false)
(define-data-var disaster-coordinator principal tx-sender)

(define-map seed-requests
  { id: uint }
  {
    requester: principal,
    seed-id: uint,
    quantity: uint,
    location: (string-ascii 100),
    status: (string-ascii 20), ;; "pending", "approved", "fulfilled"
    priority: uint ;; 1-5, with 5 being highest
  }
)

(define-map seed-distributions
  { id: uint }
  {
    request-id: uint,
    distributor: principal,
    recipient: principal,
    seed-id: uint,
    quantity: uint
  }
)

;; Set disaster mode
(define-public (set-disaster-mode
    (active bool)
  )
  (begin
    ;; Check if caller is the disaster coordinator
    (asserts! (is-eq tx-sender (var-get disaster-coordinator)) (err u403))

    ;; Update disaster mode
    (var-set disaster-mode active)

    (ok true)
  )
)

;; Request seeds
(define-public (request-seeds
    (seed-id uint)
    (quantity uint)
    (location (string-ascii 100))
    (priority uint)
  )
  (let
    (
      (new-id (+ (var-get last-request-id) u1))
    )
    ;; Check if priority is valid (1-5)
    (asserts! (and (>= priority u1) (<= priority u5)) (err u400))

    ;; Update request ID counter
    (var-set last-request-id new-id)

    ;; Store seed request details
    (map-set seed-requests
      { id: new-id }
      {
        requester: tx-sender,
        seed-id: seed-id,
        quantity: quantity,
        location: location,
        status: "pending",
        priority: priority
      }
    )

    (ok new-id)
  )
)

;; Approve seed request
(define-public (approve-request
    (request-id uint)
  )
  (let
    (
      (request (unwrap! (map-get? seed-requests { id: request-id }) (err u404)))
    )
    ;; Check if caller is the disaster coordinator
    (asserts! (is-eq tx-sender (var-get disaster-coordinator)) (err u403))

    ;; Check if request is in pending status
    (asserts! (is-eq (get status request) "pending") (err u400))

    ;; Update request status
    (map-set seed-requests
      { id: request-id }
      (merge request { status: "approved" })
    )

    (ok true)
  )
)

;; Distribute seeds
(define-public (distribute-seeds
    (request-id uint)
  )
  (let
    (
      (request (unwrap! (map-get? seed-requests { id: request-id }) (err u404)))
      (new-id (+ (var-get last-distribution-id) u1))
    )
    ;; Check if request is in approved status
    (asserts! (is-eq (get status request) "approved") (err u400))

    ;; Update distribution ID counter
    (var-set last-distribution-id new-id)

    ;; Store seed distribution details
    (map-set seed-distributions
      { id: new-id }
      {
        request-id: request-id,
        distributor: tx-sender,
        recipient: (get requester request),
        seed-id: (get seed-id request),
        quantity: (get quantity request)
      }
    )

    ;; Update request status to fulfilled
    (map-set seed-requests
      { id: request-id }
      (merge request { status: "fulfilled" })
    )

    (ok new-id)
  )
)

;; Get seed request details
(define-read-only (get-seed-request (request-id uint))
  (map-get? seed-requests { id: request-id })
)

;; Get seed distribution details
(define-read-only (get-seed-distribution (distribution-id uint))
  (map-get? seed-distributions { id: distribution-id })
)

;; Get disaster mode status
(define-read-only (get-disaster-mode)
  (var-get disaster-mode)
)

;; Get disaster coordinator
(define-read-only (get-disaster-coordinator)
  (var-get disaster-coordinator)
)
