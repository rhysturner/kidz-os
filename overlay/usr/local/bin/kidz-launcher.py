#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont
from PyQt6.QtWidgets import QApplication, QGridLayout, QMessageBox, QPushButton, QWidget

CLICK_SOUND = "/usr/share/kidz-os/click.wav"
DEFAULT_URL = "https://pbskids.org"

APPS = [
    ("🎨\nTux Paint", ["tuxpaint"]),
    ("🧩\nGCompris", ["gcompris-qt"]),
    ("💻\nScratch", ["scratch"]),
    ("🌐\nSafe Web", ["firefox-esr", "--kiosk", DEFAULT_URL]),
]


class KidzLauncher(QWidget):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("Kidz OS")
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint | Qt.WindowType.WindowStaysOnTopHint
        )
        self.showFullScreen()
        self.build_ui()

    def build_ui(self) -> None:
        layout = QGridLayout()
        layout.setSpacing(24)
        layout.setContentsMargins(40, 40, 40, 40)
        self.setLayout(layout)
        self.setStyleSheet("background-color: #1f2a44;")

        colors = ["#FF6B6B", "#4ECDC4", "#FFD93D", "#6C5CE7"]

        for index, (label, command) in enumerate(APPS):
            button = QPushButton(label)
            button.setFont(QFont("Arial", 24, QFont.Weight.Bold))
            button.setMinimumSize(320, 220)
            button.setFocusPolicy(Qt.FocusPolicy.NoFocus)
            button.setStyleSheet(
                f"""
                QPushButton {{
                    background-color: {colors[index % len(colors)]};
                    color: white;
                    border-radius: 24px;
                    border: 4px solid white;
                }}
                QPushButton:pressed {{
                    background-color: #2d3436;
                }}
                """
            )
            button.clicked.connect(lambda _, cmd=command: self.launch_app(cmd))
            row = index // 2
            col = index % 2
            layout.addWidget(button, row, col)

    def play_click(self) -> None:
        aplay = shutil.which("aplay")
        if aplay and os.path.exists(CLICK_SOUND):
            subprocess.Popen(
                [aplay, "-q", CLICK_SOUND],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    def launch_app(self, command: list[str]) -> None:
        self.play_click()
        try:
            subprocess.Popen(command)
        except Exception as exc:
            QMessageBox.critical(self, "Launch Error", str(exc))

    def closeEvent(self, event) -> None:  # type: ignore[override]
        event.ignore()

    def keyPressEvent(self, event) -> None:  # type: ignore[override]
        event.ignore()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    launcher = KidzLauncher()
    launcher.show()
    sys.exit(app.exec())
