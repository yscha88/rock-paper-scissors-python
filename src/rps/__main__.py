"""``python -m rps`` 로 실행할 수 있게 하는 패키지 진입점."""
from .cli import main

raise SystemExit(main())
