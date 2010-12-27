#!/usr/bin/clisp

(do ((line (read-line) (read-line)))
    (() ())
    (format t "~A~%" line)
)
