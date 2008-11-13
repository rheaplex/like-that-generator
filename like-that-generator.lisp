#!/usr/bin/sbcl

;; like-that-generator.lisp - Script to make Like That's works programatically.
;; Copyright (C) 2008  Rob Myers rob@robmyers.org
;;
;; This file is part of Like That.
;; 
;; Like That is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.
;; 
;; Like That is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *project-root-name* "processing-projects/"
  "The name of the project root folder.")

(defparameter *project-root* 
  (merge-pathnames (pathname *project-root-name*))
  "The folder to create for storing processing projects in.")

(defparameter *source-root* 
  (merge-pathnames (pathname "source/"))
  "The folder to copy .pde files from.")

(defparameter *resource-root* (pathname "resources/")
  "The folder to copy image (etc.) files from.")

(defparameter *media-folder* (pathname "data/")
  "The folder to copy image (etc.) files to.")

(defparameter *test-root* 
  (merge-pathnames (pathname "test/"))
  "The folder to copy .pde files into to test them.")

(defparameter *base-file* 
  (namestring (merge-pathnames (pathname "like_that_base.pde") *source-root*))
  "The basic code file. All-in-one.")

(defparameter *appearances* nil
  "Colours and other appearances for forms.")

(defparameter *forms* nil
  "Shapes, polygons and polyhedra for animation.")

(defparameter *form-resources* '()
  "The list of required media, if any, for each form strategy.")

(defparameter *animations* nil
  "The animation strategies.")

(defparameter *sequences* nil
  "The sequence strategies.")

(defparameter *clashes* nil
  "Combinations that are technically or aesthetically bad.")

(defparameter *works* '(("ghosts" white cube burst3d sequential) 
			("seance" white cube cluster3d sequential)
			("subjects" white square burst2d sequential) 
			("logistics" white square cluster2d sequential)
			("sometimes" white circle burst2d sequential) 
			("moments" white circle cluster2d sequential)
			("aesthetics" black cube burst3d sequential) 
			("market"  black cube cluster3d sequential)
			("empire" black square burst2d sequential) 
			("cliques"  black square cluster2d sequential)
			("epidemic" black circle burst2d sequential) 
			("cool" black circle cluster2d sequential)
			("citizens"  polychrome cube burst3d sequential) 
			("come_together" polychrome cube cluster3d sequential)
			("fashion" polychrome square burst2d sequential)
			("opinions" polychrome square cluster2d sequential)
			("scene" polychrome circle burst2d sequential)
			("show" polychrome circle cluster2d sequential) 
			("architecture"  neoplastic cube burst3d sequential)
			("society" neoplastic cube cluster3d sequential) 
			("systems" neoplastic square burst2d sequential)
			("design" neoplastic square cluster2d sequential)
			("transgression" neoplastic circle burst2d sequential)
			("normativity" neoplastic circle cluster2d sequential) 
			("laws" outline square burst2d sequential)
			("obligations" outline square cluster2d sequential) 
			("crime" outline circle burst2d sequential)
			("dissent" outline circle cluster2d sequential)
			("monopoly" transparentBlack cube burst3d sequential)
			("ideology" transparentBlack cube cluster3d sequential)
			("uniform" transparentBlack square burst2d sequential)
			("customs" transparentBlack square cluster2d sequential)
			("philosophy" transparentBlack circle burst2d 
			 sequential)
			("happening" transparentBlack circle cluster2d 
			 sequential)
			("structure" transparentPolychrome cube burst3d 
			 sequential)
			("psychogeography" transparentPolychrome cube cluster3d
			 sequential)
			("objects" transparentPolychrome square burst2d 
			 sequential)
			("commodities" transparentPolychrome square cluster2d 
			 sequential)
			("eventual" transparentPolychrome circle burst2d 
			 sequential)
			("happenstance" transparentPolychrome circle cluster2d 
			 sequential)
			("congress" flesh cube burst3d sequential)
			("dance"  flesh cube cluster3d sequential) 
			("mufti"  flesh square burst2d sequential)
			("party" flesh square cluster2d sequential) 
			("relational" flesh circle burst2d sequential)
			("gossip" flesh circle cluster2d sequential))
  "Names for works.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utilitites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun copy-file-into-stream (input-file-path output-stream)
  "Open the input file and copy it into the output stream."
  (with-open-file (input-stream input-file-path) 
    (let ((buf (make-array 4096 
			   :element-type (stream-element-type input-stream))))
	  (loop for pos = (read-sequence buf input-stream)
	     while (plusp pos)
	     do (write-sequence buf output-stream :end pos)))))


(defun copy-file (from to)
  "Copy the files, specified as absolute file paths."
  (with-open-file (to-stream to :direction :output 
			     :if-does-not-exist :create :if-exists :overwrite)
    (copy-file-into-stream from to-stream)))

(defun directory-pde-names (directory-path)
  "List any file names that end with .pde in the directory, stripping the .pde"
  (let ((directory-files (directory (merge-pathnames directory-path
						     (pathname "/*.pde")))))
    (mapcar #'pathname-name
	    directory-files)))

(defun first-line-of-file (file-path)
  "Open the file and get its first line as a string."
  (with-open-file (in file-path)
    (read-line in)))

(defun first-line-of-file-after-comment (file-path)
  "Open the file, assume it starts with '// ', get the rest of the line."
  (subseq (first-line-of-file file-path) 3))

(defun read-first-line-of-file-after-comment (file-path)
  "Parse the first line of the file after '// ' as a Lisp expression."
  (read-from-string (first-line-of-file-after-comment file-path)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Work specification properties
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun source-pde (kind name)
  "Make a pathname of the form ./sources/kind/.pde"
  (merge-pathnames (format nil "~a/~a.pde" kind name)
                   *source-root*))

(defun spec-name (spec)
  "Get or generate the name for the work specification"
  (or (dolist (work *works*)
	(when (equal spec (cdr work))
	  (return (car work))))
      (format nil "~a_~a_~a_~a" 
	      (first spec) (second spec) (third spec) (fourth spec))))

(defun spec-appearance (spec)
  (first spec))

(defun spec-appearance-file (spec)
  (namestring (merge-pathnames (source-pde "appearance" (spec-appearance spec))
			       *source-root*)))

(defun spec-form (spec)
  (second spec))

(defun spec-form-file (spec)
  (namestring (merge-pathnames (source-pde "form" (spec-form spec))
			       *source-root*)))

(defun spec-animation (spec)
  (third spec))

(defun spec-animation-file (spec)
  (namestring (merge-pathnames (source-pde "animation" (spec-animation spec))
			       *source-root*)))

(defun spec-sequence (spec)
  (fourth spec))

(defun spec-sequence-file (spec)
  (namestring (merge-pathnames (source-pde "sequence" (spec-sequence spec))
			       *source-root*)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun validate-work-specifications ()
  "Make sure we haven't misspelt a strategy or specified an unimplemented one."
  (dolist (work *works*)
    ;; TODO: Check for repeated work titles
    (assert (member (spec-appearance work) *appearances*))
    (assert (member (spec-form work) *forms*))
    (assert (member (spec-animation work) *animations*))
    (assert (member (spec-sequence work) *sequences*))))

(defun generate-all-possible-work-specifications ()
  "Generate every possible combination of appearance, form, and sequence."
  (let ((all '()))
    (dolist (appearance *appearances*)
      (dolist (form *forms*)
        (dolist (animation *animations*)
	  (dolist (sequence *sequences*)
	    (push (list appearance form animation sequence)
		   all)))))
    all))

(defun expand-clashes ()
  "List pairs of clashes between the first and other items of each clash list."
  (let ((expanded '())) 
    (dolist (clashlist *clashes*)
      (dolist (clashee (cdr clashlist))
	(push (cons (car clashlist) clashee) 
	      expanded)))
    expanded))

(defun clash-p (candidate clash-pair)
  "Does the candidate work spec list contain both cells of the pair of clashes?"
  (and (member (car clash-pair) candidate :test #'string-equal)
       (member (cdr clash-pair) candidate :test #'string-equal)))

(defun clashes-p (candidate clashes)
  "Does the candidate work spec list contain any of the pairs of clashes?"
  (let ((result nil)) 
    (dolist (clash clashes)
      (when (clash-p candidate clash)
	(setf result t)
	(return)))
    result))

(defun possible-work-specifications-without-clashes ()
  "Generate the list of possible work specs without clashes."
  (let ((possible-works (generate-all-possible-work-specifications))
	(clashes (expand-clashes))
	(results '()))
    (dolist (work possible-works)
	(unless (clashes-p work clashes)
	  (push work results)))
    results))

(defun print-unnamed-work-specifications ()
  "Print any possible work specs that aren't in the list of named works."
  (format t "Un-named possible combinations:~%")
  (let ((possible (possible-work-specifications-without-clashes)))
    (dolist (work *works*)
      (setf possible (remove (cdr work) possible :test #'equal)))
    (dolist (unused possible)
      (format t "  ~a~%" unused))))

(defun sanity-check ()
  "Make sure that the script has the correct environment and resources to run."
  ;; Make sure we are next to the folders we need
  (assert (probe-file *source-root*)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Work project creation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun copy-work-resources (work project-folder)
  "If the work needs any resources, make the media folder and copy them in."
  (let ((work-resources (assoc (spec-form work) *form-resources*)))
    (when work-resources
      (let ((work-media-folder (merge-pathnames (pathname "media/") 
						project-folder)))
        (ensure-directories-exist work-media-folder)
        (dolist (resource work-resources)
          (copy-file (merge-pathnames resource *resource-root*)
                     work-media-folder))))))

(defun project-folder-path (work)
  "Make a path string for the work's folder within the projects folder."
  (namestring (merge-pathnames (concatenate 'string
					    (spec-name work)
					    "/")
			       *project-root*)))

(defun project-main-pde-path (work)
  (namestring (merge-pathnames (format nil "~a.pde" (spec-name work))
			       (project-folder-path work))))

(defun generate-processing-project (work)
  "Make the project folder for the work and copy in the files it needs."
  (let ((project-folder (project-folder-path work)))
    (ensure-directories-exist project-folder)
    (format t "~a~%" (project-main-pde-path work))
    (with-open-file (pde (project-main-pde-path work) 
			 :direction :output 
			 :if-does-not-exist :create
			 :if-exists :overwrite)
      (copy-file-into-stream *base-file* pde)
      (copy-file-into-stream (spec-appearance-file work) pde)
      (copy-file-into-stream (spec-form-file work) pde)
      (copy-file-into-stream (spec-animation-file work) pde)
      (copy-file-into-stream (spec-sequence-file work) pde))
    (copy-work-resources work project-folder)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Test project creation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun test-folder-path (name)
  "Make a path string for the work's folder within the test folder."
  (namestring (merge-pathnames (concatenate 'string
					    name
					    "/")
			       *test-root*)))

(defun test-pde-path (name)
  "Make a path to the named pde in its forlder in the test directory."
  (namestring (merge-pathnames (format nil "~a.pde" name)
			       (test-folder-path name))))

(defun generate-test-project (kind name)
  "Make the project folder for the work and copy in the files it needs."
  (let ((project-folder (test-folder-path name)))
    (ensure-directories-exist project-folder)
    (with-open-file (pde (test-pde-path name) 
			 :direction :output 
			 :if-does-not-exist :create
			 :if-exists :overwrite)
;;    (copy-file-into-stream *base-file* pde)
      (copy-file-into-stream (merge-pathnames (format nil "~a/~a.pde" kind name)
					      *source-root*) pde))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project building
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun build-processing-project (file-path)
  "Build the project using our command-line hack of processing."
  ;; See http://dev.processing.org/bugs/show_bug.cgi?id=219 
  ;; and be prepared to cope with changes since then
  ;; This code is currently sbcl-only
  (let ((output (process-output (sb-ext:run-program 
				"./processing/build/linux/work/processing" 
				(list file-path)
				:output :stream
				:error :output))))
    (loop (let ((line (read-line output nil 'eof)))
	    (when (eq line 'eof)
	      (return))
	    (when (search "applet" line)
	      (format t "~a~%" line))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main program structure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun backup-existing-projects-folder ()
  "If there's an existing projects folder, move it aside."
  (when (probe-file *project-root*)
    (rename-file *project-root*
		 (merge-pathnames (format nil
					  "projects-backup.~a"
					  (get-universal-time))))))

(defun populate-pde-lists ()
  (setf *animations* 
	(directory-pde-names (merge-pathnames (pathname "animation/")
					      *source-root*)))
  (setf *appearances*
	(directory-pde-names (merge-pathnames (pathname "appearance/")
					      *source-root*)))
  (setf *forms*
	(directory-pde-names (merge-pathnames (pathname "form/")
					      *source-root* )))
  (setf *sequences*
	(directory-pde-names (merge-pathnames (pathname "sequence/") 
					      *source-root* ))))

(defun read-form-clashes ()
  "Get the list of pdes that each form clashes with."
  (dolist (form *forms*)
    (let ((first-line
	   (read-first-line-of-file-after-comment
	    (merge-pathnames (format nil "form/~a.pde" form)
			     *source-root*))))
      (when (eq (car first-line) :clashes)
	(push (cons form (cdr first-line))
	      *clashes*)))))

(defun test-source-file-kinds (kind names)
  (dolist (name names)
    (format t "Test building: ~a~%" name)
    (generate-test-project kind name)
    (build-processing-project (test-pde-path name))))

(defun test-source-files ()
  (ensure-directories-exist *test-root*)
  (test-source-file-kinds "animation" *animations*)
  (test-source-file-kinds "appearance" *appearances*)
  (test-source-file-kinds "form" *forms*)
  (test-source-file-kinds "sequence" *sequences*))

(defun make-processing-projects ()
  "Make the projects folder then make a project for each work."
  (ensure-directories-exist *project-root*)
  (let* ((works-to-make (possible-work-specifications-without-clashes))
    (total (length works-to-make))
    (count 0))
  (dolist (work works-to-make)
    (incf count)
    (format t "Making: ~d/~d: ~a~%" count total(spec-name work))
    (generate-processing-project work)
    (build-processing-project (project-main-pde-path work)))))

(defun write-index ()
  (format t "Writing html index of works.~%")
  (with-open-file (index (merge-pathnames (pathname "index.html")) 
			 :direction :output 
			 :if-does-not-exist :create 
			 :if-exists :overwrite)
    (format index "<html><head><title>Like That</title></head><body>")
    (dolist (project (possible-work-specifications-without-clashes))
      (format index "<p><a href=\"./processing-projects/~a/applet/index.html\">~a</a></p>"
	      (spec-name project) (spec-name project)))
    (format index "</body></html>")))

(defun make-works ()
  "The main entry point for the script."
  (sanity-check)
  (backup-existing-projects-folder)
  (populate-pde-lists)
  (read-form-clashes)
  (print-unnamed-work-specifications)
;;(test-source-files)
  (make-processing-projects)
  (write-index))

;; Run the script.
;; (make-works)