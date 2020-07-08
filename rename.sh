for full_path in **/rootfs/etc/cont-init.d/*.sh; do
  path=$(dirname $full_path)
  full_filename=$(basename $full_path)
  name=${full_filename#*-}
  number=${full_filename%-$name}
  single=${number#0}
  new_number=$(($single + 1))
  mv "$full_path" "$path/0$new_number-$name" 
done
