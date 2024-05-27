# Python Remote Shell Access

This Python script sets up secure, remote  shell access to your machine directly from your web browser. It uses SSH tunneling and  the `ttyd` terminal emulator to provide a seamless command-line experience within a web page.

## Features

- **Secure SSH Tunnel:** Establishes  a reverse SSH tunnel to `localhost.run`, making a local port securely accessible over the internet.
- **ttyd Integration:** Automatically downloads, installs ( if necessary), and runs the `ttyd` terminal emulator, giving you a browser-based terminal.
- **Password Protection:** Implements a simple password authentication mechanism to protect your shell access.
- **Customizable Theme:**  Applies  a visually appealing dark theme to the `ttyd` terminal interface.
- **Google Colab Integration:** Optionally, embeds the terminal directly into your Google Colab notebooks using an `IFrame`.

## Requirements

- ** Python 3:** Make sure you have Python 3 installed on your system.
- **SSH Client:** You need an SSH client installed and configured on your machine (e.g., OpenSSH).
- **localhost.run Account:** Create a free account at [https://localhost.run](https://localhost .run) to utilize their SSH tunneling service.

## Usage

**General Usage**

1. **Clone the Repository:** Clone this repository to your computer.
2. **Install Dependencies:** While in the project directory, install the required Python packages using: `pip install -r requirements.txt` 
 3. **Run the Script:** Execute the Python script: `python your-script-name.py`

**Incredibly Simple Google Colab Usage**

1. **Open a Colab Notebook:** Create or open a Google Colab notebook.
2. **Paste & Run:** Copy and paste the following  code into a code cell and execute it:

   ```bash
   !pip install git+https://github.com/0wwafa/shell &>/dev/null && echo OK || echo Fail.
   from shell import shell
   shell(True)
