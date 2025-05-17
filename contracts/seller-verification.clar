;; Seller Verification Contract
;; This contract validates equipment owners before they can list items

(define-data-var admin principal tx-sender)

;; Map to track verified sellers
(define-map verified-sellers principal bool)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ALREADY-VERIFIED u101)
(define-constant ERR-NOT-VERIFIED u102)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Verify a seller
(define-public (verify-seller (seller principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (default-to false (map-get? verified-sellers seller))) (err ERR-ALREADY-VERIFIED))
    (ok (map-set verified-sellers seller true))))

;; Revoke seller verification
(define-public (revoke-verification (seller principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (default-to false (map-get? verified-sellers seller)) (err ERR-NOT-VERIFIED))
    (ok (map-set verified-sellers seller false))))

;; Check if a seller is verified
(define-read-only (is-verified (seller principal))
  (default-to false (map-get? verified-sellers seller)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))))
