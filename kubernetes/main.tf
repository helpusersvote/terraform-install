resource "template_dir" "huv_manifests" {
  source_dir = "${var.manifest_dir}"
  destination_dir = "${var.render_dir}"
}


data "external" "manifest_files" {
  program = [
    "/bin/bash", 
    "-c",
    <<EOF
# Start JSON Object
printf "{" >> test

# Add entries
for f in `find ${template_dir.huv_manifests.destination_dir} -maxdepth 1 -type f`; do
  if [ -v started ]; then
    printf ',' >>test
  fi
  printf '"%q": "' $f >> test
  kubectl convert 
  started=true
done

printf '}' >> test
EOF
  ]
}

