;; Condition Verification Contract
;; Validates and records equipment condition

(define-map equipment-conditions
  uint
  {
    condition-rating: uint,
    inspection-date: uint,
    inspector: principal,
    notes: (string-utf8 500),
    last-maintenance: uint
  }
)

;; Map of authorized inspectors
(define-map authorized-inspectors principal bool)

;; Admin variable
(define-data-var admin principal tx-sender)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u300)
(define-constant ERR-NOT-INSPECTOR u301)
(define-constant ERR-INVALID-RATING u302)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Add an authorized inspector
(define-public (add-inspector (inspector principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (map-set authorized-inspectors inspector true))))

;; Remove an inspector
(define-public (remove-inspector (inspector principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (map-set authorized-inspectors inspector false))))

;; Record equipment condition
(define-public (verify-condition
                (equipment-id uint)
                (condition-rating uint)
                (notes (string-utf8 500))
                (last-maintenance uint))
  (begin
    (asserts! (default-to false (map-get? authorized-inspectors tx-sender)) (err ERR-NOT-INSPECTOR))
    (asserts! (<= condition-rating u10) (err ERR-INVALID-RATING))
    (ok (map-set equipment-conditions equipment-id
      {
        condition-rating: condition-rating,
        inspection-date: block-height,
        inspector: tx-sender,
        notes: notes,
        last-maintenance: last-maintenance
      }))))

;; Get equipment condition
(define-read-only (get-equipment-condition (equipment-id uint))
  (map-get? equipment-conditions equipment-id))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))))
