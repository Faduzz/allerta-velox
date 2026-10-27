"""Corregge l'Info.plist generato da `flutter create` per il GPS in background."""
import plistlib
import sys
from pathlib import Path

USAGE_TEXT = (
    'Serve per avvisarti degli autovelox mentre guidi, '
    'anche con lo schermo bloccato.'
)


def patch_info_plist(path: str) -> None:
    plist_path = Path(path)
    with plist_path.open('rb') as f:
        data = plistlib.load(f)

    data['UIBackgroundModes'] = ['location']
    data['NSLocationWhenInUseUsageDescription'] = USAGE_TEXT
    data['NSLocationAlwaysAndWhenInUseUsageDescription'] = USAGE_TEXT

    with plist_path.open('wb') as f:
        plistlib.dump(data, f)


if __name__ == '__main__':
    patch_info_plist(sys.argv[1])
