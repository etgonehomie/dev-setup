#!/bin/bash
set -euo pipefail

bash tests/test_main_sh.sh
bash tests/test_ansible.sh
bash tests/test_zshrc.sh
