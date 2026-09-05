import http.server
import os
import socketserver
import threading

PORT = 8080
# The absolute path to your updated project files
TARGET_DIRECTORY = r"C:\Users\rory\OneDrive\Desktop\LUA for HBM"


class DynamicDeployerHandler(http.server.SimpleHTTPRequestHandler):

    def __init__(self, request, client_address, server, filepath):
        self.filepath = filepath
        super().__init__(request, client_address, server)

    def do_GET(self):
        try:
            # Read your native Lua file exactly as it is written
            with open(self.filepath, "r") as file:
                lua_payload = file.read()

        except Exception as e:
            lua_payload = f'print("Error reading file on desktop: {str(e)}");'

        # Send the raw Lua code directly to your OpenComputers client
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(lua_payload.encode("utf-8"))
        print(f"\n[SUCCESS]: Sent Lua script to Minecraft deploy.lua!")

        # Shutdown server immediately to stop loops
        threading.Thread(target=self.server.shutdown).start()


# --- INTERACTIVE USER INTERFACE ---
print("=" * 60)
print("             SURVIVAL SYNC LUA PIPELINE RUNNING             ")
print("=" * 60)

# Ensure the directory exists
if not os.path.exists(TARGET_DIRECTORY):
    os.makedirs(TARGET_DIRECTORY)

# Scan the directory specifically for files ending in .lua
all_files = [f for f in os.listdir(TARGET_DIRECTORY) if f.endswith(".lua")]

selected_filepath = None

if not all_files:
    print(f"No .lua files found in: {TARGET_DIRECTORY}")
    print("Please add a .lua script to the folder and restart this program.")
    exit()
else:
    print("Available Lua programs in your HBM folder:")
    for idx, filename in enumerate(all_files, 1):
        print(f"  [{idx}] {filename}")
    print("-" * 60)

    # Prompt user by number or exact name [cite: 9]
    choice = input(
        "Enter the number or the file name you want to run: "
    ).strip()

    # Check if user typed a number selection [cite: 9]
    if choice.isdigit() and 1 <= int(choice) <= len(all_files):
        chosen_file = all_files[int(choice) - 1]
    else:
        # If they typed a name, ensure it has .lua
        chosen_file = choice if choice.endswith(".lua") else choice + ".lua"

    selected_filepath = os.path.join(TARGET_DIRECTORY, chosen_file)

# Spin up the server hosting the selected file
handler_factory = lambda *args, **kwargs: DynamicDeployerHandler(
    *args, filepath=selected_filepath, **kwargs
)

try:
    with socketserver.TCPServer(("127.0.0.1", PORT), handler_factory) as httpd:
        print(
            f"\n[READY]: Open Minecraft and run 'deploy' to execute: {os.path.basename(selected_filepath)}"
        )
        httpd.serve_forever()
except Exception as e:
    print(f"Server error: {e}")