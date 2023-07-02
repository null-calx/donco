(def-table "users" (:text "Users" :poster "username" :hidden t :write-perm "admin" :plain t)
  ("userid"
   :pkey t)
  ("username"
   :type :text
   :poster t
   :unique t
   :required t
   :default "noone")
  ("password"
   :type :text
   :required t
   :read-perm "admin")
  ("emailid"
   :type :text
   :unique t
   :required t
   :read-perm "admin")
  ("roles"
   :type (:array :text)
   :internal t))

(def-table "rolepermissions" (:text "Roles" :poster "role" :hidden t :url "roles" :plain t)
  ("id"
   :pkey t)
  ("role"
   :type :text
   :poster t)
  ("permissions"
   :type (:array :text)))

(def-table "crops" (:text "Crops" :poster "cropname" :url "crops" :write-perm "crop-manager")
  ("cropid"
   :pkey t)
  ("cropname"
   :type :text
   :poster t))

(def-table "dailyharvest" (:text "Daily Harvest" :poster "harvestname" :url "daily-harvest" :write-perm "harvest-manager")
  ("harvestid"
   :pkey t)
  ("harvestname"
   :type :text
   :poster t)
  ("cropid"
   :type :uuid
   :fkey ("crops" "cropid" "cropname")))

(def-table "sorting" (:text "Sorting" :poster "sortname" :url "sorting" :write-perm "sort-manager")
  ("sortingid"
   :pkey t)
  ("sortname"
   :type :text
   :poster t)
  ("harvestid"
   :type :uuid
   :fkey ("dailyharvest" "harvestid" "harvestname")))
