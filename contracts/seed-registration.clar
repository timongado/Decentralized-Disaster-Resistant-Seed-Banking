;; Seed Variety Registration Contract
;; Records details of locally adapted crops

(define-data-var last-seed-id uint u0)

(define-map seed-varieties
  { id: uint }
  {
    name: (string-ascii 100),
    species: (string-ascii 100),
    variety: (string-ascii 100),
    origin: (string-ascii 100),
    drought-resistant: bool,
    flood-resistant: bool,
    pest-resistant: bool,
    registrar: principal
  }
)

;; Register a new seed variety
(define-public (register-seed
    (name (string-ascii 100))
    (species (string-ascii 100))
    (variety (string-ascii 100))
    (origin (string-ascii 100))
    (drought-resistant bool)
    (flood-resistant bool)
    (pest-resistant bool)
  )
  (let
    (
      (new-id (+ (var-get last-seed-id) u1))
    )
    ;; Update seed ID counter
    (var-set last-seed-id new-id)

    ;; Store seed variety details
    (map-set seed-varieties
      { id: new-id }
      {
        name: name,
        species: species,
        variety: variety,
        origin: origin,
        drought-resistant: drought-resistant,
        flood-resistant: flood-resistant,
        pest-resistant: pest-resistant,
        registrar: tx-sender
      }
    )

    (ok new-id)
  )
)

;; Get seed variety details
(define-read-only (get-seed-variety (seed-id uint))
  (map-get? seed-varieties { id: seed-id })
)

;; Get total seed varieties count
(define-read-only (get-seed-count)
  (var-get last-seed-id)
)
