SUDO_LOCAL="/etc/pam.d/sudo_local"
PAM_LINE="auth       sufficient     pam_tid.so"

if ! grep -q "^${PAM_LINE}" "${SUDO_LOCAL}" 2>/dev/null; then
  if [[ ! -f "${SUDO_LOCAL}" ]]; then
    sudo cp /etc/pam.d/sudo_local.template "${SUDO_LOCAL}"
  fi
  sudo sed -i '' "s|^#${PAM_LINE}|${PAM_LINE}|" "${SUDO_LOCAL}"
  if ! grep -q "^${PAM_LINE}" "${SUDO_LOCAL}"; then
    echo "${PAM_LINE}" | sudo tee -a "${SUDO_LOCAL}" >/dev/null
  fi
fi
