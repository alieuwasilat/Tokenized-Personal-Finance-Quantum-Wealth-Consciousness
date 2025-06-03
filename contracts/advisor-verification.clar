;; Advisor Verification Contract
;; Validates quantum wealth consciousness advisors

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ADVISOR_EXISTS (err u101))
(define-constant ERR_ADVISOR_NOT_FOUND (err u102))

;; Data structures
(define-map advisors
  { advisor: principal }
  {
    verified: bool,
    consciousness-level: uint,
    certification-date: uint,
    specialization: (string-ascii 50)
  }
)

(define-map advisor-stats
  { advisor: principal }
  {
    clients-helped: uint,
    success-rate: uint,
    quantum-score: uint
  }
)

;; Public functions
(define-public (register-advisor (specialization (string-ascii 50)))
  (let ((advisor tx-sender))
    (asserts! (is-none (map-get? advisors { advisor: advisor })) ERR_ADVISOR_EXISTS)
    (map-set advisors
      { advisor: advisor }
      {
        verified: false,
        consciousness-level: u1,
        certification-date: block-height,
        specialization: specialization
      }
    )
    (map-set advisor-stats
      { advisor: advisor }
      {
        clients-helped: u0,
        success-rate: u0,
        quantum-score: u0
      }
    )
    (ok advisor)
  )
)

(define-public (verify-advisor (advisor principal) (consciousness-level uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? advisors { advisor: advisor })) ERR_ADVISOR_NOT_FOUND)
    (map-set advisors
      { advisor: advisor }
      (merge
        (unwrap-panic (map-get? advisors { advisor: advisor }))
        { verified: true, consciousness-level: consciousness-level }
      )
    )
    (ok true)
  )
)

(define-public (update-quantum-score (advisor principal) (new-score uint))
  (begin
    (asserts! (is-some (map-get? advisors { advisor: advisor })) ERR_ADVISOR_NOT_FOUND)
    (map-set advisor-stats
      { advisor: advisor }
      (merge
        (default-to { clients-helped: u0, success-rate: u0, quantum-score: u0 }
                   (map-get? advisor-stats { advisor: advisor }))
        { quantum-score: new-score }
      )
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-advisor-info (advisor principal))
  (map-get? advisors { advisor: advisor })
)

(define-read-only (get-advisor-stats (advisor principal))
  (map-get? advisor-stats { advisor: advisor })
)

(define-read-only (is-verified-advisor (advisor principal))
  (match (map-get? advisors { advisor: advisor })
    advisor-data (get verified advisor-data)
    false
  )
)
