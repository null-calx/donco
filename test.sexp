(def-table "users" (:text "Users" :poster "username" :hidden t :write-perm "admin" :plain t)
  ("userid" :pkey t)
  ("username" :type :text :poster t :unique t :required t)
  ("password" :type :text :required t :read-perm "admin")
  ("emailid" :type :text :unique t :required t :read-perm "admin")
  ("roles" :type (:array :text) :internal t))

(def-table "rolepermissions" (:text "Roles" :url "roles" :poster "role" :hidden t :plain t)
  ("id" :pkey t)
  ("role" :type :text :poster t)
  ("permissions" :type (:array :text)))

(def-table "crops" ()
  ("id" :pkey t)
  ("name" :type :text)
  ("variety" :type :text)
  ("sowingdate" :type :date)
  ("area" :type :number :unit "meter^2"))

(def-table "harvest" ()
  ("id" :pkey t)
  ("date" :type :date)
  ("starttime" :type :time)
  ("endtime" :type :time)
  ("quantity" :type :integer :unit "kg")
  ("labourcost" :type :integer :unit "rupees"))

(def-table "sorting" ()
  ("id" :pkey t)
  ("harvestid" :fkey ("harvest" "date"))
  ("date" :type :date)
  ("starttime" :type :time)
  ("endtime" :type :time)
  ("totalquantity" :type :integer :unit "kg")
  ("quantitydiscarded" :type :integer :unit "kg")
  ("quantitystoredforlater" :type :integer :unit "kg")
  ("labourcost" :type :integer :unit "rupees"))

(def-table "washing" ()
  ("id" :pkey t)
  ("sortingid" :fkey ("sorting" "date"))
  ("date" :type :date)
  ("starttime" :type :time)
  ("endtime" :type :time)
  ("totalquantity" :type :integer :unit "kg")
  ("water_ph" :type (:decimal 4 2) :unit "pH")
  ("water_temp" :type (:decimal 5 2) :unit "deg C"))

(def-table "processing" ()
  ("id" :pkey t)
  ("washingid" :fkey ("washing" "date"))
  ("date" :type :date)
  ("starttime" :type :time)
  ("endtime" :type :time)
  ("totalquantity" :type :integer :unit "kg"))
