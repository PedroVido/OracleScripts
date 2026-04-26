view io wait on OS disks

-- com root 
iostat -xm 5 5

iostat 1 -x disk1,disk2 ... disk n

iostat 1 -x sdbx,dm-3,dm-6