## Create a custom Alpine ISO ##

### Prerequisites ###

- Docker (for building the ISO)

- qemu-system-x86_64 binary (for testing the ISO)

### Create the ISO

* Update the `version` file with the Alpine version you want to use.

* To generate a custom ISO with this script, modify `create-iso.in` according with
the following document: [Create custom ISO with Alpine](https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage)

The relevant sections that you may want to customize are:

The name of the profile:
```export PROFILENAME=console_enable```

The script that generates the ISO:
```
cat << EOF > mkimg.${PROFILENAME}.sh
profile_${PROFILENAME}() {
        profile_extended
        kernel_cmdline="$kernel_cmdline console=ttyS0,115200"
        syslinux_serial="0 115200"
        local _k _a
        for _k in \$kernel_flavors; do
                apks="\$apks linux-\$_k"
                for _a in \$kernel_addons; do
                        apks="\$apks \$_a-\$_k"
                done
        done
        apks="\$apks linux-firmware"
}
EOF
```

## Run the script ##

```make build``` : use Docker to build an image to create the ISO

```make run``` : from the previsous created image, run a container that creates the ISO in the `./iso` folder

```make test``` : verify if the ISO boots correctly with the serial enabled

```make clean``` : remove all generated files and docker image

## NOTE ##

This script is done to create an ISO with console enabled by default.

To sign the image, the container uses a generated keys at runtime. At the moment, signing the ISO with your keys is not (yet) supported

The `make test` command, test specifically if the ISO boots and starts with the console enabled. Any other tests are not (yet) implemented.

There is not (yet) support for generated ```apkovl``` 
