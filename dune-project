(lang dune 3.20)

(name mdexp)

(generate_opam_files)

(license "LGPL-3.0-or-later WITH LGPL-3.0-linking-exception")

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/mdexp))

(documentation "https://mbarbin.github.io/mdexp/")

(implicit_transitive_deps false)

(package
 (name mdexp)
 (synopsis "Literate Programming with Embedded Snapshots")
 (depends
  (ocaml
   (>= 5.3))
  (cmdlang
   (>= 0.0.10))
  (cmdlang-cmdliner-err-runner
   (>= 0.0.16))
  (dune-build-info
   (>= 3.20))
  (dyn
   (>= 3.20))
  (fpath
   (>= 0.7.3))
  (loc
   (>= 0.3.3))
  (ordering
   (>= 3.20))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.17))
  (pplumbing-pp-tty
   (>= 0.0.17))
  (sexplib0
   (>= v0.17))
  (yojson
   (>= 3.0.0))
  (yojson-five
   (>= 3.0.0))))

(package
 (name mdexp-tests)
 (synopsis "Tests for mdexp")
 (depends
  (ocaml
   (>= 5.3))
  (mdexp
   (= :version))
  (pplumbing-err
   (>= 0.0.17))
  (ppx_expect
   (>= v0.17))
  (ppx_windtrap
   (>= 0.1.0))
  (ppxlib
   (>= 0.37.0))
  (print-table
   (>= 0.1.3))
  (windtrap
   (>= 0.1.0))
  (yojson
   (>= 3.0.0))
  (yojson-five
   (>= 3.0.0))))

(package
 (name mdexp-dev)
 (synopsis "Package to regroup dev targets, documentation, and more")
 (allow_empty)
 (depends
  (ocaml
   (>= 5.3))
  (ocamlformat
   (= 0.29.0))
  (bisect_ppx
   (>= 2.8.3))
  (mdexp
   (= :version))
  (mdexp-tests
   (= :version))
  (ppx_windtrap
   (>= 0.1.0))
  (ppxlib
   (>= 0.37.0))
  (windtrap
   (>= 0.1.0))
  (odoc
   (>= 3.0.0))))
