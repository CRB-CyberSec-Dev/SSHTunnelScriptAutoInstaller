```markdown
# SSH Stunnel Auto Installer Script

This script automatically installs and configures an SSH Stunnel SSL environment on Ubuntu 18.04.2 LTS. It sets up essential components including OpenSSL, Dropbear, Squid, Stunnel, and BadVPN.

## Features

- **OpenSSL**: Secure Socket Layer (SSL) library.
- **Dropbear**: Lightweight SSH server.
- **Squid**: Caching and forwarding HTTP web proxy.
- **Stunnel**: SSL tunneling service.
- **BadVPN**: UDP tunneling for VPN.

## Prerequisites

- Ubuntu 18.04.2 LTS
- Root user access

## Installation

1. **Clone the Repository**

   ```sh
   git clone <repository_url>
   cd <repository_directory>
   ```

2. **Make the Script Executable**

   ```sh
   chmod +x sshauto
   ```

3. **Run the Installer**

   ```sh
   ./sshauto install
   ```

   Follow the prompts to enter required information such as IP address and SSL certificate details.

## User Management

To create a new user:

```sh
./sshauto user
```

Follow the prompts to enter the username and password.

## Autostart Configuration

To configure BadVPN to start automatically:

```sh
./sshauto autostart
```

## Service Information

- **Protocols**: TCP & UDP
- **Dropbear Ports**: 444, 143
- **SSL Port**: 443
- **Proxy Port**: 3128

## Managing BadVPN Service

- Enable the service:

  ```sh
  sudo systemctl enable crbssh.service
  ```

- Start the service:

  ```sh
  sudo systemctl start crbssh.service
  ```

- Check the status of the service:

  ```sh
  sudo systemctl status crbssh.service
  ```

## Important Notes

- After the installation is complete, reboot the system for the first time.
- Ensure all security measures are in place, such as proper firewall configurations and SSH key authentication.

## Contact

For more information, visit my YouTube channel: [CRB](http://www.youtube.com/@crbchamalbandara).

---

**Developed by**: ChamalBandara (CRB-CyberSec-Dev)

## Contributing

Feel free to contribute to this project by submitting issues or pull requests. Ensure that any new features or bug fixes come with appropriate tests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Buy me a coffee...........!

**BTC :- bc1q90c30lrgcclsd9pmyqpxjecyphg7y0f2grf74u**

<a href="#" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

```
