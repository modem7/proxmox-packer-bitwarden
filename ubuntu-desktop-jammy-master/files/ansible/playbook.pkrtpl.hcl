---
# playbook.yml
- name: 'Provision Image'
  hosts: default
  become: true
  vars:
    - swap_file_path: ${swap_file_path}
    - swap_file_size_mb: ${swap_file_size_mb}
    - swap_swappiness: ${swap_swappiness}
    - swap_file_state: ${swap_file_state}
    - swap_file_create_command: dd if=/dev/zero of={{ swap_file_path }} bs=1M count={{ swap_file_size_mb }}
  roles:
#    - postfix
    - swap