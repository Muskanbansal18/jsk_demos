#!/usr/bin/env roseus

(load "models/room610-scene.l")
(load "package://pr2eus/pr2.l")
(load "package://pr2eus/pr2-interface.l")
(load "models/room73b2-broom-object.l")
(load "models/room610-scene.l")
;;(load "open-laundry.l")

(setq debug nil)

(if (not (boundp '*room610*)) (room610))
(if (not (boundp '*pr2*)) (pr2))
(if (not (boundp '*ri*)) (setq *ri* (instance pr2-interface :init :objects (send *room610* :objects))))

;;handle
#|
(setq *broom-handle2* (make-cascoords :pos (float-vector 0.0 0.0 600.0)
                                      :rot #2f((0.5 -0.866025 0.0) (0.866025 0.5 0.0) (0.0 0.0 1.0))
                                      :name "handle2"))
(send *broom* :assoc *broom-handle2*)
(defmethod room73b2-broom-object
  (:handle-handle2 () *broom-handle2*)
  (:handle () (list handle0 handle1 *broom-handle2*)))
|#

(objects (list *room610* *pr2*))

(setq *room610-origin* "/eng8/6f/room610")
(setq *table-coords* (make-coords :pos #f(4700 1000 0) :rpy (float-vector -pi/2 0 0)))
(setq *chair-coords* (make-coords :pos #f(3800 0 0)))

(setq *broom* (send *room610* :object "room610-sweeper"))
(setq *chair* (send *room610* :object "room610-chair"))
(setq *laundry* (send *room610* :object "room610-laundry-machine"))
(send *laundry* :translate #f(39.927 201.466 -85) :world)

;; spots
(setq *tray-spot* (make-cascoords :pos #f(4650 1000 0) :rpy (list -pi/2 0 0)))
(send *room610* :assoc *tray-spot*)
(setq *chair-spot* (make-cascoords :pos #f(3200 0 0) :rpy (list 0 0 0)))
(send *room610* :assoc *chair-spot*)
;;(setq *laundry-spot* (make-cascoords :pos #f(3400 1400 0) :rpy (list pi/2 0 0)))
(setq *laundry-spot* (make-cascoords :pos #f(3359.927 1601.466 0) :rpy (list pi/2 0 0)))
(send *room610* :assoc *laundry-spot*)
(setq *sink-spot* (make-cascoords :pos #f(7300 200 0) :rpy (list 0 0 0)))
(send *room610* :assoc *sink-spot*)
(setq *sweep-spot* (make-cascoords :pos #f(3750 200 0) :rpy (list (deg2rad -30) 0 0)))
(send *room610* :assoc *sweep-spot*)

(defmethod room610-scene
  (:spot-tray-spot () *tray-spot*)
  (:spot-chair-spot () *chair-spot*)
  (:spot-laundry-spot () *laundry-spot*)
  (:spot-sink-spot () *sink-spot*)
  (:spot-sweep-spot () *sweep-spot*)
  (:spots ()
          (list *tray-spot* *chair-spot* *laundry-spot* *sink-spot* *sweep-spot*)))


;(send *broom* :move-to (make-coords :pos #f(3050 2050 0) :rpy (list pi/2 0 (deg2rad 5))) :world)


(load "package://jsk_2013_04_pr2_610/euslisp/pick-broom.l")
(load "package://jsk_2013_04_pr2_610/euslisp/put-cloth-into-laundry.l")


(defun move-to-table ()
  (warn "move-to-table~%")
  (pr2-tuckarm-pose)
  (send *ri* :angle-vector (send *pr2* :angle-vector) 4000)
 ; (send *ri* :move-to *table-coords* :frame-id *room610-origin*)
  (send *pr2* :move-to (send *room610* :spot-tray-spot) :world)
  (send *ri* :move-to (send *room610* :spot-tray-spot))
  )

(defun pick-tray ()
  (warn "pick-tray (tanaka)~%")
  )

(defun move-to-sink ()
  (warn "move-to-sink~%")
;  (pr2-tuckarm-pose)
;  (send *ri* :angle-vector (send *pr2* :angle-vector) 4000)
  (send *pr2* :move-to (send *room610* :spot-sink-spot) :world)
  (send *ri* :move-to (send *room610* :spot-sink-spot))
  )

(defun place-tray ()
  (warn "place-tray (chan)~%")
  )

(defun move-to-chair ()
  (warn "move-to-chair~%")
;  (send *ri* :move-to *chair-coords* :frame-id *room610-origin*)
  (send *ri* :angle-vector (send *pr2* :angle-vector) 4000)
  (send *pr2* :move-to (send *room610* :spot-chair-spot) :world)
  (send *ri* :move-to (send *room610* :spot-chair-spot))
  )

(defun pick-cloth ()
  (warn "pick-cloth (iwaishi)~%")
  )

(defun move-to-laundry ()
  (warn "move-to-laundry~%")
 ; (pr2-tuckarm-pose)
 ; (send *ri* :angle-vector (send *pr2* :angle-vector) 4000)
  (send *pr2* :move-to (send *room610* :spot-laundry-spot) :world)
  (send *ri* :move-to (send *room610* :spot-laundry-spot))
  )

;; (defun open-laundry-door ()
;;   (warn "open-laundry-door (kuroiwa)~%"))

;; (defun put-cloth ()
;;   (warn "put-cloth (kuroiwa)~%")
;;   )

;; (defun close-laundry-door ()
;;   (warn "close-laundry-door (kuroiwa)~%")
;;   )


(defun move-chair ()
  (warn "move-chair (inagaki)~%")
  ;; use handle to manipulate
  (send *pr2* :reset-pose) ;; to solve ik, do not  send to *ri*
  (send *pr2* :inverse-kinematics (send (send (send *chair* :handle-above-rarm) :copy-worldcoords) :translate #f(0 -200 500) :world)
        :link-list (list
                      (send *pr2* :link-list (send *pr2* :rarm :end-coords :parent)))
        :move-target (list (send *pr2* :rarm :end-coords))
        :look-at-target t
                :debug-view t
        )

  (send *ri* :wait-interpolation)
  (send *ri* :stop-grasp)
  (send *ri* :wait-interpolation)


;;(send *pr2* :reset-pose) ;; to solve ik, do not  send to *ri*
  (send *pr2* :inverse-kinematics (list (send *chair* :handle-above-rarm))
        :link-list (list
                      (send *pr2* :link-list (send *pr2* :rarm :end-coords :parent)))
        :move-target (list (send *pr2* :rarm :end-coords))
        :look-at-target t
		:debug-view t
        ) 
  (send *ri* :wait-interpolation)

  (send (send *pr2* :r_wrist_roll_link) :assoc *chair*)
  (send *ri* :angle-vector (send *pr2* :angle-vector))
  (send *ri* :start-grasp)
  (send *ri* :wait-interpolation)



(setq destC (send (send *pr2* :rarm :end-coords) :copy-worldcoords))
(send destC :translate #f(-250 0 -200) :world)
(send destC :rotate (deg2rad -45) :y :world)



(send *pr2* :inverse-kinematics destC
        :link-list (list
                      (send *pr2* :link-list (send *pr2* :rarm :end-coords :parent)))
        :move-target (list (send *pr2* :rarm :end-coords))
        :look-at-target t
                :debug-view t
        )
  (send *ri* :wait-interpolation)

  (send *ri* :angle-vector (send *pr2* :angle-vector))
  (send *ri* :wait-interpolation)



  ;; backword
  (send *ri* :go-pos-unsafe -0.7 -0.3 0)
  ;;(send *pr2* :rotate (deg2rad -30) :z)
  (send *pr2* :translate #f(-700 -300 0))
  (send *ri* :wait-interpolation)
  
  (send (send *pr2* :r_wrist_roll_link) :dissoc *chair*)
  (send *ri* :stop-grasp)
  (send *ri* :wait-interpolation)
  )

(defun move-to-sweep ()
  (warn "move-to-sweep~%")
  (send *pr2* :move-to (send *room610* :spot-sweep-spot) :world)
  (send *ri* :move-to (send *room610* :spot-sweep-spot)))

(defun sweep-under-table ()
  (warn "sweep-under-table (yukizaki)~%")
  )

(defun pass-broom-to-right-hand ()
  (warn "pass-broom-to-right-hand~%"))

(defun sweep-floor ()
  (warn "sweep-floor (furuta)~%")
  )


(defun demo ()
  (if (not debug)
      (progn
        (send *irtviewer* :draw-objects)
        (move-to-table)
        (send *irtviewer* :draw-objects)
        (pick-tray)
        (send *irtviewer* :draw-objects)
        (move-to-sink)
        (send *irtviewer* :draw-objects)
        (place-tray)
        (send *irtviewer* :draw-objects)
        (move-to-chair)
        (send *irtviewer* :draw-objects)
        (pick-cloth)
        (send *irtviewer* :draw-objects)
        (move-to-laundry)
        (send *irtviewer* :draw-objects)
        (send *irtviewer* :draw-objects)
        ;; (put-cloth)
        ;; (send *irtviewer* :draw-objects)
        ;; (close-laundry-door)
        ;; (send *irtviewer* :draw-objects)
        (pick-broom)
        (send *irtviewer* :draw-objects)
        (move-to-chair)
        (send *irtviewer* :draw-objects)
        (move-chair)
        (send *irtviewer* :draw-objects)
        (move-to-sweep)
        (send *irtviewer* :draw-objects)
        (sweep-under-table)
        (send *irtviewer* :draw-objects)
        (sweep-floor)
        (send *irtviewer* :draw-objects)
        ))
  (put-cloth-into-laundry)
  )

(warn "type (demo) to start~%")