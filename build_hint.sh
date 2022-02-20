# Key maps to edit are located at ./config/dao_{left,right}.keymap
set -e
set -x
# Enter virtual environment
poetry install
poetry shell
# Build Zephyr SDK
west init ./zephyrproject
cd zephyrproject
west update
west zephyr-export
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.13.2/zephyr-sdk-0.13.2-linux-x86_64-setup.run
sudo ./zephyr-sdk-0.13.2-linux-x86_64-setup.run -- -d /opt/zephyr-sdk-0.13.2
rm ./zephyr-sdk-0.13.2-linux-x86_64-setup.run
# Allow to build without root privileges
sudo cp /opt/zephyr-sdk-0.13.2/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
sudo udevadm control --reload
# Go back
cd ..
# Setup project
west init -l config
west update
west zephyr-export
# Build keymaps for left and right side
for side in {left,right}; do
    west build -p -s zmk/app -b dao_${side} -d dao_${side} -- -DZMK_CONFIG="$(pwd)/config"
done
# Get the firmware files and then manually flash
cp dao_left/zephyr/zmk.uf2 dist/dao_left.uf2
cp dao_right/zephyr/zmk.uf2 dist/dao_right.uf2
