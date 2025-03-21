;; Viability Testing Contract
;; Schedules and records germination tests

(define-data-var last-test-id uint u0)

(define-map viability-tests
  { id: uint }
  {
    seed-id: uint,
    sample-size: uint,
    germinated-count: uint,
    germination-rate: uint,
    tester: principal,
    status: (string-ascii 20) ;; "scheduled", "completed"
  }
)

;; Schedule a viability test
(define-public (schedule-test
    (seed-id uint)
    (sample-size uint)
  )
  (let
    (
      (new-id (+ (var-get last-test-id) u1))
    )
    ;; Update test ID counter
    (var-set last-test-id new-id)

    ;; Store viability test details
    (map-set viability-tests
      { id: new-id }
      {
        seed-id: seed-id,
        sample-size: sample-size,
        germinated-count: u0,
        germination-rate: u0,
        tester: tx-sender,
        status: "scheduled"
      }
    )

    (ok new-id)
  )
)

;; Complete a viability test
(define-public (complete-test
    (test-id uint)
    (germinated-count uint)
  )
  (let
    (
      (test (unwrap! (map-get? viability-tests { id: test-id }) (err u404)))
      (sample-size (get sample-size test))
      (germination-rate (if (> sample-size u0)
                          (/ (* germinated-count u100) sample-size)
                          u0))
    )
    ;; Check if caller is the tester
    (asserts! (is-eq tx-sender (get tester test)) (err u403))

    ;; Check if germinated count is valid
    (asserts! (<= germinated-count sample-size) (err u400))

    ;; Update test with results
    (map-set viability-tests
      { id: test-id }
      (merge test {
        germinated-count: germinated-count,
        germination-rate: germination-rate,
        status: "completed"
      })
    )

    (ok true)
  )
)

;; Get viability test details
(define-read-only (get-viability-test (test-id uint))
  (map-get? viability-tests { id: test-id })
)
