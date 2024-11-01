#  Quick Start

1.  **Clone the repository:**
    ```bash
    $ git clone https://github.com/yourusername/flask-duckdns-automate.git
    ```

2.  **Make the script executable:**
    ```bash
    chmod +x flask-duckdns-setup.sh
    ```

3.  **Run the script:**
    ```bash
    ./flask-duckdns-setup.sh
    ```

4.  **Alternative method:**
    *   Create a `.env` file in the root directory.
    *   Add your secret values to the file:
    
        ```
        DUCKDNS_SUBDOMAIN=your_subdomain
        DUCKDNS_TOKEN=your_token
        FLASK_APP_NAME=your_flask_app_name
        FLASK_APP_DIR=path/to/your/flask/app
        USER=username
        VENV_PATH=path/to/your/venv
        EMAIL=your_email
        ```
        
    * Then these values can be set in the current bash shell by simply sourcing the file as
    
        ```bash
        source .env
       ```


## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
