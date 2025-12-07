#!/usr/bin/env python3
"""
Cardano Community Activities - Python Backend Entry Point
IPC-based service for Electron app
"""

import sys
import json
import os
import time
import logging
import threading

# Setup logging to stderr
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stderr
)
logger = logging.getLogger('python_backend')

# Add paths for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from python_backend.api import call_api

def send_message(status, message=None, **extra):
    """Send JSON message to Electron via stdout"""
    data = {
        "status": status,
        "timestamp": time.time(),
        **extra
    }
    if message:
        data["message"] = message
    print(json.dumps(data))
    sys.stdout.flush()

def listen_for_commands():
    """Listen for JSON commands from Electron on stdin"""
    logger.info("Listening for commands from Electron...")
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            
            try:
                command = json.loads(line.strip())
                action = command.get("action")
                params = command.get("params", {})
                request_id = command.get("id", 0)
                
                logger.info(f"Received command: {action} (id: {request_id})")
                
                # Execute the API call
                result = call_api(action, params)
                result["id"] = request_id
                
                send_message("response", **result)
                
            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON: {e}")
                send_message("error", f"Invalid JSON: {str(e)}")
        
        except Exception as e:
            logger.error(f"Error in command handler: {e}", exc_info=True)
            send_message("error", str(e))

def main():
    try:
        logger.info("Python backend starting...")
        
        # Try to import backend modules
        try:
            from python_backend.modules import key_generator
            from python_backend.utils import bip39
            logger.info("Backend modules loaded successfully")
        except ImportError as e:
            logger.warning(f"Some modules not available: {e}")
        
        # Send ready signal
        send_message("ready", "Python backend ready for commands")
        
        # Start listening for commands in a thread
        command_thread = threading.Thread(target=listen_for_commands, daemon=True)
        command_thread.start()
        
        # Keep main thread alive
        logger.info("Backend is ready and listening")
        while True:
            time.sleep(1)
    
    except KeyboardInterrupt:
        logger.info("Received interrupt signal")
        send_message("stopping", "Backend shutting down")
        sys.exit(0)
    except Exception as e:
        error_msg = str(e)
        logger.error(f"Fatal error: {error_msg}", exc_info=True)
        send_message("error", error_msg)
        sys.exit(1)

if __name__ == "__main__":
    main()


