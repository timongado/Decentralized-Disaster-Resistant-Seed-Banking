;; Storage Condition Monitoring Contract
;; Tracks temperature and humidity for seed storage

(define-data-var last-storage-id uint u0)
(define-data-var last-reading-id uint u0)

(define-map storage-locations
  { id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    manager: principal,
    active: bool
  }
)

(define-map condition-readings
  { id: uint }
  {
    storage-id: uint,
    temperature: int,
    humidity: uint,
    recorder: principal
  }
)

;; Register a new storage location
(define-public (register-storage
    (name (string-ascii 100))
    (location (string-ascii 100))
  )
  (let
    (
      (new-id (+ (var-get last-storage-id) u1))
    )
    ;; Update storage ID counter
    (var-set last-storage-id new-id)

    ;; Store storage location details
    (map-set storage-locations
      { id: new-id }
      {
        name: name,
        location: location,
        manager: tx-sender,
        active: true
      }
    )

    (ok new-id)
  )
)

;; Record a new condition reading
(define-public (record-condition
    (storage-id uint)
    (temperature int)
    (humidity uint)
  )
  (let
    (
      (new-id (+ (var-get last-reading-id) u1))
    )
    ;; Update reading ID counter
    (var-set last-reading-id new-id)

    ;; Store condition reading
    (map-set condition-readings
      { id: new-id }
      {
        storage-id: storage-id,
        temperature: temperature,
        humidity: humidity,
        recorder: tx-sender
      }
    )

    (ok new-id)
  )
)

;; Get storage location details
(define-read-only (get-storage-location (storage-id uint))
  (map-get? storage-locations { id: storage-id })
)

;; Get condition reading details
(define-read-only (get-condition-reading (reading-id uint))
  (map-get? condition-readings { id: reading-id })
)
