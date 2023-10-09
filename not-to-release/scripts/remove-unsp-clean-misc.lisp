(ql:quickload :cl-conllu)
(ql:quickload :cl-ppcre)

(in-package :conllu.user)


(defun remove-feature (key features)
  (format nil "~{~a~^|~}" (remove-if (lambda (x) (string-equal key (car (split-sequence #\= x))))
				     (split-sequence #\| features))))

(defun remove-feats (key val features)
  (format nil "~{~a~^|~}" (remove-if (lambda (x) (and (string-equal key (car (split-sequence #\= x)))
						      (string-equal val (cadr (split-sequence #\= x)))))
				     (split-sequence #\| features))))

(defun remove-d2d (misc)
  (format nil "~{~a~^|~}" (remove-if (lambda (x) (string-equal "d2d" (car (split-sequence #\: x))))
				     (split-sequence #\| misc))))

(defun fix-conllu (sentences)
  (dolist (s sentences sentences)
    (dolist (tk (sentence-mtokens s))
      (setf (slot-value tk 'misc) (remove-d2d (slot-value tk 'misc)))
      (setf (slot-value tk 'misc) (remove-feature "ChangedBy" (slot-value tk 'misc)))
      (when (or (= 0 (length (slot-value tk 'misc))) (null (slot-value tk 'misc)))
        (setf (slot-value tk 'misc) "_")))
    (dolist (tk (sentence-tokens s))
      (setf (slot-value tk 'misc) (remove-d2d (slot-value tk 'misc)))
      (setf (slot-value tk 'feats) (remove-feats "Gender" "Unsp" (slot-value tk 'feats)))
      (setf (slot-value tk 'feats) (remove-feats "Number" "Unsp" (slot-value tk 'feats)))
      (setf (slot-value tk 'feats) (remove-feats "Number" "Neut" (slot-value tk 'feats)))
      (setf (slot-value tk 'misc) (remove-feature "ChangedBy" (slot-value tk 'misc)))
      (when (or (= 0 (length (slot-value tk 'misc))) (null (slot-value tk 'misc)))
        (setf (slot-value tk 'misc) "_")))
    (setf (sentence-meta s)
          (remove "d2d" (sentence-meta s) :test #'string= :key #'car))))

(defun run ()
  (dolist (f (directory #p "documents/*.conllu"))
    (write-conllu (fix-conllu (read-conllu f)) f)))
