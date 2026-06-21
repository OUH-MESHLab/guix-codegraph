;;; guix-codegraph --- Guix channel for CodeGraph code-intelligence CLI
;;; Copyright © 2026 Rafael Palomar <rafael.palomar@ous-research.no>
;;;
;;; This file is part of guix-codegraph.
;;;
;;; guix-codegraph is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 3 of the License, or (at your option)
;;; any later version.
;;;
;;; guix-codegraph is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License along
;;; with guix-codegraph.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;;
;;; Node.js 22.16.0 — the minimum required by codegraph's FTS5 dependency.
;;; node:sqlite's bundled SQLite first enables FTS5 in Node 22.16.0; the
;;; upstream gnu node-lts (22.14.0) is missing it and causes a runtime error
;;; on `CREATE VIRTUAL TABLE ... USING fts5`.  This derivation inherits
;;; node-lts and changes only the version string and source hash.
;;;
;;; Code:

(define-module (guix-codegraph packages node-runtime)
  #:use-module (gnu packages node)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

;; Node 22.16.0 — first 22.x whose bundled node:sqlite enables FTS5,
;; which codegraph's schema requires.  Inherits node-lts (22.14.0); only
;; the version and source hash change.
(define-public node-22.16.0
  (package
    (inherit node-lts)
    (version "22.16.0")
    (source
     (origin
       (inherit (package-source node-lts))
       (uri (string-append "https://nodejs.org/dist/v" version
                           "/node-v" version ".tar.gz"))
       (sha256
        (base32 "1cnsxcjp7b6s38bif8cndi76x1plc3x43vxkcjs07hcwyw7jb3qh"))))))
