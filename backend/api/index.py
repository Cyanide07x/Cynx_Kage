import sys
from pathlib import Path

# Add backend directory to sys.path so 'app' module can be resolved regardless of execution context
BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from app.main import app
