import plistlib
from pathlib import Path

from patch_info_plist import patch_info_plist

USAGE_TEXT = (
    'Serve per avvisarti degli autovelox mentre guidi, '
    'anche con lo schermo bloccato.'
)


def _write_sample(path: Path) -> None:
    with path.open('wb') as f:
        plistlib.dump({'CFBundleName': 'allerta_velox', 'CFBundleVersion': '1'}, f)


def _load(path: Path) -> dict:
    with path.open('rb') as f:
        return plistlib.load(f)


def test_patch_adds_background_location_and_usage_texts(tmp_path):
    plist = tmp_path / 'Info.plist'
    _write_sample(plist)

    patch_info_plist(str(plist))

    data = _load(plist)
    assert data['UIBackgroundModes'] == ['location']
    assert data['NSLocationWhenInUseUsageDescription'] == USAGE_TEXT
    assert data['NSLocationAlwaysAndWhenInUseUsageDescription'] == USAGE_TEXT


def test_patch_keeps_other_keys(tmp_path):
    plist = tmp_path / 'Info.plist'
    _write_sample(plist)

    patch_info_plist(str(plist))

    data = _load(plist)
    assert data['CFBundleName'] == 'allerta_velox'
    assert data['CFBundleVersion'] == '1'


def test_patch_twice_gives_same_file(tmp_path):
    plist = tmp_path / 'Info.plist'
    _write_sample(plist)

    patch_info_plist(str(plist))
    after_one = plist.read_bytes()
    patch_info_plist(str(plist))

    assert plist.read_bytes() == after_one
